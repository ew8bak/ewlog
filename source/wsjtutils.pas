{********************************************************************************
***                               AlarmeJT                                    ***
***    AlarmeJT is designed to work with exellent WSJT -X Joe Taylor, K1JT    ***
***    running on JT65A modes and JT9.                                        ***
***    -------------------------------------------------------------------    ***
***    version : 0.5 UDP beta                                                 ***
***    -------------------------------------------------------------------    ***
***    Copyright 2015 Alain Thébault (F5JMH)                                  ***
***                                                                           ***
***    UDP and NetworkMessageUtils modules Copyright G4WJS (thank's)          ***
***                                                                           ***
***    This file is part of AlarmeJT.                                         ***
***                                                                           ***
***    AlarmeJT is free software: you can redistribute it and/or modify       ***
***    it under the terms of the GNU General Public License as published by   ***
***    the Free Software Foundation, either version 2.0 of the License, or    ***
***    any later version.                                                     ***
***                                                                           ***
***    AlarmeJT is distributed in the hope that it will be useful,            ***
***    but WITHOUT ANY WARRANTY; without even the implied warranty of         ***
***    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          ***
***    GNU General Public License for more details.                           ***
***                                                                           ***
***    You should have received a copy of the GNU General Public License      ***
***    along with AlarmeJT.  If not, see <http://www.gnu.org/licenses/>.      ***
***                                                                           ***
***    -------------------------------------------------------------------    ***
********************************************************************************}

unit WsjtUtils;

//{$mode objfpc}
{$H+}

interface

uses
  Classes, SysUtils, DateUtils, Sockets, IdGlobal, IdStack;

procedure Pack(var AData: TIdBytes; const AValue: longint) overload;
procedure Pack(var AData: TIdBytes; const AString: string) overload;
procedure Pack(var AData: TIdBytes; const AValue: QWord) overload;
procedure Pack(var AData: TIdBytes; const AValue: int64) overload;
procedure Pack(var AData: TIdBytes; const AFlag: boolean) overload;
procedure Pack(var AData: TIdBytes; const AValue: longword) overload;
procedure Pack(var AData: TIdBytes; const AValue: double) overload;
procedure Pack(var AData: TIdBytes; const ADateTime: TDateTime) overload;

procedure Unpack(const AData: TIdBytes; var index: integer;
  var AValue: longint) overload;
procedure Unpack(const AData: TIdBytes; var index: integer;
  var AString: string) overload;
procedure Unpack(const AData: TIdBytes; var index: integer; var AValue: QWord) overload;
procedure Unpack(const AData: TIdBytes; var index: integer; var AValue: int64) overload;
procedure Unpack(const AData: TIdBytes; var index: integer; var AFlag: boolean) overload;
procedure Unpack(const AData: TIdBytes; var index: integer;
  var AValue: longword) overload;
procedure Unpack(const AData: TIdBytes; var index: integer; var AValue: double) overload;
procedure Unpack(const AData: TIdBytes; var index: integer;
  var ADateTime: TDateTime) overload;

implementation

procedure Pack(var AData: TIdBytes; const AValue: longint);
begin
  AppendBytes(AData, ToBytes(HToNl(AValue)));
end;

procedure Pack(var AData: TIdBytes; const AValue: int64) overload;
begin
  {$IFNDEF BIG_ENDIAN}
  AppendBytes(AData, ToBytes(SwapEndian(AValue)));
  {$ELSE}
  AppendBytes(AData, ToBytes(AValue));
  {$ENDIF}
end;

procedure Pack(var AData: TIdBytes; const AString: string) overload;
var
  temp: TIdBytes;
  long: integer;       // length of Astring
begin
  long := Length(AString);        // longueur d'Astring
  temp := ToBytes(AString, enUTF8);
  Pack(AData, long);             // Pack avec la longueur du message
  AppendBytes(AData, temp);      // Pack du bytes
end;

procedure Pack(var AData: TIdBytes; const AValue: QWord) overload;
var
  temp: int64 absolute AValue;
begin
  Pack(AData, temp);
end;

procedure Pack(var AData: TIdBytes; const AFlag: boolean) overload;
var
  temp: ShortInt;
begin
  if AFlag then
    temp := -1
  else
    temp := 0;
  AppendBytes(AData, ToBytes(temp));
end;

procedure Pack(var AData: TIdBytes; const AValue: longword) overload;
begin
  AppendBytes(AData, ToBytes(HToNl(AValue)));
end;

procedure Pack(var AData: TIdBytes; const AValue: double) overload;
var
  temp: QWord absolute AValue;
begin
  Pack(AData, temp);
end;

procedure Pack(var AData: TIdBytes; const ADateTime: TDateTime) overload;
//var
//  dt: Int64;
//  tm: Longword;
//  ts: Byte;
//  temp: Double;
begin
  Pack(AData, MilliSecondOfTheDay(ADateTime));
  Pack(AData, QWord(DateTimeToJulianDate(ADateTime)));
  Pack(AData, byte(1));
end;


procedure Unpack(const AData: TIdBytes; var index: integer; var AValue: longint);
begin
  AValue := BytesToInt32(AData, index);
  AValue := Int32(GStack.HostToNetwork(UInt32(AValue)));
  index := index + SizeOf(AValue);
end;

procedure Unpack(const AData: TIdBytes; var index: integer; var AValue: int64) overload;
begin
  AValue := BytesToInt64(AData, index);
  index := index + SizeOf(AValue);
  {$IFNDEF BIG_ENDIAN}
  AValue := SwapEndian(AValue);
  {$ENDIF}
end;

procedure Unpack(const AData: TIdBytes; var index: integer;
  var AString: string) overload;
var
  length: longint;
begin
  Unpack(AData, index, length);
  if length <> longint($ffffffff) then
  begin
    AString := BytesToString(AData, index, length, enUtf8);
    index := index + length;
  end
  else
    AString := '';
end;

procedure Unpack(const AData: TIdBytes; var index: integer; var AValue: QWord) overload;
var
  temp: int64 absolute AValue;
begin
  Unpack(AData, index, temp);
end;

procedure Unpack(const AData: TIdBytes; var index: integer; var AFlag: boolean) overload;
begin
  AFlag := AData[index] <> 0;
  index := index + 1;
end;

procedure Unpack(const AData: TIdBytes; var index: integer;
  var AValue: longword) overload;
begin

  AValue := BytesToUInt32(AData, index);
  AValue := LongWord (GStack.HostToNetwork(LongWord(AValue)));
  index := index + SizeOf(AValue);
end;

procedure Unpack(const AData: TIdBytes; var index: integer; var AValue: double) overload;
var
  temp: QWord absolute AValue;
begin
  Unpack(AData, index, temp);
end;

procedure Unpack(const AData: TIdBytes; var index: integer;
  var ADateTime: TDateTime) overload;
var
  dt: int64;
  tm: longword;
  ts: byte;
  temp: double;
begin
  Unpack(AData, index, dt);
  Unpack(AData, index, tm);
  ts := AData[index];
  index := index + 1;
  {assume UTC for now}
  temp := dt;
  ADateTime := IncMilliSecond(JulianDateToDateTime(temp), tm);
end;

end.
