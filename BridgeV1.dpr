library BridgeV1;

uses
  SimpleShareMem,
  Windows,
  SysUtils,
  Types in 'Types.pas',
  PluginAPI in 'PluginAPI.pas',
  PluginConst in 'PluginConst.pas',
  PipeManager in 'PipeManager.pas',
  CommandProcessor in 'CommandProcessor.pas',
  EventForwarder in 'EventForwarder.pas',
  JsonSerialization in 'JsonSerialization.pas',
  Logger in 'Logger.pas';

{$R *.res}

var
  Engine: IL2Control;
  PipeManager: TPipeManager;
  CommandProcessor: TCommandProcessor;
  EventForwarder: TEventForwarder;
  hWorkerThread: THandle;
  WorkerThreadID: Cardinal;

function WorkerThread(P: Pointer): Integer;
begin
  try
    Trace('WorkerThread: started (ThreadID: ' + IntToStr(GetCurrentThreadId) + ')');
    CommandProcessor.Run;
    Trace('WorkerThread: Run loop finished');
  except
    on E: Exception do
      TraceException('WorkerThread', E);
  end;
  Result := 0;
  EndThread(0);
end;

function StartPlugin(AppHandle: Cardinal; PProc: Pointer): Cardinal; stdcall;
begin
  try
    @_PluginProc := Pointer(pproc);
    Result := 1;
  except
    on E: Exception do
      TraceException('StartPlugin', E);
  end;
end;

function StopPlugin: Boolean; stdcall;
begin
  TraceEnter('StopPlugin');
  Result := True;
  try

    if Assigned(CommandProcessor) then
    begin
      Trace('Requesting CommandProcessor stop...');
      CommandProcessor.RequestStop;
    end;

    if hWorkerThread <> 0 then
    begin
      Trace('Waiting for worker thread to exit...');
      if WaitForSingleObject(hWorkerThread, 5000) = WAIT_TIMEOUT then
        TraceError('StopPlugin', 'Worker thread did not exit in time.');
      CloseHandle(hWorkerThread);
      hWorkerThread := 0;
    end;

    if Assigned(CommandProcessor) then
    begin
      Trace('Freeing CommandProcessor...');
      FreeAndNil(CommandProcessor);
    end;

    if Assigned(EventForwarder) then
    begin
      Trace('Freeing EventForwarder...');
      FreeAndNil(EventForwarder);
    end;

    if Assigned(PipeManager) then
    begin
      Trace('Freeing PipeManager...');
      FreeAndNil(PipeManager);
    end;

    _PluginProc := nil;
    Engine := nil;

  except
    on E: Exception do
      TraceException('StopPlugin', E);
  end;
  TraceLeave('StopPlugin');
end;

procedure OnAction(Action: TL2Action; P1, P2: Pointer); stdcall;
begin
  try
    if Assigned(EventForwarder) then
      EventForwarder.ForwardAction(Action, P1, P2);
  except
    on E: Exception do
      TraceException('OnAction', E);
  end;
end;

procedure OnPacket(ID1, ID2: Cardinal; Data: Pointer; Size: Word); stdcall;
begin
  try
    if Assigned(EventForwarder) then
      EventForwarder.ForwardPacket(ID1, ID2, Data, Size);
  except
    on E: Exception do
      TraceException('OnPacket', E);
  end;
end;

procedure OnCliPacket(ID1, ID2: Cardinal; Data: Pointer; Size: Word); stdcall;
begin
  try
    if Assigned(EventForwarder) then
      EventForwarder.ForwardCliPacket(ID1, ID2, Data, Size);
  except
    on E: Exception do
      TraceException('OnCliPacket', E);
  end;
end;

function InitControl(AEngine: IL2Control): THandle; stdcall;
var
  CharName: string;
begin
  TraceEnter('InitControl');
  Result := 0;

  if AEngine = nil then
  begin
    TraceError('InitControl', 'Engine interface is nil!');
    Exit;
  end;

  Engine := AEngine;

  try
    if (Engine.User <> nil) then
      CharName := Engine.User.Name
    else
      CharName := 'Unknown';

    Trace('Initializing Bridge for character: ' + CharName);

    PipeManager := TPipeManager.Create(Engine, CharName);
    if not PipeManager.Initialize then
    begin
      TraceError('InitControl', 'PipeManager failed to initialize.');
      if Assigned(Engine) then Engine.Msg('BridgeV1', 'Pipe Init Failed');
      Exit;
    end;

    EventForwarder := TEventForwarder.Create(PipeManager);
    CommandProcessor := TCommandProcessor.Create(Engine, PipeManager);

    hWorkerThread := BeginThread(nil, 0, @WorkerThread, nil, 0, WorkerThreadID);
    Trace('Worker thread created (ThreadID: ' + IntToStr(WorkerThreadID) + ')');

    Engine.Msg('BridgeV1', 'Bridge Loaded: ' + CharName);
    Result := WorkerThreadID;

  except
    on E: Exception do
    begin
      TraceException('InitControl', E);
      if Assigned(Engine) then Engine.Msg('BridgeV1', 'Init Error: ' + E.Message);
    end;
  end;
  TraceLeave('InitControl');
end;

exports
  InitControl, StartPlugin, StopPlugin, OnPacket, OnCliPacket, OnAction;

begin
end.
