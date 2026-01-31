unit CommandProcessor;

interface

uses
  Windows, SysUtils, System.JSON, System.Generics.Collections,
  Types, PluginAPI, PipeManager, JsonSerialization, Logger;

type
  TCommandProc = function(Params: TJSONObject): TJSONValue of object;

  TCommandProcessor = class
  private
    FEngine: IL2Control;
    FPipeManager: TPipeManager;
    FCommandThread: THandle;
    FCommandThreadID: Cardinal;
    FStopRequested: Boolean;
    FMethods: TDictionary<string, TCommandProc>;

    procedure RegisterMethods;
    function ProcessRpc(const JsonStr: string): string;

    function MethodGetMe(Params: TJSONObject): TJSONValue;
    function MethodEcho(Params: TJSONObject): TJSONValue;
  public
    constructor Create(AEngine: IL2Control; APipeManager: TPipeManager);
    destructor Destroy; override;

    function Start: Boolean;
    procedure Stop;

    property ThreadID: Cardinal read FCommandThreadID;
  end;

function CommandThreadProc(P: Pointer): DWORD; stdcall;

// Если константа не определена в PluginAPI, определим её здесь по умолчанию
const
  LOCAL_COMMAND_CHECK_INTERVAL = 50;
  ERROR_PIPE_LISTENING = 536; // Код ошибки ожидания подключения

implementation

constructor TCommandProcessor.Create(AEngine: IL2Control; APipeManager: TPipeManager);
begin
  TraceEnter('TCommandProcessor.Create');
  try
    inherited Create;
    FEngine := AEngine;
    FPipeManager := APipeManager;
    FStopRequested := False;
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
    Stop;
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
end;

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

function TCommandProcessor.Start: Boolean;
begin
  TraceEnter('TCommandProcessor.Start');
  FCommandThread := CreateThread(nil, 0, @CommandThreadProc, Self, 0, FCommandThreadID);
  Result := FCommandThread <> 0;
  if Result then
    TraceFmt('Command thread started successfully (ID: %d)', [FCommandThreadID])
  else
    TraceError('TCommandProcessor.Start', 'Failed to create thread: ' + SysErrorMessage(GetLastError));
  TraceLeave('TCommandProcessor.Start');
end;

procedure TCommandProcessor.Stop;
begin
  TraceEnter('TCommandProcessor.Stop');
  if FCommandThread = 0 then Exit;

  FStopRequested := True;
  Trace('Requesting thread stop...');

  if WaitForSingleObject(FCommandThread, 500) = WAIT_TIMEOUT then
  begin
    TraceError('TCommandProcessor.Stop', 'Thread did not stop in time, forcing termination (unsafe)');
    TerminateThread(FCommandThread, 0);
  end
  else
    Trace('Thread stopped gracefully.');

  CloseHandle(FCommandThread);
  FCommandThread := 0;
  TraceLeave('TCommandProcessor.Stop');
end;

function CommandThreadProc(P: Pointer): DWORD; stdcall;
var
  Processor: TCommandProcessor;
  Cmd: string;
  Resp: string;
  ReadSuccess: Boolean;
  WriteSuccess: Boolean;
  ReconnectNeeded: Boolean;
  ErrCode: DWORD;
begin
  Result := 0;
  if not Assigned(P) then Exit;
  Processor := TCommandProcessor(P);

  TraceFmt('CommandThreadProc: Thread loop started (ID: %d)', [GetCurrentThreadId]);

  try
    while not Processor.FStopRequested do
    begin
      try
        ReadSuccess := Processor.FPipeManager.ReadFromPipe(
          Processor.FPipeManager.Pipes.Command, Cmd);

        ReconnectNeeded := False;

        if ReadSuccess then
        begin
          // Команда получена, обрабатываем
          Resp := Processor.ProcessRpc(Cmd);

          // Отправляем ответ
          WriteSuccess := Processor.FPipeManager.SendToPipe(
            Processor.FPipeManager.Pipes.Response, UTF8String(Resp + #13#10));

          if not WriteSuccess then
          begin
            TraceError('CommandThreadProc', 'Failed to send response. Triggering full reconnect.');
            ReconnectNeeded := True;
          end;
        end
        else
        begin
          // Если чтения не было, проверяем жив ли канал
          if not PeekNamedPipe(Processor.FPipeManager.Pipes.Command, nil, 0, nil, nil, nil) then
          begin
            ErrCode := GetLastError;
            // Игнорируем штатные состояния ожидания, чтобы не спамить реконнектами
            if (ErrCode <> ERROR_NO_DATA) and
               (ErrCode <> ERROR_PIPE_LISTENING) then
            begin
               // Только реальные ошибки (например, разрыв соединения клиентом) вызывают пересоздание
               ReconnectNeeded := True;
            end;
          end;
        end;

        if ReconnectNeeded then
        begin
          // УБРАЛИ ЛОГ "Performing full pipe reconnection sequence", так как это спам
          // Это нормальный процесс восстановления связи

          // Переподключаем все каналы
          Processor.FPipeManager.ReconnectPipe(
            Processor.FPipeManager.FPipes.Command, 'commands', True);
          Processor.FPipeManager.ReconnectPipe(
            Processor.FPipeManager.FPipes.Response, 'responses', False);
          Processor.FPipeManager.ReconnectPipe(
            Processor.FPipeManager.FPipes.Action, 'actions', False);
          Processor.FPipeManager.ReconnectPipe(
            Processor.FPipeManager.FPipes.Packet, 'packets', False);
          Processor.FPipeManager.ReconnectPipe(
            Processor.FPipeManager.FPipes.CliPacket, 'clipackets', False);

          // Даем небольшую паузу после реконнекта, чтобы клиент успел подцепиться
          Sleep(500);
        end;

      except
        on E: Exception do
        begin
          TraceException('CommandThreadProc Loop', E);
          Sleep(1000);
        end;
      end;

      Sleep(LOCAL_COMMAND_CHECK_INTERVAL);
    end;
  except
    on E: Exception do
      TraceException('CommandThreadProc Fatal', E);
  end;

  Trace('CommandThreadProc: Thread loop finished.');
end;

end.
