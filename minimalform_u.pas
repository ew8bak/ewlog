unit MinimalForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  DBGrids, Buttons, EditBtn, StdCtrls, DateTimePicker, LCLType, LazUTF8,
  const_u, ResourceStr, Grids, LazSysUtils, LCLProc, Menus, qso_record;

type

  { TMinimalForm }

  TMinimalForm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel6: TBevel;
    Bevel7: TBevel;
    Bevel8: TBevel;
    Bevel9: TBevel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox5: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    ComboBox6: TComboBox;
    ComboBox3: TComboBox;
    ComboBox7: TComboBox;
    DateEdit1: TDateEdit;
    DateTimePicker1: TDateTimePicker;
    DBGrid1: TDBGrid;
    Edit1: TEdit;
    Edit11: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    EditButton1: TEditButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
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
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label4: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    Label5: TLabel;
    Label53: TLabel;
    Label54: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Shape1: TShape;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Time: TTimer;
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure ComboBox1CloseUp(Sender: TObject);
    procedure ComboBox2CloseUp(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure EditButton1Change(Sender: TObject);
    procedure EditButton1KeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure TimeTimer(Sender: TObject);
  private
    DataSource: TDataSource;
    Query: TSQLQuery;
    procedure Clr;
    procedure addBands(FreqBand, mode, lastBandName: string;
      lastBand: integer; var ComboBox: TComboBox);

  public

  end;

var
  MinimalForm: TMinimalForm;

implementation

uses MainForm_U, dmFunc_U, InformationForm_U, ConfigForm_U, dmMainFunc, Earth_Form_U;

{$R *.lfm}

{ TMinimalForm }

procedure TMinimalForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Time.Enabled := False;
  MainForm.Timer1.Enabled := True;
  MainForm.Show;
end;

procedure TMinimalForm.FormCreate(Sender: TObject);
var
  modesString: TStringList;
begin
  modesString := TStringList.Create;
  ComboBox2.Items.Clear;
  MainForm.AddModes('', False, modesString);
  ComboBox2.Items := modesString;
  modesString.Free;

  Query := TSQLQuery.Create(nil);
  DataSource := TDataSource.Create(nil);
  DataSource.DataSet := Query;
  DBGrid1.DataSource := DataSource;
  Shape1.Visible := False;
  Label53.Visible := False;
  Label54.Visible := False;
  Label34.Visible := False;
  ComboBox2.ItemIndex := ComboBox2.Items.IndexOf(
    IniF.ReadString('SetLog', 'PastMode', ''));

  addBands(IniF.ReadString('SetLog', 'ShowBand', ''), ComboBox2.Text,
    MainForm.ComboBox1.Text, MainForm.ComboBox1.ItemIndex, ComboBox1);
  ComboBox2CloseUp(Self);
  ComboBox3.ItemIndex := ComboBox3.Items.IndexOf(
    IniF.ReadString('SetLog', 'PastSubMode', ''));
end;

procedure TMinimalForm.FormDestroy(Sender: TObject);
begin
  DataSource.Free;
  Query.Free;
end;

procedure TMinimalForm.FormShow(Sender: TObject);
begin
  dm_MainFunc.SetGrid(DBGrid1);
  Time.Enabled := True;
end;

procedure TMinimalForm.MenuItem3Click(Sender: TObject);
begin
  Earth.Show;
end;

procedure TMinimalForm.SpeedButton1Click(Sender: TObject);
  var
  QSL_SENT_ADV, QSL_SENT, dift: string;
  DigiBand: double;
  NameBand: string;
  DigiBand_String: string;
  timeQSO: TTime;
  FmtStngs: TFormatSettings;
  lat, lon: currency;
  SQSO: TQSO;
begin
  QSL_SENT := '';
  QSL_SENT_ADV := '';
  NameBand := '';
  FmtStngs.TimeSeparator := ':';
  FmtStngs.LongTimeFormat := 'hh:nn';

  if (Length(ComboBox1.Text) = 0) then
  begin
    ShowMessage(rCheckBand);
    Exit;
  end;

  if (Length(ComboBox2.Text) = 0) then
  begin
    ShowMessage(rCheckMode);
    Exit;
  end;

    dift := FormatDateTime('hh', Now - NowUTC);
    if CheckBox2.Checked = True then
    begin
      timeQSO := DateTimePicker1.Time - StrToTime(dift);
    end
    else
      timeQSO := DateTimePicker1.Time;

    if EditButton1.Text = '' then
      ShowMessage(rEnCall)
    else
    begin

      if ComboBox7.ItemIndex = 0 then
      begin
        QSL_SENT_ADV := 'T';
        QSL_SENT := '1';
      end;
      if ComboBox7.ItemIndex = 1 then
      begin
        QSL_SENT_ADV := 'P';
        QSL_SENT := '0';
      end;
      if ComboBox7.ItemIndex = 2 then
      begin
        QSL_SENT_ADV := 'Q';
        QSL_SENT := '0';
      end;
      if ComboBox7.ItemIndex = 3 then
      begin
        QSL_SENT_ADV := 'F';
        QSL_SENT := '0';
      end;
      if ComboBox7.ItemIndex = 4 then
      begin
        QSL_SENT_ADV := 'N';
        QSL_SENT := '0';
      end;

      if IniF.ReadString('SetLog', 'ShowBand', '') = 'True' then
        NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(
          ComboBox1.Text, ComboBox2.Text))
      else
        NameBand := ComboBox1.Text;

      DigiBand_String := NameBand;
      Delete(DigiBand_String, length(DigiBand_String) - 2, 1);
      DigiBand := dmFunc.GetDigiBandFromFreq(DigiBand_String);

      SQSO.CallSing := EditButton1.Text;
      SQSO.QSODate := DateEdit1.Date;
      SQSO.QSOTime := FormatDateTime('hh:nn', timeQSO);
      SQSO.QSOBand := NameBand;
      SQSO.QSOMode := ComboBox2.Text;
      SQSO.QSOSubMode := ComboBox3.Text;
      SQSO.QSOReportSent := ComboBox4.Text;
      SQSO.QSOReportRecived := ComboBox5.Text;
      SQSO.OmName := Edit1.Text;
      SQSO.OmQTH := Edit2.Text;
      SQSO.State0 := Edit4.Text;
      SQSO.Grid := Edit3.Text;
      SQSO.IOTA := Edit5.Text;
      SQSO.QSLManager := Edit6.Text;
      SQSO.QSLSent := QSL_SENT;
      SQSO.QSLSentAdv := QSL_SENT_ADV;
      SQSO.QSLSentDate := 'NULL';
      SQSO.QSLRec := '0';
      SQSO.QSLRecDate := 'NULL';
      SQSO.MainPrefix := Label38.Caption;
      SQSO.DXCCPrefix := Label34.Caption;
      SQSO.CQZone := Label45.Caption;
      SQSO.ITUZone := Label47.Caption;
      SQSO.QSOAddInfo := Edit11.Text;
      SQSO.Marker := BoolToStr(CheckBox5.Checked);
      SQSO.ManualSet := 0;
      SQSO.DigiBand := FloatToStr(DigiBand);
      SQSO.Continent := Label43.Caption;
      SQSO.ShortNote := Edit11.Text;
      SQSO.QSLReceQSLcc := 0;
      SQSO.LotWRec := '';
      SQSO.LotWRecDate := 'NULL';

      if not StateToQSLInfo then
        SQSO.QSLInfo := SetQSLInfo
      else
      begin
        if (MainForm.Edit14.Text <> '') or (MainForm.Edit15.Text <> '') then
          SQSO.QSLInfo := MainForm.Edit15.Text + ' ' + MainForm.Edit14.Text
        else
          SQSO.QSLInfo := SetQSLInfo;
      end;

      SQSO.Call := dmFunc.ExtractCallsign(EditButton1.Text);
      SQSO.State1 := '';
      SQSO.State2 := '';
      SQSO.State3 := '';
      SQSO.State4 := '';
      SQSO.WPX := dmFunc.ExtractWPXPrefix(EditButton1.Text);
      SQSO.AwardsEx := 'NULL';
      SQSO.ValidDX := IntToStr(1);
      SQSO.SRX := 0;
      SQSO.SRX_String := '';
      SQSO.STX := 0;
      SQSO.STX_String := '';
      SQSO.SAT_NAME := '';
      SQSO.SAT_MODE := '';
      SQSO.PROP_MODE := '';
      SQSO.LotWSent := 0;
      SQSO.QSL_RCVD_VIA := '';
      SQSO.QSL_SENT_VIA := ComboBox6.Text;
      SQSO.DXCC := IntToStr(DXCCNum);
      SQSO.USERS := '';
      SQSO.NoCalcDXCC := 0;
      SQSO.SYNC := 0;

      if SetLoc <> '' then
        SQSO.My_Grid := SetLoc;

      if MainForm.Edit14.Text <> '' then
        SQSO.My_Grid := MainForm.Edit14.Text;

      SQSO.My_State := MainForm.Edit15.Text;

      if (SQSO.My_Grid <> '') and (dmFunc.IsLocOK(SQSO.My_Grid)) then
      begin
        dmFunc.CoordinateFromLocator(SQSO.My_Grid, lat, lon);
        SQSO.My_Lat := CurrToStr(lat);
        SQSO.My_Lon := CurrToStr(lon);
      end
      else
      begin
        SQSO.My_Lat := '';
        SQSO.My_Lon := '';
      end;
      SQSO.NLogDB := LogTable;
      dm_MainFunc.SaveQSO(SQSO);

      if AutoEQSLcc = True then
      begin
        dm_MainFunc.StartEQSLThread(eQSLccLogin, eQSLccPassword,
          SQSO.CallSing, SQSO.QSODate, StrToTime(SQSO.QSOTime), SQSO.QSOBand,
          SQSO.QSOMode, SQSO.QSOSubMode, SQSO.QSOReportSent, SetQSLInfo);
      end;

      if AutoHRDLog = True then
      begin
       dm_MainFunc.StartHRDLogThread(eQSLccLogin, eQSLccPassword,
          SQSO.CallSing, SQSO.QSODate, StrToTime(SQSO.QSOTime), SQSO.QSOBand,
          SQSO.QSOMode, SQSO.QSOSubMode, SQSO.QSOReportSent, SQSO.QSOReportRecived, SQSO.Grid, SetQSLInfo);
      end;

      MainForm.SelDB(CallLogBook);
      Clr;
    end;
