unit MainFuncDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, SQLDB, RegExpr, qso_record, Dialogs, ResourceStr,
  prefix_record, LazUTF8, const_u, DBGrids, inifile_record, selectQSO_record,
  foundQSO_record;

type
  bandArray = array of string;
  modeArray = array of string;
  subModeArray = array of string;
  CallsignArray = array of string;

  { TMainFunc }

  TMainFunc = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    SearchPrefixQuery: TSQLQuery;
  public
    procedure SaveQSO(var SQSO: TQSO);
    procedure SetGrid(var DBGRID: TDBGrid);
    procedure GetDistAzim(la, lo: string; var Distance, Azimuth: string);
    procedure CheckDXCC(Callsign, mode, band: string; var DMode, DBand, DCall: boolean);
    procedure CheckQSL(Callsign, band, mode: string; var QSL: integer);
    procedure LoadINIsettings;
    procedure ClearPFXR(var PFXR: TPFXR);
    function FindWorkedCall(Callsign, band, mode: string): boolean;
    function WorkedQSL(Callsign, band, mode: string): boolean;
    function WorkedLoTW(Callsign, band, mode: string): boolean;
    function SearchPrefix(Callsign, Grid: string): TPFXR;
    function LoadBands(mode: string): bandArray;
    function LoadModes: modeArray;
    function LoadSubModes(mode: string): subModeArray;
    function FindQSO(Callsign: string): TFoundQSOR;
    function SelectQSO(DataSource: TDataSource): TSelQSOR;
    function GetAllCallsign: CallsignArray;

  end;

var
  MainFunc: TMainFunc;
  IniSet: TINIR;


implementation

uses InitDB_dm, dmFunc_U, MainForm_U;

{$R *.lfm}

function TMainFunc.GetAllCallsign: CallsignArray;
var
  i: integer;
  Query: TSQLQuery;
  CallsignList: CallsignArray;
begin
  try
    Query := TSQLQuery.Create(nil);
    if DBRecord.CurrentDB = 'MySQL' then
    Query.DataBase := InitDB.MySQLConnection
    else
    Query.DataBase := InitDB.SQLiteConnection;

     Query.SQL.Text := 'SELECT CallName FROM LogBookInfo';
      Query.Open;
      if Query.RecordCount = 0 then
        Exit;
      SetLength(CallsignList, Query.RecordCount);
      Query.First;
      for i := 0 to Query.RecordCount - 1 do
      begin
        CallsignList[i] := Query.FieldByName('CallName').AsString;
        Query.Next;
      end;
      Query.Close;
    Result := CallsignList;
  finally
    FreeAndNil(Query);
  end;
end;

function TMainFunc.SelectQSO(DataSource: TDataSource): TSelQSOR;
var
  SelQSOR: TSelQSOR;
begin
  SelQSOR.QSODate := DataSource.DataSet.FieldByName('QSODate').AsString;
  SelQSOR.QSOTime := DataSource.DataSet.FieldByName('QSOTime').AsString;
  SelQSOR.QSOBand := DataSource.DataSet.FieldByName('QSOBand').AsString;
  SelQSOR.QSOMode := DataSource.DataSet.FieldByName('QSOMode').AsString;
  SelQSOR.OMName := DataSource.DataSet.FieldByName('OMName').AsString;
  Result := SelQSOR;
end;

function TMainFunc.FindQSO(Callsign: string): TFoundQSOR;
var
  FoundQSOR: TFoundQSOR;
