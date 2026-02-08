# BridgeV1 — L2Bot IPC Bridge Plugin

A Delphi plugin DLL for L2Bot that exposes a JSON-RPC interface over Windows Named Pipes, enabling external applications (Kotlin/Java or any language supporting Named Pipes) to control and monitor the bot programmatically.

## Project Structure

```
BridgeV1/
├── BridgeV1.dpr             # Main DLL entry point & exported functions
├── Types.pas                # Shared types and constants
├── PluginAPI.pas            # L2Bot engine interfaces (IL2Control, IL2User, etc.)
├── PluginConst.pas          # Game-related enums and constants
├── PipeManager.pas          # Named Pipes creation, I/O, reconnection
├── CommandProcessor.pas     # JSON-RPC command handler (threaded)
├── EventForwarder.pas       # Streams game events to pipes
├── JsonSerialization.pas    # Game object → JSON serialization
└── Logger.pas               # Debug logging via OutputDebugString
```

## Architecture

```
┌────────────┐                  ┌───────────────┐                  ┌─────────┐
│  External  │ ──commands────>  │   BridgeV1    │  <──Engine────  │  L2Bot  │
│  Client    │ <─responses────  │    Plugin     │  ──Engine────>  │         │
│ (Kotlin/..)│ <─actions──────  │     DLL       │                  │         │
│            │ <─packets──────  │               │                  │         │
└────────────┘                  └───────────────┘                  └─────────┘
```

### Named Pipes (5 per character)

Each character creates pipes with the pattern `\\.\pipe\l2bot_{type}_{CharName}`:

| Pipe | Direction | Purpose |
|------|-----------|---------|
| `l2bot_commands_{CharName}` | Client → Plugin | Receives JSON-RPC commands |
| `l2bot_responses_{CharName}` | Plugin → Client | Sends JSON-RPC responses |
| `l2bot_actions_{CharName}` | Plugin → Client | Streams game action events |
| `l2bot_packets_{CharName}` | Plugin → Client | Streams server → client packets (hex) |
| `l2bot_clipackets_{CharName}` | Plugin → Client | Streams client → server packets (hex) |

### Core Components

**PipeManager** — Creates and manages all 5 named pipes. Handles UTF-8 I/O, automatic reconnection with retry logic, and character name sanitization for pipe naming.

**CommandProcessor** — Runs a dedicated polling thread (10 ms interval) that reads JSON-RPC requests from the command pipe, dispatches them to registered handlers, and writes responses back.

**EventForwarder** — Subscribes to L2Bot engine callbacks (`OnAction`, `OnPacket`, `OnCliPacket`) and forwards events to the corresponding outbound pipes.

**JsonSerialization** — Converts L2Bot interfaces (`IL2User`, `IL2Npc`, `IL2Char`, etc.) to JSON objects. Handles player stats, inventory, skills, buffs, NPC lists, drop lists, and more.

**Logger** — Debug output via `OutputDebugString()` with `ADR_BRIDGE:` prefix. Supports method enter/leave tracing and exception logging.

## JSON-RPC Protocol

### Request Format

```json
{
  "id": 1,
  "method": "Engine.GetMe",
  "params": {}
}
```

### Response Format

```json
{
  "id": 1,
  "status": "success",
  "result": { ... }
}
```

Error response:
```json
{
  "id": 1,
  "status": "error",
  "error": "Unknown method: Foo.Bar"
}
```

### Available Methods

| Method | Params | Description |
|--------|--------|-------------|
| `System.Echo` | `{"message": "..."}` | Echo test, returns the message back |
| `Engine.GetMe` | `{}` | Returns full player data (stats, inventory, skills, buffs) |
| `Engine.GetNpcList` | `{}` | Returns list of visible NPCs with positions, HP, buffs |
| `Engine.MoveTo` | `{"x": int, "y": int, "z": int}` | Move character to coordinates |
| `Engine.MoveToByOid` | `{"oid": int}` | Move to a specific NPC/object by OID |

### Event Stream Formats

**Actions pipe:** `{ActionID}|{P1}|{P2}\r\n`

**Packets pipe:** `{HexID}|{HexData}\r\n`

## Plugin Lifecycle

```
DLL loaded by L2Bot
    │
    ▼
StartPlugin(AppHandle, PProc)     ← Plugin initialization
    │
    ▼
InitControl(Engine)               ← Called per character
    ├── PipeManager.Initialize()  ← Creates 5 named pipes
    ├── EventForwarder.Create()   ← Registers engine callbacks
    └── CommandProcessor.Start()  ← Starts polling thread
    │
    ▼
Game loop: events forwarded, commands processed
    │
    ▼
StopPlugin()                      ← Cleanup & shutdown
```

### DLL Exports

| Export | Signature | Description |
|--------|-----------|-------------|
| `StartPlugin` | `(AppHandle, PProc): Cardinal` | Called once when the plugin is loaded |
| `InitControl` | `(AEngine: IL2Control): THandle` | Called per character, returns instance handle |
| `StopPlugin` | `(): Boolean` | Called on plugin unload |
| `OnAction` | `(Action, P1, P2)` | Game action callback |
| `OnPacket` | `(ID1, ID2, Data, Size)` | Server → client packet callback |
| `OnCliPacket` | `(ID1, ID2, Data, Size)` | Client → server packet callback |

## Configuration

Constants in `Types.pas`:

```delphi
BUFFER_SIZE = 16384;          // Pipe buffer size in bytes (16 KB)
COMMAND_CHECK_INTERVAL = 10;  // Command polling interval in ms
```

Debug flags in `Logger.pas`:

```delphi
DEBUG_MODE = True;            // Enable/disable debug output
TRACE_ENTER_LEAVE = True;     // Log method entry/exit
```

## Building

1. Open `BridgeV1.dpr` in Delphi IDE
2. Build → Compile
3. Copy the resulting `BridgeV1.dll` to the L2Bot plugins directory

## Usage Example (Kotlin)

```kotlin
// Connect to the command pipe
val commandPipe = FileOutputStream("\\\\.\\pipe\\l2bot_commands_MyChar")
val responsePipe = FileInputStream("\\\\.\\pipe\\l2bot_responses_MyChar")

// Send a command
val request = """{"id":1,"method":"Engine.GetMe","params":{}}"""
commandPipe.write(request.toByteArray(Charsets.UTF_8))

// Read the response
val buffer = ByteArray(16384)
val bytesRead = responsePipe.read(buffer)
val response = String(buffer, 0, bytesRead, Charsets.UTF_8)
println(response) // {"id":1,"status":"success","result":{...}}
```

## Debugging

All debug messages are sent via `OutputDebugString()` with the `ADR_BRIDGE:` prefix. Use tools like **DebugView** (Sysinternals) to capture output:

```
ADR_BRIDGE: [PipeManager] Created INBOUND: \\.\pipe\l2bot_commands_MyChar
ADR_BRIDGE: [CommandProcessor] Thread started
ADR_BRIDGE: [CommandProcessor] Received: {"id":1,"method":"Engine.GetMe","params":{}}
ADR_BRIDGE: [CommandProcessor] Response sent, 2048 bytes
```

## License

Open source. Free to use.
