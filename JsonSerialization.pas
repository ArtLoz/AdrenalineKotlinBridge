unit JsonSerialization;

interface

uses
  System.JSON, Windows, SysUtils, PluginAPI, PluginConst, Logger;

procedure FillL2Object(Src: IL2Object; Dest: TJSONObject);
procedure FillL2Spawn(Src: IL2Spawn; Dest: TJSONObject);
procedure FillL2Live(Src: IL2Live; Dest: TJSONObject; Depth: Integer = 0);
procedure FillL2Char(Src: IL2Char; Dest: TJSONObject);
procedure FillL2User(Src: IL2User; Dest: TJSONObject);
procedure FillL2Npc(Src: IL2Npc; Dest: TJSONObject);
procedure FillL2Pet(Src: IL2Pet; Dest: TJSONObject);
//Items
procedure FillL2Item(Src: IL2Item; Dest: TJSONObject);
procedure FillL2Drop(Src: IL2Drop; Dest: TJSONObject);
procedure FillL2ShopItem(Src: IL2ShopItem; Dest: TJSONObject);
procedure FillL2MailItem(Src: IL2MailItem; Dest: TJSONObject);
procedure FillL2AucItem(Src: IL2AucItem; Dest: TJSONObject);
//Buff
procedure FillL2Buff(Src: IL2Buff; Dest: TJSONObject);
procedure FillL2Skill(Src: IL2Skill; Dest: TJSONObject);
procedure FillLearnItem(Src: ILearnItem; Dest: TJSONObject);

//Utils
procedure FillL2BuffList(Src: IBuffList; Dest: TJSONArray);
procedure FillL2ItemList(Src: IL2List; Dest: TJSONArray);
procedure FillL2SpawnList(Src: ISpawnList; Dest: TJSONArray);
procedure FillL2CharList(Src: ICharList; Dest: TJSONArray);
procedure FillL2NpcList(Src: INpcList; Dest: TJSONArray);
procedure FillL2PetList(Src: IPetList; Dest: TJSONArray);
procedure FillL2DropList(Src: IDropList; Dest: TJSONArray);
procedure FillL2SkillList(Src: ISkillList; Dest: TJSONArray);
procedure FillLearnList(Src: ILearnList; Dest: TJSONArray);
procedure FillL2AuctionList(Src: IL2Auction; Dest: TJSONArray);
//party
procedure FillL2Party(Src: IParty; Dest: TJSONObject);
procedure FillL2Inventory(Src: IInventory; Dest: TJSONObject);

procedure FillL2ConfirmDlg(Src: IConfirmDlg; Dest: TJSONObject);
procedure FillL2ChatMessage(Src: IChatMessage; Dest: TJSONObject);
procedure FillL2Messages(Src: IMessages; Dest: TJSONObject; MsgType: TMessageType = mtAll);

procedure FillGpsPointFromStr(const RawData: WideString; Dest: TJSONObject);

implementation

procedure FillL2Object(Src: IL2Object; Dest: TJSONObject);
begin
  if Src = nil then begin Trace('[FillL2Object] Src is NIL'); Exit; end;
  try
    Trace('[FillL2Object] >> Name');
    Dest.AddPair('name', TJSONString.Create(Src.Name));
    Trace('[FillL2Object] >> ID');
    Dest.AddPair('id', TJSONNumber.Create(Src.ID));
    Trace('[FillL2Object] >> OID');
    Dest.AddPair('oid', TJSONNumber.Create(Src.OID));
    Trace('[FillL2Object] >> Valid');
    Dest.AddPair('valid', TJSONBool.Create(Src.Valid));
    Trace('[FillL2Object] >> L2Class');

    case Src.L2Class of
      lcError: Dest.AddPair('l2_class', TJSONString.Create('error'));
      lcDrop:  Dest.AddPair('l2_class', TJSONString.Create('drop'));
      lcNpc:   Dest.AddPair('l2_class', TJSONString.Create('npc'));
      lcPet:   Dest.AddPair('l2_class', TJSONString.Create('pet'));
      lcChar:  Dest.AddPair('l2_class', TJSONString.Create('char'));
      lcUser:  Dest.AddPair('l2_class', TJSONString.Create('user'));
      lcBuff:  Dest.AddPair('l2_class', TJSONString.Create('buff'));
      lcSkill: Dest.AddPair('l2_class', TJSONString.Create('skill'));
      lcItem:  Dest.AddPair('l2_class', TJSONString.Create('item'));
    else
      Dest.AddPair('l2_class', TJSONString.Create('unknown'));
    end;
    Trace('[FillL2Object] DONE');
  except
    on E: Exception do
      TraceException('FillL2Object', E);
  end;
end;

