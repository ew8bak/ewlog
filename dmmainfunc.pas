unit dmMainFunc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, sqlite3conn, DB, LazUTF8, LCLProc, LCLType,
  Graphics, DBGrids, FileUtil, qso_record, LogBookTable_record, RegExpr,
  Dialogs, prefix_record, old_record, wsjt_record;

type

  { Tdm_MainFunc }

  Tdm_MainFunc = class(TDataModule)
    LogBookInfoQuery: TSQLQuery;
    ServiceDBConnection: TSQLite3Connection;
    ServiceTransaction: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    OldInfoCall: string;
    PrefixProvinceCount: integer;
    PrefixARRLCount: integer;
    UniqueCallsCount: integer;
    UniqueCallsList: TStringList;
    PrefixProvinceList: TStringList;
    PrefixARRLList: TStringList;
    SearchPrefixQuery: TSQLQuery;
    PrefixExpProvinceArray: array [0..1000] of record
      reg: TRegExpr;
      id: integer;
    end;
    PrefixExpARRLArray: array [0..1000] of record
      reg: TRegExpr;
      id: integer;
    end;

  public
    function GetModeFromFreq(MHz: string): string;
    procedure WSJTtoForm(Save: boolean);
    procedure ShowOldQSO(DBGRID: TDBGrid);
    procedure FreePrefix;
    procedure ServiceDBInit;
    procedure InitPrefix;
    procedure GetLogBookTable(Callsign: string);
    procedure SearchPrefix(CallName, Grid: string);
    procedure GetDistAzim(la, lo: string; var Distance, Azimuth: string);
    procedure SearchCallInLog(CallName: string; var setColors: TColor;
      var OMName, OMQTH, Grid, State, IOTA, QSLManager: string; var Query: TSQLQuery);
    procedure SetGrid(var DBGRID: TDBGrid);
    procedure CheckDXCC(callsign, mode, band: string; var DMode, DBand, DCall: boolean);
    procedure CheckQSL(callsign, band, mode: string; var QSL: integer);
    procedure FindLanguageFiles(Dir: string; var LangList: TStringList);
    procedure FindCountryFlag(Country: string);
    procedure SaveQSO(var SQSO: TQSO);
    procedure GetLatLon(Latitude, Longitude: string; var Lat, Lon: string);
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
    function SearchCountry(CallName: string; Province: boolean): string;

  end;

var
  dm_MainFunc: Tdm_MainFunc;
  FilePATH: string;
  LBParam: TLBParam;
  PFXR: TPFXR;
  OldRec: TOldQSOR;
  WSJTR: TWSJTR;

implementation

uses MainForm_U, dmFunc_U, const_u, ResourceStr, hrdlog,
  hamqth, clublog, qrzcom, eqsl, MinimalForm_U, InformationForm_U;

{$R *.lfm}

procedure Tdm_MainFunc.DataModuleCreate(Sender: TObject);
begin
  {$IFDEF UNIX}
  FilePATH := GetEnvironmentVariable('HOME') + '/EWLog/';
  {$ELSE}
  FilePATH := GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
  {$ENDIF UNIX}
  if not DirectoryExists(FilePATH) then
    CreateDir(FilePATH);
  SearchPrefixQuery := TSQLQuery.Create(nil);
  OldInfoCall := '';
end;

procedure Tdm_MainFunc.DataModuleDestroy(Sender: TObject);
begin
  FreePrefix;
end;

function Tdm_MainFunc.GetModeFromFreq(MHz: string): string;
var
  Band: string;
  tmp: extended;
  Query: TSQLQuery;
begin
  Result := '';
  try
    Query := TSQLQuery.Create(nil);
    Query.DataBase := ServiceDBConnection;
    band := dmFunc.GetBandFromFreq(MHz);
    MHz := MHz.replace('.', DefaultFormatSettings.DecimalSeparator);
    MHz := MHz.replace(',', DefaultFormatSettings.DecimalSeparator);
    Query.SQL.Text := 'SELECT * FROM Bands WHERE band = ' + QuotedStr(band);
    Query.Open;
    tmp := StrToFloat(MHz);

    if Query.RecordCount > 0 then
    begin
      if ((tmp >= Query.FieldByName('B_BEGIN').AsCurrency) and
        (tmp <= Query.FieldByName('CW').AsCurrency)) then
        Result := 'CW'
      else
      begin
        if ((tmp > Query.FieldByName('DIGI').AsCurrency) and
          (tmp <= Query.FieldByName('SSB').AsCurrency)) then
          Result := 'DIGI'
        else
        begin
          if (tmp > 5) and (tmp < 6) then
            Result := 'USB'
          else
          begin
            if tmp > 10 then
              Result := 'USB'
            else
              Result := 'LSB';
          end;
        end;
      end;
    end
  finally
    Query.Close;
    Query.Free;
  end;
