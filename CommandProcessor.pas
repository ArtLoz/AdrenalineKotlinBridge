unit CommandProcessor;

interface

uses
  Windows, SysUtils, System.JSON, System.Generics.Collections,
  Types, PluginAPI, PipeManager, JsonSerialization;

type
  TCommandProc = function(Params: TJSONObject): TJSONValue of object;

  TCommandProcessor = class
  private
    FEngine: IL2Control;
    FPipeManager: TPipeManager;
    FCommandThread: THandle;
    FCommandThreadID: Cardinal;
    FStopRequested: Boolean;
    FMethods: TDictionary<string, TCommandProc>;

    procedure RegisterMethods;
    function ProcessRpc(const JsonStr: string): string;

    function MethodGetMe(Params: TJSONObject): TJSONValue;
    function MethodEcho(Params: TJSONObject): TJSONValue;
  public
    constructor Create(AEngine: IL2Control; APipeManager: TPipeManager);
    destructor Destroy; override;

    function Start: Boolean;
    procedure Stop;

    property ThreadID: Cardinal read FCommandThreadID;
  end;

function CommandThreadProc(P: Pointer): DWORD; stdcall;

implementation

constructor TCommandProcessor.Create(AEngine: IL2Control; APipeManager: TPipeManager);
begin
  inherited Create;
  FEngine := AEngine;
  FPipeManager := APipeManager;
  FStopRequested := False;
  FMethods := TDictionary<string, TCommandProc>.Create;
  RegisterMethods;
end;

destructor TCommandProcessor.Destroy;
begin
  Stop;
  FMethods.Free;
  inherited;
end;

procedure TCommandProcessor.RegisterMethods;
begin
  FMethods.Add('Engine.GetMe', MethodGetMe);
  FMethods.Add('System.Echo', MethodEcho);
end;

function TCommandProcessor.MethodGetMe(Params: TJSONObject): TJSONValue;
var Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  FillL2User(FEngine.User, Obj);
  Result := Obj;
end;

function TCommandProcessor.MethodEcho(Params: TJSONObject): TJSONValue;
begin
  if Assigned(Params) then Result := Params.Clone as TJSONValue
  else Result := TJSONString.Create('pong');
end;

function TCommandProcessor.ProcessRpc(const JsonStr: string): string;
var
  Req, Resp, ErrObj: TJSONObject;
  Rid, Meth: TJSONValue;
  Handler: TCommandProc;
begin
  Resp := TJSONObject.Create;
  try
    Req := TJSONObject.ParseJSONValue(JsonStr) as TJSONObject;
    if not Assigned(Req) then
    begin
      Resp.AddPair('status', 'error');
      ErrObj := TJSONObject.Create;
      ErrObj.AddPair('code', TJSONNumber.Create(400));
      ErrObj.AddPair('message', 'Invalid JSON');
      Resp.AddPair('error', ErrObj);
      Exit(Resp.ToJSON);
    end;

    try
      Rid := Req.GetValue('id');
      if Assigned(Rid) then Resp.AddPair('id', Rid.Clone as TJSONValue)
      else Resp.AddPair('id', TJSONNumber.Create(0));

      Meth := Req.GetValue('method');
      if Assigned(Meth) and FMethods.TryGetValue(Meth.Value, Handler) then
      begin
        Resp.AddPair('status', 'success');
        Resp.AddPair('result', Handler(Req.GetValue('params') as TJSONObject));
      end
      else
      begin
        Resp.AddPair('status', 'error');
        ErrObj := TJSONObject.Create;
        ErrObj.AddPair('code', TJSONNumber.Create(404));
        ErrObj.AddPair('message', 'Method not found');
        Resp.AddPair('error', ErrObj);
      end;
    finally
      Req.Free;
    end;
  except
    on E: Exception do
    begin
      Resp.AddPair('status', 'error');
      ErrObj := TJSONObject.Create;
      ErrObj.AddPair('code', TJSONNumber.Create(500));
      ErrObj.AddPair('message', E.Message);
      Resp.AddPair('error', ErrObj);
    end;
  end;
  Result := Resp.ToJSON;
  Resp.Free;
end;

function TCommandProcessor.Start: Boolean;
begin
  FCommandThread := CreateThread(nil, 0, @CommandThreadProc, Self, 0, FCommandThreadID);
  Result := FCommandThread <> 0;
end;

procedure TCommandProcessor.Stop;
begin
  if FCommandThread = 0 then Exit;
  FStopRequested := True;
  WaitForSingleObject(FCommandThread, 500);
  CloseHandle(FCommandThread);
  FCommandThread := 0;
end;

function CommandThreadProc(P: Pointer): DWORD; stdcall;
var
  Processor: TCommandProcessor;
  Cmd: string;
  Resp: string;
  ReadSuccess: Boolean;
  WriteSuccess: Boolean;
begin
  Result := 0;
  if not Assigned(P) then Exit;
  Processor := TCommandProcessor(P);

  while not Processor.FStopRequested do
  begin
    ReadSuccess := Processor.FPipeManager.ReadFromPipe(
      Processor.FPipeManager.Pipes.Command, Cmd);
    
    if ReadSuccess then
    begin
      Resp := Processor.ProcessRpc(Cmd);
      WriteSuccess := Processor.FPipeManager.SendToPipe(
        Processor.FPipeManager.Pipes.Response, UTF8String(Resp + #13#10));
      if not WriteSuccess then
      begin
        Processor.FPipeManager.ReconnectPipe(
          Processor.FPipeManager.FPipes.Command, 'commands', True);
        Processor.FPipeManager.ReconnectPipe(
          Processor.FPipeManager.FPipes.Response, 'responses', False);
        Processor.FPipeManager.ReconnectPipe(
          Processor.FPipeManager.FPipes.Action, 'actions', False);
        Processor.FPipeManager.ReconnectPipe(
          Processor.FPipeManager.FPipes.Packet, 'packets', False);
        Processor.FPipeManager.ReconnectPipe(
          Processor.FPipeManager.FPipes.CliPacket, 'clipackets', False);
      end;
    end
    else
    begin
      if not PeekNamedPipe(Processor.FPipeManager.Pipes.Command, nil, 0, nil, nil, nil) then
      begin
        Processor.FPipeManager.ReconnectPipe(
          Processor.FPipeManager.FPipes.Command, 'commands', True);
        Processor.FPipeManager.ReconnectPipe(
          Processor.FPipeManager.FPipes.Response, 'responses', False);
        Processor.FPipeManager.ReconnectPipe(
          Processor.FPipeManager.FPipes.Action, 'actions', False);
        Processor.FPipeManager.ReconnectPipe(
          Processor.FPipeManager.FPipes.Packet, 'packets', False);
        Processor.FPipeManager.ReconnectPipe(
          Processor.FPipeManager.FPipes.CliPacket, 'clipackets', False);
      end;
    end;
    
    Sleep(COMMAND_CHECK_INTERVAL);
  end;
end;

end.
