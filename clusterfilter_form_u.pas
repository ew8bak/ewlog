unit ClusterFilter_Form_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, CheckLst, Spin;

type

  { TClusterFilter }

  TClusterFilter = class(TForm)
    Button1: TButton;
    Button2: TButton;
    cbSSB: TCheckBox;
    cbCW: TCheckBox;
    cbData: TCheckBox;
    CheckListBox1: TCheckListBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    SpinEdit1: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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
      IniF.ReadBool('TelnetCluster', 'Bands' + IntToStr(i), True);
  end;
  if Length(IniF.ReadString('TelnetCluster', 'CWMode', '')) > 0 then
    Edit1.Text := IniF.ReadString('TelnetCluster', 'CWMode', '');
  if Length(IniF.ReadString('TelnetCluster', 'PhoneMode', '')) > 0 then
    Edit2.Text := IniF.ReadString('TelnetCluster', 'PhoneMode', '');
  if Length(IniF.ReadString('TelnetCluster', 'DIGIMode', '')) > 0 then
    Edit3.Text := IniF.ReadString('TelnetCluster', 'DIGIMode', '');
  cbCW.Checked := IniF.ReadBool('TelnetCluster', 'DX_CW', True);
  cbSSB.Checked := IniF.ReadBool('TelnetCluster', 'DX_Phone', True);
  cbData.Checked := IniF.ReadBool('TelnetCluster', 'DX_DIGI', True);
  SpinEdit1.Value := IniF.ReadInteger('TelnetCluster', 'spotDelTime', 15);
end;

procedure TClusterFilter.WriteBandsModes;
var
  i: integer;
begin
  for i := 0 to CheckListBox1.Items.Count - 1 do
  begin
    IniF.WriteBool('TelnetCluster', 'Bands' + IntToStr(i),
      CheckListBox1.Checked[i]);
  end;
  IniF.WriteBool('TelnetCluster', 'DX_CW', cbCW.Checked);
  IniF.WriteBool('TelnetCluster', 'DX_Phone', cbSSB.Checked);
  IniF.WriteBool('TelnetCluster', 'DX_DIGI', cbData.Checked);
  IniF.WriteString('TelnetCluster', 'CWMode', Edit1.Text);
  IniF.WriteString('TelnetCluster', 'PhoneMode', Edit2.Text);
  IniF.WriteString('TelnetCluster', 'DIGIMode', Edit3.Text);
  IniF.WriteInteger('TelnetCluster', 'spotDelTime', SpinEdit1.Value);
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

procedure TClusterFilter.Button1Click(Sender: TObject);
begin
  ClusterFilter.Close;
end;

procedure TClusterFilter.Button2Click(Sender: TObject);
begin
  WriteBandsModes;
end;

procedure TClusterFilter.FormShow(Sender: TObject);
begin
  ReadBandsModes;
end;

end.