begin
    InitDB.FindQSOQuery.Close;
    if DBRecord.CurrentDB = 'MySQL' then
      InitDB.FindQSOQuery.DataBase := InitDB.MySQLConnection
    else
      InitDB.FindQSOQuery.DataBase := InitDB.SQLiteConnection;
    if DBRecord.CurrentDB = 'MySQL' then
      InitDB.FindQSOQuery.SQL.Text :=
        'SELECT `UnUsedIndex`, `CallSign`,' +
        ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
        + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
        + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
        + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
        + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
        + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
        + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
        + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
        + '`LoTWSent`) AS QSLs FROM ' + LBRecord.LogTable +
        ' WHERE `Call` LIKE ' + QuotedStr(Callsign) +
        ' ORDER BY UNIX_TIMESTAMP(STR_TO_DATE(QSODate, ''%Y-%m-%d'')) DESC, QSOTime DESC'
    else
      InitDB.FindQSOQuery.SQL.Text :=
        'SELECT `UnUsedIndex`, `CallSign`,' +
        'strftime("%d.%m.%Y",QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
        + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
        + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
        + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
        + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
        + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
        + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
        + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||`LoTWSent`) AS QSLs FROM '
        + LBRecord.LogTable +
        ' INNER JOIN (SELECT UnUsedIndex, QSODate as QSODate2, QSOTime as QSOTime2 from '
        +
        LBRecord.LogTable + ' WHERE `Call` LIKE ' + QuotedStr(Callsign) +
        ' ORDER BY QSODate2 DESC, QSOTime2 DESC) as lim USING(UnUsedIndex)';
    InitDB.FindQSOQuery.Open;
    if InitDB.FindQSOQuery.RecordCount > 0 then
    begin
      FoundQSOR.Found := True;
      FoundQSOR.CountQSO := InitDB.FindQSOQuery.RecordCount;
      FoundQSOR.OMName := InitDB.FindQSOQuery.FieldByName('OMName').AsString;
      FoundQSOR.OMQTH := InitDB.FindQSOQuery.FieldByName('OMQTH').AsString;
      FoundQSOR.Grid := InitDB.FindQSOQuery.FieldByName('Grid').AsString;
      FoundQSOR.State := InitDB.FindQSOQuery.FieldByName('State').AsString;
      FoundQSOR.IOTA := InitDB.FindQSOQuery.FieldByName('IOTA').AsString;
      FoundQSOR.QSLManager := InitDB.FindQSOQuery.FieldByName('QSLManager').AsString;
    end;
    Result := FoundQSOR;
end;

function TMainFunc.LoadSubModes(mode: string): subModeArray;
var
  i: integer;
  Query: TSQLQuery;
  SubModeList: subModeArray;
  SubModeSlist: TStringList;
begin
  try
    Query := TSQLQuery.Create(nil);
    SubModeSlist := TStringList.Create;
    if InitDB.ServiceDBConnection.Connected then
    begin
      SubModeSlist.Delimiter := ',';
      Query.DataBase := InitDB.ServiceDBConnection;
      Query.SQL.Text := 'SELECT submode FROM Modes WHERE mode = ' + QuotedStr(mode);
      Query.Open;
      SubModeSlist.DelimitedText := Query.FieldByName('submode').AsString;
      Query.Close;
    end;
    if SubModeSlist.Count = 0 then
      Exit;
    SetLength(SubModeList, SubModeSlist.Count);
    for i := 0 to SubModeSlist.Count - 1 do
      SubModeList[i] := SubModeSlist.Strings[i];
    Result := SubModeList;
  finally
    FreeAndNil(Query);
    FreeAndNil(SubModeSlist);
  end;
end;

function TMainFunc.LoadModes: modeArray;
var
  i: integer;
  Query: TSQLQuery;
  ModeList: modeArray;
begin
  try
    Query := TSQLQuery.Create(nil);
    if InitDB.ServiceDBConnection.Connected then
    begin
      Query.DataBase := InitDB.ServiceDBConnection;
      Query.SQL.Text := 'SELECT * FROM Modes WHERE Enable = 1';
      Query.Open;
      if Query.RecordCount = 0 then
        Exit;
      SetLength(ModeList, Query.RecordCount);
      Query.First;
      for i := 0 to Query.RecordCount - 1 do
      begin
        ModeList[i] := Query.FieldByName('mode').AsString;
        Query.Next;
      end;
      Query.Close;
    end;
    Result := ModeList;
  finally
    FreeAndNil(Query);
  end;
end;

function TMainFunc.LoadBands(mode: string): bandArray;
var
  Query: TSQLQuery;
  BandList: bandArray;
  i: integer;
