unit PipeManager;

interface

uses
  Windows, SysUtils, Types, PluginAPI;

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

constructor TPipeManager.Create(AEngine: IL2Control; const ACharName: string);
begin
  inherited Create;
  FEngine := AEngine;
  FCharacterName := Sanitize(ACharName);
  FPipes.Command := INVALID_HANDLE_VALUE;
  FPipes.Response := INVALID_HANDLE_VALUE;
  FPipes.Action := INVALID_HANDLE_VALUE;
  FPipes.Packet := INVALID_HANDLE_VALUE;
  FPipes.CliPacket := INVALID_HANDLE_VALUE;
end;

destructor TPipeManager.Destroy;
begin
  if FPipes.Command <> INVALID_HANDLE_VALUE then CloseHandle(FPipes.Command);
  if FPipes.Response <> INVALID_HANDLE_VALUE then CloseHandle(FPipes.Response);
  if FPipes.Action <> INVALID_HANDLE_VALUE then CloseHandle(FPipes.Action);
  if FPipes.Packet <> INVALID_HANDLE_VALUE then CloseHandle(FPipes.Packet);
  if FPipes.CliPacket <> INVALID_HANDLE_VALUE then CloseHandle(FPipes.CliPacket);
  inherited;
end;

function TPipeManager.Sanitize(const S: string): string;
var i: Integer;
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
begin
  FullName := Format('\\.\pipe\l2bot_%s_%s', [BaseName, FCharacterName]);

  InitializeSecurityDescriptor(@SD, SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorDacl(@SD, True, nil, False);

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
end;

function TPipeManager.Initialize: Boolean;
begin
  FPipes.Command := CreatePipe('commands', True);
  FPipes.Response := CreatePipe('responses', False);
  FPipes.Action := CreatePipe('actions', False);
  FPipes.Packet := CreatePipe('packets', False);
  FPipes.CliPacket := CreatePipe('clipackets', False);

  Result := (FPipes.Command <> INVALID_HANDLE_VALUE) and (FPipes.Response <> INVALID_HANDLE_VALUE);
end;

function TPipeManager.ReadFromPipe(PipeHandle: THandle; var Data: string): Boolean;
var
  Buffer: array[0..BUFFER_SIZE-1] of Byte;
  BytesRead, Available: DWORD;
  UTF8: UTF8String;
begin
  Result := False;
  if PipeHandle = INVALID_HANDLE_VALUE then Exit;
  if not PeekNamedPipe(PipeHandle, nil, 0, nil, @Available, nil) then Exit;
  if Available = 0 then Exit;

  if ReadFile(PipeHandle, Buffer, BUFFER_SIZE, BytesRead, nil) and (BytesRead > 0) then
  begin
    SetLength(UTF8, BytesRead);
    Move(Buffer[0], UTF8[1], BytesRead);
    Data := string(UTF8);
    Result := True;
  end;
end;

function TPipeManager.SendToPipe(PipeHandle: THandle; const Data: AnsiString): Boolean;
var BytesWritten: DWORD;
begin
  Result := False;
  if (PipeHandle <> INVALID_HANDLE_VALUE) and (Length(Data) > 0) then
    Result := WriteFile(PipeHandle, Data[1], Length(Data), BytesWritten, nil);
end;

function TPipeManager.ReconnectPipe(var PipeHandle: THandle; const BaseName: string; Inbound: Boolean): Boolean;
begin
  Result := False;

  if PipeHandle <> INVALID_HANDLE_VALUE then
  begin
    DisconnectNamedPipe(PipeHandle);
    CloseHandle(PipeHandle);
    PipeHandle := INVALID_HANDLE_VALUE;
  end;

  PipeHandle := CreatePipe(BaseName, Inbound);
  Result := (PipeHandle <> INVALID_HANDLE_VALUE);
end;

end.