end;

procedure TMinimalForm.SpeedButton2Click(Sender: TObject);
begin
  Clr;
end;

procedure TMinimalForm.TimeTimer(Sender: TObject);
begin
  Label24.Caption := FormatDateTime('hh:mm:ss', Now);
  Label26.Caption := FormatDateTime('hh:mm:ss', NowUTC);
  Label28.Caption := FormatDateTime('hh:mm:ss', NowUTC + timedif / 24);
  if CheckBox1.Checked = True then
  begin
    DateTimePicker1.Time := NowUTC;
    DateEdit1.Date := NowUTC;
  end;
end;

procedure TMinimalForm.addBands(FreqBand, mode, lastBandName: string;
  lastBand: integer; var ComboBox: TComboBox);
var
  i: integer;
  BandsQuery: TSQLQuery;
begin
  try
    BandsQuery := TSQLQuery.Create(nil);
    DefaultFormatSettings.DecimalSeparator := '.';
    if MainForm.ServiceDBConnection.Connected then
    begin
      BandsQuery.DataBase := MainForm.ServiceDBConnection;
      ComboBox.Items.Clear;
      BandsQuery.SQL.Text := 'SELECT * FROM Bands WHERE Enable = 1';
      BandsQuery.Open;
      BandsQuery.First;
      for i := 0 to BandsQuery.RecordCount - 1 do
      begin
        if FreqBand = 'True' then
          ComboBox.Items.Add(BandsQuery.FieldByName('band').AsString)
        else
        begin
          if mode = 'SSB' then
            ComboBox.Items.Add(FormatFloat(view_freq,
              BandsQuery.FieldByName('ssb').AsFloat));
          if mode = 'CW' then
            ComboBox.Items.Add(FormatFloat(view_freq,
              BandsQuery.FieldByName('cw').AsFloat));
          if (mode <> 'CW') and (mode <> 'SSB') then
            ComboBox.Items.Add(FormatFloat(view_freq,
              BandsQuery.FieldByName('b_begin').AsFloat));
        end;
        BandsQuery.Next;
      end;
      BandsQuery.Close;
      if ComboBox.Items.IndexOf(lastBandName) >= 0 then
        ComboBox.ItemIndex := ComboBox.Items.IndexOf(lastBandName)
      else
        ComboBox.ItemIndex := lastBand;
    end;

  finally
    BandsQuery.Free;
  end;