procedure FillL2Spawn(Src: IL2Spawn; Dest: TJSONObject);
begin
  if Src = nil then begin Trace('[FillL2Spawn] Src is NIL'); Exit; end;
  try
    Trace('[FillL2Spawn] >> FillL2Object');
    FillL2Object(Src, Dest);
    Trace('[FillL2Spawn] >> X');
    Dest.AddPair('x', TJSONNumber.Create(Src.X));
    Trace('[FillL2Spawn] >> Y');
    Dest.AddPair('y', TJSONNumber.Create(Src.Y));
    Trace('[FillL2Spawn] >> Z');
    Dest.AddPair('z', TJSONNumber.Create(Src.Z));
    Trace('[FillL2Spawn] >> SpawnTime');
    Dest.AddPair('spawn_time', TJSONNumber.Create(Src.SpawnTime));
    Trace('[FillL2Spawn] >> InZone');
    Dest.AddPair('in_zone', TJSONBool.Create(Src.InZone));
    Trace('[FillL2Spawn] DONE');
  except
    on E: Exception do
      TraceException('FillL2Spawn', E);
  end;
end;

procedure FillL2Live(Src: IL2Live; Dest: TJSONObject; Depth: Integer = 0);
var
  TargetObj, CastObj: TJSONObject;
  BuffsArr, AbnormalsArr, EquipsArr: TJSONArray;
begin
  if Src = nil then begin Trace('[FillL2Live] Src is NIL'); Exit; end;
  if not Src.Valid then begin Trace('[FillL2Live] Src is INVALID'); Exit; end;
  try
    Trace('[FillL2Live] >> FillL2Spawn (Depth=' + IntToStr(Depth) + ')');
    FillL2Spawn(Src, Dest);
    Trace('[FillL2Live] >> Title');
    Dest.AddPair('title', TJSONString.Create(Src.Title));
    Trace('[FillL2Live] >> Level');
    Dest.AddPair('level', TJSONNumber.Create(Src.Level));
    Trace('[FillL2Live] >> HP');
    Dest.AddPair('hp', TJSONNumber.Create(Src.HP));
    Trace('[FillL2Live] >> CurHP');
    Dest.AddPair('cur_hp', TJSONNumber.Create(Src.CurHP));
    Trace('[FillL2Live] >> MaxHP');
    Dest.AddPair('max_hp', TJSONNumber.Create(Src.MaxHP));
    Trace('[FillL2Live] >> MP');
    Dest.AddPair('mp', TJSONNumber.Create(Src.MP));
    Trace('[FillL2Live] >> CurMP');
    Dest.AddPair('cur_mp', TJSONNumber.Create(Src.CurMP));
    Trace('[FillL2Live] >> MaxMP');
    Dest.AddPair('max_mp', TJSONNumber.Create(Src.MaxMP));
    Trace('[FillL2Live] >> Load');
    Dest.AddPair('load', TJSONNumber.Create(Src.Load));
    Trace('[FillL2Live] >> EXP');
    Dest.AddPair('exp', TJSONNumber.Create(Src.EXP));
    Trace('[FillL2Live] >> EXP2');
    Dest.AddPair('exp2', TJSONNumber.Create(Src.EXP2));
    Trace('[FillL2Live] >> SP');
    Dest.AddPair('sp', TJSONNumber.Create(Src.SP));
    Trace('[FillL2Live] >> PK');
    Dest.AddPair('is_pk', TJSONBool.Create(Src.PK));
    Trace('[FillL2Live] >> PvP');
    Dest.AddPair('is_pvp', TJSONBool.Create(Src.PvP));
    Trace('[FillL2Live] >> Karma');
    Dest.AddPair('karma', TJSONNumber.Create(Src.Karma));
    Trace('[FillL2Live] >> Attackable');
    Dest.AddPair('attackable', TJSONBool.Create(Src.Attackable));
    Trace('[FillL2Live] >> Sweepable');
    Dest.AddPair('sweepable', TJSONBool.Create(Src.Sweepable));
    Trace('[FillL2Live] >> Running');
    Dest.AddPair('is_running', TJSONBool.Create(Src.Running));
    Trace('[FillL2Live] >> InCombat');
    Dest.AddPair('in_combat', TJSONBool.Create(Src.InCombat));
    Trace('[FillL2Live] >> Sitting');
    Dest.AddPair('is_sitting', TJSONBool.Create(Src.Sitting));
    Trace('[FillL2Live] >> Dead');
    Dest.AddPair('is_dead', TJSONBool.Create(Src.Dead));
    Trace('[FillL2Live] >> Invisible');
    Dest.AddPair('is_invisible', TJSONBool.Create(Src.Invisible));
    Trace('[FillL2Live] >> Speed');
    Dest.AddPair('speed', TJSONNumber.Create(Src.Speed));
    Trace('[FillL2Live] >> ToX');
    Dest.AddPair('to_x', TJSONNumber.Create(Src.ToX));
    Trace('[FillL2Live] >> ToY');
    Dest.AddPair('to_y', TJSONNumber.Create(Src.ToY));
    Trace('[FillL2Live] >> ToZ');
    Dest.AddPair('to_z', TJSONNumber.Create(Src.ToZ));
    Trace('[FillL2Live] >> Clan');
    Dest.AddPair('clan', TJSONString.Create(Src.Clan));
    Trace('[FillL2Live] >> ClanID');
    Dest.AddPair('clan_id', TJSONNumber.Create(Src.ClanID));
    Trace('[FillL2Live] >> AtkOID');
    Dest.AddPair('atk_oid', TJSONNumber.Create(Src.AtkOID));
    Trace('[FillL2Live] >> CastSpd');
    Dest.AddPair('cast_spd', TJSONNumber.Create(Src.CastSpd));
    Trace('[FillL2Live] >> AtkSpd');
    Dest.AddPair('atk_spd', TJSONNumber.Create(Src.AtkSpd));

    Trace('[FillL2Live] >> Target check');
    if (Depth < 1) and (Src.Target <> nil) and (Src.Target.Valid) then
    begin
      Trace('[FillL2Live] >> Target FOUND, filling...');
      TargetObj := TJSONObject.Create;
      FillL2Live(Src.Target, TargetObj, Depth + 1);
      Dest.AddPair('target', TargetObj);
      Trace('[FillL2Live] >> Target DONE');
    end
    else
      Trace('[FillL2Live] >> Target: none or depth limit');

    Trace('[FillL2Live] >> Cast check');
    if Src.Cast <> nil then
    begin
      Trace('[FillL2Live] >> Cast FOUND, filling...');
      CastObj := TJSONObject.Create;
      FillL2Buff(Src.Cast, CastObj);
      Dest.AddPair('cast_info', CastObj);
      Trace('[FillL2Live] >> Cast DONE');
    end;

    Trace('[FillL2Live] >> Buffs check');
    if Src.Buffs <> nil then
    begin
      Trace('[FillL2Live] >> Buffs FOUND, filling...');
      BuffsArr := TJSONArray.Create;
      FillL2BuffList(Src.Buffs, BuffsArr);
      Dest.AddPair('buffs', BuffsArr);
      Trace('[FillL2Live] >> Buffs DONE');
    end;

    Trace('[FillL2Live] >> Abnormals check');
    if Src.Abnormals <> nil then
    begin
      Trace('[FillL2Live] >> Abnormals FOUND, filling...');
      AbnormalsArr := TJSONArray.Create;
      FillL2BuffList(Src.Abnormals, AbnormalsArr);
      Dest.AddPair('abnormals', AbnormalsArr);
      Trace('[FillL2Live] >> Abnormals DONE');
    end;

    Trace('[FillL2Live] >> Equips check');
    if ((Src.L2Class = lcUser) or (Src.L2Class = lcChar)) and (Src.Equips <> nil) then
    begin
      Trace('[FillL2Live] >> Equips FOUND, filling...');
      EquipsArr := TJSONArray.Create;
      FillL2ItemList(Src.Equips, EquipsArr);
      Dest.AddPair('equips', EquipsArr);
      Trace('[FillL2Live] >> Equips DONE');
    end;

    Trace('[FillL2Live] DONE (Depth=' + IntToStr(Depth) + ')');
  except
    on E: Exception do
      TraceException('FillL2Live (Depth=' + IntToStr(Depth) + ')', E);
  end;
