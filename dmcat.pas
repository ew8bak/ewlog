unit dmCat;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, MainFuncDM, ResourceStr, StdCtrls, LazFileUtils,
  Dialogs, process, synaser {$IFDEF UNIX},
  BaseUnix {$ENDIF};

type
  TCatSettingsRecord = record
    COMPort: string;
    Speed: integer;
    StopBit: integer;
    DataBit: integer;
    Parity: integer;
    Handshake: integer;
    RTSstate: integer;
    DTRstate: integer;
    CIVaddress: string;
    Poll: integer;
    Address: string;
    Port: integer;
    Extracmd: string;
    Transceiver: string;
    numTRX: integer;
    RigctldPath: string;
    StartRigctld: boolean;
  end;

type
  TCATdm = class(TDataModule)
  private

  public
    CatSettings: TCatSettingsRecord;
    function GetSerialPortNames: string;
    function LoadRIGs(PathRigctl: string; nTRX: integer): string;
    function SearchRigctld: string;
    procedure LoadCATini(nTRX: integer);

  end;

var
  CATdm: TCATdm;

implementation

uses dmFunc_U, InitDB_dm;

{$R *.lfm}

procedure TCATdm.LoadCATini(nTRX: integer);
begin
  CatSettings.COMPort := INIFile.ReadString('TRX' + IntToStr(nTRX), 'device', '');
  CatSettings.CIVaddress := INIFile.ReadString('TRX' + IntToStr(nTRX), 'CiV', '');
  CatSettings.Poll := INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'Poll', 3);
  CatSettings.Speed := INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'SerialSpeed', 0);
  CatSettings.StopBit := INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'StopBits', 0);
  CatSettings.DataBit := INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'DataBits', 0);
  CatSettings.Parity := INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'Parity', 0);
  CatSettings.Handshake := INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'HandShake', 0);
  CatSettings.RTSstate := INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'RTS', 0);
  CatSettings.DTRstate := INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'DTR', 0);
end;

function TCATdm.SearchRigctld: string;
var
  s: string;
begin
   {$IFDEF LINUX}
  if RunCommand('/bin/bash', ['-c', 'which rigctld'], s) then
  begin
    s := StringReplace(s, #10, '', [rfReplaceAll]);
    s := StringReplace(s, #13, '', [rfReplaceAll]);
    if Length(s) <> 0 then
      Result := s;
  end;
   {$ENDIF}
end;

function TCATdm.LoadRIGs(PathRigctl: string; nTRX: integer): string;
var
  dev: string;
  CBRigs: TComboBox;
begin
  Result := '';
  try
    CBRigs := TComboBox.Create(nil);
    CBRigs.Items.Clear;
    if FileExistsUTF8(PathRigctl) then
    begin
      dev := INIFile.ReadString('TRX' + IntToStr(nTRX), 'model', '');
      dmFunc.LoadRigsToComboBox(dev, StringReplace(PathRigctl, 'rigctld',
        'rigctl', [rfReplaceAll, rfIgnoreCase]), CBRigs);
    end
    else
      ShowMessage(rLibHamLibNotFound);

  finally
    Result := CBRigs.Items.CommaText;
    FreeAndNil(CBRigs);
  end;
end;

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
