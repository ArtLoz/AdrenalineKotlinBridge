unit CommandProcessor;

interface

uses
  Windows, SysUtils, System.JSON, System.Generics.Collections,
  Types, PluginAPI, PluginConst, PipeManager, JsonSerialization, TypInfo, Logger;

type
  TCommandProc = function(Params: TJSONObject): TJSONValue of object;

  TCommandProcessor = class
  private
    FEngine: IL2Control;
    FPipeManager: TPipeManager;
    FStopRequested: Boolean;
    FStoppedEvent: THandle;
    FMethods: TDictionary<string, TCommandProc>;

    procedure RegisterMethods;
    function ProcessRpc(const JsonStr: string): string;

    function MethodGetMe(Params: TJSONObject): TJSONValue;
    function MethodEcho(Params: TJSONObject): TJSONValue;
    function MethodMoveTo(Params: TJSONObject): TJSONValue;
    function MethodMoveToByOid(Params: TJSONObject): TJSONValue;
    function GetNpcList(Params: TJSONObject): TJSONValue;
    function MethodMoveToTarget(Params: TJSONObject): TJSONValue;
    function MethodUnstuck(Params: TJSONObject): TJSONValue;
    function MethodGoHome(Params: TJSONObject): TJSONValue;
    function MethodTeleport(Params: TJSONObject): TJSONValue;
    function MethodUseAction(Params: TJSONObject): TJSONValue;
    function MethodAttack(Params: TJSONObject): TJSONValue;
    function MethodPickUp(Params: TJSONObject): TJSONValue;
    function MethodStand(Params: TJSONObject): TJSONValue;
    function MethodSit(Params: TJSONObject): TJSONValue;
    function MethodSetTarget(Params: TJSONObject): TJSONValue;
    function MethodSetTargetID(Params: TJSONObject): TJSONValue;
    function MethodSetTargetByOid(Params: TJSONObject): TJSONValue;
    function MethodAction(Params: TJSONObject): TJSONValue;
    function MethodCancelTarget(Params: TJSONObject): TJSONValue;
    function MethodAssist(Params: TJSONObject): TJSONValue;
    function MethodFindEnemy(Params: TJSONObject): TJSONValue;
    function MethodAutoTarget(Params: TJSONObject): TJSONValue;
    function MethodIgnore(Params: TJSONObject): TJSONValue;
    function MethodClearIgnore(Params: TJSONObject): TJSONValue;
    function MethodIsBusy(Params: TJSONObject): TJSONValue;
    function MethodUseSkill(Params: TJSONObject): TJSONValue;
    function MethodDUseSkill(Params: TJSONObject): TJSONValue;
    function MethodUseSkillGround(Params: TJSONObject): TJSONValue;
    function MethodStopCasting(Params: TJSONObject): TJSONValue;
    function MethodDispel(Params: TJSONObject): TJSONValue;
    function MethodLearnSkill(Params: TJSONObject): TJSONValue;
    function MethodUpdateSkillList(Params: TJSONObject): TJSONValue;
    function MethodUseItemByName(Params: TJSONObject): TJSONValue;
    function MethodUseItemByID(Params: TJSONObject): TJSONValue;
    function MethodUseItemByOid(Params: TJSONObject): TJSONValue;
    function MethodUseItemOID(Params: TJSONObject): TJSONValue;
    function MethodDestroyItemByName(Params: TJSONObject): TJSONValue;
    function MethodDestroyItemByID(Params: TJSONObject): TJSONValue;
    function MethodDestroyItemByOid(Params: TJSONObject): TJSONValue;
    function MethodDropItem(Params: TJSONObject): TJSONValue;
    function MethodMakeItem(Params: TJSONObject): TJSONValue;
    function MethodCrystalItemByID(Params: TJSONObject): TJSONValue;
    function MethodCrystalItemByOid(Params: TJSONObject): TJSONValue;
    function MethodMoveItem(Params: TJSONObject): TJSONValue;
    function MethodLoadItems(Params: TJSONObject): TJSONValue;
    function MethodAutoSoulShot(Params: TJSONObject): TJSONValue;
    function MethodDAutoSoulShot(Params: TJSONObject): TJSONValue;
    function MethodEquipped(Params: TJSONObject): TJSONValue;
    function MethodDismissPet(Params: TJSONObject): TJSONValue;
    function MethodDismissSum(Params: TJSONObject): TJSONValue;
    function MethodSay(Params: TJSONObject): TJSONValue;
    function MethodInviteParty(Params: TJSONObject): TJSONValue;
    function MethodDismissParty(Params: TJSONObject): TJSONValue;
    function MethodJoinParty(Params: TJSONObject): TJSONValue;
    function MethodLeaveParty(Params: TJSONObject): TJSONValue;
    function MethodSetPartyLeader(Params: TJSONObject): TJSONValue;
    function MethodGetMentor(Params: TJSONObject): TJSONValue;
    function MethodKickMentor(Params: TJSONObject): TJSONValue;
    function MethodCloseRoom(Params: TJSONObject): TJSONValue;
    function MethodCreateRoom(Params: TJSONObject): TJSONValue;
    function MethodAutoAcceptClan(Params: TJSONObject): TJSONValue;
    function MethodAutoAcceptCC(Params: TJSONObject): TJSONValue;
    function MethodAutoAcceptMentors(Params: TJSONObject): TJSONValue;
    function MethodQuestStatusGetStage(Params: TJSONObject): TJSONValue;
    function MethodQuestStatusCheckStage(Params: TJSONObject): TJSONValue;
    function MethodCancelQuest(Params: TJSONObject): TJSONValue;
    function MethodOpenQuestion(Params: TJSONObject): TJSONValue;
    function MethodGetDailyItems(Params: TJSONObject): TJSONValue;
    function MethodGetDailyItem(Params: TJSONObject): TJSONValue;
    function MethodUpdateDailyList(Params: TJSONObject): TJSONValue;
    function MethodDlgOpen(Params: TJSONObject): TJSONValue;
    function MethodDlgSel(Params: TJSONObject): TJSONValue;
    function MethodDlgSelText(Params: TJSONObject): TJSONValue;
    function MethodBypassToServer(Params: TJSONObject): TJSONValue;
    function MethodDlgText(Params: TJSONObject): TJSONValue;
    function MethodDlgTime(Params: TJSONObject): TJSONValue;
    function MethodCBText(Params: TJSONObject): TJSONValue;
    function MethodCBTime(Params: TJSONObject): TJSONValue;
    function MethodHlpText(Params: TJSONObject): TJSONValue;
    function MethodHlpTime(Params: TJSONObject): TJSONValue;
    function MethodConfirmDlg(Params: TJSONObject): TJSONValue;
    function MethodConfirmDialog(Params: TJSONObject): TJSONValue;
    function MethodOpenPrivateStore(Params: TJSONObject): TJSONValue;
    function MethodNpcTrade(Params: TJSONObject): TJSONValue;
    function MethodNpcExchange(Params: TJSONObject): TJSONValue;
    function MethodCastleTax(Params: TJSONObject): TJSONValue;
    function MethodSendMail(Params: TJSONObject): TJSONValue;
    function MethodGetMailItems(Params: TJSONObject): TJSONValue;
    function MethodGetZoneType(Params: TJSONObject): TJSONValue;
    function MethodGetZoneName(Params: TJSONObject): TJSONValue;
    function MethodGetZoneID(Params: TJSONObject): TJSONValue;
    function MethodInZoneXYZ(Params: TJSONObject): TJSONValue;
    function MethodInZoneObj(Params: TJSONObject): TJSONValue;
    function MethodGameTime(Params: TJSONObject): TJSONValue;
    function MethodIsDay(Params: TJSONObject): TJSONValue;
    function MethodStatus(Params: TJSONObject): TJSONValue;
    function MethodLoginStatus(Params: TJSONObject): TJSONValue;
    function MethodAuthLogin(Params: TJSONObject): TJSONValue;
    function MethodGameStart(Params: TJSONObject): TJSONValue;
    function MethodRestart(Params: TJSONObject): TJSONValue;
    function MethodDRestart(Params: TJSONObject): TJSONValue;
    function MethodFaceControl(Params: TJSONObject): TJSONValue;
    function MethodGetFaceState(Params: TJSONObject): TJSONValue;
    function MethodUpdateCfg(Params: TJSONObject): TJSONValue;
    function MethodLoadConfig(Params: TJSONObject): TJSONValue;
    function MethodLoadZone(Params: TJSONObject): TJSONValue;
    function MethodClearZone(Params: TJSONObject): TJSONValue;
    function MethodSetPerform(Params: TJSONObject): TJSONValue;
    function MethodSetMapKeepDist(Params: TJSONObject): TJSONValue;
    function MethodGamePrint(Params: TJSONObject): TJSONValue;
    function MethodGameClose(Params: TJSONObject): TJSONValue;
    function MethodBlinkWindow(Params: TJSONObject): TJSONValue;
    function MethodSetGameWindow(Params: TJSONObject): TJSONValue;
    function MethodUseKey(Params: TJSONObject): TJSONValue;
    function MethodEnterText(Params: TJSONObject): TJSONValue;
    function MethodPostMessage(Params: TJSONObject): TJSONValue;
    function MethodSendMessage(Params: TJSONObject): TJSONValue;
    function MethodGamePath(Params: TJSONObject): TJSONValue;
    function MethodGameWindow(Params: TJSONObject): TJSONValue;
    function MethodGameHash(Params: TJSONObject): TJSONValue;
    function MethodGameProtocol(Params: TJSONObject): TJSONValue;
    function MethodGameVersion(Params: TJSONObject): TJSONValue;
    function MethodGetServerIP(Params: TJSONObject): TJSONValue;
    function MethodGetServerName(Params: TJSONObject): TJSONValue;
    function MethodGetServerID(Params: TJSONObject): TJSONValue;
    function MethodIsClassicServer(Params: TJSONObject): TJSONValue;
    function MethodServerTime(Params: TJSONObject): TJSONValue;
    function MethodMsg(Params: TJSONObject): TJSONValue;
    function MethodBlinkWindow2(Params: TJSONObject): TJSONValue;
    function MethodHKPauseScript(Params: TJSONObject): TJSONValue;
    function MethodSendActID(Params: TJSONObject): TJSONValue;
    function MethodSendToServer(Params: TJSONObject): TJSONValue;
    function MethodSendToClient(Params: TJSONObject): TJSONValue;
    function MethodBlockPacket(Params: TJSONObject): TJSONValue;
    function MethodWaitAction(Params: TJSONObject): TJSONValue;
    function GetPetList(Params: TJSONObject): TJSONValue;
    function GetInventoryList(Params: TJSONObject): TJSONValue;
    function GetQuestInventoryList(Params: TJSONObject): TJSONValue;
    function GetSkillList(Params: TJSONObject): TJSONValue;
    function GetCharList(Params: TJSONObject): TJSONValue;
    function GetDropList(Params: TJSONObject): TJSONValue;
    function MethodLoadGPSPoint(Params: TJSONObject): TJSONValue;
    function MethodGPSMove(Params: TJSONObject): TJSONValue;
    function MethodGetGPSPoint(Params: TJSONObject): TJSONValue;
    function MethodGPSMoveRandom(Params: TJSONObject): TJSONValue;


  public
    constructor Create(AEngine: IL2Control; APipeManager: TPipeManager);
    destructor Destroy; override;

    procedure Run;
    procedure RequestStop;
    procedure WaitForStop(TimeoutMS: Cardinal = 5000);
  end;

var
  _PluginProc: function(Code: Cardinal; p1, p2, p3: widestring): widestring; stdcall;

const
  ERROR_PIPE_LISTENING = 536;

implementation

function PluginProc(Code: Cardinal; p1: widestring = ''; p2: widestring = ''; p3: widestring = ''): widestring;
begin
  Result := _PluginProc(Code, p1, p2, p3);
end;

constructor TCommandProcessor.Create(AEngine: IL2Control; APipeManager: TPipeManager);
begin
  TraceEnter('TCommandProcessor.Create');
  try
    inherited Create;
    FEngine := AEngine;
    FPipeManager := APipeManager;
    FStopRequested := False;
    FStoppedEvent := CreateEvent(nil, True, False, nil);
    FMethods := TDictionary<string, TCommandProc>.Create;
    RegisterMethods;
    TraceFmt('CommandProcessor created. Methods registered: %d', [FMethods.Count]);
  except
    on E: Exception do
    begin
      TraceException('TCommandProcessor.Create', E);
      raise;
    end;
  end;
  TraceLeave('TCommandProcessor.Create');
end;

destructor TCommandProcessor.Destroy;
begin
  TraceEnter('TCommandProcessor.Destroy');
  try
    if FStoppedEvent <> INVALID_HANDLE_VALUE then
    begin
      CloseHandle(FStoppedEvent);
      FStoppedEvent := INVALID_HANDLE_VALUE;
    end;
    if Assigned(FMethods) then
      FMethods.Free;
    inherited;
  except
    on E: Exception do
      TraceException('TCommandProcessor.Destroy', E);
  end;
  TraceLeave('TCommandProcessor.Destroy');
end;

