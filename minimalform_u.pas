unit MinimalForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  DBGrids, Buttons, EditBtn, StdCtrls, DateTimePicker, LCLType, LazUTF8,
  const_u, ResourceStr, Grids, LazSysUtils;

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
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure EditButton1Change(Sender: TObject);
    procedure EditButton1KeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure TimeTimer(Sender: TObject);
  private
    DataSource: TDataSource;
    Query: TSQLQuery;
    procedure SearchPrefix(CallName: string;
      var Country, ARRLPrefix, Prefix, CQZone, ITUZone, Continent,
      Latitude, Longitude, Distance, Azimuth: string);
    procedure GetDistAzim(la, lo: string; var Distance, Azimuth: string);
    procedure SearchCallInLog(CallName: string; var setColors: TColor;
      var OMName, OMQTH, Grid, State, IOTA, QSLManager: string);
    procedure Clr;
    procedure SetGrid(var DBGRID: TDBGrid);
    procedure addBands(FreqBand: string; mode: string);

  public

  end;

var
  MinimalForm: TMinimalForm;

implementation

uses MainForm_U, dmFunc_U, InformationForm_U, ConfigForm_U;

{$R *.lfm}

{ TMinimalForm }

procedure TMinimalForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Time.Enabled := False;
  MainForm.Timer1.Enabled := True;
  MainForm.Timer3.Enabled := True;
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
  addBands(IniF.ReadString('SetLog', 'ShowBand', ''), ComboBox2.Text);
end;

procedure TMinimalForm.FormDestroy(Sender: TObject);
begin
  DataSource.Free;
  Query.Free;
end;

procedure TMinimalForm.FormShow(Sender: TObject);
begin
  SetGrid(DBGrid1);
  Time.Enabled := True;
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

procedure TMinimalForm.addBands(FreqBand: string; mode: string);
var
  i: integer;
  lastBand: integer;
  lastBandName: string;
begin
  DefaultFormatSettings.DecimalSeparator := '.';
  if MainForm.ServiceDBConnection.Connected then
  begin
    lastBand := ComboBox1.ItemIndex;
    lastBandName := ComboBox1.Text;
    MainForm.BandsQuery.Close;
    ComboBox1.Items.Clear;
    MainForm.BandsQuery.SQL.Text := 'SELECT * FROM Bands WHERE Enable = 1';
    MainForm.BandsQuery.Open;
    MainForm.BandsQuery.First;
    for i := 0 to MainForm.BandsQuery.RecordCount - 1 do
    begin
      if FreqBand = 'True' then
        ComboBox1.Items.Add(MainForm.BandsQuery.FieldByName('band').AsString)
      else
      begin
        if mode = 'SSB' then
          ComboBox1.Items.Add(FormatFloat(view_freq,
            MainForm.BandsQuery.FieldByName('ssb').AsFloat));
        if mode = 'CW' then
          ComboBox1.Items.Add(FormatFloat(view_freq,
            MainForm.BandsQuery.FieldByName('cw').AsFloat));
        if (mode <> 'CW') and (mode <> 'SSB') then
          ComboBox1.Items.Add(FormatFloat(view_freq,
            MainForm.BandsQuery.FieldByName('b_begin').AsFloat));
      end;
      MainForm.BandsQuery.Next;
    end;
    MainForm.BandsQuery.Close;
    if ComboBox1.Items.IndexOf(lastBandName) >= 0 then
      ComboBox1.ItemIndex := ComboBox1.Items.IndexOf(lastBandName)
    else
      ComboBox1.ItemIndex := lastBand;
  end;
end;

procedure TMinimalForm.SetGrid(var DBGRID: TDBGrid);
var
  i: integer;
  QBAND: string;
