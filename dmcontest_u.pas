unit dmContest_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, SQLDB, StdCtrls, InitDB_dm;

type
  TdmContest = class(TDataModule)
  private

  public
    procedure LoadContestName(var CBContest: TComboBox);

  end;

var
  dmContest: TdmContest;

implementation

{$R *.lfm}

procedure TdmContest.LoadContestName(var CBContest: TComboBox);
var
  Query: TSQLQuery;
begin
  try
    try
      Query := TSQLQuery.Create(nil);
      CBContest.Items.Clear;
      Query.DataBase := InitDB.ServiceDBConnection;
      Query.SQL.Text := 'SELECT * FROM contest';
      Query.Open;
      while not Query.EOF do
      begin
        CBContest.Items.Add(Query.Fields[1].AsString);
        Query.Next;
      end;
      Query.Close;
    finally
      CBContest.ItemIndex := 0;
      FreeAndNil(Query);
    end;
  except
    on E: Exception do
    begin
      WriteLn(ExceptFile, 'LoadContestName:' + E.ClassName + ':' + E.Message);
    end;
  end;
end;

end.