procedure TCommandProcessor.RegisterMethods;
begin
  FMethods.Add('Engine.GetMe', MethodGetMe);
  FMethods.Add('System.Echo', MethodEcho);
  FMethods.Add('Engine.MoveTo', MethodMoveTo);
  FMethods.Add('Engine.MoveToByOid', MethodMoveToByOid);
  FMethods.Add('Engine.MoveToTarget', MethodMoveToTarget);
  FMethods.Add('Engine.Unstuck', MethodUnstuck);
  FMethods.Add('Engine.GoHome', MethodGoHome);
  FMethods.Add('Engine.Teleport', MethodTeleport);
  FMethods.Add('Engine.UseAction', MethodUseAction);
  FMethods.Add('Engine.Attack', MethodAttack);
  FMethods.Add('Engine.PickUp', MethodPickUp);
  FMethods.Add('Engine.Stand', MethodStand);
  FMethods.Add('Engine.Sit', MethodSit);
  FMethods.Add('Engine.SetTarget', MethodSetTarget);
  FMethods.Add('Engine.SetTargetID', MethodSetTargetID);
  FMethods.Add('Engine.SetTargetByOid', MethodSetTargetByOid);
  FMethods.Add('Engine.Action', MethodAction);
  FMethods.Add('Engine.CancelTarget', MethodCancelTarget);
  FMethods.Add('Engine.Assist', MethodAssist);
  FMethods.Add('Engine.FindEnemy', MethodFindEnemy);
  FMethods.Add('Engine.AutoTarget', MethodAutoTarget);
  FMethods.Add('Engine.Ignore', MethodIgnore);
  FMethods.Add('Engine.ClearIgnore', MethodClearIgnore);
  FMethods.Add('Engine.IsBusy', MethodIsBusy);
  FMethods.Add('Engine.UseSkill', MethodUseSkill);
  FMethods.Add('Engine.DUseSkill', MethodDUseSkill);
  FMethods.Add('Engine.UseSkillGround', MethodUseSkillGround);
  FMethods.Add('Engine.StopCasting', MethodStopCasting);
  FMethods.Add('Engine.Dispel', MethodDispel);
  FMethods.Add('Engine.LearnSkill', MethodLearnSkill);
  FMethods.Add('Engine.UpdateSkillList', MethodUpdateSkillList);
  FMethods.Add('Engine.UseItemByName', MethodUseItemByName);
  FMethods.Add('Engine.UseItemByID', MethodUseItemByID);
  FMethods.Add('Engine.UseItemByOid', MethodUseItemByOid);
  FMethods.Add('Engine.UseItemOID', MethodUseItemOID);
  FMethods.Add('Engine.DestroyItemByName', MethodDestroyItemByName);
  FMethods.Add('Engine.DestroyItemByID', MethodDestroyItemByID);
  FMethods.Add('Engine.DestroyItemByOid', MethodDestroyItemByOid);
  FMethods.Add('Engine.DropItem', MethodDropItem);
  FMethods.Add('Engine.MakeItem', MethodMakeItem);
  FMethods.Add('Engine.CrystalItemByID', MethodCrystalItemByID);
  FMethods.Add('Engine.CrystalItemByOid', MethodCrystalItemByOid);
  FMethods.Add('Engine.MoveItem', MethodMoveItem);
  FMethods.Add('Engine.LoadItems', MethodLoadItems);
  FMethods.Add('Engine.AutoSoulShot', MethodAutoSoulShot);
  FMethods.Add('Engine.DAutoSoulShot', MethodDAutoSoulShot);
  FMethods.Add('Engine.Equipped', MethodEquipped);
  FMethods.Add('Engine.DismissPet', MethodDismissPet);
  FMethods.Add('Engine.DismissSum', MethodDismissSum);
  FMethods.Add('Engine.Say', MethodSay);
  FMethods.Add('Engine.InviteParty', MethodInviteParty);
  FMethods.Add('Engine.DismissParty', MethodDismissParty);
  FMethods.Add('Engine.JoinParty', MethodJoinParty);
  FMethods.Add('Engine.LeaveParty', MethodLeaveParty);
  FMethods.Add('Engine.SetPartyLeader', MethodSetPartyLeader);
  FMethods.Add('Engine.GetMentor', MethodGetMentor);
  FMethods.Add('Engine.KickMentor', MethodKickMentor);
  FMethods.Add('Engine.CloseRoom', MethodCloseRoom);
  FMethods.Add('Engine.CreateRoom', MethodCreateRoom);
  FMethods.Add('Engine.AutoAcceptClan', MethodAutoAcceptClan);
  FMethods.Add('Engine.AutoAcceptCC', MethodAutoAcceptCC);
  FMethods.Add('Engine.AutoAcceptMentors', MethodAutoAcceptMentors);
  FMethods.Add('Engine.QuestStatusGetStage', MethodQuestStatusGetStage);
  FMethods.Add('Engine.QuestStatusCheckStage', MethodQuestStatusCheckStage);
  FMethods.Add('Engine.CancelQuest', MethodCancelQuest);
  FMethods.Add('Engine.OpenQuestion', MethodOpenQuestion);
  FMethods.Add('Engine.GetDailyItems', MethodGetDailyItems);
  FMethods.Add('Engine.GetDailyItem', MethodGetDailyItem);
  FMethods.Add('Engine.UpdateDailyList', MethodUpdateDailyList);
  FMethods.Add('Engine.DlgOpen', MethodDlgOpen);
  FMethods.Add('Engine.DlgSelText', MethodDlgSelText);
  FMethods.Add('Engine.DlgSel', MethodDlgSel);
  FMethods.Add('Engine.BypassToServer', MethodBypassToServer);
  FMethods.Add('Engine.DlgText', MethodDlgText);
  FMethods.Add('Engine.DlgTime', MethodDlgTime);
  FMethods.Add('Engine.CBText', MethodCBText);
  FMethods.Add('Engine.CBTime', MethodCBTime);
  FMethods.Add('Engine.HlpText', MethodHlpText);
  FMethods.Add('Engine.HlpTime', MethodHlpTime);
  FMethods.Add('Engine.ConfirmDlg', MethodConfirmDlg);
  FMethods.Add('Engine.ConfirmDialog', MethodConfirmDialog);
  FMethods.Add('Engine.OpenPrivateStore', MethodOpenPrivateStore);
  FMethods.Add('Engine.NpcTrade', MethodNpcTrade);
  FMethods.Add('Engine.NpcExchange', MethodNpcExchange);
  FMethods.Add('Engine.CastleTax', MethodCastleTax);
  FMethods.Add('Engine.SendMail', MethodSendMail);
  FMethods.Add('Engine.GetMailItems', MethodGetMailItems);
  FMethods.Add('Engine.GetZoneType', MethodGetZoneType);
  FMethods.Add('Engine.GetZoneName', MethodGetZoneName);
  FMethods.Add('Engine.GetZoneID', MethodGetZoneID);
  FMethods.Add('Engine.InZoneXYZ', MethodInZoneXYZ);
  FMethods.Add('Engine.InZoneObj', MethodInZoneObj);
  FMethods.Add('Engine.GameTime', MethodGameTime);
  FMethods.Add('Engine.IsDay', MethodIsDay);
  FMethods.Add('Engine.Status', MethodStatus);
  FMethods.Add('Engine.LoginStatus', MethodLoginStatus);
  FMethods.Add('Engine.AuthLogin', MethodAuthLogin);
  FMethods.Add('Engine.GameStart', MethodGameStart);
  FMethods.Add('Engine.Restart', MethodRestart);
  FMethods.Add('Engine.DRestart', MethodDRestart);
  FMethods.Add('Engine.FaceControl', MethodFaceControl);
  FMethods.Add('Engine.GetFaceState', MethodGetFaceState);
  FMethods.Add('Engine.UpdateCfg', MethodUpdateCfg);
  FMethods.Add('Engine.LoadConfig', MethodLoadConfig);
  FMethods.Add('Engine.LoadZone', MethodLoadZone);
  FMethods.Add('Engine.ClearZone', MethodClearZone);
  FMethods.Add('Engine.SetPerform', MethodSetPerform);
  FMethods.Add('Engine.SetMapKeepDist', MethodSetMapKeepDist);
  FMethods.Add('Engine.GamePrint', MethodGamePrint);
  FMethods.Add('Engine.GameClose', MethodGameClose);
  FMethods.Add('Engine.BlinkWindow', MethodBlinkWindow);
  FMethods.Add('Engine.SetGameWindow', MethodSetGameWindow);
  FMethods.Add('Engine.UseKey', MethodUseKey);
  FMethods.Add('Engine.EnterText', MethodEnterText);
  FMethods.Add('Engine.PostMessage', MethodPostMessage);
  FMethods.Add('Engine.SendMessage', MethodSendMessage);
  FMethods.Add('Engine.GamePath', MethodGamePath);
  FMethods.Add('Engine.GameWindow', MethodGameWindow);
  FMethods.Add('Engine.GameHash', MethodGameHash);
  FMethods.Add('Engine.GameProtocol', MethodGameProtocol);
  FMethods.Add('Engine.GameVersion', MethodGameVersion);
  FMethods.Add('Engine.GetServerIP', MethodGetServerIP);
  FMethods.Add('Engine.GetServerName', MethodGetServerName);
  FMethods.Add('Engine.GetServerID', MethodGetServerID);
  FMethods.Add('Engine.IsClassicServer', MethodIsClassicServer);
  FMethods.Add('Engine.ServerTime', MethodServerTime);
  FMethods.Add('Engine.Msg', MethodMsg);
  FMethods.Add('Engine.BlinkWindow2', MethodBlinkWindow2);
  FMethods.Add('Engine.HKPauseScript', MethodHKPauseScript);
  FMethods.Add('Engine.SendActID', MethodSendActID);
  FMethods.Add('Engine.SendToServer', MethodSendToServer);
  FMethods.Add('Engine.SendToClient', MethodSendToClient);
  FMethods.Add('Engine.BlockPacket', MethodBlockPacket);
  FMethods.Add('Engine.WaitAction', MethodWaitAction);

  //list
  FMethods.Add('Engine.GetNpcList', GetNpcList);
  FMethods.Add('Engine.GetPetList', GetPetList);
  FMethods.Add('Engine.GetInventoryList', GetInventoryList);
  FMethods.Add('Engine.GetSkillList', GetSkillList);
  FMethods.Add('Engine.GetCharList', GetCharList);
  FMethods.Add('Engine.GetDropList', GetDropList);
  FMethods.Add('Engine.GetQuestInventoryList', GetQuestInventoryList);

  FMethods.Add('Engine.LoadGPSPoint', MethodLoadGPSPoint);
  FMethods.Add('Engine.GPSMove', MethodGPSMove);
  FMethods.Add('Engine.GPSPoint', MethodGetGPSPoint);
  FMethods.Add('Engine.GPSMoveRandom', MethodGPSMoveRandom);

end;

//comands
function TCommandProcessor.MethodGetMe(Params: TJSONObject): TJSONValue;
var
  Obj: TJSONObject;
begin
  // TraceEnter('MethodGetMe'); // Можно включить для детальной отладки
  try
    Obj := TJSONObject.Create;
    FillL2User(FEngine.User, Obj);
    Result := Obj;
  except
    on E: Exception do
    begin
      TraceException('MethodGetMe', E);
      Result := nil;
    end;
  end;
end;
function TCommandProcessor.MethodEcho(Params: TJSONObject): TJSONValue;
begin
  if Assigned(Params) then
    Result := Params.Clone as TJSONValue
  else
    Result := TJSONString.Create('pong');
end;
function TCommandProcessor.MethodMoveTo(Params: TJSONObject): TJSONValue;
var
  X, Y, Z, Timeout: Integer;
  MoveResult: Boolean;
begin
  Result := TJSONBool.Create(False);

  try
    if not Assigned(Params) or not Assigned(FEngine) then Exit;

    X := Params.GetValue<Integer>('x');
    Y := Params.GetValue<Integer>('y');
    Z := Params.GetValue<Integer>('z');

    if not Params.TryGetValue<Integer>('timeout', Timeout) then
      Timeout := 8000;

    MoveResult := FEngine.MoveTo(X, Y, Z);

    Result.Free;
    Result := TJSONBool.Create(MoveResult);
  except
    on E: Exception do
      TraceException('TCommandProcessor.MethodMoveTo', E);
  end;
end;
function TCommandProcessor.MethodMoveToByOid(Params: TJSONObject): TJSONValue;
var
  TargetOID: Cardinal;
  Delta: Integer;
  i: Integer;
  IsFound: Boolean;
  Obj: IL2Object;
begin
  Result := TJSONBool.Create(False);
  IsFound := False;
  if not Assigned(FEngine) then Exit;
  // 1. Парсинг параметров
  if not Params.TryGetValue<Cardinal>('oid', TargetOID) then Exit;
  if not Params.TryGetValue<Integer>('delta', Delta) then Delta := -70;
  // 2. ПРОВЕРКА НА СЕБЯ
  // Если целевой OID совпадает с нашим, никуда бежать не надо.
  if Assigned(FEngine.User) and (FEngine.User.OID = TargetOID) then
  begin
    Trace('MoveToByOid: Target is Self (' + IntToStr(TargetOID) + '). Skipping move.');
    Result.Free;
    Result := TJSONBool.Create(True); // Считаем действие выполненным (мы уже тут)
    Exit;
  end;
  try
    FEngine.Lock;
    try
      // 3. Поиск в NPC
      if Assigned(FEngine.NpcList) then
      begin
        for i := 0 to FEngine.NpcList.Count - 1 do
        begin
          Obj := FEngine.NpcList.Items[i];
          if (Obj <> nil) and (Obj.OID = TargetOID) then
          begin
            IsFound := True;
            Break;
          end;
        end;
      end;
      // 4. Поиск в Игроках (если не нашли в NPC)
      if (not IsFound) and Assigned(FEngine.CharList) then
      begin
        for i := 0 to FEngine.CharList.Count - 1 do
        begin
          Obj := FEngine.CharList.Items[i];
          if (Obj <> nil) and (Obj.OID = TargetOID) then
          begin
            IsFound := True;
            Break;
          end;
        end;
      end;
      // 5. Поиск в Дропе (если не нашли ранее)
      if (not IsFound) and Assigned(FEngine.DropList) then
      begin
        for i := 0 to FEngine.DropList.Count - 1 do
        begin
          Obj := FEngine.DropList.Items[i];
          if (Obj <> nil) and (Obj.OID = TargetOID) then
          begin
            IsFound := True;
            Break;
          end;
        end;
      end;
    finally
      FEngine.UnLock;
    end;
    // MoveTo вызываем уже после UnLock
    if IsFound and (Obj <> nil) then
    begin
      FEngine.MoveTo(Obj as IL2Spawn, Delta);
      Result.Free;
      Result := TJSONBool.Create(True);
    end
    else
    begin
      TraceError('MoveToByOid', 'Object not found. OID: ' + IntToStr(TargetOID));
    end;
  except
    on E: Exception do
      TraceError('MoveToByOid', 'Exception: ' + E.Message);
  end;
