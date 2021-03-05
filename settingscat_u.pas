(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit SettingsCAT_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, Process,
  EditBtn, Spin, LazFileUtils, MainFuncDM, ResourceStr;

resourcestring
  rLibHamLibNotFound = 'HamLib library not found';

type

  { TSettingsCAT }

  TSettingsCAT = class(TForm)
    Button1: TButton;
    Button2: TButton;
    cbBaudRate: TComboBox;
    cbCatPort: TComboBox;
    cbDataBits: TComboBox;
    cbDTRstate: TComboBox;
    cbHandshake: TComboBox;
    cbManufacturer: TComboBox;
    cbParity: TComboBox;
    cbRTSstate: TComboBox;
    cbStopBits: TComboBox;
    CheckBox1: TCheckBox;
    EditAddress: TEdit;
    EditCMD: TEdit;
    EditCIVaddress: TEdit;
    FileNameEdit1: TFileNameEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label16: TLabel;
    LBExtraCMD: TLabel;
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
    procedure Button2Click(Sender: TObject);
    procedure cbManufacturerChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioButton1Change(Sender: TObject);
    procedure RIG1Change(Sender: TObject);
    procedure LoadINI;
    procedure ChangePortAddress;
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
  MainForm_U, dmFunc_U, TRXForm_U, InitDB_dm;

{$R *.lfm}

{ TSettingsCAT }

procedure TSettingsCAT.LoadINI;
begin
  cbCatPort.Text := INIFile.ReadString('TRX' + IntToStr(nTRX), 'device', '');
  EditCIVaddress.Text := INIFile.ReadString('TRX' + IntToStr(nTRX), 'CiV', '');
  SpinEdit1.Value := INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'Poll', 1);

  case INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'SerialSpeed', 0) of
    0: cbBaudRate.ItemIndex := 0;
    1: cbBaudRate.ItemIndex := 1;
    2: cbBaudRate.ItemIndex := 2;
    3: cbBaudRate.ItemIndex := 3;
    4: cbBaudRate.ItemIndex := 4;
    5: cbBaudRate.ItemIndex := 5;
    6: cbBaudRate.ItemIndex := 6;
    7: cbBaudRate.ItemIndex := 7;
    8: cbBaudRate.ItemIndex := 8;
    9: cbBaudRate.ItemIndex := 9;
  end;

  case INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'DataBits', 0) of
    0: cbDataBits.ItemIndex := 0;
    1: cbDataBits.ItemIndex := 1;
    2: cbDataBits.ItemIndex := 2;
    3: cbDataBits.ItemIndex := 3;
    4: cbDataBits.ItemIndex := 4;
    5: cbDataBits.ItemIndex := 5;
  end;

  case INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'Parity', 0) of
    0: cbParity.ItemIndex := 0;
    1: cbParity.ItemIndex := 1;
    2: cbParity.ItemIndex := 2;
    3: cbParity.ItemIndex := 3;
    4: cbParity.ItemIndex := 4;
    5: cbParity.ItemIndex := 5;
  end;

  case INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'HandShake', 0) of
    0: cbHandshake.ItemIndex := 0;
    1: cbHandshake.ItemIndex := 1;
    2: cbHandshake.ItemIndex := 2;
    3: cbHandshake.ItemIndex := 3;
  end;

  case INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'DTR', 0) of
    0: cbDTRstate.ItemIndex := 0;
    1: cbDTRstate.ItemIndex := 1;
    2: cbDTRstate.ItemIndex := 2;
    3: cbDTRstate.ItemIndex := 3;
  end;

  case INIFile.ReadInteger('TRX' + IntToStr(nTRX), 'RTS', 0) of
    0: cbRTSstate.ItemIndex := 0;
    1: cbRTSstate.ItemIndex := 1;
    2: cbRTSstate.ItemIndex := 2;
    3: cbRTSstate.ItemIndex := 3;
  end;
end;

procedure TSettingsCAT.FormShow(Sender: TObject);
begin
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
  model: string;
