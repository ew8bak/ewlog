unit editqso_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DateTimePicker, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ComCtrls, EditBtn, Buttons, ExtCtrls, DBGrids, DBCtrls,
  InformationForm_U, sqldb, DB, RegExpr, Grids, resourcestr, prefix_record;

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
    Label8: TLabel;
    Label9: TLabel;
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
    UPDATE_Query: TSQLQuery;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);
    procedure SpeedButton12Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  EditQSO_Form: TEditQSO_Form;

implementation

uses MainForm_U, DXCCEditForm_U, QSLManagerForm_U,
  dmFunc_U, IOTA_Form_U, STATE_Form_U,
  ConfigForm_U, const_u, InitDB_dm, MainFuncDM;

{$R *.lfm}

{ TEditQSO_Form }

procedure TEditQSO_Form.SpeedButton11Click(Sender: TObject);
begin
  CheckForm := 'Edit';
  InformationForm.Show;
end;

procedure TEditQSO_Form.SpeedButton12Click(Sender: TObject);
begin
  QSLManager_Form.Show;
end;

procedure TEditQSO_Form.SpeedButton1Click(Sender: TObject);
begin
  // CountryEditForm.CountryQditQuery.DataBase := MainForm.ServiceDBConnection;
  CountryEditForm.CountryQditQuery.Close;
  CountryEditForm.CountryQditQuery.SQL.Clear;
  CountryEditForm.CountryQditQuery.SQL.Text := 'SELECT * FROM CountryDataEx';
  CountryEditForm.CountryQditQuery.Open;
  //MainForm.SQLServiceTransaction.Active := True;
  CountryEditForm.Caption := 'ARRLList';
  CountryEditForm.DBGrid1.DataSource.DataSet.Locate('ARRLPrefix', Edit7.Text, []);
  CountryEditForm.Show;
end;

procedure TEditQSO_Form.SpeedButton2Click(Sender: TObject);
begin
  // CountryEditForm.CountryQditQuery.DataBase := MainForm.ServiceDBConnection;

  CountryEditForm.CountryQditQuery.Close;
  CountryEditForm.CountryQditQuery.SQL.Clear;
  CountryEditForm.CountryQditQuery.SQL.Text := 'SELECT * FROM Province';
  CountryEditForm.CountryQditQuery.Open;
  //MainForm.SQLServiceTransaction.Active := True;
  CountryEditForm.Caption := 'Province';
  CountryEditForm.DBGrid1.DataSource.DataSet.Locate('Prefix', Edit8.Text, []);
  CountryEditForm.Show;
end;

procedure TEditQSO_Form.SpeedButton9Click(Sender: TObject);
begin
  IOTA_Form.Show;
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
  FmtStngs: TFormatSettings;
  DigiBand: double;
  ind: integer;
  FREQ_string: string;
  NameBand: string;
