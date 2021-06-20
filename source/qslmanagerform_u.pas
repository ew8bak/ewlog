(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit QSLManagerForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, DB, FileUtil, Forms, Controls, Graphics, Dialogs,
  Buttons, ExtCtrls, StdCtrls, DBGrids, DBCtrls;

type

  { TQSLManager_Form }

  TQSLManager_Form = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    DBNavigator1: TDBNavigator;
    Label6: TLabel;
    ManagerDS: TDataSource;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    DBGrid1: TDBGrid;
    DBMemo1: TDBMemo;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    ManagersQuery: TSQLQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBNavigator1Click(Sender: TObject; Button: TDBNavButtonType);
    procedure Edit1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  QSLManager_Form: TQSLManager_Form;

implementation

{$R *.lfm}
uses miniform_u;

{ TQSLManager_Form }

procedure TQSLManager_Form.Button2Click(Sender: TObject);
begin
  QSLManager_Form.Close;
end;

procedure TQSLManager_Form.Button1Click(Sender: TObject);
begin

end;

procedure TQSLManager_Form.Button3Click(Sender: TObject);
begin
  Edit1.Clear;
end;

procedure TQSLManager_Form.DBGrid1DblClick(Sender: TObject);
begin
MiniForm.EditMGR.Text:=ManagersQuery.FieldByName('Manager').AsString;
end;

procedure TQSLManager_Form.DBNavigator1Click(Sender: TObject;
  Button: TDBNavButtonType);
begin
  if (Button = nbEdit) or (Button = nbInsert) then
  DBGrid1.ReadOnly:=False
  else
  DBGrid1.ReadOnly:=True;
end;

procedure TQSLManager_Form.Edit1Change(Sender: TObject);
begin
  with ManagersQuery do
  begin
    Close;
    if Edit1.Text <> '' then
    SQL.Text := 'SELECT * FROM managers WHERE `Call` = ' + QuotedStr(Edit1.Text)
    else
    SQL.Text := 'SELECT * FROM managers LIMIT 20';
    Active := True;
  end;
end;

procedure TQSLManager_Form.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  ManagersQuery.Active:=False;
end;

procedure TQSLManager_Form.FormShow(Sender: TObject);
begin
  with ManagersQuery do
  begin
    Close;
    SQL.Text := 'SELECT * FROM managers';
    Active := True;
  end;
  Edit1.Text:=MiniForm.EditCallsign.Text;
end;

end.