end;

procedure TMinimalForm.EditButton1Change(Sender: TObject);
var
  engText: string;
  DBand, DMode, DCall: boolean;
  QSL: integer;
  Country, ARRLPrefix, Prefix, CQZone, ITUZone, Continent, Latitude,
  Longitude, Distance, Azimuth: string;
  OMName, OMQTH, Grid, State, IOTA, QSLManager: string;
  setColors: TColor;
begin
  setColors := clDefault;
  OMName := '';
  OMQTH := '';
  Grid := '';
  State := '';
  IOTA := '';
  QSLManager := '';
  DBand := False;
  DMode := False;
  DCall := False;
  Label53.Visible := False;
  Label54.Visible := False;
  Label34.Visible := False;
  QSL := 0;

  if Length(EditButton1.Text) >= 2 then
  begin
    dm_MainFunc.CheckDXCC(EditButton1.Text, ComboBox2.Text, ComboBox1.Text,
      DMode, DBand, DCall);
    dm_MainFunc.CheckQSL(EditButton1.Text, ComboBox1.Text, ComboBox2.Text, QSL);
    Label53.Visible := dm_MainFunc.FindWorkedCall(EditButton1.Text,
      ComboBox1.Text, ComboBox2.Text);
    Label54.Visible := dm_MainFunc.WorkedQSL(EditButton1.Text,
      ComboBox1.Text, ComboBox2.Text);
    Label34.Visible := dm_MainFunc.WorkedLoTW(EditButton1.Text,
      ComboBox1.Text, ComboBox2.Text);
  end;

  Image1.Visible := DBand;
  Image2.Visible := DMode;
  Image3.Visible := DCall;

  Shape1.Visible := (QSL <> 0);

  if QSL = 1 then
    Shape1.Brush.Color := clFuchsia;

  if QSL = 2 then
    Shape1.Brush.Color := clLime;

  if (Sender = ComboBox1) or (Sender = ComboBox2) then
    Exit;

  Edit1.Clear;
  Edit2.Clear;
  Edit3.Clear;
  Edit4.Clear;
  Edit5.Clear;
  Edit6.Clear;

  EditButton1.SelStart := seleditnum;
  engText := dmFunc.RusToEng(EditButton1.Text);
  if (engText <> EditButton1.Text) then
  begin
    EditButton1.Text := engText;
    exit;
  end;

  if EditButton1.Text = '' then
  begin
    Clr;
    label29.Caption := '.......';
    label31.Caption := '.......';
    label33.Caption := '.......';
    label36.Caption := '.......';
    label38.Caption := '.......';
    label40.Caption := '.......';
    label47.Caption := '.......';
    label44.Caption := '..';
    label46.Caption := '..';
    label42.Caption := '.......';
    Exit;
  end;
  dm_MainFunc.SearchCallInLog(dmFunc.ExtractCallsign(EditButton1.Text), setColors,
    OMName, OMQTH, Grid, State, IOTA, QSLManager, Query);
  EditButton1.Color := setColors;
  dm_MainFunc.SearchPrefix(EditButton1.Text, Edit3.Text, Country, ARRLPrefix,
    Prefix, CQZone, ITUZone, Continent, Latitude, Longitude, Distance, Azimuth);
  Label31.Caption := Country;
  Label33.Caption := ARRLPrefix;
  Label38.Caption := Prefix;
  Label44.Caption := CQZone;
  Label46.Caption := ITUZone;
  Label47.Caption := Continent;
  Label40.Caption := Latitude;
  Label42.Caption := Longitude;
  Label36.Caption := Distance;
  Label29.Caption := Azimuth;
  Edit1.Text := OMName;
  Edit2.Text := OMQTH;
  Edit3.Text := Grid;
  Edit4.Text := State;
  Edit5.Text := IOTA;
  Edit6.Text := QSLManager;