end;

procedure FillL2Npc(Src: IL2Npc; Dest: TJSONObject);
var
  Owner: IL2Live;
  OwnerObj: TJSONObject;
begin
  if (Src = nil) or (not Src.Valid) then Exit;
  try
    FillL2Live(Src, Dest);

    Dest.AddPair('is_pet', TJSONBool.Create(Src.IsPet));
    Dest.AddPair('pet_type', TJSONNumber.Create(Src.PetType));
    Dest.AddPair('npc_type', TJSONNumber.Create(Src.NpcType));
    Dest.AddPair('npc_count', TJSONNumber.Create(Src.NpcCount));
    Owner := Src.Owner;
    if (Owner <> nil) and Owner.Valid then
    begin
      OwnerObj := TJSONObject.Create;
      FillL2Live(Owner, OwnerObj);
      Dest.AddPair('owner', OwnerObj);
    end;
  except
    on E: Exception do
      TraceException('FillL2Npc', E);
  end;
end;

procedure FillL2Pet(Src: IL2Pet; Dest: TJSONObject);
begin
  if (Src = nil) or (not Src.Valid) then Exit;
  try
    FillL2Npc(Src, Dest);
    Dest.AddPair('fed', TJSONNumber.Create(Src.Fed));
  except
    on E: Exception do
      TraceException('FillL2Pet', E);
  end;
end;

procedure FillL2Char(Src: IL2Char; Dest: TJSONObject);
var
  RaceStr: string;
