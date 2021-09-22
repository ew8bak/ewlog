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
    BtClose: TButton;
    BtCancel: TButton;
    BtApply: TButton;
    Button4: TButton;
    CBNoCalcDXCC: TCheckBox;
    CBValidDXCC: TCheckBox;
    CBMarkQSO: TCheckBox;
    CBReceived: TCheckBox;
    CBReceivedEQSL: TCheckBox;
    CBReceivedLoTW: TCheckBox;
    CBSentLoTW: TCheckBox;
    CBBand: TComboBox;
    CBMode: TComboBox;
    CBPropagation: TComboBox;
    CBSATMode: TComboBox;
    ComboBox6: TComboBox;
    ComboBox7: TComboBox;
    CBSubMode: TComboBox;
    DEDate: TDateEdit;
    DateEdit2: TDateEdit;
    DateEdit3: TDateEdit;
    DateEdit4: TDateEdit;
    DTTime: TDateTimePicker;
    DBGrid1: TDBGrid;
    DBLookupComboBox2: TDBLookupComboBox;
    EditCallSign: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    EditContinent: TEdit;
    EditGrid: TEdit;
    EditCQ: TEdit;
    EditITU: TEdit;
    EditState: TEdit;
    EditIOTA: TEdit;
    Edit19: TEdit;
    EditRSTs: TEdit;
    Edit20: TEdit;
    EditRSTr: TEdit;
    EditName: TEdit;
    EditQTH: TEdit;
    EditDXCC: TEdit;
    Edit7: TEdit;
    EditPrefix: TEdit;
    Edit9: TEdit;
    GBCallInfo: TGroupBox;
    GBQSLReceived: TGroupBox;
    GBQSLSent: TGroupBox;
    LBCallsign: TLabel;
    LBDXCC: TLabel;
    LBPrefix: TLabel;
    LBCQ: TLabel;
    LBITU: TLabel;
    LBGrid: TLabel;
    LbSubState: TLabel;
    LBContinent: TLabel;
    LBMode: TLabel;
    LBBand: TLabel;
    LBState: TLabel;
    LBDate: TLabel;
    LBIOTA: TLabel;
    LBSatelite: TLabel;
    LBSATMode: TLabel;
    LBPropagation: TLabel;
    LBRecVia: TLabel;
    LBQSLManager: TLabel;
    LBQSLSentVia: TLabel;
    LBQSLInfo: TLabel;
    LBRSTs: TLabel;
    LBRSTr: TLabel;
    LBName: TLabel;
    LBQTH: TLabel;
    LBNote: TLabel;
    MemoNote: TMemo;
    PageControl1: TPageControl;
    RBSent: TRadioButton;
    RBPrinted: TRadioButton;
    RBQueued: TRadioButton;
    RBWSent: TRadioButton;
    RBDSent: TRadioButton;
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
    procedure BtCloseClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtApplyClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CBBandSelect(Sender: TObject);
    procedure CBModeChange(Sender: TObject);
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
  InformationForm.Callsign := dmFunc.ExtractCallsign(EditCallSign.Text);
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
  CountryEditForm.Caption := 'Province';
  CountryEditForm.DBGrid1.DataSource.DataSet.Locate('Prefix', EditPrefix.Text, []);
  CountryEditForm.ShowModal;
end;

procedure TEditQSO_Form.SpeedButton9Click(Sender: TObject);
begin
  IOTA_Form.ShowModal;
end;

procedure TEditQSO_Form.BtCloseClick(Sender: TObject);
begin
  EditQSO_Form.Close;
end;

procedure TEditQSO_Form.BtCancelClick(Sender: TObject);
begin
  EditQSO_Form.Close;
end;

procedure TEditQSO_Form.BtApplyClick(Sender: TObject);
var
  UQSO: TQSO;
  FmtStngs: TFormatSettings;
  NameBand: string;
  DigiBand: double;
