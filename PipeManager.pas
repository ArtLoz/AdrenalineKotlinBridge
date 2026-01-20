unit PipeManager;

{
  Управление Named Pipes:
  - Создание INBOUND/OUTBOUND пайпов
  - Чтение/запись данных
  - Автоматическое закрытие при уничтожении
}

interface

uses
  Windows, SysUtils, Types, PluginAPI;

type
  TPipeManager = class
  private
    FEngine: IL2Control;
    FCharacterName: string;
    FPipes: TPipeHandles;
    
    function CreateInboundPipe(const BaseName: string): THandle;
    function CreateOutboundPipe(const BaseName: string): THandle;
    
  public
    constructor Create(AEngine: IL2Control; const ACharName: string);
    destructor Destroy; override;
    
    function Initialize: Boolean;
    function ReadFromPipe(PipeHandle: THandle; var Data: string): Boolean;
    function SendToPipe(PipeHandle: THandle; const Data: AnsiString): Boolean;
    
    property Pipes: TPipeHandles read FPipes;
  end;

implementation


constructor TPipeManager.Create(AEngine: IL2Control; const ACharName: string);
begin
  inherited Create;
  FEngine := AEngine;
  FCharacterName := ACharName;
  
  FPipes.Command := INVALID_HANDLE_VALUE;
  FPipes.Response := INVALID_HANDLE_VALUE;
  FPipes.Action := INVALID_HANDLE_VALUE;
  FPipes.Packet := INVALID_HANDLE_VALUE;
  FPipes.CliPacket := INVALID_HANDLE_VALUE;
end;

destructor TPipeManager.Destroy;
begin
  if FPipes.Command <> INVALID_HANDLE_VALUE then
    CloseHandle(FPipes.Command);
  if FPipes.Response <> INVALID_HANDLE_VALUE then
    CloseHandle(FPipes.Response);
  if FPipes.Action <> INVALID_HANDLE_VALUE then
    CloseHandle(FPipes.Action);
  if FPipes.Packet <> INVALID_HANDLE_VALUE then
    CloseHandle(FPipes.Packet);
  if FPipes.CliPacket <> INVALID_HANDLE_VALUE then
    CloseHandle(FPipes.CliPacket);
    
  inherited;
end;

function TPipeManager.CreateInboundPipe(const BaseName: string): THandle;
var
  PipeName: string;
  sa: SECURITY_ATTRIBUTES;
  sd: SECURITY_DESCRIPTOR;
begin
  PipeName := '\\.\pipe\' + BaseName + '_' + FCharacterName;

  InitializeSecurityDescriptor(@sd, SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorDacl(@sd, True, nil, False);
  
  sa.nLength := SizeOf(SECURITY_ATTRIBUTES);
  sa.lpSecurityDescriptor := @sd;
  sa.bInheritHandle := False;
  
  Result := CreateNamedPipe(
    PChar(PipeName),
    PIPE_ACCESS_INBOUND,
    PIPE_TYPE_MESSAGE or PIPE_READMODE_MESSAGE or PIPE_NOWAIT,
    PIPE_UNLIMITED_INSTANCES,
    BUFFER_SIZE,
    BUFFER_SIZE,
    0,
    @sa
  );
  
  if Result <> INVALID_HANDLE_VALUE then
    FEngine.Msg('PipeManager', 'Created INBOUND: ' + PipeName)
  else
    FEngine.Msg('PipeManager', 'FAILED INBOUND: ' + PipeName + ' Error=' + IntToStr(GetLastError));
end;

function TPipeManager.CreateOutboundPipe(const BaseName: string): THandle;
var
  PipeName: string;
  sa: SECURITY_ATTRIBUTES;
  sd: SECURITY_DESCRIPTOR;
begin
  PipeName := '\\.\pipe\' + BaseName + '_' + FCharacterName;
  
  InitializeSecurityDescriptor(@sd, SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorDacl(@sd, True, nil, False);
  
  sa.nLength := SizeOf(SECURITY_ATTRIBUTES);
  sa.lpSecurityDescriptor := @sd;
  sa.bInheritHandle := False;
  
  Result := CreateNamedPipe(
    PChar(PipeName),
    PIPE_ACCESS_OUTBOUND,
    PIPE_TYPE_MESSAGE or PIPE_READMODE_MESSAGE or PIPE_NOWAIT,
    PIPE_UNLIMITED_INSTANCES,
    BUFFER_SIZE,
    BUFFER_SIZE,
    0,
    @sa
  );
  
  if Result <> INVALID_HANDLE_VALUE then
    FEngine.Msg('PipeManager', 'Created OUTBOUND: ' + PipeName)
  else
    FEngine.Msg('PipeManager', 'FAILED OUTBOUND: ' + PipeName + ' Error=' + IntToStr(GetLastError));
end;

function TPipeManager.Initialize: Boolean;
begin
  Result := False;
  
  FPipes.Command := CreateInboundPipe('l2bot_commands');
  FPipes.Response := CreateOutboundPipe('l2bot_responses');
  FPipes.Action := CreateOutboundPipe('l2bot_actions');
  FPipes.Packet := CreateOutboundPipe('l2bot_packets');
  FPipes.CliPacket := CreateOutboundPipe('l2bot_clipackets');
  
  if (FPipes.Command = INVALID_HANDLE_VALUE) or
     (FPipes.Response = INVALID_HANDLE_VALUE) or
     (FPipes.Action = INVALID_HANDLE_VALUE) or
     (FPipes.Packet = INVALID_HANDLE_VALUE) or
     (FPipes.CliPacket = INVALID_HANDLE_VALUE) then
  begin
    FEngine.Msg('PipeManager', 'ERROR: Failed to create all pipes!');
    Exit;
  end;
  
  FEngine.Msg('PipeManager', 'All 5 pipes created successfully!');
  Result := True;
end;

function TPipeManager.ReadFromPipe(PipeHandle: THandle; var Data: string): Boolean;
var
  Buffer: array[0..BUFFER_SIZE-1] of Byte;
  BytesRead: DWORD;
  Available: DWORD;
  UTF8Str: UTF8String;
begin
  Result := False;
  if PipeHandle = INVALID_HANDLE_VALUE then Exit;
  
  if not PeekNamedPipe(PipeHandle, nil, 0, nil, @Available, nil) then
    Exit;
    
  if Available = 0 then
    Exit;
  
  Result := ReadFile(PipeHandle, Buffer, BUFFER_SIZE, BytesRead, nil);
  if Result and (BytesRead > 0) then
  begin
    SetString(UTF8Str, PAnsiChar(@Buffer[0]), BytesRead);
    Data := UTF8ToString(UTF8Str);
  end;
end;

function TPipeManager.SendToPipe(PipeHandle: THandle; const Data: AnsiString): Boolean;
var
  BytesWritten: DWORD;
begin
  Result := False;
  if PipeHandle = INVALID_HANDLE_VALUE then Exit;
  Result := WriteFile(PipeHandle, PAnsiChar(Data)^, Length(Data), BytesWritten, nil);
end;

end.
