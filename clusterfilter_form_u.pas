(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

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
    CheckBox1: TCheckBox;
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
  MainForm_U, const_u, ResourceStr, InitDB_dm;

{$R *.lfm}

{ TClusterFilter }

procedure TClusterFilter.ReadBandsModes;
var
  i: integer;
begin
  for i := 0 to CheckListBox1.Items.Count - 1 do
  begin
    CheckListBox1.Checked[i] :=
      INIFile.ReadBool('TelnetCluster', 'Bands' + IntToStr(i), True);
  end;
  if Length(INIFile.ReadString('TelnetCluster', 'CWMode', '')) > 0 then
    Edit1.Text := INIFile.ReadString('TelnetCluster', 'CWMode', '');
  if Length(INIFile.ReadString('TelnetCluster', 'PhoneMode', '')) > 0 then
    Edit2.Text := INIFile.ReadString('TelnetCluster', 'PhoneMode', '');
  if Length(INIFile.ReadString('TelnetCluster', 'DIGIMode', '')) > 0 then
    Edit3.Text := INIFile.ReadString('TelnetCluster', 'DIGIMode', '');
  cbCW.Checked := INIFile.ReadBool('TelnetCluster', 'DX_CW', True);
  cbSSB.Checked := INIFile.ReadBool('TelnetCluster', 'DX_Phone', True);
  cbData.Checked := INIFile.ReadBool('TelnetCluster', 'DX_DIGI', True);
  CheckBox1.Checked := INIFile.ReadBool('TelnetCluster', 'Expand', True);
  SpinEdit1.Value := INIFile.ReadInteger('TelnetCluster', 'spotDelTime', 15);
end;

procedure TClusterFilter.WriteBandsModes;
var
  i: integer;
begin
  for i := 0 to CheckListBox1.Items.Count - 1 do
  begin
    INIFile.WriteBool('TelnetCluster', 'Bands' + IntToStr(i),
      CheckListBox1.Checked[i]);
  end;
  INIFile.WriteBool('TelnetCluster', 'DX_CW', cbCW.Checked);
  INIFile.WriteBool('TelnetCluster', 'DX_Phone', cbSSB.Checked);
  INIFile.WriteBool('TelnetCluster', 'DX_DIGI', cbData.Checked);
  INIFile.WriteBool('TelnetCluster', 'Expand', CheckBox1.Checked);
  INIFile.WriteString('TelnetCluster', 'CWMode', Edit1.Text);
  INIFile.WriteString('TelnetCluster', 'PhoneMode', Edit2.Text);
  INIFile.WriteString('TelnetCluster', 'DIGIMode', Edit3.Text);
  INIFile.WriteInteger('TelnetCluster', 'spotDelTime', SpinEdit1.Value);
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
