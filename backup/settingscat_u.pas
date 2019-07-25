unit SettingsCAT_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, Spin, SimpleXML, LazFileUtils, synaser {$IFDEF UNIX},baseunix {$ENDIF};

type

  { TSettingsCAT }

  TSettingsCAT = class(TForm)
    Button1: TButton;
    cbBaudRate: TComboBox;
    cbCatPort: TComboBox;
    cbDataBits: TComboBox;
    cbDTRstate: TComboBox;
    cbHandshake: TComboBox;
    cbManufacturer: TComboBox;
    cbParity: TComboBox;
    cbRTSstate: TComboBox;
    cbStopBits: TComboBox;
    EditCIVaddress: TEdit;
    FileNameEdit1: TFileNameEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label16: TLabel;
    Label61: TLabel;
    Label62: TLabel;
    Label63: TLabel;
    Label64: TLabel;
    Label65: TLabel;
    Label66: TLabel;
    Label67: TLabel;
    RadioButton1: TRadioButton;
    RIG1: TRadioButton;
    SpinEdit1: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioButton1Change(Sender: TObject);
    procedure RIG1Change(Sender: TObject);
    procedure LoadINI;
    function GetSerialPortNames: string;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  SettingsCAT: TSettingsCAT;
  ID_Number, nTRX: integer;
  ModelName: string;
  Manufacturer: string;

implementation

uses
  MainForm_U, dmFunc_U, TRXForm_U;

{$R *.lfm}

{ TSettingsCAT }

procedure TSettingsCAT.LoadINI;
begin
 cbCatPort.Text:=IniF.ReadString('TRX' + IntToStr(nTRX), 'device', '');
 EditCIVaddress.Text:=IniF.ReadString('TRX' + IntToStr(nTRX), 'CiV', '');
 SpinEdit1.Value:=IniF.ReadInteger('TRX' + IntToStr(nTRX), 'Poll', 1);

 case IniF.ReadInteger('TRX' + IntToStr(nTRX), 'SerialSpeed', 0) of
    0: cbBaudRate.ItemIndex:=0;
    1: cbBaudRate.ItemIndex:=1;
    2: cbBaudRate.ItemIndex:=2;
    3: cbBaudRate.ItemIndex:=3;
    4: cbBaudRate.ItemIndex:=4;
    5: cbBaudRate.ItemIndex:=5;
    6: cbBaudRate.ItemIndex:=6;
    7: cbBaudRate.ItemIndex:=7;
    8: cbBaudRate.ItemIndex:=8;
    9: cbBaudRate.ItemIndex:=9;
  end;

 case IniF.ReadInteger('TRX' + IntToStr(nTRX), 'DataBits', 0) of
    0: cbDataBits.ItemIndex:=0;
    1: cbDataBits.ItemIndex:=1;
    2: cbDataBits.ItemIndex:=2;
    3: cbDataBits.ItemIndex:=3;
    4: cbDataBits.ItemIndex:=4;
    5: cbDataBits.ItemIndex:=5;
  end;

  case IniF.ReadInteger('TRX' + IntToStr(nTRX), 'Parity', 0) of
    0: cbParity.ItemIndex:=0;
    1: cbParity.ItemIndex:=1;
    2: cbParity.ItemIndex:=2;
    3: cbParity.ItemIndex:=3;
    4: cbParity.ItemIndex:=4;
    5: cbParity.ItemIndex:=5;
  end;

  case IniF.ReadInteger('TRX' + IntToStr(nTRX), 'HandShake', 0) of
    0: cbHandshake.ItemIndex:=0;
    1: cbHandshake.ItemIndex:=1;
    2: cbHandshake.ItemIndex:=2;
    3: cbHandshake.ItemIndex:=3;
  end;

  case IniF.ReadInteger('TRX' + IntToStr(nTRX), 'DTR', 0) of
    0: cbDTRstate.ItemIndex:=0;
    1: cbDTRstate.ItemIndex:=1;
    2: cbDTRstate.ItemIndex:=2;
    3: cbDTRstate.ItemIndex:=3;
  end;

  case IniF.ReadInteger('TRX' + IntToStr(nTRX), 'RTS', 0) of
    0: cbRTSstate.ItemIndex:=0;
    1: cbRTSstate.ItemIndex:=1;
    2: cbRTSstate.ItemIndex:=2;
    3: cbRTSstate.ItemIndex:=3;
  end;
end;

procedure TSettingsCAT.FormShow(Sender: TObject);
var
  dev:string;
begin
  cbCatPort.Items.CommaText:=GetSerialPortNames;
  cbManufacturer.Items.Clear;

    if RIG1.Checked then
    nTRX := 1
  else
    nTRX := 2;
  FileNameEdit1.Text:=IniF.ReadString('TRX' + IntToStr(nTRX), 'RigCtldPath', '');
  if (FileExistsUTF8(FileNameEdit1.Text)) then begin
  dev:=IniF.ReadString('TRX'+IntToStr(nTRX), 'model', '');
  dmFunc.LoadRigsToComboBox(dev,StringReplace(FileNameEdit1.Text,'rigctld','rigctl',[rfReplaceAll, rfIgnoreCase]),cbManufacturer);
  end
  else
  ShowMessage('Не найдена библиотека HamLib');
  LoadINI;
end;

procedure TSettingsCAT.RadioButton1Change(Sender: TObject);
begin
  if RIG1.Checked then
    nTRX := 1
  else
    nTRX := 2;
end;

procedure TSettingsCAT.RIG1Change(Sender: TObject);
begin
  if RIG1.Checked then
    nTRX := 1
  else
    nTRX := 2;
end;

procedure TSettingsCAT.Button1Click(Sender: TObject);
var
  model:string;