begin
  for i := 0 to 29 do
  begin
    MainForm.columnsGrid[i] :=
      IniF.ReadString('GridSettings', 'Columns' + IntToStr(i), constColumnName[i]);
    MainForm.columnsWidth[i] :=
      IniF.ReadInteger('GridSettings', 'ColWidth' + IntToStr(i), constColumnWidth[i]);
    MainForm.columnsVisible[i] :=
      IniF.ReadBool('GridSettings', 'ColVisible' + IntToStr(i), True);
  end;

  MainForm.ColorTextGrid := IniF.ReadInteger('GridSettings', 'TextColor', 0);
  MainForm.SizeTextGrid := IniF.ReadInteger('GridSettings', 'TextSize', 8);
  MainForm.ColorBackGrid := IniF.ReadInteger('GridSettings', 'BackColor', -2147483617);

  DBGRID.Font.Size := MainForm.SizeTextGrid;
  DBGRID.Font.Color := MainForm.ColorTextGrid;
  DBGRID.Color := MainForm.ColorBackGrid;

  if IniF.ReadString('SetLog', 'ShowBand', '') = 'True' then
    QBAND := rQSOBand
  else
    QBAND := rQSOBandFreq;

  for i := 0 to 29 do
  begin
    DBGRID.Columns.Items[i].FieldName := MainForm.columnsGrid[i];
    DBGRID.Columns.Items[i].Width := MainForm.columnsWidth[i];
    case MainForm.columnsGrid[i] of
      'QSL': DBGRID.Columns.Items[i].Title.Caption := rQSL;
      'QSLs': DBGRID.Columns.Items[i].Title.Caption := rQSLs;
      'QSODate': DBGRID.Columns.Items[i].Title.Caption := rQSODate;
      'QSOTime': DBGRID.Columns.Items[i].Title.Caption := rQSOTime;
      'QSOBand': DBGRID.Columns.Items[i].Title.Caption := QBAND;
      'CallSign': DBGRID.Columns.Items[i].Title.Caption := rCallSign;
      'QSOMode': DBGRID.Columns.Items[i].Title.Caption := rQSOMode;
      'QSOSubMode': DBGRID.Columns.Items[i].Title.Caption := rQSOSubMode;
      'OMName': DBGRID.Columns.Items[i].Title.Caption := rOMName;
      'OMQTH': DBGRID.Columns.Items[i].Title.Caption := rOMQTH;
      'State': DBGRID.Columns.Items[i].Title.Caption := rState;
      'Grid': DBGRID.Columns.Items[i].Title.Caption := rGrid;
      'QSOReportSent': DBGRID.Columns.Items[i].Title.Caption := rQSOReportSent;
      'QSOReportRecived': DBGRID.Columns.Items[i].Title.Caption := rQSOReportRecived;
      'IOTA': DBGRID.Columns.Items[i].Title.Caption := rIOTA;
      'QSLManager': DBGRID.Columns.Items[i].Title.Caption := rQSLManager;
      'QSLSentDate': DBGRID.Columns.Items[i].Title.Caption := rQSLSentDate;
      'QSLRecDate': DBGRID.Columns.Items[i].Title.Caption := rQSLRecDate;
      'LoTWRecDate': DBGRID.Columns.Items[i].Title.Caption := rLoTWRecDate;
      'MainPrefix': DBGRID.Columns.Items[i].Title.Caption := rMainPrefix;
      'DXCCPrefix': DBGRID.Columns.Items[i].Title.Caption := rDXCCPrefix;
      'CQZone': DBGRID.Columns.Items[i].Title.Caption := rCQZone;
      'ITUZone': DBGRID.Columns.Items[i].Title.Caption := rITUZone;
      'ManualSet': DBGRID.Columns.Items[i].Title.Caption := rManualSet;
      'Continent': DBGRID.Columns.Items[i].Title.Caption := rContinent;
      'ValidDX': DBGRID.Columns.Items[i].Title.Caption := rValidDX;
      'QSL_RCVD_VIA': DBGRID.Columns.Items[i].Title.Caption := rQSL_RCVD_VIA;
      'QSL_SENT_VIA': DBGRID.Columns.Items[i].Title.Caption := rQSL_SENT_VIA;
      'USERS': DBGRID.Columns.Items[i].Title.Caption := rUSERS;
      'NoCalcDXCC': DBGRID.Columns.Items[i].Title.Caption := rNoCalcDXCC;
    end;

    case MainForm.columnsGrid[i] of
      'QSL': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[0];
      'QSLs': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[1];
      'QSODate': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[2];
      'QSOTime': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[3];
      'QSOBand': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[4];
      'CallSign': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[5];
      'QSOMode': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[6];
      'QSOSubMode': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[7];
      'OMName': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[8];
      'OMQTH': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[9];
      'State': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[10];
      'Grid': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[11];
      'QSOReportSent': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[12];
      'QSOReportRecived': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[13];
      'IOTA': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[14];
      'QSLManager': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[15];
      'QSLSentDate': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[16];
      'QSLRecDate': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[17];
      'LoTWRecDate': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[18];
      'MainPrefix': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[19];
      'DXCCPrefix': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[20];
      'CQZone': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[21];
      'ITUZone': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[22];
      'ManualSet': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[23];
      'Continent': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[24];
      'ValidDX': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[25];
      'QSL_RCVD_VIA': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[26];
      'QSL_SENT_VIA': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[27];
      'USERS': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[28];
      'NoCalcDXCC': DBGRID.Columns.Items[i].Visible := MainForm.columnsVisible[29];
    end;
  end;

  case MainForm.SizeTextGrid of
    8: DBGRID.DefaultRowHeight := 15;
    10: DBGRID.DefaultRowHeight := DBGRID.Font.Size + 12;
    12: DBGRID.DefaultRowHeight := DBGRID.Font.Size + 12;
    14: DBGRID.DefaultRowHeight := DBGRID.Font.Size + 12;
  end;

  for i := 0 to DBGRID.Columns.Count - 1 do
    DBGRID.Columns.Items[i].Title.Font.Size := MainForm.SizeTextGrid;
