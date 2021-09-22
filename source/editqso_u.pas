(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit editqso_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DateTimePicker, Forms, Controls,
  Dialogs, StdCtrls, ComCtrls, EditBtn, Buttons, DBGrids, DBCtrls,
  InformationForm_U, sqldb, Grids, prefix_record, qso_record;

type

  { TEditQSO_Form }

  TEditQSO_Form = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox6: TComboBox;
    ComboBox7: TComboBox;
    ComboBox9: TComboBox;
    DateEdit1: TDateEdit;
    DateEdit2: TDateEdit;
    DateEdit3: TDateEdit;
    DateEdit4: TDateEdit;
    DateTimePicker1: TDateTimePicker;
    DBGrid1: TDBGrid;
    DBLookupComboBox2: TDBLookupComboBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    Edit2: TEdit;
    Edit20: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    SpeedButton1: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    SatPropQuery: TSQLQuery;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);
    procedure SpeedButton12Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
  private
    function SearchCountry(CallSign: string): string;
    { private declarations }
  public
    { public declarations }
  end;

var
  EditQSO_Form: TEditQSO_Form;

implementation

uses miniform_u, DXCCEditForm_U, QSLManagerForm_U,
  dmFunc_U, IOTA_Form_U, STATE_Form_U,
  InitDB_dm, MainFuncDM, GridsForm_u;

{$R *.lfm}

{ TEditQSO_Form }

function TEditQSO_Form.SearchCountry(CallSign: string): string;
var
  PFXR: TPFXR;
begin
  Result := '';
  if Length(CallSign) > 0 then
  begin
    PFXR := MainFunc.SearchPrefix(CallSign, '');
    Result := PFXR.Country;
  end;
end;

procedure TEditQSO_Form.SpeedButton11Click(Sender: TObject);
begin
  InformationForm.FromForm := 'EditForm';
  InformationForm.Callsign := dmFunc.ExtractCallsign(Edit1.Text);
  InformationForm.ShowModal;
end;

procedure TEditQSO_Form.SpeedButton12Click(Sender: TObject);
begin
  QSLManager_Form.ShowModal;
end;

procedure TEditQSO_Form.SpeedButton1Click(Sender: TObject);
begin
  CountryEditForm.CountryQditQuery.DataBase := InitDB.ServiceDBConnection;
  CountryEditForm.CountryQditQuery.Close;
  CountryEditForm.CountryQditQuery.SQL.Clear;
  CountryEditForm.CountryQditQuery.SQL.Text := 'SELECT * FROM CountryDataEx';
  CountryEditForm.CountryQditQuery.Open;
  //MainForm.SQLServiceTransaction.Active := True;
  CountryEditForm.Caption := 'ARRLList';
  CountryEditForm.DBGrid1.DataSource.DataSet.Locate('ARRLPrefix', Edit7.Text, []);
  CountryEditForm.ShowModal;
end;

procedure TEditQSO_Form.SpeedButton2Click(Sender: TObject);
begin
  CountryEditForm.CountryQditQuery.DataBase := InitDB.ServiceDBConnection;

  CountryEditForm.CountryQditQuery.Close;
  CountryEditForm.CountryQditQuery.SQL.Clear;
  CountryEditForm.CountryQditQuery.SQL.Text := 'SELECT * FROM Province';
  CountryEditForm.CountryQditQuery.Open;
  //MainForm.SQLServiceTransaction.Active := True;
  CountryEditForm.Caption := 'Province';
  CountryEditForm.DBGrid1.DataSource.DataSet.Locate('Prefix', Edit8.Text, []);
  CountryEditForm.ShowModal;
end;

procedure TEditQSO_Form.SpeedButton9Click(Sender: TObject);
begin
  IOTA_Form.ShowModal;
end;

procedure TEditQSO_Form.Button1Click(Sender: TObject);
begin
  EditQSO_Form.Close;
end;

procedure TEditQSO_Form.Button2Click(Sender: TObject);
begin
  EditQSO_Form.Close;
end;

procedure TEditQSO_Form.Button3Click(Sender: TObject);
var
  UQSO: TQSO;
  FmtStngs: TFormatSettings;
  NameBand: string;
  DigiBand: double;
