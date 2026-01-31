unit Logger;

interface

uses
  Windows, SysUtils;

procedure Trace(const Msg: string);
procedure TraceError(const Context, ErrorMsg: string);
procedure TraceFmt(const Fmt: string; const Args: array of const);
procedure TraceEnter(const MethodName: string);
procedure TraceLeave(const MethodName: string);
procedure TraceException(const Context: string; E: Exception);
procedure TracePtr(const Context: string; Ptr: Pointer);

const
  DEBUG_MODE = True;
  TRACE_ENTER_LEAVE = True;  // ¬ключить трассировку входа/выхода из методов

implementation

procedure Trace(const Msg: string);
begin
  if DEBUG_MODE then
  try
    OutputDebugString(PChar('ADR_BRIDGE: ' + Msg));
  except
    // »гнорируем ошибки в самом логере
  end;
end;

procedure TraceError(const Context, ErrorMsg: string);
begin
  Trace('!!! ERROR in [' + Context + '] -> ' + ErrorMsg);
end;

procedure TraceFmt(const Fmt: string; const Args: array of const);
begin
  if DEBUG_MODE then
  try
    Trace(Format(Fmt, Args));
  except
    on E: Exception do
      Trace('TraceFmt failed: ' + E.Message);
  end;
end;

procedure TraceEnter(const MethodName: string);
begin
  if DEBUG_MODE and TRACE_ENTER_LEAVE then
    Trace('>>> ENTER: ' + MethodName);
end;

procedure TraceLeave(const MethodName: string);
begin
  if DEBUG_MODE and TRACE_ENTER_LEAVE then
    Trace('<<< LEAVE: ' + MethodName);
end;

procedure TraceException(const Context: string; E: Exception);
begin
  if E <> nil then
    Trace('!!! EXCEPTION in [' + Context + ']: ' + E.ClassName + ' - ' + E.Message)
  else
    Trace('!!! EXCEPTION in [' + Context + ']: Unknown exception (nil)');
end;

procedure TracePtr(const Context: string; Ptr: Pointer);
begin
  if DEBUG_MODE then
    TraceFmt('%s: Pointer = %p', [Context, Ptr]);
end;

end.