end;

procedure TMinimalForm.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: integer; Column: TColumn; State: TGridDrawState);
var
  Field_QSL: string;
  Field_QSLs: string;
  Field_QSLSentAdv: string;
begin
  Field_QSL := DataSource.DataSet.FieldByName('QSL').AsString;
  Field_QSLs := DataSource.DataSet.FieldByName('QSLs').AsString;
  Field_QSLSentAdv := DataSource.DataSet.FieldByName('QSLSentAdv').AsString;

  if Field_QSLSentAdv = 'N' then
    with DBGrid1.Canvas do
    begin
      Brush.Color := clRed;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (Field_QSL = '001') or (Field_QSL = '100') or (Field_QSL = '011') or
    (Field_QSL = '110') or (Field_QSL = '111') or (Field_QSL = '101') then
    with DBGrid1.Canvas do
    begin
      Brush.Color := clFuchsia;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (Field_QSLs = '10') or (Field_QSLs = '11') then
    with DBGrid1.Canvas do
    begin
      Brush.Color := clAqua;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if ((Field_QSLs = '10') or (Field_QSLs = '11')) and
    ((Field_QSL = '001') or (Field_QSL = '011') or (Field_QSL = '111') or
    (Field_QSL = '101') or (Field_QSL = '110')) then
    with DBGrid1.Canvas do
    begin
      Brush.Color := clLime;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (Column.FieldName = 'CallSign') then
    if (Field_QSL = '010') or (Field_QSL = '110') or (Field_QSL = '111') or
      (Field_QSL = '011') then
    begin
      with DBGrid1.Canvas do
      begin
        Brush.Color := clYellow;
        Font.Color := clBlack;
        if (gdSelected in State) then
        begin
          Brush.Color := clHighlight;
          Font.Color := clWhite;
        end;
        FillRect(Rect);
        DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
      end;
    end;
  if (Column.FieldName = 'QSL') then
  begin
    with DBGrid1.Canvas do
    begin
      FillRect(Rect);

      if (Field_QSL = '100') then
        TextOut(Rect.Right - 6 - TextWidth('P'), Rect.Top + 0, 'P');

      if (Field_QSL = '110') then
        TextOut(Rect.Right - 10 - TextWidth('PE'), Rect.Top + 0, 'PE');

      if (Field_QSL = '111') then
        TextOut(Rect.Right - 6 - TextWidth('PLE'), Rect.Top + 0, 'PLE');

      if (Field_QSL = '010') then
        TextOut(Rect.Right - 6 - TextWidth('E'), Rect.Top + 0, 'E');

      if (Field_QSL = '001') then
        TextOut(Rect.Right - 6 - TextWidth('L'), Rect.Top + 0, 'L');

      if (Field_QSL = '101') then
        TextOut(Rect.Right - 10 - TextWidth('PL'), Rect.Top + 0, 'PL');

      if (Field_QSL = '011') then
        TextOut(Rect.Right - 10 - TextWidth('LE'), Rect.Top + 0, 'LE');
    end;
  end;
  if (Column.FieldName = 'QSLs') then
  begin
    with DBGrid1.Canvas do
    begin
      FillRect(Rect);
      if (Field_QSLs = '10') then
        TextOut(Rect.Right - 6 - TextWidth('P'), Rect.Top + 0, 'P');

      if (Field_QSLs = '11') then
        TextOut(Rect.Right - 10 - TextWidth('PL'), Rect.Top + 0, 'PL');

      if (Field_QSLs = '01') then
        TextOut(Rect.Right - 6 - TextWidth('L'), Rect.Top + 0, 'L');
    end;
  end;
  if ConfigForm.CheckBox2.Checked = True then
  begin
    if (Column.FieldName = 'QSOBand') then
    begin
      DBGrid1.Canvas.FillRect(Rect);
      DBGrid1.Canvas.TextOut(Rect.Left + 2, Rect.Top + 0,
        dmFunc.GetBandFromFreq(DataSource.DataSet.FieldByName('QSOBand').AsString));
    end;
  end;