begin
  if Src = nil then begin Trace('[FillL2Char] Src is NIL'); Exit; end;
  if not Src.Valid then begin Trace('[FillL2Char] Src is INVALID'); Exit; end;
  try
    Trace('[FillL2Char] >> FillL2Live');
    FillL2Live(Src, Dest);
    Trace('[FillL2Char] >> Race');
    case Cardinal(Src.Race) of
      0: RaceStr := 'human';
      1: RaceStr := 'elf';
      2: RaceStr := 'dark_elf';
      3: RaceStr := 'orc';
      4: RaceStr := 'dwarf';
      5: RaceStr := 'kamael';
      6: RaceStr := 'erthea';
    else
      RaceStr := 'unknown';
    end;
    Trace('[FillL2Char] >> CP');
    Dest.AddPair('cp', TJSONNumber.Create(Src.CP));
    Trace('[FillL2Char] >> CurCP');
    Dest.AddPair('cur_cp', TJSONNumber.Create(Src.CurCP));
    Trace('[FillL2Char] >> MaxCP');
    Dest.AddPair('max_cp', TJSONNumber.Create(Src.MaxCP));
    Trace('[FillL2Char] >> Sex');
    Dest.AddPair('sex', TJSONNumber.Create(Src.Sex));
    Dest.AddPair('race', TJSONString.Create(RaceStr));
    Trace('[FillL2Char] >> Hero');
    Dest.AddPair('is_hero', TJSONBool.Create(Src.Hero));
    Trace('[FillL2Char] >> Noble');
    Dest.AddPair('is_noble', TJSONBool.Create(Src.Noble));
    Trace('[FillL2Char] >> Premium');
    Dest.AddPair('premium', TJSONBool.Create(Src.Premium));
    Trace('[FillL2Char] >> ClassID');
    Dest.AddPair('class_id', TJSONNumber.Create(Src.ClassID));
    Trace('[FillL2Char] >> MainClass');
    Dest.AddPair('main_class_id', TJSONNumber.Create(Src.MainClass));
    Trace('[FillL2Char] >> ClassName');
    Dest.AddPair('class_name', TJSONString.Create(Src.ClassName));
    Trace('[FillL2Char] >> ClassName2');
    Dest.AddPair('class_name_alt', TJSONString.Create(Src.ClassName2));
    Trace('[FillL2Char] >> ClassPriority');
    Dest.AddPair('class_priority', TJSONNumber.Create(Src.ClassPriority));
    Trace('[FillL2Char] >> MountType');
    Dest.AddPair('mount_type', TJSONNumber.Create(Src.MountType));
    Trace('[FillL2Char] >> StoreType');
    Dest.AddPair('store_type', TJSONNumber.Create(Src.StoreType));
    Trace('[FillL2Char] >> CubicCount');
    Dest.AddPair('cubic_count', TJSONNumber.Create(Src.CubicCount));
    Trace('[FillL2Char] >> Recom');
    Dest.AddPair('recom', TJSONNumber.Create(Src.Recom));
    Trace('[FillL2Char] >> ClanName');
    Dest.AddPair('clan_name', TJSONString.Create(Src.ClanName));
    Trace('[FillL2Char] >> AllyName');
    Dest.AddPair('ally_name', TJSONString.Create(Src.AllyName));
    Trace('[FillL2Char] DONE');
  except
    on E: Exception do
      TraceException('FillL2Char', E);
  end;
end;

procedure FillL2User(Src: IL2User; Dest: TJSONObject);
begin
  if (Src = nil) then
  begin
    TraceError('FillL2User', 'Source object is NIL');
    Exit;
  end;

  if not Src.Valid then
  begin
    TraceFmt('FillL2User: Source object is INVALID (OID: %d)', [Src.OID]);
    Exit;
  end;

  try
    Trace('[FillL2User] >> FillL2Char');
    FillL2Char(Src, Dest);
    Trace('[FillL2User] >> CanCryst');
    Dest.AddPair('can_cryst', TJSONBool.Create(Src.CanCryst));
    Trace('[FillL2User] >> Charges');
    Dest.AddPair('charges', TJSONNumber.Create(Src.Charges));
    Trace('[FillL2User] >> Souls');
    Dest.AddPair('souls', TJSONNumber.Create(Src.Souls));
    Trace('[FillL2User] >> WeightPenalty');
    Dest.AddPair('weight_penalty', TJSONNumber.Create(Src.WeightPenalty));
    Trace('[FillL2User] >> WeapPenalty');
    Dest.AddPair('weapon_penalty', TJSONNumber.Create(Src.WeapPenalty));
    Trace('[FillL2User] >> ArmorPenalty');
    Dest.AddPair('armor_penalty', TJSONNumber.Create(Src.ArmorPenalty));
    Trace('[FillL2User] >> DeathPenalty');
    Dest.AddPair('death_penalty', TJSONNumber.Create(Src.DeathPenalty));
    Trace('[FillL2User] >> STR');
    Dest.AddPair('stat_str', TJSONNumber.Create(Src.STR));
    Trace('[FillL2User] >> DEX');
    Dest.AddPair('stat_dex', TJSONNumber.Create(Src.DEX));
    Trace('[FillL2User] >> CON');
    Dest.AddPair('stat_con', TJSONNumber.Create(Src.CON));
    Trace('[FillL2User] >> INT');
    Dest.AddPair('stat_int', TJSONNumber.Create(Src.INT));
    Trace('[FillL2User] >> WIT');
    Dest.AddPair('stat_wit', TJSONNumber.Create(Src.WIT));
    Trace('[FillL2User] >> MEN');
    Dest.AddPair('stat_men', TJSONNumber.Create(Src.MEN));
    Trace('[FillL2User] >> PAtk');
    Dest.AddPair('p_atk', TJSONNumber.Create(Src.PAtk));
    Trace('[FillL2User] >> PASpd');
    Dest.AddPair('p_atk_spd', TJSONNumber.Create(Src.PASpd));
    Trace('[FillL2User] >> PDef');
    Dest.AddPair('p_def', TJSONNumber.Create(Src.PDef));
    Trace('[FillL2User] >> Accuracy');
    Dest.AddPair('p_accuracy', TJSONNumber.Create(Src.Accuracy));
    Trace('[FillL2User] >> Evasion');
    Dest.AddPair('p_evasion', TJSONNumber.Create(Src.Evasion));
    Trace('[FillL2User] >> CritHit');
    Dest.AddPair('p_crit', TJSONNumber.Create(Src.CritHit));
    Trace('[FillL2User] >> MAtk');
    Dest.AddPair('m_atk', TJSONNumber.Create(Src.MAtk));
    Trace('[FillL2User] >> MDef');
    Dest.AddPair('m_def', TJSONNumber.Create(Src.MDef));
    Trace('[FillL2User] >> MAccuracy');
    Dest.AddPair('m_accuracy', TJSONNumber.Create(Src.MAccuracy));
    Trace('[FillL2User] >> MEvasion');
    Dest.AddPair('m_evasion', TJSONNumber.Create(Src.MEvasioon));
    Trace('[FillL2User] >> MCritical');
    Dest.AddPair('m_crit', TJSONNumber.Create(Src.MCritical));
    Trace('[FillL2User] DONE');
  except
    on E: Exception do
      TraceException('FillL2User', E);
  end;