begin
  try
    Query := TSQLQuery.Create(nil);
    if InitDB.ServiceDBConnection.Connected then
    begin
      Query.DataBase := InitDB.ServiceDBConnection;
      Query.SQL.Text := 'SELECT * FROM Bands WHERE Enable = 1';
      Query.Open;
      if Query.RecordCount = 0 then
        Exit;
      SetLength(BandList, Query.RecordCount);
      Query.First;
      for i := 0 to Query.RecordCount - 1 do
      begin
        if IniSet.showBand then
          BandList[i] := Query.FieldByName('band').AsString
        else
        begin
          if mode = 'SSB' then
            BandList[i] := FormatFloat(view_freq, Query.FieldByName('ssb').AsFloat);
          if mode = 'CW' then
            BandList[i] := FormatFloat(view_freq, Query.FieldByName('cw').AsFloat);
          if (mode <> 'CW') and (mode <> 'SSB') then
            BandList[i] := FormatFloat(view_freq, Query.FieldByName('b_begin').AsFloat);
        end;
        Query.Next;
      end;
      Query.Close;
    end;
    Result := BandList;
  finally
    FreeAndNil(Query);
  end;
end;

procedure TMainFunc.LoadINIsettings;
begin
  IniSet.UseIntCallBook := INIFile.ReadBool('SetLog', 'IntCallBook', False);
  IniSet.PhotoDir := INIFile.ReadString('SetLog', 'PhotoDir', '');
  IniSet.StateToQSLInfo := INIFile.ReadBool('SetLog', 'StateToQSLInfo', False);
  IniSet.Fl_PATH := INIFile.ReadString('FLDIGI', 'FldigiPATH', '');
  IniSet.WSJT_PATH := INIFile.ReadString('WSJT', 'WSJTPATH', '');
  IniSet.FLDIGI_USE := INIFile.ReadBool('FLDIGI', 'USEFLDIGI', False);
  IniSet.WSJT_USE := INIFile.ReadBool('WSJT', 'USEWSJT', False);
  IniSet.ShowTRXForm := INIFile.ReadBool('SetLog', 'TRXForm', False);
  IniSet._l := INIFile.ReadInteger('SetLog', 'Left', 0);
  IniSet._t := INIFile.ReadInteger('SetLog', 'Top', 0);
  IniSet._w := INIFile.ReadInteger('SetLog', 'Width', 1043);
  IniSet._h := INIFile.ReadInteger('SetLog', 'Height', 671);
  IniSet.PastMode := INIFile.ReadString('SetLog', 'PastMode', '');
  IniSet.PastSubMode := INIFile.ReadString('SetLog', 'PastSubMode', '');
  IniSet.PastBand := INIFile.ReadInteger('SetLog', 'PastBand', 0);
  IniSet.Language := INIFile.ReadString('SetLog', 'Language', '');
  IniSet.Map_Use := INIFile.ReadBool('SetLog', 'UseMAPS', False);
  IniSet.PrintPrev := INIFile.ReadBool('SetLog', 'PrintPrev', False);
  IniSet.FormState := INIFile.ReadString('SetLog', 'FormState', '');
  IniSet.showBand := INIFile.ReadBool('SetLog', 'ShowBand', False);
end;

procedure TMainFunc.CheckDXCC(Callsign, mode, band: string;
  var DMode, DBand, DCall: boolean);
var
  Query: TSQLQuery;
  digiBand: double;
  nameBand: string;
  PFXR: TPFXR;
begin
  if Pos('M', band) > 0 then
    NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(band, mode))
  else
    nameBand := band;

  Delete(nameBand, length(nameBand) - 2, 1);
  digiBand := dmFunc.GetDigiBandFromFreq(nameBand);

  try
    PFXR := SearchPrefix(Callsign, '');
    Query := TSQLQuery.Create(nil);
    Query.Transaction := InitDB.DefTransaction;
    if DBRecord.CurrentDB = 'MySQL' then
      Query.DataBase := InitDB.MySQLConnection
    else
      Query.DataBase := InitDB.SQLiteConnection;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
      ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
      DCall := False
    else
      DCall := True;
    Query.Close;
    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
      ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' AND QSOMode = ' +
      QuotedStr(mode) + ' LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
      DMode := False
    else
      DMode := True;
    Query.Close;
    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
      ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' AND DigiBand = ' +
      FloatToStr(digiBand) + ' LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
      DBand := False
    else
      DBand := True;
  finally
    Query.Free;
  end;
end;

procedure TMainFunc.CheckQSL(Callsign, band, mode: string; var QSL: integer);
var
  Query: TSQLQuery;
  digiBand: double;
  nameBand: string;
  PFXR: TPFXR;
