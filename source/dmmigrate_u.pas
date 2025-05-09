unit dmmigrate_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, Dialogs, InitDB_dm, ResourceStr;

const
  Current_Table = '1.5.2';

type
  TdmMigrate = class(TDataModule)
  private
    function MigrationEnd(ToTableVersion, Callsign: string): boolean;
    function Migrate146(Callsign: string): boolean;
    function Migrate147(Callsign: string): boolean;
    function Migrate148(Callsign: string): boolean;
    function Migrate150(Callsign: string): boolean;
    function Migrate151(Callsign: string): boolean;
    function Migrate152(Callsign: string): boolean;
    function CheckTableVersion(Callsign, MigrationVer: string): boolean;
    function SearchColumn(table, column: string): boolean;
  public
    procedure Migrate(Callsign, Description: string);
  end;

var
  dmMigrate: TdmMigrate;

implementation

{$R *.lfm}

function TdmMigrate.SearchColumn(table, column: string): boolean;
var
  Query: TSQLQuery;
begin
  Result := False;
  try
    Query := TSQLQuery.Create(nil);
    Query.DataBase := InitDB.SQLiteConnection;
    Query.SQL.Text := 'PRAGMA table_info(' + table + ')';
    Query.Open;
    while not Query.EOF do
    begin
      if Query.FieldByName('name').AsString = column then
      begin
        Result := True;
        Break;
      end;
      Query.Next;
    end;
    Query.Close;

  finally
    FreeAndNil(Query);
  end;
end;

function TdmMigrate.CheckTableVersion(Callsign, MigrationVer: string): boolean;
var
  Query: TSQLQuery;
  CurrentTableVersion: string;
  MigrationVersion: integer;
  CurrentTableVersionNumber: integer;
  TableVersion: integer;
