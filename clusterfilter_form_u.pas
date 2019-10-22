unit ClusterFilter_Form_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TClusterFilter }

  TClusterFilter = class(TForm)
    cb160m: TCheckBox;
    cb80m: TCheckBox;
    cb6m: TCheckBox;
    cb4m: TCheckBox;
    cb2m: TCheckBox;
    cb70cm: TCheckBox;
    cb60m: TCheckBox;
    cb40m: TCheckBox;
    cb30m: TCheckBox;
    cb20m: TCheckBox;
    cb17m: TCheckBox;
    cb15m: TCheckBox;
    cb12m: TCheckBox;
    cb10m: TCheckBox;
    cbSSB: TCheckBox;
    cbCW: TCheckBox;
    cbData: TCheckBox;
    cbAllModes: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure ReadBandsModes();
    { private declarations }
  public
    { public declarations }
  end;

var
  ClusterFilter: TClusterFilter;

implementation

uses
  MainForm_U;

{$R *.lfm}

{ TClusterFilter }

procedure TClusterFilter.ReadBandsModes();
var
  i: integer;
begin
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TCheckBox then
    begin
      (Components[i] as TCheckBox).Checked :=
        IniF.ReadBool('TelnetCluster', 'BandsModes' + IntToStr(i), True);
    end;
end;

procedure TClusterFilter.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i: integer;
begin
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TCheckBox then
    begin
      IniF.WriteBool('TelnetCluster', 'BandsModes' + IntToStr(i),
        (Components[i] as TCheckBox).Checked);
    end;
end;

procedure TClusterFilter.FormCreate(Sender: TObject);
begin
  ReadBandsModes;
end;

procedure TClusterFilter.FormShow(Sender: TObject);
begin
  ReadBandsModes;
end;

end.