begin
  if Pos('M', band) > 0 then
    NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(band, mode))
  else
    nameBand := band;

  Delete(nameBand, length(nameBand) - 2, 1);
  digiBand := dmFunc.GetDigiBandFromFreq(nameBand);

  try
    PFXR := SearchPrefix(Callsign, '');
    Query := TSQLQuery.Create(nil);
    Query.Transaction := InitDB.DefTransaction;
    if DBRecord.CurrentDB = 'MySQL' then
      Query.DataBase := InitDB.MySQLConnection
    else
      Query.DataBase := InitDB.SQLiteConnection;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
      ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' AND DigiBand = ' +
      FloatToStr(digiBand) + ' AND (QSLRec = 1 OR LoTWRec = 1) LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
    begin
      QSL := 0;
      Exit;
    end;
    Query.Close;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
      ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' LIMIT 1';
    Query.Open;
    if Query.RecordCount = 0 then
    begin
      QSL := 0;
      Exit;
    end;
    Query.Close;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
      ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' AND DigiBand = ' +
      FloatToStr(digiBand) + ' AND (QSLRec = 0 AND LoTWRec = 0) LIMIT 1';
    Query.Open;
    if Query.RecordCount = 0 then
    begin
      QSL := 2;
      Exit;
    end
    else
    begin
      QSL := 1;
      Exit;
    end;
    Query.Close;

  finally
    Query.Free;
  end;
end;

function TMainFunc.FindWorkedCall(Callsign, band, mode: string): boolean;
var
  Query: TSQLQuery;
  digiBand: double;
  nameBand: string;
begin
  Result := False;
  if Pos('M', band) > 0 then
    NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(band, mode))
  else
    nameBand := band;

  Delete(nameBand, length(nameBand) - 2, 1);
  digiBand := dmFunc.GetDigiBandFromFreq(nameBand);
  try
    Query := TSQLQuery.Create(nil);
    Query.Transaction := InitDB.DefTransaction;
    if DBRecord.CurrentDB = 'MySQL' then
      Query.DataBase := InitDB.MySQLConnection
    else
      Query.DataBase := InitDB.SQLiteConnection;
    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
      ' WHERE `Call` = ' + QuotedStr(Callsign) + ' AND DigiBand = ' +
      FloatToStr(digiBand) + ' AND QSOMode = ' + QuotedStr(mode) + ' LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
      Result := True;

  finally
    Query.Free;
  end;
end;

function TMainFunc.WorkedQSL(Callsign, band, mode: string): boolean;
var
  Query: TSQLQuery;
  digiBand: double;
  nameBand: string;
begin
  Result := False;
  if Pos('M', band) > 0 then
    NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(band, mode))
  else
    nameBand := band;

  Delete(nameBand, length(nameBand) - 2, 1);
  digiBand := dmFunc.GetDigiBandFromFreq(nameBand);
  try
    Query := TSQLQuery.Create(nil);
    Query.Transaction := InitDB.DefTransaction;
    if DBRecord.CurrentDB = 'MySQL' then
      Query.DataBase := InitDB.MySQLConnection
    else
      Query.DataBase := InitDB.SQLiteConnection;
    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
      ' WHERE `Call` = ' + QuotedStr(Callsign) + ' AND DigiBand = ' +
      FloatToStr(digiBand) + ' AND (LoTWRec = 1 OR QSLRec = 1) LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
      Result := True;

  finally
    Query.Free;
  end;
end;

function TMainFunc.WorkedLoTW(Callsign, band, mode: string): boolean;
var
  Query: TSQLQuery;
  digiBand: double;
  nameBand: string;
  PFXR: TPFXR;
begin
  Result := False;
  if Pos('M', band) > 0 then
    NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(band, mode))
  else
    nameBand := band;

  Delete(nameBand, length(nameBand) - 2, 1);
  digiBand := dmFunc.GetDigiBandFromFreq(nameBand);
  try
    PFXR := SearchPrefix(Callsign, '');
    Query := TSQLQuery.Create(nil);
    Query.Transaction := InitDB.DefTransaction;
    if DBRecord.CurrentDB = 'MySQL' then
      Query.DataBase := InitDB.MySQLConnection
    else
      Query.DataBase := InitDB.SQLiteConnection;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
      ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' AND DigiBand = ' +
      FloatToStr(digiBand) + ' AND (LoTWRec = 1 OR QSLRec = 1) LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
      Result := True;

  finally
    Query.Free;
  end;
