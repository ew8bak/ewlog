unit ClusterFilter_Form_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, CheckLst;

type

  { TClusterFilter }

  TClusterFilter = class(TForm)
    cbSSB: TCheckBox;
    cbCW: TCheckBox;
    cbData: TCheckBox;
    CheckListBox1: TCheckListBox;
    GroupBox2: TGroupBox;
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure ReadBandsModes;
    procedure WriteBandsModes;
    { private declarations }
  public
    { public declarations }
  end;

var
  ClusterFilter: TClusterFilter;

implementation

uses
  MainForm_U, const_u, ResourceStr;

{$R *.lfm}

{ TClusterFilter }

procedure TClusterFilter.ReadBandsModes;
var
  i: integer;
begin
  for i := 0 to CheckListBox1.Items.Count - 1 do
  begin
    CheckListBox1.Checked[i] :=
      IniF.ReadBool('TelnetCluster', 'BandsModes' + IntToStr(i), True);
  end;
end;

procedure TClusterFilter.WriteBandsModes;
var
  i: integer;
begin
  for i := 0 to CheckListBox1.Items.Count - 1 do
  begin
    IniF.WriteBool('TelnetCluster', 'BandsModes' + IntToStr(i),
      CheckListBox1.Checked[i]);
  end;
end;

procedure TClusterFilter.FormCreate(Sender: TObject);
var
  i: integer;
begin
  for i := Length(bandsMm) - 1 downto 0 do
  begin
    CheckListBox1.Items.Add(bandsMm[i] + ' / ' + bandsHz[i] + ' ' + rMHZ);
  end;
  ReadBandsModes;
end;

procedure TClusterFilter.CheckListBox1ClickCheck(Sender: TObject);
begin
  WriteBandsModes;
end;

procedure TClusterFilter.FormShow(Sender: TObject);
begin
  ReadBandsModes;
end;

end.
