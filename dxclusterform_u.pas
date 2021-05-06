(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit dxclusterform_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Buttons, Menus, VirtualTrees, telnetClientThread,
  prefix_record, const_u, SQLDB, ResourceStr, LCLType, DateUtils, LazSysUtils;

type

  { TdxClusterForm }

  TdxClusterForm = class(TForm)
    CBServers: TComboBox;
    EditCommand: TEdit;
    EditCallsign: TEdit;
    EditMessage: TEdit;
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
    SBConnect: TSpeedButton;
    SBClear: TSpeedButton;
    SBDisconnect: TSpeedButton;
    SBSentDX: TSpeedButton;
    SBFilter: TSpeedButton;
    SBEditServers: TSpeedButton;
    SpeedButton7: TSpeedButton;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    CheckClusterTimer: TTimer;
    VSTCluster: TVirtualStringTree;
    procedure CBServersChange(Sender: TObject);
    procedure CheckClusterTimerTimer(Sender: TObject);
    procedure EditCommandKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure EditMessageKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure SBConnectClick(Sender: TObject);
    procedure SBClearClick(Sender: TObject);
    procedure SBDisconnectClick(Sender: TObject);
    procedure SBSentDXClick(Sender: TObject);
    procedure SBFilterClick(Sender: TObject);
    procedure SBEditServersClick(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure VSTClusterChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VSTClusterClick(Sender: TObject);
    procedure VSTClusterCompareNodes(Sender: TBaseVirtualTree;
      Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: integer);
    procedure VSTClusterDblClick(Sender: TObject);
    procedure VSTClusterFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure VSTClusterFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VSTClusterGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: boolean; var ImageIndex: integer);
    procedure VSTClusterGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: integer);
    procedure VSTClusterGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure VSTClusterHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    procedure VSTClusterNodeClick(Sender: TBaseVirtualTree;
      const HitInfo: THitInfo);
  private
    FlagList: TImageList;
    FlagSList: TStringList;
    function FindNode(const APattern: string; Country: boolean): PVirtualNode;
    procedure FindCountryFlag(Country: string);
    procedure ButtonSet;
    function GetModeFromFreq(MHz: string): string;
    procedure CheckClusterRestartTimer;
    procedure FindAndDeleteSpot(min: integer);

  public
    procedure FromClusterThread(buffer: string);
    procedure LoadClusterString;
    procedure SendSpot(freq, call, cname, mode, rsts, grid: string);
    procedure SavePosition;
    procedure FreeClusterThread;
    procedure FindAndDeleteBand(band: string);

  end;

var
  dxClusterForm: TdxClusterForm;
  //TelStr: array[1..9] of string;
  TelServ, TelPort, TelName: string;
  qBands: TSQLQuery;

implementation

uses ClusterFilter_Form_U, MainFuncDM, InitDB_dm, dmFunc_U,
  MainForm_U, Earth_Form_U, TRXForm_U,
  sendtelnetspot_form_U, miniform_u, infoDM_U, ConfigForm_U;

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

procedure TdxClusterForm.SavePosition;
begin
  if (IniSet.MainForm = 'MULTI') and IniSet.cShow then
    if dxClusterForm.WindowState <> wsMaximized then
    begin
      INIFile.WriteInteger('SetLog', 'cLeft', dxClusterForm.Left);
      INIFile.WriteInteger('SetLog', 'cTop', dxClusterForm.Top);
      INIFile.WriteInteger('SetLog', 'cWidth', dxClusterForm.Width);
      INIFile.WriteInteger('SetLog', 'cHeight', dxClusterForm.Height);
    end;
end;

function TdxClusterForm.GetModeFromFreq(MHz: string): string;
var
  Band: string;
  tmp: extended;
begin
  try
    Result := '';
    band := dmFunc.GetBandFromFreq(MHz);

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
    SBConnect.Enabled := False;
    SBClear.Enabled := True;
    SBDisconnect.Enabled := True;
    SBSentDX.Enabled := True;
  end
  else
  begin
    SBConnect.Enabled := True;
    SBClear.Enabled := False;
    SBDisconnect.Enabled := False;
    SBSentDX.Enabled := False;
  end;
end;

procedure TdxClusterForm.LoadClusterString;
var
  i, j: integer;