end;

function TMainFunc.SearchPrefix(Callsign, Grid: string): TPFXR;
var
  i: integer;
  La, Lo: currency;
  PFXR: TPFXR;
begin
  ClearPFXR(PFXR);
  Result:=PFXR;
  if UniqueCallsList.IndexOf(Callsign) > -1 then
  begin
    with SearchPrefixQuery do
    begin
      Close;
      SQL.Text := 'SELECT * FROM UniqueCalls WHERE _id = "' +
        IntToStr(UniqueCallsList.IndexOf(Callsign)) + '"';
      Open;
      PFXR.Country := FieldByName('Country').AsString;
      PFXR.ARRLPrefix := FieldByName('ARRLPrefix').AsString;
      PFXR.Prefix := FieldByName('Prefix').AsString;
      PFXR.CQZone := FieldByName('CQZone').AsString;
      PFXR.ITUZone := FieldByName('ITUZone').AsString;
      PFXR.Continent := FieldByName('Continent').AsString;
      PFXR.Latitude := FieldByName('Latitude').AsString;
      PFXR.Longitude := FieldByName('Longitude').AsString;
      PFXR.DXCCNum := FieldByName('DXCC').AsInteger;
    end;
    if (Grid <> '') and dmFunc.IsLocOK(Grid) then
    begin
      dmFunc.CoordinateFromLocator(Grid, La, Lo);
      PFXR.Latitude := CurrToStr(La);
      PFXR.Longitude := CurrToStr(Lo);
    end;
    GetDistAzim(PFXR.Latitude, PFXR.Longitude, PFXR.Distance, PFXR.Azimuth);
    Result := PFXR;
    Exit;
  end;

  for i := 0 to PrefixProvinceCount do
  begin
    if (PrefixExpProvinceArray[i].reg.Exec(Callsign)) and
      (PrefixExpProvinceArray[i].reg.Match[0] = Callsign) then
    begin
      with SearchPrefixQuery do
      begin
        Close;
        SQL.Text := 'SELECT * FROM Province WHERE _id = "' +
          IntToStr(PrefixExpProvinceArray[i].id) + '"';
        Open;
        PFXR.Country := FieldByName('Country').AsString;
        PFXR.ARRLPrefix := FieldByName('ARRLPrefix').AsString;
        PFXR.Prefix := FieldByName('Prefix').AsString;
        PFXR.CQZone := FieldByName('CQZone').AsString;
        PFXR.ITUZone := FieldByName('ITUZone').AsString;
        PFXR.Continent := FieldByName('Continent').AsString;
        PFXR.Latitude := FieldByName('Latitude').AsString;
        PFXR.Longitude := FieldByName('Longitude').AsString;
        PFXR.DXCCNum := FieldByName('DXCC').AsInteger;
        PFXR.TimeDiff := FieldByName('TimeDiff').AsInteger;
      end;
      if (Grid <> '') and dmFunc.IsLocOK(Grid) then
      begin
        dmFunc.CoordinateFromLocator(Grid, La, Lo);
        PFXR.Latitude := CurrToStr(La);
        PFXR.Longitude := CurrToStr(Lo);
      end;
      GetDistAzim(PFXR.Latitude, PFXR.Longitude, PFXR.Distance, PFXR.Azimuth);
      Result := PFXR;
      Exit;
    end;
  end;

  for i := 0 to PrefixARRLCount do
  begin
    if (PrefixExpARRLArray[i].reg.Exec(Callsign)) and
      (PrefixExpARRLArray[i].reg.Match[0] = Callsign) then
    begin
      with SearchPrefixQuery do
      begin
        Close;
        SQL.Text := 'SELECT * FROM CountryDataEx WHERE _id = "' +
          IntToStr(PrefixExpARRLArray[i].id) + '"';
        Open;
        if (FieldByName('Status').AsString = 'Deleted') then
        begin
          PrefixExpARRLArray[i].reg.ExecNext;
          Exit;
        end;
      end;
      PFXR.Country := SearchPrefixQuery.FieldByName('Country').AsString;
      PFXR.ARRLPrefix := SearchPrefixQuery.FieldByName('ARRLPrefix').AsString;
      PFXR.Prefix := SearchPrefixQuery.FieldByName('ARRLPrefix').AsString;
      PFXR.CQZone := SearchPrefixQuery.FieldByName('CQZone').AsString;
      PFXR.ITUZone := SearchPrefixQuery.FieldByName('ITUZone').AsString;
      PFXR.Continent := SearchPrefixQuery.FieldByName('Continent').AsString;
      PFXR.Latitude := SearchPrefixQuery.FieldByName('Latitude').AsString;
      PFXR.Longitude := SearchPrefixQuery.FieldByName('Longitude').AsString;
      PFXR.DXCCNum := SearchPrefixQuery.FieldByName('DXCC').AsInteger;
      PFXR.TimeDiff := SearchPrefixQuery.FieldByName('TimeDiff').AsInteger;
      if (Grid <> '') and dmFunc.IsLocOK(Grid) then
      begin
        dmFunc.CoordinateFromLocator(Grid, La, Lo);
        PFXR.Latitude := CurrToStr(La);
        PFXR.Longitude := CurrToStr(Lo);
      end;
      GetDistAzim(PFXR.Latitude, PFXR.Longitude, PFXR.Distance, PFXR.Azimuth);
      Result := PFXR;
      Exit;
    end;
  end;