end;
function TCommandProcessor.MethodMoveToTarget(Params: TJSONObject): TJSONValue;
var
  Delta: Integer;
  TargetObj: IL2Live;
begin
  Result := TJSONBool.Create(False);

  if not Assigned(FEngine) or not Assigned(FEngine.User) then Exit;

  // 1. Парсим параметры. По умолчанию Delta = -100
  if not Params.TryGetValue<Integer>('delta', Delta) then Delta := -100;

  try
    // 2. Получаем текущую цель
    TargetObj := FEngine.User.Target;

    // 3. Проверяем, есть ли цель и валидна ли она
    if (TargetObj <> nil) and (TargetObj.Valid) then
    begin
      // Trace('MoveToTarget: Moving to ' + TargetObj.Name + ' (OID: ' + IntToStr(TargetObj.OID) + ')');

      // 4. Выполняем движение
      // Метод MoveTo обычно возвращает Boolean, используем его для результата
      if FEngine.MoveTo(TargetObj, Delta) then
      begin
        Result.Free;
        Result := TJSONBool.Create(True);
      end;
    end
    else
    begin
      // Цели нет или она мертва/исчезла
      TraceError('MoveToTarget', 'Target is invalid or NIL');
    end;

  except
    on E: Exception do
      TraceError('MoveToTarget', 'Exception: ' + E.Message);
  end;
end;
function TCommandProcessor.MethodUnstuck(Params: TJSONObject): TJSONValue;
var
  Res: Boolean;
begin
  // Инициализируем дефолтным значением (False)
  Result := TJSONBool.Create(False);

  try
    if Assigned(FEngine) then
    begin
      // Вызываем оригинальный Unstuck и сохраняем его результат
      Res := FEngine.Unstuck;

      // Пересоздаем JSON-результат на основе того, что вернул движок
      Result.Free;
      Result := TJSONBool.Create(Res);
    end;
  except
    on E: Exception do
      TraceException('MethodUnstuck', E);
  end;
end;
function TCommandProcessor.MethodGoHome(Params: TJSONObject): TJSONValue;
var
  ResStr: string;
  RestartType: TRestartType;
  Success: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    if not Params.TryGetValue<string>('res_type', ResStr) then
      ResStr := 'town';

    ResStr := LowerCase(ResStr);
    if ResStr = 'clanhall' then RestartType := rtClanHall
    else if ResStr = 'castle'   then RestartType := rtCastle
    else if ResStr = 'fort'     then RestartType := rtFort
    else if ResStr = 'flags'    then RestartType := rtFlags
    else RestartType := rtTown;

    Success := FEngine.GoHome(RestartType);

    Result.Free;
    Result := TJSONBool.Create(Success);
  except
    on E: Exception do
      TraceException('MethodGoHome', E);
  end;
end;
function TCommandProcessor.MethodTeleport(Params: TJSONObject): TJSONValue;
var
  TeleportID: Cardinal;
  Success: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Извлекаем ID. В JSON Cardinal лучше парсить как Cardinal или Int64 для безопасности
    if not Params.TryGetValue<Cardinal>('id', TeleportID) then
    begin
      TraceError('MethodTeleport', 'Parameter "id" missing or invalid');
      Exit;
    end;

    // Вызываем оригинальную функцию движка
    Success := FEngine.Teleport(TeleportID);

    Result.Free;
    Result := TJSONBool.Create(Success);

  except
    on E: Exception do
      TraceException('MethodTeleport', E);
  end;
end;
function TCommandProcessor.MethodUseAction(Params: TJSONObject): TJSONValue;
var
  ActionID: Cardinal;
  Force, Shift, Success: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Обязательный параметр ID
    if not Params.TryGetValue<Cardinal>('id', ActionID) then
    begin
      TraceError('MethodUseAction', 'Action ID is missing');
      Exit;
    end;

    // Опциональные параметры (Force/Shift)
    if not Params.TryGetValue<Boolean>('force', Force) then Force := False;
    if not Params.TryGetValue<Boolean>('shift', Shift) then Shift := False;

    // Вызов движка
    Success := FEngine.UseAction(ActionID, Force, Shift);

    Result.Free;
    Result := TJSONBool.Create(Success);
  except
    on E: Exception do
      TraceException('MethodUseAction', E);
  end;
end;
function TCommandProcessor.MethodAttack(Params: TJSONObject): TJSONValue;
var
  PauseTime: Cardinal;
  Force, Success: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Читаем параметры из JSON, задаем дефолты если параметров нет
    if not Params.TryGetValue<Cardinal>('pause_time', PauseTime) then
      PauseTime := 2000;

    if not Params.TryGetValue<Boolean>('force', Force) then
      Force := False;

    // Вызываем метод движка
    Success := FEngine.ForceAtk(PauseTime, Force);

    Result.Free;
    Result := TJSONBool.Create(Success);
  except
    on E: Exception do
      TraceException('MethodAttack', E);
  end;
end;
function TCommandProcessor.MethodPickUp(Params: TJSONObject): TJSONValue;
var
  ItemOID: Cardinal;
  ByPet: Boolean;
  i: Integer;
  Item, FoundItem: IL2Drop;
begin
  Result := TJSONBool.Create(False);
  FoundItem := nil;
  try
    if not Assigned(FEngine) or not Assigned(FEngine.DropList) then Exit;

    if not Params.TryGetValue<Cardinal>('oid', ItemOID) then Exit;
    if not Params.TryGetValue<Boolean>('by_pet', ByPet) then ByPet := False;

    // Ищем предмет в DropList по OID
    FEngine.Lock;
    try
      for i := 0 to FEngine.DropList.Count - 1 do
      begin
        Item := FEngine.DropList.Items[i];
        if (Item <> nil) and (Item.OID = ItemOID) then
        begin
          FoundItem := Item;
          Break;
        end;
      end;
    finally
      FEngine.UnLock;
    end;

    if FoundItem <> nil then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.PickUp(FoundItem, ByPet));
    end;
  except
    on E: Exception do
      TraceException('MethodPickUp', E);
  end;
end;
function TCommandProcessor.MethodStand(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.Stand);
    end;
  except
    on E: Exception do
      TraceException('MethodStand', E);
  end;
end;
function TCommandProcessor.MethodSit(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.Sit);
    end;
  except
    on E: Exception do
      TraceException('MethodSit', E);
  end;
end;
function TCommandProcessor.MethodSetTarget(Params: TJSONObject): TJSONValue;
var Name: string;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) and Params.TryGetValue<string>('name', Name) then begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.SetTarget(Name));
    end;
  except on E: Exception do TraceException('MethodSetTarget', E); end;
end;
function TCommandProcessor.MethodSetTargetID(Params: TJSONObject): TJSONValue;
var ID: Cardinal;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) and Params.TryGetValue<Cardinal>('id', ID) then begin
      Result.Free;
     // FEngine.Lock;
      Result := TJSONBool.Create(FEngine.SetTargetID(ID));
      //FEngine.UnLock;
    end;
  except on E: Exception do begin
    //FEngine.UnLock;
    TraceException('MethodSetTargetID', E);
    end;
  end;
end;
function TCommandProcessor.MethodSetTargetByOid(Params: TJSONObject): TJSONValue;
var
  TargetOID: Cardinal;
  i: Integer;
  Obj, FoundObj: IL2Live;
begin
  Result := TJSONBool.Create(False);
  FoundObj := nil;
  try
    if not Assigned(FEngine) or not Params.TryGetValue<Cardinal>('oid', TargetOID) then Exit;

    // 1. ПРОВЕРКА НА СЕБЯ (User)
    if Assigned(FEngine.User) and (FEngine.User.OID = TargetOID) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.SetTarget(FEngine.User));
      Exit;
    end;

    FEngine.Lock;
    try
      // 2. ПОИСК В NPC (Монстры, НПЦ)
      if Assigned(FEngine.NpcList) then
        for i := 0 to FEngine.NpcList.Count - 1 do
        begin
          Obj := FEngine.NpcList.Items[i];
          if (Obj <> nil) and (Obj.OID = TargetOID) then
          begin
            FoundObj := Obj;
            Break;
          end;
        end;

      // 3. ПОИСК В CHARS (Другие игроки)
      if (FoundObj = nil) and Assigned(FEngine.CharList) then
        for i := 0 to FEngine.CharList.Count - 1 do
        begin
          Obj := FEngine.CharList.Items[i];
          if (Obj <> nil) and (Obj.OID = TargetOID) then
          begin
            FoundObj := Obj;
            Break;
          end;
        end;
    finally
      FEngine.UnLock;
    end;

    if FoundObj <> nil then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.SetTarget(FoundObj));
    end;
  except
    on E: Exception do
      TraceException('MethodSetTargetByOid', E);
  end;
end;
function TCommandProcessor.MethodAction(Params: TJSONObject): TJSONValue;
var
  TargetOID: Cardinal;
  Force: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Извлекаем параметры. Если OID не пришел — выходим.
    if not Params.TryGetValue<Cardinal>('oid', TargetOID) then Exit;
    if not Params.TryGetValue<Boolean>('force', Force) then Force := False;

    // Используем прямую перегрузку Engine.Action(OID, Force)
    Result.Free;
    Result := TJSONBool.Create(FEngine.Action(TargetOID, Force));
  except
    on E: Exception do
      TraceException('MethodAction', E);
  end;
end;
function TCommandProcessor.MethodCancelTarget(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.CancelTarget);
    end;
  except
    on E: Exception do
      TraceException('MethodCancelTarget', E);
  end;
end;
function TCommandProcessor.MethodAssist(Params: TJSONObject): TJSONValue;
var
  TargetName: string;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) or not Params.TryGetValue<string>('name', TargetName) then Exit;

    Result.Free;
    Result := TJSONBool.Create(FEngine.Assist(TargetName));
  except
    on E: Exception do
      TraceException('MethodAssist', E);
  end;
end;
function TCommandProcessor.MethodFindEnemy(Params: TJSONObject): TJSONValue;
var
  TargetOID: Cardinal;
  Range, ZLimit: Cardinal;
  Obj, Enemy: IL2Live;
  i: Integer;
  Resp: TJSONObject;
begin
  Result := TJSONNull.Create;
  try
    if not Assigned(FEngine) then Exit;

    // 1. Парсим входные параметры
    if not Params.TryGetValue<Cardinal>('oid', TargetOID) then Exit;
    if not Params.TryGetValue<Cardinal>('range', Range) then Range := 2000;
    if not Params.TryGetValue<Cardinal>('z_limit', ZLimit) then ZLimit := 300;

    // 2. Ищем базовый объект (от которого ищем врага)
    Obj := nil;
    if (FEngine.User <> nil) and (FEngine.User.OID = TargetOID) then
      Obj := FEngine.User
    else begin
      FEngine.Lock;
      try
        // Ищем в NPC и игроках
        if Assigned(FEngine.NpcList) then
          for i := 0 to FEngine.NpcList.Count - 1 do
            if (FEngine.NpcList.Items[i] <> nil) and (FEngine.NpcList.Items[i].OID = TargetOID) then begin
              Obj := FEngine.NpcList.Items[i];
              Break;
            end;
        if (Obj = nil) and Assigned(FEngine.CharList) then
          for i := 0 to FEngine.CharList.Count - 1 do
            if (FEngine.CharList.Items[i] <> nil) and (FEngine.CharList.Items[i].OID = TargetOID) then begin
              Obj := FEngine.CharList.Items[i];
              Break;
            end;
      finally
        FEngine.UnLock;
      end;
    end;

    if not Assigned(Obj) then Exit;

    // 3. Вызываем поиск врага
    Enemy := nil;
    if FEngine.FindEnemy(Enemy, Obj, Range, ZLimit) and Assigned(Enemy) then
    begin
      Resp := TJSONObject.Create;
      FillL2Live(Enemy, Resp);
      Result.Free;
      Result := Resp;
    end;

  except
    on E: Exception do
      TraceException('MethodFindEnemy', E);
  end;
end;
function TCommandProcessor.MethodAutoTarget(Params: TJSONObject): TJSONValue;
var
  Range, ZLimit: Cardinal;
  NotBusy: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Парсим параметры с дефолтными значениями из оригинальной функции
    if not Params.TryGetValue<Cardinal>('range', Range) then Range := 2000;
    if not Params.TryGetValue<Cardinal>('z_limit', ZLimit) then ZLimit := 300;
    if not Params.TryGetValue<Boolean>('not_busy', NotBusy) then NotBusy := True;

    Result.Free;
    Result := TJSONBool.Create(FEngine.AutoTarget(Range, ZLimit, NotBusy));
  except
    on E: Exception do
      TraceException('MethodAutoTarget', E);
  end;
end;
function TCommandProcessor.MethodIgnore(Params: TJSONObject): TJSONValue;
var
  TargetOID: Cardinal;
  i: Integer;
  Obj, FoundObj: IL2Spawn;
