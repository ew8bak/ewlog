unit IOTA_Form_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  Grids, StdCtrls, DBGrids, ExtCtrls;

type

  { TIOTA_Form }

  TIOTA_Form = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    IOTA_DS: TDataSource;
    DBGrid1: TDBGrid;
    IOTA_Query: TSQLQuery;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  IOTA_Form: TIOTA_Form;

implementation
//uses MainForm_U;
  {$R *.lfm}

{ TIOTA_Form }

procedure TIOTA_Form.FormShow(Sender: TObject);
begin
IOTA_Query.SQL.Text:='SELECT * FROM IOTA';
IOTA_Query.Active:=True;
end;

procedure TIOTA_Form.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Edit1.Clear;
  Edit2.Clear;
  IOTA_Query.Close;
end;

procedure TIOTA_Form.FormCreate(Sender: TObject);
begin

end;

procedure TIOTA_Form.Button1Click(Sender: TObject);
begin
  IOTA_Form.Close;
end;

procedure TIOTA_Form.Edit1Change(Sender: TObject);
begin
  IOTA_Query.Close;
  Edit2.Clear;
  IOTA_Query.SQL.Text:='SELECT * FROM IOTA WHERE IOTA LIKE :iota';
  IOTA_Query.Params.ParamValues['iota']:=Trim(Edit1.Text)+'%';
  IOTA_Query.Active:=True;
end;

procedure TIOTA_Form.Edit2Change(Sender: TObject);
begin
  IOTA_Query.Close;
  Edit1.Clear;
  IOTA_Query.SQL.Text:='SELECT * FROM IOTA WHERE Name LIKE :name';
  IOTA_Query.Params.ParamValues['name']:=Trim(Edit2.Text)+'%';
  IOTA_Query.Active:=True;
end;

end.

