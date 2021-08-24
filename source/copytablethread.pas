(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit CopyTableThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, ResourceStr, LazFileUtils, LCLType,
  const_u, DateUtils;

type
  TData = record
    ErrorStr: string;
    AllRec: integer;
    RecCount: integer;
    ErrorCount: integer;
    ErrorType: integer;
    Result: boolean;
  end;

type
  TCopyTThread = class(TThread)
  protected
    procedure Execute; override;
  private
    procedure CopyTableToTable(toMySQL: boolean);
  public
    toDB: boolean;
    Data: TData;
    constructor Create;
    procedure ToForm;
  end;

var
  CopyTThread: TCopyTThread;

implementation

uses miniform_u, InitDB_dm;

procedure TCopyTThread.CopyTableToTable(toMySQL: boolean);
var
  QueryToList: TStringList;
  QueryFrom: TSQLQuery;
  Query: TSQLQuery;
  Transaction: TSQLTransaction;
  LogTableNameTo: string;
  LogTableNameFrom: string;
  i: integer;
  strQuery: string;
  DateStr: string;
begin
  Data.Result := False;
  Data.ErrorType := -1;
  Data.ErrorStr := '';
  Data.AllRec := 0;
  Data.ErrorCount := 0;
  Data.RecCount := 0;
  if (Length(DBRecord.MySQLDBName) = 0) then
  begin
    Data.ErrorStr := rCheckSettingsMySQL;
    Data.ErrorType := 1;
    Synchronize(@ToForm);
    Exit;
  end;
  if not FileExistsUTF8(DBRecord.SQLitePATH) then
  begin
    Data.ErrorStr := rCheckSettingsSQLite;
    Data.ErrorType := 1;
    Synchronize(@ToForm);
    Exit;
  end;
  try
    try
      QueryToList := TStringList.Create;
      QueryFrom := TSQLQuery.Create(nil);
      Query := TSQLQuery.Create(nil);
      Transaction := TSQLTransaction.Create(nil);

      if toMySQL and (DBRecord.CurrentDB = 'SQLite') then
      begin
        Transaction.DataBase := InitDB.MySQLConnection;
        Query.DataBase := InitDB.MySQLConnection;
        QueryFrom.DataBase := InitDB.SQLiteConnection;
        InitDB.MySQLConnection.HostName := DBRecord.MySQLHost;
        InitDB.MySQLConnection.Port := DBRecord.MySQLPort;
        InitDB.MySQLConnection.UserName := DBRecord.MySQLUser;
        InitDB.MySQLConnection.Password := DBRecord.MySQLPass;
        InitDB.MySQLConnection.DatabaseName := DBRecord.MySQLDBName;
        InitDB.MySQLConnection.Connected := True;
        InitDB.MySQLConnection.ExecuteDirect('SET autocommit = 0');
        InitDB.MySQLConnection.ExecuteDirect('BEGIN');
      end;

      if not toMySQL and (DBRecord.CurrentDB = 'SQLite') then
      begin
        InitDB.MySQLConnection.HostName := DBRecord.MySQLHost;
        InitDB.MySQLConnection.Port := DBRecord.MySQLPort;
        InitDB.MySQLConnection.UserName := DBRecord.MySQLUser;
        InitDB.MySQLConnection.Password := DBRecord.MySQLPass;
        InitDB.MySQLConnection.DatabaseName := DBRecord.MySQLDBName;
        Transaction.DataBase := InitDB.MySQLConnection;
        QueryFrom.DataBase := InitDB.MySQLConnection;
        InitDB.MySQLConnection.Connected := True;
        Query.DataBase := InitDB.SQLiteConnection;
      end;

      if not toMySQL and (DBRecord.CurrentDB = 'MySQL') then
      begin
        Transaction.DataBase := InitDB.SQLiteConnection;
        Query.DataBase := InitDB.SQLiteConnection;
        QueryFrom.DataBase := InitDB.MySQLConnection;
        InitDB.SQLiteConnection.DatabaseName := DBRecord.SQLitePATH;
        InitDB.SQLiteConnection.Connected := True;
      end;

      if toMySQL and (DBRecord.CurrentDB = 'MySQL') then
      begin
        Transaction.DataBase := InitDB.SQLiteConnection;
        InitDB.SQLiteConnection.DatabaseName := DBRecord.SQLitePATH;
        QueryFrom.DataBase := InitDB.SQLiteConnection;
        Query.DataBase := InitDB.MySQLConnection;
        InitDB.SQLiteConnection.Connected := True;
      end;

      Query.SQL.Text := 'SELECT LogTable FROM LogBookInfo WHERE CallName = ' +
        QuotedStr(LBRecord.CallSign);
      Query.Open;
      if Query.RecordCount > 0 then
        LogTableNameTo := Query.Fields.Fields[0].AsString
      else
      begin
        Data.ErrorStr := tNotFoundTableToCopy;
        Data.ErrorType := 1;
        Synchronize(@ToForm);
      end;
      Query.Close;

      QueryFrom.SQL.Text := 'SELECT LogTable FROM LogBookInfo WHERE CallName = ' +
        QuotedStr(LBRecord.CallSign);
      QueryFrom.Open;
      if QueryFrom.RecordCount > 0 then
        LogTableNameFrom := QueryFrom.Fields.Fields[0].AsString
      else
      begin
        Data.ErrorStr := tNotFoundTableToCopy;
        Data.ErrorType := 1;
        Synchronize(@ToForm);
      end;
      QueryFrom.Close;

      if (Length(LogTableNameFrom) < 2) or (Length(LogTableNameTO) < 2) then
        Exit;

      QueryFrom.SQL.Text := 'SELECT COUNT(*) FROM ' + LogTableNameFrom;
      QueryFrom.Open;
      Data.AllRec := QueryFrom.Fields.Fields[0].AsInteger;
      QueryFrom.Close;
      QueryFrom.SQL.Text := 'SELECT ' + CopyField + ' FROM ' + LogTableNameFrom;
      QueryFrom.Open;
      QueryFrom.First;
      while not QueryFrom.EOF do
      begin
        try
          QueryToList.Clear;
          QueryToList.Add('INSERT INTO ' + LogTableNameTo + ' (' +
            CopyField + ') VALUES (');
          for i := 0 to 71 do
          begin
            if QueryFrom.Fields.Fields[i].AsString <> '' then
            begin
              if (QueryFrom.Fields.Fields[i].FieldName = 'QSODate') or
                (QueryFrom.Fields.Fields[i].FieldName = 'QSLSentDate') or
                (QueryFrom.Fields.Fields[i].FieldName = 'QSLRecDate') or
                (QueryFrom.Fields.Fields[i].FieldName = 'LoTWRecDate') or
                (QueryFrom.Fields.Fields[i].FieldName = 'CLUBLOG_QSO_UPLOAD_DATE') or
                (QueryFrom.Fields.Fields[i].FieldName = 'HRDLOG_QSO_UPLOAD_DATE') or
                (QueryFrom.Fields.Fields[i].FieldName = 'QRZCOM_QSO_UPLOAD_DATE') or
                (QueryFrom.Fields.Fields[i].FieldName = 'HAMLOG_QSO_UPLOAD_DATE') then
              begin
                if toMySQL then
                  DateStr := FormatDateTime('YYYY-MM-DD',
                    QueryFrom.Fields.Fields[i].AsDateTime)
                else begin
                  DateStr := FloatToStr(DateTimeToJulianDate(
                    QueryFrom.Fields.Fields[i].AsDateTime));
                  DateStr := StringReplace(DateStr,',','.',[rfReplaceAll]);
                 end;
                QueryToList.Add(QuotedStr(DateStr) + ',');
              end
              else
                QueryToList.Add(QuotedStr(QueryFrom.Fields.Fields[i].AsString) + ',');
            end
            else
              QueryToList.Add('NULL,');
          end;
          QueryToList.Add(')');
          strQuery := QueryToList.Text;
          strQuery := StringReplace(strQuery, #10, '', [rfReplaceAll]);
          strQuery := StringReplace(strQuery, #13, '', [rfReplaceAll]);
          Delete(strQuery, LastDelimiter(',', strQuery), 1);

          if toMySQL then
            InitDB.MySQLConnection.ExecuteDirect(strQuery)
          else
            InitDB.SQLiteConnection.ExecuteDirect(strQuery);

          QueryFrom.Next;
          Inc(Data.RecCount);
          if Data.RecCount mod 100 = 0 then
          begin
            Data.ErrorType := -1;
            Synchronize(@ToForm);
          end;
        except
          on E: ESQLDatabaseError do
          begin
            if (E.ErrorCode = 1062) or (E.ErrorCode = 2067) then
            begin
              Inc(Data.ErrorCount);
              if Data.ErrorCount mod 100 = 0 then
              begin
                Data.ErrorType := 3;
                Synchronize(@ToForm);
              end;
              Data.ErrorType := 3;
              Synchronize(@ToForm);
            end;
            if E.ErrorCode = 1366 then
            begin
              Inc(Data.ErrorCount);
              if Data.ErrorCount mod 100 = 0 then
              begin
                Data.ErrorType := 3;
                Synchronize(@ToForm);
              end;
              // WriteWrongADIF(s);
            end;
            QueryFrom.Next;
          end;
        end;
      end;

    finally
      if toMySQL and (DBRecord.CurrentDB = 'SQLite') then
      begin
        InitDB.MySQLConnection.ExecuteDirect('COMMIT');
        InitDB.MySQLConnection.Connected := False;
      end;
      if not toMySQL and (DBRecord.CurrentDB = 'SQLite') then
      begin
        InitDB.DefTransaction.Commit;
        InitDB.MySQLConnection.Connected := False;
      end;
      if not toMySQL and (DBRecord.CurrentDB = 'MySQL') then
      begin
        Transaction.Commit;
        InitDB.SQLiteConnection.Connected := False;
      end;
      if toMySQL and (DBRecord.CurrentDB = 'MySQL') then
      begin
        InitDB.DefTransaction.Commit;
        InitDB.SQLiteConnection.Connected := False;
      end;
      Data.ErrorType := -1;
      Data.Result := True;
      Synchronize(@ToForm);
      FreeAndNil(QueryFrom);
      FreeAndNil(QueryToList);
      FreeAndNil(Query);
      FreeAndNil(Transaction);
    end;
  except
    on E: Exception do
    begin
      Data.ErrorStr := 'CopyTableToTable:' + E.Message;
      Data.ErrorType := 1;
      Synchronize(@ToForm);
      WriteLn(ExceptFile, 'CopyTableToTable:' + E.ClassName + ':' + E.Message);
    end;
  end;
end;

constructor TCopyTThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TCopyTThread.ToForm;
begin
  MiniForm.FromCopyTableThread(Data);
end;

procedure TCopyTThread.Execute;
begin
  CopyTableToTable(toDB);
end;

end.
