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
  ComCtrls, CheckLst, Spin, const_u;

type

  { TClusterFilter }

  TClusterFilter = class(TForm)
    Button1: TButton;
    Button2: TButton;
    cbSSB: TCheckBox;
    cbCW: TCheckBox;
    cbData: TCheckBox;
    CheckBox1: TCheckBox;
    CBDeleteNode: TCheckBox;
    CLBFilterBands: TCheckListBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    SEDelSpot: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CLBFilterBandsClickCheck(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure ReadBandsModes;
    procedure WriteBandsModes;
    procedure DeleteFilteredNodes;
    { private declarations }
  public
    { public declarations }
  end;

var
  ClusterFilter: TClusterFilter;

implementation

uses
  MainForm_U, ResourceStr, InitDB_dm, dxclusterform_u;

{$R *.lfm}

{ TClusterFilter }

procedure TClusterFilter.ReadBandsModes;
var
  i: integer;
begin
  for i := 0 to CLBFilterBands.Items.Count - 1 do
  begin
    CLBFilterBands.Checked[i] :=
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
  CBDeleteNode.Checked := INIFile.ReadBool('TelnetCluster', 'DeleteNodeOnFilter', False);
  SEDelSpot.Value := INIFile.ReadInteger('TelnetCluster', 'spotDelTime', 15);
end;

procedure TClusterFilter.WriteBandsModes;
var
  i: integer;
begin
  for i := 0 to CLBFilterBands.Items.Count - 1 do
  begin
    INIFile.WriteBool('TelnetCluster', 'Bands' + IntToStr(i),
      CLBFilterBands.Checked[i]);
  end;
  INIFile.WriteBool('TelnetCluster', 'DX_CW', cbCW.Checked);
  INIFile.WriteBool('TelnetCluster', 'DX_Phone', cbSSB.Checked);
  INIFile.WriteBool('TelnetCluster', 'DX_DIGI', cbData.Checked);
  INIFile.WriteBool('TelnetCluster', 'Expand', CheckBox1.Checked);
  INIFile.WriteBool('TelnetCluster', 'DeleteNodeOnFilter', CBDeleteNode.Checked);
  INIFile.WriteString('TelnetCluster', 'CWMode', Edit1.Text);
  INIFile.WriteString('TelnetCluster', 'PhoneMode', Edit2.Text);
  INIFile.WriteString('TelnetCluster', 'DIGIMode', Edit3.Text);
  INIFile.WriteInteger('TelnetCluster', 'spotDelTime', SEDelSpot.Value);
end;

procedure TClusterFilter.FormCreate(Sender: TObject);
var
  i: integer;
begin
  for i := Length(bandsMm) - 1 downto 0 do
  begin
    CLBFilterBands.Items.Add(bandsMm[i] + ' / ' + bandsHz[i] + ' ' + rMHZ);
  end;
  ReadBandsModes;
end;

procedure TClusterFilter.CLBFilterBandsClickCheck(Sender: TObject);
begin
  WriteBandsModes;
  if CBDeleteNode.Checked then
    DeleteFilteredNodes;
end;

procedure TClusterFilter.DeleteFilteredNodes;
var
  i, j: integer;
  arrayBands: array [0..23] of string;
begin
  j := 0;
  for i := High(bandsMm) downto 0 do
  begin
    arrayBands[i] := bandsMm[j];
    Inc(j);
  end;

  for i := 0 to High(arrayBands) do
  begin
    if not ClusterFilter.CLBFilterBands.Checked[i] then
      DXClusterForm.FindAndDeleteBand(arrayBands[i]);
  end;
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
