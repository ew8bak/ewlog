unit InitDB_dm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, mysql57conn, Dialogs, LogBookTable_record,
  DB_record, ResourceStr, IniFiles, RegExpr, LazUTF8;

type

  { TInitDB }

  TInitDB = class(TDataModule)
    ImbeddedCallBookConnection: TSQLite3Connection;
    MySQLConnection: TMySQL57Connection;
    SQLiteConnection: TSQLite3Connection;
    DefTransaction: TSQLTransaction;
    DefLogBookQuery: TSQLQuery;
    ServiceDBConnection: TSQLite3Connection;
    ServiceTransaction: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private

  public
    function ServiceDBInit: boolean;
    function LogbookDBInit: boolean;
    function ImbeddedCallBookInit(Use: boolean): boolean;
    function SelectLogbookTable(LogTable: string): boolean;
    function GetLogBookTable(Callsign, typeDataBase: string): boolean;
    function InitPrefix: boolean;
    procedure AllFree;
    function InitDBINI: boolean;

  end;

var
  InitDB: TInitDB;
  FilePATH: string;
  INIFile: TINIFile;
  LBRecord: TLBRecord;
  DBRecord: TDBRecord;
  CountAllRecords: integer;
  UniqueCallsList: TStringList;
  PrefixProvinceList: TStringList;
  PrefixARRLList: TStringList;
  PrefixProvinceCount: integer;
  PrefixARRLCount: integer;
  UniqueCallsCount: integer;
  SearchPrefixQuery: TSQLQuery;
  PrefixExpProvinceArray: array [0..1000] of record
    reg: TRegExpr;
    id: integer;
  end;
  PrefixExpARRLArray: array [0..1000] of record
    reg: TRegExpr;
    id: integer;
  end;

implementation

{$R *.lfm}

{ TInitDB }

procedure TInitDB.DataModuleCreate(Sender: TObject);
begin
  {$IFDEF UNIX}
  FilePATH := GetEnvironmentVariable('HOME') + '/EWLog/';
   {$ELSE}
  FilePATH := GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
   {$ENDIF UNIX}
  if not DirectoryExists(FilePATH) then
    CreateDir(FilePATH);
  INIFile := TINIFile.Create(FilePATH + 'settings.ini');
  if InitDBINI then
    if ServiceDBInit then
      if LogbookDBInit then
        if InitPrefix then
          if GetLogBookTable(DBRecord.DefCall, DBRecord.DefaultDB) then
           if not SelectLogbookTable(LBRecord.LogTable) then
            ShowMessage(rDBError);
end;

procedure TInitDB.DataModuleDestroy(Sender: TObject);
begin
  AllFree;
end;

function TInitDB.ServiceDBInit: boolean;
begin
  Result := False;
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
  if ServiceDBConnection.Connected then
    Result := True;
end;

function TInitDB.LogbookDBInit: boolean;
begin
  Result := False;
  if DBRecord.DefaultDB = 'MySQL' then
  begin
    DefTransaction.DataBase := MySQLConnection;
    MySQLConnection.HostName := DBRecord.MySQLHost;
    MySQLConnection.Port := DBRecord.MySQLPort;
    MySQLConnection.UserName := DBRecord.MySQLUser;
    MySQLConnection.Password := DBRecord.MySQLPass;
    MySQLConnection.DatabaseName := DBRecord.MySQLDBName;
    MySQLConnection.Connected := True;
    if MySQLConnection.Connected then
    begin
      DBRecord.CurrentDB := 'MySQL';
      DefLogBookQuery.DataBase := MySQLConnection;
      Result := True;
    end;
  end;
  if DBRecord.DefaultDB = 'SQLite' then
  begin
    DefTransaction.DataBase := SQLiteConnection;
    SQLiteConnection.DatabaseName := DBRecord.SQLitePATH;
    SQLiteConnection.Connected := True;
    if SQLiteConnection.Connected then
    begin
      DBRecord.CurrentDB := 'SQLite';
      DefLogBookQuery.DataBase := SQLiteConnection;
      Result := True;
    end;
  end;
end;