begin
  FmtStngs.TimeSeparator := ':';
  FmtStngs.LongTimeFormat := 'hh:nn';

  NameBand := MainFunc.ConvertFreqToSave(CBBand.Text);
  DigiBand := dmFunc.GetDigiBandFromFreq(NameBand);

  UQSO.CallSing := EditCallSign.Text;
  UQSO.QSODate := DEDate.Date;
  UQSO.QSOTime := TimeToStr(DTTime.Time, FmtStngs);
  UQSO.QSOBand := NameBand;
  UQSO.QSOMode := CBMode.Text;
  UQSO.QSOSubMode := CBSubMode.Text;
  UQSO.QSOReportSent := EditRSTs.Text;
  UQSO.QSOReportRecived := EditRSTr.Text;
  UQSO.OMName := EditName.Text;
  UQSO.OMQTH := EditQTH.Text;
  UQSO.State0 := EditState.Text;
  UQSO.Grid := EditGrid.Text;
  UQSO.IOTA := EditIOTA.Text;
  UQSO.QSLManager := Edit19.Text;
  UQSO.QSLSent := BoolToStr(RBSent.Checked, '1', '0');
  if RBSent.Checked = True then
    UQSO.QSLSentAdv := 'T';
  if RBPrinted.Checked = True then
    UQSO.QSLSentAdv := 'P';
  if RBQueued.Checked = True then
    UQSO.QSLSentAdv := 'Q';
  if RBWSent.Checked = True then
    UQSO.QSLSentAdv := 'F';
  if RBDSent.Checked = True then
    UQSO.QSLSentAdv := 'N';
  UQSO.QSLSentDate := DateEdit3.Date;
  UQSO.QSLRec := BoolToStr(CBReceived.Checked, '1', '0');
  UQSO.QSLRecDate := DateEdit2.Date;
  UQSO.DXCC := EditDXCC.Text;
  UQSO.DXCCPrefix := Edit7.Text;
  UQSO.CQZone := EditCQ.Text;
  UQSO.ITUZone := EditITU.Text;
  UQSO.QSOAddInfo := MemoNote.Text;
  UQSO.Marker := BoolToStr(CBMarkQSO.Checked, '1', '0');
  UQSO.ManualSet := 0;
  UQSO.DigiBand := StringReplace(FloatToStr(DigiBand), ',', '.', [rfReplaceAll]);
  UQSO.Continent := EditContinent.Text;
  UQSO.ShortNote := MemoNote.Text;
  UQSO.QSLReceQSLcc := 0;
  if CBReceivedEQSL.Checked then
    UQSO.QSLReceQSLcc := 1;
  UQSO.LoTWRec := BoolToStr(CBReceivedLoTW.Checked, '1', '0');
  UQSO.LoTWRecDate := DateEdit4.Date;
  UQSO.QSLInfo := Edit20.Text;
  UQSO.Call := EditCallSign.Text;
  UQSO.State1 := Edit10.Text;
  UQSO.State2 := Edit9.Text;
  UQSO.State3 := Edit11.Text;
  UQSO.State4 := Edit12.Text;
  UQSO.WPX := EditPrefix.Text;
  UQSO.ValidDX := BoolToStr(CBValidDXCC.Checked, '1', '0');
  UQSO.SRX := 0;
  UQSO.SRX_STRING := '';
  UQSO.STX := 0;
  UQSO.STX_STRING := '';
  UQSO.SAT_NAME := DBLookupComboBox2.Text;
  UQSO.SAT_MODE := CBSATMode.Text;
  UQSO.PROP_MODE := CBPropagation.Text;
  UQSO.LoTWSent := 0;
  if CBSentLoTW.Checked then
    UQSO.LoTWSent := 1;
  UQSO.NoCalcDXCC := 0;
  if CBNoCalcDXCC.Checked then
    UQSO.NoCalcDXCC := 1;
  UQSO.MainPrefix := EditPrefix.Text;
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
  if Length(EditCallSign.Text) > 0 then
  begin
    PFXR := MainFunc.SearchPrefix(EditCallSign.Text, EditGrid.Text);
    GBCallInfo.Caption := PFXR.Country;
    Edit7.Text := PFXR.ARRLPrefix;
    EditPrefix.Text := PFXR.Prefix;
    EditCQ.Text := PFXR.CQZone;
    EditITU.Text := PFXR.ITUZone;
    EditContinent.Text := PFXR.Continent;
    EditDXCC.Text := IntToStr(PFXR.DXCCNum);
  end;
end;

procedure TEditQSO_Form.CBBandSelect(Sender: TObject);
begin
  CBBand.Text := MainFunc.ConvertFreqToShow(
    CBBand.Items.Strings[CBBand.ItemIndex]);
end;

procedure TEditQSO_Form.CBModeChange(Sender: TObject);
var
  i: integer;
begin
  CBSubMode.Items.Clear;
  for i := 0 to High(MainFunc.LoadSubModes(CBMode.Text)) do
    CBSubMode.Items.Add(MainFunc.LoadSubModes(CBMode.Text)[i]);
end;

procedure TEditQSO_Form.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: integer; Column: TColumn; State: TGridDrawState);
begin
  MainFunc.DrawColumnGrid(GridsForm.LOGBookDS.DataSet, Rect, DataCol,
    Column, State, DBGrid1);
