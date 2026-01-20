# BridgeV1 - Kotlin Bridge Plugin

Модульная архитектура плагина для связи L2Bot с Kotlin через Named Pipes.

## 📁 Структура проекта

```
BridgeV1/
├── BridgeV1.dpr           # Главный файл плагина
├── Types.pas              # Общие типы и константы
├── PipeManager.pas        # Управление Named Pipes
├── CommandProcessor.pas   # Обработка команд от Kotlin
├── EventForwarder.pas     # Отправка событий в Kotlin
├── PluginAPI.pas          # API интерфейсы бота (копия)
├── PluginConst.pas        # Константы бота (копия)
└── README.md              # Эта документация
```

## 🏗️ Архитектура

### 1. Types.pas
**Назначение:** Общие типы данных и константы.

**Содержит:**
- `TPipeHandles` - структура с хендлами всех пайпов
- `BUFFER_SIZE` - размер буфера для чтения/записи
- `COMMAND_CHECK_INTERVAL` - интервал проверки команд

### 2. PipeManager.pas
**Назначение:** Управление Named Pipes.

**Ключевые методы:**
- `Create()` - создаёт менеджер с именем персонажа
- `Initialize()` - создаёт все 5 пайпов
- `ReadFromPipe()` - читает данные из пайпа (UTF-8)
- `SendToPipe()` - отправляет данные в пайп
- `Destroy()` - автоматически закрывает все пайпы

**Пайпы:**
- `l2bot_commands_{CharName}` - INBOUND (Kotlin → Plugin)
- `l2bot_responses_{CharName}` - OUTBOUND (Plugin → Kotlin)
- `l2bot_actions_{CharName}` - OUTBOUND (события)
- `l2bot_packets_{CharName}` - OUTBOUND (пакеты сервер→клиент)
- `l2bot_clipackets_{CharName}` - OUTBOUND (пакеты клиент→сервер)

### 3. CommandProcessor.pas
**Назначение:** Обработка команд от Kotlin.

**Ключевые методы:**
- `Start()` - запускает отдельный поток для чтения команд
- `Stop()` - останавливает поток
- `ExecuteCommand()` - парсит JSON и выполняет команду

**Поддерживаемые команды:**
- `Ping` → `{"status":"ok","data":"pong"}`
- `GetUserName` → возвращает имя персонажа
- `GetUserHP` → текущее HP
- `GetUserMP` → текущее MP
- `GetUserLevel` → уровень персонажа
- `GetUserXYZ` → координаты X, Y, Z
- `Say` → отправить сообщение в чат

**Поток команд:**
```
Цикл (каждые 10ms):
  1. Проверить наличие команды в пайпе
  2. Если есть - прочитать JSON
  3. Выполнить команду через Engine
  4. Отправить JSON ответ
```

### 4. EventForwarder.pas
**Назначение:** Отправка событий бота в Kotlin.

**Методы:**
- `ForwardAction()` - отправляет события OnAction
- `ForwardPacket()` - отправляет пакеты сервер→клиент
- `ForwardCliPacket()` - отправляет пакеты клиент→сервер

**Формат данных:**
- Actions: `{ActionID}|{P1}|{P2}\r\n`
- Packets: `{HexID}|{HexData}\r\n`

## 🚀 Как добавить новую команду

### Шаг 1: Добавить обработку в CommandProcessor.pas

```delphi
function TCommandProcessor.ExecuteCommand(const CommandJson: string): AnsiString;
begin
  // ...
  
  // Добавить новую команду
  else if Cmd = 'MoveTo' then
  begin
    X := StrToInt(GetJsonValue(CommandJson, 'x'));
    Y := StrToInt(GetJsonValue(CommandJson, 'y'));
    Z := StrToInt(GetJsonValue(CommandJson, 'z'));
    
    if FEngine.MoveTo(X, Y, Z) then
      Result := '{"status":"ok","data":"Moving"}'
    else
      Result := '{"status":"error","message":"Failed to move"}';
  end
  
  // ...
end;
```

### Шаг 2: Использовать в Kotlin

```kotlin
val response = client.sendCommand("""{"cmd":"MoveTo","x":12345,"y":67890,"z":100}""")
println(response) // {"status":"ok","data":"Moving"}
```

## 🔧 Компиляция

1. Открыть `BridgeV1.dpr` в Delphi
2. Build → Compile
3. Скопировать `BridgeV1.dll` в папку плагинов бота

## 📊 Поток данных

```
┌─────────┐                  ┌──────────────┐                  ┌────────┐
│ Kotlin  │ ───commands───>  │  BridgeV1    │  <───Engine───  │  Bot   │
│ Client  │ <──responses───  │   Plugin     │  ───Engine───>  │        │
│         │ <──events──────  │              │                  │        │
└─────────┘                  └──────────────┘                  └────────┘
```

## ⚙️ Настройки

### Изменить интервал проверки команд

В `Types.pas`:
```delphi
const
  COMMAND_CHECK_INTERVAL = 10; // мс (меньше = быстрее отклик)
```

### Изменить размер буфера

В `Types.pas`:
```delphi
const
  BUFFER_SIZE = 4096; // байт
```

## 🐛 Отладка

Все сообщения выводятся в лог бота через `Engine.Msg()`:

```
[BridgeV1] Initializing for: CharName
[PipeManager] Created INBOUND: \\.\pipe\l2bot_commands_CharName
[CommandProcessor] Thread started: 12345
[CommandThread] CMD: {"cmd":"Ping"}
[CommandThread] RESP: {"status":"ok","data":"pong"}
```

## 📝 Лицензия

Открытый код. Используйте свободно.
