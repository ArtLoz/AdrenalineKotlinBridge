unit PipeManager;

interface

uses
  Windows, SysUtils, Types, PluginAPI, Logger;

type
  TPipeManager = class
  private
    FEngine: IL2Control;
    FCharacterName: string;
    function CreatePipe(const BaseName: string; Inbound: Boolean): THandle;
    function Sanitize(const S: string): string;
  public
    FPipes: TPipeHandles;
    constructor Create(AEngine: IL2Control; const ACharName: string);
    destructor Destroy; override;

    function Initialize: Boolean;
    function ReadFromPipe(PipeHandle: THandle; var Data: string): Boolean;
    function SendToPipe(PipeHandle: THandle; const Data: AnsiString): Boolean;
    function ReconnectPipe(var PipeHandle: THandle; const BaseName: string; Inbound: Boolean): Boolean;

    property Pipes: TPipeHandles read FPipes;
  end;

implementation

// Константы ошибок Windows
const
  ERROR_BAD_PIPE = 230;
  ERROR_PIPE_NOT_CONNECTED = 233;
  ERROR_PIPE_LISTENING = 536; // Добавили код 536

constructor TPipeManager.Create(AEngine: IL2Control; const ACharName: string);
begin
  try
    inherited Create;
    FEngine := AEngine;
    FCharacterName := Sanitize(ACharName);

    TraceFmt('TPipeManager initialized for char: "%s" (Sanitized: "%s")', [ACharName, FCharacterName]);

    FPipes.Command := INVALID_HANDLE_VALUE;
    FPipes.Response := INVALID_HANDLE_VALUE;
    FPipes.Action := INVALID_HANDLE_VALUE;
    FPipes.Packet := INVALID_HANDLE_VALUE;
    FPipes.CliPacket := INVALID_HANDLE_VALUE;
  except
    on E: Exception do
    begin
      TraceException('TPipeManager.Create', E);
      raise;
    end;
  end;
end;

destructor TPipeManager.Destroy;
  procedure SafeClose(var Handle: THandle; const Name: string);
  begin
    if Handle <> INVALID_HANDLE_VALUE then
    begin
      TraceFmt('Closing pipe handle for %s: %d', [Name, Handle]);
      CloseHandle(Handle);
      Handle := INVALID_HANDLE_VALUE;
    end;
  end;
begin
  try
    SafeClose(FPipes.Command, 'Command');
    SafeClose(FPipes.Response, 'Response');
    SafeClose(FPipes.Action, 'Action');
    SafeClose(FPipes.Packet, 'Packet');
    SafeClose(FPipes.CliPacket, 'CliPacket');
    inherited;
  except
    on E: Exception do
      TraceException('TPipeManager.Destroy', E);
  end;
end;

function TPipeManager.Sanitize(const S: string): string;
var
  i: Integer;
begin
  Result := S;
  for i := 1 to Length(Result) do
    if not (Result[i] in ['a'..'z', 'A'..'Z', '0'..'9', '_']) then Result[i] := '_';
end;

function TPipeManager.CreatePipe(const BaseName: string; Inbound: Boolean): THandle;
var
  FullName: string;
  Access: Cardinal;
  SA: TSecurityAttributes;
  SD: TSecurityDescriptor;
  ErrCode: DWORD;
begin
  try
    FullName := Format('\\.\pipe\l2bot_%s_%s', [BaseName, FCharacterName]);

    if not InitializeSecurityDescriptor(@SD, SECURITY_DESCRIPTOR_REVISION) then
    begin
      TraceError('CreatePipe', 'InitializeSecurityDescriptor failed: ' + SysErrorMessage(GetLastError));
    end;

    if not SetSecurityDescriptorDacl(@SD, True, nil, False) then
    begin
      TraceError('CreatePipe', 'SetSecurityDescriptorDacl failed: ' + SysErrorMessage(GetLastError));
    end;

    SA.nLength := SizeOf(SA);
    SA.lpSecurityDescriptor := @SD;
    SA.bInheritHandle := False;

    if Inbound then
      Access := PIPE_ACCESS_DUPLEX
    else
      Access := PIPE_ACCESS_OUTBOUND;

    Result := CreateNamedPipe(PChar(FullName), Access,
      PIPE_TYPE_MESSAGE or PIPE_READMODE_MESSAGE or PIPE_WAIT,
      PIPE_UNLIMITED_INSTANCES, BUFFER_SIZE, BUFFER_SIZE, 0, @SA);

    if Result = INVALID_HANDLE_VALUE then
    begin
      ErrCode := GetLastError;
      TraceError('CreatePipe', Format('Failed to create pipe "%s". Error [%d]: %s',
        [FullName, ErrCode, SysErrorMessage(ErrCode)]));
    end;

  except
    on E: Exception do
    begin
      TraceException('TPipeManager.CreatePipe', E);
      Result := INVALID_HANDLE_VALUE;
    end;
  end;