end;

//Items
procedure FillL2Item(Src: IL2Item; Dest: TJSONObject);
begin
  if Src = nil then begin Trace('[FillL2Item] Src is NIL'); Exit; end;
  if not Src.Valid then begin Trace('[FillL2Item] Src is INVALID'); Exit; end;
  try
    Trace('[FillL2Item] >> FillL2Object');
    FillL2Object(Src, Dest);
    Trace('[FillL2Item] >> Slot');
    Dest.AddPair('slot', TJSONNumber.Create(Src.Slot));
    Trace('[FillL2Item] >> Count');
    Dest.AddPair('count', TJSONNumber.Create(Src.Count));
    Trace('[FillL2Item] >> Equipped');
    Dest.AddPair('equipped', TJSONBool.Create(Src.Equipped));
    Trace('[FillL2Item] >> ItemType');
    Dest.AddPair('item_type', TJSONNumber.Create(Src.ItemType));
    Trace('[FillL2Item] >> Grade');
    Dest.AddPair('grade', TJSONNumber.Create(Src.Grade));
    Trace('[FillL2Item] >> GradeName');
    Dest.AddPair('grade_name', TJSONString.Create(Src.GradeName));
    Trace('[FillL2Item] >> EnchantLevel');
    Dest.AddPair('enchant', TJSONNumber.Create(Src.EnchantLevel));
    Trace('[FillL2Item] >> BodyPart');
    Dest.AddPair('body_part', TJSONNumber.Create(Src.BodyPart));
    Trace('[FillL2Item] >> AugmentID');
    Dest.AddPair('augment_id', TJSONNumber.Create(Src.AugmentID));
    Trace('[FillL2Item] >> AugmentID2');
    Dest.AddPair('augment_id2', TJSONNumber.Create(Src.AugmentID2));
    Trace('[FillL2Item] >> AtkElem');
    Dest.AddPair('atk_elem', TJSONNumber.Create(Src.AtkElem));
    Trace('[FillL2Item] >> ElemPower');
    Dest.AddPair('elem_power', TJSONNumber.Create(Src.ElemPower));
    Trace('[FillL2Item] >> WaterPower');
    Dest.AddPair('p_water', TJSONNumber.Create(Src.WaterPower));
    Trace('[FillL2Item] >> FirePower');
    Dest.AddPair('p_fire', TJSONNumber.Create(Src.FirePower));
    Trace('[FillL2Item] >> EartPower');
    Dest.AddPair('p_earth', TJSONNumber.Create(Src.EartPower));
    Trace('[FillL2Item] >> WindPower');
    Dest.AddPair('p_wind', TJSONNumber.Create(Src.WindPower));
    Trace('[FillL2Item] >> UnholyPower');
    Dest.AddPair('p_unholy', TJSONNumber.Create(Src.UnholyPower));
    Trace('[FillL2Item] >> HolyPower');
    Dest.AddPair('p_holy', TJSONNumber.Create(Src.HolyPower));
    Trace('[FillL2Item] DONE');
  except
    on E: Exception do
      TraceException('FillL2Item', E);
  end;
end;

procedure FillL2Drop(Src: IL2Drop; Dest: TJSONObject);
begin
  if (Src = nil) or (not Src.Valid) then Exit;
  try
    FillL2Spawn(Src, Dest);
    Dest.AddPair('count', TJSONNumber.Create(Src.Count));
    Dest.AddPair('owner_oid', TJSONNumber.Create(Src.OwnerOID));
    Dest.AddPair('stackable', TJSONBool.Create(Src.Stackable));
    Dest.AddPair('is_my', TJSONBool.Create(Src.IsMy));
  except
    on E: Exception do
      TraceException('FillL2Drop', E);
  end;
end;