begin
  {for i := 1 to 9 do
  begin
    TelStr[i] := INIFile.ReadString('TelnetCluster', 'Server' +
      IntToStr(i), 'FEERC -> dx.feerc.ru:8000');
  end;
  TelName := INIFile.ReadString('TelnetCluster', 'ServerDef',
    'FEERC -> dx.feerc.ru:8000');
  CBServers.Items.Clear;
  CBServers.Items.AddStrings(TelStr);
  if CBServers.Items.IndexOf(TelName) > -1 then
    CBServers.ItemIndex := CBServers.Items.IndexOf(TelName)
  else
    CBServers.ItemIndex := 0;

  i := pos('>', CBServers.Text);
  j := pos(':', CBServers.Text);
  //Сервер
  IniSet.Cluster_Host := copy(CBServers.Text, i + 1, j - i - 1);
  Delete(IniSet.Cluster_Host, 1, 1);
  //Порт
  IniSet.Cluster_Port := copy(CBServers.Text, j + 1, Length(CBServers.Text) - i);
 }
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
  ANode := VSTCluster.GetFirst();
  while ANode <> nil do
  begin
    DataNode := VSTCluster.GetNodeData(ANode);
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
    ANode := VSTCluster.GetNext(ANode);
  end;
end;

procedure TdxClusterForm.FindAndDeleteBand(band: string);
begin
  if FindNode(band, False) <> nil then
    VSTCluster.DeleteNode(FindNode(band, False));
end;

procedure TdxClusterForm.FindAndDeleteSpot(min: integer);
var
  ANode, SubNode, TmpNode: PVirtualNode;
  DataNode: PTreeData;
  NowUTCTime: TTime;
begin
  NowUTCTime := StrToTime(FormatDateTime('h:m', NowUTC));
  ANode := VSTCluster.GetFirst;
  while Assigned(ANode) do
  begin
    TmpNode := VSTCluster.GetNext(ANode);
    DataNode := VSTCluster.GetNodeData(ANode);
    SubNode := VSTCluster.GetFirstChild(ANode);
    if (SubNode = nil) then
    begin
      if DataNode^.Time <> '' then
      begin
        if MinutesBetween(NowUTCTime, StrToTime(DataNode^.Time, ':')) > min then
          VSTCluster.DeleteNode(ANode);
      end
      else
        VSTCluster.DeleteNode(ANode);
    end;
    ANode := TmpNode;
  end;
end;