begin
  if RIG1.Checked then
    nTRX := 1
  else
    nTRX := 2;
  model := cbManufacturer.Text;
  delete(model,1,pos(' ',model));

  IniF.WriteString('TRX' + IntToStr(nTRX), 'RigCtldPath', FileNameEdit1.Text);
  IniF.WriteString('TRX' + IntToStr(nTRX), 'model', dmFunc.GetRigIdFromComboBoxItem(cbManufacturer.Text));
  IniF.WriteString('TRX' + IntToStr(nTRX), 'name', model);
  IniF.WriteString('TRX' + IntToStr(nTRX), 'device', cbCatPort.Text);
  IniF.WriteString('TRX' + IntToStr(nTRX), 'CiV', EditCIVaddress.Text);
  IniF.WriteInteger('TRX' + IntToStr(nTRX), 'Poll', SpinEdit1.Value);

  case cbBaudRate.ItemIndex of
    0: IniF.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '');
    1: IniF.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '1');
    2: IniF.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '2');
    3: IniF.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '3');
    4: IniF.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '4');
    5: IniF.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '5');
    6: IniF.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '6');
    7: IniF.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '7');
    8: IniF.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '8');
    9: IniF.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '9');
  end;

  case cbDataBits.ItemIndex of
    0: IniF.WriteString('TRX' + IntToStr(nTRX), 'DataBits', '');
    1: IniF.WriteString('TRX' + IntToStr(nTRX), 'DataBits', '1');
    2: IniF.WriteString('TRX' + IntToStr(nTRX), 'DataBits', '2');
    3: IniF.WriteString('TRX' + IntToStr(nTRX), 'DataBits', '3');
    4: IniF.WriteString('TRX' + IntToStr(nTRX), 'DataBits', '4');
    5: IniF.WriteString('TRX' + IntToStr(nTRX), 'DataBits', '5');
  end;

  case cbParity.ItemIndex of
    0: IniF.WriteString('TRX' + IntToStr(nTRX), 'Parity', '');
    1: IniF.WriteString('TRX' + IntToStr(nTRX), 'Parity', '1');
    2: IniF.WriteString('TRX' + IntToStr(nTRX), 'Parity', '2');
    3: IniF.WriteString('TRX' + IntToStr(nTRX), 'Parity', '3');
    4: IniF.WriteString('TRX' + IntToStr(nTRX), 'Parity', '4');
    5: IniF.WriteString('TRX' + IntToStr(nTRX), 'Parity', '5');
  end;

  case cbHandshake.ItemIndex of
    0: IniF.WriteString('TRX' + IntToStr(nTRX), 'HandShake', '');
    1: IniF.WriteString('TRX' + IntToStr(nTRX), 'HandShake', '1');
    2: IniF.WriteString('TRX' + IntToStr(nTRX), 'HandShake', '2');
    3: IniF.WriteString('TRX' + IntToStr(nTRX), 'HandShake', '3');
  end;

  case cbDTRstate.ItemIndex of
    0: IniF.WriteString('TRX' + IntToStr(nTRX), 'DTR', '');
    1: IniF.WriteString('TRX' + IntToStr(nTRX), 'DTR', '1');
    2: IniF.WriteString('TRX' + IntToStr(nTRX), 'DTR', '2');
    3: IniF.WriteString('TRX' + IntToStr(nTRX), 'DTR', '3');
  end;

  case cbRTSstate.ItemIndex of
    0: IniF.WriteString('TRX' + IntToStr(nTRX), 'RTS', '');
    1: IniF.WriteString('TRX' + IntToStr(nTRX), 'RTS', '1');
    2: IniF.WriteString('TRX' + IntToStr(nTRX), 'RTS', '2');
    3: IniF.WriteString('TRX' + IntToStr(nTRX), 'RTS', '3');
  end;
  SettingsCAT.Close;
end;

function TSettingsCAT.GetSerialPortNames: string;
begin
  {$IFDEF WINDOWS}
  Result:=synaser.GetSerialPortNames;
  {$ELSE}
  if fpAccess('/dev/ttyS0',W_OK)=0 then Result:=Result+',/dev/ttyS0';
  if fpAccess('/dev/ttyS1',W_OK)=0 then Result:=Result+',/dev/ttyS1';
  if fpAccess('/dev/ttyS2',W_OK)=0 then Result:=Result+',/dev/ttyS2';
  if fpAccess('/dev/ttyS3',W_OK)=0 then Result:=Result+',/dev/ttyS3';
  if fpAccess('/dev/ttyUSB0',W_OK)=0 then Result:=Result+',/dev/ttyUSB0';
  if fpAccess('/dev/ttyUSB1',W_OK)=0 then Result:=Result+',/dev/ttyUSB1';
  if fpAccess('/dev/ttyUSB2',W_OK)=0 then Result:=Result+',/dev/ttyUSB2';
  if fpAccess('/dev/ttyUSB3',W_OK)=0 then Result:=Result+',/dev/ttyUSB3';
  if fpAccess('/dev/ttyd0',W_OK)=0 then Result:=Result+',/dev/ttyd0';
  if fpAccess('/dev/ttyd1',W_OK)=0 then Result:=Result+',/dev/ttyd1';
  if fpAccess('/dev/ttyd2',W_OK)=0 then Result:=Result+',/dev/ttyd2';
  if fpAccess('/dev/ttyd3',W_OK)=0 then Result:=Result+',/dev/ttyd3';
  if fpAccess('/dev/cu.usbserial',W_OK)=0 then Result:=Result+',/dev/cu.usbserial';
  if fpAccess('/dev/tty.usbserial',W_OK)=0 then Result:=Result+',/dev/tty.usbserial';
  {$ENDIF}
end;

end.