begin
  try
    try
      Result := False;
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.SQLiteConnection;

      Query.SQL.Text :=
        'SELECT Table_version FROM LogBookInfo WHERE CallName = "' + Callsign + '"';
      Query.Open;
      CurrentTableVersion := Query.Fields.Fields[0].AsString;
      CurrentTableVersionNumber :=
        StrToInt(StringReplace(CurrentTableVersion, '.', '', [rfReplaceAll]));
      TableVersion := StrToInt(StringReplace(Current_Table, '.', '', [rfReplaceAll]));
      MigrationVersion := StrToInt(StringReplace(MigrationVer, '.', '', [rfReplaceAll]));
      Query.Close;
      if (CurrentTableVersionNumber < TableVersion) and
        (MigrationVersion > CurrentTableVersionNumber) then
        Result := True;

    finally
      FreeAndNil(Query);
    end;
  except
    on E: Exception do
    begin
      ShowMessage('CheckTableVersion: Error: ' + E.ClassName + #13#10 + E.Message);
      WriteLn(ExceptFile, 'CheckTableVersion: Error: ' + E.ClassName +
        ':' + E.Message);
    end;
  end;
end;

procedure TdmMigrate.Migrate(Callsign, Description: string);
begin
  Migrate146(Callsign);
  Migrate147(Callsign);
  Migrate148(Callsign);
  Migrate150(Callsign);
  Migrate151(Callsign);
  Migrate152(Callsign);
end;

function TdmMigrate.MigrationEnd(ToTableVersion, Callsign: string): boolean;
var
  Query: TSQLQuery;
begin
  Result := False;
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.SQLiteConnection;

      Query.SQL.Text :=
        'UPDATE LogBookInfo SET Table_version = ' + QuotedStr(ToTableVersion) +
        ' WHERE CallName = "' + Callsign + '"';
      Query.ExecSQL;
      InitDB.DefTransaction.Commit;
      Result := True;
    except
      on E: Exception do
      begin
        ShowMessage('MigrationEnd: Error: ' + E.ClassName + #13#10 + E.Message);
        WriteLn(ExceptFile, 'MigrationEnd: Error: ' + E.ClassName + ':' + E.Message);
      end;
    end;
  finally
    FreeAndNil(Query);
  end;
end;

function TdmMigrate.Migrate146(Callsign: string): boolean;
const
  Version = '1.4.6';
var
  Query: TSQLQuery;
begin
  Result := False;
  if not CheckTableVersion(Callsign, Version) then
    Exit;
  try
    try
      ShowMessage(rDBNeedUpdate + Version);
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.SQLiteConnection;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('ContestSession varchar(255) DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('ContestName varchar(255) DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('EQSL_QSL_SENT varchar(2) DEFAULT ''N'';');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('HAMLOGRec tinyint(1) DEFAULT 0;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('CLUBLOG_QSO_UPLOAD_DATE datetime DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('CLUBLOG_QSO_UPLOAD_STATUS tinyint(1) DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('HRDLOG_QSO_UPLOAD_DATE datetime DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('HRDLOG_QSO_UPLOAD_STATUS tinyint(1) DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('QRZCOM_QSO_UPLOAD_DATE datetime DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('QRZCOM_QSO_UPLOAD_STATUS tinyint(1) DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('HAMLOG_QSO_UPLOAD_DATE datetime DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('HAMLOG_QSO_UPLOAD_STATUS tinyint(1) DEFAULT NULL;');
      Query.ExecSQL;
      InitDB.DefTransaction.Commit;
      if MigrationEnd(Version, Callsign) then
        Result := True;

    except
      on E: Exception do
      begin
        if Pos('duplicate', E.Message) > 0 then
        begin
          MigrationEnd(Version, Callsign);
          Exit;
        end;
        ShowMessage('Migrate146: Error: ' + E.ClassName + #13#10 + E.Message);
        WriteLn(ExceptFile, 'Migrate146: Error: ' + E.ClassName + ':' + E.Message);
      end;
    end;

  finally
    FreeAndNil(Query);
  end;
end;

function TdmMigrate.Migrate147(Callsign: string): boolean;
const
  Version = '1.4.7';
var
  Query: TSQLQuery;
begin
  Result := False;
  if not CheckTableVersion(Callsign, Version) then
    Exit;
  try
    try
      ShowMessage(rDBNeedUpdate + Version);
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.SQLiteConnection;

      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('SOTA_REF varchar(15) DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('MY_SOTA_REF varchar(15) DEFAULT NULL;');
      Query.ExecSQL;
      InitDB.DefTransaction.Commit;
      if MigrationEnd(Version, Callsign) then
        Result := True;

    except
      on E: Exception do
      begin
        if Pos('duplicate', E.Message) > 0 then
        begin
          MigrationEnd(Version, Callsign);
          Exit;
        end;
        ShowMessage('Migrate147: Error: ' + E.ClassName + #13#10 + E.Message);
        WriteLn(ExceptFile, 'Migrate147: Error: ' + E.ClassName + ':' + E.Message);
      end;
    end;

  finally
    FreeAndNil(Query);
  end;
end;

function TdmMigrate.Migrate148(Callsign: string): boolean;
const
  Version = '1.4.8';
var
  Query: TSQLQuery;
begin
  Result := False;
  if not CheckTableVersion(Callsign, Version) then
    Exit;
  try
    try
      ShowMessage(rDBNeedUpdate + Version);
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.SQLiteConnection;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('QSODateTime datetime DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('UPDATE ' + LBRecord.LogTable + ' SET QSODateTime = ');
      Query.SQL.Add('CAST(strftime(''%s'', Date(QSODate) || time(QSOTime)) AS QSODT)');
      Query.ExecSQL;
      InitDB.DefTransaction.Commit;
      if MigrationEnd(Version, Callsign) then
        Result := True;

    except
      on E: Exception do
      begin
        if Pos('duplicate', E.Message) > 0 then
        begin
          MigrationEnd(Version, Callsign);
          Exit;
        end;
        ShowMessage('Migrate148: Error: ' + E.ClassName + #13#10 + E.Message);
        WriteLn(ExceptFile, 'Migrate148: Error: ' + E.ClassName + ':' + E.Message);
      end;
    end;

  finally
    FreeAndNil(Query);
  end;
end;

function TdmMigrate.Migrate150(Callsign: string): boolean;
const
  Version = '1.5.0';
var
  Query: TSQLQuery;
begin
  Result := False;
  if not CheckTableVersion(Callsign, Version) then
    Exit;
  try
    try
      ShowMessage(rDBNeedUpdate + Version);
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.SQLiteConnection;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('FREQ_RX varchar(20) DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('BAND_RX varchar(20) DEFAULT NULL;');
      Query.ExecSQL;
      InitDB.DefTransaction.Commit;
      if MigrationEnd(Version, Callsign) then
        Result := True;

    except
      on E: Exception do
      begin
        if Pos('duplicate', E.Message) > 0 then
        begin
          MigrationEnd(Version, Callsign);
          Exit;
        end;
        ShowMessage('Migrate150: Error: ' + E.ClassName + #13#10 + E.Message);
        WriteLn(ExceptFile, 'Migrate150: Error: ' + E.ClassName + ':' + E.Message);
      end;
    end;

  finally
    FreeAndNil(Query);
  end;
end;

function TdmMigrate.Migrate151(Callsign: string): boolean;
const
  Version = '1.5.1';
  newTemp_LogBookInfo = 'CREATE TABLE IF NOT EXISTS `tempLogBookInfo` ( ' +
    '`id` integer UNIQUE PRIMARY KEY, `LogTable` TEXT NOT NULL, ' +
    '`Description` TEXT NOT NULL UNIQUE, ' +
    '`CallName` TEXT NOT NULL, `Name` TEXT NOT NULL, ' +
    '`QTH` TEXT NOT NULL, `ITU` INTEGER NOT NULL, ' +
    '`CQ` INTEGER NOT NULL, `Loc` TEXT NOT NULL, ' +
    '`Lat` TEXT NOT NULL, `Lon` TEXT NOT NULL, ' +
    '`QSLInfo` TEXT NOT NULL DEFAULT "TNX For QSO TU 73!", ' +
    '`EQSLLogin` TEXT DEFAULT NULL, ' + '`EQSLPassword` TEXT DEFAULT NULL, ' +
    '`AutoEQSLcc` INTEGER DEFAULT NULL, ' + '`HamQTHLogin` TEXT DEFAULT NULL, ' +
    '`HamQTHPassword` TEXT DEFAULT NULL, ' + '`AutoHamQTH` INTEGER DEFAULT NULL, ' +
    '`HRDLogLogin` TEXT DEFAULT NULL, ' + '`HRDLogPassword` TEXT DEFAULT NULL, ' +
    '`AutoHRDLog` INTEGER DEFAULT NULL, `LoTW_User` TEXT, `LoTW_Password` TEXT, ' +
    '`ClubLog_User` TEXT, `ClubLog_Password` TEXT, `AutoClubLog` INTEGER DEFAULT NULL, '
    +
    '`QRZCOM_User` TEXT, `QRZCOM_Password` TEXT, `AutoQRZCom` INTEGER DEFAULT NULL, `Table_version` TEXT);';
var
  Query: TSQLQuery;
  DescriptionColumnExists: boolean;
begin
  Result := False;
  DescriptionColumnExists := False;
  if not CheckTableVersion(Callsign, Version) then
    Exit;
  try
    try
      ShowMessage(rDBNeedUpdate + Version);
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.SQLiteConnection;

      if not SearchColumn('LogBookInfo', 'Description') then
      begin
        Query.SQL.Text := newTemp_LogBookInfo;
        Query.ExecSQL;
        Query.SQL.Clear;
        Query.SQL.Add('INSERT INTO "tempLogBookInfo" (');
        Query.SQL.Add(
          '"id", "LogTable", "Description", "CallName", "Name", "QTH", "ITU", "CQ", "Loc", "Lat", "Lon", "QSLInfo",');
        Query.SQL.Add(
          '"EQSLLogin", "EQSLPassword", "AutoEQSLcc", "HamQTHLogin", "HamQTHPassword", "AutoHamQTH",');
        Query.SQL.Add(
          '"HRDLogLogin", "HRDLogPassword", "AutoHRDLog", "LoTW_User", "LoTW_Password", "ClubLog_User",');
        Query.SQL.Add(
          '"ClubLog_Password", "AutoClubLog", "QRZCOM_User", "QRZCOM_Password", "AutoQRZCom", "Table_version" )');
        Query.SQL.Add('SELECT ');
        Query.SQL.Add(
          '"id", "LogTable", "Discription", "CallName", "Name", "QTH", "ITU", "CQ", "Loc", "Lat", "Lon", "QSLInfo",');
        Query.SQL.Add(
          '"EQSLLogin", "EQSLPassword", "AutoEQSLcc", "HamQTHLogin", "HamQTHPassword", "AutoHamQTH",');
        Query.SQL.Add(
          '"HRDLogLogin", "HRDLogPassword", "AutoHRDLog", "LoTW_User", "LoTW_Password", "ClubLog_User",');
        Query.SQL.Add(
          '"ClubLog_Password", "AutoClubLog", "QRZCOM_User", "QRZCOM_Password", "AutoQRZCom", "Table_version" ');
        Query.SQL.Add('FROM "LogBookInfo";');
        Query.ExecSQL;
        Query.SQL.Text := 'DROP TABLE "LogBookInfo";';
        Query.ExecSQL;
        Query.SQL.Text := 'ALTER TABLE "tempLogBookInfo" RENAME TO "LogBookInfo";';
        Query.ExecSQL;
      end;


      if not SearchColumn(LBRecord.LogTable, 'HAMQTH_QSO_UPLOAD_DATE') then
      begin
        Query.SQL.Clear;
        Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
        Query.SQL.Add('HAMLOGRU_QSO_UPLOAD_DATE datetime DEFAULT NULL;');
        Query.ExecSQL;
        Query.SQL.Clear;
        Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
        Query.SQL.Add('HAMLOGRU_QSO_UPLOAD_STATUS INTEGER DEFAULT NULL;');
        Query.ExecSQL;
        Query.SQL.Clear;

        Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
        Query.SQL.Add('HAMLOGEU_QSO_UPLOAD_DATE datetime DEFAULT NULL;');
        Query.ExecSQL;
        Query.SQL.Clear;
        Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
        Query.SQL.Add('HAMLOGEU_QSO_UPLOAD_STATUS INTEGER DEFAULT NULL;');
        Query.ExecSQL;
        Query.SQL.Clear;

        Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
        Query.SQL.Add('HAMQTH_QSO_UPLOAD_DATE datetime DEFAULT NULL;');
        Query.ExecSQL;
        Query.SQL.Clear;
        Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
        Query.SQL.Add('HAMQTH_QSO_UPLOAD_STATUS INTEGER DEFAULT NULL;');
        Query.ExecSQL;
      end;

      Query.SQL.Text := 'SELECT * FROM LogBookInfo WHERE CallName = "' +
        DBRecord.DefaultLogTable + '" LIMIT 1';
      Query.Open;
      if Query.FieldByName('Description').AsString <> '' then
      begin
        iniFile.WriteString('SetLog', 'DefaultCallLogBook',
          Query.FieldByName('Description').AsString);
        DBRecord.DefaultLogTable := Query.FieldByName('Description').AsString;
      end;


      InitDB.DefTransaction.Commit;
      if MigrationEnd(Version, Callsign) then
        Result := True;

    except
      on E: Exception do
      begin
        if Pos('duplicate', E.Message) > 0 then
        begin
          MigrationEnd(Version, Callsign);
          Exit;
        end;
        ShowMessage('Migrate151: Error: ' + E.ClassName + #13#10 + E.Message);
        WriteLn(ExceptFile, 'Migrate151: Error: ' + E.ClassName + ':' + E.Message);
      end;
    end;

  finally
    FreeAndNil(Query);
  end;
end;

function TdmMigrate.Migrate152(Callsign: string): boolean;
const
  Version = '1.5.2';
var
  Query: TSQLQuery;
begin
  Result := False;
  if not CheckTableVersion(Callsign, Version) then
    Exit;
  try
    try
      ShowMessage(rDBNeedUpdate + Version);
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.SQLiteConnection;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE LogBookInfo ADD COLUMN ');
      Query.SQL.Add('QSOSU_Token varchar(50) DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE LogBookInfo ADD COLUMN ');
      Query.SQL.Add('AutoQSOsu tinyint(1) DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('QSOSU_QSO_UPLOAD_DATE datetime DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('QSOSU_QSO_UPLOAD_STATUS tinyint(1) DEFAULT NULL;');
      Query.ExecSQL;
      InitDB.DefTransaction.Commit;
      if MigrationEnd(Version, Callsign) then
        Result := True;

    except
      on E: Exception do
      begin
        if Pos('duplicate', E.Message) > 0 then
        begin
          MigrationEnd(Version, Callsign);
          Exit;
        end;
        ShowMessage('Migrate146: Error: ' + E.ClassName + #13#10 + E.Message);
        WriteLn(ExceptFile, 'Migrate146: Error: ' + E.ClassName + ':' + E.Message);
      end;
    end;

  finally
    FreeAndNil(Query);
  end;
end;

end.