end;

procedure TEditQSO_Form.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  EditCallSign.Text := '';
end;

procedure TEditQSO_Form.FormShow(Sender: TObject);
var
  i: integer;
  SelQSO: TQSO;
begin
  GBCallInfo.Height := CBNoCalcDXCC.Height + CBNoCalcDXCC.Top + 20;
  PageControl1.Height:= Edit20.Top + Edit20.Height + 30;
  EditQSO_Form.Height := PageControl1.Height + PageControl1.Top + BtClose.Height + 10;

  GBQSLReceived.Height:= DateEdit4.Top + DateEdit4.Height + 20;
  GBQSLSent.Height := GBQSLReceived.Height;

  MainFunc.LoadBMSL(CBMode, CBSubMode, CBBand);
  MainFunc.SetGrid(DBGrid1);

  SelQSO := MainFunc.SelectEditQSO(UnUsIndex);
  EditCallSign.Text := SelQSO.CallSing;
  DEDate.Date := SelQSO.QSODate;
  DTTime.Time := StrToTime(SelQSO.QSOTime);
  EditName.Text := SelQSO.OMName;
  EditQTH.Text := SelQSO.OMQTH;
  EditState.Text := SelQSO.State0;
  EditGrid.Text := SelQSO.Grid;
  EditRSTs.Text := SelQSO.QSOReportSent;
  EditRSTr.Text := SelQSO.QSOReportRecived;
  EditIOTA.Text := SelQSO.IOTA;
  DateEdit3.Date := SelQSO.QSLSentDate;
  DateEdit2.Date := SelQSO.QSLRecDate;
  DateEdit4.Date := SelQSO.LoTWRecDate;
  EditPrefix.Text := SelQSO.MainPrefix;
  Edit7.Text := SelQSO.DXCCPrefix;
  EditDXCC.Text := SelQSO.DXCC;
  EditCQ.Text := SelQSO.CQZone;
  EditITU.Text := SelQSO.ITUZone;
  CBMarkQSO.Checked := MainFunc.StringToBool(SelQSO.Marker);
  CBMode.Text := SelQSO.QSOMode;
  CBSubMode.Text := SelQSO.QSOSubMode;
  CBBand.Text := SelQSO.QSOBand;
  EditContinent.Text := SelQSO.Continent;
  Edit20.Text := SelQSO.QSLInfo;
  CBValidDXCC.Checked := MainFunc.StringToBool(SelQSO.ValidDX);
  Edit19.Text := SelQSO.QSLManager;
  Edit10.Text := SelQSO.State1;
  Edit9.Text := SelQSO.State2;
  Edit11.Text := SelQSO.State3;
  Edit12.Text := SelQSO.State4;
  MemoNote.Text := SelQSO.QSOAddInfo;
  CBNoCalcDXCC.Checked := MainFunc.IntToBool(SelQSO.NoCalcDXCC);
  CBReceivedEQSL.Checked := MainFunc.IntToBool(SelQSO.QSLReceQSLcc);
  CBReceived.Checked := MainFunc.StringToBool(SelQSO.QSLRec);
  CBReceivedLoTW.Checked := MainFunc.StringToBool(SelQSO.LoTWRec);
  CBSentLoTW.Checked := MainFunc.IntToBool(SelQSO.LoTWSent);
  CBPropagation.Text := SelQSO.PROP_MODE;

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
    'P': RBPrinted.Checked := True;
    'T': RBSent.Checked := True;
    'Q': RBQueued.Checked := True;
    'F': RBWSent.Checked := True;
    'N': RBDSent.Checked := True;
  end;

  if DBRecord.InitDB = 'YES' then
    SatPropQuery.DataBase := InitDB.ServiceDBConnection;

  if CBMode.Text <> '' then
    CBModeChange(Self);
  CBPropagation.Items.Clear;
  SatPropQuery.SQL.Text := 'SELECT * FROM PropMode';
  SatPropQuery.Open;
  SatPropQuery.First;
  for i := 0 to SatPropQuery.RecordCount - 1 do
  begin
    CBPropagation.Items.Add(SatPropQuery.FieldByName('Type').AsString);
    SatPropQuery.Next;
  end;
  SatPropQuery.Close;

  GBCallInfo.Caption := SearchCountry(EditCallSign.Text);
end;

procedure TEditQSO_Form.SpeedButton10Click(Sender: TObject);
begin
  STATE_Form.ShowModal;
end;

end.
