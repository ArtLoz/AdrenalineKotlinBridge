unit EventForwarder;

interface

uses
  Windows, SysUtils, Types, PluginAPI, PluginConst, PipeManager, Logger;

type
  TEventForwarder = class
  private
    FPipeManager: TPipeManager;

    function MemToHex(const Data; Size: Integer): AnsiString;

  public
    constructor Create(APipeManager: TPipeManager);

    procedure ForwardAction(Action: TL2Action; P1, P2: Pointer);
    procedure ForwardPacket(ID1, ID2: Cardinal; Data: Pointer; Size: Word);
    procedure ForwardCliPacket(ID1, ID2: Cardinal; Data: Pointer; Size: Word);
  end;

implementation

constructor TEventForwarder.Create(APipeManager: TPipeManager);
begin
  TraceEnter('TEventForwarder.Create');
  try
    inherited Create;
    FPipeManager := APipeManager;
  except
    on E: Exception do
      TraceException('TEventForwarder.Create', E);
  end;
  TraceLeave('TEventForwarder.Create');
end;

function TEventForwarder.MemToHex(const Data; Size: Integer): AnsiString;
const
  HexChars: array[0..15] of AnsiChar = '0123456789ABCDEF';
var
  I: Integer;
  P: PByte;
begin
  // Здесь нет try..except ради скорости, проверки делаются вызывающим кодом
  SetLength(Result, Size * 2);
  P := @Data;
  for I := 0 to Size - 1 do
  begin
    Result[I * 2 + 1] := HexChars[P^ shr 4];
    Result[I * 2 + 2] := HexChars[P^ and $0F];
    Inc(P);
  end;
end;

procedure TEventForwarder.ForwardAction(Action: TL2Action; P1, P2: Pointer);
var
  Data: AnsiString;
begin
  try
    Data := AnsiString(
      IntToStr(Ord(Action)) + '|' +
      IntToStr(Integer(P1)) + '|' +
      IntToStr(Integer(P2)) + #13#10
    );

    // SendToPipe сам обрабатывает ошибки записи, здесь ловить False не обязательно,
    // если не нужно специфической логики
    FPipeManager.SendToPipe(FPipeManager.Pipes.Action, Data);
  except
    on E: Exception do
      TraceException('ForwardAction', E);
  end;
end;

procedure TEventForwarder.ForwardPacket(ID1, ID2: Cardinal; Data: Pointer; Size: Word);
var
  PacketData: AnsiString;
begin
  try
    // Защита от краша при nil указателе
    if (Data = nil) and (Size > 0) then
    begin
      // Это не критично, но лучше знать
      // TraceError('ForwardPacket', 'Data is nil but Size > 0');
      Exit;
    end;

    if ID2 > 0 then
      PacketData := MemToHex(ID1, 1) + MemToHex(ID2, 2) + '|' + MemToHex(Data^, Size)
    else
      PacketData := MemToHex(ID1, 1) + '|' + MemToHex(Data^, Size);

    FPipeManager.SendToPipe(FPipeManager.Pipes.Packet, PacketData + #13#10);
  except
    on E: Exception do
      TraceException('ForwardPacket', E);
  end;
end;

procedure TEventForwarder.ForwardCliPacket(ID1, ID2: Cardinal; Data: Pointer; Size: Word);
var
  PacketData: AnsiString;
begin
  try
    // Защита от краша при nil указателе
    if (Data = nil) and (Size > 0) then
      Exit;

    if ID2 > 0 then
      PacketData := MemToHex(ID1, 1) + MemToHex(ID2, 2) + '|' + MemToHex(Data^, Size)
    else
      PacketData := MemToHex(ID1, 1) + '|' + MemToHex(Data^, Size);

    FPipeManager.SendToPipe(FPipeManager.Pipes.CliPacket, PacketData + #13#10);
  except
    on E: Exception do
      TraceException('ForwardCliPacket', E);
  end;
end;

end.