begin
  Result := TJSONNull.Create;
  FoundObj := nil;
  try
    if not Assigned(FEngine) or not Params.TryGetValue<Cardinal>('oid', TargetOID) then Exit;

    FEngine.Lock;
    try
      // Ищем объект в списках NPC или Drop
      // 1. Поиск в NPC
      if Assigned(FEngine.NpcList) then
        for i := 0 to FEngine.NpcList.Count - 1 do
        begin
          Obj := FEngine.NpcList.Items[i];
          if (Obj <> nil) and (Obj.OID = TargetOID) then
          begin
            FoundObj := Obj;
            Break;
          end;
        end;

      // 2. Поиск в Drop
      if (FoundObj = nil) and Assigned(FEngine.DropList) then
        for i := 0 to FEngine.DropList.Count - 1 do
        begin
          Obj := FEngine.DropList.Items[i];
          if (Obj <> nil) and (Obj.OID = TargetOID) then
          begin
            FoundObj := Obj;
            Break;
          end;
        end;
    finally
      FEngine.UnLock;
    end;

    if FoundObj <> nil then
      FEngine.Ignore(FoundObj);
  except
    on E: Exception do
      TraceException('MethodIgnore', E);
  end;
end;
function TCommandProcessor.MethodClearIgnore(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONNull.Create;
  try
    if Assigned(FEngine) then
      FEngine.ClearIgnore;
  except
    on E: Exception do
      TraceException('MethodClearIgnore', E);
  end;
end;
function TCommandProcessor.MethodIsBusy(Params: TJSONObject): TJSONValue;
var
  TargetOID: Cardinal;
  i: Integer;
  FoundNpc: IL2Npc;
begin
  Result := TJSONBool.Create(False);
  FoundNpc := nil;
  try
    if not Assigned(FEngine) or not Assigned(FEngine.NpcList) then Exit;
    if not Params.TryGetValue<Cardinal>('oid', TargetOID) then Exit;

    // Ищем NPC по OID
    FEngine.Lock;
    try
      for i := 0 to FEngine.NpcList.Count - 1 do
      begin
        if (FEngine.NpcList.Items[i] <> nil) and (FEngine.NpcList.Items[i].OID = TargetOID) then
        begin
          FoundNpc := FEngine.NpcList.Items[i];
          Break;
        end;
      end;
    finally
      FEngine.UnLock;
    end;

    if FoundNpc <> nil then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.IsBusy(FoundNpc));
    end;
  except
    on E: Exception do
      TraceException('MethodIsBusy', E);
  end;
end;
function TCommandProcessor.MethodUseSkill(Params: TJSONObject): TJSONValue;
var
  SkillID: Cardinal;
  Force, Shift: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // ID умения обязателен
    if not Params.TryGetValue<Cardinal>('id', SkillID) then Exit;

    // Опциональные флаги
    if not Params.TryGetValue<Boolean>('force', Force) then Force := False;
    if not Params.TryGetValue<Boolean>('shift', Shift) then Shift := False;

    Result.Free;
    // Вызываем оригинальный метод движка
    Result := TJSONBool.Create(FEngine.UseSkill(SkillID, Force, Shift));
  except
    on E: Exception do
      TraceException('MethodUseSkill', E);
  end;
end;
function TCommandProcessor.MethodDUseSkill(Params: TJSONObject): TJSONValue;
var
  SkillID: Cardinal;
  Force, Shift: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Извлекаем параметры. В DUseSkill обычно важны все три.
    if not Params.TryGetValue<Cardinal>('id', SkillID) then Exit;
    if not Params.TryGetValue<Boolean>('force', Force) then Force := False;
    if not Params.TryGetValue<Boolean>('shift', Shift) then Shift := False;

    Result.Free;
    // Прямой вызов метода движка
    Result := TJSONBool.Create(FEngine.DUseSkill(SkillID, Force, Shift));
  except
    on E: Exception do
      TraceException('MethodDUseSkill', E);
  end;
end;
function TCommandProcessor.MethodUseSkillGround(Params: TJSONObject): TJSONValue;
var
  SkillID: Cardinal;
  X, Y, Z: Integer;
  Force, Shift: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Обязательные параметры
    if not Params.TryGetValue<Cardinal>('id', SkillID) then Exit;
    if not Params.TryGetValue<Integer>('x', X) then Exit;
    if not Params.TryGetValue<Integer>('y', Y) then Exit;
    if not Params.TryGetValue<Integer>('z', Z) then Exit;

    // Опциональные флаги
    if not Params.TryGetValue<Boolean>('force', Force) then Force := False;
    if not Params.TryGetValue<Boolean>('shift', Shift) then Shift := False;

    Result.Free;
    Result := TJSONBool.Create(FEngine.UseSkillGround(SkillID, X, Y, Z, Force, Shift));
  except
    on E: Exception do
      TraceException('MethodUseSkillGround', E);
  end;
end;
function TCommandProcessor.MethodStopCasting(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.StopCasting);
    end;
  except
    on E: Exception do
      TraceException('MethodStopCasting', E);
  end;
end;
function TCommandProcessor.MethodDispel(Params: TJSONObject): TJSONValue;
var
  SkillID: Cardinal;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    if not Params.TryGetValue<Cardinal>('id', SkillID) then Exit;

    Result.Free;
    Result := TJSONBool.Create(FEngine.Dispel(SkillID));
  except
    on E: Exception do
      TraceException('MethodDispel', E);
  end;
end;
function TCommandProcessor.MethodLearnSkill(Params: TJSONObject): TJSONValue;
var
  SkillID: Cardinal;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    if not Params.TryGetValue<Cardinal>('id', SkillID) then Exit;

    Result.Free;
    Result := TJSONBool.Create(FEngine.LearnSkill(SkillID));
  except
    on E: Exception do
      TraceException('MethodLearnSkill', E);
  end;
end;
function TCommandProcessor.MethodUpdateSkillList(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.UpdateSkillList);
    end;
  except
    on E: Exception do
      TraceException('MethodUpdateSkillList', E);
  end;
end;
function TCommandProcessor.MethodUseItemByName(Params: TJSONObject): TJSONValue;
var Name: string; ByPet, Force: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) or not Params.TryGetValue<string>('name', Name) then Exit;
    Params.TryGetValue<Boolean>('by_pet', ByPet);
    Params.TryGetValue<Boolean>('force', Force);
    Result.Free;
    Result := TJSONBool.Create(FEngine.UseItem(Name, ByPet, Force));
  except on E: Exception do TraceException('MethodUseItemByName', E); end;
end;
function TCommandProcessor.MethodUseItemByID(Params: TJSONObject): TJSONValue;
var ID: Cardinal; ByPet, Force: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) or not Params.TryGetValue<Cardinal>('id', ID) then Exit;
    Params.TryGetValue<Boolean>('by_pet', ByPet);
    Params.TryGetValue<Boolean>('force', Force);
    Result.Free;
    Result := TJSONBool.Create(FEngine.UseItem(ID, ByPet, Force));
  except on E: Exception do TraceException('MethodUseItemByID', E); end;
end;
function TCommandProcessor.MethodUseItemByOid(Params: TJSONObject): TJSONValue;
var
  Oid: Cardinal;
  ByPet, Force: Boolean;
  i: Integer;
  ItemList: IItemList;
  Item, FoundItem: IL2Item;
begin
  Result := TJSONBool.Create(False);
  FoundItem := nil;
  try
    if not Assigned(FEngine) or (FEngine.Inventory = nil) then Exit;

    if not Params.TryGetValue<Cardinal>('oid', Oid) then Exit;
    if not Params.TryGetValue<Boolean>('by_pet', ByPet) then ByPet := False;
    if not Params.TryGetValue<Boolean>('force', Force) then Force := False;

    // Выбираем нужный список через интерфейс IInventory
    if ByPet then
      ItemList := FEngine.Inventory.Pet
    else
      ItemList := FEngine.Inventory.User;

    if Assigned(ItemList) then
    begin
      FEngine.Lock;
      try
        for i := 0 to ItemList.Count - 1 do
        begin
          Item := ItemList.Items[i];
          if (Item <> nil) and (Item.OID = Oid) then
          begin
            FoundItem := Item;
            Break;
          end;
        end;
      finally
        FEngine.UnLock;
      end;

      if FoundItem <> nil then
      begin
        Result.Free;
        Result := TJSONBool.Create(FEngine.UseItem(FoundItem, ByPet, Force));
      end;
    end;
  except
    on E: Exception do
      TraceException('MethodUseItemByOid', E);
  end;
end;
function TCommandProcessor.MethodUseItemOID(Params: TJSONObject): TJSONValue;
var
  OID: Cardinal;
  ByPet, Force: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    if not Params.TryGetValue<Cardinal>('oid', OID) then Exit;
    if not Params.TryGetValue<Boolean>('by_pet', ByPet) then ByPet := False;
    if not Params.TryGetValue<Boolean>('force', Force) then Force := False;

    Result.Free;
    // Прямой вызов перегруженного метода движка по OID
    Result := TJSONBool.Create(FEngine.UseItemOID(OID, ByPet, Force));
  except
    on E: Exception do
      TraceException('MethodUseItemOID', E);
  end;
end;
function TCommandProcessor.MethodDestroyItemByName(Params: TJSONObject): TJSONValue;
var Name: string; Count: Cardinal;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) and Params.TryGetValue<string>('name', Name) and Params.TryGetValue<Cardinal>('count', Count) then begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.DestroyItem(Name, Count));
    end;
  except on E: Exception do TraceException('MethodDestroyItemByName', E); end;
end;
function TCommandProcessor.MethodDestroyItemByID(Params: TJSONObject): TJSONValue;
var ID: Integer; Count: Cardinal;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) and Params.TryGetValue<Integer>('id', ID) and Params.TryGetValue<Cardinal>('count', Count) then begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.DestroyItem(ID, Count));
    end;
  except on E: Exception do TraceException('MethodDestroyItemByID', E); end;
end;
function TCommandProcessor.MethodDestroyItemByOid(Params: TJSONObject): TJSONValue;
var Oid, Count: Cardinal; i: Integer;
    Item, FoundItem: IL2Item;
begin
  Result := TJSONBool.Create(False);
  FoundItem := nil;
  try
    if not Assigned(FEngine) or (FEngine.Inventory = nil) then Exit;
    if not Params.TryGetValue<Cardinal>('oid', Oid) or not Params.TryGetValue<Cardinal>('count', Count) then Exit;

    FEngine.Lock;
    try
      for i := 0 to FEngine.Inventory.User.Count - 1 do begin
        Item := FEngine.Inventory.User.Items[i];
        if (Item <> nil) and (Item.OID = Oid) then begin
          FoundItem := Item;
          Break;
        end;
      end;
    finally
      FEngine.UnLock;
    end;

    if FoundItem <> nil then begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.DestroyItem(FoundItem, Count));
    end;
  except on E: Exception do TraceException('MethodDestroyItemByOid', E); end;
end;
function TCommandProcessor.MethodDropItem(Params: TJSONObject): TJSONValue;
var
  ItemID, Count: Cardinal;
  X, Y, Z: Integer;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Парсим параметры
    if not Params.TryGetValue<Cardinal>('id', ItemID) then Exit;
    if not Params.TryGetValue<Cardinal>('count', Count) then Exit;
    if not Params.TryGetValue<Integer>('x', X) then Exit;
    if not Params.TryGetValue<Integer>('y', Y) then Exit;
    if not Params.TryGetValue<Integer>('z', Z) then Exit;

    Result.Free;
    Result := TJSONBool.Create(FEngine.DropItem(ItemID, Count, X, Y, Z));
  except
    on E: Exception do
      TraceException('MethodDropItem', E);
  end;
end;
function TCommandProcessor.MethodMakeItem(Params: TJSONObject): TJSONValue;
var
  Index: Cardinal;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Извлекаем индекс рецепта
    if not Params.TryGetValue<Cardinal>('index', Index) then Exit;

    Result.Free;
    Result := TJSONBool.Create(FEngine.MakeItem(Index));
  except
    on E: Exception do
      TraceException('MethodMakeItem', E);
  end;
end;
function TCommandProcessor.MethodCrystalItemByID(Params: TJSONObject): TJSONValue;
var
  ItemID: Cardinal;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) and Params.TryGetValue<Cardinal>('id', ItemID) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.CrystalItem(ItemID));
    end;
  except
    on E: Exception do TraceException('MethodCrystalItemByID', E);
  end;
end;
function TCommandProcessor.MethodCrystalItemByOid(Params: TJSONObject): TJSONValue;
var
  Oid: Cardinal;
  i: Integer;
  Item, FoundItem: IL2Item;
begin
  Result := TJSONBool.Create(False);
  FoundItem := nil;
  try
    if not Assigned(FEngine) or (FEngine.Inventory = nil) then Exit;
    if not Params.TryGetValue<Cardinal>('oid', Oid) then Exit;

    FEngine.Lock;
    try
      for i := 0 to FEngine.Inventory.User.Count - 1 do
      begin
        Item := FEngine.Inventory.User.Items[i];
        if (Item <> nil) and (Item.OID = Oid) then
        begin
          FoundItem := Item;
          Break;
        end;
      end;
    finally
      FEngine.UnLock;
    end;

    if FoundItem <> nil then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.CrystalItem(FoundItem));
    end;
  except
    on E: Exception do TraceException('MethodCrystalItemByOid', E);
  end;
