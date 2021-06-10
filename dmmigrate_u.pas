unit dmmigrate_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, Dialogs, InitDB_dm, ResourceStr;

const
  Current_Table = '1.4.7';

type
  TdmMigrate = class(TDataModule)
  private
    function MigrationEnd(ToTableVersion, Callsign: string): boolean;
    function Migrate146(Callsign: string): boolean;
    function Migrate147(Callsign: string): boolean;
    function CheckTableVersion(Callsign, MigrationVer: string): boolean;

  public
    procedure Migrate(Callsign: string);
  end;

var
  dmMigrate: TdmMigrate;

implementation

{$R *.lfm}

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
      if DBRecord.CurrentDB = 'SQLite' then
        Query.DataBase := InitDB.SQLiteConnection
      else
        Query.DataBase := InitDB.MySQLConnection;

      Query.SQL.Text :=
        'SELECT Table_version FROM LogBookInfo WHERE CallName = "' + Callsign + '"';
      Query.Open;
      CurrentTableVersion := Query.Fields.Fields[0].AsString;
      CurrentTableVersionNumber :=
        StrToInt(StringReplace(CurrentTableVersion, '.', '', [rfReplaceAll]));
      TableVersion := StrToInt(StringReplace(Current_Table, '.', '', [rfReplaceAll]));
      MigrationVersion := StrToInt(StringReplace(MigrationVer, '.', '', [rfReplaceAll]));
      Query.Close;
      if (CurrentTableVersionNumber < TableVersion) and (MigrationVersion > CurrentTableVersionNumber) then
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

procedure TdmMigrate.Migrate(Callsign: string);
begin
  Migrate146(Callsign);
  Migrate147(Callsign);
end;

function TdmMigrate.MigrationEnd(ToTableVersion, Callsign: string): boolean;
var
  Query: TSQLQuery;
begin
  Result := False;
  try
    try
      Query := TSQLQuery.Create(nil);
      if DBRecord.CurrentDB = 'SQLite' then
        Query.DataBase := InitDB.SQLiteConnection
      else
        Query.DataBase := InitDB.MySQLConnection;

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
      if DBRecord.CurrentDB = 'SQLite' then
        Query.DataBase := InitDB.SQLiteConnection
      else
        Query.DataBase := InitDB.MySQLConnection;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('ContestSession TEXT DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('ContestName TEXT DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('EQSL_QSL_SENT varchar(2) DEFAULT N;');
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
      if DBRecord.CurrentDB = 'SQLite' then
        Query.DataBase := InitDB.SQLiteConnection
      else
        Query.DataBase := InitDB.MySQLConnection;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('SOTA_REF TEXT DEFAULT NULL;');
      Query.ExecSQL;
      Query.SQL.Clear;
      Query.SQL.Add('ALTER TABLE ' + LBRecord.LogTable + ' ADD COLUMN ');
      Query.SQL.Add('MY_SOTA_REF TEXT DEFAULT NULL;');
      Query.ExecSQL;
      InitDB.DefTransaction.Commit;
      if MigrationEnd(Version, Callsign) then
        Result := True;

    except
      on E: Exception do
      begin
        ShowMessage('Migrate147: Error: ' + E.ClassName + #13#10 + E.Message);
        WriteLn(ExceptFile, 'Migrate147: Error: ' + E.ClassName + ':' + E.Message);
      end;
    end;

  finally
    FreeAndNil(Query);
  end;
end;

end.