begin
  FmtStngs.TimeSeparator := ':';
  FmtStngs.LongTimeFormat := 'hh:nn';

  NameBand := MainFunc.ConvertFreqToSave(ComboBox1.Text);
  DigiBand := dmFunc.GetDigiBandFromFreq(NameBand);

  UQSO.CallSing := Edit1.Text;
  UQSO.QSODate := DateEdit1.Date;
  UQSO.QSOTime := TimeToStr(DateTimePicker1.Time, FmtStngs);
  UQSO.QSOBand := NameBand;
  UQSO.QSOMode := ComboBox2.Text;
  UQSO.QSOSubMode := ComboBox9.Text;
  UQSO.QSOReportSent := Edit2.Text;
  UQSO.QSOReportRecived := Edit3.Text;
  UQSO.OMName := Edit4.Text;
  UQSO.OMQTH := Edit5.Text;
  UQSO.State0 := Edit17.Text;
  UQSO.Grid := Edit14.Text;
  UQSO.IOTA := Edit18.Text;
  UQSO.QSLManager := Edit19.Text;
  UQSO.QSLSent := BoolToStr(RadioButton1.Checked, '1', '0');
  if RadioButton1.Checked = True then
    UQSO.QSLSentAdv := 'T';
  if RadioButton2.Checked = True then
    UQSO.QSLSentAdv := 'P';
  if RadioButton3.Checked = True then
    UQSO.QSLSentAdv := 'Q';
  if RadioButton4.Checked = True then
    UQSO.QSLSentAdv := 'F';
  if RadioButton5.Checked = True then
    UQSO.QSLSentAdv := 'N';
  UQSO.QSLSentDate := DateEdit3.Date;
  UQSO.QSLRec := BoolToStr(CheckBox4.Checked, '1', '0');
  UQSO.QSLRecDate := DateEdit2.Date;
  UQSO.DXCC := Edit6.Text;
  UQSO.DXCCPrefix := Edit7.Text;
  UQSO.CQZone := Edit15.Text;
  UQSO.ITUZone := Edit16.Text;
  UQSO.QSOAddInfo := Memo1.Text;
  UQSO.Marker := BoolToStr(CheckBox3.Checked, '1', '0');
  UQSO.ManualSet := 0;
  UQSO.DigiBand := StringReplace(FloatToStr(DigiBand), ',', '.', [rfReplaceAll]);
  UQSO.Continent := Edit13.Text;
  UQSO.ShortNote := Memo1.Text;
  UQSO.QSLReceQSLcc := 0;
  if CheckBox5.Checked then
    UQSO.QSLReceQSLcc := 1;
  UQSO.LoTWRec := BoolToStr(CheckBox6.Checked, '1', '0');
  UQSO.LoTWRecDate := DateEdit4.Date;
  UQSO.QSLInfo := Edit20.Text;
  UQSO.Call := Edit1.Text;
  UQSO.State1 := Edit10.Text;
  UQSO.State2 := Edit9.Text;
  UQSO.State3 := Edit11.Text;
  UQSO.State4 := Edit12.Text;
  UQSO.WPX := Edit8.Text;
  UQSO.ValidDX := BoolToStr(CheckBox2.Checked, '1', '0');
  UQSO.SRX := 0;
  UQSO.SRX_STRING := '';
  UQSO.STX := 0;
  UQSO.STX_STRING := '';
  UQSO.SAT_NAME := DBLookupComboBox2.Text;
  UQSO.SAT_MODE := ComboBox4.Text;
  UQSO.PROP_MODE := ComboBox3.Text;
  UQSO.LoTWSent := 0;
  if CheckBox7.Checked then
    UQSO.LoTWSent := 1;
  UQSO.NoCalcDXCC := 0;
  if CheckBox1.Checked then
    UQSO.NoCalcDXCC := 1;
  UQSO.MainPrefix := Edit8.Text;
  UQSO.QSL_RCVD_VIA := 'NULL';
  UQSO.QSL_SENT_VIA := 'NULL';
  if ComboBox6.Text <> '' then
    UQSO.QSL_RCVD_VIA := ComboBox6.Text[1];
  if ComboBox7.Text <> '' then
    UQSO.QSL_SENT_VIA := ComboBox7.Text[1];
  MainFunc.UpdateEditQSO(UnUsIndex, UQSO);
  MainFunc.CurrPosGrid(GridRecordIndex, GridsForm.DBGrid1);
end;

procedure TEditQSO_Form.Button4Click(Sender: TObject);
var
  PFXR: TPFXR;
begin
  if Length(Edit1.Text) > 0 then
  begin
    PFXR := MainFunc.SearchPrefix(Edit1.Text, Edit14.Text);
    GroupBox1.Caption := PFXR.Country;
    Edit7.Text := PFXR.ARRLPrefix;
    Edit8.Text := PFXR.Prefix;
    Edit15.Text := PFXR.CQZone;
    Edit16.Text := PFXR.ITUZone;
    Edit13.Text := PFXR.Continent;
    Edit6.Text := IntToStr(PFXR.DXCCNum);
  end;
end;

procedure TEditQSO_Form.ComboBox1Select(Sender: TObject);
begin
  ComboBox1.Text := MainFunc.ConvertFreqToShow(
    ComboBox1.Items.Strings[ComboBox1.ItemIndex]);
end;

procedure TEditQSO_Form.ComboBox2Change(Sender: TObject);
var
  i: integer;
begin
  ComboBox9.Items.Clear;
  for i := 0 to High(MainFunc.LoadSubModes(ComboBox2.Text)) do
    ComboBox9.Items.Add(MainFunc.LoadSubModes(ComboBox2.Text)[i]);
end;

