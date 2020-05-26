unit dmMainFunc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, DB, LazUTF8, LCLProc, LCLType, Graphics,
  DBGrids, FileUtil, qso_record;

type
  Tdm_MainFunc = class(TDataModule)
  private

  public
    procedure SearchPrefix(CallName, Grid: string;
      var Country, ARRLPrefix, Prefix, CQZone, ITUZone, Continent,
      Latitude, Longitude, Distance, Azimuth: string);
    procedure GetDistAzim(la, lo: string; var Distance, Azimuth: string);
    procedure SearchCallInLog(CallName: string; var setColors: TColor;
      var OMName, OMQTH, Grid, State, IOTA, QSLManager: string; var Query: TSQLQuery);
    procedure SetGrid(var DBGRID: TDBGrid);
    procedure CheckDXCC(callsign, mode, band: string; var DMode, DBand, DCall: boolean);
    procedure CheckQSL(callsign, band, mode: string; var QSL: integer);
    procedure FindLanguageFiles(Dir: string; var LangList: TStringList);
    procedure FindCountryFlag(Country: string);
    procedure SaveQSO(var SQSO: TQSO);
    procedure GetLatLon(Latitude, Longitude: String; var Lat, Lon:String);
    procedure StartEQSLThread(Login, Password, Callsign: string;
      QSODate, QSOTime: TDateTime;
      QSOBand, QSOMode, QSOSubMode, QSOReportSent, QSLInfo: string);
    procedure StartHRDLogThread(Login, Password, Callsign: string;
      QSODate, QSOTime: TDateTime;
      QSOBand, QSOMode, QSOSubMode, QSOReportSent, QSOReportRcv, Grid, QSLInfo: string);
    function FindWorkedCall(callsign, band, mode: string): boolean;
    function WorkedLoTW(callsign, band, mode: string): boolean;
    function WorkedQSL(callsign, band, mode: string): boolean;
    function FindDXCC(callsign: string): integer;
    function FindISOCountry(Country: string): string;
    function FindCountry(ISOCode: string): string;

  end;

var
  dm_MainFunc: Tdm_MainFunc;

implementation

uses MainForm_U, dmFunc_U, const_u, ResourceStr, hrdlog,
  hamqth, clublog, qrzcom, eqsl;

{$R *.lfm}

procedure Tdm_MainFunc.GetLatLon(Latitude, Longitude: String; var Lat, Lon:String);
begin
    if (UTF8Pos('W', Longitude) <> 0) then
      Longitude := '-' + Longitude;
    if (UTF8Pos('S', Latitude) <> 0) then
      Latitude := '-' + Latitude;
    Delete(Latitude, length(Latitude), 1);
    Delete(Longitude, length(Longitude), 1);
    Lat:=Latitude;
    Lon:=Longitude;
end;

procedure Tdm_MainFunc.StartEQSLThread(Login, Password, Callsign: string;
  QSODate, QSOTime: TDateTime;
  QSOBand, QSOMode, QSOSubMode, QSOReportSent, QSLInfo: string);
begin
  SendEQSLThread := TSendEQSLThread.Create;
  if Assigned(SendEQSLThread.FatalException) then
    raise SendEQSLThread.FatalException;
  with SendEQSLThread do
  begin
    userid := Login;
    userpwd := Password;
    call := Callsign;
    startdate := QSODate;
    starttime := QSOTime;
    freq := QSOBand;
    mode := QSOMode;
    submode := QSOSubMode;
    rst := QSOReportSent;
    qslinf := QSLInfo;
    Start;
  end;
end;

procedure Tdm_MainFunc.StartHRDLogThread(Login, Password, Callsign: string;
  QSODate, QSOTime: TDateTime;
  QSOBand, QSOMode, QSOSubMode, QSOReportSent, QSOReportRcv, Grid, QSLInfo: string);
