library BridgeV1;

uses
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

function StartPlugin(AppHandle: Cardinal; PProc: Pointer): Cardinal; stdcall;
begin
  // Обычно вызывается игрой при загрузке DLL
  TraceEnter('StartPlugin');
  Result := 1;
  TraceLeave('StartPlugin');
end;

function StopPlugin: Boolean; stdcall;
begin
  TraceEnter('StopPlugin');
  Result := True;
  try
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

    if CommandProcessor.Start then
    begin
      Result := CommandProcessor.ThreadID;
      TraceFmt('Plugin initialized successfully. ThreadID: %d', [Result]);
      Engine.Msg('BridgeV1', 'Bridge Loaded: ' + CharName);
    end
    else
    begin
      TraceError('InitControl', 'CommandProcessor thread failed to start.');
      Engine.Msg('BridgeV1', 'Thread Start Failed');
    end;

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
