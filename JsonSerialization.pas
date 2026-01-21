unit JsonSerialization;

interface

uses
  System.JSON, SysUtils, PluginAPI, PluginConst;

procedure FillL2Object(Src: IL2Object; Dest: TJSONObject);
procedure FillL2Spawn(Src: IL2Spawn; Dest: TJSONObject);
procedure FillL2Live(Src: IL2Live; Dest: TJSONObject);
procedure FillL2Char(Src: IL2Char; Dest: TJSONObject);
procedure FillL2User(Src: IL2User; Dest: TJSONObject);

implementation

procedure FillL2Object(Src: IL2Object; Dest: TJSONObject);
begin
  if Src = nil then Exit;
  Dest.AddPair('name', TJSONString.Create(Src.Name));
  Dest.AddPair('id', TJSONNumber.Create(Src.ID));
  Dest.AddPair('oid', TJSONNumber.Create(Src.OID));
end;

procedure FillL2Spawn(Src: IL2Spawn; Dest: TJSONObject);
begin
  if Src = nil then Exit;
  FillL2Object(Src, Dest);
  Dest.AddPair('x', TJSONNumber.Create(Src.X));
  Dest.AddPair('y', TJSONNumber.Create(Src.Y));
  Dest.AddPair('z', TJSONNumber.Create(Src.Z));
  Dest.AddPair('spawn_time', TJSONNumber.Create(Src.SpawnTime));
end;

procedure FillL2Live(Src: IL2Live; Dest: TJSONObject);
begin
  if Src = nil then Exit;
  FillL2Spawn(Src, Dest);
  Dest.AddPair('hp', TJSONNumber.Create(Src.HP));
  Dest.AddPair('max_hp', TJSONNumber.Create(Src.MaxHP));
  Dest.AddPair('mp', TJSONNumber.Create(Src.MP));
  Dest.AddPair('max_mp', TJSONNumber.Create(Src.MaxMP));
  Dest.AddPair('is_dead', TJSONBool.Create(Src.Dead));
end;

procedure FillL2Char(Src: IL2Char; Dest: TJSONObject);
var
  LTarget: IL2Live;
begin
  if Src = nil then Exit;
  FillL2Live(Src, Dest);
  LTarget := Src.Target;
  if LTarget <> nil then
    Dest.AddPair('target_oid', TJSONNumber.Create(LTarget.OID))
  else
    Dest.AddPair('target_oid', TJSONNumber.Create(0));
end;

procedure FillL2User(Src: IL2User; Dest: TJSONObject);
begin
  if Src = nil then Exit;
  FillL2Char(Src, Dest);
  Dest.AddPair('is_sitting', TJSONBool.Create(Src.Sitting));
end;

end.