begin
  SendHRDThread := TSendHRDThread.Create;
  if Assigned(SendHRDThread.FatalException) then
    raise SendHRDThread.FatalException;
  with SendHRDThread do
  begin
    userid := Login;
    userpwd := Password;
    call := Callsign;
    startdate := QSODate;
    starttime := QSOTime;
    freq := QSOBand;
    mode := QSOMode;
    submode := QSOSubMode;
    rsts := QSOReportSent;
    rstr := QSOReportRcv;
    locat := Grid;
    qslinf := QSLInfo;
    Start;
  end;
end;

procedure Tdm_MainFunc.SaveQSO(var SQSO: TQSO);
var
  Query: TSQLQuery;
begin
  try
    Query := TSQLQuery.Create(nil);
    Query.Transaction := MainForm.SQLTransaction1;

    if MainForm.MySQLLOGDBConnection.Connected then
      Query.DataBase := MainForm.MySQLLOGDBConnection
    else
      Query.DataBase := MainForm.SQLiteDBConnection;

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
      Params.ParamByName('SRX').AsInteger := SQSO.SRX;
      Params.ParamByName('SRX_STRING').AsString := SQSO.SRX_String;
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
    MainForm.SQLTransaction1.Commit;
  finally
    Query.Free;
  end;
end;

function Tdm_MainFunc.FindISOCountry(Country: string): string;
var
  ISOList: TStringList;
  LanguageList: TStringList;
  Index: integer;
begin
  Result := '';
  try
    ISOList := TStringList.Create;
    LanguageList := TStringList.Create;
    ISOList.AddStrings(constLanguageISO);
    LanguageList.AddStrings(constLanguage);
    Index := LanguageList.IndexOf(Country);
    if Index <> -1 then
      Result := ISOList.Strings[Index]
    else
      Result := 'None';

  finally
    ISOList.Free;
    LanguageList.Free;
  end;
end;

function Tdm_MainFunc.FindCountry(ISOCode: string): string;
var
  ISOList: TStringList;
  LanguageList: TStringList;
  Index: integer;
begin
  try
    Result := '';
    ISOList := TStringList.Create;
    LanguageList := TStringList.Create;
    ISOList.AddStrings(constLanguageISO);
    LanguageList.AddStrings(constLanguage);
    Index := ISOList.IndexOf(ISOCode);
    if Index <> -1 then
      Result := LanguageList.Strings[Index]
    else
      Result := 'None';

  finally
    ISOList.Free;
    LanguageList.Free;
  end;
end;

procedure Tdm_MainFunc.FindLanguageFiles(Dir: string; var LangList: TStringList);
begin
  LangList := FindAllFiles(Dir, 'ewlog.*.po', False, faNormal);
  LangList.Text := StringReplace(LangList.Text, Dir + DirectorySeparator +
    'ewlog.', '', [rfreplaceall]);
  LangList.Text := StringReplace(LangList.Text, '.po', '', [rfreplaceall]);
end;

procedure Tdm_MainFunc.FindCountryFlag(Country: string);
var
  pImage: TPortableNetworkGraphic;
begin
  try
    pImage := TPortableNetworkGraphic.Create;
    pImage.LoadFromLazarusResource(dmFunc.ReplaceCountry(Country));
    if MainForm.FlagSList.IndexOf(dmFunc.ReplaceCountry(Country)) = -1 then
    begin
      MainForm.FlagList.Add(pImage, nil);
      MainForm.FlagSList.Add(dmFunc.ReplaceCountry(Country));
    end;
  except
    on EResNotFound do
    begin
      pImage.LoadFromLazarusResource('Unknown');
      if MainForm.FlagSList.IndexOf('Unknown') = -1 then
      begin
        MainForm.FlagList.Add(pImage, nil);
        MainForm.FlagSList.Add('Unknown');
      end;
    end;
  end;
  pImage.Free;
end;

procedure Tdm_MainFunc.SearchPrefix(CallName, Grid: string;
  var Country, ARRLPrefix, Prefix, CQZone, ITUZone, Continent, Latitude,
  Longitude, Distance, Azimuth: string);