end;

procedure Tdm_MainFunc.WSJTtoForm(Save: boolean);
begin
  if WSJTR.Call.Length > 2 then
  begin
    if WSJTR.Call <> OldInfoCall then
      if MainForm.CallBookLiteConnection.Connected = False then
        InformationForm.GetInformation(WSJTR.Call, True);
    OldInfoCall := WSJTR.Call;
    if Minimal then
    begin
      MinimalForm.EditButton1.Text := WSJTR.Call;
      MinimalForm.Edit3.Text := WSJTR.Grid;
      MinimalForm.ComboBox1.Text := WSJTR.Freq;
      MinimalForm.ComboBox2.Text := WSJTR.Mode;
      MinimalForm.ComboBox3.Text := WSJTR.SubMode;
      MinimalForm.ComboBox4.Text := WSJTR.RSTs;
      if Save then
      begin
        MinimalForm.CheckBox1.Checked := False;
        MinimalForm.ComboBox5.Text := WSJTR.RSTr;
        MinimalForm.DateEdit1.Date := WSJTR.Date;
        MinimalForm.DateTimePicker1.Time := WSJTR.Date;
        MinimalForm.Edit11.Text := WSJTR.Comment;
        MinimalForm.SpeedButton1.Click;
        MinimalForm.CheckBox1.Checked := True;
      end;
    end
    else
    begin
      MainForm.EditButton1.Text := WSJTR.Call;
      MainForm.Edit3.Text := WSJTR.Grid;
      MainForm.ComboBox1.Text := WSJTR.Freq;
      MainForm.ComboBox2.Text := WSJTR.Mode;
      MainForm.ComboBox9.Text := WSJTR.SubMode;
      MainForm.ComboBox4.Text := WSJTR.RSTs;
      if Save then
      begin
        MainForm.CheckBox1.Checked := False;
        MainForm.ComboBox5.Text := WSJTR.RSTr;
        MainForm.DateEdit1.Date := WSJTR.Date;
        MainForm.DateTimePicker1.Time := WSJTR.Date;
        MainForm.Edit11.Text := WSJTR.Comment;
        MainForm.SpeedButton8.Click;
        MainForm.CheckBox1.Checked := True;
      end;
    end;
  end
  else
  begin
    if Minimal then
      MinimalForm.Clr
    else
      MainForm.Clr;
  end;
end;

procedure Tdm_MainFunc.ShowOldQSO(DBGRID: TDBGrid);
begin
  OldRec.Num := IntToStr(DBGRID.DataSource.DataSet.RecordCount);
  OldRec.Date := DBGRID.DataSource.DataSet.FieldByName('QSODate').AsString;
  OldRec.Time := DBGRID.DataSource.DataSet.FieldByName('QSOTime').AsString;
  OldRec.Frequency := DBGRID.DataSource.DataSet.FieldByName('QSOBand').AsString;
  OldRec.Mode := DBGRID.DataSource.DataSet.FieldByName('QSOMode').AsString;
  OldRec.Name := DBGRID.DataSource.DataSet.FieldByName('OMName').AsString;
end;

procedure Tdm_MainFunc.ServiceDBInit;
begin
  ServiceDBConnection.Connected := False;
  if not FileExists(FilePATH + 'serviceLOG.db') then
    ServiceDBConnection.DatabaseName :=
      ExtractFileDir(ParamStr(0)) + DirectorySeparator + 'serviceLOG.db'
  else
    ServiceDBConnection.DatabaseName := FilePATH + 'serviceLOG.db';
    {$IFDEF LINUX}
  if not FileExists(ServiceDBConnection.DatabaseName) then
    ServiceDBConnection.DatabaseName := '/usr/share/ewlog/serviceLOG.db';
    {$ENDIF LINUX}
  if not FileExists(ServiceDBConnection.DatabaseName) then
  begin
    ShowMessage(rErrorServiceDB);
    Exit;
  end;
  ServiceDBConnection.Transaction := ServiceTransaction;
  ServiceDBConnection.Connected := True;
  SearchPrefixQuery.DataBase := ServiceDBConnection;
