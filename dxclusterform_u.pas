unit dxclusterform_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Buttons, VirtualTrees, telnetClientThread, prefix_record;

type

  { TdxClusterForm }

  TdxClusterForm = class(TForm)
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Memo1: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    VirtualStringTree1: TVirtualStringTree;
    procedure ComboBox1Change(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure VirtualStringTree1Change(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure VirtualStringTree1CompareNodes(Sender: TBaseVirtualTree;
      Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: integer);
    procedure VirtualStringTree1FocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure VirtualStringTree1FreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure VirtualStringTree1GetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: boolean; var ImageIndex: integer);
    procedure VirtualStringTree1GetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: integer);
    procedure VirtualStringTree1GetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure VirtualStringTree1HeaderClick(Sender: TVTHeader;
      HitInfo: TVTHeaderHitInfo);
    procedure VirtualStringTree1NodeClick(Sender: TBaseVirtualTree;
      const HitInfo: THitInfo);
  private
    FlagList: TImageList;
    FlagSList: TStringList;
    function FindNode(const APattern: string; Country: boolean): PVirtualNode;
    procedure FindCountryFlag(Country: string);
    procedure ButtonSet;

  public
    procedure FromClusterThread(buffer: string);
    procedure LoadClusterString;

  end;

var
  dxClusterForm: TdxClusterForm;
  TelStr: array[1..9] of string;
  TelServ, TelPort, TelName: string;

implementation

uses ClusterFilter_Form_U, MainFuncDM, InitDB_dm, dmFunc_U, ClusterServer_Form_U;

type
  PTreeData = ^TTreeData;

  TTreeData = record
    DX: string;
    Spots: string;
    Call: string;
    Freq: string;
    Moda: string;
    Comment: string;
    Time: string;
    Country: string;
    Loc: string;
  end;

{$R *.lfm}

{ TdxClusterForm }

procedure TdxClusterForm.ButtonSet;
begin
  if ConnectCluster then
  begin
    SpeedButton1.Enabled := False;
    SpeedButton2.Enabled := True;
    SpeedButton3.Enabled := True;
    SpeedButton4.Enabled := True;
  end
  else
  begin
    SpeedButton1.Enabled := True;
    SpeedButton2.Enabled := False;
    SpeedButton3.Enabled := False;
    SpeedButton4.Enabled := False;
  end;
end;

procedure TdxClusterForm.LoadClusterString;
var
  i, j: integer;
begin
  for i := 1 to 9 do
  begin
    TelStr[i] := INIFile.ReadString('TelnetCluster', 'Server' +
      IntToStr(i), 'FREERC -> dx.feerc.ru:8000');
  end;
  TelName := INIFile.ReadString('TelnetCluster', 'ServerDef',
    'FREERC -> dx.freerc.ru:8000');
  ComboBox1.Items.Clear;
  ComboBox1.Items.AddStrings(TelStr);
  if ComboBox1.Items.IndexOf(TelName) > -1 then
    ComboBox1.ItemIndex := ComboBox1.Items.IndexOf(TelName)
  else
    ComboBox1.ItemIndex := 0;

  i := pos('>', ComboBox1.Text);
  j := pos(':', ComboBox1.Text);
  //Сервер
  IniSet.Cluster_Host := copy(ComboBox1.Text, i + 1, j - i - 1);
  Delete(IniSet.Cluster_Host, 1, 1);
  //Порт
  IniSet.Cluster_Port := copy(ComboBox1.Text, j + 1, Length(ComboBox1.Text) - i);

end;

procedure TdxClusterForm.FindCountryFlag(Country: string);
var
  pImage: TPortableNetworkGraphic;
begin
  try
    pImage := TPortableNetworkGraphic.Create;
    pImage.LoadFromLazarusResource(dmFunc.ReplaceCountry(Country));
    if FlagSList.IndexOf(dmFunc.ReplaceCountry(Country)) = -1 then
    begin
      FlagList.Add(pImage, nil);
      FlagSList.Add(dmFunc.ReplaceCountry(Country));
    end;
  except
    on EResNotFound do
    begin
      pImage.LoadFromLazarusResource('Unknown');
      if FlagSList.IndexOf('Unknown') = -1 then
      begin
        FlagList.Add(pImage, nil);
        FlagSList.Add('Unknown');
      end;
    end;
  end;
  pImage.Free;