end;

procedure TMinimalForm.ComboBox2CloseUp(Sender: TObject);
var
  modesString: TStringList;
  deldot: string;
begin
  modesString := TStringList.Create;
  deldot := ComboBox1.Text;
  if Pos('M', deldot) > 0 then
  begin
    deldot := FormatFloat(view_freq, dmFunc.GetFreqFromBand(deldot, ComboBox2.Text));
    Delete(deldot, length(deldot) - 2, 1);
  end
  else
    Delete(deldot, length(deldot) - 2, 1);
  ComboBox3.Items.Clear;
  MainForm.addModes(ComboBox2.Text, True, modesString);
  ComboBox3.Items := modesString;
  modesString.Free;
  addBands(IniF.ReadString('SetLog', 'ShowBand', ''), ComboBox2.Text,
    ComboBox1.Text, ComboBox1.ItemIndex, ComboBox1);
  if ComboBox2.Text <> 'SSB' then
    ComboBox3.Text := '';
  if deldot <> '' then
  begin
    if StrToDouble(deldot) >= 10 then
      ComboBox3.ItemIndex := ComboBox3.Items.IndexOf('USB')
    else
      ComboBox3.ItemIndex := ComboBox3.Items.IndexOf('LSB');
  end;
end;

procedure TMinimalForm.ComboBox1CloseUp(Sender: TObject);
var
  deldot: string;
