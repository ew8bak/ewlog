unit QSODataDecoder;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DateUtils;

type
  TQDateTime = record
    JulianDay: Int64;
    MsecsSinceMidnight: Cardinal;
    TimeSpec: Byte;         // 0=local, 1=UTC, 2=Offset from UTC, 3=time zone
    Offset: Integer;
  end;

  TQSOLogged = class
  public
    SchemaVersion: Cardinal;
    MessageType: Cardinal;
    ID: string;
    DateTimeOff: TQDateTime;
    DXCall: string;
    DXGrid: string;
    TxFrequency: UInt64;
    Mode: string;
    ReportSent: string;
    ReportReceived: string;
    TxPower: string;
    Comments: string;
    Name: string;
    DateTimeOn: TQDateTime;
    OperatorCall: string;
    MyCall: string;
    MyGrid: string;
  end;

  TQSODataDecoder = class
  private
    FStream: TMemoryStream;
    FBigEndian: Boolean;
    function ReadUInt32: Cardinal;
    function ReadUInt64: UInt64;
    function ReadInt64: Int64;
    function ReadUTF8String: string;
    function ReadQDateTime: TQDateTime;
    procedure SwapBytes(var Value; Size: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function DecodeMessage(const Data: TBytes): TQSOLogged;
  end;

implementation

constructor TQSODataDecoder.Create;
begin
  FStream := TMemoryStream.Create;
  FBigEndian := True; // Сообщения в big-endian формате
end;

destructor TQSODataDecoder.Destroy;
begin
  FStream.Free;
  inherited;
end;

procedure TQSODataDecoder.SwapBytes(var Value; Size: Integer);
var
  P: PByte;
  i: Integer;
  Temp: Byte;
begin
  P := @Value;
  for i := 0 to (Size div 2) - 1 do
  begin
    Temp := P[i];
    P[i] := P[Size - 1 - i];
    P[Size - 1 - i] := Temp;
  end;
end;

function TQSODataDecoder.ReadUInt32: Cardinal;
begin
  FStream.Read(Result, SizeOf(Result));
  if FBigEndian then SwapBytes(Result, SizeOf(Result));
end;

function TQSODataDecoder.ReadUInt64: UInt64;
begin
  FStream.Read(Result, SizeOf(Result));
  if FBigEndian then SwapBytes(Result, SizeOf(Result));
end;

function TQSODataDecoder.ReadInt64: Int64;
begin
  FStream.Read(Result, SizeOf(Result));
  if FBigEndian then SwapBytes(Result, SizeOf(Result));
end;

function TQSODataDecoder.ReadUTF8String: string;
var
  Len: Cardinal;
  Bytes: TBytes;
begin
  Len := ReadUInt32;
  if Len = $FFFFFFFF then // Null string
    Exit('');

  SetLength(Bytes, Len);
  if Len > 0 then
    FStream.Read(Bytes[0], Len);

  Result := TEncoding.UTF8.GetString(Bytes);
end;

function TQSODataDecoder.ReadQDateTime: TQDateTime;
begin
  Result.JulianDay := ReadInt64;
  Result.MsecsSinceMidnight := ReadUInt32;
  Result.TimeSpec := FStream.ReadByte;

  if Result.TimeSpec = 2 then
    Result.Offset := ReadUInt32
  else
    Result.Offset := 0;
end;

function TQSODataDecoder.DecodeMessage(const Data: TBytes): TQSOLogged;
var
  Magic: Cardinal;
begin
  Result := nil;
  FStream.Clear;
  FStream.Write(Data[0], Length(Data));
  FStream.Position := 0;

  // Check magic number
  Magic := ReadUInt32;
  if Magic <> $ADBCCBDA then
    raise Exception.Create('Invalid magic number');

  Result := TQSOLogged.Create;
  try
    Result.SchemaVersion := ReadUInt32;

    // Check message type
    Result.MessageType := ReadUInt32;
    if Result.MessageType <> 5 then
      raise Exception.Create('Not a QSO Logged message');

    // Read QSO fields
    Result.ID := ReadUTF8String;
    Result.DateTimeOff := ReadQDateTime;
    Result.DXCall := ReadUTF8String;
    Result.DXGrid := ReadUTF8String;
    Result.TxFrequency := ReadUInt64;
    Result.Mode := ReadUTF8String;
    Result.ReportSent := ReadUTF8String;
    Result.ReportReceived := ReadUTF8String;
    Result.TxPower := ReadUTF8String;
    Result.Comments := ReadUTF8String;
    Result.Name := ReadUTF8String;
    Result.DateTimeOn := ReadQDateTime;
    Result.OperatorCall := ReadUTF8String;
    Result.MyCall := ReadUTF8String;
    Result.MyGrid := ReadUTF8String;
  except
    on E: Exception do
    begin
      Result.Free;
      raise;
    end;
  end;
end;

end.