end;

procedure TMainFunc.GetDistAzim(la, lo: string; var Distance, Azimuth: string);
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
  DefaultFormatSettings.DecimalSeparator := '.';
  R := dmFunc.Vincenty(LBRecord.OpLat, LBRecord.OpLon, StrToFloat(la),
    StrToFloat(lo)) / 1000;
  Distance := FormatFloat('0.00', R) + ' KM';
  dmFunc.DistanceFromCoordinate(LBRecord.OpLoc, StrToFloat(la),
    strtofloat(lo), qra, azim);
  Azimuth := azim;
end;

procedure TMainFunc.DataModuleCreate(Sender: TObject);
begin
  SearchPrefixQuery := TSQLQuery.Create(nil);
  SearchPrefixQuery.DataBase := InitDB.ServiceDBConnection;
end;

procedure TMainFunc.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(SearchPrefixQuery);
end;

procedure TMainFunc.SaveQSO(var SQSO: TQSO);
var
  Query: TSQLQuery;
begin
  try
    Query := TSQLQuery.Create(nil);
    Query.Transaction := InitDB.DefTransaction;
    if DBRecord.CurrentDB = 'MySQL' then
      Query.DataBase := InitDB.MySQLConnection
    else
      Query.DataBase := InitDB.SQLiteConnection;

    with Query do
    begin
      SQL.Text := 'INSERT INTO ' + SQSO.NLogDB +
        '(`CallSign`, `QSODate`, `QSOTime`, `QSOBand`, `QSOMode`, `QSOSubMode`, ' +
        '`QSOReportSent`, `QSOReportRecived`, `OMName`, `OMQTH`, `State`, `Grid`, `IOTA`,'
        + '`QSLManager`, `QSLSent`, `QSLSentAdv`, `QSLSentDate`, `QSLRec`, `QSLRecDate`,'
        + '`MainPrefix`, `DXCCPrefix`, `CQZone`, `ITUZone`, `QSOAddInfo`, `Marker`, `ManualSet`,'
        + '`DigiBand`, `Continent`, `ShortNote`, `QSLReceQSLcc`, `LoTWRec`, `LoTWRecDate`,'
        + '`QSLInfo`, `Call`, `State1`, `State2`, `State3`, `State4`, `WPX`, `AwardsEx`, '
        + '`ValidDX`, `SRX`, `SRX_STRING`, `STX`, `STX_STRING`, `SAT_NAME`, `SAT_MODE`,'
        + '`PROP_MODE`, `LoTWSent`, `QSL_RCVD_VIA`, `QSL_SENT_VIA`, `DXCC`, `USERS`, `NoCalcDXCC`,'
        + '`MY_STATE`, `MY_GRIDSQUARE`, `MY_LAT`, `MY_LON`, `SYNC`)' +
        'VALUES (:CallSign, :QSODate, :QSOTime, :QSOBand, :QSOMode, :QSOSubMode, :QSOReportSent,'
        + ':QSOReportRecived, :OMName, :OMQTH, :State, :Grid, :IOTA, :QSLManager, :QSLSent,'
        + ':QSLSentAdv, :QSLSentDate, :QSLRec, :QSLRecDate, :MainPrefix, :DXCCPrefix, :CQZone,'
        + ':ITUZone, :QSOAddInfo, :Marker, :ManualSet, :DigiBand, :Continent, :ShortNote,'
        + ':QSLReceQSLcc, :LoTWRec, :LoTWRecDate, :QSLInfo, :Call, :State1, :State2, :State3, :State4,'
        + ':WPX, :AwardsEx, :ValidDX, :SRX, :SRX_STRING, :STX, :STX_STRING, :SAT_NAME,'
        + ':SAT_MODE, :PROP_MODE, :LoTWSent, :QSL_RCVD_VIA, :QSL_SENT_VIA, :DXCC, :USERS, :NoCalcDXCC, :MY_STATE, :MY_GRIDSQUARE, :MY_LAT, :MY_LON, :SYNC)';

      Params.ParamByName('CallSign').AsString := SQSO.CallSing;
      Params.ParamByName('QSODate').AsDateTime := SQSO.QSODate;
      Params.ParamByName('QSOTime').AsString := SQSO.QSOTime;
      Params.ParamByName('QSOBand').AsString := SQSO.QSOBand;
      Params.ParamByName('QSOMode').AsString := SQSO.QSOMode;
      Params.ParamByName('QSOSubMode').AsString := SQSO.QSOSubMode;
      Params.ParamByName('QSOReportSent').AsString := SQSO.QSOReportSent;
      Params.ParamByName('QSOReportRecived').AsString := SQSO.QSOReportRecived;
      Params.ParamByName('OMName').AsString := SQSO.OmName;
      Params.ParamByName('OMQTH').AsString := SQSO.OmQTH;
      Params.ParamByName('State').AsString := SQSO.State0;
      Params.ParamByName('Grid').AsString := SQSO.Grid;
      Params.ParamByName('IOTA').AsString := SQSO.IOTA;
      Params.ParamByName('QSLManager').AsString := SQSO.QSLManager;
      Params.ParamByName('QSLSent').AsString := SQSO.QSLSent;
      Params.ParamByName('QSLSentAdv').AsString := SQSO.QSLSentAdv;

      if SQSO.QSLSentDate = 'NULL' then
        Params.ParamByName('QSLSentDate').IsNull
      else
        Params.ParamByName('QSLSentDate').AsString := SQSO.QSLSentDate;
      Params.ParamByName('QSLRec').AsString := SQSO.QSLRec;
      if SQSO.QSLRecDate = 'NULL' then
        Params.ParamByName('QSLRecDate').IsNull
      else
        Params.ParamByName('QSLRecDate').AsString := SQSO.QSLRecDate;

      Params.ParamByName('MainPrefix').AsString := SQSO.MainPrefix;
      Params.ParamByName('DXCCPrefix').AsString := SQSO.DXCCPrefix;
      Params.ParamByName('CQZone').AsString := SQSO.CQZone;
      Params.ParamByName('ITUZone').AsString := SQSO.ITUZone;
      Params.ParamByName('QSOAddInfo').AsString := SQSO.QSOAddInfo;
      Params.ParamByName('Marker').AsString := SQSO.Marker;
      Params.ParamByName('ManualSet').AsInteger := SQSO.ManualSet;
      Params.ParamByName('DigiBand').AsString := SQSO.DigiBand;
      Params.ParamByName('Continent').AsString := SQSO.Continent;
      Params.ParamByName('ShortNote').AsString := SQSO.ShortNote;
      Params.ParamByName('QSLReceQSLcc').AsInteger := SQSO.QSLReceQSLcc;
      if SQSO.LotWRec = '' then
        Params.ParamByName('LoTWRec').AsInteger := 0
      else
        Params.ParamByName('LoTWRec').AsInteger := 1;
      if SQSO.LotWRecDate = 'NULL' then
        Params.ParamByName('LoTWRecDate').IsNull
      else
        Params.ParamByName('LoTWRecDate').AsString := SQSO.LotWRecDate;
      Params.ParamByName('QSLInfo').AsString := SQSO.QSLInfo;
      Params.ParamByName('Call').AsString := SQSO.Call;
      Params.ParamByName('State1').AsString := SQSO.State1;
      Params.ParamByName('State2').AsString := SQSO.State2;
      Params.ParamByName('State3').AsString := SQSO.State3;
      Params.ParamByName('State4').AsString := SQSO.State4;
      Params.ParamByName('WPX').AsString := SQSO.WPX;
      Params.ParamByName('AwardsEx').AsString := SQSO.AwardsEx;
      Params.ParamByName('ValidDX').AsString := SQSO.ValidDX;
      if SQSO.SRX = 0 then
        Params.ParamByName('SRX').IsNull
      else
        Params.ParamByName('SRX').AsInteger := SQSO.SRX;
      Params.ParamByName('SRX_STRING').AsString := SQSO.SRX_String;
      if SQSO.STX = 0 then
        Params.ParamByName('STX').IsNull
      else
        Params.ParamByName('STX').AsInteger := SQSO.STX;
      Params.ParamByName('STX_STRING').AsString := SQSO.STX_String;
      Params.ParamByName('SAT_NAME').AsString := SQSO.SAT_NAME;
      Params.ParamByName('SAT_MODE').AsString := SQSO.SAT_MODE;
      Params.ParamByName('PROP_MODE').AsString := SQSO.PROP_MODE;
      Params.ParamByName('LoTWSent').AsInteger := SQSO.LotWSent;
      if SQSO.QSL_RCVD_VIA = '' then
        Params.ParamByName('QSL_RCVD_VIA').IsNull
      else
        Params.ParamByName('QSL_RCVD_VIA').AsString := SQSO.QSL_RCVD_VIA;
      if SQSO.QSL_SENT_VIA = '' then
        Params.ParamByName('QSL_SENT_VIA').IsNull
      else
        Params.ParamByName('QSL_SENT_VIA').AsString := SQSO.QSL_SENT_VIA;
      Params.ParamByName('DXCC').AsString := SQSO.DXCC;
      Params.ParamByName('USERS').AsString := SQSO.USERS;
      Params.ParamByName('NoCalcDXCC').AsInteger := SQSO.NoCalcDXCC;
      Params.ParamByName('MY_STATE').AsString := SQSO.My_State;
      Params.ParamByName('MY_GRIDSQUARE').AsString := SQSO.My_Grid;
      Params.ParamByName('MY_LAT').AsString := SQSO.My_Lat;
      Params.ParamByName('MY_LON').AsString := SQSO.My_Lon;
      Params.ParamByName('SYNC').AsInteger := SQSO.SYNC;
      ExecSQL;
    end;
    InitDB.DefTransaction.Commit;
  finally
    FreeAndNil(Query);
  end;
