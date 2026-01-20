unit CommandProcessor;


interface

uses
  Windows, SysUtils, Types, PluginAPI, PipeManager;

type
  TCommandProcessor = class
  private
    FEngine: IL2Control;
    FPipeManager: TPipeManager;
    FCommandThread: THandle;
    FCommandThreadID: Cardinal;
    FStopRequested: Boolean;
    
    function GetJsonValue(const Json, Key: string): string;
    function ExecuteCommand(const CommandJson: string): AnsiString;
    
  public
    constructor Create(AEngine: IL2Control; APipeManager: TPipeManager);
    destructor Destroy; override;
    
    function Start: Boolean;
    procedure Stop;

    property ThreadID: Cardinal read FCommandThreadID;
  end;

function CommandThreadProc(P: Pointer): DWORD; stdcall;

implementation

var
  GlobalProcessor: TCommandProcessor;


constructor TCommandProcessor.Create(AEngine: IL2Control; APipeManager: TPipeManager);
begin
  inherited Create;
  FEngine := AEngine;
  FPipeManager := APipeManager;
  FStopRequested := False;
  FCommandThread := 0;
end;

destructor TCommandProcessor.Destroy;
begin
  Stop;
  inherited;
end;

function TCommandProcessor.GetJsonValue(const Json, Key: string): string;
var
  StartPos, EndPos: Integer;
  SearchStr: string;
begin
  Result := '';
  SearchStr := '"' + Key + '":"';
  StartPos := Pos(SearchStr, Json);
  if StartPos = 0 then Exit;
  
  StartPos := StartPos + Length(SearchStr);
  EndPos := StartPos;
  
  while (EndPos <= Length(Json)) and (Json[EndPos] <> '"') do
    Inc(EndPos);
    
  Result := Copy(Json, StartPos, EndPos - StartPos);
end;

function TCommandProcessor.ExecuteCommand(const CommandJson: string): AnsiString;
var
  Cmd: string;
begin
  try
    Cmd := GetJsonValue(CommandJson, 'cmd');

    if Cmd = 'Ping' then
      Result := '{"status":"ok","data":"pong"}'
    else if Cmd = 'GetUserName' then
      Result := AnsiString('{"status":"ok","data":"' + FEngine.User.Name + '"}')
    else if Cmd = 'GetUserHP' then
      Result := AnsiString('{"status":"ok","data":' + IntToStr(FEngine.User.CurHP) + '}')
    else if Cmd = 'GetUserMP' then
      Result := AnsiString('{"status":"ok","data":' + IntToStr(FEngine.User.CurMP) + '}')
    else if Cmd = 'GetUserLevel' then
      Result := AnsiString('{"status":"ok","data":' + IntToStr(FEngine.User.Level) + '}')
    else if Cmd = 'GetUserXYZ' then
      Result := AnsiString('{"status":"ok","data":{"x":' + IntToStr(FEngine.User.X) + 
                ',"y":' + IntToStr(FEngine.User.Y) + 
                ',"z":' + IntToStr(FEngine.User.Z) + '}}')

    else if Cmd = 'Say' then
    begin
      FEngine.Say(GetJsonValue(CommandJson, 'text'));
      Result := '{"status":"ok","data":"Message sent"}';
    end

    else
      Result := '{"status":"error","message":"Unknown command: ' + Cmd + '"}';
    
  except
    on E: Exception do
      Result := AnsiString('{"status":"error","message":"' + E.Message + '"}');
  end;
end;

function TCommandProcessor.Start: Boolean;
begin
  Result := False;
  
  FEngine.Msg('CommandProcessor', 'Starting command thread...');
  
  GlobalProcessor := Self;
  
  FCommandThread := CreateThread(
    nil,
    0,
    @CommandThreadProc,
    nil,
    0,
    FCommandThreadID
  );
  
  if FCommandThread <> 0 then
  begin
    FEngine.Msg('CommandProcessor', 'Thread started: ' + IntToStr(FCommandThreadID));
    Result := True;
  end
  else
    FEngine.Msg('CommandProcessor', 'Thread creation FAILED!');
end;

procedure TCommandProcessor.Stop;
begin
  if FCommandThread = 0 then Exit;
  
  FEngine.Msg('CommandProcessor', 'Stopping command thread...');
  FStopRequested := True;
  
  WaitForSingleObject(FCommandThread, 2000);
  CloseHandle(FCommandThread);
  FCommandThread := 0;
  
  FEngine.Msg('CommandProcessor', 'Command thread stopped');
end;

function CommandThreadProc(P: Pointer): DWORD; stdcall;
var
  CommandData: string;
  Response: AnsiString;
  Processor: TCommandProcessor;
begin
  Result := 0;
  Processor := GlobalProcessor;
  
  try
    Processor.FEngine.Msg('CommandThread', 'Thread started');
    
    while not Processor.FStopRequested do
    begin
      if Processor.FPipeManager.ReadFromPipe(Processor.FPipeManager.Pipes.Command, CommandData) then
      begin
        Processor.FEngine.Msg('CommandThread', 'CMD: ' + CommandData);
        
        Response := Processor.ExecuteCommand(CommandData);
        
        Processor.FPipeManager.SendToPipe(Processor.FPipeManager.Pipes.Response, Response + #13#10);
        
        Processor.FEngine.Msg('CommandThread', 'RESP: ' + string(Response));
        
        Sleep(1);
      end
      else
      begin
        Sleep(COMMAND_CHECK_INTERVAL);
      end;
    end;
    
    Processor.FEngine.Msg('CommandThread', 'Thread stopped normally');
  except
    on E: Exception do
      Processor.FEngine.Msg('CommandThread', 'ERROR: ' + E.Message);
  end;
end;

end.
