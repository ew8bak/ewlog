unit ClusterServer_Form_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  ExtCtrls, StdCtrls;

type

  { TClusterServer_Form }

  TClusterServer_Form = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  ClusterServer_Form: TClusterServer_Form;

implementation

uses MainForm_U;

{$R *.lfm}

{ TClusterServer_Form }

procedure TClusterServer_Form.FormShow(Sender: TObject);
var
  i, j, k: integer;
  HostArray: array[1..9] of string;
  PortArray: array[1..9] of string;
  NameArray: array[1..9] of string;
begin
  try
    StringGrid1.RowCount := 10;
    for i := 1 to 9 do
    begin
      k := pos('>', TelStr[i]);
      j := pos(':', TelStr[i]);
      NameArray[i] := copy(TelStr[i], 1, k - 3);
      HostArray[i] := copy(TelStr[i], k + 1, j - k - 1);
      Delete(HostArray[i], 1, 1);
      PortArray[i] := copy(TelStr[i], j + 1, Length(TelStr[i]) - k);
    end;
    for i := 1 to 9 do
    begin
      StringGrid1.Cells[0, i] := NameArray[i];
      StringGrid1.Cells[1, i] := HostArray[i];
      StringGrid1.Cells[2, i] := PortArray[i];
    end;
  except
    on e: Exception do
  end;

end;

procedure TClusterServer_Form.FormCreate(Sender: TObject);
begin

end;

procedure TClusterServer_Form.Button1Click(Sender: TObject);
var
  i: integer;
  HostArray: array[1..9] of string;
  PortArray: array[1..9] of string;
  NameArray: array[1..9] of string;
begin
  for i:=1 to 9 do begin
  NameArray[i]:=StringGrid1.Cells[0,i]+' -> ';
  HostArray[i]:=StringGrid1.Cells[1,i]+':';
  PortArray[i]:=StringGrid1.Cells[2,i];
  IniF.WriteString('TelnetCluster','Server'+IntToStr(i),NameArray[i]+HostArray[i]+PortArray[i]);
  end;
  ClusterServer_Form.Close;
end;

end.