end;

procedure TMinimalForm.SearchCallInLog(CallName: string; var setColors: TColor;
  var OMName, OMQTH, Grid, State, IOTA, QSLManager: string);
begin
  Query.Close;
  if MainForm.MySQLLOGDBConnection.Connected then
  begin
    Query.DataBase := MainForm.MySQLLOGDBConnection;
    Query.SQL.Text := 'SELECT `UnUsedIndex`, `CallSign`,' +
      ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
      + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
      + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `Call` LIKE ' +
      QuotedStr(CallName) +
      ' ORDER BY UNIX_TIMESTAMP(STR_TO_DATE(QSODate, ''%Y-%m-%d'')) DESC, QSOTime DESC';
  end
  else
  begin
    Query.DataBase := MainForm.SQLiteDBConnection;
    Query.SQL.Text := 'SELECT `UnUsedIndex`, `CallSign`,' +
      'strftime("%d.%m.%Y",QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
      + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||`LoTWSent`) AS QSLs FROM '
      + LogTable +
      ' INNER JOIN (SELECT UnUsedIndex, QSODate as QSODate2, QSOTime as QSOTime2 from ' +
      LogTable + ' WHERE `Call` LIKE ' + QuotedStr(CallName) +
      ' ORDER BY QSODate2 DESC, QSOTime2 DESC) as lim USING(UnUsedIndex)';
  end;
  Query.Transaction := MainForm.SQLTransaction1;
  Query.Open;
  if Query.RecordCount > 0 then
  begin
    setColors := clMoneyGreen;
    OMName := Query.FieldByName('OMName').AsString;
    OMQTH := Query.FieldByName('OMQTH').AsString;
    Grid := Query.FieldByName('Grid').AsString;
    State := Query.FieldByName('State').AsString;
    IOTA := Query.FieldByName('IOTA').AsString;
    QSLManager := Query.FieldByName('QSLManager').AsString;
  end
  else
    setColors := clDefault;
end;

procedure TMinimalForm.GetDistAzim(la, lo: string; var Distance, Azimuth: string);
var
  R: extended;
  azim, qra: string;
begin
  qra := '';
  azim := '';
  if (UTF8Pos('W', lo) <> 0) then
    lo := '-' + lo;
  if (UTF8Pos('S', la) <> 0) then
    la := '-' + la;
  Delete(la, length(la), 1);
  Delete(lo, length(lo), 1);
  R := dmFunc.Vincenty(QTH_LAT, QTH_LON, StrToFloat(la), StrToFloat(lo)) / 1000;
  Distance := FormatFloat('0.00', R) + ' KM';
  dmFunc.DistanceFromCoordinate(SetLoc, StrToFloat(la),
    strtofloat(lo), qra, azim);
  Azimuth := azim;
end;

procedure TMinimalForm.SearchPrefix(CallName: string;
  var Country, ARRLPrefix, Prefix, CQZone, ITUZone, Continent, Latitude,
  Longitude, Distance, Azimuth: string);
var
  i, j: integer;