begin
  if RIG1.Checked then
    nTRX := 1
  else
    nTRX := 2;
  model := cbManufacturer.Text;
  Delete(model, 1, pos(' ', model));

  INIFile.WriteString('SetCAT', 'rigctldPath', FileNameEdit1.Text);
  IniSet.rigctldPath := FileNameEdit1.Text;
  INIFile.WriteString('SetCAT', 'rigctldExtra', EditCMD.Text);
  IniSet.rigctldExtra := EditCMD.Text;
  INIFile.WriteBool('SetCAT', 'rigctldStartUp', CheckBox1.Checked);
  IniSet.rigctldStartUp := CheckBox1.Checked;

  INIFile.WriteString('TRX' + IntToStr(nTRX), 'model',
    dmFunc.GetRigIdFromComboBoxItem(cbManufacturer.Text));
  INIFile.WriteString('TRX' + IntToStr(nTRX), 'name', model);
  INIFile.WriteString('TRX' + IntToStr(nTRX), 'device', cbCatPort.Text);
  INIFile.WriteString('TRX' + IntToStr(nTRX), 'CiV', EditCIVaddress.Text);
  INIFile.WriteInteger('TRX' + IntToStr(nTRX), 'Poll', SpinEdit1.Value);

  case cbBaudRate.ItemIndex of
    0: INIFile.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '');
    1: INIFile.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '1');
    2: INIFile.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '2');
    3: INIFile.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '3');
    4: INIFile.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '4');
    5: INIFile.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '5');
    6: INIFile.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '6');
    7: INIFile.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '7');
    8: INIFile.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '8');
    9: INIFile.WriteString('TRX' + IntToStr(nTRX), 'SerialSpeed', '9');
  end;

  case cbDataBits.ItemIndex of
    0: INIFile.WriteString('TRX' + IntToStr(nTRX), 'DataBits', '');
    1: INIFile.WriteString('TRX' + IntToStr(nTRX), 'DataBits', '1');
    2: INIFile.WriteString('TRX' + IntToStr(nTRX), 'DataBits', '2');
    3: INIFile.WriteString('TRX' + IntToStr(nTRX), 'DataBits', '3');
    4: INIFile.WriteString('TRX' + IntToStr(nTRX), 'DataBits', '4');
    5: INIFile.WriteString('TRX' + IntToStr(nTRX), 'DataBits', '5');
  end;

  case cbParity.ItemIndex of
    0: INIFile.WriteString('TRX' + IntToStr(nTRX), 'Parity', '');
    1: INIFile.WriteString('TRX' + IntToStr(nTRX), 'Parity', '1');
    2: INIFile.WriteString('TRX' + IntToStr(nTRX), 'Parity', '2');
    3: INIFile.WriteString('TRX' + IntToStr(nTRX), 'Parity', '3');
    4: INIFile.WriteString('TRX' + IntToStr(nTRX), 'Parity', '4');
    5: INIFile.WriteString('TRX' + IntToStr(nTRX), 'Parity', '5');
  end;

  case cbHandshake.ItemIndex of
    0: INIFile.WriteString('TRX' + IntToStr(nTRX), 'HandShake', '');
    1: INIFile.WriteString('TRX' + IntToStr(nTRX), 'HandShake', '1');
    2: INIFile.WriteString('TRX' + IntToStr(nTRX), 'HandShake', '2');
    3: INIFile.WriteString('TRX' + IntToStr(nTRX), 'HandShake', '3');
  end;

  case cbDTRstate.ItemIndex of
    0: INIFile.WriteString('TRX' + IntToStr(nTRX), 'DTR', '');
    1: INIFile.WriteString('TRX' + IntToStr(nTRX), 'DTR', '1');
    2: INIFile.WriteString('TRX' + IntToStr(nTRX), 'DTR', '2');
    3: INIFile.WriteString('TRX' + IntToStr(nTRX), 'DTR', '3');
  end;

  case cbRTSstate.ItemIndex of
    0: INIFile.WriteString('TRX' + IntToStr(nTRX), 'RTS', '');
    1: INIFile.WriteString('TRX' + IntToStr(nTRX), 'RTS', '1');
    2: INIFile.WriteString('TRX' + IntToStr(nTRX), 'RTS', '2');
    3: INIFile.WriteString('TRX' + IntToStr(nTRX), 'RTS', '3');
  end;
  TRXForm.InicializeRig;
end;

procedure TSettingsCAT.Button2Click(Sender: TObject);
begin
  SettingsCAT.Close;
end;

procedure TSettingsCAT.ChangePortAddress;
begin
  if (Pos('Hamlib NET rigctl', cbManufacturer.Text) > 0) or
    (Pos('FLRig', cbManufacturer.Text) > 0) then
  begin
    Label11.Caption := rAddress;
    EditAddress.Visible := True;
    cbCatPort.Visible := False;
  end
  else
  begin
    Label11.Caption := rCOMPort;
    EditAddress.Visible := False;
    cbCatPort.Visible := True;
  end;
end;

procedure TSettingsCAT.cbManufacturerChange(Sender: TObject);
begin
  ChangePortAddress;
end;

end.
