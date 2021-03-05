unit dmCat;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, MainFuncDM, ResourceStr, synaser {$IFDEF UNIX},
  BaseUnix {$ENDIF};

type
  TCATdm = class(TDataModule)
  private

  public
    function GetSerialPortNames: string;

  end;

var
  CATdm: TCATdm;

implementation

{$R *.lfm}

function TCATdm.GetSerialPortNames: string;
begin
  Result := '';
  {$IFDEF WINDOWS}
  Result := synaser.GetSerialPortNames;
  {$ELSE}
  if fpAccess('/dev/ttyS0', W_OK) = 0 then
    Result := Result + ',/dev/ttyS0';
  if fpAccess('/dev/ttyS1', W_OK) = 0 then
    Result := Result + ',/dev/ttyS1';
  if fpAccess('/dev/ttyS2', W_OK) = 0 then
    Result := Result + ',/dev/ttyS2';
  if fpAccess('/dev/ttyS3', W_OK) = 0 then
    Result := Result + ',/dev/ttyS3';
  if fpAccess('/dev/tnt0', W_OK) = 0 then
    Result := Result + ',/dev/tnt0';
  if fpAccess('/dev/tnt1', W_OK) = 0 then
    Result := Result + ',/dev/tnt1';
  if fpAccess('/dev/tnt2', W_OK) = 0 then
    Result := Result + ',/dev/tnt2';
  if fpAccess('/dev/tnt3', W_OK) = 0 then
    Result := Result + ',/dev/tnt3';
  if fpAccess('/dev/tnt4', W_OK) = 0 then
    Result := Result + ',/dev/tnt4';
  if fpAccess('/dev/tnt5', W_OK) = 0 then
    Result := Result + ',/dev/tnt5';
  if fpAccess('/dev/tnt6', W_OK) = 0 then
    Result := Result + ',/dev/tnt6';
  if fpAccess('/dev/tnt7', W_OK) = 0 then
    Result := Result + ',/dev/tnt7';
  if fpAccess('/dev/ttyUSB0', W_OK) = 0 then
    Result := Result + ',/dev/ttyUSB0';
  if fpAccess('/dev/ttyUSB1', W_OK) = 0 then
    Result := Result + ',/dev/ttyUSB1';
  if fpAccess('/dev/ttyUSB2', W_OK) = 0 then
    Result := Result + ',/dev/ttyUSB2';
  if fpAccess('/dev/ttyUSB3', W_OK) = 0 then
    Result := Result + ',/dev/ttyUSB3';
  if fpAccess('/dev/ttyd0', W_OK) = 0 then
    Result := Result + ',/dev/ttyd0';
  if fpAccess('/dev/ttyd1', W_OK) = 0 then
    Result := Result + ',/dev/ttyd1';
  if fpAccess('/dev/ttyd2', W_OK) = 0 then
    Result := Result + ',/dev/ttyd2';
  if fpAccess('/dev/ttyd3', W_OK) = 0 then
    Result := Result + ',/dev/ttyd3';
  if fpAccess('/dev/cu.usbserial', W_OK) = 0 then
    Result := Result + ',/dev/cu.usbserial';
  if fpAccess('/dev/tty.usbserial', W_OK) = 0 then
    Result := Result + ',/dev/tty.usbserial';
  {$ENDIF}
end;

end.

