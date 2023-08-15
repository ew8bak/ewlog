(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit InitDB_dm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, Dialogs, LogBookTable_record,
  DB_record, ResourceStr, IniFiles, RegExpr, LazUTF8, init_record, ImbedCallBookCheckRec,
  Forms, LCLType, UniqueInstance;

type
  TParamData = record
    version: string;
    portable: boolean;
  end;

type

  { TInitDB }

  TInitDB = class(TDataModule)
    ImbeddedCallBookConnection: TSQLite3Connection;
    SQLiteConnection: TSQLite3Connection;
    DefTransaction: TSQLTransaction;
    DefLogBookQuery: TSQLQuery;
    FindQSOQuery: TSQLQuery;
    ServiceDBConnection: TSQLite3Connection;
    ServiceTransaction: TSQLTransaction;
    ImbeddedCallBookTransaction: TSQLTransaction;
    UniqueInstance: TUniqueInstance;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure UniqueInstanceOtherInstance(Sender: TObject; ParamCount: integer;
      const Parameters: array of string);
  private
    ParamData: TParamData;

  public
    function ImbeddedCallBookCheck(PathDB: string): TImbedCallBookCheckRec;
    function ServiceDBInit: boolean;
    function LogbookDBInit: boolean;
    function ImbeddedCallBookInit(Use: boolean): boolean;
    function SelectLogbookTable(LogTable: string): boolean;
    function GetLogBookTable(Callsign: string): boolean;
    function InitPrefix: boolean;
    procedure AllFree;
    function InitDBINI: boolean;
    procedure CheckSQLVersion;
    function SwitchDB: boolean;
    function GetParam: TParamData;

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
  NumberSelectRecord: integer;
  UniqueCallsList: TStringList;
  PrefixProvinceList: TStringList;
  PrefixARRLList: TStringList;
  PrefixProvinceCount: integer;
  PrefixARRLCount: integer;
  UniqueCallsCount: integer;
  sqlite_version: string;
  SearchPrefixQuery: TSQLQuery;
  RadioList: TStringList;
  PrefixExpProvinceArray: array of record
    reg: TRegExpr;
    id: integer;
  end;
  PrefixExpARRLArray: array of record
    reg: TRegExpr;
    id: integer;
  end;
  function TryStrToFloatSafe(const aStr : String; out aValue : Double) : Boolean;

implementation

uses MainFuncDM, setupForm_U, ConfigForm_U, dmFunc_U, dmmigrate_u;

{$R *.lfm}

{ TInitDB }

function TInitDB.GetParam: TParamData;
begin
  Result.portable := False;
  Result.version := dmFunc.GetMyVersion;
  if ParamStr(1) = '-p' then
    Result.portable := True;
  if ParamStr(1) = '-v' then
  begin
    {$IFDEF UNIX}
    WriteLn(Result.version);
    Halt;
    {$ELSE}
    MessageDlg('Version:' + Result.version, mtInformation, mbOKCancel, 0);
    Halt;
    {$ENDIF UNIX}
  end;
end;

procedure TInitDB.DataModuleCreate(Sender: TObject);
{$IFDEF WINDOWS}
var
  tempProfileDir, tempUserDir: string;
{$ENDIF WINDOWS}
begin
  //sqlite3dyn.SQLiteDefaultLibrary:='libsqlite3.so';
  ParamData := GetParam;
  if Sender <> SetupForm then
  begin
    if not ParamData.portable then begin
      if FileExists(ExtractFilePath(ParamStr(0))+'portable') then
      ParamData.portable:=True
      else
      ParamData.portable:=False;
    end;

  {$IFDEF UNIX}
    if not ParamData.portable then
      FilePATH := GetEnvironmentVariable('HOME') + '/EWLog/'
    else
      FilePATH := ExtractFilePath(ParamStr(0));
   {$ELSE}
    if not ParamData.portable then
    begin
      tempProfileDir := dmFunc.GetUserProfilesDir;
      tempUserDir := dmFunc.GetCurrentUserName;
      FilePATH := tempProfileDir + DirectorySeparator + tempUserDir +
        DirectorySeparator + 'EWLog' + DirectorySeparator;
    end
    else
      FilePATH := ExtractFilePath(ParamStr(0));
    if dmFunc.CheckProcess('rigctld.exe') then
      dmFunc.CloseProcess('rigctld.exe');
   {$ENDIF UNIX}
    if not DirectoryExists(FilePATH) then
      CreateDir(FilePATH);

    INIFile := TINIFile.Create(FilePATH + 'settings.ini');
    ExceptFilePATH := FilePATH + 'except.err';
    AssignFile(ExceptFile, ExceptFilePATH);
    try
      if FileExists(ExceptFilePATH) then
        Append(ExceptFile)
      else
        ReWrite(ExceptFile);
    except
      on E: Exception do
      begin
        ExceptFilePATH := FilePATH + 'except.' + DateToStr(Now) + '.err';
        AssignFile(ExceptFile, ExceptFilePATH);
        if FileExists(ExceptFilePATH) then
          Append(ExceptFile)
        else
          ReWrite(ExceptFile);
      end;
    end;
  end
  else
    SQLiteConnection.Connected := False;

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
  if not InitPrefix then
    ShowMessage('Init Prefix ERROR')
  else
  if InitDBINI and (DBRecord.InitDB = 'YES') then
    if (not LogbookDBInit) and (DBRecord.InitDB = 'YES') then
      ShowMessage('Logbook database ERROR')
    else
    if (not GetLogBookTable(DBRecord.DefCall)) and
      (DBRecord.InitDB = 'YES') then
      ShowMessage('LogBook Table ERROR')
    else
    if (not SelectLogbookTable(LBRecord.LogTable)) and (DBRecord.InitDB = 'YES') then
      ShowMessage(rDBError);
  CheckSQLVersion;
  MainFunc.LoadINIsettings;
  ImbeddedCallBookInit(IniSet.UseIntCallBook);
end;

function TInitDB.SwitchDB: boolean;
begin

end;

procedure TInitDB.DataModuleDestroy(Sender: TObject);
begin
  INIFile.Free;
  CloseFile(ExceptFile);
  AllFree;
end;

procedure TInitDB.UniqueInstanceOtherInstance(Sender: TObject;
  ParamCount: integer; const Parameters: array of string);
begin
  ShowMessage(rProgramAgain);
end;

procedure TInitDB.CheckSQLVersion;
var
  Query: TSQLQuery;
begin
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.ServiceDBConnection;
      Query.SQL.Text := 'SELECT sqlite_version()';
      Query.Open;
      sqlite_version := Query.Fields.Fields[0].AsString;
      Query.Close;
    finally
      FreeAndNil(Query);
    end;
  except
    on E: Exception do
    begin
      ShowMessage('CheckSQLVersion: Error: ' + E.ClassName + #13#10 + E.Message);
      WriteLn(ExceptFile, 'CheckSQLVersion: Error: ' + E.ClassName +
        ':' + E.Message);
    end;
  end;
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
  try
      DefTransaction.DataBase := SQLiteConnection;
      FindQSOQuery.DataBase := SQLiteConnection;
      SQLiteConnection.DatabaseName := DBRecord.SQLitePATH;
      SQLiteConnection.Connected := True;
      if SQLiteConnection.Connected then
      begin
        DefLogBookQuery.DataBase := SQLiteConnection;
        Result := True;
        InitRecord.LogbookDBInit := True;
      end;
  except
    on E: Exception do
    begin
      ShowMessage('LogbookDBInit: Error: ' + E.ClassName + #13#10 + E.Message);
      WriteLn(ExceptFile, 'LogbookDBInit: Error: ' + E.ClassName +
        ':' + E.Message);
      InitRecord.LogbookDBInit := False;
      Result := False;
    end;
  end;
end;

function TInitDB.ImbeddedCallBookInit(Use: boolean): boolean;
begin
  try
    Result := False;
    ImbeddedCallBookConnection.Connected := False;
    if (FileExists(FilePATH + 'callbook.db')) and (Use) then
    begin
      ImbeddedCallBookConnection.DatabaseName := FilePATH + 'callbook.db';
      ImbeddedCallBookConnection.Connected := True;
    end
    else
      ImbeddedCallBookConnection.Connected := False;
    if ImbeddedCallBookConnection.Connected then
      Result := True;
  except
    on E: Exception do
    begin
      ShowMessage('ImbeddedCallBookInit: Error: ' + E.ClassName + #13#10 + E.Message);
      WriteLn(ExceptFile, 'ImbeddedCallBookInit: Error: ' + E.ClassName +
        ':' + E.Message);
      Result := False;
    end;
  end;
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

function TInitDB.GetLogBookTable(Callsign: string): boolean;
var
  LogBookInfoQuery: TSQLQuery;
begin
  Result := False;

  if DBRecord.InitDB = 'YES' then
  begin
    try
      try
        LogBookInfoQuery := TSQLQuery.Create(nil);
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
          TryStrToFloatSafe(LogBookInfoQuery.FieldByName('Lat').AsString, LBRecord.OpLat);
          TryStrToFloatSafe(LogBookInfoQuery.FieldByName('Lon').AsString, LBRecord.OpLon);
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

          dmMigrate.Migrate(LBRecord.CallSign);

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
      SetLength(PrefixExpProvinceArray, PrefixProvinceCount);
      SetLength(PrefixExpARRLArray, PrefixARRLCount);
      for i := 0 to PrefixProvinceCount - 1 do
      begin
        PrefixProvinceList.Add(PrefixProvinceQuery.FieldByName('PrefixList').AsString);
        PrefixExpProvinceArray[i].reg := TRegExpr.Create;
        PrefixExpProvinceArray[i].reg.Expression := PrefixProvinceList.Strings[i];
        PrefixExpProvinceArray[i].id := PrefixProvinceQuery.FieldByName('_id').AsInteger;
        PrefixProvinceQuery.Next;
      end;
      for i := 0 to PrefixARRLCount - 1 do
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

    if not ParamData.portable then
      DBRecord.SQLitePATH := INIFile.ReadString('DataBases', 'FileSQLite', '')
    else
      DBRecord.SQLitePATH := FilePATH + 'logbook.db';

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

    DefLogBookQuery.SQL.Text :=
        'SELECT `UnUsedIndex`, `CallSign`, `QSODateTime`,' +
        'strftime("%d.%m.%Y",QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,'
        + '(COALESCE(`QSOReportSent`, '''') || '' '' || COALESCE(`STX`, '''') || '' '' || COALESCE(`STX_STRING`, '''')) AS QSOReportSent,'
        + '(COALESCE(`QSOReportRecived`, '''') || '' '' || COALESCE(`SRX`, '''') || '' '' || COALESCE(`SRX_STRING`, '''')) AS QSOReportRecived,'
        + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
        + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
        + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
        + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
        + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
        + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
        + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||`LoTWSent`) AS QSLs FROM '
        + LogTable + ' ORDER BY QSODateTime DESC';
       // ' INNER JOIN (SELECT UnUsedIndex, QSODate as QSODate2, QSOTime as QSOTime2 FROM ' +
       // LogTable + ' ORDER BY QSODate2 DESC, QSOTime2 DESC) as lim USING(UnUsedIndex)';

    DefLogBookQuery.Open;
    NumberSelectRecord := DefLogBookQuery.RecNo;
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

function TryStrToFloatSafe(const aStr : String; out aValue : Double) : Boolean;
const
  D = ['.', ','];
var
  S : String;
  i : Integer;
begin
  S := aStr;
  for i := 1 to Length(S) do
    if S[i] in D then begin
      S[i] := DefaultFormatSettings.DecimalSeparator;
      Break;
    end;
  Result := TryStrToFloat(S, aValue);
end;

procedure TInitDB.AllFree;
var
  i: integer;
begin
  FreeAndNil(PrefixProvinceList);
  FreeAndNil(PrefixARRLList);
  FreeAndNil(UniqueCallsList);
  FreeAndNil(SearchPrefixQuery);
  for i := 0 to Length(PrefixExpARRLArray) - 1 do
    FreeAndNil(PrefixExpARRLArray[i].reg);
  for i := 0 to Length(PrefixExpProvinceArray) - 1 do
    FreeAndNil(PrefixExpProvinceArray[i].reg);
end;

end.