var
  i, j: integer;
  La, Lo: currency;
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
    if (Grid <> '') and dmFunc.IsLocOK(Grid) then
    begin
      dmFunc.CoordinateFromLocator(Grid, La, Lo);
      Latitude := CurrToStr(La);
      Longitude := CurrToStr(Lo);
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
      if (Grid <> '') and dmFunc.IsLocOK(Grid) then
      begin
        dmFunc.CoordinateFromLocator(Grid, La, Lo);
        Latitude := CurrToStr(La);
        Longitude := CurrToStr(Lo);
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
      if (Grid <> '') and dmFunc.IsLocOK(Grid) then
      begin
        dmFunc.CoordinateFromLocator(Grid, La, Lo);
        Latitude := CurrToStr(La);
        Longitude := CurrToStr(Lo);
      end;
      GetDistAzim(Latitude, Longitude, Distance, Azimuth);
      Exit;
    end;
  end;
end;

procedure Tdm_MainFunc.GetDistAzim(la, lo: string; var Distance, Azimuth: string);
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

procedure Tdm_MainFunc.SearchCallInLog(CallName: string; var setColors: TColor;
  var OMName, OMQTH, Grid, State, IOTA, QSLManager: string; var Query: TSQLQuery);
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

procedure Tdm_MainFunc.SetGrid(var DBGRID: TDBGrid);
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

function Tdm_MainFunc.WorkedQSL(callsign, band, mode: string): boolean;
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

    if MainForm.MySQLLOGDBConnection.Connected then
      Query.DataBase := MainForm.MySQLLOGDBConnection
    else
      Query.DataBase := MainForm.SQLiteDBConnection;
    Query.Transaction := MainForm.SQLTransaction1;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LogTable +
      ' WHERE `Call` = ' + QuotedStr(callsign) + ' AND DigiBand = ' +
      FloatToStr(digiBand) + ' AND (LoTWRec = 1 OR QSLRec = 1) LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
      Result := True;

  finally
    Query.Free;
  end;
end;

function Tdm_MainFunc.WorkedLoTW(callsign, band, mode: string): boolean;
var
  Query: TSQLQuery;
  digiBand: double;
  nameBand: string;
  dxcc: integer;
begin
  Result := False;
  if Pos('M', band) > 0 then
    NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(band, mode))
  else
    nameBand := band;

  Delete(nameBand, length(nameBand) - 2, 1);
  digiBand := dmFunc.GetDigiBandFromFreq(nameBand);
  try
    dxcc := FindDXCC(callsign);
    Query := TSQLQuery.Create(nil);

    if MainForm.MySQLLOGDBConnection.Connected then
      Query.DataBase := MainForm.MySQLLOGDBConnection
    else
      Query.DataBase := MainForm.SQLiteDBConnection;
    Query.Transaction := MainForm.SQLTransaction1;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LogTable +
      ' WHERE DXCC = ' + IntToStr(dxcc) + ' AND DigiBand = ' +
      FloatToStr(digiBand) + ' AND (LoTWRec = 1 OR QSLRec = 1) LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
      Result := True;

  finally
    Query.Free;
  end;
end;

function Tdm_MainFunc.FindWorkedCall(callsign, band, mode: string): boolean;
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

    if MainForm.MySQLLOGDBConnection.Connected then
      Query.DataBase := MainForm.MySQLLOGDBConnection
    else
      Query.DataBase := MainForm.SQLiteDBConnection;
    Query.Transaction := MainForm.SQLTransaction1;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LogTable +
      ' WHERE `Call` = ' + QuotedStr(callsign) + ' AND DigiBand = ' +
      FloatToStr(digiBand) + ' AND QSOMode = ' + QuotedStr(mode) + ' LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
      Result := True;

  finally
    Query.Free;
  end;
end;

