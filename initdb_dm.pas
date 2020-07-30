unit InitDB_dm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, mysql57conn, LogBookTable_record,
  DB_record, ResourceStr;

type

  { TInitDB }

  TInitDB = class(TDataModule)
    MySQLConnection: TMySQL57Connection;
    ServiceDBConnection: TSQLite3Connection;
    ServiceTransaction: TSQLTransaction;
    DefTransaction: TSQLTransaction;
    ImbeddedCallBookConnection: TSQLite3Connection;
    SQLiteConnection: TSQLite3Connection;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    function ServiceDBInit: boolean;
    function LogbookDBInit: boolean;
    function ImbeddedCallBookInit(Use: boolean): boolean;
    procedure GetLogBookTable(Callsign, typeDataBase: string);

  end;

var
  InitDB: TInitDB;
  FilePATH: string;
  LBRecord: TLBRecord;
  DBRecord: TDBRecord;

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
  if ServiceDBConnection.Connected then
    Result := True;
end;

function TInitDB.LogbookDBInit: boolean;
begin
  try
    Result := False;
    if DBRecord.DefaultDB = 'MySQL' then
    begin
      DefTransaction.DataBase := MySQLConnection;
      MySQLConnection.HostName := DBRecord.MySQLHost;
      MySQLConnection.Port := DBRecord.MySQLPort;
      MySQLConnection.UserName := DBRecord.MySQLUser;
      MySQLConnection.Password := DBRecord.MySQLPass;
      MySQLConnection.DatabaseName := DBRecord.MySQLDBName;
      if MySQLConnection.Connected then begin
        DBRecord.CurrentDB:='MySQL';
        Result := True;
      end;
    end;
    if DBRecord.DefaultDB = 'SQLite' then
    begin
      DefTransaction.DataBase := SQLiteConnection;
      SQLiteConnection.DatabaseName := DBRecord.SQLitePATH;
      if SQLiteConnection.Connected then begin
        DBRecord.CurrentDB:='SQLite';
        Result := True;
      end;
    end;
  finally
  end;
end;

function TInitDB.ImbeddedCallBookInit(Use: boolean): boolean;
begin
  try
    Result := False;
    if (FileExists(FilePATH + 'callbook.db')) and (Use) then
      ImbeddedCallBookConnection.DatabaseName := FilePATH + 'callbook.db';
    if ImbeddedCallBookConnection.Connected then
      Result := True
  finally
  end;
end;

procedure TInitDB.GetLogBookTable(Callsign, typeDataBase: string);
var
  LogBookInfoQuery: TSQLQuery;
begin
  try
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

  finally
    FreeAndNil(LogBookInfoQuery);
  end;

end;

end.
