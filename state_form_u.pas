(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit STATE_Form_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  DBGrids, ExtCtrls, StdCtrls;

type

  { TSTATE_Form }

  TSTATE_Form = class(TForm)
    Button1: TButton;
    DBGrid1: TDBGrid;
    Edit1: TEdit;
    Edit2: TEdit;
    STATE_DS: TDataSource;
    STATE_Query: TSQLQuery;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  STATE_Form: TSTATE_Form;

implementation

{$R *.lfm}
uses miniform_u;

{ TSTATE_Form }

procedure TSTATE_Form.Edit1Change(Sender: TObject);
begin
  STATE_Query.Close;
  Edit2.Clear;
  STATE_Query.SQL.Text:='SELECT * FROM STATE WHERE STATE LIKE :state';
  STATE_Query.Params.ParamValues['state']:=Trim(Edit1.Text)+'%';
  STATE_Query.Active:=True;
end;

procedure TSTATE_Form.Button1Click(Sender: TObject);
begin
  STATE_Form.Close;
end;

procedure TSTATE_Form.DBGrid1DblClick(Sender: TObject);
begin
  MiniForm.EditState.Text:=STATE_Query.FieldByName('State').AsString;
end;

procedure TSTATE_Form.Edit2Change(Sender: TObject);
begin
  STATE_Query.Close;
  Edit1.Clear;
  STATE_Query.SQL.Text:='SELECT * FROM STATE WHERE Name LIKE :name';
  STATE_Query.Params.ParamValues['name']:=Trim(Edit2.Text)+'%';
  STATE_Query.Active:=True;
end;

procedure TSTATE_Form.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
   Edit1.Clear;
   Edit2.Clear;
   STATE_Query.Close;
end;

procedure TSTATE_Form.FormShow(Sender: TObject);
begin
  STATE_Query.SQL.Text:='SELECT * FROM STATE';
  STATE_Query.Active:=True;
end;

end.

