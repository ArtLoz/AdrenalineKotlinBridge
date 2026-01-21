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
  JsonSerialization in 'JsonSerialization.pas';

{$R *.res}

var
  Engine: IL2Control;
  PipeManager: TPipeManager;
  CommandProcessor: TCommandProcessor;
  EventForwarder: TEventForwarder;

function StartPlugin(AppHandle: Cardinal; PProc: Pointer): Cardinal; stdcall;
begin
  Result := 1;
end;

function StopPlugin: Boolean; stdcall;
begin
  Result := True;
  try
    if Assigned(CommandProcessor) then FreeAndNil(CommandProcessor);
    if Assigned(EventForwarder) then FreeAndNil(EventForwarder);
    if Assigned(PipeManager) then FreeAndNil(PipeManager);
  except
  end;
end;

procedure OnAction(Action: TL2Action; P1, P2: Pointer); stdcall;
begin
  if Assigned(EventForwarder) then
    EventForwarder.ForwardAction(Action, P1, P2);
end;

procedure OnPacket(ID1, ID2: Cardinal; Data: Pointer; Size: Word); stdcall;
begin
  if Assigned(EventForwarder) then
    EventForwarder.ForwardPacket(ID1, ID2, Data, Size);
end;

procedure OnCliPacket(ID1, ID2: Cardinal; Data: Pointer; Size: Word); stdcall;
begin
  if Assigned(EventForwarder) then
    EventForwarder.ForwardCliPacket(ID1, ID2, Data, Size);
end;

function InitControl(AEngine: IL2Control): THandle; stdcall;
var
  CharName: string;
begin
  Result := 0;
  if AEngine = nil then Exit;
  Engine := AEngine;

  try
    if (Engine.User <> nil) then CharName := Engine.User.Name else CharName := 'Unknown';

    PipeManager := TPipeManager.Create(Engine, CharName);
    if not PipeManager.Initialize then Exit;

    EventForwarder := TEventForwarder.Create(PipeManager);
    CommandProcessor := TCommandProcessor.Create(Engine, PipeManager);

    if CommandProcessor.Start then
      Result := CommandProcessor.ThreadID;

  except
    on E: Exception do
      if Assigned(Engine) then Engine.Msg('BridgeV1', 'Init Error: ' + E.Message);
  end;
end;

exports
  InitControl, StartPlugin, StopPlugin, OnPacket, OnCliPacket, OnAction;

begin
end.