procedure FillL2ShopItem(Src: IL2ShopItem; Dest: TJSONObject);
begin
  if (Src = nil) or (not Src.Valid) then Exit;
  try
    FillL2Item(Src, Dest);
    Dest.AddPair('price', TJSONNumber.Create(Src.Price));
  except
    on E: Exception do
      TraceException('FillL2ShopItem', E);
  end;
end;

procedure FillL2MailItem(Src: IL2MailItem; Dest: TJSONObject);
begin
  if (Src = nil) or (not Src.Valid) then Exit;
  try
    FillL2Object(Src, Dest);

    Dest.AddPair('is_sent', TJSONBool.Create(Src.IsSent));
    Dest.AddPair('mail_type', TJSONNumber.Create(Src.MailType));
    Dest.AddPair('title', TJSONString.Create(Src.Title));
    Dest.AddPair('sender', TJSONString.Create(Src.Sender));
    Dest.AddPair('is_locked', TJSONBool.Create(Src.IsLocked));
    Dest.AddPair('expiration_time', TJSONNumber.Create(Src.Expirate));
    Dest.AddPair('is_unread', TJSONBool.Create(Src.IsUnread));
    Dest.AddPair('with_items', TJSONBool.Create(Src.WithItems));
    Dest.AddPair('no_recv_items', TJSONBool.Create(Src.NoRecvItems));
    Dest.AddPair('is_news', TJSONBool.Create(Src.IsNews));
    Dest.AddPair('actual_time', TJSONNumber.Create(Src.ActualTime));
  except
    on E: Exception do
      TraceException('FillL2MailItem', E);
  end;
end;

procedure FillL2AucItem(Src: IL2AucItem; Dest: TJSONObject);
begin
  if (Src = nil) or (not Src.Valid) then Exit;
  try
    FillL2Item(Src, Dest);

    Dest.AddPair('lot_type', TJSONNumber.Create(Src.LotType));
    Dest.AddPair('seller', TJSONString.Create(Src.Seller));
    Dest.AddPair('price', TJSONNumber.Create(Src.Price));
    Dest.AddPair('days', TJSONNumber.Create(Src.Days));
    Dest.AddPair('end_time', TJSONNumber.Create(Src.EndTime));
  except
    on E: Exception do
      TraceException('FillL2AucItem', E);
  end;
end;

//buff
procedure FillL2Buff(Src: IL2Buff; Dest: TJSONObject);
begin
  if Src = nil then Exit;
  try
    FillL2Object(Src, Dest);

    Dest.AddPair('level', TJSONNumber.Create(Src.Level));
    Dest.AddPair('level2', TJSONNumber.Create(Src.Level2));
    Dest.AddPair('start_time', TJSONNumber.Create(Src.StartTime));
    Dest.AddPair('end_time', TJSONNumber.Create(Src.EndTime));
    Dest.AddPair('reuse_time', TJSONNumber.Create(Src.ReuseTime));
  except
    on E: Exception do
      TraceException('FillL2Buff', E);
  end;
end;

procedure FillL2Skill(Src: IL2Skill; Dest: TJSONObject);
begin
  if (Src = nil) or (not Src.Valid) then Exit;
  try
    FillL2Buff(Src, Dest);
    Dest.AddPair('is_passive', TJSONBool.Create(Src.Passive));
    Dest.AddPair('is_disabled', TJSONBool.Create(Src.Disabled));
    Dest.AddPair('is_enchanted', TJSONBool.Create(Src.Enchanted));
    Dest.AddPair('range', TJSONNumber.Create(Src.Range));
    Dest.AddPair('is_aura', TJSONBool.Create(Src.IsAura));
  except
    on E: Exception do
      TraceException('FillL2Skill', E);
  end;
end;

procedure FillLearnItem(Src: ILearnItem; Dest: TJSONObject);
begin
  if (Src = nil) or (not Src.Valid) then Exit;
  try
    FillL2Skill(Src, Dest);
    Dest.AddPair('need_level', TJSONNumber.Create(Src.NeedLevel));
    Dest.AddPair('max_level', TJSONNumber.Create(Src.MaxLevel));
    Dest.AddPair('sp_cost', TJSONNumber.Create(Src.SpCost));
    Dest.AddPair('requirements', TJSONNumber.Create(Src.Requirements));
    Dest.AddPair('group', TJSONNumber.Create(Src.Group));
  except
    on E: Exception do
      TraceException('FillLearnItem', E);
  end;
end;

procedure FillL2Party(Src: IParty; Dest: TJSONObject);
var
  CharsArr, PetsArr: TJSONArray;
  LeaderObj: TJSONObject;
begin
  if (Src = nil) or (Dest = nil) then Exit;
  try
    Dest.AddPair('leader_oid', TJSONNumber.Create(Src.LeaderOID));
    Dest.AddPair('loot_type', TJSONNumber.Create(Ord(Src.LootType)));

    Dest.AddPair('is_ask_join', TJSONBool.Create(Src.IsAskJoin));
    Dest.AddPair('ask_join_name', TJSONString.Create(Src.AskJoinName));
    Dest.AddPair('ask_join_time', TJSONNumber.Create(Src.AskJoinTime));

    if (Src.Leader <> nil) and Src.Leader.Valid then
    begin
      LeaderObj := TJSONObject.Create;
      FillL2Char(Src.Leader, LeaderObj);
      Dest.AddPair('leader', LeaderObj);
    end;

    CharsArr := TJSONArray.Create;
    FillL2CharList(Src.Chars, CharsArr);
    Dest.AddPair('members', CharsArr);

    PetsArr := TJSONArray.Create;
    FillL2NpcList(Src.Pets, PetsArr);
    Dest.AddPair('pets', PetsArr);
  except
    on E: Exception do
      TraceException('FillL2Party', E);
  end;
