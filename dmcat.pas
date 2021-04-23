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
    TransceiverNum: integer;
    TransceiverName: string;
    numTRX: integer;
    RigctldPath: string;
    StartRigctld: boolean;
  end;

type
  TCATdm = class(TDataModule)
  private

  public
    function GetSerialPortNames: string;
    function LoadRIGs(PathRigctl: string; nTRX: integer): string;
    function SearchRigctld: string;
    function GetRadioRigCtldCommandLine(radio: word): string;
    procedure LoadCATini(nTRX: integer);
    procedure SaveCATini(nTRX: integer);

  end;

var
  CATdm: TCATdm;
  CatSettings: TCatSettingsRecord;

implementation

uses dmFunc_U, InitDB_dm;

{$R *.lfm}

procedure TCATdm.LoadCATini(nTRX: integer);
begin
  CatSettings.TransceiverNum := INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'model', 0);
  CatSettings.TransceiverName := INIFile.ReadString('TRX' + IntToStr(nTRX), 'name', '');
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
  CatSettings.Address := INIFile.ReadString('TRX' + IntToStr(nTRX),
    'RigCtldHost', '127.0.0.1');
  CatSettings.Port := INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'RigCtldPort', 4532);
  CatSettings.Extracmd := INIFile.ReadString('TRX' + IntToStr(nTRX), 'rigctldExtra', '');
  CatSettings.StartRigctld := INIFile.ReadBool('TRX' + IntToStr(nTRX),
    'RunRigCtld', True);
  CatSettings.RigctldPath := INIFile.ReadString('SetCAT', 'rigctldPath', '');
end;

procedure TCATdm.SaveCATini(nTRX: integer);
begin
  INIFile.WriteInteger('TRX' + IntToStr(nTRX), 'model', CatSettings.TransceiverNum);
  INIFile.WriteString('TRX' + IntToStr(nTRX), 'name', CatSettings.TransceiverName);
  INIFile.WriteString('TRX' + IntToStr(nTRX), 'device', CatSettings.COMPort);
  INIFile.WriteString('TRX' + IntToStr(nTRX), 'CiV', CatSettings.CIVaddress);
  INIFile.WriteInteger('TRX' + IntToStr(nTRX), 'Poll', CatSettings.Poll);
  INIFile.WriteInteger('TRX' + IntToStr(nTRX), 'SerialSpeed', CatSettings.Speed);
  INIFile.WriteInteger('TRX' + IntToStr(nTRX), 'StopBits', CatSettings.StopBit);
  INIFile.WriteInteger('TRX' + IntToStr(nTRX), 'DataBits', CatSettings.DataBit);
  INIFile.WriteInteger('TRX' + IntToStr(nTRX), 'Parity', CatSettings.Parity);
  INIFile.WriteInteger('TRX' + IntToStr(nTRX), 'HandShake', CatSettings.Handshake);
  INIFile.WriteInteger('TRX' + IntToStr(nTRX), 'RTS', CatSettings.RTSstate);
  INIFile.WriteInteger('TRX' + IntToStr(nTRX), 'DTR', CatSettings.DTRstate);
  INIFile.WriteString('TRX' + IntToStr(nTRX), 'RigCtldHost', CatSettings.Address);
  INIFile.WriteInteger('TRX' + IntToStr(nTRX), 'RigCtldPort', CatSettings.Port);
  INIFile.WriteString('TRX' + IntToStr(nTRX), 'rigctldExtra', CatSettings.Extracmd);
  INIFile.WriteBool('TRX' + IntToStr(nTRX), 'RunRigCtld', CatSettings.StartRigctld);
  INIFile.WriteString('SetCAT', 'rigctldPath', CatSettings.RigctldPath);
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

function TCATdm.GetRadioRigCtldCommandLine(radio: word): string;
var
  section: ShortString = '';
  arg: string = '';
  set_conf: string = '';
begin
  section := 'TRX' + IntToStr(radio);

  if INIFile.ReadString(section, 'model', '') = '' then
  begin
    Result := '';
    exit;
  end;

  Result := '-m ' + INIFile.ReadString(section, 'model', '') + ' ' +
    '-t ' + INIFile.ReadString(section, 'RigCtldPort', '4532') + ' ';

  Result := Result + INIFile.ReadString('SetCAT', 'rigctldExtra', '') + ' ';

  case INIFile.ReadInteger(section, 'SerialSpeed', 0) of
    0: arg := '';
    1: arg := '-s 1200 ';
    2: arg := '-s 2400 ';
    3: arg := '-s 4800 ';
    4: arg := '-s 9600 ';
    5: arg := '-s 14400 ';
    6: arg := '-s 19200 ';
    7: arg := '-s 38400 ';
    8: arg := '-s 57600 ';
    9: arg := '-s 115200 '

    else
      arg := ''
  end; //case
  Result := Result + arg;

  case INIFile.ReadInteger(section, 'DataBits', 0) of
    0: arg := '';
    1: arg := 'data_bits=5';
    2: arg := 'data_bits=6';
    3: arg := 'data_bits=7';
    4: arg := 'data_bits=8';
    5: arg := 'data_bits=9'
    else
      arg := ''
  end; //case
  if arg <> '' then
    set_conf := set_conf + arg + ',';

  if INIFile.ReadInteger(section, 'StopBits', 0) > 0 then
    set_conf := set_conf + 'stop_bits=' + IntToStr(INIFile.ReadInteger(
      section, 'StopBits', 0) - 1) + ',';

  case INIFile.ReadInteger(section, 'Parity', 0) of
    0: arg := '';
    1: arg := 'serial_parity=None';
    2: arg := 'serial_parity=Odd';
    3: arg := 'serial_parity=Even';
    4: arg := 'serial_parity=Mark';
    5: arg := 'serial_parity=Space'
    else
      arg := ''
  end; //case
  if arg <> '' then
    set_conf := set_conf + arg + ',';

  case INIFile.ReadInteger(section, 'HandShake', 0) of
    0: arg := '';
    1: arg := 'serial_handshake=None';
    2: arg := 'serial_handshake=XONXOFF';
    3: arg := 'serial_handshake=Hardware';
    else
      arg := ''
  end; //case
  if arg <> '' then
    set_conf := set_conf + arg + ',';

  case INIFile.ReadInteger(section, 'DTR', 0) of
    0: arg := '';
    1: arg := 'dtr_state=Unset';
    2: arg := 'dtr_state=ON';
    3: arg := 'dtr_state=OFF';
    else
      arg := ''
  end; //case
  if arg <> '' then
    set_conf := set_conf + arg + ',';

  case INIFile.ReadInteger(section, 'RTS', 0) of
    0: arg := '';
    1: arg := 'rts_state=Unset';
    2: arg := 'rts_state=ON';
    3: arg := 'rts_state=OFF';
    else
      arg := ''
  end; //case
  if arg <> '' then
    set_conf := set_conf + arg + ',';

  if (set_conf <> '') then
  begin
    set_conf := copy(set_conf, 1, Length(set_conf) - 1);
    Result := Result + ' --set-conf=' + set_conf;
  end;
end;

end.
