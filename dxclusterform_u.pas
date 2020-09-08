unit dxclusterform_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Buttons, Menus, VirtualTrees, telnetClientThread,
  prefix_record, const_u, SQLDB, ResourceStr;

type

  { TdxClusterForm }

  TdxClusterForm = class(TForm)
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PopupCluster: TPopupMenu;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    VirtualStringTree1: TVirtualStringTree;
    procedure ComboBox1Change(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure Edit3KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure VirtualStringTree1Change(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure VirtualStringTree1Click(Sender: TObject);
    procedure VirtualStringTree1CompareNodes(Sender: TBaseVirtualTree;
      Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: integer);
    procedure VirtualStringTree1DblClick(Sender: TObject);
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
    function GetModeFromFreq(MHz: string): string;

  public
    procedure FromClusterThread(buffer: string);
    procedure LoadClusterString;
    procedure SendSpot(freq, call, cname, mode, rsts, grid: string);

  end;

var
  dxClusterForm: TdxClusterForm;
  TelStr: array[1..9] of string;
  TelServ, TelPort, TelName: string;
  qBands: TSQLQuery;

implementation

uses ClusterFilter_Form_U, MainFuncDM, InitDB_dm, dmFunc_U,
  ClusterServer_Form_U, MainForm_U, Earth_Form_U, TRXForm_U, sendtelnetspot_form_U;

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

function TdxClusterForm.GetModeFromFreq(MHz: string): string;
var
  Band: string;
  tmp: extended;
begin
  try
    Result := '';
    band := dmFunc.GetBandFromFreq(MHz);

    //  MHz := MHz.replace('.', DefaultFormatSettings.DecimalSeparator);
    //  MHz := MHz.replace(',', DefaultFormatSettings.DecimalSeparator);

    qBands.Close;
    qBands.SQL.Text := 'SELECT * FROM Bands WHERE band = ' + QuotedStr(band);
    try
      qBands.Open;
      tmp := StrToFloat(MHz);

      if qBands.RecordCount > 0 then
      begin
        if ((tmp >= qBands.FieldByName('B_BEGIN').AsCurrency) and
          (tmp <= qBands.FieldByName('CW').AsCurrency)) then
          Result := 'CW'
        else
        begin
          if ((tmp > qBands.FieldByName('DIGI').AsCurrency) and
            (tmp <= qBands.FieldByName('SSB').AsCurrency)) then
            Result := 'DIGI'
          else
          begin
            if (tmp > 5) and (tmp < 6) then
              Result := 'USB'
            else
            begin
              if tmp > 10 then
                Result := 'USB'
              else
                Result := 'LSB';
            end;
          end;
        end;
      end
    finally
      qBands.Close;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('GetModeFromFreq: Error: ' + E.ClassName + #13#10 + E.Message);
      WriteLn(ExceptFile, 'GetModeFromFreq: Error: ' + E.ClassName +
        ':' + E.Message);
      Result := '';
    end;
  end;
end;

procedure TdxClusterForm.SendSpot(freq, call, cname, mode, rsts, grid: string);
var
  comment: string;
begin
  comment := cname + ' ' + mode + ' ' + rsts;
  try
    DXTelnetClient.SendMessage(Trim(Format('dx %s %s %s', [freq, call, comment])) +
      #13#10);
  except
    on E: Exception do
      Memo1.Append(E.Message);
  end;
end;

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

    if Pos(UpperCase(IniSet.Cluster_Login) + ' de', buffer) > 0 then
    begin
      Memo2.Lines.Add(buffer);
      exit;
    end;

    if Pos('WCY de', buffer) > 0 then
    begin
      Memo3.Lines.Add(buffer);
      exit;
    end;

    if Pos('To ALL de', buffer) > 0 then
    begin
      Memo4.Lines.Add(buffer);
      exit;
    end;

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
    if Length(Loc) < 4 then
      Loc := '';

    Band := dmFunc.GetBandFromFreq(FloatToStr(freqMhz));
    Mode := GetModeFromFreq(FloatToStr(freqMhz));
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

procedure TdxClusterForm.VirtualStringTree1Click(Sender: TObject);
var
  XNode: PVirtualNode;
  Data: PTreeData;
  PFXR: TPFXR;
  Lat, Lon: string;
begin
  XNode := VirtualStringTree1.FocusedNode;
  Data := VirtualStringTree1.GetNodeData(XNode);
  if VirtualStringTree1.SelectedCount <> 0 then
  begin
    if Length(Data^.Spots) > 1 then
    begin
      PFXR := MainFunc.SearchPrefix(Data^.Spots, Data^.Loc);
      MainForm.Label32.Caption := PFXR.Azimuth;
      MainForm.Label37.Caption := PFXR.Distance;
      MainForm.Label40.Caption := PFXR.Latitude;
      MainForm.Label42.Caption := PFXR.Longitude;
      MainForm.Label33.Caption := PFXR.Country;
      MainForm.Label43.Caption := PFXR.Continent;
      MainForm.Label34.Caption := PFXR.ARRLPrefix;
      MainForm.Label38.Caption := PFXR.Prefix;
      MainForm.Label45.Caption := PFXR.CQZone;
      MainForm.Label47.Caption := PFXR.ITUZone;
      timedif := PFXR.TimeDiff;
      dmFunc.GetLatLon(PFXR.Latitude, PFXR.Longitude, Lat, Lon);
      Earth.PaintLine(Lat, Lon, LBRecord.OpLat, LBRecord.OpLon);
      Earth.PaintLine(Lat, Lon, LBRecord.OpLat, LBRecord.OpLon);
      if PFXR.Found and MainForm.CheckBox3.Checked then
        MainFunc.LoadMaps(Lat, Lon, MainForm.MapView1);
    end;
  end;
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

procedure TdxClusterForm.SpeedButton4Click(Sender: TObject);
begin
  SendTelnetSpot.Show;
end;

procedure TdxClusterForm.SpeedButton5Click(Sender: TObject);
begin
  ClusterFilter.Show;
end;

procedure TdxClusterForm.SpeedButton6Click(Sender: TObject);
begin
  ClusterServer_Form.Show;
end;

procedure TdxClusterForm.SpeedButton7Click(Sender: TObject);
begin
  if Length(Edit2.Text) > 2 then
  begin
    DXTelnetClient.SendMessage('talk ' + Edit2.Text + ' ' + Edit3.Text + #13#10, nil);
    Edit3.Clear;
  end
  else
    Memo2.Text := rCallsignNotEntered;
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
  qBands := TSQLQuery.Create(nil);
  qBands.DataBase := InitDB.ServiceDBConnection;
  LoadClusterString;
  MainFunc.SetDXColumns(VirtualStringTree1, False, VirtualStringTree1);
end;

procedure TdxClusterForm.FormDestroy(Sender: TObject);
begin
  FlagList.Free;
  FlagSList.Free;
  FreeAndNil(qBands);
end;

procedure TdxClusterForm.FormResize(Sender: TObject);
begin
  ComboBox1.Width := dxClusterForm.Width - 180;
  Edit3.Width := dxClusterForm.Width - 105;
end;

procedure TdxClusterForm.FormShow(Sender: TObject);
begin
  ButtonSet;
end;

procedure TdxClusterForm.MenuItem1Click(Sender: TObject);
var
  XNode: PVirtualNode;
  Data: PTreeData;
begin
  XNode := VirtualStringTree1.FocusedNode;
  Data := VirtualStringTree1.GetNodeData(XNode);
  if VirtualStringTree1.SelectedCount <> 0 then
    if Length(Data^.Spots) > 1 then
      MainForm.EditButton1.Text := Data^.Spots;
end;

procedure TdxClusterForm.MenuItem2Click(Sender: TObject);
begin
  VirtualStringTree1.DeleteSelectedNodes;
end;

procedure TdxClusterForm.MenuItem3Click(Sender: TObject);
begin
  if not VirtualStringTree1.IsEmpty then
  begin
    VirtualStringTree1.BeginUpdate;
    VirtualStringTree1.Clear;
    VirtualStringTree1.EndUpdate;
  end;
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

procedure TdxClusterForm.Edit3KeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    if Length(Edit2.Text) > 2 then
    begin
      DXTelnetClient.SendMessage('talk ' + Edit2.Text + ' ' + Edit3.Text + #13#10, nil);
      Edit3.Clear;
    end
    else
      Memo2.Text := rCallsignNotEntered;
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

procedure TdxClusterForm.VirtualStringTree1DblClick(Sender: TObject);
var
  XNode: PVirtualNode;
  Data: PTreeData;
begin
  XNode := VirtualStringTree1.FocusedNode;
  Data := VirtualStringTree1.GetNodeData(XNode);
  if VirtualStringTree1.SelectedCount <> 0 then
  begin
    if Length(Data^.Spots) > 1 then
    begin
      MainForm.EditButton1.Text := Data^.Spots;
      // if (CallBookLiteConnection.Connected = False) and
      //   (Length(Data^.Spots) >= 3) then
      //   InformationForm.GetInformation(Data^.Spots, True);

      if Assigned(TRXForm.radio) and (Length(Data^.Freq) > 1) and
        (TRXForm.radio.GetFreqHz > 0) then
      begin
        TRXForm.radio.SetFreqKHz(StrToFloat(Data^.Freq));
        if Data^.Moda = 'DIGI' then
          TRXForm.SetMode('USB', 0)
        else
          TRXForm.SetMode(Data^.Moda, 0);
      end
      else
      begin
        if IniSet.showBand then
          MainForm.ComboBox1.Text :=
            dmFunc.GetBandFromFreq(FormatFloat(view_freq,
            StrToFloat(Data^.Freq) / 1000))
        else
          MainForm.ComboBox1.Text :=
            FormatFloat(view_freq, StrToFloat(Data^.Freq) / 1000);

        if (Data^.Moda = 'LSB') or (Data^.Moda = 'USB') then
        begin
          MainForm.ComboBox2.Text := 'SSB';
          MainForm.ComboBox2CloseUp(Sender);
          MainForm.ComboBox9.Text := Data^.Moda;
        end;
        if Data^.Moda = 'DIGI' then
        begin
          MainForm.ComboBox2.Text := 'SSB';
          MainForm.ComboBox2CloseUp(Sender);
          MainForm.ComboBox9.Text := 'USB';
        end;
        if Data^.Moda = 'CW' then
        begin
          MainForm.ComboBox2.Text := 'CW';
          MainForm.ComboBox2CloseUp(Sender);
          MainForm.ComboBox9.Text := '';
        end;
      end;
    end;
  end;

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