end;

procedure FillL2Inventory(Src: IInventory; Dest: TJSONObject);
var
  UserArr, PetArr, QuestArr: TJSONArray;
begin
  if (Src = nil) or (Dest = nil) then Exit;
  try
    UserArr := TJSONArray.Create;
    FillL2ItemList(Src.User, UserArr);
    Dest.AddPair('user', UserArr);

    PetArr := TJSONArray.Create;
    FillL2ItemList(Src.Pet, PetArr);
    Dest.AddPair('pet', PetArr);

    QuestArr := TJSONArray.Create;
    FillL2ItemList(Src.Quest, QuestArr);
    Dest.AddPair('quest', QuestArr);
  except
    on E: Exception do
      TraceException('FillL2Inventory', E);
  end;
end;

procedure FillL2ConfirmDlg(Src: IConfirmDlg; Dest: TJSONObject);
begin
  if (Src = nil) or (not Src.Valid) then Exit;
  try
    Dest.AddPair('msg_id', TJSONNumber.Create(Src.MsgID));
    Dest.AddPair('req_id', TJSONNumber.Create(Src.ReqID));
    Dest.AddPair('sender', TJSONString.Create(Src.Sender));
    Dest.AddPair('end_time', TJSONNumber.Create(Src.EndTime));
  except
    on E: Exception do
      TraceException('FillL2ConfirmDlg', E);
  end;
end;

procedure FillL2ChatMessage(Src: IChatMessage; Dest: TJSONObject);
begin
  if (Src = nil) then Exit;
  try
    Dest.AddPair('oid', TJSONNumber.Create(Src.OID));
    Dest.AddPair('time', TJSONNumber.Create(Src.Time));
    Dest.AddPair('sender', TJSONString.Create(Src.Sender));
    Dest.AddPair('text', TJSONString.Create(Src.Text));
    Dest.AddPair('chat_type', TJSONNumber.Create(Ord(Src.ChatType)));
    Dest.AddPair('unread', TJSONBool.Create(Src.UnRead));
  except
    on E: Exception do
      TraceException('FillL2ChatMessage', E);
  end;
end;

procedure FillL2Messages(Src: IMessages; Dest: TJSONObject; MsgType: TMessageType = mtAll);
var
  i: Integer;
  MsgArr: TJSONArray;
  MsgObj: TJSONObject;
begin
  if (Src = nil) or (Dest = nil) then Exit;
  try
    Dest.AddPair('max_count', TJSONNumber.Create(Src.MaxCount));

    MsgArr := TJSONArray.Create;
    for i := 0 to Src.Count(MsgType) - 1 do
    begin
      if Src.Items[i, MsgType] <> nil then
      begin
        MsgObj := TJSONObject.Create;
        FillL2ChatMessage(Src.Items[i, MsgType], MsgObj);
        MsgArr.AddElement(MsgObj);
      end;
    end;

    Dest.AddPair('items', MsgArr);
  except
    on E: Exception do
      TraceException('FillL2Messages', E);
  end;
end;

//Utils
procedure FillL2BuffList(Src: IBuffList; Dest: TJSONArray);
var
  I: Integer;
  BuffObj: TJSONObject;
  Item: IL2Buff;
begin
  if (Src = nil) or (Dest = nil) then Exit;
  try
    for I := 0 to Src.Count - 1 do
    begin
      Item := Src.Items[I];
      if Item <> nil then
      begin
        BuffObj := TJSONObject.Create;
        FillL2Buff(Item, BuffObj);
        Dest.AddElement(BuffObj);
      end;
    end;
  except
    on E: Exception do
      TraceException('FillL2BuffList', E);
  end;
end;

procedure FillL2ItemList(Src: IL2List; Dest: TJSONArray);
var
  I: Integer;
  ItemObj: TJSONObject;
  Item: IL2Item;
begin
  if (Src = nil) or (Dest = nil) then Exit;
  try
    for I := 0 to Src.Count - 1 do
    begin
      Item := IL2Item(Src.Items[I]);
      if (Item <> nil) and Item.Valid then
      begin
        ItemObj := TJSONObject.Create;
        FillL2Item(Item, ItemObj);
        Dest.AddElement(ItemObj);
      end;
    end;
  except
    on E: Exception do
      TraceException('FillL2ItemList', E);
  end;
end;

procedure FillL2SpawnList(Src: ISpawnList; Dest: TJSONArray);
var
  i: Integer;
  SpawnObj: TJSONObject;
