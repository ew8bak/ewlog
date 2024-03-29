(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit ManagerBasePrefixForm_U;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, DB, Forms, Graphics,
  ComCtrls, ExtCtrls, DBGrids;

type

  { TManagerBasePrefixForm }

  TManagerBasePrefixForm = class(TForm)
    UCallsDS: TDataSource;
    OblDS: TDataSource;
    CountryDS: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    OblastQuery: TSQLQuery;
    CountryQuery: TSQLQuery;
    UniqueCallsQuery: TSQLQuery;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  ManagerBasePrefixForm: TManagerBasePrefixForm;

implementation

uses InitDB_dm;

{$R *.lfm}

{ TManagerBasePrefixForm }

procedure TManagerBasePrefixForm.FormShow(Sender: TObject);
begin

  UniqueCallsQuery.DataBase := InitDB.ServiceDBConnection;
  OblastQuery.DataBase := InitDB.ServiceDBConnection;
  CountryQuery.DataBase := InitDB.ServiceDBConnection;

  UniqueCallsQuery.Active := True;
  OblastQuery.Active := True;
  CountryQuery.Active := True;
  DBGrid1.Columns.Items[0].Width := 40;
  DBGrid1.Columns.Items[1].Width := 130;
  DBGrid1.Columns.Items[2].Width := 50;
  DBGrid1.Columns.Items[3].Width := 50;
  DBGrid1.Columns.Items[4].Width := 40;
  DBGrid1.Columns.Items[5].Width := 70;
  DBGrid1.Columns.Items[6].Width := 70;
  DBGrid1.Columns.Items[7].Width := 70;
  DBGrid1.Columns.Items[8].Width := 70;
  DBGrid1.Columns.Items[9].Width := 70;
  DBGrid1.Columns.Items[10].Width := 150;
  DBGrid1.Columns.Items[11].Width := 70;
  DBGrid1.Columns.Items[12].Width := 70;
  DBGrid1.Columns.Items[13].Width := 70;
  DBGrid1.Columns.Items[14].Width := 70;

  DBGrid2.Columns.Items[0].Width := 40;
  DBGrid2.Columns.Items[1].Width := 70;
  DBGrid2.Columns.Items[2].Width := 70;
  DBGrid2.Columns.Items[3].Width := 70;
  DBGrid2.Columns.Items[4].Width := 200;
  DBGrid2.Columns.Items[5].Width := 70;
  DBGrid2.Columns.Items[6].Width := 70;
  DBGrid2.Columns.Items[7].Width := 70;
  DBGrid2.Columns.Items[8].Width := 70;
  DBGrid2.Columns.Items[9].Width := 70;
  DBGrid2.Columns.Items[10].Width := 150;
  DBGrid2.Columns.Items[11].Width := 70;
  DBGrid2.Columns.Items[12].Width := 70;
  DBGrid2.Columns.Items[13].Width := 70;
  DBGrid2.Columns.Items[14].Width := 70;

  DBGrid3.Columns.Items[0].Width := 40;
  DBGrid3.Columns.Items[1].Width := 70;
  DBGrid3.Columns.Items[2].Width := 70;
  DBGrid3.Columns.Items[3].Width := 70;
  DBGrid3.Columns.Items[4].Width := 200;
  DBGrid3.Columns.Items[5].Width := 70;
  DBGrid3.Columns.Items[6].Width := 70;
  DBGrid3.Columns.Items[7].Width := 70;
  DBGrid3.Columns.Items[8].Width := 70;
  DBGrid3.Columns.Items[9].Width := 70;
  DBGrid3.Columns.Items[10].Width := 150;
  DBGrid3.Columns.Items[11].Width := 70;
  DBGrid3.Columns.Items[12].Width := 70;
  DBGrid3.Columns.Items[13].Width := 70;
  DBGrid3.Columns.Items[14].Width := 70;
end;

procedure TManagerBasePrefixForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  UniqueCallsQuery.Close;
  CountryQuery.Close;
  OblastQuery.Close;
end;

end.