end;

function TdxClusterForm.FindNode(const APattern: string; Country: boolean): PVirtualNode;
var
  ANode: PVirtualNode;
  DataNode: PTreeData;
begin
  Result := nil;
  ANode := VirtualStringTree1.GetFirst();
  while ANode <> nil do
  begin
    DataNode := VirtualStringTree1.GetNodeData(ANode);
    if Country = False then
    begin
      if DataNode^.DX = APattern then
      begin
        Result := ANode;
        exit;
      end;
    end
    else
    begin
      if DataNode^.Country = APattern then
      begin
        Result := ANode;
        exit;
      end;
    end;
    ANode := VirtualStringTree1.GetNext(ANode);
  end;
end;

procedure TdxClusterForm.FromClusterThread(buffer: string);
var
  DX, Call, Freq, Comment, Time, Loc, Band, Mode: string;
  Data: PTreeData;
  XNode: PVirtualNode;
  ShowSpotBand: boolean;
  ShowSpotMode: boolean;
  freqMhz: double;
  PFXR: TPFXR;
begin
  freqMhz := 0;
  DX := '';
  Call := '';
  Freq := '';
  Comment := '';
  Time := '';
  Loc := '';
  Band := '';
  ShowSpotBand := False;
  ShowSpotMode := True;
  ButtonSet;
  if Length(buffer) > 0 then
  begin
    Memo1.Lines.Add(Trim(buffer));

    if (Length(IniSet.Cluster_Login) > 0) and (Pos('login', TelnetLine) > 0) then
      DXTelnetClient.SendMessage(IniSet.Cluster_Login + #13#10, nil);

    if Pos('DX de', buffer) = 1 then
    begin
      buffer := StringReplace(buffer, ':', ' ', [rfReplaceAll]);
      Call := StringReplace(buffer.Substring(6, 8), ' ', '', [rfReplaceAll]);
      Freq := StringReplace(buffer.Substring(15, 10), ' ', '', [rfReplaceAll]);
      DX := StringReplace(buffer.Substring(26, 12), ' ', '', [rfReplaceAll]);
      Comment := Trim(buffer.Substring(39, 30));
      Time := StringReplace(buffer.Substring(70, 2) + ':' +
        buffer.Substring(72, 2), ' ', '', [rfReplaceAll]);
      Loc := StringReplace(buffer.Substring(76, 4), ' ', '', [rfReplaceAll]);
    end;
    if Freq <> '' then
      if TryStrToFloat(Freq, freqMhz) then
        freqMhz := freqMhz / 1000
      else
        exit;

    Band := dmFunc.GetBandFromFreq(FloatToStr(freqMhz));
    // Mode := GetModeFromFreq(FloatToStr(freqMhz));
    if Length(Band) > 0 then
    begin
      if (not ShowSpotBand) or (not ShowSpotMode) then
      begin
        case Band of
          '2190M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[0];
          '630M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[1];
          '160M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[2];
          '80M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[3];
          '60M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[4];
          '40M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[5];
          '30M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[6];
          '20M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[7];
          '17M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[8];
          '15M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[9];
          '12M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[10];
          '10M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[11];
          '6M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[12];
          '4M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[13];
          '2M': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[14];
          '70CM': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[15];
          '23CM': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[16];
          '13CM': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[17];
          '9CM': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[18];
          '6CM': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[19];
          '3CM': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[20];
          '1.25CM': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[21];
          '6MM': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[22];
          '4MM': ShowSpotBand := ClusterFilter.CheckListBox1.Checked[23];
        end;
        case Mode of
          'LSB': ShowSpotMode := ClusterFilter.cbSSB.Checked;
          'USB': ShowSpotMode := ClusterFilter.cbSSB.Checked;
          'CW': ShowSpotMode := ClusterFilter.cbCW.Checked;
          'DIGI': ShowSpotMode := ClusterFilter.cbData.Checked;
        end;
      end;
    end;
    if (Length(DX) > 0) and ShowSpotBand and ShowSpotMode then
    begin
      if FindNode(dmFunc.GetBandFromFreq(FloatToStr(freqMhz)), False) = nil then
      begin
        XNode := VirtualStringTree1.AddChild(nil);
        Data := VirtualStringTree1.GetNodeData(Xnode);
        Data^.DX := dmFunc.GetBandFromFreq(FloatToStr(freqMhz));
        XNode := VirtualStringTree1.AddChild(
          FindNode(dmFunc.GetBandFromFreq(FloatToStr(freqMhz)), False));
        Data := VirtualStringTree1.GetNodeData(Xnode);
        Data^.Spots := DX;
        Data^.Call := Call;
        Data^.Freq := Freq;
        Data^.Moda := Mode;
        Data^.Comment := Comment;
        Data^.Time := Time;
        Data^.Loc := Loc;
        PFXR := MainFunc.SearchPrefix(DX, Loc);
        Data^.Country := PFXR.Country;
        VirtualStringTree1.Expanded[XNode^.Parent] := ClusterFilter.CheckBox1.Checked;
        FindCountryFlag(Data^.Country);
      end
      else
      begin
        XNode := VirtualStringTree1.InsertNode(
          FindNode(dmFunc.GetBandFromFreq(FloatToStr(freqMhz)), False), amAddChildFirst);
        Data := VirtualStringTree1.GetNodeData(Xnode);
        Data^.Spots := DX;
        Data^.Call := Call;
        Data^.Freq := Freq;
        Data^.Moda := Mode;
        Data^.Comment := Comment;
        Data^.Time := Time;
        Data^.Loc := Loc;
        PFXR := MainFunc.SearchPrefix(DX, Loc);
        Data^.Country := PFXR.Country;
        FindCountryFlag(Data^.Country);
      end;
    end;
  end;
end;

procedure TdxClusterForm.VirtualStringTree1Change(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  VirtualStringTree1.Refresh;
end;

procedure TdxClusterForm.SpeedButton1Click(Sender: TObject);
begin
  TelnetThread := TTelnetThread.Create;
  if Assigned(TelnetThread.FatalException) then
    raise TelnetThread.FatalException;
  TelnetThread.Start;
  SpeedButton1.Enabled := False;
end;

procedure TdxClusterForm.SpeedButton2Click(Sender: TObject);
begin
  if not VirtualStringTree1.IsEmpty and (PageControl1.ActivePageIndex = 1) then
  begin
    VirtualStringTree1.BeginUpdate;
    VirtualStringTree1.Clear;
    VirtualStringTree1.EndUpdate;
  end;
  if PageControl1.ActivePageIndex = 0 then
    Memo1.Clear;
end;

procedure TdxClusterForm.SpeedButton3Click(Sender: TObject);
begin
  DXTelnetClient.SendMessage('bye' + #13#10);
end;

procedure TdxClusterForm.SpeedButton5Click(Sender: TObject);
begin
  ClusterFilter.Show;
end;

procedure TdxClusterForm.SpeedButton6Click(Sender: TObject);
begin
  ClusterServer_Form.Show;
end;

procedure TdxClusterForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if TelnetThread <> nil then
    TelnetThread.Terminate;
  INIFile.WriteString('TelnetCluster', 'ServerDef', ComboBox1.Text);
  MainFunc.SetDXColumns(VirtualStringTree1, True, VirtualStringTree1);
end;

procedure TdxClusterForm.FormCreate(Sender: TObject);
begin
  FlagList := TImageList.Create(Self);
  FlagSList := TStringList.Create;
  VirtualStringTree1.Images := FlagList;
  LoadClusterString;
  MainFunc.SetDXColumns(VirtualStringTree1, False, VirtualStringTree1);
end;

procedure TdxClusterForm.FormDestroy(Sender: TObject);
begin
  FlagList.Free;
  FlagSList.Free;
end;

procedure TdxClusterForm.FormResize(Sender: TObject);
begin
  ComboBox1.Width := dxClusterForm.Width - 200;
end;

procedure TdxClusterForm.FormShow(Sender: TObject);
begin
  ButtonSet;
end;

procedure TdxClusterForm.Edit1KeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    DXTelnetClient.SendMessage(Edit1.Text + #13#10, nil);
    Edit1.Clear;
  end;
end;

procedure TdxClusterForm.ComboBox1Change(Sender: TObject);
var
  i, j: integer;
begin
  i := pos('>', ComboBox1.Text);
  j := pos(':', ComboBox1.Text);
  //Сервер
  IniSet.Cluster_Host := copy(ComboBox1.Text, i + 1, j - i - 1);
  Delete(IniSet.Cluster_Host, 1, 1);
  //Порт
  IniSet.Cluster_Port := copy(ComboBox1.Text, j + 1, Length(ComboBox1.Text) - i);
end;

procedure TdxClusterForm.VirtualStringTree1CompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: integer);
begin
  with TVirtualStringTree(Sender) do
    Result := AnsiCompareText(Text[Node1, Column], Text[Node2, Column]);
end;

procedure TdxClusterForm.VirtualStringTree1FocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  VirtualStringTree1.Refresh;
end;

procedure TdxClusterForm.VirtualStringTree1FreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PTreeData;
begin
  Data := VirtualStringTree1.GetNodeData(Node);
  if Assigned(Data) then
  begin
    Data^.DX := '';
    Data^.Spots := '';
    Data^.Call := '';
    Data^.Freq := '';
    Data^.Moda := '';
    Data^.Comment := '';
    Data^.Time := '';
    Data^.Loc := '';
    Data^.Country := '';
  end;
end;

procedure TdxClusterForm.VirtualStringTree1GetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: boolean; var ImageIndex: integer);
var
  Data: PTreeData;
begin
  if Column <> 8 then
    Exit;

  ImageIndex := -1;
  Data := VirtualStringTree1.GetNodeData(Node);
  if Assigned(Data) then
  begin
    ImageIndex := FlagSList.IndexOf(dmFunc.ReplaceCountry(Data^.Country));
  end;
end;

procedure TdxClusterForm.VirtualStringTree1GetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: integer);
begin
  NodeDataSize := SizeOf(TTreeData);
end;

procedure TdxClusterForm.VirtualStringTree1GetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PTreeData;
begin
  Data := VirtualStringTree1.GetNodeData(Node);
  case Column of
    0: CellText := Data^.DX;
    1: CellText := Data^.Spots;
    2: CellText := Data^.Call;
    3: CellText := Data^.Freq;
    4: CellText := Data^.Moda;
    5: CellText := Data^.Comment;
    6: CellText := Data^.Time;
    7: CellText := Data^.Loc;
    8: CellText := Data^.Country;
  end;
end;

procedure TdxClusterForm.VirtualStringTree1HeaderClick(Sender: TVTHeader;
  HitInfo: TVTHeaderHitInfo);
begin
  if HitInfo.Button = mbLeft then
  begin
    VirtualStringTree1.Header.SortColumn := HitInfo.Column;
    if VirtualStringTree1.Header.SortDirection = sdAscending then
      VirtualStringTree1.Header.SortDirection := sdDescending
    else
      VirtualStringTree1.Header.SortDirection := sdAscending;
    VirtualStringTree1.SortTree(HitInfo.Column, VirtualStringTree1.Header.SortDirection);
  end;
end;

procedure TdxClusterForm.VirtualStringTree1NodeClick(Sender: TBaseVirtualTree;
  const HitInfo: THitInfo);
var
  XNode: PVirtualNode;
begin
  XNode := VirtualStringTree1.FocusedNode;
  VirtualStringTree1.Selected[XNode] := True;
end;


end.