end;
function TCommandProcessor.MethodMoveItem(Params: TJSONObject): TJSONValue;
var
  ItemName: string;
  Count: Cardinal;
  ToPet: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Извлекаем параметры
    if not Params.TryGetValue<string>('name', ItemName) then Exit;
    if not Params.TryGetValue<Cardinal>('count', Count) then Exit;
    if not Params.TryGetValue<Boolean>('to_pet', ToPet) then ToPet := False;

    Result.Free;
    // Вызываем метод движка
    Result := TJSONBool.Create(FEngine.MoveItem(ItemName, Count, ToPet));
  except
    on E: Exception do
      TraceException('MethodMoveItem', E);
  end;
end;
function TCommandProcessor.MethodLoadItems(Params: TJSONObject): TJSONValue;
var
  ToWH: Boolean;
  JSArray: TJSONArray;
  IDList: array of Cardinal;
  i: Integer;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['to_wh'];
    if (LValue <> nil) and (LValue is TJSONBool) then
      ToWH := TJSONBool(LValue).AsBoolean
    else
      Exit;

    LValue := Params.Values['list'];
    if (LValue <> nil) and (LValue is TJSONArray) then
      JSArray := TJSONArray(LValue)
    else
      Exit;

    SetLength(IDList, JSArray.Count);
    for i := 0 to JSArray.Count - 1 do
    begin
      IDList[i] := Cardinal(StrToIntDef(JSArray.Items[i].Value, 0));
    end;

    Result.Free;
    Result := TJSONBool.Create(FEngine.LoadItems(ToWH, IDList));
  except
    on E: Exception do
      TraceException('MethodLoadItems', E);
  end;
end;
function TCommandProcessor.MethodAutoSoulShot(Params: TJSONObject): TJSONValue;
var
  ItemName: string;
  IsActive: Boolean;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Извлекаем имя предмета
    LValue := Params.Values['name'];
    if Assigned(LValue) then ItemName := LValue.Value
    else Exit;

    // Извлекаем флаг активности
    LValue := Params.Values['active'];
    if (LValue <> nil) and (LValue is TJSONBool) then
      IsActive := TJSONBool(LValue).AsBoolean
    else
      IsActive := False;

    Result.Free;
    Result := TJSONBool.Create(FEngine.AutoSoulShot(ItemName, IsActive));
  except
    on E: Exception do
      TraceException('MethodAutoSoulShot', E);
  end;
end;
function TCommandProcessor.MethodDAutoSoulShot(Params: TJSONObject): TJSONValue;
var
  ItemID: Cardinal;
  IsActive: Boolean;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Извлекаем ID (через Int64 для безопасности Cardinal)
    LValue := Params.Values['id'];
    if Assigned(LValue) then ItemID := Cardinal(StrToInt64Def(LValue.Value, 0))
    else Exit;

    // Извлекаем флаг активности
    LValue := Params.Values['active'];
    if (LValue <> nil) and (LValue is TJSONBool) then
      IsActive := TJSONBool(LValue).AsBoolean
    else
      IsActive := False;

    Result.Free;
    Result := TJSONBool.Create(FEngine.DAutoSoulShot(ItemID, IsActive));
  except
    on E: Exception do
      TraceException('MethodDAutoSoulShot', E);
  end;
end;
function TCommandProcessor.MethodEquipped(Params: TJSONObject): TJSONValue;
var
  ItemName: string;
  LValue: TJSONValue;
begin
  // По умолчанию возвращаем 0 (не надето)
  Result := TJSONNumber.Create(0);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['name'];
    if Assigned(LValue) then
    begin
      ItemName := LValue.Value;
      Result.Free;
      // Вызываем метод движка и возвращаем число
      Result := TJSONNumber.Create(FEngine.Equipped(ItemName));
    end;
  except
    on E: Exception do
      TraceException('MethodEquipped', E);
  end;
end;
function TCommandProcessor.MethodDismissPet(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.DismissPet);
    end;
  except
    on E: Exception do
      TraceException('MethodDismissPet', E);
  end;
end;
function TCommandProcessor.MethodDismissSum(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.DismissSum);
    end;
  except
    on E: Exception do
      TraceException('MethodDismissSum', E);
  end;
end;
function TCommandProcessor.MethodSay(Params: TJSONObject): TJSONValue;
var
  Text, PlayerName: string;
  ChatType: Cardinal;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Извлекаем текст
    LValue := Params.Values['text'];
    if Assigned(LValue) then Text := LValue.Value else Exit;

    // Извлекаем тип чата
    LValue := Params.Values['chat_type'];
    if Assigned(LValue) then ChatType := Cardinal(StrToInt64Def(LValue.Value, 0)) else ChatType := 0;

    // Извлекаем имя игрока
    LValue := Params.Values['player_name'];
    if Assigned(LValue) then PlayerName := LValue.Value else PlayerName := '';

    Result.Free;
    Result := TJSONBool.Create(FEngine.Say(Text, ChatType, PlayerName));
  except
    on E: Exception do
      TraceException('MethodSay', E);
  end;
end;
function TCommandProcessor.MethodInviteParty(Params: TJSONObject): TJSONValue;
var
  PlayerName: string;
  LootIdx: Integer;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Извлекаем имя игрока
    LValue := Params.Values['name'];
    if Assigned(LValue) then PlayerName := LValue.Value else Exit;

    // Извлекаем тип лута (по умолчанию 0 - ldLooter)
    LValue := Params.Values['loot_mode'];
    if Assigned(LValue) then
      LootIdx := StrToIntDef(LValue.Value, 0)
    else
      LootIdx := 0;

    Result.Free;
    // Приводим Integer к типу перечисления TLootType
    Result := TJSONBool.Create(FEngine.InviteParty(PlayerName, TLootType(LootIdx)));
  except
    on E: Exception do
      TraceException('MethodInviteParty', E);
  end;
end;
function TCommandProcessor.MethodDismissParty(Params: TJSONObject): TJSONValue;
var
  PlayerName: string;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['name'];
    if Assigned(LValue) then
    begin
      PlayerName := LValue.Value;
      Result.Free;
      Result := TJSONBool.Create(FEngine.DismissParty(PlayerName));
    end;
  except
    on E: Exception do
      TraceException('MethodDismissParty', E);
  end;
end;
function TCommandProcessor.MethodJoinParty(Params: TJSONObject): TJSONValue;
var
  Accept: Boolean;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Извлекаем флаг Accept
    LValue := Params.Values['accept'];
    if (LValue <> nil) and (LValue is TJSONBool) then
      Accept := TJSONBool(LValue).AsBoolean
    else
      Accept := False;

    Result.Free;
    Result := TJSONBool.Create(FEngine.JoinParty(Accept));
  except
    on E: Exception do
      TraceException('MethodJoinParty', E);
  end;
end;
function TCommandProcessor.MethodLeaveParty(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.LeaveParty);
    end;
  except
    on E: Exception do
      TraceException('MethodLeaveParty', E);
  end;
end;
function TCommandProcessor.MethodSetPartyLeader(Params: TJSONObject): TJSONValue;
var
  PlayerName: string;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Извлекаем имя будущего лидера
    LValue := Params.Values['name'];
    if Assigned(LValue) then
    begin
      PlayerName := LValue.Value;
      Result.Free;
      Result := TJSONBool.Create(FEngine.SetPartyLeader(PlayerName));
    end;
  except
    on E: Exception do
      TraceException('MethodSetPartyLeader', E);
  end;