function Tdm_MainFunc.FindDXCC(callsign: string): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to PrefixARRLCount do
  begin
    if (MainForm.PrefixExpARRLArray[i].reg.Exec(callsign)) and
      (MainForm.PrefixExpARRLArray[i].reg.Match[0] = callsign) then
    begin
      with MainForm.PrefixQuery do
      begin
        Close;
        SQL.Text := 'SELECT DXCC, Status from CountryDataEx where _id = "' +
          IntToStr(MainForm.PrefixExpARRLArray[i].id) + '"';
        Open;
        if (FieldByName('Status').AsString = 'Deleted') then
        begin
          MainForm.PrefixExpARRLArray[i].reg.ExecNext;
          Exit;
        end;
        Result := FieldByName('DXCC').AsInteger;
        Close;
      end;
    end;
  end;

  if Result = -1 then
  begin
    for i := 0 to PrefixProvinceCount do
    begin
      if (MainForm.PrefixExpProvinceArray[i].reg.Exec(callsign)) and
        (MainForm.PrefixExpProvinceArray[i].reg.Match[0] = callsign) then
      begin
        with MainForm.PrefixQuery do
        begin
          Close;
          SQL.Text := 'SELECT * from Province where _id = "' +
            IntToStr(MainForm.PrefixExpProvinceArray[i].id) + '"';
          Open;
          Result := FieldByName('DXCC').AsInteger;
          if Result <> -1 then
          begin
            Close;
            Exit;
          end;
        end;
      end;
    end;
  end;
end;

procedure Tdm_MainFunc.CheckQSL(callsign, band, mode: string; var QSL: integer);
var
  Query: TSQLQuery;
  dxcc: integer;
  digiBand: double;
  nameBand: string;
begin
  if Pos('M', band) > 0 then
    NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(band, mode))
  else
    nameBand := band;

  Delete(nameBand, length(nameBand) - 2, 1);
  digiBand := dmFunc.GetDigiBandFromFreq(nameBand);

  try
    dxcc := dm_MainFunc.FindDXCC(callsign);
    Query := TSQLQuery.Create(nil);

    if MainForm.MySQLLOGDBConnection.Connected then
      Query.DataBase := MainForm.MySQLLOGDBConnection
    else
      Query.DataBase := MainForm.SQLiteDBConnection;
    Query.Transaction := MainForm.SQLTransaction1;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LogTable +
      ' WHERE DXCC = ' + IntToStr(dxcc) + ' AND DigiBand = ' +
      FloatToStr(digiBand) + ' AND (QSLRec = 1 OR LoTWRec = 1) LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
    begin
      QSL := 0;
      Exit;
    end;
    Query.Close;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LogTable +
      ' WHERE DXCC = ' + IntToStr(dxcc) + ' LIMIT 1';
    Query.Open;
    if Query.RecordCount = 0 then
    begin
      QSL := 0;
      Exit;
    end;
    Query.Close;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LogTable +
      ' WHERE DXCC = ' + IntToStr(dxcc) + ' AND DigiBand = ' +
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

procedure Tdm_MainFunc.CheckDXCC(callsign, mode, band: string;
  var DMode, DBand, DCall: boolean);
var
  Query: TSQLQuery;
  dxcc, i: integer;
  digiBand: double;
  nameBand: string;
begin
  if Pos('M', band) > 0 then
    NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(band, mode))
  else
    nameBand := band;

  Delete(nameBand, length(nameBand) - 2, 1);
  digiBand := dmFunc.GetDigiBandFromFreq(nameBand);

  try
    dxcc := dm_MainFunc.FindDXCC(callsign);
    Query := TSQLQuery.Create(nil);
    if MainForm.MySQLLOGDBConnection.Connected then
      Query.DataBase := MainForm.MySQLLOGDBConnection
    else
      Query.DataBase := MainForm.SQLiteDBConnection;
    Query.Transaction := MainForm.SQLTransaction1;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LogTable +
      ' WHERE DXCC = ' + IntToStr(dxcc) + ' LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
      DCall := False
    else
      DCall := True;
    Query.Close;
    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LogTable +
      ' WHERE DXCC = ' + IntToStr(dxcc) + ' AND QSOMode = ' +
      QuotedStr(mode) + ' LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
      DMode := False
    else
      DMode := True;
    Query.Close;
    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LogTable +
      ' WHERE DXCC = ' + IntToStr(dxcc) + ' AND DigiBand = ' +
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

end.
