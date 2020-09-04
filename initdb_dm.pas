unit InitDB_dm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, mysql57conn, Dialogs, LogBookTable_record,
  DB_record, ResourceStr, IniFiles, RegExpr, LazUTF8, init_record, ImbedCallBookCheckRec;

type

  { TInitDB }

  TInitDB = class(TDataModule)
    ImbeddedCallBookConnection: TSQLite3Connection;
    MySQLConnection: TMySQL57Connection;
    SQLiteConnection: TSQLite3Connection;
    DefTransaction: TSQLTransaction;
    DefLogBookQuery: TSQLQuery;
    FindQSOQuery: TSQLQuery;
    ServiceDBConnection: TSQLite3Connection;
    ServiceTransaction: TSQLTransaction;
    ImbeddedCallBookTransaction: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private

  public
    function ImbeddedCallBookCheck(PathDB: string): TImbedCallBookCheckRec;
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
  ExceptFile: TextFile;
  ExceptFilePATH: string;
  LBRecord: TLBRecord;
  DBRecord: TDBRecord;
  InitRecord: TInitRecord;
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

uses MainFuncDM, setupForm_U;

{$R *.lfm}

{ TInitDB }

procedure TInitDB.DataModuleCreate(Sender: TObject);
begin
  if Sender <> SetupForm then
  begin
  {$IFDEF UNIX}
    FilePATH := GetEnvironmentVariable('HOME') + '/EWLog/';
   {$ELSE}
    FilePATH := GetEnvironmentVariable('SystemDrive') +
      SysToUTF8(GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
   {$ENDIF UNIX}
    DefaultFormatSettings.DecimalSeparator := '.';
    if not DirectoryExists(FilePATH) then
      CreateDir(FilePATH);
    INIFile := TINIFile.Create(FilePATH + 'settings.ini');
    ExceptFilePATH := FilePATH + 'except.err';
    AssignFile(ExceptFile, ExceptFilePATH);
    if FileExists(ExceptFilePATH) then
      Append(ExceptFile)
    else
      ReWrite(ExceptFile);
  end
  else
  begin
    SQLiteConnection.Connected := False;
    MySQLConnection.Connected := False;
  end;
  InitRecord.ServiceDBInit := False;
  InitRecord.InitDBINI := False;
  InitRecord.LogbookDBInit := False;
  InitRecord.InitPrefix := False;
  InitRecord.GetLogBookTable := False;
  InitRecord.SelectLogbookTable := False;
  InitRecord.LoadINIsettings := False;

  if not ServiceDBInit then
    ShowMessage('Service database Init ERROR')
  else
  if InitDBINI and (DBRecord.InitDB = 'YES') then
    if (not LogbookDBInit) and (DBRecord.InitDB = 'YES') then
      ShowMessage('Logbook database ERROR')
    else
    if not InitPrefix then
      ShowMessage('Init Prefix ERROR')
    else
    if (not GetLogBookTable(DBRecord.DefCall, DBRecord.DefaultDB)) and
      (DBRecord.InitDB = 'YES') then
      ShowMessage('LogBook Table ERROR')
    else
    if (not SelectLogbookTable(LBRecord.LogTable)) and (DBRecord.InitDB = 'YES') then
      ShowMessage(rDBError);
  MainFunc.LoadINIsettings;
  ImbeddedCallBookInit(IniSet.UseIntCallBook);
end;

procedure TInitDB.DataModuleDestroy(Sender: TObject);
begin
  INIFile.Free;
  CloseFile(ExceptFile);
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
  begin
    Result := True;
    InitRecord.ServiceDBInit := True;
  end;
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
      FindQSOQuery.DataBase := MySQLConnection;
      Result := True;
      InitRecord.LogbookDBInit := True;
    end;
  end;
  if DBRecord.DefaultDB = 'SQLite' then
  begin
    DefTransaction.DataBase := SQLiteConnection;
    FindQSOQuery.DataBase := SQLiteConnection;
    SQLiteConnection.DatabaseName := DBRecord.SQLitePATH;
    SQLiteConnection.Connected := True;
    if SQLiteConnection.Connected then
    begin
      DBRecord.CurrentDB := 'SQLite';
      DefLogBookQuery.DataBase := SQLiteConnection;
      Result := True;
      InitRecord.LogbookDBInit := True;
    end;
  end;
end;

function TInitDB.ImbeddedCallBookInit(Use: boolean): boolean;
begin
  Result := False;
  if (FileExists(FilePATH + 'callbook.db')) and (Use) then
  begin
    ImbeddedCallBookConnection.DatabaseName := FilePATH + 'callbook.db';
    ImbeddedCallBookConnection.Connected := True;
  end
  else
    ImbeddedCallBookConnection.Connected := False;
  if ImbeddedCallBookConnection.Connected then
    Result := True;
end;

function TInitDB.ImbeddedCallBookCheck(PathDB: string): TImbedCallBookCheckRec;
var
  Query: TSQLQuery;
begin
  try
    Result.Found := False;
    if ImbeddedCallBookConnection.Connected then
      ImbeddedCallBookInit(False);
    if FileExists(PathDB) then
    begin
      try
        ImbeddedCallBookConnection.DatabaseName := PathDB;
        Query := TSQLQuery.Create(nil);
        Query.DataBase := ImbeddedCallBookConnection;
        ImbeddedCallBookConnection.Connected := True;
        Query.SQL.Text := 'SELECT COUNT(*) as Count FROM Callbook';
        Query.Open;
        Result.NumberOfRec := Query.FieldByName('Count').AsInteger;
        Query.Close;
        Query.SQL.Text := 'SELECT * FROM inform';
        Query.Open;
        Result.ReleaseDate := Query.FieldByName('date').AsString;
        Result.Version := Query.FieldByName('version').AsString;
        Query.Close;
      finally
        FreeAndNil(Query);
        ImbeddedCallBookConnection.Connected := False;
      end;
      if Result.NumberOfRec > 0 then
        Result.Found := True;
    end;

  except
    on E: Exception do
    begin
      ShowMessage('ImbeddedCallBookCheck: Error: ' + E.ClassName +
        #13#10 + E.Message);
      WriteLn(ExceptFile, 'ImbeddedCallBookCheck: Error: ' +
        E.ClassName + ':' + E.Message);
      Result.Found := False;
    end;
  end;
end;

function TInitDB.GetLogBookTable(Callsign, typeDataBase: string): boolean;
var
  LogBookInfoQuery: TSQLQuery;
begin
  Result := False;
  if DBRecord.InitDB = 'YES' then
  begin
    try
      try
        LogBookInfoQuery := TSQLQuery.Create(nil);
        if typeDataBase = 'MySQL' then
          LogBookInfoQuery.DataBase := MySQLConnection
        else
          LogBookInfoQuery.DataBase := SQLiteConnection;
        LogBookInfoQuery.Close;
        if Callsign = '' then
          LogBookInfoQuery.SQL.Text := 'SELECT * FROM LogBookInfo LIMIT 1'
        else
          LogBookInfoQuery.SQL.Text :=
            'SELECT * FROM LogBookInfo WHERE CallName = "' + Callsign + '"';
        LogBookInfoQuery.Open;

        if LogBookInfoQuery.FieldByName('CallName').AsString = '' then
        begin
          LogBookInfoQuery.Close;
          LogBookInfoQuery.SQL.Text := 'SELECT * FROM LogBookInfo LIMIT 1';
          LogBookInfoQuery.Open;
        end;

        if LogBookInfoQuery.FieldByName('CallName').AsString <> '' then
        begin
          LBRecord.Discription := LogBookInfoQuery.FieldByName('Discription').AsString;
          LBRecord.CallSign := LogBookInfoQuery.FieldByName('CallName').AsString;
          LBRecord.OpName := LogBookInfoQuery.FieldByName('Name').AsString;
          LBRecord.OpQTH := LogBookInfoQuery.FieldByName('QTH').AsString;
          LBRecord.OpITU := LogBookInfoQuery.FieldByName('ITU').AsString;
          LBRecord.OpLoc := LogBookInfoQuery.FieldByName('Loc').AsString;
          LBRecord.OpCQ := LogBookInfoQuery.FieldByName('CQ').AsString;
          LBRecord.OpLat := LogBookInfoQuery.FieldByName('Lat').AsFloat;
          LBRecord.OpLon := LogBookInfoQuery.FieldByName('Lon').AsFloat;
          LBRecord.QSLInfo := LogBookInfoQuery.FieldByName('QSLInfo').AsString;
          LBRecord.LogTable := LogBookInfoQuery.FieldByName('LogTable').AsString;
          LBRecord.eQSLccLogin := LogBookInfoQuery.FieldByName('EQSLLogin').AsString;
          LBRecord.eQSLccPassword :=
            LogBookInfoQuery.FieldByName('EQSLPassword').AsString;
          LBRecord.LoTWLogin := LogBookInfoQuery.FieldByName('LoTW_User').AsString;
          LBRecord.LoTWPassword :=
            LogBookInfoQuery.FieldByName('LoTW_Password').AsString;
          LBRecord.AutoEQSLcc := LogBookInfoQuery.FieldByName('AutoEQSLcc').AsBoolean;
          LBRecord.HRDLogin := LogBookInfoQuery.FieldByName('HRDLogLogin').AsString;
          LBRecord.HRDCode := LogBookInfoQuery.FieldByName('HRDLogPassword').AsString;
          LBRecord.AutoHRDLog := LogBookInfoQuery.FieldByName('AutoHRDLog').AsBoolean;
          LBRecord.HamQTHLogin := LogBookInfoQuery.FieldByName('HamQTHLogin').AsString;
          LBRecord.HamQTHPassword :=
            LogBookInfoQuery.FieldByName('HamQTHPassword').AsString;
          LBRecord.AutoHamQTH := LogBookInfoQuery.FieldByName('AutoHamQTH').AsBoolean;
          LBRecord.ClubLogLogin := LogBookInfoQuery.FieldByName('ClubLog_User').AsString;
          LBRecord.ClubLogPassword :=
            LogBookInfoQuery.FieldByName('ClubLog_Password').AsString;
          LBRecord.AutoClubLog := LogBookInfoQuery.FieldByName('AutoClubLog').AsBoolean;
          LBRecord.QRZComLogin := LogBookInfoQuery.FieldByName('QRZCOM_User').AsString;
          LBRecord.QRZComPassword :=
            LogBookInfoQuery.FieldByName('QRZCOM_Password').AsString;
          LBRecord.AutoQRZCom := LogBookInfoQuery.FieldByName('AutoQRZCom').AsBoolean;
          LogBookInfoQuery.Close;
          Result := True;
          InitRecord.GetLogBookTable := True;
          DBRecord.CurrCall := LBRecord.CallSign;
        end;
      except
        on E: Exception do
        begin
          ShowMessage('Error: ' + E.ClassName + #13#10 + E.Message);
          WriteLn(ExceptFile, 'GetLogBookTable:' + E.ClassName + ':' + E.Message);
          Result := False;
        end;
      end;
    finally
      FreeAndNil(LogBookInfoQuery);
    end;
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
      InitRecord.InitPrefix := True;
    except
      on E: Exception do
      begin
        ShowMessage('Error: ' + E.ClassName + #13#10 + E.Message);
        WriteLn(ExceptFile, 'InitPrefix:' + E.ClassName + ':' + E.Message);
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
  DBRecord.InitDB := INIFile.ReadString('SetLog', 'LogBookInit', 'NO');
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
    InitRecord.InitDBINI := True;
  end;
end;

function TInitDB.SelectLogbookTable(LogTable: string): boolean;
begin
  try
    Result := False;
    if LogTable = '' then
      Exit;
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
    InitRecord.SelectLogbookTable := True;
  except
    on E: Exception do
    begin
      ShowMessage('Error: ' + E.ClassName + #13#10 + E.Message);
      WriteLn(ExceptFile, 'SelectLogbookTable:' + E.ClassName + ':' + E.Message);
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
