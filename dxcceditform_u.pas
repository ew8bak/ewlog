(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit DXCCEditForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, DBGrids, DbCtrls, StdCtrls;

type

  { TCountryEditForm }

  TCountryEditForm = class(TForm)
    CountryDS: TDataSource;
    DBGrid1: TDBGrid;
    Edit1: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    CountryQditQuery: TSQLQuery;
    procedure Edit1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  CountryEditForm: TCountryEditForm;

implementation
uses
  editqso_u, mainform_u;

{$R *.lfm}

{ TCountryEditForm }

procedure TCountryEditForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CountryQditQuery.Active:=False;
end;

procedure TCountryEditForm.FormCreate(Sender: TObject);
begin

end;

procedure TCountryEditForm.Edit1Change(Sender: TObject);
begin
  if CountryEditForm.Caption='Province' then
  DBGrid1.DataSource.DataSet.Locate('Prefix',Edit1.Text,[])
  else
  DBGrid1.DataSource.DataSet.Locate('ARRLPrefix',Edit1.Text,[])
end;

procedure TCountryEditForm.FormShow(Sender: TObject);
begin

  DBGrid1.Columns.Items[0].Width:=40;
  DBGrid1.Columns.Items[1].Width:=70;
  DBGrid1.Columns.Items[2].Width:=70;
  DBGrid1.Columns.Items[3].Width:=70;
  DBGrid1.Columns.Items[4].Width:=200;
  DBGrid1.Columns.Items[5].Width:=70;
  DBGrid1.Columns.Items[6].Width:=70;
  DBGrid1.Columns.Items[7].Width:=70;
  DBGrid1.Columns.Items[8].Width:=70;
  DBGrid1.Columns.Items[9].Width:=70;
  DBGrid1.Columns.Items[10].Width:=150;
  DBGrid1.Columns.Items[11].Width:=70;
  DBGrid1.Columns.Items[12].Width:=70;
  DBGrid1.Columns.Items[13].Width:=70;
  DBGrid1.Columns.Items[14].Width:=70;

end;

end.