end;

procedure Tdm_MainFunc.InitPrefix;
var
  i: integer;
  PrefixProvinceQuery: TSQLQuery;
  PrefixARRLQuery: TSQLQuery;
  UniqueCallsQuery: TSQLQuery;
begin
  try
    PrefixProvinceQuery := TSQLQuery.Create(nil);
    PrefixARRLQuery := TSQLQuery.Create(nil);
    UniqueCallsQuery := TSQLQuery.Create(nil);
    PrefixProvinceQuery.PacketRecords := 2000;
    PrefixARRLQuery.PacketRecords := 2000;
    UniqueCallsQuery.PacketRecords := 10000;
    PrefixProvinceList := TStringList.Create;
    PrefixARRLList := TStringList.Create;
    UniqueCallsList := TStringList.Create;
    PrefixProvinceQuery.DataBase := ServiceDBConnection;
    PrefixARRLQuery.DataBase := ServiceDBConnection;
    UniqueCallsQuery.DataBase := ServiceDBConnection;
    PrefixProvinceQuery.SQL.Text :=
      'SELECT _id, PrefixList FROM Province WHERE EndDate == ""';
    PrefixARRLQuery.SQL.Text :=
      'SELECT _id, PrefixList, Status FROM CountryDataEx WHERE EndDate == ""';
    UniqueCallsQuery.SQL.Text := 'SELECT Callsign FROM UniqueCalls';
    PrefixProvinceQuery.Active := True;
    PrefixARRLQuery.Active := True;
    UniqueCallsQuery.Active := True;
    PrefixProvinceCount := PrefixProvinceQuery.RecordCount;
    PrefixARRLCount := PrefixARRLQuery.RecordCount;
    UniqueCallsCount := UniqueCallsQuery.RecordCount;
    PrefixProvinceQuery.First;
    PrefixARRLQuery.First;
    UniqueCallsQuery.First;
    for i := 0 to PrefixProvinceCount do
    begin
      PrefixProvinceList.Add(PrefixProvinceQuery.FieldByName('PrefixList').AsString);
      PrefixExpProvinceArray[i].reg := TRegExpr.Create;
      PrefixExpProvinceArray[i].reg.Expression := PrefixProvinceList.Strings[i];
      PrefixExpProvinceArray[i].id := PrefixProvinceQuery.FieldByName('_id').AsInteger;
      PrefixProvinceQuery.Next;
    end;
    for i := 0 to PrefixARRLCount do
    begin
      PrefixARRLList.Add(PrefixARRLQuery.FieldByName('PrefixList').AsString);
      PrefixExpARRLArray[i].reg := TRegExpr.Create;
      PrefixExpARRLArray[i].reg.Expression := PrefixARRLList.Strings[i];
      PrefixExpARRLArray[i].id := PrefixARRLQuery.FieldByName('_id').AsInteger;
      PrefixARRLQuery.Next;
    end;
    for i := 0 to UniqueCallsCount do
    begin
      UniqueCallsList.Add(UniqueCallsQuery.FieldByName('Callsign').AsString);
      UniqueCallsQuery.Next;
    end;

  finally
    PrefixProvinceQuery.Free;
    PrefixARRLQuery.Free;
    UniqueCallsQuery.Free;
  end;

end;