procedure TEditQSO_Form.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: integer; Column: TColumn; State: TGridDrawState);
begin
  MainFunc.DrawColumnGrid(GridsForm.LOGBookDS.DataSet, Rect, DataCol,
    Column, State, DBGrid1);
end;

procedure TEditQSO_Form.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Edit1.Text := '';
end;

procedure TEditQSO_Form.FormShow(Sender: TObject);
var
  i: integer;
  SelQSO: TQSO;
begin
  GroupBox1.Height := CheckBox1.Top + 40;
  MainFunc.LoadBMSL(ComboBox2, ComboBox9, ComboBox1);
  MainFunc.SetGrid(DBGrid1);

  SelQSO := MainFunc.SelectEditQSO(UnUsIndex);
  Edit1.Text := SelQSO.CallSing;
  DateEdit1.Date := SelQSO.QSODate;
  DateTimePicker1.Time := StrToTime(SelQSO.QSOTime);
  Edit4.Text := SelQSO.OMName;
  Edit5.Text := SelQSO.OMQTH;
  Edit17.Text := SelQSO.State0;
  Edit14.Text := SelQSO.Grid;
  Edit2.Text := SelQSO.QSOReportSent;
  Edit3.Text := SelQSO.QSOReportRecived;
  Edit18.Text := SelQSO.IOTA;
  DateEdit3.Date := SelQSO.QSLSentDate;
  DateEdit2.Date := SelQSO.QSLRecDate;
  DateEdit4.Date := SelQSO.LoTWRecDate;
  Edit8.Text := SelQSO.MainPrefix;
  Edit7.Text := SelQSO.DXCCPrefix;
  Edit6.Text := SelQSO.DXCC;
  Edit15.Text := SelQSO.CQZone;
  Edit16.Text := SelQSO.ITUZone;
  CheckBox3.Checked := MainFunc.StringToBool(SelQSO.Marker);
  ComboBox2.Text := SelQSO.QSOMode;
  ComboBox9.Text := SelQSO.QSOSubMode;
  ComboBox1.Text := SelQSO.QSOBand;
  Edit13.Text := SelQSO.Continent;
  Edit20.Text := SelQSO.QSLInfo;
  CheckBox2.Checked := MainFunc.StringToBool(SelQSO.ValidDX);
  Edit19.Text := SelQSO.QSLManager;
  Edit10.Text := SelQSO.State1;
  Edit9.Text := SelQSO.State2;
  Edit11.Text := SelQSO.State3;
  Edit12.Text := SelQSO.State4;
  Memo1.Text := SelQSO.QSOAddInfo;
  CheckBox1.Checked := MainFunc.IntToBool(SelQSO.NoCalcDXCC);
  CheckBox5.Checked := MainFunc.IntToBool(SelQSO.QSLReceQSLcc);
  CheckBox4.Checked := MainFunc.StringToBool(SelQSO.QSLRec);
  CheckBox6.Checked := MainFunc.StringToBool(SelQSO.LoTWRec);
  CheckBox7.Checked := MainFunc.IntToBool(SelQSO.LoTWSent);
  ComboBox3.Text := SelQSO.PROP_MODE;

  case SelQSO.QSL_RCVD_VIA of
    '': ComboBox6.ItemIndex := 0;
    'B': ComboBox6.ItemIndex := 1;
    'D': ComboBox6.ItemIndex := 2;
    'E': ComboBox6.ItemIndex := 3;
    'M': ComboBox6.ItemIndex := 4;
    'G': ComboBox6.ItemIndex := 5;
  end;

  case SelQSO.QSL_SENT_VIA of
    '': ComboBox6.ItemIndex := 0;
    'B': ComboBox6.ItemIndex := 1;
    'D': ComboBox6.ItemIndex := 2;
    'E': ComboBox6.ItemIndex := 3;
    'M': ComboBox6.ItemIndex := 4;
    'G': ComboBox6.ItemIndex := 5;
  end;

  case SelQSO.QSLSentAdv of
    'P': RadioButton2.Checked := True;
    'T': RadioButton1.Checked := True;
    'Q': RadioButton3.Checked := True;
    'F': RadioButton4.Checked := True;
    'N': RadioButton5.Checked := True;
  end;

  if DBRecord.InitDB = 'YES' then
    SatPropQuery.DataBase := InitDB.ServiceDBConnection;

  if ComboBox2.Text <> '' then
    ComboBox2Change(Self);
  ComboBox3.Items.Clear;
  SatPropQuery.SQL.Text := 'SELECT * FROM PropMode';
  SatPropQuery.Open;
  SatPropQuery.First;
  for i := 0 to SatPropQuery.RecordCount - 1 do
  begin
    ComboBox3.Items.Add(SatPropQuery.FieldByName('Type').AsString);
    SatPropQuery.Next;
  end;
  SatPropQuery.Close;

  GroupBox1.Caption := SearchCountry(Edit1.Text);
end;

procedure TEditQSO_Form.SpeedButton10Click(Sender: TObject);
begin
  STATE_Form.ShowModal;
end;

end.