end;
function TCommandProcessor.MethodGetMentor(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONString.Create('');
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONString.Create(FEngine.GetMentor);
    end;
  except
    on E: Exception do
      TraceException('MethodGetMentor', E);
  end;
end;
function TCommandProcessor.MethodKickMentor(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.KickMentor);
    end;
  except
    on E: Exception do
      TraceException('MethodKickMentor', E);
  end;
end;
function TCommandProcessor.MethodCloseRoom(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.CloseRoom);
    end;
  except
    on E: Exception do
      TraceException('MethodCloseRoom', E);
  end;
end;
function TCommandProcessor.MethodCreateRoom(Params: TJSONObject): TJSONValue;
var
  Caption: string;
  MinLv, MaxLv: Integer;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Извлекаем заголовок
    LValue := Params.Values['caption'];
    if Assigned(LValue) then Caption := LValue.Value else Caption := '';

    // Извлекаем минимальный уровень
    LValue := Params.Values['min_level'];
    if Assigned(LValue) then MinLv := StrToIntDef(LValue.Value, 1) else MinLv := 1;

    // Извлекаем максимальный уровень
    LValue := Params.Values['max_level'];
    if Assigned(LValue) then MaxLv := StrToIntDef(LValue.Value, 99) else MaxLv := 99;

    Result.Free;
    Result := TJSONBool.Create(FEngine.CreateRoom(Caption, MinLv, MaxLv));
  except
    on E: Exception do
      TraceException('MethodCreateRoom', E);
  end;
end;
function TCommandProcessor.MethodAutoAcceptClan(Params: TJSONObject): TJSONValue;
var
  PlayersList: string;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(True);
  try
    if Assigned(FEngine) and Params.TryGetValue('players_list', LValue) then
    begin
      PlayersList := LValue.Value;
      FEngine.AutoAcceptClan(PlayersList);
    end;
  except
    on E: Exception do TraceException('MethodAutoAcceptClan', E);
  end;
end;
function TCommandProcessor.MethodAutoAcceptCC(Params: TJSONObject): TJSONValue;
var
  PlayersList: string;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(True);
  try
    if not Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(False);
      Exit;
    end;

    LValue := Params.Values['players_list'];
    if Assigned(LValue) then
    begin
      PlayersList := LValue.Value;
      FEngine.AutoAcceptCC(PlayersList);
    end;
  except
    on E: Exception do
      TraceException('MethodAutoAcceptCC', E);
  end;
end;
function TCommandProcessor.MethodAutoAcceptMentors(Params: TJSONObject): TJSONValue;
var
  PlayersList: string;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(True);
  try
    if not Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(False);
      Exit;
    end;

    LValue := Params.Values['players_list'];
    if Assigned(LValue) then
    begin
      PlayersList := LValue.Value;
      FEngine.AutoAcceptMentors(PlayersList);
    end;
  except
    on E: Exception do
      TraceException('MethodAutoAcceptMentors', E);
  end;
end;
function TCommandProcessor.MethodQuestStatusGetStage(Params: TJSONObject): TJSONValue;
var
  QuestID: Cardinal;
  LValue: TJSONValue;
begin
  Result := TJSONNumber.Create(0);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['id'];
    if Assigned(LValue) then
    begin
      QuestID := Cardinal(StrToInt64Def(LValue.Value, 0));
      Result.Free;
      Result := TJSONNumber.Create(FEngine.QuestStatus2(QuestID));
    end;
  except
    on E: Exception do TraceException('MethodQuestStatusGetStage', E);
  end;
end;
function TCommandProcessor.MethodQuestStatusCheckStage(Params: TJSONObject): TJSONValue;
var
  QuestID, Stage: Cardinal;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['id'];
    if not Assigned(LValue) then Exit;
    QuestID := Cardinal(StrToInt64Def(LValue.Value, 0));

    LValue := Params.Values['stage'];
    if not Assigned(LValue) then Exit;
    Stage := Cardinal(StrToInt64Def(LValue.Value, 0));

    Result.Free;
    Result := TJSONBool.Create(FEngine.QuestStatus(QuestID, Stage));
  except
    on E: Exception do TraceException('MethodQuestStatusCheckStage', E);
  end;
end;
function TCommandProcessor.MethodCancelQuest(Params: TJSONObject): TJSONValue;
var
  QuestID: Integer;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['id'];
    if Assigned(LValue) then
    begin
      QuestID := StrToIntDef(LValue.Value, 0);
      Result.Free;
      Result := TJSONBool.Create(FEngine.CancelQuest(QuestID));
    end;
  except
    on E: Exception do
      TraceException('MethodCancelQuest', E);
  end;
end;
function TCommandProcessor.MethodOpenQuestion(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.OpenQuestion);
    end;
  except
    on E: Exception do
      TraceException('MethodOpenQuestion', E);
  end;
end;
function TCommandProcessor.MethodGetDailyItems(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.GetDailyItems);
    end;
  except
    on E: Exception do
      TraceException('MethodGetDailyItems', E);
  end;
end;
function TCommandProcessor.MethodGetDailyItem(Params: TJSONObject): TJSONValue;
var
  ItemID: Cardinal;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['id'];
    if Assigned(LValue) then
    begin
      ItemID := Cardinal(StrToInt64Def(LValue.Value, 0));
      Result.Free;
      Result := TJSONBool.Create(FEngine.GetDailyItem(ItemID));
    end;
  except
    on E: Exception do
      TraceException('MethodGetDailyItem', E);
  end;
end;
function TCommandProcessor.MethodUpdateDailyList(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.UpdateDailyList);
    end;
  except
    on E: Exception do
      TraceException('MethodUpdateDailyList', E);
  end;
end;
function TCommandProcessor.MethodDlgOpen(Params: TJSONObject): TJSONValue;
var
  Timeout: Cardinal;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;
    //FEngine.Lock;
    LValue := Params.Values['timeout'];
    if Assigned(LValue) then
      Timeout := Cardinal(StrToInt64Def(LValue.Value, 5000))
    else
      Timeout := 5000;

    Result.Free;
    Result := TJSONBool.Create(FEngine.DlgOpen(Timeout));
   // FEngine.UnLock;
  except
    on E: Exception do      begin
     // FEngine.UnLock;
      TraceException('MethodDlgOpen', E);
    end;
  end;
end;
function TCommandProcessor.MethodDlgSel(Params: TJSONObject): TJSONValue;
var
  Index: Integer;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['index'];
    if Assigned(LValue) then
    begin
      Index := StrToIntDef(LValue.Value, 0);
      Result.Free;
      Result := TJSONBool.Create(FEngine.DlgSel(Index));
    end;
  except
    on E: Exception do
      TraceException('MethodDlgSel', E);
  end;
end;
function TCommandProcessor.MethodDlgSelText(Params: TJSONObject): TJSONValue;
var
  Caption: string;
  Timeout: Integer;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    // Извлекаем текст кнопки
    LValue := Params.Values['caption'];
    if not Assigned(LValue) then Exit;
    Caption := LValue.Value;

    // Извлекаем таймаут (по умолчанию 1000 мс)
    LValue := Params.Values['timeout'];
    if Assigned(LValue) then
      Timeout := StrToIntDef(LValue.Value, 1000)
    else
      Timeout := 1000;

    Result.Free;
    Result := TJSONBool.Create(FEngine.DlgSel(Caption, Timeout));
  except
    on E: Exception do
      TraceException('MethodDlgSelText', E);
  end;
end;
function TCommandProcessor.MethodBypassToServer(Params: TJSONObject): TJSONValue;
var
  BypassText: string;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['text'];
    if Assigned(LValue) then
    begin
      BypassText := LValue.Value;
      Result.Free;
      Result := TJSONBool.Create(FEngine.BypassToServer(BypassText));
    end;
  except
    on E: Exception do
      TraceException('MethodBypassToServer', E);
  end;
end;
function TCommandProcessor.MethodDlgText(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONString.Create('');
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONString.Create(FEngine.DlgText);
    end;
  except
    on E: Exception do
      TraceException('MethodDlgText', E);
  end;
end;
function TCommandProcessor.MethodDlgTime(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONNumber.Create(0);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONNumber.Create(FEngine.DlgTime);
    end;
  except
    on E: Exception do
      TraceException('MethodDlgTime', E);
  end;
end;
function TCommandProcessor.MethodCBText(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONString.Create('');
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONString.Create(FEngine.CBText);
    end;
  except
    on E: Exception do
      TraceException('MethodCBText', E);
  end;
end;
function TCommandProcessor.MethodCBTime(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONNumber.Create(0);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONNumber.Create(FEngine.CBTime);
    end;
  except
    on E: Exception do
      TraceException('MethodCBTime', E);
  end;
end;
function TCommandProcessor.MethodHlpText(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONString.Create('');
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONString.Create(FEngine.HlpText);
    end;
  except
    on E: Exception do
      TraceException('MethodHlpText', E);
  end;
end;
function TCommandProcessor.MethodHlpTime(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONNumber.Create(0);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONNumber.Create(FEngine.HlpTime);
    end;
  except
    on E: Exception do
      TraceException('MethodHlpTime', E);
  end;
end;
function TCommandProcessor.MethodConfirmDlg(Params: TJSONObject): TJSONValue;
var
  Dlg: IConfirmDlg;
  ResObj: TJSONObject;
begin
  Result := TJSONNull.Create;
  try
    if Assigned(FEngine) then
    begin
      Dlg := FEngine.ConfirmDlg;
      if Dlg.Valid then
      begin
        Result.Free;
        ResObj := TJSONObject.Create;
        FillL2ConfirmDlg(Dlg, ResObj);
        Result := ResObj;
      end;
    end;
  except
    on E: Exception do
      TraceException('MethodConfirmDlg', E);
  end;
end;
function TCommandProcessor.MethodConfirmDialog(Params: TJSONObject): TJSONValue;
var
  Accept: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) and Params.TryGetValue('accept', Accept) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.ConfirmDialog(Accept));
    end;
  except
    on E: Exception do TraceException('MethodConfirmDialog', E);
  end;
end;
function TCommandProcessor.MethodOpenPrivateStore(Params: TJSONObject): TJSONValue;
var
  ItemsArray: TJSONArray;
  List: array of Cardinal;
  StoreType: Byte;
  StoreCaption: string;
  I: Integer;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    ItemsArray := Params.Values['list'] as TJSONArray;
    SetLength(List, ItemsArray.Count);
    for I := 0 to ItemsArray.Count - 1 do
      List[I] := Cardinal(StrToInt64Def(ItemsArray.Items[I].Value, 0));

    StoreType := Byte(StrToIntDef(Params.Values['store_type'].Value, 1));
    StoreCaption := Params.Values['caption'].Value;

    Result.Free;
    Result := TJSONBool.Create(FEngine.OpenPrivateStore(List, StoreType, StoreCaption));
  except
    on E: Exception do
      TraceException('MethodOpenPrivateStore', E);
  end;
end;
function TCommandProcessor.MethodNpcTrade(Params: TJSONObject): TJSONValue;
var
  Sell: Boolean;
  ItemsArray: TJSONArray;
  List: array of Cardinal;
  I: Integer;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['sell'];
    Sell := Assigned(LValue) and (LValue is TJSONTrue);

    if Params.Values['list'] is TJSONArray then
    begin
      ItemsArray := Params.Values['list'] as TJSONArray;
      SetLength(List, ItemsArray.Count);
      for I := 0 to ItemsArray.Count - 1 do
        List[I] := Cardinal(StrToInt64Def(ItemsArray.Items[I].Value, 0));

      Result.Free;
      Result := TJSONBool.Create(FEngine.NpcTrade(Sell, List));
    end;
  except
    on E: Exception do
      TraceException('MethodNpcTrade', E);
  end;
end;
function TCommandProcessor.MethodNpcExchange(Params: TJSONObject): TJSONValue;
var
  IDorIndex, Count: Cardinal;
  ByIndex: Boolean;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['id_or_index'];
    if not Assigned(LValue) then Exit;
    IDorIndex := Cardinal(StrToInt64Def(LValue.Value, 0));

    LValue := Params.Values['count'];
    if Assigned(LValue) then
      Count := Cardinal(StrToInt64Def(LValue.Value, 1))
    else
      Count := 1;

    LValue := Params.Values['by_index'];
    ByIndex := Assigned(LValue) and (LValue is TJSONTrue);

    Result.Free;
    Result := TJSONBool.Create(FEngine.NpcExchange(IDorIndex, Count, ByIndex));
  except
    on E: Exception do
      TraceException('MethodNpcExchange', E);
  end;
end;
function TCommandProcessor.MethodCastleTax(Params: TJSONObject): TJSONValue;
var
  TownID: Cardinal;
  LValue: TJSONValue;
begin
  Result := TJSONNumber.Create(-1);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['town_id'];
    if Assigned(LValue) then
    begin
      TownID := Cardinal(StrToInt64Def(LValue.Value, 0));
      Result.Free;
      Result := TJSONNumber.Create(FEngine.CastleTax(TownID));
    end;
  except
    on E: Exception do
      TraceException('MethodCastleTax', E);
  end;
end;
function TCommandProcessor.MethodSendMail(Params: TJSONObject): TJSONValue;
var
  Receiver, Topic, MailText: string;
  ItemsArray: TJSONArray;
  List: array of Cardinal;
  Price: Cardinal;
  I: Integer;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    Receiver := Params.Values['receiver'].Value;
    Topic    := Params.Values['topic'].Value;
    MailText := Params.Values['text'].Value;

    if Params.Values['items'] is TJSONArray then
    begin
      ItemsArray := Params.Values['items'] as TJSONArray;
      SetLength(List, ItemsArray.Count);
      for I := 0 to ItemsArray.Count - 1 do
        List[I] := Cardinal(StrToInt64Def(ItemsArray.Items[I].Value, 0));
    end;

    Price := Cardinal(StrToInt64Def(Params.Values['price'].Value, 0));

    Result.Free;
    Result := TJSONBool.Create(FEngine.SendMail(Receiver, Topic, MailText, List, Price));
  except
    on E: Exception do
      TraceException('MethodSendMail', E);
  end;
end;
function TCommandProcessor.MethodGetMailItems(Params: TJSONObject): TJSONValue;
var
  MaxLoad, MaxCount: Cardinal;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['max_load'];
    if Assigned(LValue) then MaxLoad := Cardinal(StrToInt64Def(LValue.Value, 65))
    else MaxLoad := 65;

    LValue := Params.Values['max_count'];
    if Assigned(LValue) then MaxCount := Cardinal(StrToInt64Def(LValue.Value, 1000))
    else MaxCount := 1000;

    Result.Free;
    Result := TJSONBool.Create(FEngine.GetMailItems(MaxLoad, MaxCount));
  except
    on E: Exception do
      TraceException('MethodGetMailItems', E);
  end;
end;
function TCommandProcessor.MethodGetZoneType(Params: TJSONObject): TJSONValue;
var
  Zone: TZoneType;
  ZoneName: string;
begin
  Result := TJSONString.Create('ztUnknown');
  try
    if Assigned(FEngine) then
    begin
      Zone := FEngine.GetZoneType;
      ZoneName := GetEnumName(TypeInfo(TZoneType), Ord(Zone));
      Result.Free;
      Result := TJSONString.Create(ZoneName);
    end;
  except
    on E: Exception do
      TraceException('MethodGetZoneType', E);
  end;
end;
function TCommandProcessor.MethodGetZoneName(Params: TJSONObject): TJSONValue;
var
  X, Y, Z: Integer;
begin
  Result := TJSONString.Create('Unknown Zone');
  try
    if not Assigned(FEngine) then Exit;

    X := StrToIntDef(Params.Values['x'].Value, 0);
    Y := StrToIntDef(Params.Values['y'].Value, 0);
    Z := StrToIntDef(Params.Values['z'].Value, 0);

    Result.Free;

    Result := TJSONString.Create(FEngine.GetZoneName(X, Y, Z));
  except
    on E: Exception do
      TraceException('MethodGetZoneName', E);
  end;
end;
function TCommandProcessor.MethodGetZoneID(Params: TJSONObject): TJSONValue;
var
  X, Y, Z: Integer;
begin
  Result := TJSONNumber.Create(0);
  try
    if not Assigned(FEngine) then Exit;

    X := StrToIntDef(Params.Values['x'].Value, 0);
    Y := StrToIntDef(Params.Values['y'].Value, 0);
    Z := StrToIntDef(Params.Values['z'].Value, 0);

    Result.Free;

    Result := TJSONNumber.Create(FEngine.GetZoneID(X, Y, Z));
  except
    on E: Exception do
      TraceException('MethodGetZoneID', E);
  end;
end;
function TCommandProcessor.MethodInZoneXYZ(Params: TJSONObject): TJSONValue;
var X, Y, Z: Integer;
begin
  Result := TJSONBool.Create(False);
  try
    X := StrToIntDef(Params.Values['x'].Value, 0);
    Y := StrToIntDef(Params.Values['y'].Value, 0);
    Z := StrToIntDef(Params.Values['z'].Value, 0);
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.InZone(X, Y, Z));
    end;
  except on E: Exception do TraceException('InZoneXYZ', E); end;
end;
function TCommandProcessor.MethodInZoneObj(Params: TJSONObject): TJSONValue;
var
  OID: Integer;
  I: Integer;
  FoundObj: IL2Spawn;
begin
  Result := TJSONBool.Create(False);
  FoundObj := nil;
  try
    OID := StrToIntDef(Params.Values['oid'].Value, 0);
    if not Assigned(FEngine) then Exit;

    // Проверка User
    if Assigned(FEngine.User) and (FEngine.User.OID = OID) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.InZone(FEngine.User));
      Exit;
    end;

    FEngine.Lock;
    try
      if Assigned(FEngine.NpcList) then
        for I := 0 to FEngine.NpcList.Count - 1 do
        begin
          if (FEngine.NpcList.Items[I] <> nil) and (FEngine.NpcList.Items[I].OID = OID) then
          begin
            FoundObj := FEngine.NpcList.Items[I];
            Break;
          end;
        end;

      if (FoundObj = nil) and Assigned(FEngine.CharList) then
        for I := 0 to FEngine.CharList.Count - 1 do
        begin
          if (FEngine.CharList.Items[I] <> nil) and (FEngine.CharList.Items[I].OID = OID) then
          begin
            FoundObj := FEngine.CharList.Items[I];
            Break;
          end;
        end;
    finally
      FEngine.UnLock;
    end;

    if FoundObj <> nil then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.InZone(FoundObj));
    end;
  except
    on E: Exception do TraceException('MethodInZoneObj', E);
  end;
end;
function TCommandProcessor.MethodGameTime(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONNumber.Create(0);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONNumber.Create(FEngine.GameTime);
    end;
  except
    on E: Exception do
      TraceException('MethodGameTime', E);
  end;
end;
function TCommandProcessor.MethodIsDay(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(True);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.IsDay);
    end;
  except
    on E: Exception do
      TraceException('MethodIsDay', E);
  end;
end;
function TCommandProcessor.MethodStatus(Params: TJSONObject): TJSONValue;
var
  LStatus: TL2Status;
  StatusName: string;
begin
  Result := TJSONString.Create('lsOff');
  try
    if Assigned(FEngine) then
    begin
      LStatus := FEngine.Status;
      StatusName := GetEnumName(TypeInfo(TL2Status), Ord(LStatus));
      Result.Free;
      Result := TJSONString.Create(StatusName);
    end;
  except
    on E: Exception do
      TraceException('MethodStatus', E);
  end;
end;
function TCommandProcessor.MethodLoginStatus(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONNumber.Create(-1);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONNumber.Create(FEngine.LoginStatus);
    end;
  except
    on E: Exception do
      TraceException('MethodLoginStatus', E);
  end;
end;
function TCommandProcessor.MethodAuthLogin(Params: TJSONObject): TJSONValue;
var
  Login, Password: string;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    Login := Params.Values['login'].Value;
    Password := Params.Values['password'].Value;

    Result.Free;
    Result := TJSONBool.Create(FEngine.AuthLogin(Login, Password));
  except
    on E: Exception do
      TraceException('MethodAuthLogin', E);
  end;
end;
function TCommandProcessor.MethodGameStart(Params: TJSONObject): TJSONValue;
var
  CharIndex: Integer;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['char_index'];
    if Assigned(LValue) then
      CharIndex := StrToIntDef(LValue.Value, -1)
    else
      CharIndex := -1;

    Result.Free;
    Result := TJSONBool.Create(FEngine.GameStart(CharIndex));
  except
    on E: Exception do
      TraceException('MethodGameStart', E);
  end;
end;
function TCommandProcessor.MethodRestart(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.Restart);
    end;
  except
    on E: Exception do
      TraceException('MethodRestart', E);
  end;
end;
function TCommandProcessor.MethodDRestart(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.DRestart);
    end;
  except
    on E: Exception do
      TraceException('MethodDRestart', E);
  end;
end;
function TCommandProcessor.MethodFaceControl(Params: TJSONObject): TJSONValue;
var
  ID: Integer;
  Active: Boolean;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    ID := StrToIntDef(Params.Values['id'].Value, 0);

    LValue := Params.Values['active'];
    Active := Assigned(LValue) and (LValue is TJSONTrue);

    Result.Free;
    Result := TJSONBool.Create(FEngine.FaceControl(ID, Active));
  except
    on E: Exception do
      TraceException('MethodFaceControl', E);
  end;
end;
function TCommandProcessor.MethodGetFaceState(Params: TJSONObject): TJSONValue;
var
  ID: Integer;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      ID := StrToIntDef(Params.Values['id'].Value, 0);
      Result.Free;
      Result := TJSONBool.Create(FEngine.GetFaceState(ID));
    end;
  except
    on E: Exception do
      TraceException('MethodGetFaceState', E);
  end;
end;
function TCommandProcessor.MethodUpdateCfg(Params: TJSONObject): TJSONValue;
var
  Wait: Boolean;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['wait'];
    Wait := Assigned(LValue) and (LValue is TJSONTrue);

    Result.Free;
    Result := TJSONBool.Create(FEngine.UpdateCfg(Wait));
  except
    on E: Exception do
      TraceException('MethodUpdateCfg', E);
  end;
end;
function TCommandProcessor.MethodLoadConfig(Params: TJSONObject): TJSONValue;
var
  FilePath: string;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    FilePath := Params.Values['file_path'].Value;

    Result.Free;
    Result := TJSONBool.Create(FEngine.LoadConfig(FilePath));
  except
    on E: Exception do
      TraceException('MethodLoadConfig', E);
  end;
end;
function TCommandProcessor.MethodLoadZone(Params: TJSONObject): TJSONValue;
var
  FilePath: string;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    FilePath := Params.Values['file_path'].Value;

    Result.Free;
    Result := TJSONBool.Create(FEngine.LoadZone(FilePath));
  except
    on E: Exception do
      TraceException('MethodLoadZone', E);
  end;
end;
function TCommandProcessor.MethodClearZone(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      FEngine.ClearZone;
      Result.Free;
      Result := TJSONBool.Create(True);
    end;
  except
    on E: Exception do
      TraceException('MethodClearZone', E);
  end;
end;
function TCommandProcessor.MethodSetPerform(Params: TJSONObject): TJSONValue;
var
  Level: Cardinal;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    Level := Cardinal(StrToInt64Def(Params.Values['level'].Value, 1));

    Result.Free;
    Result := TJSONBool.Create(FEngine.SetPerform(Level));
  except
    on E: Exception do
      TraceException('MethodSetPerform', E);
  end;
end;
function TCommandProcessor.MethodSetMapKeepDist(Params: TJSONObject): TJSONValue;
var
  Dist: Integer;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Dist := StrToIntDef(Params.Values['dist'].Value, 50);
      FEngine.SetMapKeepDist(Dist);

      Result.Free;
      Result := TJSONBool.Create(True);
    end;
  except
    on E: Exception do
      TraceException('MethodSetMapKeepDist', E);
  end;
end;
function TCommandProcessor.MethodGamePrint(Params: TJSONObject): TJSONValue;
var
  MsgText, Author: string;
  ChatType: Integer;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    MsgText := Params.Values['text'].Value;

    LValue := Params.Values['author'];
    if Assigned(LValue) then Author := LValue.Value else Author := '';

    LValue := Params.Values['chat_type'];
    if Assigned(LValue) then ChatType := StrToIntDef(LValue.Value, 0) else ChatType := 0;

    Result.Free;
    Result := TJSONBool.Create(FEngine.GamePrint(MsgText, Author, ChatType));
  except
    on E: Exception do
      TraceException('MethodGamePrint', E);
  end;
end;
function TCommandProcessor.MethodGameClose(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.GameClose);
    end;
  except
    on E: Exception do
      TraceException('MethodGameClose', E);
  end;
end;
function TCommandProcessor.MethodBlinkWindow(Params: TJSONObject): TJSONValue;
var
  TargetGame: Boolean;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['game'];
    TargetGame := not (Assigned(LValue) and (LValue is TJSONFalse));

    Result.Free;
    Result := TJSONBool.Create(FEngine.BlinkWindow(TargetGame));
  except
    on E: Exception do
      TraceException('MethodBlinkWindow', E);
  end;
end;
function TCommandProcessor.MethodSetGameWindow(Params: TJSONObject): TJSONValue;
var
  Show: Boolean;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['show'];

    Show := not (Assigned(LValue) and (LValue is TJSONFalse));

    Result.Free;
    Result := TJSONBool.Create(FEngine.SetGameWindow(Show));
  except
    on E: Exception do
      TraceException('MethodSetGameWindow', E);
  end;
end;
function TCommandProcessor.MethodUseKey(Params: TJSONObject): TJSONValue;
var
  LValue, LDownUp: TJSONValue;
  DownUp: Byte;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['key'];
    LDownUp := Params.Values['down_up'];

    DownUp := 0;
    if Assigned(LDownUp) then DownUp := StrToIntDef(LDownUp.Value, 0);

    Result.Free;


    if LValue is TJSONString then
      Result := TJSONBool.Create(FEngine.UseKey(LValue.Value, DownUp))

    else if LValue is TJSONNumber then
      Result := TJSONBool.Create(FEngine.UseKey(Word(StrToInt(LValue.Value)), DownUp));

  except
    on E: Exception do TraceException('MethodUseKey', E);
  end;
end;
function TCommandProcessor.MethodEnterText(Params: TJSONObject): TJSONValue;
var
  LText: string;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LText := Params.Values['text'].Value;

    Result.Free;
    Result := TJSONBool.Create(FEngine.EnterText(LText));
  except
    on E: Exception do
      TraceException('MethodEnterText', E);
  end;
end;
function TCommandProcessor.MethodPostMessage(Params: TJSONObject): TJSONValue;
var
  Msg: Cardinal;
  WParam, LParam: Integer;
begin
  Result := TJSONNumber.Create(-1);
  try
    if not Assigned(FEngine) then Exit;

    Msg := Cardinal(StrToInt64Def(Params.Values['msg'].Value, 0));
    WParam := StrToIntDef(Params.Values['w_param'].Value, 0);
    LParam := StrToIntDef(Params.Values['l_param'].Value, 0);

    Result.Free;
    Result := TJSONNumber.Create(FEngine.PostMessage(Msg, WParam, LParam));
  except
    on E: Exception do TraceException('MethodPostMessage', E);
  end;
end;
function TCommandProcessor.MethodSendMessage(Params: TJSONObject): TJSONValue;
var
  Msg: Cardinal;
  WParam, LParam: Integer;
begin
  Result := TJSONNumber.Create(-1);
  try
    if not Assigned(FEngine) then Exit;

    Msg := Cardinal(StrToInt64Def(Params.Values['msg'].Value, 0));
    WParam := StrToIntDef(Params.Values['w_param'].Value, 0);
    LParam := StrToIntDef(Params.Values['l_param'].Value, 0);

    Result.Free;
    Result := TJSONNumber.Create(FEngine.SendMessage(Msg, WParam, LParam));
  except
    on E: Exception do TraceException('MethodSendMessage', E);
  end;
end;
function TCommandProcessor.MethodGamePath(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONString.Create('');
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONString.Create(FEngine.GamePath);
    end;
  except
    on E: Exception do
      TraceException('MethodGamePath', E);
  end;
end;
function TCommandProcessor.MethodGameWindow(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONNumber.Create(0);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONNumber.Create(FEngine.GameWindow);
    end;
  except
    on E: Exception do
      TraceException('MethodGameWindow', E);
  end;
end;
function TCommandProcessor.MethodGameHash(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONNumber.Create(0);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONNumber.Create(FEngine.GameHash);
    end;
  except
    on E: Exception do
      TraceException('MethodGameHash', E);
  end;
end;
function TCommandProcessor.MethodGameProtocol(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONNumber.Create(0);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONNumber.Create(FEngine.GameProtocol);
    end;
  except
    on E: Exception do
      TraceException('MethodGameProtocol', E);
  end;
end;
function TCommandProcessor.MethodGameVersion(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONNumber.Create(0);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONNumber.Create(FEngine.GameVersion);
    end;
  except
    on E: Exception do
      TraceException('MethodGameVersion', E);
  end;
end;
function TCommandProcessor.MethodGetServerIP(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONString.Create('');
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONString.Create(FEngine.GetServerIP);
    end;
  except
    on E: Exception do
      TraceException('MethodGetServerIP', E);
  end;
end;
function TCommandProcessor.MethodGetServerName(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONString.Create('');
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONString.Create(FEngine.GetServerName);
    end;
  except
    on E: Exception do
      TraceException('MethodGetServerName', E);
  end;
end;
function TCommandProcessor.MethodGetServerID(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONNumber.Create(0);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;

      Result := TJSONNumber.Create(FEngine.GetServerID);
    end;
  except
    on E: Exception do
      TraceException('MethodGetServerID', E);
  end;
end;
function TCommandProcessor.MethodIsClassicServer(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      Result := TJSONBool.Create(FEngine.IsClassicServer);
    end;
  except
    on E: Exception do
      TraceException('MethodIsClassicServer', E);
  end;
end;
function TCommandProcessor.MethodServerTime(Params: TJSONObject): TJSONValue;
begin
  Result := TJSONNumber.Create(0);
  try
    if Assigned(FEngine) then
    begin
      Result.Free;
      // Получаем время от движка
      Result := TJSONNumber.Create(FEngine.ServerTime);
    end;
  except
    on E: Exception do
      TraceException('MethodServerTime', E);
  end;
end;
function TCommandProcessor.MethodMsg(Params: TJSONObject): TJSONValue;
var
  Title, Text: string;
  Color: Integer;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    Title := Params.Values['title'].Value;
    Text := Params.Values['text'].Value;
    Color := StrToIntDef(Params.Values['color'].Value, $FFFFFF);

    FEngine.Msg(Title, Text, Color);

    Result.Free;
    Result := TJSONBool.Create(True);
  except
    on E: Exception do TraceException('MethodMsg', E);
  end;
end;
function TCommandProcessor.MethodBlinkWindow2(Params: TJSONObject): TJSONValue;
var
  TargetGame: Boolean;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['game'];
    // Если параметр не передан, по умолчанию мигаем окном игры
    TargetGame := not (Assigned(LValue) and (LValue is TJSONFalse));

    Result.Free;
    Result := TJSONBool.Create(FEngine.BlinkWindow(TargetGame));
  except
    on E: Exception do
      TraceException('MethodBlinkWindow', E);
  end;
end;
function TCommandProcessor.MethodHKPauseScript(Params: TJSONObject): TJSONValue;
var
  Enable: Boolean;
  LValue: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LValue := Params.Values['enable'];

    Enable := not (Assigned(LValue) and (LValue is TJSONFalse));

    FEngine.HKPauseScript(Enable);

    Result.Free;
    Result := TJSONBool.Create(True);
  except
    on E: Exception do TraceException('MethodHKPauseScript', E);
  end;
end;
function TCommandProcessor.MethodSendActID(Params: TJSONObject): TJSONValue;
var
  Level: Cardinal;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    Level := Cardinal(StrToInt64Def(Params.Values['level'].Value, 0));

    Result.Free;
    Result := TJSONBool.Create(FEngine.SendActID(Level));
  except
    on E: Exception do
      TraceException('MethodSendActID', E);
  end;
end;
function TCommandProcessor.MethodSendToServer(Params: TJSONObject): TJSONValue;
var
  LText: string;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LText := Params.Values['text'].Value;

    Result.Free;
    Result := TJSONBool.Create(FEngine.SendToServer(LText));
  except
    on E: Exception do TraceException('MethodSendToServer', E);
  end;
end;
function TCommandProcessor.MethodSendToClient(Params: TJSONObject): TJSONValue;
var
  LText: string;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    LText := Params.Values['text'].Value;

    Result.Free;

    Result := TJSONBool.Create(FEngine.SendToClient(LText));
  except
    on E: Exception do TraceException('MethodSendToClient', E);
  end;
end;
function TCommandProcessor.MethodBlockPacket(Params: TJSONObject): TJSONValue;
var
  ID, ID2: Word;
  IsServerPacket: Boolean;
  Time: Cardinal;
  LTime: TJSONValue;
begin
  Result := TJSONBool.Create(False);
  try
    if not Assigned(FEngine) then Exit;

    ID := Word(StrToIntDef(Params.Values['id'].Value, 0));
    ID2 := Word(StrToIntDef(Params.Values['id2'].Value, 0));
    IsServerPacket := (Params.Values['is_server'] is TJSONTrue);

    LTime := Params.Values['time'];
    if Assigned(LTime) then
      Time := Cardinal(StrToInt64Def(LTime.Value, $FFFFFFFF))
    else
      Time := $FFFFFFFF;

    Result.Free;
    Result := TJSONBool.Create(FEngine.BlockPacket(ID, ID2, IsServerPacket, Time));
  except
    on E: Exception do TraceException('MethodBlockPacket', E);
  end;
end;
function TCommandProcessor.MethodWaitAction(Params: TJSONObject): TJSONValue;
var
  LActionVal, LTimeoutVal: TJSONValue;
  Actions: TL2Actions;
  TimeOut: Cardinal;
  Prm1, Prm2: Integer;
  ActionResult: TL2Action;
  ResObj: TJSONObject;
  ActionInt: Integer;
begin
  Result := TJSONNull.Create;
  try
    if not Assigned(FEngine) then Exit;

    LActionVal := Params.Values['action'];
    LTimeoutVal := Params.Values['timeout'];

    // 1. Формируем множество Actions
    Actions := [];
    if Assigned(LActionVal) then
    begin
      // Преобразуем значение в Integer безопасно
      ActionInt := StrToIntDef(LActionVal.Value, 0);
      Actions := [TL2Action(ActionInt)];
    end;

    // 2. Определяем таймаут (по умолчанию 5000 мс)
    TimeOut := 5000;
    if Assigned(LTimeoutVal) then
      TimeOut := Cardinal(StrToInt64Def(LTimeoutVal.Value, 5000));

    Prm1 := 0;
    Prm2 := 0;

    // 3. Вызов блокирующей функции движка
    ActionResult := FEngine.WaitAction2(Actions, Prm1, Prm2, TimeOut);

    // 4. Формируем JSON ответ
    ResObj := TJSONObject.Create;
    ResObj.AddPair('action_type', TJSONNumber.Create(Ord(ActionResult)));
    ResObj.AddPair('p1', TJSONNumber.Create(Prm1));
    ResObj.AddPair('p2', TJSONNumber.Create(Prm2));
    ResObj.AddPair('success', TJSONBool.Create(ActionResult <> laNull));

    Result.Free;
    Result := ResObj;
  except
    on E: Exception do TraceException('MethodWaitAction', E);
  end;
end;
function TCommandProcessor.MethodLoadGPSPoint(Params: TJSONObject): TJSONValue;
var
  FilePath: string;
begin
  Result := TJSONNumber.Create(0);
  try
    if not Assigned(FEngine) then Exit;

    FilePath := Params.Values['file_path'].Value;

    Result.Free;
    Result := TJSONNumber.Create(StrToInt(PluginProc(1000, FilePath)));
  except
    on E: Exception do
      TraceException('MethodLoadGPSPoint', E);
  end;
end;
function TCommandProcessor.MethodGPSMove(Params: TJSONObject): TJSONValue;
var
 GPSName:WideString;
 bValue: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      GPSName := Params.Values['gps_name'].Value;
      bValue:= (PluginProc(1001,GPSName) = '1');
      Result.Free;
      Result := TJSONBool.Create(bValue);
    end;
  except
    on E: Exception do
      TraceException('MethodGPSMove', E);
  end;
end;
function TCommandProcessor.MethodGetGPSPoint(Params: TJSONObject): TJSONValue;
var
 GPSName:WideString;
 Obj: TJSONObject;
begin
   Obj:= TJSONObject.Create;
  try
    if Assigned(FEngine) then
    begin
      GPSName := Params.Values['gps_name'].Value;
      FillGpsPointFromStr(PluginProc(1002, GPSName), Obj);
      Result:= Obj;
    end;
  except
    on E: Exception do
      TraceException('MethodGetGPSPoint', E);
  end;
end;
function TCommandProcessor.MethodGPSMoveRandom(Params: TJSONObject): TJSONValue;
var
 GPSName:WideString;
 RandomRange:WideString;
 bValue: Boolean;
begin
  Result := TJSONBool.Create(False);
  try
    if Assigned(FEngine) then
    begin
      GPSName := Params.Values['gps_name'].Value;
      RandomRange := Params.Values['gps_range'].Value;
      bValue:= (PluginProc(1003,GPSName, RandomRange) = '1');
      Result.Free;
      Result := TJSONBool.Create(bValue);
    end;
  except
    on E: Exception do
      TraceException('MethodGPSMove', E);
  end;
end;

//lists
function TCommandProcessor.GetNpcList(Params: TJSONObject): TJSONValue;
var
  jarray: TJSONArray;
begin
  TraceEnter('TCommandProcessor.GetNpcList');
  jarray := TJSONArray.Create;

  try
    if Assigned(FEngine) and Assigned(FEngine.NpcList) then
    begin
      FEngine.Lock;
      try
        FillL2NpcList(FEngine.NpcList, jarray);
      finally
        FEngine.UnLock;
      end;
    end;
    Result := jarray;
  except
    on E: Exception do
    begin
      TraceException('TCommandProcessor.GetNpcList', E);
      jarray.Free;
      Result := TJSONArray.Create;
    end;
  end;
  TraceLeave('TCommandProcessor.GetNpcList');
end;
function TCommandProcessor.GetPetList(Params: TJSONObject): TJSONValue;
var
  jarray: TJSONArray;
begin
  TraceEnter('TCommandProcessor.GetPetList');
  jarray := TJSONArray.Create;

  try
    if Assigned(FEngine) and Assigned(FEngine.PetList) then
    begin
      FEngine.Lock;
      try
        FillL2PetList(FEngine.PetList, jarray);
      finally
        FEngine.UnLock;
      end;
    end;
    Result := jarray;
  except
    on E: Exception do
    begin
      TraceException('TCommandProcessor.GetPetList', E);
      jarray.Free;
      Result := TJSONArray.Create;
    end;
  end;
  TraceLeave('TCommandProcessor.GetPetList');
end;
function TCommandProcessor.GetInventoryList(Params: TJSONObject): TJSONValue;
var
  jarray: TJSONArray;
begin
  TraceEnter('TCommandProcessor.GetInventoryList');
  jarray := TJSONArray.Create;

  try
    if Assigned(FEngine) and Assigned(FEngine.Inventory) then
    begin
      FEngine.Lock;
      try
        FillL2ItemList(FEngine.Inventory.User, jarray);
      finally
        FEngine.UnLock;
      end;
    end;
    Result := jarray;
  except
    on E: Exception do
    begin
      TraceException('TCommandProcessor.GetInventoryList', E);
      jarray.Free;
      Result := TJSONArray.Create;
    end;
  end;
  TraceLeave('TCommandProcessor.GetInventoryList');
end;
function TCommandProcessor.GetQuestInventoryList(Params: TJSONObject): TJSONValue;
var
  jarray: TJSONArray;
begin
  TraceEnter('TCommandProcessor.GetInventoryList');
  jarray := TJSONArray.Create;

  try
    if Assigned(FEngine) and Assigned(FEngine.Inventory) then
    begin
      FEngine.Lock;
      try
        FillL2ItemList(FEngine.Inventory.Quest, jarray);
      finally
        FEngine.UnLock;
      end;
    end;
    Result := jarray;
  except
    on E: Exception do
    begin
      TraceException('TCommandProcessor.GetInventoryList', E);
      jarray.Free;
      Result := TJSONArray.Create;
    end;
  end;
  TraceLeave('TCommandProcessor.GetInventoryList');
end;
function TCommandProcessor.GetSkillList(Params: TJSONObject): TJSONValue;
var jarray: TJSONArray;
begin
  jarray := TJSONArray.Create;
  try
    if Assigned(FEngine) and Assigned(FEngine.SkillList) then
    begin
      FEngine.Lock;
      try
        FillL2SkillList(FEngine.SkillList, jarray);
      finally
        FEngine.UnLock;
      end;
    end;
    Result := jarray;
  except
    on E: Exception do begin
      TraceException('GetSkillList', E);
      jarray.Free;
      Result := TJSONArray.Create;
    end;
  end;
end;
function TCommandProcessor.GetCharList(Params: TJSONObject): TJSONValue;
var
  jarray: TJSONArray;
begin
  jarray := TJSONArray.Create;
  try
    if Assigned(FEngine) and Assigned(FEngine.CharList) then
    begin
      FEngine.Lock;
      try
        FillL2CharList(FEngine.CharList, jarray);
      finally
        FEngine.UnLock;
      end;
    end;
    Result := jarray;
  except
    on E: Exception do
    begin
      TraceException('TCommandProcessor.GetCharList', E);
      jarray.Free;
      Result := TJSONArray.Create;
    end;
  end;
end;
function TCommandProcessor.GetDropList(Params: TJSONObject): TJSONValue;
var
  jarray: TJSONArray;
begin
  jarray := TJSONArray.Create;
  try
    if Assigned(FEngine) and Assigned(FEngine.DropList) then
    begin
      FEngine.Lock;
      try
        FillL2DropList(FEngine.DropList, jarray);
      finally
        FEngine.UnLock;
      end;
    end;
    Result := jarray;
  except
    on E: Exception do
    begin
      TraceException('TCommandProcessor.GetDropList', E);
      jarray.Free;
      Result := TJSONArray.Create;
    end;
  end;
end;

function TCommandProcessor.ProcessRpc(const JsonStr: string): string;
var
  Req, Resp, ErrObj: TJSONObject;
  Rid, Meth: TJSONValue;
  Handler: TCommandProc;
begin
  // Логируем входящую команду (обрезаем, если слишком длинная)
  if Length(JsonStr) > 200 then
    Trace('RPC Process: ' + Copy(JsonStr, 1, 200) + '...')
  else
    Trace('RPC Process: ' + JsonStr);

  Resp := TJSONObject.Create;
  try
    try
      Req := TJSONObject.ParseJSONValue(JsonStr) as TJSONObject;
      if not Assigned(Req) then
      begin
        TraceError('ProcessRpc', 'Invalid JSON received: ' + JsonStr);
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
          try
            Resp.AddPair('status', 'success');
            Resp.AddPair('result', Handler(Req.GetValue('params') as TJSONObject));
          except
            on E: Exception do
            begin
              TraceException('ProcessRpc execution error (' + Meth.Value + ')', E);
              // Если метод упал, возвращаем ошибку в JSON
              Resp.RemovePair('status'); // Удаляем success если был добавлен
              Resp.AddPair('status', 'error');
              ErrObj := TJSONObject.Create;
              ErrObj.AddPair('code', TJSONNumber.Create(500));
              ErrObj.AddPair('message', 'Internal Method Error: ' + E.Message);
              Resp.AddPair('error', ErrObj);
            end;
          end;
        end
        else
        begin
          TraceError('ProcessRpc', 'Method not found: ' + (Meth.Value));
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
        TraceException('ProcessRpc (JSON Parsing)', E);
        Resp.AddPair('status', 'error');
        ErrObj := TJSONObject.Create;
        ErrObj.AddPair('code', TJSONNumber.Create(500));
        ErrObj.AddPair('message', E.Message);
        Resp.AddPair('error', ErrObj);
      end;
    end;
    Result := Resp.ToJSON;
  finally
    Resp.Free;
  end;
end;

procedure TCommandProcessor.RequestStop;
begin
  FStopRequested := True;
end;

procedure TCommandProcessor.Run;
var
  Cmd: string;
  Resp: string;
  ReadSuccess: Boolean;
  WriteSuccess: Boolean;
  ReconnectNeeded: Boolean;
  ErrCode: DWORD;
begin
  TraceFmt('TCommandProcessor.Run: Loop started (ThreadID: %d)', [GetCurrentThreadId]);

  try
    while not FStopRequested do
    begin
      try
        ReadSuccess := FPipeManager.ReadFromPipe(FPipeManager.Pipes.Command, Cmd);

        ReconnectNeeded := False;

        if ReadSuccess then
        begin
          Resp := ProcessRpc(Cmd);

          WriteSuccess := FPipeManager.SendToPipe(
            FPipeManager.Pipes.Response, UTF8String(Resp + #13#10));

          if not WriteSuccess then
          begin
            TraceError('TCommandProcessor.Run', 'Failed to send response. Triggering full reconnect.');
            ReconnectNeeded := True;
          end;
        end
        else
        begin
          if not PeekNamedPipe(FPipeManager.Pipes.Command, nil, 0, nil, nil, nil) then
          begin
            ErrCode := GetLastError;
            if (ErrCode <> ERROR_NO_DATA) and
               (ErrCode <> ERROR_PIPE_LISTENING) then
              ReconnectNeeded := True;
          end;
        end;

        if ReconnectNeeded then
        begin
          FPipeManager.ReconnectPipe(FPipeManager.FPipes.Command, 'commands', True);
          FPipeManager.ReconnectPipe(FPipeManager.FPipes.Response, 'responses', False);
          FPipeManager.ReconnectPipe(FPipeManager.FPipes.Action, 'actions', False);
          FPipeManager.ReconnectPipe(FPipeManager.FPipes.Packet, 'packets', False);
          FPipeManager.ReconnectPipe(FPipeManager.FPipes.CliPacket, 'clipackets', False);
          Sleep(500);
        end;

      except
        on E: Exception do
        begin
          TraceException('TCommandProcessor.Run Loop', E);
          Sleep(1000);
        end;
      end;

      Sleep(COMMAND_CHECK_INTERVAL);
    end;
  except
    on E: Exception do
      TraceException('TCommandProcessor.Run Fatal', E);
  end;

  Trace('TCommandProcessor.Run: Loop finished.');
  SetEvent(FStoppedEvent);
end;

procedure TCommandProcessor.WaitForStop(TimeoutMS: Cardinal);
begin
  if FStoppedEvent <> INVALID_HANDLE_VALUE then
  begin
    if WaitForSingleObject(FStoppedEvent, TimeoutMS) = WAIT_TIMEOUT then
      TraceError('TCommandProcessor.WaitForStop', 'Run loop did not exit in time.');
  end;
end;

end.
