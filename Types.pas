unit Types;

interface

uses
  Windows;

const
  BUFFER_SIZE = 16384;
  COMMAND_CHECK_INTERVAL = 10;

type
  TPipeHandles = record
    Command: THandle;
    Response: THandle;
    Action: THandle;
    Packet: THandle;
    CliPacket: THandle;
  end;

implementation

end.