function TInitDB.ImbeddedCallBookInit(Use: boolean): boolean;
begin
  Result := False;
  if (FileExists(FilePATH + 'callbook.db')) and (Use) then
    ImbeddedCallBookConnection.DatabaseName := FilePATH + 'callbook.db';
  if ImbeddedCallBookConnection.Connected then
    Result := True;
end;

function TInitDB.GetLogBookTable(Callsign, typeDataBase: string): boolean;
var
  LogBookInfoQuery: TSQLQuery;
begin
  try
    try
      Result := False;
      LogBookInfoQuery := TSQLQuery.Create(nil);
      if typeDataBase = 'MySQL' then
        LogBookInfoQuery.DataBase := MySQLConnection
      else
        LogBookInfoQuery.DataBase := SQLiteConnection;
      with LogBookInfoQuery do
      begin
        Close;
        if Callsign = '' then
          SQL.Text := 'SELECT * FROM LogBookInfo LIMIT 1'
        else
          SQL.Text := 'SELECT * FROM LogBookInfo WHERE CallName = "' + Callsign + '"';
        Open;
        LBRecord.Discription := FieldByName('Discription').AsString;
        LBRecord.CallSign := FieldByName('CallName').AsString;
        LBRecord.OpName := FieldByName('Name').AsString;
        LBRecord.OpQTH := FieldByName('QTH').AsString;
        LBRecord.OpITU := FieldByName('ITU').AsString;
        LBRecord.OpLoc := FieldByName('Loc').AsString;
        LBRecord.OpCQ := FieldByName('CQ').AsString;
        LBRecord.OpLat := FieldByName('Lat').AsString;
        LBRecord.OpLon := FieldByName('Lon').AsString;
        LBRecord.QSLInfo := FieldByName('QSLInfo').AsString;
        LBRecord.LogTable := FieldByName('LogTable').AsString;
        LBRecord.eQSLccLogin := FieldByName('EQSLLogin').AsString;
        LBRecord.eQSLccPassword := FieldByName('EQSLPassword').AsString;
        LBRecord.LoTWLogin := FieldByName('LoTW_User').AsString;
        LBRecord.LoTWPassword := FieldByName('LoTW_Password').AsString;
        LBRecord.AutoEQSLcc := FieldByName('AutoEQSLcc').AsBoolean;
        LBRecord.HRDLogin := FieldByName('HRDLogLogin').AsString;
        LBRecord.HRDCode := FieldByName('HRDLogPassword').AsString;
        LBRecord.AutoHRDLog := FieldByName('AutoHRDLog').AsBoolean;
        LBRecord.HamQTHLogin := FieldByName('HamQTHLogin').AsString;
        LBRecord.HamQTHPassword := FieldByName('HamQTHPassword').AsString;
        LBRecord.AutoHamQTH := FieldByName('AutoHamQTH').AsBoolean;
        LBRecord.ClubLogLogin := FieldByName('ClubLog_User').AsString;
        LBRecord.ClubLogPassword := FieldByName('ClubLog_Password').AsString;
        LBRecord.AutoClubLog := FieldByName('AutoClubLog').AsBoolean;
        LBRecord.QRZComLogin := FieldByName('QRZCOM_User').AsString;
        LBRecord.QRZComPassword := FieldByName('QRZCOM_Password').AsString;
        LBRecord.AutoQRZCom := FieldByName('AutoQRZCom').AsBoolean;
        Close;
      end;
      Result := True;
    except
      on E: Exception do
      begin
        ShowMessage('Error: ' + E.ClassName + #13#10 + E.Message);
        Result := False;
      end;
    end;
  finally
    FreeAndNil(LogBookInfoQuery);
  end;
end;

function TInitDB.InitPrefix: boolean;
var
  i: integer;
  PrefixProvinceQuery: TSQLQuery;
  PrefixARRLQuery: TSQLQuery;
  UniqueCallsQuery: TSQLQuery;
begin
  Result := False;
  try
    try
      PrefixProvinceQuery := TSQLQuery.Create(nil);
      PrefixARRLQuery := TSQLQuery.Create(nil);
      UniqueCallsQuery := TSQLQuery.Create(nil);
      PrefixProvinceQuery.PacketRecords := 1000;
      PrefixARRLQuery.PacketRecords := 1000;
      UniqueCallsQuery.PacketRecords := 10000;
      PrefixProvinceList := TStringList.Create;
      PrefixARRLList := TStringList.Create;
      UniqueCallsList := TStringList.Create;
      PrefixProvinceQuery.DataBase := InitDB.ServiceDBConnection;
      PrefixARRLQuery.DataBase := InitDB.ServiceDBConnection;
      UniqueCallsQuery.DataBase := InitDB.ServiceDBConnection;
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
      Result := True;
    except
      on E: Exception do
      begin
        ShowMessage('Error: ' + E.ClassName + #13#10 + E.Message);
        Result := False;
      end;
    end;

  finally
    FreeAndNil(PrefixProvinceQuery);
    FreeAndNil(PrefixARRLQuery);
    FreeAndNil(UniqueCallsQuery);
  end;
end;

function TInitDB.InitDBINI: boolean;
begin
  Result := False;
  DBRecord.InitDB := INIFile.ReadString('SetLog', 'LogBookInit', '');
  if DBRecord.InitDB = 'YES' then
  begin
    DBRecord.DefCall := INIFile.ReadString('SetLog', 'DefaultCallLogBook', '');
    DBRecord.DefaultDB := INIFile.ReadString('DataBases', 'DefaultDataBase', '');
    DBRecord.MySQLUser := INIFile.ReadString('DataBases', 'LoginName', '');
    DBRecord.MySQLPass := INIFile.ReadString('DataBases', 'Password', '');
    DBRecord.MySQLHost := INIFile.ReadString('DataBases', 'HostAddr', '');
    DBRecord.MySQLPort := INIFile.ReadInteger('DataBases', 'Port', 3306);
    DBRecord.MySQLDBName := INIFile.ReadString('DataBases', 'DataBaseName', '');
    DBRecord.SQLitePATH := INIFile.ReadString('DataBases', 'FileSQLite', '');

    if not FileExists(DBRecord.SQLitePATH) and (DBRecord.SQLitePATH <> '') then
    begin
      ShowMessage(rNoLogFileFound);
      exit;
    end;
    Result := True;
  end;
end;

function TInitDB.SelectLogbookTable(LogTable: string): boolean;
begin
  try
    Result := False;
    DefLogBookQuery.Close;
    DefLogBookQuery.SQL.Text := 'SELECT COUNT(*) FROM ' + LogTable;
    DefLogBookQuery.Open;
    CountAllRecords := DefLogBookQuery.Fields[0].AsInteger;
    DefLogBookQuery.Close;

    if DBRecord.DefaultDB = 'MySQL' then
    begin
      DefLogBookQuery.SQL.Text :=
        'SELECT `UnUsedIndex`, `CallSign`,' +
        ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
        + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
        + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
        + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
        + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
        + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
        + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
        + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
        + '`LoTWSent`) AS QSLs FROM ' + LogTable +
        ' ORDER BY UNIX_TIMESTAMP(STR_TO_DATE(QSODate, ''%Y-%m-%d'')) DESC, QSOTime DESC';
    end
    else
    begin
      DefLogBookQuery.SQL.Text :=
        'SELECT `UnUsedIndex`, `CallSign`,' +
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
        LogTable + ' ORDER BY QSODate2 DESC, QSOTime2 DESC) as lim USING(UnUsedIndex)';
    end;
    DefLogBookQuery.Open;
    Result := True;
  except
    on E: Exception do
    begin
      ShowMessage('Error: ' + E.ClassName + #13#10 + E.Message);
      Result := False;
    end;
  end;
end;

procedure TInitDB.AllFree;
var
  i: integer;
begin
  FreeAndNil(PrefixProvinceList);
  FreeAndNil(PrefixARRLList);
  FreeAndNil(UniqueCallsList);
  FreeAndNil(SearchPrefixQuery);
  for i := 0 to 1000 do
  begin
    FreeAndNil(PrefixExpARRLArray[i].reg);
    FreeAndNil(PrefixExpProvinceArray[i].reg);
  end;
end;

end.