begin
  if MainForm.UniqueCallsList.IndexOf(CallName) > -1 then
  begin
    with MainForm.PrefixQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('select * from UniqueCalls where _id = "' +
        IntToStr(MainForm.UniqueCallsList.IndexOf(CallName)) + '"');
      Open;
      Country := FieldByName('Country').AsString;
      ARRLPrefix := FieldByName('ARRLPrefix').AsString;
      Prefix := FieldByName('Prefix').AsString;
      CQZone := FieldByName('CQZone').AsString;
      ITUZone := FieldByName('ITUZone').AsString;
      Continent := FieldByName('Continent').AsString;
      Latitude := FieldByName('Latitude').AsString;
      Longitude := FieldByName('Longitude').AsString;
      DXCCNum := FieldByName('DXCC').AsInteger;
    end;
    GetDistAzim(Latitude, Longitude, Distance, Azimuth);
    Exit;
  end;

  for i := 0 to PrefixProvinceCount do
  begin
    if (MainForm.PrefixExpProvinceArray[i].reg.Exec(CallName)) and
      (MainForm.PrefixExpProvinceArray[i].reg.Match[0] = CallName) then
    begin
      with MainForm.PrefixQuery do
      begin
        Close;
        SQL.Clear;
        SQL.Add('select * from Province where _id = "' +
          IntToStr(MainForm.PrefixExpProvinceArray[i].id) + '"');
        Open;
        Country := FieldByName('Country').AsString;
        ARRLPrefix := FieldByName('ARRLPrefix').AsString;
        Prefix := FieldByName('Prefix').AsString;
        CQZone := FieldByName('CQZone').AsString;
        ITUZone := FieldByName('ITUZone').AsString;
        Continent := FieldByName('Continent').AsString;
        Latitude := FieldByName('Latitude').AsString;
        Longitude := FieldByName('Longitude').AsString;
        DXCCNum := FieldByName('DXCC').AsInteger;
        timedif := FieldByName('TimeDiff').AsInteger;
      end;
      GetDistAzim(Latitude, Longitude, Distance, Azimuth);
      Exit;
    end;
  end;

  for j := 0 to PrefixARRLCount do
  begin
    if (MainForm.PrefixExpARRLArray[j].reg.Exec(CallName)) and
      (MainForm.PrefixExpARRLArray[j].reg.Match[0] = CallName) then
    begin
      with MainForm.PrefixQuery do
      begin
        Close;
        SQL.Clear;
        SQL.Add('select * from CountryDataEx where _id = "' +
          IntToStr(MainForm.PrefixExpARRLArray[j].id) + '"');
        Open;
        if (FieldByName('Status').AsString = 'Deleted') then
        begin
          MainForm.PrefixExpARRLArray[j].reg.ExecNext;
          Exit;
        end;
      end;
      Country := MainForm.PrefixQuery.FieldByName('Country').AsString;
      ARRLPrefix := MainForm.PrefixQuery.FieldByName('ARRLPrefix').AsString;
      Prefix := MainForm.PrefixQuery.FieldByName('ARRLPrefix').AsString;
      CQZone := MainForm.PrefixQuery.FieldByName('CQZone').AsString;
      ITUZone := MainForm.PrefixQuery.FieldByName('ITUZone').AsString;
      Continent := MainForm.PrefixQuery.FieldByName('Continent').AsString;
      Latitude := MainForm.PrefixQuery.FieldByName('Latitude').AsString;
      Longitude := MainForm.PrefixQuery.FieldByName('Longitude').AsString;
      DXCCNum := MainForm.PrefixQuery.FieldByName('DXCC').AsInteger;
      timedif := MainForm.PrefixQuery.FieldByName('TimeDiff').AsInteger;
      GetDistAzim(Latitude, Longitude, Distance, Azimuth);
      Exit;
    end;
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
    MainForm.CheckDXCC(EditButton1.Text, ComboBox2.Text, ComboBox1.Text,
      DMode, DBand, DCall);
    MainForm.CheckQSL(EditButton1.Text, ComboBox1.Text, ComboBox2.Text, QSL);
    Label53.Visible := MainForm.FindWorkedCall(EditButton1.Text,
      ComboBox1.Text, ComboBox2.Text);
    Label54.Visible := MainForm.WorkedQSL(EditButton1.Text, ComboBox1.Text,
      ComboBox2.Text);
    Label34.Visible := MainForm.WorkedLoTW(EditButton1.Text, ComboBox1.Text,
      ComboBox2.Text);
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
  SearchCallInLog(dmFunc.ExtractCallsign(EditButton1.Text), setColors,
    OMName, OMQTH, Grid, State, IOTA, QSLManager);
  EditButton1.Color := setColors;
  SearchPrefix(EditButton1.Text, Country, ARRLPrefix,
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