procedure TdxClusterForm.CheckClusterRestartTimer;
begin
  CheckClusterTimer.Enabled := False;
  CheckClusterTimer.Interval := ClusterFilter.SEReconnect.Value * 60000;
  CheckClusterTimer.Enabled := True;
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
    buffer := StringReplace(buffer, #7, ' ', [rfReplaceAll]);
    buffer := Trim(buffer);
    Memo1.Lines.Add(buffer);

    if (Length(IniSet.Cluster_Login) > 0) and (Pos('login', TelnetLine) = 1) then
      DXTelnetClient.SendMessage(IniSet.Cluster_Login + #13#10, nil);

    {if Length(IniSet.Cluster_Login) > 0 then
      if (Pos(UpperCase(IniSet.Cluster_Login) + ' de', buffer) > 0) and
        (Pos('>', buffer) <> Length(buffer)) then
      begin
        Memo2.Lines.Add(buffer);
        exit;
      end; }

    if (Pos('WCY de', buffer) = 1) or (Pos('WWV de', buffer) = 1) then
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
          '2190M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[0];
          '630M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[1];
          '160M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[2];
          '80M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[3];
          '60M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[4];
          '40M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[5];
          '30M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[6];
          '20M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[7];
          '17M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[8];
          '15M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[9];
          '12M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[10];
          '10M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[11];
          '6M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[12];
          '4M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[13];
          '2M': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[14];
          '70CM': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[15];
          '23CM': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[16];
          '13CM': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[17];
          '9CM': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[18];
          '6CM': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[19];
          '3CM': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[20];
          '1.25CM': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[21];
          '6MM': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[22];
          '4MM': ShowSpotBand := ClusterFilter.CLBFilterBands.Checked[23];
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
        XNode := VSTCluster.AddChild(nil);
        Data := VSTCluster.GetNodeData(Xnode);
        Data^.DX := dmFunc.GetBandFromFreq(FloatToStr(freqMhz));
        XNode := VSTCluster.AddChild(
          FindNode(dmFunc.GetBandFromFreq(FloatToStr(freqMhz)), False));
        Data := VSTCluster.GetNodeData(Xnode);
        Data^.Spots := DX;
        Data^.Call := Call;
        Data^.Freq := Freq;
        Data^.Moda := Mode;
        Data^.Comment := Comment;
        Data^.Time := Time;
        Data^.Loc := Loc;
        PFXR := MainFunc.SearchPrefix(DX, Loc);
        Data^.Country := PFXR.Country;
        VSTCluster.Expanded[XNode^.Parent] := ClusterFilter.CheckBox1.Checked;
        FindCountryFlag(Data^.Country);
      end
      else
      begin
        XNode := VSTCluster.InsertNode(
          FindNode(dmFunc.GetBandFromFreq(FloatToStr(freqMhz)), False), amAddChildFirst);
        Data := VSTCluster.GetNodeData(Xnode);
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
  FindAndDeleteSpot(ClusterFilter.SEDelSpot.Value);
  FindAndDeleteSpot(ClusterFilter.SEDelSpot.Value);
  CheckClusterRestartTimer;
end;

procedure TdxClusterForm.VSTClusterChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  VSTCluster.Refresh;
end;

procedure TdxClusterForm.VSTClusterClick(Sender: TObject);
var
  XNode: PVirtualNode;
  Data: PTreeData;
  PFXR: TPFXR;
  Lat, Lon: string;
begin
  XNode := VSTCluster.FocusedNode;
  Data := VSTCluster.GetNodeData(XNode);
  if VSTCluster.SelectedCount <> 0 then
  begin
    if Length(Data^.Spots) > 1 then
    begin
      PFXR := MainFunc.SearchPrefix(Data^.Spots, '');
      MiniForm.LBAzimuthD.Caption := PFXR.Azimuth;
      MiniForm.LBDistanceD.Caption := PFXR.Distance;
      MiniForm.LBLatitudeD.Caption := PFXR.Latitude;
      MiniForm.LBLongitudeD.Caption := PFXR.Longitude;
      MiniForm.LBTerritoryD.Caption := PFXR.Country;
      MiniForm.LBCont.Caption := PFXR.Continent;
      MiniForm.LBDXCCD.Caption := PFXR.ARRLPrefix;
      MiniForm.LBPrefixD.Caption := PFXR.Prefix;
      MiniForm.LBCQD.Caption := PFXR.CQZone;
      MiniForm.LBITUD.Caption := PFXR.ITUZone;
      TimeDIF := PFXR.TimeDiff;
      dmFunc.GetLatLon(PFXR.Latitude, PFXR.Longitude, Lat, Lon);
      Earth.PaintLine(Lat, Lon, LBRecord.OpLat, LBRecord.OpLon);
      Earth.PaintLine(Lat, Lon, LBRecord.OpLat, LBRecord.OpLon);
      //if PFXR.Found and MiniForm.CBMap.Checked then
      //  MainFunc.LoadMaps(Lat, Lon, MainForm.MapView1);
    end;
  end;
end;

procedure TdxClusterForm.SBConnectClick(Sender: TObject);
begin
  if TelnetThread = nil then
  begin
    TelnetThread := TTelnetThread.Create;
    if Assigned(TelnetThread.FatalException) then
      raise TelnetThread.FatalException;
    TelnetThread.Start;
    SBConnect.Enabled := False;
  end;
end;

procedure TdxClusterForm.SBClearClick(Sender: TObject);
begin
  if not VSTCluster.IsEmpty and (PageControl1.ActivePageIndex = 1) then
  begin
    VSTCluster.BeginUpdate;
    VSTCluster.Clear;
    VSTCluster.EndUpdate;
  end;
  if PageControl1.ActivePageIndex = 0 then
    Memo1.Clear;
end;

procedure TdxClusterForm.SBDisconnectClick(Sender: TObject);
begin
  if DXTelnetClient <> nil then
    DXTelnetClient.Disconnect(True);
  ConnectCluster := False;
  ButtonSet;
  if TelnetThread <> nil then
  begin
    TelnetThread.Terminate;
    TelnetThread := nil;
  end;
  Memo1.Lines.Add('DX Cluster disconnected');
  CheckClusterTimer.Enabled := False;
end;

procedure TdxClusterForm.SBSentDXClick(Sender: TObject);
begin
  SendTelnetSpot.Show;
end;

procedure TdxClusterForm.SBFilterClick(Sender: TObject);
begin
  ClusterFilter.Show;
end;

procedure TdxClusterForm.SBEditServersClick(Sender: TObject);
begin
  ConfigForm.Show;
  ConfigForm.PControl.ActivePageIndex:=4;
end;

procedure TdxClusterForm.SpeedButton7Click(Sender: TObject);
begin
  if Length(EditCallsign.Text) > 2 then
  begin
    DXTelnetClient.SendMessage('talk ' + EditCallsign.Text + ' ' +
      EditMessage.Text + #13#10, nil);
    EditMessage.Clear;
  end
  else
    Memo2.Text := rCallsignNotEntered;
end;

procedure TdxClusterForm.FreeClusterThread;
begin
  if TelnetThread <> nil then
    TelnetThread.Terminate;
end;

procedure TdxClusterForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Sender <> MainForm then
  begin
    INIFile.WriteString('TelnetCluster', 'ServerDef', CBServers.Text);
    MainFunc.SetDXColumns(VSTCluster, True, VSTCluster);
    if Application.MessageBox(PChar(rShowNextStart), PChar(rWarning),
      MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      INIFile.WriteBool('SetLog', 'cShow', True)
    else
      INIFile.WriteBool('SetLog', 'cShow', False);
    IniSet.cShow := False;
    FreeClusterThread;
    ConnectCluster := False;
    ButtonSet;
    MiniForm.CheckFormMenu('DXClusterForm', False);
    CloseAction := caHide;
  end
  else
  begin
    INIFile.WriteString('TelnetCluster', 'ServerDef', CBServers.Text);
    MainFunc.SetDXColumns(VSTCluster, True, VSTCluster);
    FreeClusterThread;
  end;
end;

procedure TdxClusterForm.FormCreate(Sender: TObject);
begin
  FlagList := TImageList.Create(Self);
  FlagSList := TStringList.Create;
  VSTCluster.Images := FlagList;
  qBands := TSQLQuery.Create(nil);
  qBands.DataBase := InitDB.ServiceDBConnection;
  MainFunc.LoadTelnetAddress;
  LoadClusterString;
  MainFunc.SetDXColumns(VSTCluster, False, VSTCluster);
  ButtonSet;
  if IniSet.ClusterAutoStart then
    SBConnect.Click;
end;

procedure TdxClusterForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FlagList);
  FreeAndNil(FlagSList);
  FreeAndNil(qBands);
end;

procedure TdxClusterForm.FormResize(Sender: TObject);
begin
  CBServers.Width := dxClusterForm.Width - 180;
  EditMessage.Width := dxClusterForm.Width - 120;
end;

procedure TdxClusterForm.FormShow(Sender: TObject);
begin
  if IniSet.MainForm = 'MULTI' then
    if (IniSet._l_c <> 0) and (IniSet._t_c <> 0) and (IniSet._w_c <> 0) and
      (IniSet._h_c <> 0) then
      dxClusterForm.SetBounds(IniSet._l_c, IniSet._t_c, IniSet._w_c, IniSet._h_c);
end;

procedure TdxClusterForm.MenuItem1Click(Sender: TObject);
var
  XNode: PVirtualNode;
  Data: PTreeData;
begin
  XNode := VSTCluster.FocusedNode;
  Data := VSTCluster.GetNodeData(XNode);
  if VSTCluster.SelectedCount <> 0 then
    if Length(Data^.Spots) > 1 then
      MiniForm.EditCallsign.Text := Data^.Spots;
end;

procedure TdxClusterForm.MenuItem2Click(Sender: TObject);
begin
  VSTCluster.DeleteSelectedNodes;
end;

procedure TdxClusterForm.MenuItem3Click(Sender: TObject);
begin
  if not VSTCluster.IsEmpty then
  begin
    VSTCluster.BeginUpdate;
    VSTCluster.Clear;
    VSTCluster.EndUpdate;
  end;
end;

procedure TdxClusterForm.EditCommandKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    if DXTelnetClient <> nil then
    begin
      DXTelnetClient.SendMessage(EditCommand.Text + #13#10, nil);
      EditCommand.Clear;
    end
    else
    begin
      ConnectCluster := False;
      ButtonSet;
      Memo1.Lines.Add('DX Cluster disconnected');
    end;
  end;
end;

procedure TdxClusterForm.EditMessageKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    if Length(EditCallsign.Text) > 2 then
    begin
      DXTelnetClient.SendMessage('talk ' + EditCallsign.Text + ' ' +
        EditMessage.Text + #13#10, nil);
      EditMessage.Clear;
    end
    else
      Memo2.Text := rCallsignNotEntered;
  end;
end;

procedure TdxClusterForm.CBServersChange(Sender: TObject);
var
  i, j: integer;
begin
  i := pos('>', CBServers.Text);
  j := pos(':', CBServers.Text);
  //Сервер
  IniSet.Cluster_Host := copy(CBServers.Text, i + 1, j - i - 1);
  Delete(IniSet.Cluster_Host, 1, 1);
  //Порт
  IniSet.Cluster_Port := copy(CBServers.Text, j + 1, Length(CBServers.Text) - i);
end;

procedure TdxClusterForm.CheckClusterTimerTimer(Sender: TObject);
begin
  SBDisconnect.Click;
  SBConnect.Click;
end;

procedure TdxClusterForm.VSTClusterCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: integer);
begin
  with TVirtualStringTree(Sender) do
    Result := AnsiCompareText(Text[Node1, Column], Text[Node2, Column]);
end;

procedure TdxClusterForm.VSTClusterDblClick(Sender: TObject);
var
  XNode: PVirtualNode;
  Data: PTreeData;
begin
  XNode := VSTCluster.FocusedNode;
  Data := VSTCluster.GetNodeData(XNode);
  if VSTCluster.SelectedCount <> 0 then
  begin
    if Length(Data^.Spots) > 1 then
    begin
      MiniForm.EditCallsign.Text := Data^.Spots;
      if Length(Data^.Spots) >= 3 then
        InfoDM.GetInformation(dmFunc.ExtractCallsign(Data^.Spots), 'MainForm');

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
          MiniForm.CBBand.Text :=
            dmFunc.GetBandFromFreq(FormatFloat(view_freq,
            StrToFloat(Data^.Freq) / 1000))
        else
          MiniForm.CBBand.Text :=
            FormatFloat(view_freq, StrToFloat(Data^.Freq) / 1000);

        if (Data^.Moda = 'LSB') or (Data^.Moda = 'USB') then
        begin
          MiniForm.CBMode.Text := 'SSB';
          MiniForm.CBModeCloseUp(Sender);
          MiniForm.CBSubMode.Text := Data^.Moda;
        end;
        if Data^.Moda = 'DIGI' then
        begin
          MiniForm.CBMode.Text := 'SSB';
          MiniForm.CBModeCloseUp(Sender);
          MiniForm.CBSubMode.Text := 'USB';
        end;
        if Data^.Moda = 'CW' then
        begin
          MiniForm.CBMode.Text := 'CW';
          MiniForm.CBModeCloseUp(Sender);
          MiniForm.CBSubMode.Text := '';
        end;
      end;
    end;
  end;

end;

procedure TdxClusterForm.VSTClusterFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  VSTCluster.Refresh;
end;

procedure TdxClusterForm.VSTClusterFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PTreeData;
begin
  Data := VSTCluster.GetNodeData(Node);
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

procedure TdxClusterForm.VSTClusterGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: boolean; var ImageIndex: integer);
var
  Data: PTreeData;
begin
  if Column <> 8 then
    Exit;

  ImageIndex := -1;
  Data := VSTCluster.GetNodeData(Node);
  if Assigned(Data) then
  begin
    ImageIndex := FlagSList.IndexOf(dmFunc.ReplaceCountry(Data^.Country));
  end;
end;

procedure TdxClusterForm.VSTClusterGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: integer);
begin
  NodeDataSize := SizeOf(TTreeData);
end;

procedure TdxClusterForm.VSTClusterGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PTreeData;
begin
  Data := VSTCluster.GetNodeData(Node);
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

procedure TdxClusterForm.VSTClusterHeaderClick(Sender: TVTHeader;
  HitInfo: TVTHeaderHitInfo);
begin
  if HitInfo.Button = mbLeft then
  begin
    VSTCluster.Header.SortColumn := HitInfo.Column;
    if VSTCluster.Header.SortDirection = sdAscending then
      VSTCluster.Header.SortDirection := sdDescending
    else
      VSTCluster.Header.SortDirection := sdAscending;
    VSTCluster.SortTree(HitInfo.Column, VSTCluster.Header.SortDirection);
  end;
end;

procedure TdxClusterForm.VSTClusterNodeClick(Sender: TBaseVirtualTree;
  const HitInfo: THitInfo);
var
  XNode: PVirtualNode;
begin
  XNode := VSTCluster.FocusedNode;
  VSTCluster.Selected[XNode] := True;
end;


end.