begin
  MainForm.freqchange := True;
  deldot := ComboBox1.Text;
  if Pos('M', deldot) > 0 then
  begin
    deldot := FormatFloat(view_freq, dmFunc.GetFreqFromBand(deldot, ComboBox2.Text));
    Delete(deldot, length(deldot) - 2, 1);
  end
  else
    Delete(deldot, length(deldot) - 2, 1);

  if ComboBox2.Text = 'SSB' then
  begin
    if StrToDouble(deldot) >= 10 then
      ComboBox3.ItemIndex := ComboBox3.Items.IndexOf('USB')
    else
      ComboBox3.ItemIndex := ComboBox3.Items.IndexOf('LSB');
  end;

  if Length(EditButton1.Text) >= 2 then
    EditButton1Change(ComboBox1);
end;

procedure TMinimalForm.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked = False then
  begin
    EditButton1.Font.Color := clRed;
    DateTimePicker1.Font.Color := clRed;
    DateEdit1.Font.Color := clRed;
    CheckBox2.Enabled := True;
    DateTimePicker1.ReadOnly := False;
  end
  else
  begin
    EditButton1.Font.Color := clDefault;
    DateTimePicker1.Font.Color := clDefault;
    DateEdit1.Font.Color := clDefault;
    CheckBox2.Enabled := False;
    CheckBox2.Checked := False;
    DateTimePicker1.ReadOnly := True;
  end;
end;

procedure TMinimalForm.CheckBox2Change(Sender: TObject);
begin
  if CheckBox2.Checked = True then
    Label4.Caption := rQSOTime + ' (Local)'
  else
    Label4.Caption := rQSOTime + ' (UTC)';
end;

procedure TMinimalForm.Clr;
begin
  EditButton1.Clear;
  EditButton1.Color := clDefault;
  Edit1.Clear;
  Edit2.Clear;
  Edit3.Clear;
  Edit4.Clear;
  Edit5.Clear;
  Edit6.Clear;
  Edit11.Clear;
  ComboBox4.ItemIndex := 0;
  ComboBox5.ItemIndex := 0;
  Image1.Visible := False;
  Image2.Visible := False;
  Image3.Visible := False;
  Shape1.Visible := False;
  Label53.Visible := False;
  Label54.Visible := False;
  Label34.Visible := False;
  ComboBox6.Text := '';
end;

procedure TMinimalForm.EditButton1KeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  seleditnum := EditButton1.SelStart + 1;
  if (Key = VK_BACK) then
    seleditnum := EditButton1.SelStart - 1;
  if (Key = VK_DELETE) then
    seleditnum := EditButton1.SelStart;
  if (EditButton1.SelLength <> 0) and (Key = VK_BACK) then
    seleditnum := EditButton1.SelStart;
  if (Key = VK_RETURN) then
  begin
    if (MainForm.CallBookLiteConnection.Connected = False) and
      (Length(dmFunc.ExtractCallsign(EditButton1.Text)) >= 3) then
      InformationForm.GetInformation(EditButton1.Text, True);
  end;
end;

end.
