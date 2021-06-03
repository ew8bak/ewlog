unit dmmigrate_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, Dialogs, InitDB_dm;

const
  Current_Table = '1.4.6';

type
  TdmMigrate = class(TDataModule)
  private
    function MigrationEnd(ToTableVersion: integer; Callsign: string): boolean;
    function Migrate146(Callsign: string): boolean;
    function CheckTableVersion(Callsign: string): boolean;

  public
    procedure Migrate(Callsign: string);
  end;

var
  dmMigrate: TdmMigrate;

implementation

{$R *.lfm}

function TdmMigrate.CheckTableVersion(Callsign: string): boolean;
var
  Query: TSQLQuery;
  CurrentTableVersion: string;
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
      Query.Close;
      if CurrentTableVersionNumber < TableVersion then
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
end;

function TdmMigrate.MigrationEnd(ToTableVersion: integer; Callsign: string): boolean;
var
  Query: TSQLQuery;
begin
  Result := False;
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.SQLiteConnection;
      Query.SQL.Text :=
        'UPDATE LogBookInfo SET Table_version = ' +
        QuotedStr(FormatFloat('0.0"."0', ToTableVersion)) + ' WHERE CallName = "' +
        Callsign + '"';
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
var
  Query: TSQLQuery;
begin
  Result := False;
  if not CheckTableVersion(Callsign) then
    Exit;
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.SQLiteConnection;
      Query.SQL.Text := 'ALTER TABLE ' + LBRecord.LogTable +
        ' ADD COLUMN ContestSession int(15);';
      Query.ExecSQL;
      InitDB.DefTransaction.Commit;
      if MigrationEnd(146, Callsign) then
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

end.