procedure Tdm_MainFunc.GetLogBookTable(Callsign: string);
begin
  with LogBookInfoQuery do
  begin
    Close;
    if Callsign = '' then
      SQL.Text := 'SELECT * FROM LogBookInfo LIMIT 1'
    else
      SQL.Text := 'SELECT * FROM LogBookInfo WHERE CallName = "' + Callsign + '"';
    Open;
    LBParam.Discription := FieldByName('Discription').AsString;
    LBParam.CallSign := FieldByName('CallName').AsString;
    LBParam.OpName := FieldByName('Name').AsString;
    LBParam.OpQTH := FieldByName('QTH').AsString;
    LBParam.OpITU := FieldByName('ITU').AsString;
    LBParam.OpLoc := FieldByName('Loc').AsString;
    LBParam.OpCQ := FieldByName('CQ').AsString;
    LBParam.OpLat := FieldByName('Lat').AsString;
    LBParam.OpLon := FieldByName('Lon').AsString;
    LBParam.QSLInfo := FieldByName('QSLInfo').AsString;
    LBParam.LogTable := FieldByName('LogTable').AsString;
    LBParam.eQSLccLogin := FieldByName('EQSLLogin').AsString;
    LBParam.eQSLccPassword := FieldByName('EQSLPassword').AsString;
    LBParam.LoTWLogin := FieldByName('LoTW_User').AsString;
    LBParam.LoTWPassword := FieldByName('LoTW_Password').AsString;
    LBParam.AutoEQSLcc := FieldByName('AutoEQSLcc').AsBoolean;
    LBParam.HRDLogin := FieldByName('HRDLogLogin').AsString;
    LBParam.HRDCode := FieldByName('HRDLogPassword').AsString;
    LBParam.AutoHRDLog := FieldByName('AutoHRDLog').AsBoolean;
    LBParam.HamQTHLogin := FieldByName('HamQTHLogin').AsString;
    LBParam.HamQTHPassword := FieldByName('HamQTHPassword').AsString;
    LBParam.AutoHamQTH := FieldByName('AutoHamQTH').AsBoolean;
    LBParam.ClubLogLogin := FieldByName('ClubLog_User').AsString;
    LBParam.ClubLogPassword := FieldByName('ClubLog_Password').AsString;
    LBParam.AutoClubLog := FieldByName('AutoClubLog').AsBoolean;
    LBParam.QRZComLogin := FieldByName('QRZCOM_User').AsString;
    LBParam.QRZComPassword := FieldByName('QRZCOM_Password').AsString;
    LBParam.AutoQRZCom := FieldByName('AutoQRZCom').AsBoolean;
    Close;
  end;
end;

procedure Tdm_MainFunc.GetLatLon(Latitude, Longitude: string; var Lat, Lon: string);
begin
  if (UTF8Pos('W', Longitude) <> 0) then
    Longitude := '-' + Longitude;
  if (UTF8Pos('S', Latitude) <> 0) then
    Latitude := '-' + Latitude;
  Delete(Latitude, length(Latitude), 1);
  Delete(Longitude, length(Longitude), 1);
  Lat := Latitude;
  Lon := Longitude;
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

procedure Tdm_MainFunc.SearchPrefix(CallName, Grid: string);
var
  i, j: integer;
  La, Lo: currency;
begin
  if UniqueCallsList.IndexOf(CallName) > -1 then
  begin
    with SearchPrefixQuery do
    begin
      Close;
      SQL.Text := 'select * from UniqueCalls where _id = "' +
        IntToStr(UniqueCallsList.IndexOf(CallName)) + '"';
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
    Exit;
  end;

  for i := 0 to PrefixProvinceCount do
  begin
    if (PrefixExpProvinceArray[i].reg.Exec(CallName)) and
      (PrefixExpProvinceArray[i].reg.Match[0] = CallName) then
    begin
      with SearchPrefixQuery do
      begin
        Close;
        SQL.Text := 'select * from Province where _id = "' +
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
      Exit;
    end;
  end;

  for j := 0 to PrefixARRLCount do
  begin
    if (PrefixExpARRLArray[j].reg.Exec(CallName)) and
      (PrefixExpARRLArray[j].reg.Match[0] = CallName) then
    begin
      with SearchPrefixQuery do
      begin
        Close;
        SQL.Text := 'select * from CountryDataEx where _id = "' +
          IntToStr(PrefixExpARRLArray[j].id) + '"';
        Open;
        if (FieldByName('Status').AsString = 'Deleted') then
        begin
          PrefixExpARRLArray[j].reg.ExecNext;
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
      Exit;
    end;
  end;
end;

function Tdm_MainFunc.SearchCountry(CallName: string; Province: boolean): string;
var
  i, j: integer;
  PrefixQuery: TSQLQuery;
