unit Logger;

interface

uses
  Windows, SysUtils;
procedure Trace(const Msg: string);
procedure TraceError(const Context, ErrorMsg: string);

const
  DEBUG_MODE = True;

implementation

procedure Trace(const Msg: string);
begin
  if DEBUG_MODE then
    OutputDebugString(PChar('ADR_BRIDGE: ' + Msg));
end;

procedure TraceError(const Context, ErrorMsg: string);
begin
  Trace('!!! ERROR in [' + Context + '] -> ' + ErrorMsg);
end;

end.
