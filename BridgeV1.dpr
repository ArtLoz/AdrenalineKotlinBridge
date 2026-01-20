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
  EventForwarder in 'EventForwarder.pas';

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
    if Assigned(Engine) then
      Engine.Msg('BridgeV1', 'Stopping...');
    if Assigned(CommandProcessor) then
      FreeAndNil(CommandProcessor);
    if Assigned(EventForwarder) then
      FreeAndNil(EventForwarder);
    if Assigned(PipeManager) then
      FreeAndNil(PipeManager);
    if Assigned(Engine) then
      Engine.Msg('BridgeV1', 'Stopped successfully');

  except
    on E: Exception do
    begin
      if Assigned(Engine) then
        Engine.Msg('BridgeV1', 'Stop error: ' + E.Message);
      Result := False;
    end;
  end;
end;

procedure ShowPlugin; stdcall;
begin
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
  CharacterName: string;
begin
  Result := 0;
  Engine := AEngine;
  
  try
    CharacterName := Engine.User.Name;
    if CharacterName = '' then
      CharacterName := 'Unknown';
    Engine.Msg('BridgeV1', '========================================');
    Engine.Msg('BridgeV1', 'Initializing for: ' + CharacterName);
    PipeManager := TPipeManager.Create(Engine, CharacterName);
    if not PipeManager.Initialize then
    begin
      Engine.Msg('BridgeV1', 'ERROR: PipeManager initialization failed!');
      Exit;
    end;
    EventForwarder := TEventForwarder.Create(PipeManager);
    Engine.Msg('BridgeV1', 'EventForwarder created');
    CommandProcessor := TCommandProcessor.Create(Engine, PipeManager);
    if not CommandProcessor.Start then
    begin
      Engine.Msg('BridgeV1', 'ERROR: CommandProcessor start failed!');
      Exit;
    end;
    Engine.Msg('BridgeV1', 'Plugin started successfully!');
    Engine.Msg('BridgeV1', '========================================');
    Result := CommandProcessor.ThreadID;
    
  except
    on E: Exception do
    begin
      Engine.Msg('BridgeV1', 'FATAL ERROR: ' + E.Message);
      Result := 0;
    end;
  end;
end;

exports
  StartPlugin,
  StopPlugin,
  ShowPlugin,
  InitControl,
  OnAction,
  OnPacket,
  OnCliPacket;

end.