begin
  if (Src = nil) or (Dest = nil) then Exit;
  try
    for i := 0 to Src.Count - 1 do
    begin
      if (Src.Items[i] <> nil) and Src.Items[i].Valid then
      begin
        SpawnObj := TJSONObject.Create;
        FillL2Spawn(Src.Items[i], SpawnObj);
        Dest.AddElement(SpawnObj);
      end;
    end;
  except
    on E: Exception do
      TraceException('FillL2SpawnList', E);
  end;
end;

procedure FillL2CharList(Src: ICharList; Dest: TJSONArray);
var i: Integer; Obj: TJSONObject;
begin
  if (Src = nil) or (Dest = nil) then Exit;
  try
    for i := 0 to Src.Count - 1 do begin
      if (Src[i] <> nil) and Src[i].Valid then begin
        Obj := TJSONObject.Create;
        FillL2Char(Src[i], Obj);
        Dest.AddElement(Obj);
      end;
    end;
  except
    on E: Exception do
      TraceException('FillL2CharList', E);
  end;
end;

procedure FillL2NpcList(Src: INpcList; Dest: TJSONArray);
var i: Integer; Obj: TJSONObject;
begin
  if (Src = nil) or (Dest = nil) then Exit;
  try
    for i := 0 to Src.Count - 1 do begin
      if (Src[i] <> nil) and Src[i].Valid then begin
        Obj := TJSONObject.Create;
        FillL2Npc(Src[i], Obj);
        Dest.AddElement(Obj);
      end;
    end;
  except
    on E: Exception do
      TraceException('FillL2NpcList', E);
  end;
end;

procedure FillL2PetList(Src: IPetList; Dest: TJSONArray);
var i: Integer; Obj: TJSONObject;
begin
  if (Src = nil) or (Dest = nil) then Exit;
  try
    for i := 0 to Src.Count - 1 do begin
      if (Src[i] <> nil) and Src[i].Valid then begin
        Obj := TJSONObject.Create;
        FillL2Pet(Src[i], Obj);
        Dest.AddElement(Obj);
      end;
    end;
  except
    on E: Exception do
      TraceException('FillL2PetList', E);
  end;
end;

procedure FillL2DropList(Src: IDropList; Dest: TJSONArray);
var i: Integer; Obj: TJSONObject;
begin
  if (Src = nil) or (Dest = nil) then Exit;
  try
    for i := 0 to Src.Count - 1 do begin
      if (Src[i] <> nil) and Src[i].Valid then begin
        Obj := TJSONObject.Create;
        FillL2Drop(Src[i], Obj);
        Dest.AddElement(Obj);
      end;
    end;
  except
    on E: Exception do
      TraceException('FillL2DropList', E);
  end;
end;

procedure FillL2SkillList(Src: ISkillList; Dest: TJSONArray);
var i: Integer; Obj: TJSONObject;
begin
  if (Src = nil) or (Dest = nil) then Exit;
  try
    for i := 0 to Src.Count - 1 do begin
      if (Src[i] <> nil) and Src[i].Valid then begin
        Obj := TJSONObject.Create;
        FillL2Skill(Src[i], Obj);
        Dest.AddElement(Obj);
      end;
    end;
  except
    on E: Exception do
      TraceException('FillL2SkillList', E);
  end;
end;

procedure FillLearnList(Src: ILearnList; Dest: TJSONArray);
var i: Integer; Obj: TJSONObject;
begin
  if (Src = nil) or (Dest = nil) then Exit;
  try
    for i := 0 to Src.Count - 1 do begin
      if (Src[i] <> nil) and Src[i].Valid then begin
        Obj := TJSONObject.Create;
        FillLearnItem(Src[i], Obj);
        Dest.AddElement(Obj);
      end;
    end;
  except
    on E: Exception do
      TraceException('FillLearnList', E);
  end;
end;

procedure FillL2AuctionList(Src: IL2Auction; Dest: TJSONArray);
var
  i: Integer;
  AucItemObj: TJSONObject;
begin
  if (Src = nil) or (Dest = nil) then Exit;
  try
    for i := 0 to Src.Count - 1 do
    begin
      if (Src.Items[i] <> nil) and Src.Items[i].Valid then
      begin
        AucItemObj := TJSONObject.Create;
        FillL2AucItem(Src.Items[i], AucItemObj);
        Dest.AddElement(AucItemObj);
      end;
    end;
  except
    on E: Exception do
      TraceException('FillL2AuctionList', E);
  end;
end;

procedure FillGpsPointFromStr(const RawData: WideString; Dest: TJSONObject);
var
  Parts: TArray<string>;
begin
  if Dest = nil then Exit;

  if RawData = '' then Exit;

  try
    Parts := string(RawData).Split([';']);

    if Length(Parts) < 5 then Exit;

    Dest.AddPair('name', TJSONString.Create(Parts[0]));
    Dest.AddPair('x',    TJSONNumber.Create(Parts[1]));
    Dest.AddPair('y',    TJSONNumber.Create(Parts[2]));
    Dest.AddPair('z',    TJSONNumber.Create(Parts[3]));
    Dest.AddPair('id',   TJSONNumber.Create(Parts[4]));

  except
    on E: Exception do
    begin
      TraceException('FillGpsPointFromStr', E);
    end;
  end;
end;

end.