begin
  try
    PrefixQuery := TSQLQuery.Create(nil);
    PrefixQuery.DataBase := ServiceDBConnection;
    if Province then
    begin
      for i := 0 to PrefixProvinceCount do
      begin
        if (PrefixExpProvinceArray[i].reg.Exec(CallName)) and
          (PrefixExpProvinceArray[i].reg.Match[0] = CallName) then
        begin
          with PrefixQuery do
          begin
            SQL.Text := 'SELECT * FROM Province WHERE _id = "' +
              IntToStr(PrefixExpProvinceArray[i].id) + '"';
            Open;
            Result := FieldByName('Country').AsString;
          end;
          Exit;
        end;
      end;
    end
    else
    begin
      for j := 0 to PrefixARRLCount do
      begin
        if (PrefixExpARRLArray[j].reg.Exec(CallName)) and
          (PrefixExpARRLArray[j].reg.Match[0] = CallName) then
        begin
          with PrefixQuery do
          begin
            SQL.Text := 'SELECT * FROM CountryDataEx WHERE _id = "' +
              IntToStr(PrefixExpARRLArray[j].id) + '"';
            Open;
            if (FieldByName('Status').AsString = 'Deleted') then
            begin
              PrefixExpARRLArray[j].reg.ExecNext;
              Exit;
            end;
          end;
          Result := PrefixQuery.FieldByName('Country').AsString;
          Exit;
        end;
      end;
    end;

  finally
    PrefixQuery.Free;
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
  dmFunc.DistanceFromCoordinate(LBParam.OpLoc, StrToFloat(la),
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
      + '`LoTWSent`) AS QSLs FROM ' + LBParam.LogTable + ' WHERE `Call` LIKE ' +
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
      + LBParam.LogTable +
      ' INNER JOIN (SELECT UnUsedIndex, QSODate as QSODate2, QSOTime as QSOTime2 from ' +
      LBParam.LogTable + ' WHERE `Call` LIKE ' + QuotedStr(CallName) +
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

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBParam.LogTable +
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

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBParam.LogTable +
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

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBParam.LogTable +
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
  PrefixQuery: TSQLQuery;
begin
  try
    PrefixQuery := TSQLQuery.Create(nil);
    PrefixQuery.DataBase := ServiceDBConnection;
    Result := -1;
    for i := 0 to PrefixARRLCount do
    begin
      if (PrefixExpARRLArray[i].reg.Exec(callsign)) and
        (PrefixExpARRLArray[i].reg.Match[0] = callsign) then
      begin
        with PrefixQuery do
        begin
          Close;
          SQL.Text := 'SELECT DXCC, Status from CountryDataEx where _id = "' +
            IntToStr(PrefixExpARRLArray[i].id) + '"';
          Open;
          if (FieldByName('Status').AsString = 'Deleted') then
          begin
            PrefixExpARRLArray[i].reg.ExecNext;
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
        if (PrefixExpProvinceArray[i].reg.Exec(callsign)) and
          (PrefixExpProvinceArray[i].reg.Match[0] = callsign) then
        begin
          with PrefixQuery do
          begin
            Close;
            SQL.Text := 'SELECT * from Province where _id = "' +
              IntToStr(PrefixExpProvinceArray[i].id) + '"';
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

  finally
    PrefixQuery.Free;
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

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBParam.LogTable +
      ' WHERE DXCC = ' + IntToStr(dxcc) + ' AND DigiBand = ' +
      FloatToStr(digiBand) + ' AND (QSLRec = 1 OR LoTWRec = 1) LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
    begin
      QSL := 0;
      Exit;
    end;
    Query.Close;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBParam.LogTable +
      ' WHERE DXCC = ' + IntToStr(dxcc) + ' LIMIT 1';
    Query.Open;
    if Query.RecordCount = 0 then
    begin
      QSL := 0;
      Exit;
    end;
    Query.Close;

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBParam.LogTable +
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

    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBParam.LogTable +
      ' WHERE DXCC = ' + IntToStr(dxcc) + ' LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
      DCall := False
    else
      DCall := True;
    Query.Close;
    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBParam.LogTable +
      ' WHERE DXCC = ' + IntToStr(dxcc) + ' AND QSOMode = ' +
      QuotedStr(mode) + ' LIMIT 1';
    Query.Open;
    if Query.RecordCount > 0 then
      DMode := False
    else
      DMode := True;
    Query.Close;
    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBParam.LogTable +
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

procedure Tdm_MainFunc.FreePrefix;
var
  i: integer;
begin
  FreeAndNil(PrefixProvinceList);
  FreeAndNil(PrefixARRLList);
  FreeAndNil(UniqueCallsList);
  FreeAndNil(MainForm.subModesList);
  FreeAndNil(SearchPrefixQuery);
  for i := 0 to 1000 do
  begin
    FreeAndNil(PrefixExpARRLArray[i].reg);
    FreeAndNil(PrefixExpProvinceArray[i].reg);
  end;
end;

end.