end;

procedure TMainFunc.SetGrid(var DBGRID: TDBGrid);
var
  i: integer;
  QBAND: string;
begin
  for i := 0 to 29 do
  begin
    MainForm.columnsGrid[i] :=
      INIFile.ReadString('GridSettings', 'Columns' + IntToStr(i), constColumnName[i]);
    MainForm.columnsWidth[i] :=
      INIFile.ReadInteger('GridSettings', 'ColWidth' + IntToStr(i), constColumnWidth[i]);
    MainForm.columnsVisible[i] :=
      INIFile.ReadBool('GridSettings', 'ColVisible' + IntToStr(i), True);
  end;

  MainForm.ColorTextGrid := INIFile.ReadInteger('GridSettings', 'TextColor', 0);
  MainForm.SizeTextGrid := INIFile.ReadInteger('GridSettings', 'TextSize', 8);
  MainForm.ColorBackGrid := INIFile.ReadInteger('GridSettings',
    'BackColor', -2147483617);

  DBGRID.Font.Size := MainForm.SizeTextGrid;
  DBGRID.Font.Color := MainForm.ColorTextGrid;
  DBGRID.Color := MainForm.ColorBackGrid;

  if INIFile.ReadString('SetLog', 'ShowBand', '') = 'True' then
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

procedure TMainFunc.ClearPFXR(var PFXR: TPFXR);
begin
  PFXR.Country := '';
  PFXR.ARRLPrefix := '';
  PFXR.Prefix := '';
  PFXR.CQZone := '';
  PFXR.ITUZone := '';
  PFXR.Continent := '';
  PFXR.Latitude := '';
  PFXR.Longitude := '';
  PFXR.DXCCNum := 0;
  PFXR.TimeDiff := 0;
  PFXR.Distance := '';
  PFXR.Azimuth := '';
end;

end.