begin
  FmtStngs.TimeSeparator := ':';
  FmtStngs.LongTimeFormat := 'hh:nn';
  FREQ_string := ComboBox1.Text;
  Delete(FREQ_string, length(FREQ_string) - 2, 1);
  DigiBand := dmFunc.GetDigiBandFromFreq(FREQ_string);

  ind := MainForm.DBGrid1.DataSource.DataSet.RecNo;
  with UPDATE_Query do
  begin
    Close;
    SQL.Clear;
    SQL.Add('UPDATE ' + LBRecord.LogTable +
      ' SET `CallSign`=:CallSign, `QSODate`=:QSODate, `QSOTime`=:QSOTime, `QSOBand`=:QSOBand, `QSOMode`=:QSOMode,`QSOSubMode`=:QSOSubMode, `QSOReportSent`=:QSOReportSent, `QSOReportRecived`=:QSOReportRecived, `OMName`=:OMName, `OMQTH`=:OMQTH, `State`=:State, `Grid`=:Grid, `IOTA`=:IOTA, `QSLManager`=:QSLManager, `QSLSent`=:QSLSent, `QSLSentAdv`=:QSLSentAdv, `QSLSentDate`=:QSLSentDate, `QSLRec`=:QSLRec, `QSLRecDate`=:QSLRecDate, `MainPrefix`=:MainPrefix, `DXCCPrefix`=:DXCCPrefix, `CQZone`=:CQZone, `ITUZone`=:ITUZone, `QSOAddInfo`=:QSOAddInfo, `Marker`=:Marker, `ManualSet`=:ManualSet, `DigiBand`=:DigiBand, `Continent`=:Continent, `ShortNote`=:ShortNote, `QSLReceQSLcc`=:QSLReceQSLcc, `LoTWRec`=:LoTWRec, `LoTWRecDate`=:LoTWRecDate, `QSLInfo`=:QSLInfo, `Call`=:Call, `State1`=:State1, `State2`=:State2, `State3`=:State3, `State4`=:State4, `WPX`=:WPX, `ValidDX`=:ValidDX, `SRX`=:SRX, `SRX_STRING`=:SRX_STRING, `STX`=:STX, `STX_STRING`=:STX_STRING, `SAT_NAME`=:SAT_NAME, `SAT_MODE`=:SAT_MODE, `PROP_MODE`=:PROP_MODE, `LoTWSent`=:LoTWSent, `QSL_RCVD_VIA`=:QSL_RCVD_VIA, `QSL_SENT_VIA`=:QSL_SENT_VIA, `DXCC`=:DXCC, `NoCalcDXCC`=:NoCalcDXCC WHERE `UnUsedIndex`=:UnUsedIndex');
    Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
    Params.ParamByName('CallSign').AsString := Edit1.Text;
    Params.ParamByName('QSODate').AsDateTime := DateEdit1.Date;
    Params.ParamByName('QSOTime').AsString := TimeToStr(DateTimePicker1.Time, FmtStngs);

    if Pos('M', ComboBox1.Text) > 0 then
      NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(
        ComboBox1.Text, ComboBox2.Text))
    else
      NameBand := ComboBox1.Text;

    Params.ParamByName('QSOBand').AsString := NameBand;

    Params.ParamByName('QSOMode').AsString := ComboBox2.Text;
    Params.ParamByName('QSOSubMode').AsString := ComboBox9.Text;
    Params.ParamByName('QSOReportSent').AsString := Edit2.Text;
    Params.ParamByName('QSOReportRecived').AsString := Edit3.Text;
    Params.ParamByName('OMName').AsString := Edit4.Text;
    Params.ParamByName('OMQTH').AsString := Edit5.Text;
    Params.ParamByName('State').AsString := Edit17.Text;
    Params.ParamByName('Grid').AsString := Edit14.Text;
    Params.ParamByName('IOTA').AsString := Edit18.Text;
    Params.ParamByName('QSLManager').AsString := Edit19.Text;
    Params.ParamByName('QSLSent').AsBoolean := RadioButton1.Checked;

    if RadioButton1.Checked = True then
      Params.ParamByName('QSLSentAdv').AsString := 'T';
    if RadioButton2.Checked = True then
      Params.ParamByName('QSLSentAdv').AsString := 'P';
    if RadioButton3.Checked = True then
      Params.ParamByName('QSLSentAdv').AsString := 'Q';
    if RadioButton4.Checked = True then
      Params.ParamByName('QSLSentAdv').AsString := 'F';
    if RadioButton5.Checked = True then
      Params.ParamByName('QSLSentAdv').AsString := 'N';

    if DateEdit3.Text <> '' then
      Params.ParamByName('QSLSentDate').AsDate := DateEdit3.Date
    else
      Params.ParamByName('QSLSentDate').IsNull;

    Params.ParamByName('QSLRec').AsBoolean := CheckBox4.Checked;

    if DateEdit2.Text <> '' then
      Params.ParamByName('QSLRecDate').AsDate := DateEdit2.Date
    else
      Params.ParamByName('QSLRecDate').IsNull;

    Params.ParamByName('DXCC').AsString := Edit6.Text;
    Params.ParamByName('DXCCPrefix').AsString := Edit7.Text;
    Params.ParamByName('CQZone').AsString := Edit15.Text;
    Params.ParamByName('ITUZone').AsString := Edit16.Text;
    Params.ParamByName('QSOAddInfo').AsString := Memo1.Text;
    Params.ParamByName('Marker').AsBoolean := CheckBox3.Checked;
    Params.ParamByName('ManualSet').AsBoolean := False;

    Params.ParamByName('DigiBand').AsString := FloatToStr(DigiBand);

    Params.ParamByName('Continent').AsString := Edit13.Text;
    Params.ParamByName('ShortNote').AsString := Memo1.Text;
    Params.ParamByName('QSLReceQSLcc').AsBoolean := CheckBox5.Checked;
    Params.ParamByName('LoTWRec').AsBoolean := CheckBox6.Checked;

    if DateEdit4.Text <> '' then
      Params.ParamByName('LoTWRecDate').AsDate := DateEdit4.Date
    else
      Params.ParamByName('LoTWRecDate').IsNull;

    Params.ParamByName('QSLInfo').AsString := Edit20.Text;
    Params.ParamByName('Call').AsString := Edit1.Text;
    Params.ParamByName('State1').AsString := Edit10.Text;
    Params.ParamByName('State2').AsString := Edit9.Text;
    Params.ParamByName('State3').AsString := Edit11.Text;
    Params.ParamByName('State4').AsString := Edit12.Text;
    Params.ParamByName('WPX').AsString := Edit8.Text;
    Params.ParamByName('ValidDX').AsBoolean := CheckBox2.Checked;
    Params.ParamByName('SRX').IsNull;
    Params.ParamByName('SRX_STRING').AsString := '';
    Params.ParamByName('STX').IsNull;
    Params.ParamByName('STX_STRING').AsString := '';
    Params.ParamByName('SAT_NAME').AsString := DBLookupComboBox2.Text;
    Params.ParamByName('SAT_MODE').AsString := ComboBox4.Text;
    Params.ParamByName('PROP_MODE').AsString := ComboBox3.Text;

    Params.ParamByName('LoTWSent').AsBoolean := CheckBox7.Checked;

    if ComboBox6.Text <> '' then
      Params.ParamByName('QSL_RCVD_VIA').AsString := ComboBox6.Text[1]
    else
      Params.ParamByName('QSL_RCVD_VIA').IsNull;
    if ComboBox7.Text <> '' then
      Params.ParamByName('QSL_SENT_VIA').AsString := ComboBox7.Text[1]
    else
      Params.ParamByName('QSL_SENT_VIA').IsNull;
    Params.ParamByName('NoCalcDXCC').AsBoolean := CheckBox1.Checked;
    Params.ParamByName('MainPrefix').AsString := Edit8.Text;
    ExecSQL;
  end;
  InitDB.DefTransaction.Commit;
  MainForm.SelDB(CallLogBook);
  MainForm.DBGrid1.DataSource.DataSet.RecNo := ind;

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
  MainFunc.DrawColumnGrid(MainForm.LOGBookDS.DataSet, Rect, DataCol, Column, State, DBGrid1);
end;

procedure TEditQSO_Form.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Edit1.Text := '';
end;

procedure TEditQSO_Form.FormCreate(Sender: TObject);
begin

end;

procedure TEditQSO_Form.FormShow(Sender: TObject);
var
  i: integer;
begin
  MainFunc.LoadBMSL(ComboBox2, ComboBox9, ComboBox1);
  MainFunc.SetGrid(DBGrid1);

  if DBRecord.InitDB = 'YES' then
  begin
    SatPropQuery.DataBase := InitDB.ServiceDBConnection;
    if DBRecord.CurrentDB = 'MySQL' then
    begin
      UPDATE_Query.DataBase := InitDB.MySQLConnection;
    end
    else
    begin
      UPDATE_Query.DataBase := InitDB.SQLiteConnection;
    end;
  end;

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

  Button4.Click;
  Edit1.SetFocus;

end;

procedure TEditQSO_Form.SpeedButton10Click(Sender: TObject);
begin
  STATE_Form.Show;
end;

end.