end;

function TPipeManager.Initialize: Boolean;
begin
  try
    FPipes.Command := CreatePipe('commands', True);
    FPipes.Response := CreatePipe('responses', False);
    FPipes.Action := CreatePipe('actions', False);
    FPipes.Packet := CreatePipe('packets', False);
    FPipes.CliPacket := CreatePipe('clipackets', False);

    Result := (FPipes.Command <> INVALID_HANDLE_VALUE) and (FPipes.Response <> INVALID_HANDLE_VALUE);

    if not Result then
      TraceError('TPipeManager.Initialize', 'Failed to create one or more critical pipes.');

  except
    on E: Exception do
    begin
      TraceException('TPipeManager.Initialize', E);
      Result := False;
    end;
  end;
end;

function TPipeManager.ReadFromPipe(PipeHandle: THandle; var Data: string): Boolean;
var
  Buffer: array[0..BUFFER_SIZE-1] of Byte;
  BytesRead, Available: DWORD;
  UTF8: UTF8String;
  ErrCode: DWORD;
begin
  Result := False;

  if PipeHandle = INVALID_HANDLE_VALUE then Exit;

  if not PeekNamedPipe(PipeHandle, nil, 0, nil, @Available, nil) then
  begin
    ErrCode := GetLastError;
    if (ErrCode <> ERROR_BROKEN_PIPE) and
       (ErrCode <> ERROR_BAD_PIPE) and
       (ErrCode <> ERROR_PIPE_NOT_CONNECTED) then
      TraceError('ReadFromPipe', Format('PeekNamedPipe failed. Handle: %d. Error [%d]: %s',
        [PipeHandle, ErrCode, SysErrorMessage(ErrCode)]));
    Exit;
  end;

  if Available = 0 then Exit;

  if ReadFile(PipeHandle, Buffer, BUFFER_SIZE, BytesRead, nil) then
  begin
    if BytesRead > 0 then
    begin
      try
        SetLength(UTF8, BytesRead);
        Move(Buffer[0], UTF8[1], BytesRead);
        Data := string(UTF8);
        Result := True;
      except
        on E: Exception do
          TraceException('ReadFromPipe (Conversion)', E);
      end;
    end;
  end
  else
  begin
    ErrCode := GetLastError;
    if (ErrCode <> ERROR_BROKEN_PIPE) and
       (ErrCode <> ERROR_BAD_PIPE) and
       (ErrCode <> ERROR_PIPE_NOT_CONNECTED) then
      TraceError('ReadFromPipe', Format('ReadFile failed. Handle: %d. Error [%d]: %s',
        [PipeHandle, ErrCode, SysErrorMessage(ErrCode)]));
  end;
end;

function TPipeManager.SendToPipe(PipeHandle: THandle; const Data: AnsiString): Boolean;
var
  BytesWritten: DWORD;
  ErrCode: DWORD;
begin
  Result := False;
  try
    if PipeHandle = INVALID_HANDLE_VALUE then
    begin
      TraceError('SendToPipe', 'Attempt to write to INVALID_HANDLE_VALUE');
      Exit;
    end;

    if Length(Data) = 0 then Exit;

    if WriteFile(PipeHandle, Data[1], Length(Data), BytesWritten, nil) then
    begin
      Result := True;
    end
    else
    begin
      ErrCode := GetLastError;
      // Добавили ERROR_PIPE_LISTENING (536) в исключения
      if (ErrCode <> ERROR_BROKEN_PIPE) and
         (ErrCode <> ERROR_NO_DATA) and
         (ErrCode <> ERROR_PIPE_LISTENING) then
        TraceError('SendToPipe', Format('WriteFile failed. Handle: %d. Error [%d]: %s',
          [PipeHandle, ErrCode, SysErrorMessage(ErrCode)]));
    end;
  except
    on E: Exception do
      TraceException('TPipeManager.SendToPipe', E);
  end;
end;

function TPipeManager.ReconnectPipe(var PipeHandle: THandle; const BaseName: string; Inbound: Boolean): Boolean;
begin
  Result := False;
  try
    if PipeHandle <> INVALID_HANDLE_VALUE then
    begin
      DisconnectNamedPipe(PipeHandle);
      CloseHandle(PipeHandle);
      PipeHandle := INVALID_HANDLE_VALUE;
    end;

    PipeHandle := CreatePipe(BaseName, Inbound);
    Result := (PipeHandle <> INVALID_HANDLE_VALUE);
  except
    on E: Exception do
      TraceException('TPipeManager.ReconnectPipe', E);
  end;
end;

end.
