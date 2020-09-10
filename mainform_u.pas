unit MainForm_U;

{$mode objfpc}{$H+}

interface

uses
  Forms, ExtCtrls, Classes, Controls;

type
  { TMainForm }

  TMainForm = class(TForm)
    LeftPanel: TPanel;
    AllClientPanel: TPanel;
    GridsPanel: TPanel;
    ClusterPanel: TPanel;
    EarthPanel: TPanel;
    MiniPanel: TPanel;
    OtherPanel: TPanel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }

  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses miniform_u, GridsForm_u, Earth_Form_U, dxclusterform_u;

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormShow(Sender: TObject);
begin
  MiniForm.Menu:=nil;
  MainForm.Menu := MiniForm.MainMenu;
  MiniForm.Parent := MiniPanel;
  MiniForm.BorderStyle := bsNone;
  MiniForm.Align := alClient;
  GridsForm.Parent := GridsPanel;
  GridsForm.BorderStyle := bsNone;
  GridsForm.Align := alClient;
  Earth.Parent := EarthPanel;
  Earth.BorderStyle := bsNone;
  Earth.Align := alClient;
  dxClusterForm.Parent := ClusterPanel;
  dxClusterForm.BorderStyle := bsNone;
  dxClusterForm.Align := alClient;
  MiniForm.Show;
  GridsForm.Show;
  Earth.Show;
  dxClusterForm.Show;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  MiniForm.Close;
  GridsForm.Close;
  Earth.Close;
  dxClusterForm.Close;
end;

end.
