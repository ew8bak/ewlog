(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit miniform_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  EditBtn, Buttons, ComCtrls, DateTimePicker, LazSysUtils, foundQSO_record,
  prefix_record, LCLType, Menus, inform_record, ResourceStr, qso_record,
  const_u, LCLProc, LCLTranslator, FileUtil, Zipper, fphttpclient, LCLIntf,
  ActnList, gettext, digi_record, ImportADIThread, CloudLogCAT, dmHamLib_u
  {$IFDEF WINDOWS}
    ,uDarkStyleParams, uWin32WidgetSetDark, uDarkStyleSchemes, uMetaDarkStyle;
  {$ELSE} ;
  {$ENDIF}

type

  { TMiniForm }

  TMiniForm = class(TForm)
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MISatellite: TMenuItem;
    MIRadio: TMenuItem;
    SentSpot: TAction;
    MacroKeyF2: TAction;
    MacroKeyF3: TAction;
    MacroKeyF4: TAction;
    MacroKeyF5: TAction;
    MacroKeyF6: TAction;
    MacroKeyF7: TAction;
    MacroKeyF8: TAction;
    MacroKeyF9: TAction;
    MacroKeyF10: TAction;
    MacroKeyF1: TAction;
    ExportADI: TAction;
    ImportADI: TAction;
    GetReference: TAction;
    ActionList: TActionList;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel6: TBevel;
    Bevel7: TBevel;
    Bevel8: TBevel;
    Bevel9: TBevel;
    CBBand: TComboBox;
    CBMode: TComboBox;
    CBSubMode: TComboBox;
    CBRealTime: TCheckBox;
    CBSaveUTC: TCheckBox;
    CBRSTs: TComboBox;
    CBRSTr: TComboBox;
    CBQSLVia: TComboBox;
    CBMark: TCheckBox;
    CBMap: TCheckBox;
    CBFilter: TCheckBox;
    CBYourQSL: TComboBox;
    CBCurrentLog: TComboBox;
    ClearEdit: TAction;
    DateEdit1: TDateEdit;
    DateTimePicker1: TDateTimePicker;
    EditMyGrid: TEdit;
    EditMyState: TEdit;
    EditComment: TEdit;
    EditGrid: TEdit;
    EditState: TEdit;
    EditIOTA: TEdit;
    EditMGR: TEdit;
    EditQTH: TEdit;
    EditName: TEdit;
    EditCallsign: TEditButton;
    ImDXCCcountry: TImage;
    ImDXCCBand: TImage;
    ImDXCCMode: TImage;
    Label10: TLabel;
    LBCurrentLog: TLabel;
    LBMyGrid: TLabel;
    LBMyState: TLabel;
    LBCount: TLabel;
    LBDateQSO: TLabel;
    LBTimeQSO: TLabel;
    LBBandQSO: TLabel;
    LBModeQSO: TLabel;
    LBNameQSO: TLabel;
    LBAzimuth: TLabel;
    LBTerritory: TLabel;
    LBDXCC: TLabel;
    LBAzimuthD: TLabel;
    LBTerritoryD: TLabel;
    LBDXCCD: TLabel;
    LBDistance: TLabel;
    LBPrefix: TLabel;
    LBDistanceD: TLabel;
    LBPrefixD: TLabel;
    LBLatitude: TLabel;
    LBLatitudeD: TLabel;
    LBLongitude: TLabel;
    LBLongitudeD: TLabel;
    LBCont: TLabel;
    LBCQ: TLabel;
    LBCQD: TLabel;
    LBITU: TLabel;
    LBITUD: TLabel;
    LBYourQSL: TLabel;
    LBCfm: TLabel;
    LBComment: TLabel;
    LBGrid: TLabel;
    LBState: TLabel;
    LBIOTA: TLabel;
    LBMGR: TLabel;
    LBRSTs: TLabel;
    LBRSTr: TLabel;
    LBQTH: TLabel;
    LBName: TLabel;
    LBWorked: TLabel;
    LBQSL: TLabel;
    LBCallsign: TLabel;
    LBTime: TLabel;
    LBDate: TLabel;
    LBBand: TLabel;
    LBMode: TLabel;
    MainMenu: TMainMenu;
    MICWType: TMenuItem;
    MiCWKeys: TMenuItem;
    MIContestLogging: TMenuItem;
    N8: TMenuItem;
    MiPhotoSeparateTop: TMenuItem;
    MiPhotoSeparate: TMenuItem;
    N7: TMenuItem;
    MiMainTop: TMenuItem;
    MiPhotoTop: TMenuItem;
    N6: TMenuItem;
    N5: TMenuItem;
    MiLogGridTop: TMenuItem;
    MIClusterTop: TMenuItem;
    miMapTop: TMenuItem;
    N4: TMenuItem;
    N3: TMenuItem;
    N2: TMenuItem;
    MIPhoto: TMenuItem;
    MIMMode: TMenuItem;
    MIMapForm: TMenuItem;
    MITelnetForm: TMenuItem;
    MiLogbookForm: TMenuItem;
    MILogbook: TMenuItem;
    MenuItem102: TMenuItem;
    MenuItem110: TMenuItem;
    MenuItem111: TMenuItem;
    MenuItem112: TMenuItem;
    MILanguage: TMenuItem;
    MenuItem118: TMenuItem;
    MIDownloadLang: TMenuItem;
    MenuItem123: TMenuItem;
    MenuItem124: TMenuItem;
    MISettings: TMenuItem;
    MenuItem3: TMenuItem;
    MIExtProg: TMenuItem;
    MenuItem43: TMenuItem;
    MenuItem52: TMenuItem;
    MenuItem53: TMenuItem;
    MenuItem54: TMenuItem;
    MenuItem55: TMenuItem;
    MenuItem56: TMenuItem;
    MenuItem57: TMenuItem;
    MenuItem58: TMenuItem;
    MenuItem59: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem60: TMenuItem;
    MenuItem61: TMenuItem;
    MenuItem62: TMenuItem;
    MenuItem63: TMenuItem;
    MenuItem64: TMenuItem;
    MenuItem65: TMenuItem;
    MenuItem66: TMenuItem;
    MenuItem67: TMenuItem;
    MenuItem68: TMenuItem;
    MenuItem69: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem70: TMenuItem;
    MenuItem71: TMenuItem;
    MenuItem72: TMenuItem;
    MenuItem73: TMenuItem;
    MenuItem74: TMenuItem;
    MenuItem85: TMenuItem;
    MenuItem87: TMenuItem;
    MenuItem90: TMenuItem;
    MenuItem91: TMenuItem;
    MenuItem92: TMenuItem;
    MenuItem93: TMenuItem;
    MenuItem94: TMenuItem;
    N1: TMenuItem;
    SaveQSOinBase: TAction;
    SBSave: TSpeedButton;
    SBNew: TSpeedButton;
    SBState: TSpeedButton;
    SBIOTA: TSpeedButton;
    SBMGR: TSpeedButton;
    SBCopy: TSpeedButton;
    SBInfo: TSpeedButton;
    Shape1: TShape;
    SBHideComment: TSpeedButton;
    StatBar: TStatusBar;
    CheckUpdateTimer: TTimer;
    TMTime: TTimer;
    LBLocalTimeD: TLabel;
    LBUTCTimeD: TLabel;
    RemoteTimeLabel: TLabel;
    LBRemoteTimeD: TLabel;
    UTCLabel: TLabel;
    LocalTimeLabel: TLabel;
    Panel1: TPanel;
    procedure EditGridChange(Sender: TObject);
    procedure MacroKeyF10Execute(Sender: TObject);
    procedure MacroKeyF1Execute(Sender: TObject);
    procedure CBBandChange(Sender: TObject);
    procedure CBBandCloseUp(Sender: TObject);
    procedure CBCurrentLogChange(Sender: TObject);
    procedure CBFilterChange(Sender: TObject);
    procedure CBMapChange(Sender: TObject);
    procedure CBModeChange(Sender: TObject);
    procedure CBModeCloseUp(Sender: TObject);
    procedure CBRealTimeChange(Sender: TObject);
    procedure CBSaveUTCChange(Sender: TObject);
    procedure CheckUpdateTimerStartTimer(Sender: TObject);
    procedure CheckUpdateTimerTimer(Sender: TObject);
    procedure ClearEditExecute(Sender: TObject);
    procedure EditCallsignButtonClick(Sender: TObject);
    procedure EditCallsignChange(Sender: TObject);
    procedure EditCallsignKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditCallsignKeyPress(Sender: TObject; var Key: char);
    procedure EditCallsignMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ExportADIExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure GetReferenceExecute(Sender: TObject);
    procedure ImportADIExecute(Sender: TObject);
    procedure MacroKeyF2Execute(Sender: TObject);
    procedure MacroKeyF3Execute(Sender: TObject);
    procedure MacroKeyF4Execute(Sender: TObject);
    procedure MacroKeyF5Execute(Sender: TObject);
    procedure MacroKeyF6Execute(Sender: TObject);
    procedure MacroKeyF7Execute(Sender: TObject);
    procedure MacroKeyF8Execute(Sender: TObject);
    procedure MacroKeyF9Execute(Sender: TObject);
    procedure MenuItem102Click(Sender: TObject);
    procedure MenuItem111Click(Sender: TObject);
    procedure MenuItem112Click(Sender: TObject);
    procedure MenuItem118Click(Sender: TObject);
    procedure MenuItem123Click(Sender: TObject);
    procedure MenuItem124Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem43Click(Sender: TObject);
    procedure MenuItem58Click(Sender: TObject);
    procedure MenuItem74Click(Sender: TObject);
    procedure MenuItem85Click(Sender: TObject);
    procedure MIContestLoggingClick(Sender: TObject);
    procedure MiCWKeysClick(Sender: TObject);
    procedure MICWTypeClick(Sender: TObject);
    procedure MIExtProgClick(Sender: TObject);
    procedure miMapTopClick(Sender: TObject);
    procedure MiMainTopClick(Sender: TObject);
    procedure MiLogGridTopClick(Sender: TObject);
    procedure MIClusterTopClick(Sender: TObject);
    procedure MiLogbookFormClick(Sender: TObject);
    procedure MIMapFormClick(Sender: TObject);
    procedure MIMModeClick(Sender: TObject);
    procedure MenuItem48Click(Sender: TObject);
    procedure MenuItem52Click(Sender: TObject);
    procedure MenuItem53Click(Sender: TObject);
    procedure MenuItem55Click(Sender: TObject);
    procedure MenuItem56Click(Sender: TObject);
    procedure MenuItem63Click(Sender: TObject);
    procedure MenuItem65Click(Sender: TObject);
    procedure MenuItem66Click(Sender: TObject);
    procedure MenuItem69Click(Sender: TObject);
    procedure MenuItem70Click(Sender: TObject);
    procedure MenuItem73Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem87Click(Sender: TObject);
    procedure MenuItem91Click(Sender: TObject);
    procedure MenuItem92Click(Sender: TObject);
    procedure MenuItem94Click(Sender: TObject);
    procedure MIDownloadLangClick(Sender: TObject);
    procedure MILanguageClick(Sender: TObject);
    procedure MIPhotoClick(Sender: TObject);
    procedure MiPhotoSeparateClick(Sender: TObject);
    procedure MiPhotoSeparateTopClick(Sender: TObject);
    procedure MiPhotoTopClick(Sender: TObject);
    procedure MIRadioClick(Sender: TObject);
    procedure MISatelliteClick(Sender: TObject);
    procedure MITelnetFormClick(Sender: TObject);
    procedure SaveQSOinBaseExecute(Sender: TObject);
    procedure SBInfoClick(Sender: TObject);
    procedure SBIOTAClick(Sender: TObject);
    procedure SBMGRClick(Sender: TObject);
    procedure SBNewClick(Sender: TObject);
    procedure SBSaveClick(Sender: TObject);
    procedure SBStateClick(Sender: TObject);
    procedure SentSpotExecute(Sender: TObject);
    procedure Shape1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure SBHideCommentClick(Sender: TObject);
    procedure StatBarClick(Sender: TObject);
    procedure StatBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure TMTimeTimer(Sender: TObject);
  private
    SelEditNumChar: integer;
    showForm: boolean;
    CatCloudData: TCatData;
    procedure Clr;
    procedure LangItemClick(Sender: TObject);
    procedure RadioItemClick(Sender: TObject);
    procedure ProgramItemClick(Sender: TObject);
    procedure FindLanguageFiles(Dir: string; var LangList: TStringList);
    procedure DisableMenuMiniMode;
    procedure SentCloudLogCat;
    procedure HideCommentStat;
    procedure ShowCommentStat;
    procedure CloseForm;
    procedure FreeMenuItem;
    procedure FreeMenuItem(TagNum: integer); overload;

  public
    procedure LoadPhotoFromInternetCallbook(info: TInformRecord);
    procedure LoadFromInternetCallBook(info: TInformRecord);
    procedure LoadComboBoxItem;
    procedure SwitchForm;
    procedure TextSB(Value: string; PanelNum: integer);
    procedure ShowInfoFromRIG;
    procedure ShowDataFromDIGI(DataDigi: TDigiR);
    procedure FromImportThread(Info: TInfo);
    procedure FromMobileSyncThread(InfoStr: string);
    procedure CheckFormMenu(NameForm: string; StateForm: boolean);
    procedure SetHotKey;

  end;

var
  MiniForm: TMiniForm;
  TimeDIF: integer;
  FreqChange: boolean;
  UnUsIndex: integer;
  GridRecordIndex: integer;
  CloseApp: boolean;

implementation

uses MainFuncDM, InitDB_dm, dmFunc_U, infoDM_U, Earth_Form_U, hiddentsettings_u,
  GridsForm_u, dxclusterform_u, AboutForm_U, ConfigForm_U,
  InformationForm_U, UpdateForm_U, famm_u, mmform_u, synDBDate_u,
  ExportAdifForm_u, ImportADIFForm_U, CreateJournalForm_U,
  ThanksForm_u, LogConfigForm_U, SettingsProgramForm_U, IOTA_Form_U,
  QSLManagerForm_U, STATE_Form_U, TRXForm_U, MainForm_U, MapForm_u, viewPhoto_U,
  serverDM_u, contestForm_u, CWKeysForm_u, CWTypeForm_u,
  sendtelnetspot_form_U, WSJT_UDP_Form_U, satForm_u, ServiceEqslForm_u,
  ServiceLoTWForm_u, databasesettingsform_u;

{$R *.lfm}

{ TMiniForm }

procedure TMiniForm.FreeMenuItem;
var
  i: integer;
begin
  for i := MiniForm.ComponentCount - 1 downto 0 do
    if (MiniForm.Components[i] is TMenuItem) then
      if (MiniForm.Components[i] as TMenuItem).Tag = 75 then
        (MiniForm.Components[i] as TMenuItem).Free;
  for i := MiniForm.ComponentCount - 1 downto 0 do
    if (MiniForm.Components[i] is TMenuItem) then
      if (MiniForm.Components[i] as TMenuItem).Tag = 99 then
        (MiniForm.Components[i] as TMenuItem).Free;
  for i := MiniForm.ComponentCount - 1 downto 0 do
    if (MiniForm.Components[i] is TMenuItem) then
      if (MiniForm.Components[i] as TMenuItem).Tag = 76 then
        (MiniForm.Components[i] as TMenuItem).Free;
end;

procedure TMiniForm.FreeMenuItem(TagNum: integer);
var
  i: integer;
begin
  for i := MiniForm.ComponentCount - 1 downto 0 do
    if (MiniForm.Components[i] is TMenuItem) then
      if (MiniForm.Components[i] as TMenuItem).Tag = TagNum then
        (MiniForm.Components[i] as TMenuItem).Free;
end;

procedure TMiniForm.CheckFormMenu(NameForm: string; StateForm: boolean);
begin
  if NameForm = 'GridsForm' then
  begin
    MiLogbookForm.Checked := StateForm;
    Exit;
  end;
  if NameForm = 'DXClusterForm' then
  begin
    MITelnetForm.Checked := StateForm;
    Exit;
  end;
  if NameForm = 'viewPhoto' then
  begin
    MIPhoto.Checked := StateForm;
    Exit;
  end;
  if NameForm = 'MapForm' then
  begin
    MIMapForm.Checked := StateForm;
    Exit;
  end;
  if NameForm = 'EarthForm' then
  begin
    MIMapForm.Checked := StateForm;
    Exit;
  end;
end;

procedure TMiniForm.SentCloudLogCat;
begin
  if IniSet.FreqToCloudLog then
  begin
    CatCloudData.mode := CBMode.Text;
    CatCloudData.freq := CBBand.Text;
    CatCloudData.dt := FormatDateTime('yyyy/mm/dd hh:mm', Now);
    CatCloudData.address := IniSet.CloudLogServer;
    CatCloudData.key := IniSet.CloudLogApiKey;
    CatCloudData.radio := 'EWLog';
    if CatCloudData.address <> '' then
      MainFunc.SentCATCloudLog(CatCloudData);
  end;
end;

procedure TMiniForm.FromImportThread(Info: TInfo);
begin
  TextSB(rImported + ':' + IntToStr(Info.RecCount) + rOf + IntToStr(Info.AllRec) +
    ' ' + rImportErrors + ':' + IntToStr(info.ErrorCount), 0);
  if Info.Result then
  begin
    TextSB(rImport + ':' + rDone, 1);
    InitDB.SelectLogbookTable(LBRecord.LogTable);
  end
  else
    TextSB(rImport + ':' + rProcessing, 1);
end;

procedure TMiniForm.FromMobileSyncThread(InfoStr: string);
begin
  TextSB(InfoStr, 0);
end;

procedure TMiniForm.ShowDataFromDIGI(DataDigi: TDigiR);
var
  tempCall: string;
  tempMode: string;
  tempSubMode: string;
  updateTimer: Boolean;
begin
  tempCall := DataDigi.DXCall;
  tempMode := DataDigi.Mode;
  tempSubMode := DataDigi.SubMode;
  if tempCall <> EditCallsign.Text then
  begin
    EditCallsign.Text := tempCall;
    if Length(tempCall) > 2 then
      InfoDM.GetInformation(dmFunc.ExtractCallsign(tempCall), 'MainForm');
  end;

  if DataDigi.Freq <> 0 then
  begin
    if IniSet.showBand then
      CBBand.Text := dmFunc.GetBandFromFreq(
        StringReplace(FormatFloat(view_freq[IniSet.ViewFreq], DataDigi.Freq / 1000000),
        ',', '.', [rfReplaceAll]))
    else
      CBBand.Text := StringReplace(FormatFloat(view_freq[IniSet.ViewFreq],
        DataDigi.Freq / 1000000), ',', '.', [rfReplaceAll]);
  end;

  if tempMode <> CBMode.Text then
    CBMode.Text := tempMode;
  if tempSubMode <> CBSubMode.Text then
    CBSubMode.Text := tempSubMode;
  CBRSTr.Text := DataDigi.RSTr;
  CBRSTs.Text := DataDigi.RSTs;
  if DataDigi.DXGrid <> '' then
    EditGrid.Text := DataDigi.DXGrid;
  if DataDigi.OmName <> '' then
    EditName.Text := DataDigi.OmName;
  if DataDigi.QTH <> '' then
    EditQTH.Text := DataDigi.QTH;
  if DataDigi.State <> '' then
    EditState.Text := DataDigi.State;

  if DataDigi.Save then
  begin
    if DataDigi.date > 0 then
    begin
      if TMTime.Enabled = true then
      begin
        TMTime.Enabled := false;
        updateTimer := true;
      end;
      DateTimePicker1.Time := DataDigi.date;
    end;
    SBSave.Click;

    if updateTimer then
       TMTime.Enabled := true;
  end;
end;

procedure TMiniForm.ShowInfoFromRIG;
begin
  if not WSJT_Run then
  begin
    if FMS.Mode <> '' then
    begin
      CBMode.Text := FMS.Mode;
      CBSubMode.Text := FMS.SubMode;
    end;

    if FMS.Freq <> 0 then
    begin
      if IniSet.showBand then
        CBBand.Text := dmFunc.GetBandFromFreq(
          StringReplace(FormatFloat(view_freq[IniSet.ViewFreq], FMS.Freq / 1000000),
          ',', '.', [rfReplaceAll]))
      else
        CBBand.Text := StringReplace(FormatFloat(view_freq[IniSet.ViewFreq],
          FMS.Freq / 1000000), ',', '.', [rfReplaceAll]);
    end;
  end;
end;

procedure TMiniForm.TextSB(Value: string; PanelNum: integer);
begin
  if PanelNum = 0 then
    StatBar.Panels.Items[0].Text := Value;
  if PanelNum = 1 then
    StatBar.Panels.Items[1].Text := Value + '     ';
end;

procedure TMiniForm.SwitchForm;
begin
  if IniSet.MainForm <> 'MULTI' then
  begin
    MiniForm.Menu := nil;
    MainForm.Menu := MiniForm.MainMenu;
    MenuItem110.Enabled := True;
    MiniForm.BorderStyle := bsNone;
    MiniForm.Parent := MainForm.MiniPanel;
    ShowCommentStat;
    MiniForm.Align := alClient;
    StatBar.Parent := MainForm;
    GridsForm.BorderStyle := bsNone;
    GridsForm.Parent := MainForm.GridsPanel;
    GridsForm.Align := alClient;
    if not IniSet.Map_Use then
    begin
      Earth.BorderStyle := bsNone;
      Earth.Parent := MainForm.EarthPanel;
      Earth.Align := alClient;
    end
    else
    begin
      MapForm.BorderStyle := bsNone;
      MapForm.Parent := MainForm.EarthPanel;
      MapForm.Align := alClient;
    end;
    dxClusterForm.BorderStyle := bsNone;
    dxClusterForm.Parent := MainForm.ClusterPanel;
    dxClusterForm.Align := alClient;
    GridsForm.Show;
    dxClusterForm.Show;
    if IniSet.trxShow then
      TRXForm.Show;
    if not IniSet.Map_Use then
      Earth.Show
    else
      MapForm.Show;

    if IniSet.pShow then
    begin
      if not IniSet.pSeparate then
      begin
        viewPhoto.BorderStyle := bsNone;
        viewPhoto.Parent := MainForm.OtherPanel;
        viewPhoto.Align := alClient;
        viewPhoto.Show;
      end
      else
      begin
        viewPhoto.BorderStyle := bsSizeable;
        viewPhoto.Parent := nil;
        viewPhoto.Align := alNone;
        viewPhoto.Show;
      end;
    end;
    SBHideComment.Visible := False;
    IniSet.MainForm := 'MAIN';
    MainForm.Show;
    DisableMenuMiniMode;
  end
  else
  begin
    MainForm.Menu := nil;
    MiniForm.Menu := MiniForm.MainMenu;
    MenuItem110.Enabled := False;
    MiniForm.Parent := nil;
    MiniForm.BorderStyle := bsSizeable;
    MiniForm.Align := alNone;
    SBHideComment.Visible := True;
    if not IniSet.VisibleComment then
      SBHideComment.Click;
    StatBar.Parent := MiniForm;
    MainForm.Hide;
    GridsForm.Parent := nil;
    GridsForm.BorderStyle := bsSizeable;
    GridsForm.Align := alNone;
    if not IniSet.Map_Use then
    begin
      Earth.Parent := nil;
      Earth.BorderStyle := bsSizeable;
      Earth.Align := alNone;
      if IniSet.eTop then
        Earth.FormStyle := fsSystemStayOnTop;
    end
    else
    begin
      MapForm.Parent := nil;
      MapForm.BorderStyle := bsSizeable;
      MapForm.Align := alNone;
      if IniSet.eTop then
        MapForm.FormStyle := fsSystemStayOnTop;
    end;
    dxClusterForm.Parent := nil;
    dxClusterForm.BorderStyle := bsSizeable;
    dxClusterForm.Align := alNone;
    GridsForm.hide;
    dxClusterForm.hide;
    viewPhoto.Hide;
    if IniSet.gShow then
      GridsForm.Show;
    if IniSet.eShow then
      if not IniSet.Map_Use then
        Earth.Show
      else
        MapForm.Show;

    if IniSet.pShow then
    begin
      viewPhoto.Parent := nil;
      viewPhoto.BorderStyle := bsSizeable;
      viewPhoto.Align := alNone;
      viewPhoto.Show;
    end;
    if IniSet.trxShow then
    begin
      TRXForm.Parent := nil;
      TRXForm.BorderStyle := bsSingle;
      TRXForm.Align := alNone;
      TRXForm.Show;
    end;
    if IniSet.cShow then
      dxClusterForm.Show;
    if IniSet.mTop then
      MiniForm.FormStyle := fsSystemStayOnTop;
    if IniSet.gTop then
      GridsForm.FormStyle := fsSystemStayOnTop;
    if IniSet.cTop then
      dxClusterForm.FormStyle := fsSystemStayOnTop;
    if IniSet.pTop then
      viewPhoto.FormStyle := fsSystemStayOnTop;
    if IniSet.trxTop then
      TRXForm.FormStyle := fsSystemStayOnTop;
    IniSet.MainForm := 'MULTI';
  end;
end;

procedure TMiniForm.FindLanguageFiles(Dir: string; var LangList: TStringList);
begin
  LangList := FindAllFiles(Dir, 'ewlog.*.po', False, faNormal);
  LangList.Text := StringReplace(LangList.Text, Dir + DirectorySeparator +
    'ewlog.', '', [rfreplaceall]);
  LangList.Text := StringReplace(LangList.Text, '.po', '', [rfreplaceall]);
end;

procedure TMiniForm.LangItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
begin
  MenuItem := (Sender as TMenuItem);
  SetDefaultLang(MainFunc.FindISOCountry(MenuItem.Caption), FilePATH + 'locale');
  IniSet.Language := MainFunc.FindISOCountry(MenuItem.Caption);
  if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
    ShowMessage(rDBError);
  CBYourQSL.ItemIndex := 3;
end;

procedure TMiniForm.Clr;
begin
  EditCallsign.Clear;
  EditCallsign.Color := clDefault;
  EditName.Clear;
  EditQTH.Clear;
  EditGrid.Clear;
  EditState.Clear;
  EditIOTA.Clear;
  EditMGR.Clear;
  EditComment.Clear;
  CBRSTs.ItemIndex := 0;
  CBRSTr.ItemIndex := 0;
  ImDXCCcountry.Visible := False;
  ImDXCCBand.Visible := False;
  ImDXCCMode.Visible := False;
  Shape1.Visible := False;
  LBQSL.Visible := False;
  LBWorked.Visible := False;
  LBCfm.Visible := False;
  MapForm.WriteMap('0', '0', 1);
  CBQSLVia.Text := '';
  if IniSet.pShow then
    viewPhoto.ImPhoto.Picture.LoadFromLazarusResource('no-photo');
end;

procedure TMiniForm.LoadComboBoxItem;
begin
  MainFunc.LoadBMSL(CBMode, CBSubMode, CBBand, CBCurrentLog);
  CBCurrentLogChange(nil);
  CBModeCloseUp(nil);
end;

procedure TMiniForm.LoadFromInternetCallBook(info: TInformRecord);
begin
  if Length(info.Name) > 0 then
  begin
    EditName.Text := info.Name;
    EditQTH.Text := info.City;
    EditGrid.Text := info.Grid;
    EditState.Text := info.State;
  end;
  if Length(info.Error) > 0 then
    TextSB(info.Error, 0)
  else
    TextSB('', 0);
end;

procedure TMiniForm.LoadPhotoFromInternetCallbook(info: TInformRecord);
begin
  if IniSet.pShow then
  begin
    if dmFunc.Extention(info.PhotoURL) = '.gif' then
      viewPhoto.ImPhoto.Picture.Assign(info.PhotoGIF);
    if dmFunc.Extention(info.PhotoURL) = '.jpg' then
      viewPhoto.ImPhoto.Picture.Assign(info.PhotoJPEG);
    if dmFunc.Extention(info.PhotoURL) = '.png' then
      viewPhoto.ImPhoto.Picture.Assign(info.PhotoPNG);
  end;
end;

procedure TMiniForm.FormShow(Sender: TObject);
begin
  if not showForm then
  begin
    showForm := True;
    MainFunc.LoadWindowPosition(MiniForm);

    if DBRecord.InitDB <> 'YES' then
    begin
      if Application.MessageBox(PChar(rDBNotinit), PChar(rWarning),
        MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
        DataBaseSettingsForm.Show;
    end;

    SwitchForm;
    CBMap.Checked := IniSet.Map_Use;
    CheckUpdateTimer.Enabled := True;
    if IniSet.FLDIGI_USE then
      ServerDM.IdFldigiTCP.Active := True;
  end;

  CBYourQSL.ItemIndex := 3;
  TextSB('QSO № ' + IntToStr(NumberSelectRecord) + rQSOTotal +
    IntToStr(CountAllRecords), 1);
end;

procedure TMiniForm.GetReferenceExecute(Sender: TObject);
begin
  // if (Key = VK_RETURN) then
  InfoDM.GetInformation(dmFunc.ExtractCallsign(EditCallsign.Text), 'MainForm');
end;

procedure TMiniForm.ImportADIExecute(Sender: TObject);
begin
  ImportADIFForm.Show;
end;

procedure TMiniForm.MacroKeyF2Execute(Sender: TObject);
begin
  if CWKeysForm.Showing then
    CWKeysForm.BtF2.Click;
end;

procedure TMiniForm.MacroKeyF3Execute(Sender: TObject);
begin
  if CWKeysForm.Showing then
    CWKeysForm.BtF3.Click;
end;

procedure TMiniForm.MacroKeyF4Execute(Sender: TObject);
begin
  if CWKeysForm.Showing then
    CWKeysForm.BtF4.Click;
end;

procedure TMiniForm.MacroKeyF5Execute(Sender: TObject);
begin
  if CWKeysForm.Showing then
    CWKeysForm.BtF5.Click;
end;

procedure TMiniForm.MacroKeyF6Execute(Sender: TObject);
begin
  if CWKeysForm.Showing then
    CWKeysForm.BtF6.Click;
end;

procedure TMiniForm.MacroKeyF7Execute(Sender: TObject);
begin
  if CWKeysForm.Showing then
    CWKeysForm.BtF7.Click;
end;

procedure TMiniForm.MacroKeyF8Execute(Sender: TObject);
begin
  if CWKeysForm.Showing then
    CWKeysForm.BtF8.Click;
end;

procedure TMiniForm.MacroKeyF9Execute(Sender: TObject);
begin
  if CWKeysForm.Showing then
    CWKeysForm.BtF9.Click;
end;

procedure TMiniForm.MenuItem102Click(Sender: TObject);
begin
  openURL('https://www.patreon.com/ewlog');
end;

procedure TMiniForm.MenuItem111Click(Sender: TObject);
begin
  MenuItem112.Checked := False;
  if MenuItem111.Checked and not IniSet.pSeparate then
  begin
    viewPhoto.BorderStyle := bsNone;
    viewPhoto.Parent := MainForm.OtherPanel;
    viewPhoto.Align := alClient;
    viewPhoto.Show;
    IniSet.pShow := True;
    MiPhotoSeparate.Checked := IniSet.pSeparate;
    MiPhotoSeparateTop.Checked := IniSet.pTop;
    INIFile.WriteBool('SetLog', 'pShow', True);
  end;

  if MenuItem111.Checked and IniSet.pSeparate then
  begin
    viewPhoto.BorderStyle := bsSizeable;
    viewPhoto.Parent := nil;
    viewPhoto.Align := alNone;
    if IniSet.pTop then
      viewPhoto.FormStyle := fsSystemStayOnTop;
    viewPhoto.Show;
    IniSet.pShow := True;
    MiPhotoSeparate.Checked := IniSet.pSeparate;
    MiPhotoSeparateTop.Checked := IniSet.pTop;
    INIFile.WriteBool('SetLog', 'pShow', True);
  end;
  if not MenuItem111.Checked then
  begin
    viewPhoto.Hide;
    IniSet.pShow := False;
  end;
end;

procedure TMiniForm.MenuItem112Click(Sender: TObject);
begin
  if MenuItem111.Checked then
  begin
    viewPhoto.hide;
    IniSet.pShow := False;
    INIFile.WriteBool('SetLog', 'pShow', False);
    INIFile.WriteBool('SetLog', 'pTop', False);
    INIFile.WriteBool('SetLog', 'pSeparate', False);
    MiPhotoSeparate.Checked := False;
    MiPhotoSeparateTop.Checked := False;
    IniSet.pSeparate := False;
    IniSet.pTop := False;
  end;
  MenuItem111.Checked := False;
  MenuItem112.Checked := True;
end;

procedure TMiniForm.MenuItem118Click(Sender: TObject);
begin
  if Application.MessageBox(PChar(rDeleteLog), PChar(rWarning),
    MB_YESNO + MB_DEFBUTTON2 + MB_ICONWARNING) = idYes then
    MainFunc.TruncateTable(LBRecord.LogTable);
end;

procedure TMiniForm.MenuItem123Click(Sender: TObject);
begin
  FM_Form.Show;
end;

procedure TMiniForm.MenuItem124Click(Sender: TObject);
begin
  MM_Form.Show;
end;

procedure TMiniForm.MenuItem1Click(Sender: TObject);
begin
  ServiceEqslForm.Show;
end;

procedure TMiniForm.MenuItem2Click(Sender: TObject);
begin
  ServiceLoTWForm.Show;
end;

procedure TMiniForm.MenuItem43Click(Sender: TObject);
begin
  dmFunc.RunProgram(IniSet.WSJT_PATH, '');
end;

procedure TMiniForm.MenuItem58Click(Sender: TObject);
begin
  MainFunc.VacuumDB;
end;

procedure TMiniForm.MenuItem74Click(Sender: TObject);
begin
  dmFunc.RunProgram(IniSet.Fl_PATH, '');
end;

procedure TMiniForm.MenuItem85Click(Sender: TObject);
begin
  if MenuItem85.Checked then
  begin
    INIFile.WriteBool('SetLog', 'trxShow', True);
    IniSet.trxShow := True;
    TRXForm.Show;
  end
  else
  begin
    INIFile.WriteBool('SetLog', 'trxShow', False);
    IniSet.trxShow := False;
    TRXForm.Hide;
  end;
end;

procedure TMiniForm.MIContestLoggingClick(Sender: TObject);
begin
  if IniSet.showBand then
    ContestForm.CBBand.Text := CBBand.Text
  else
    ContestForm.CBBand.Text := dmFunc.GetBandFromFreq(CBBand.Text);
  ContestForm.CBBandChange(self);
  ContestForm.ShowModal;
end;

procedure TMiniForm.MiCWKeysClick(Sender: TObject);
begin
  CWKeysForm.Show;
end;

procedure TMiniForm.MICWTypeClick(Sender: TObject);
begin
  CWTypeForm.Show;
  MiCWKeys.Enabled := False;
end;

procedure TMiniForm.ProgramItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
begin
  MenuItem := (Sender as TMenuItem);
  dmFunc.RunProgram(MainFunc.GetExternalProgramsPath(MenuItem.Caption), '');
end;

procedure TMiniForm.MIExtProgClick(Sender: TObject);
var
  ProgramItem: TMenuItem;
  i: integer;
begin
  FreeMenuItem(75);

  for i := 0 to High(MainFunc.GetExternalProgramsName) do
  begin
    ProgramItem := TMenuItem.Create(Self);
    ProgramItem.Name := 'ProgramItem' + IntToStr(i);
    ProgramItem.Caption := MainFunc.GetExternalProgramsName[i];
    ProgramItem.OnClick := @ProgramItemClick;
    ProgramItem.Tag := 75;
    if MainFunc.GetExternalProgramsName[i] <> '' then
      MIExtProg.Add(ProgramItem);
  end;
end;

procedure TMiniForm.miMapTopClick(Sender: TObject);
begin
  if IniSet.Map_Use then
  begin
    if miMapTop.Checked then
    begin
      MapForm.FormStyle := fsSystemStayOnTop;
      IniSet.eTop := True;
      INIFile.WriteBool('SetLog', 'eTop', True);
    end
    else
    begin
      MapForm.FormStyle := fsNormal;
      IniSet.eTop := False;
      INIFile.WriteBool('SetLog', 'eTop', False);
    end;
  end
  else
  begin
    if miMapTop.Checked then
    begin
      Earth.FormStyle := fsSystemStayOnTop;
      IniSet.eTop := True;
      INIFile.WriteBool('SetLog', 'eTop', True);
    end
    else
    begin
      Earth.FormStyle := fsNormal;
      IniSet.eTop := False;
      INIFile.WriteBool('SetLog', 'eTop', False);
    end;
  end;
end;

procedure TMiniForm.MiMainTopClick(Sender: TObject);
begin
  if MiMainTop.Checked then
  begin
    MiniForm.FormStyle := fsSystemStayOnTop;
    IniSet.mTop := True;
    INIFile.WriteBool('SetLog', 'mTop', True);
  end
  else
  begin
    MiniForm.FormStyle := fsNormal;
    IniSet.mTop := False;
    INIFile.WriteBool('SetLog', 'mTop', False);
  end;

end;

procedure TMiniForm.MiLogGridTopClick(Sender: TObject);
begin
  if MiLogGridTop.Checked then
  begin
    GridsForm.FormStyle := fsSystemStayOnTop;
    IniSet.gTop := True;
    INIFile.WriteBool('SetLog', 'gTop', True);
  end
  else
  begin
    GridsForm.FormStyle := fsNormal;
    IniSet.gTop := False;
    INIFile.WriteBool('SetLog', 'gTop', False);
  end;
end;

procedure TMiniForm.MIClusterTopClick(Sender: TObject);
begin
  if MIClusterTop.Checked then
  begin
    dxClusterForm.FormStyle := fsSystemStayOnTop;
    IniSet.cTop := True;
    INIFile.WriteBool('SetLog', 'cTop', True);
  end
  else
  begin
    dxClusterForm.FormStyle := fsNormal;
    IniSet.cTop := False;
    INIFile.WriteBool('SetLog', 'cTop', False);
  end;
end;

procedure TMiniForm.MiLogbookFormClick(Sender: TObject);
begin
  if MiLogbookForm.Checked then
  begin
    INIFile.WriteBool('SetLog', 'gShow', True);
    GridsForm.Show;
  end
  else
  begin
    INIFile.WriteBool('SetLog', 'gShow', False);
    GridsForm.Hide;
  end;
end;

procedure TMiniForm.MIMapFormClick(Sender: TObject);
begin
  if MIMapForm.Checked then
  begin
    INIFile.WriteBool('SetLog', 'eShow', True);
    if IniSet.Map_Use then
      MapForm.Show
    else
      Earth.Show;
  end
  else
  begin
    INIFile.WriteBool('SetLog', 'eShow', False);
    if IniSet.Map_Use then
      MapForm.hide
    else
      Earth.Hide;
  end;
end;

procedure TMiniForm.MIMModeClick(Sender: TObject);
var
  tempSet: string;
begin
  tempSet := IniSet.MainForm;
  IniSet.MainForm := 'MULTI';
  if tempSet <> IniSet.MainForm then
  begin
    SwitchForm;
    MenuItem73.Checked := False;
    MiLogbookForm.Enabled := True;
    MITelnetForm.Enabled := True;
    MIMapForm.Enabled := True;
    MIPhoto.Enabled := True;
    MiMainTop.Enabled := True;
    MiLogGridTop.Enabled := True;
    MIClusterTop.Enabled := True;
    miMapTop.Enabled := True;
    MiPhotoTop.Enabled := True;
  end;
  MIMMode.Checked := False;
  MIMMode.Checked := True;
end;

procedure TMiniForm.MenuItem48Click(Sender: TObject);
begin
  SynDBDate.Show;
end;

procedure TMiniForm.MenuItem52Click(Sender: TObject);
begin
  ConfigForm.Show;
end;

procedure TMiniForm.MenuItem53Click(Sender: TObject);
begin
  ExportAdifForm.Show;
end;

procedure TMiniForm.MenuItem55Click(Sender: TObject);
begin
  CBCurrentLog.SetFocus;
  CBCurrentLog.DroppedDown := True;
end;

procedure TMiniForm.MenuItem56Click(Sender: TObject);
begin
  CreateJournalForm.Show;
end;

procedure TMiniForm.MenuItem63Click(Sender: TObject);
begin
  thanks_form.Show;
end;

procedure TMiniForm.MenuItem65Click(Sender: TObject);
begin
  SBNew.Click;
end;

procedure TMiniForm.MenuItem66Click(Sender: TObject);
begin
  SBSave.Click;
end;

procedure TMiniForm.MenuItem69Click(Sender: TObject);
begin
  Close;
end;

procedure TMiniForm.MenuItem70Click(Sender: TObject);
begin
  ImportADIFForm.Show;
end;

procedure TMiniForm.MenuItem73Click(Sender: TObject);
begin
  MenuItem73.Checked := True;
  if MenuItem73.Checked then
  begin
    IniSet.MainForm := 'MAIN';
    MIMMode.Checked := False;
    DisableMenuMiniMode;
    SwitchForm;
  end;
end;

procedure TMiniForm.DisableMenuMiniMode;
begin
  MiLogbookForm.Enabled := False;
  MITelnetForm.Enabled := False;
  MIMapForm.Enabled := False;
  MIPhoto.Enabled := False;
  MiMainTop.Enabled := False;
  MiLogGridTop.Enabled := False;
  MIClusterTop.Enabled := False;
  miMapTop.Enabled := False;
  MiPhotoTop.Enabled := False;
end;

procedure TMiniForm.MenuItem7Click(Sender: TObject);
begin
  LogConfigForm.Show;
  LogConfigForm.PageControl1.ActivePageIndex := 0;
end;

procedure TMiniForm.MenuItem87Click(Sender: TObject);
begin
  SettingsProgramForm.Show;
end;

procedure TMiniForm.MenuItem91Click(Sender: TObject);
begin
  DataBaseSettingsForm.Show;
end;

procedure TMiniForm.MenuItem92Click(Sender: TObject);
begin
  Update_Form.Show;
end;

procedure TMiniForm.MenuItem94Click(Sender: TObject);
begin
  About_Form.Show;
end;

procedure TMiniForm.MIDownloadLangClick(Sender: TObject);
var
  HTTP: TFPHttpClient;
  Document: TMemoryStream;
  UnZipper: TUnZipper;
begin
  if DirectoryExists(FilePATH + 'locale') then
    DeleteDirectory(FilePATH + 'locale', False);
  ForceDirectories(FilePATH + 'locale');
  try
    HTTP := TFPHttpClient.Create(nil);
    Document := TMemoryStream.Create;
    HTTP.Get(DownLocaleURL, Document);
    if HTTP.ResponseStatusCode = 200 then
      Document.SaveToFile(FilePATH + 'updates' + DirectorySeparator + 'locale.zip');
  finally
    FreeAndNil(HTTP);
    FreeAndNil(Document);
    try
      UnZipper := TUnZipper.Create;
      UnZipper.FileName := FilePATH + 'updates' + DirectorySeparator + 'locale.zip';
      UnZipper.OutputPath := FilePATH + 'locale' + DirectorySeparator;
      UnZipper.Examine;
      UnZipper.UnZipAllFiles;
    finally
      FreeAndNil(UnZipper);
      ShowMessage(rLanguageComplite);
    end;
  end;
end;

procedure TMiniForm.MILanguageClick(Sender: TObject);
var
  LangItem: TMenuItem;
  LangList: TStringList;
  i: integer;
begin
  FreeMenuItem(99);

  LangList := TStringList.Create;
  FindLanguageFiles(FilePATH + 'locale', LangList);
  for i := 0 to LangList.Count - 1 do
  begin
    LangItem := TMenuItem.Create(Self);
    LangItem.Name := 'LangItem' + IntToStr(i);
    LangItem.Caption := MainFunc.FindCountry(LangList.Strings[i]);
    LangItem.OnClick := @LangItemClick;
    LangItem.Tag := 99;
    if MainFunc.FindCountry(LangList.Strings[i]) <> 'None' then
      MILanguage.Insert(i, LangItem);
  end;
  LangList.Free;
end;

procedure TMiniForm.MIPhotoClick(Sender: TObject);
begin
  if MIPhoto.Checked then
  begin
    INIFile.WriteBool('SetLog', 'pShow', True);
    IniSet.pShow := True;
    viewPhoto.Show;
  end
  else
  begin
    INIFile.WriteBool('SetLog', 'pShow', False);
    IniSet.pShow := False;
    viewPhoto.Hide;
  end;
end;

procedure TMiniForm.MiPhotoSeparateClick(Sender: TObject);
begin
  if MiPhotoSeparate.Checked then
  begin
    INIFile.WriteBool('SetLog', 'pSeparate', True);
    IniSet.pSeparate := True;
    viewPhoto.BorderStyle := bsSizeable;
    viewPhoto.Parent := nil;
    viewPhoto.Align := alNone;
    if IniSet.pTop then
      viewPhoto.FormStyle := fsSystemStayOnTop;
    viewPhoto.Show;
  end
  else
  begin
    INIFile.WriteBool('SetLog', 'pSeparate', False);
    IniSet.pSeparate := False;
    viewPhoto.Hide;
    viewPhoto.BorderStyle := bsNone;
    viewPhoto.Parent := MainForm.OtherPanel;
    viewPhoto.Align := alClient;
    if IniSet.pShow then
      viewPhoto.Show;
  end;
end;

procedure TMiniForm.MiPhotoSeparateTopClick(Sender: TObject);
begin
  if MiPhotoSeparateTop.Checked then
  begin
    viewPhoto.FormStyle := fsSystemStayOnTop;
    IniSet.pTop := True;
    INIFile.WriteBool('SetLog', 'pTop', True);
  end
  else
  begin
    viewPhoto.FormStyle := fsNormal;
    IniSet.pTop := False;
    INIFile.WriteBool('SetLog', 'pTop', False);
  end;
end;

procedure TMiniForm.MiPhotoTopClick(Sender: TObject);
begin
  if MiPhotoTop.Checked then
  begin
    viewPhoto.FormStyle := fsSystemStayOnTop;
    IniSet.pTop := True;
    INIFile.WriteBool('SetLog', 'pTop', True);
  end
  else
  begin
    viewPhoto.FormStyle := fsNormal;
    IniSet.pTop := False;
    INIFile.WriteBool('SetLog', 'pTop', False);
  end;
end;

procedure TMiniForm.MIRadioClick(Sender: TObject);
var
  RadioItems: TMenuItem;
  i: integer;
begin
  FreeMenuItem(76);
  for i := 0 to RadioList.Count - 1 do
  begin
    RadioItems := TMenuItem.Create(Self);
    RadioItems.Name := 'RadioItems' + IntToStr(i);
    RadioItems.Caption := RadioList.Names[i];
    RadioItems.OnClick := @RadioItemClick;
    RadioItems.Tag := 76;
    if RadioList.Values[RadioItems.Caption] = IniSet.CurrentRIG then
      RadioItems.Checked := True;
    MIRadio.Insert(i, RadioItems);
  end;
end;

procedure TMiniForm.MISatelliteClick(Sender: TObject);
begin
  SATForm.Show;
end;

procedure TMiniForm.RadioItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
begin
  MenuItem := (Sender as TMenuItem);
  IniSet.CurrentRIG := RadioList.Values[MenuItem.Caption];
  MenuItem.Checked := True;
  INIFile.WriteString('SetCAT', 'CurrentRIG', IniSet.CurrentRIG);
  MainFunc.StartRadio(IniSet.CurrentRIG);
end;

procedure TMiniForm.MITelnetFormClick(Sender: TObject);
begin
  if MITelnetForm.Checked then
  begin
    INIFile.WriteBool('SetLog', 'cShow', True);
    dxClusterForm.Show;
  end
  else
  begin
    INIFile.WriteBool('SetLog', 'cShow', False);
    dxClusterForm.Hide;
  end;
end;

procedure TMiniForm.SaveQSOinBaseExecute(Sender: TObject);
begin
  SBSave.Click;
end;

procedure TMiniForm.SBInfoClick(Sender: TObject);
begin
  if EditCallsign.Text <> '' then
  begin
    InformationForm.Callsign := dmFunc.ExtractCallsign(EditCallsign.Text);
    InformationForm.FromForm := 'MainForm';
    InformationForm.Show;
  end
  else
    ShowMessage(rNotCallsign);
end;

procedure TMiniForm.SBIOTAClick(Sender: TObject);
begin
  IOTA_Form.Edit1.Text := EditIOTA.Text;
  IOTA_Form.Show;
end;

procedure TMiniForm.SBMGRClick(Sender: TObject);
begin
  QSLManager_Form.Show;
end;

procedure TMiniForm.SBNewClick(Sender: TObject);
begin
  Clr;
end;

procedure TMiniForm.SBSaveClick(Sender: TObject);
var
  QSL_SENT_ADV, QSL_SENT, dift: string;
  DigiBand: double;
  NameBand: string;
  timeQSO: TTime;
  FmtStngs: TFormatSettings;
  lat, lon: currency;
  SQSO: TQSO;
  PFXR: TPFXR;
begin
  if InitRecord.SelectLogbookTable then
  begin
    QSL_SENT := '';
    QSL_SENT_ADV := '';
    NameBand := '';
    FmtStngs.TimeSeparator := ':';
    FmtStngs.LongTimeFormat := 'hh:nn';

    if (Length(CBBand.Text) = 0) then
    begin
      ShowMessage(rCheckBand);
      Exit;
    end;

    if (Length(CBMode.Text) = 0) then
    begin
      ShowMessage(rCheckMode);
      Exit;
    end;

    dift := FormatDateTime('hh', Now - NowUTC);
    if CBSaveUTC.Checked then
    begin
      timeQSO := DateTimePicker1.Time - StrToTime(dift);
    end
    else
      timeQSO := DateTimePicker1.Time;

    if EditCallsign.Text = '' then
      ShowMessage(rEnCall)
    else
    begin
      QSL_SENT := '0';
      case CBYourQSL.ItemIndex of
        0:
        begin
          QSL_SENT_ADV := 'T';
          QSL_SENT := '1';
        end;
        1: QSL_SENT_ADV := 'P';
        2: QSL_SENT_ADV := 'Q';
        3: QSL_SENT_ADV := 'F';
        4: QSL_SENT_ADV := 'N';
      end;

      if FMS.Freq > 0 then
        NameBand := MainFunc.ConvertFreqToSave(FloatToStr(FMS.Freq / 1000000))
      else
        NameBand := MainFunc.ConvertFreqToSave(CBBand.Text);
      DigiBand := dmFunc.GetDigiBandFromFreq(NameBand);
      PFXR := MainFunc.SearchPrefix(EditCallsign.Text, EditGrid.Text);
      SQSO.CallSing := EditCallsign.Text;
      SQSO.QSODateTime := DateTimePicker1.DateTime;
      if not CBRealTime.Checked then
        SQSO.QSODateTime := DateEdit1.Date + timeQSO;
      SQSO.QSODate := DateEdit1.Date;
      SQSO.QSOTime := FormatDateTime('hh:nn', timeQSO);
      SQSO.QSOBand := NameBand;
      SQSO.QSOMode := CBMode.Text;
      SQSO.QSOSubMode := CBSubMode.Text;
      SQSO.QSOReportSent := CBRSTs.Text;
      SQSO.QSOReportRecived := CBRSTr.Text;
      SQSO.OmName := EditName.Text;
      SQSO.OmQTH := EditQTH.Text;
      SQSO.State0 := EditState.Text;
      SQSO.Grid := EditGrid.Text;
      SQSO.IOTA := EditIOTA.Text;
      SQSO.QSLManager := EditMGR.Text;
      SQSO.QSLSent := QSL_SENT;
      SQSO.QSLSentAdv := QSL_SENT_ADV;
      SQSO.QSLRec := '0';
      SQSO.MainPrefix := PFXR.Prefix;
      SQSO.DXCCPrefix := PFXR.ARRLPrefix;
      SQSO.CQZone := PFXR.CQZone;
      SQSO.ITUZone := PFXR.ITUZone;
      SQSO.QSOAddInfo := EditComment.Text;
      SQSO.Marker := BoolToStr(CBMark.Checked);
      SQSO.ManualSet := 0;
      SQSO.DigiBand := StringReplace(FloatToStr(DigiBand), ',', '.', [rfReplaceAll]);
      SQSO.Continent := PFXR.Continent;
      SQSO.ShortNote := EditComment.Text;
      SQSO.QSLReceQSLcc := 0;
      SQSO.LotWRec := '';

      if not IniSet.StateToQSLInfo then
        SQSO.QSLInfo := LBRecord.QSLInfo
      else
      begin
        if (EditMyGrid.Text <> '') or (EditMyState.Text <> '') then
          SQSO.QSLInfo := EditMyState.Text + ' ' + EditMyGrid.Text
        else
          SQSO.QSLInfo := LBRecord.QSLInfo;
      end;

      SQSO.Call := dmFunc.ExtractCallsign(EditCallsign.Text);
      SQSO.State1 := '';
      SQSO.State2 := '';
      SQSO.State3 := '';
      SQSO.State4 := '';
      SQSO.WPX := dmFunc.ExtractWPXPrefix(EditCallsign.Text);
      SQSO.AwardsEx := 'NULL';
      SQSO.ValidDX := IntToStr(1);
      SQSO.SRX := 0;
      SQSO.SRX_String := '';
      SQSO.STX := 0;
      SQSO.STX_String := '';
      SQSO.SAT_NAME := '';
      SQSO.SAT_MODE := '';
      SQSO.PROP_MODE := '';
      SQSO.LotWSent := 0;
      SQSO.QSL_RCVD_VIA := '';
      SQSO.QSL_SENT_VIA := CBQSLVia.Text;
      SQSO.DXCC := IntToStr(PFXR.DXCCNum);
      SQSO.USERS := '';
      SQSO.NoCalcDXCC := 0;
      SQSO.SYNC := 0;
      SQSO.ContestName := 'NULL';
      SQSO.ContestSession := 'NULL';
      SQSO.FreqRX := 'NULL';
      SQSO.BandRX := 'NULL';

      if SATFormActive then
      begin
        SQSO.SAT_NAME := SATForm.CBSat.Text;
        SQSO.SAT_MODE := SATForm.CBSatMode.Text;
        SQSO.PROP_MODE := SATForm.CBProp.Text;
        if Length(SATForm.CbTXFrequency.Text) > 1 then
        begin
          NameBand := MainFunc.ConvertFreqToSave(SATForm.CbTXFrequency.Text);
          SQSO.QSOBand := NameBand;
          if FMS.Freq > 0 then
            NameBand := MainFunc.ConvertFreqToSave(FloatToStr(FMS.Freq / 1000000))
          else
            NameBand := MainFunc.ConvertFreqToSave(CBBand.Text);
          SQSO.FreqRX := NameBand;
          DigiBand := dmFunc.GetDigiBandFromFreq(SQSO.QSOBand);
          SQSO.DigiBand := StringReplace(FloatToStr(DigiBand), ',', '.', [rfReplaceAll]);
          SQSO.BandRX := dmFunc.GetBandFromFreq(SQSO.FreqRX);
        end;
        if Length(SATForm.CBqslMsg.Text) > 2 then
          SQSO.QSLInfo := SATForm.CBqslMsg.Text;
      end;

      if LBRecord.OpLoc <> '' then
        SQSO.My_Grid := LBRecord.OpLoc;

      if EditMyGrid.Text <> '' then
        SQSO.My_Grid := EditMyGrid.Text;

      SQSO.My_State := EditMyState.Text;

      if (SQSO.My_Grid <> '') and (dmFunc.IsLocOK(SQSO.My_Grid)) then
      begin
        dmFunc.CoordinateFromLocator(SQSO.My_Grid, lat, lon);
        SQSO.My_Lat := CurrToStr(lat);
        SQSO.My_Lon := CurrToStr(lon);
      end
      else
      begin
        SQSO.My_Lat := '';
        SQSO.My_Lon := '';
      end;
      SQSO.NLogDB := LBRecord.LogTable;
      MainFunc.SaveQSO(SQSO);
      SQSO.Auto := True;
      if LBRecord.AutoClubLog then
        MainFunc.SendQSOto('clublog', SQSO);
      if LBRecord.AutoEQSLcc then
        MainFunc.SendQSOto('eqslcc', SQSO);
      if LBRecord.AutoHRDLog then
        MainFunc.SendQSOto('hrdlog', SQSO);
      if LBRecord.AutoHamQTH then
        MainFunc.SendQSOto('hamqth', SQSO);
      if LBRecord.AutoQRZCom then
        MainFunc.SendQSOto('qrzcom', SQSO);
      if LBRecord.AutoQSOsu then
        MainFunc.SendQSOto('qsosu', SQSO);
      if LBRecord.AutoHAMLogOnline then
        MainFunc.SendQSOto('hamlogonline', SQSO);
      if IniSet.AutoCloudLog then
        MainFunc.SendQSOto('cloudlog', SQSO);
      if IniSet.WorkOnLAN then
        ServerDM.SendBroadcastADI(ServerDM.CreateADIBroadcast(SQSO, 'ANY', 'TRUE'));

      Clr;
      MiniForm.TextSB('QSO № ' + IntToStr(1) + rQSOTotal +
        IntToStr(CountAllRecords), 1);
    end;
  end;
end;

procedure TMiniForm.SBStateClick(Sender: TObject);
begin
  STATE_Form.Show;
  STATE_Form.Edit1.Text := EditState.Text;
end;

procedure TMiniForm.SentSpotExecute(Sender: TObject);
begin
  if Length(EditCallsign.Text) > 0 then
    SendTelnetSpot.EditDXCall.Text := EditCallsign.Text;
  SendTelnetSpot.Show;
end;

procedure TMiniForm.Shape1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  if Shape1.Brush.Color = clLime then
    Shape1.Hint := rNewDXCCInBM;
  if Shape1.Brush.Color = clFuchsia then
    Shape1.Hint := rNeedQSL;
end;

procedure TMiniForm.ShowCommentStat;
begin
  LBComment.Visible := True;
  EditComment.Visible := True;
  INIFile.WriteBool('SetLog', 'VisibleComment', True);
  MiniForm.Height := MiniForm.Height + 50;
  SBHideComment.Caption := '▲';
end;

procedure TMiniForm.HideCommentStat;
begin
  LBComment.Visible := False;
  EditComment.Visible := False;
  INIFile.WriteBool('SetLog', 'VisibleComment', False);
  SBHideComment.Caption := '▼';
end;

procedure TMiniForm.SBHideCommentClick(Sender: TObject);
begin
  if SBHideComment.Caption = '▲' then
  begin
    HideCommentStat;
    Exit;
  end;
  if SBHideComment.Caption = '▼' then
  begin
    ShowCommentStat;
    Exit;
  end;
end;

procedure TMiniForm.StatBarClick(Sender: TObject);
begin
  if StatBar.Panels.Items[0].Text = rUpdateRequired then
    Update_Form.Show;
end;

procedure TMiniForm.StatBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  if (Panel = StatusBar.Panels[0]) and (StatusBar.Panels[0].Text = rUpdateRequired) then
  begin
    StatusBar.Canvas.Font.Color := clRed;
    StatusBar.Canvas.TextOut(Rect.left, Rect.Top, StatusBar.Panels[0].Text);
  end;
end;

procedure TMiniForm.EditCallsignButtonClick(Sender: TObject);
var
  FoundQSOR: TFoundQSOR;
begin
  if InitDB.ImbeddedCallBookConnection.Connected then
  begin
    FoundQSOR := MainFunc.FindInCallBook(dmfunc.ExtractCallsign(EditCallsign.Text));
    EditName.Text := FoundQSOR.OMName;
    EditQTH.Text := FoundQSOR.OMQTH;
    EditGrid.Text := FoundQSOR.Grid;
    EditState.Text := FoundQSOR.State;
    EditMGR.Text := FoundQSOR.QSLManager;
  end
  else
    InfoDM.GetInformation(dmFunc.ExtractCallsign(EditCallsign.Text), 'MainForm');
  if not FoundQSOR.Found then
    InfoDM.GetInformation(dmFunc.ExtractCallsign(EditCallsign.Text), 'MainForm');
end;

procedure TMiniForm.CBRealTimeChange(Sender: TObject);
begin
  if not CBRealTime.Checked then
  begin
    EditCallsign.Font.Color := clRed;
    DateTimePicker1.Font.Color := clRed;
    DateEdit1.Font.Color := clRed;
    CBSaveUTC.Enabled := True;
    DateTimePicker1.ReadOnly := False;
  end
  else
  begin
    EditCallsign.Font.Color := clDefault;
    DateTimePicker1.Font.Color := clDefault;
    DateEdit1.Font.Color := clDefault;
    CBSaveUTC.Enabled := False;
    CBSaveUTC.Checked := False;
    DateTimePicker1.ReadOnly := True;
  end;
end;

procedure TMiniForm.CBFilterChange(Sender: TObject);
begin
  if not CBFilter.Checked then
    InitDB.SelectLogbookTable(LBRecord.LogTable);
  MainFunc.SetGrid(GridsForm.DBGrid1);
  MainFunc.SetGrid(GridsForm.DBGrid2);
end;

procedure TMiniForm.CBMapChange(Sender: TObject);
begin
  INIFile.WriteBool('SetLog', 'UseMAPS', CBMap.Checked);
  IniSet.Map_Use := CBMap.Checked;
  if IniSet.MainForm <> 'MULTI' then
  begin
    if CBMap.Checked then
    begin
      Earth.Parent := nil;
      MapForm.BorderStyle := bsNone;
      MapForm.Parent := MainForm.EarthPanel;
      MapForm.Align := alClient;
      Earth.Close;
      MapForm.Show;
    end
    else
    begin
      MapForm.Parent := nil;
      Earth.BorderStyle := bsNone;
      Earth.Parent := MainForm.EarthPanel;
      Earth.Align := alClient;
      MapForm.Close;
      Earth.Show;
    end;
  end
  else
  begin
    if CBMap.Checked then
    begin
      MapForm.BorderStyle := bsSizeable;
      Earth.Close;
      MapForm.Show;
    end
    else
    begin
      Earth.BorderStyle := bsSizeable;
      Earth.Show;
      if MapForm.Showing then
        MapForm.Close;
    end;
  end;
end;

procedure TMiniForm.CBModeChange(Sender: TObject);
begin
  SentCloudLogCat;
end;

procedure TMiniForm.CBModeCloseUp(Sender: TObject);
var
  RSdigi: array[0..4] of string = ('599', '589', '579', '569', '559');
  RSssb: array[0..6] of string = ('59', '58', '57', '56', '55', '54', '53');
  i: integer;
  FormatFreqFloat: double;
begin
  FreqChange := True;
  //Загрузка сабмодуляций
  CBSubMode.Items.Clear;
  for i := 0 to High(MainFunc.LoadSubModes(CBMode.Text)) do
    CBSubMode.Items.Add(MainFunc.LoadSubModes(CBMode.Text)[i]);

  if CBMode.Text <> 'SSB' then
    CBSubMode.Text := '';
  //  TryStrToFloatSafe(MainFunc.ConvertFreqToSave(CBBand.Text), FormatFreqFloat);
  TryStrToFloatSafe(MainFunc.FormatFreq(CBBand.Text), FormatFreqFloat);
  if FormatFreqFloat >= 10 then
    CBSubMode.ItemIndex := CBSubMode.Items.IndexOf('USB')
  else
    CBSubMode.ItemIndex := CBSubMode.Items.IndexOf('LSB');

  CBRSTs.Items.Clear;
  CBRSTs.Items.AddStrings(RSssb);
  CBRSTs.ItemIndex := 0;
  CBRSTr.Items.Clear;
  CBRSTr.Items.AddStrings(RSssb);
  CBRSTr.ItemIndex := 0;

  if (CBMode.Text = 'CW') or (CBMode.Text = 'PSK') or (CBMode.Text = 'RTTY') then
  begin
    CBRSTs.Items.Clear;
    CBRSTs.Items.AddStrings(RSdigi);
    CBRSTs.ItemIndex := 0;
    CBRSTr.Items.Clear;
    CBRSTr.Items.AddStrings(RSdigi);
    CBRSTr.ItemIndex := 0;
  end;

  if (CBMode.Text = 'JT65') or (CBMode.Text = 'FT8') or (CBMode.Text = 'JT9') or
    (CBSubMode.Text = 'FT4') then
  begin
    CBRSTs.Items.Clear;
    CBRSTs.Text := '-10';
    CBRSTr.Items.Clear;
    CBRSTr.Text := '-10';
  end;

  if Length(EditCallsign.Text) >= 2 then
    EditCallsignChange(CBMode);
end;

procedure TMiniForm.CBCurrentLogChange(Sender: TObject);
begin
  EditMyGrid.Clear;
  EditMyState.Clear;
  if Sender <> LogConfigForm then
  begin
    if InitDB.GetLogBookTable(CBCurrentLog.Text) then
      if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
        ShowMessage(rDBError)
      else
        DBRecord.CurrentLogTable := CBCurrentLog.Text;
  end;
  if CBCurrentLog.ItemIndex > -1 then
  begin
    if Pos('/', CBCurrentLog.Text) > 0 then
    begin
      LBMyGrid.Visible := True;
      EditMyGrid.Visible := True;
      LBMyState.Visible := True;
      EditMyState.Visible := True;
    end
    else
    begin
      LBMyGrid.Visible := False;
      EditMyGrid.Visible := False;
      LBMyState.Visible := False;
      EditMyState.Visible := False;
    end;
  end;
end;

procedure TMiniForm.CBBandCloseUp(Sender: TObject);
var
  FormatFreqFloat: double;
begin
  FreqChange := True;
  if CBMode.Text = 'SSB' then
  begin
    TryStrToFloatSafe(MainFunc.FormatFreq(CBBand.Text), FormatFreqFloat);
    if FormatFreqFloat >= 10 then
      CBSubMode.ItemIndex := CBSubMode.Items.IndexOf('USB')
    else
      CBSubMode.ItemIndex := CBSubMode.Items.IndexOf('LSB');
  end;

  if Length(EditCallsign.Text) >= 2 then
    EditCallsignChange(CBBand);
end;

procedure TMiniForm.CBBandChange(Sender: TObject);
begin
  SentCloudLogCat;
end;

procedure TMiniForm.MacroKeyF1Execute(Sender: TObject);
begin
  if CWKeysForm.Showing then
    CWKeysForm.BtF1.Click;
end;

procedure TMiniForm.MacroKeyF10Execute(Sender: TObject);
begin
  if CWKeysForm.Showing then
    CWKeysForm.BtF10.Click;
end;

procedure TMiniForm.EditGridChange(Sender: TObject);
var
  PFXR: TPFXR;
begin
  if Length(EditCallsign.Text) < 3 then Exit;
  if Length(EditGrid.Text) > 3 then
  begin
    PFXR := MainFunc.SearchPrefix(EditCallsign.Text, EditGrid.Text);
    LBAzimuthD.Caption := PFXR.Azimuth;
    LBDistanceD.Caption := PFXR.Distance;
    LBLatitudeD.Caption := PFXR.Latitude;
    LBLongitudeD.Caption := PFXR.Longitude;
  end;
end;

procedure TMiniForm.CBSaveUTCChange(Sender: TObject);
begin
  if CBSaveUTC.Checked then
    LBTime.Caption := rQSOTime + ' (Local)'
  else
    LBTime.Caption := rQSOTime + ' (UTC)';
end;

procedure TMiniForm.CheckUpdateTimerStartTimer(Sender: TObject);
begin
  Update_Form.CheckServerVersionFile;
end;

procedure TMiniForm.CheckUpdateTimerTimer(Sender: TObject);
begin
  Update_Form.CheckServerVersionFile;
end;

procedure TMiniForm.ClearEditExecute(Sender: TObject);
begin
  SBNew.Click;
end;

procedure TMiniForm.EditCallsignChange(Sender: TObject);
var
  engText: string;
  DBand, DMode, DCall: boolean;
  QSL: integer;
  Lat, Lon: string;
  PFXR: TPFXR;
  FoundQSOR: TFoundQSOR;
  editButtonLeng: integer;
  editButtonText: string;
begin
  DBand := False;
  DMode := False;
  DCall := False;
  LBQSL.Visible := False;
  LBWorked.Visible := False;
  LBCfm.Visible := False;
  QSL := 0;
  editButtonLeng := Length(EditCallsign.Text);
  EditCallsign.SelStart := SelEditNumChar;
  engText := dmFunc.RusToEng(EditCallsign.Text);
  if (engText <> EditCallsign.Text) then
  begin
    EditCallsign.Text := engText;
    exit;
  end;
  editButtonText := EditCallsign.Text;

  if CBFilter.Checked then
  begin
    MainFunc.FilterQSO('Call', editButtonText + '%');
    Exit;
  end;

  if editButtonText = '' then
  begin
    Clr;
    LBAzimuthD.Caption := '.......';
    LBDistanceD.Caption := '.......';
    LBLatitudeD.Caption := '.......';
    LBLongitudeD.Caption := '.......';
    LBTerritoryD.Caption := '.......';
    LBCont.Caption := '.......';
    LBDXCCD.Caption := '.......';
    LBITUD.Caption := '..';
    LBCQD.Caption := '..';
    LBPrefixD.Caption := '.......';
    Earth.PaintLine(FloatToStr(LBRecord.OpLat), FloatToStr(LBRecord.OpLon),
      LBRecord.OpLat, LBRecord.OpLon);
    Earth.Invalidate;
    Exit;
  end;

  if editButtonLeng > 1 then
  begin
    MainFunc.CheckDXCC(editButtonText, CBMode.Text, CBBand.Text,
      DMode, DBand, DCall);
    QSL := MainFunc.CheckQSL(editButtonText, CBBand.Text, CBMode.Text);
    LBWorked.Visible := MainFunc.FindWorkedCall(editButtonText,
      CBBand.Text, CBMode.Text);
    LBQSL.Visible := MainFunc.WorkedQSL(editButtonText, CBBand.Text, CBMode.Text);
    LBCfm.Visible := MainFunc.WorkedLoTW(editButtonText, CBBand.Text, CBMode.Text);
  end;

  ImDXCCBand.Visible := DBand;
  ImDXCCMode.Visible := DMode;
  ImDXCCcountry.Visible := DCall;

  Shape1.Visible := (QSL <> 0);

  if QSL = 1 then
    Shape1.Brush.Color := clFuchsia;

  if QSL = 2 then
    Shape1.Brush.Color := clLime;

  if (Sender = CBBand) or (Sender = CBMode) then
    Exit;

  EditName.Clear;
  EditQTH.Clear;
  EditGrid.Clear;
  EditState.Clear;
  EditIOTA.Clear;
  EditMGR.Clear;

  if editButtonLeng > 0 then
  begin
    PFXR := MainFunc.SearchPrefix(editButtonText, EditGrid.Text);
    LBAzimuthD.Caption := PFXR.Azimuth;
    LBDistanceD.Caption := PFXR.Distance;
    LBLatitudeD.Caption := PFXR.Latitude;
    LBLongitudeD.Caption := PFXR.Longitude;
    LBTerritoryD.Caption := PFXR.Country;
    LBCont.Caption := PFXR.Continent;
    LBDXCCD.Caption := PFXR.ARRLPrefix;
    LBPrefixD.Caption := PFXR.Prefix;
    LBCQD.Caption := PFXR.CQZone;
    LBITUD.Caption := PFXR.ITUZone;
    TimeDIF := PFXR.TimeDiff;
  end;
  dmFunc.GetLatLon(PFXR.Latitude, PFXR.Longitude, Lat, Lon);
  Earth.PaintLine(Lat, Lon, LBRecord.OpLat, LBRecord.OpLon);
  Earth.Invalidate;

  //MapView
  if PFXR.Found and CBMap.Checked then
    MapForm.WriteMap(Lat, Lon, 9);

  FoundQSOR := MainFunc.FindQSO(dmfunc.ExtractCallsign(editButtonText));
  if FoundQSOR.Found then
  begin
    EditName.Text := FoundQSOR.OMName;
    EditQTH.Text := FoundQSOR.OMQTH;
    EditGrid.Text := FoundQSOR.Grid;
    EditState.Text := FoundQSOR.State;
    EditIOTA.Text := FoundQSOR.IOTA;
    EditMGR.Text := FoundQSOR.QSLManager;
    LBCount.Caption := IntToStr(FoundQSOR.CountQSO);
    LBDateQSO.Caption := FoundQSOR.QSODate;
    LBTimeQSO.Caption := FoundQSOR.QSOTime;
    LBBandQSO.Caption := FoundQSOR.QSOBand;
    LBModeQSO.Caption := FoundQSOR.QSOMode;
    LBNameQSO.Caption := FoundQSOR.OMName;
    EditCallsign.Color := clMoneyGreen;
  end
  else
    EditCallsign.Color := clDefault;

  if not FoundQSOR.Found and IniSet.UseIntCallBook then
  begin
    FoundQSOR := MainFunc.FindInCallBook(dmfunc.ExtractCallsign(editButtonText));
    if FoundQSOR.Found then
    begin
      EditName.Text := FoundQSOR.OMName;
      EditQTH.Text := FoundQSOR.OMQTH;
      EditGrid.Text := FoundQSOR.Grid;
      EditState.Text := FoundQSOR.State;
      EditMGR.Text := FoundQSOR.QSLManager;
    end;
  end;

  if IniSet.pShow then
    viewPhoto.ImPhoto.Picture.LoadFromLazarusResource('no-photo');
end;

procedure TMiniForm.EditCallsignKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  SelEditNumChar := EditCallsign.SelStart + 1;
  if (Key = VK_BACK) then
    SelEditNumChar := EditCallsign.SelStart - 1;
  if (Key = VK_DELETE) then
    SelEditNumChar := EditCallsign.SelStart;
  if (EditCallsign.SelLength <> 0) and (Key = VK_BACK) then
    SelEditNumChar := EditCallsign.SelStart;
  //if (Key = VK_RETURN) then
  //  InfoDM.GetInformation(dmFunc.ExtractCallsign(EditCallsign.Text), 'MainForm');
end;

procedure TMiniForm.EditCallsignKeyPress(Sender: TObject; var Key: char);
begin
  if Key = ' ' then
    Key := Chr(0);
end;

procedure TMiniForm.EditCallsignMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  tempName, tempQTH, tempGrid, tempState: string;
  tempImage: TMemoryStream;
begin
  try
    tempImage := TMemoryStream.Create;
    if Button = mbLeft then
    begin
      {$IFDEF WINDOWS}
      viewPhoto.ImPhoto.Picture.SaveToStream(tempImage);
    {$ENDIF}
      tempName := EditName.Text;
      tempQTH := EditQTH.Text;
      tempGrid := EditGrid.Text;
      tempState := EditState.Text;
      SelEditNumChar := EditCallsign.SelStart;
      EditCallsignChange(nil);
      EditName.Text := tempName;
      EditQTH.Text := tempQTH;
      EditGrid.Text := tempGrid;
      EditState.Text := tempState;
    {$IFDEF WINDOWS}
      tempImage.Position := 0;
      if tempImage.Size > 0 then
        viewPhoto.ImPhoto.Picture.LoadFromStream(tempImage);
    {$ENDIF}
    end;
  finally
    FreeAndNil(tempImage);
  end;
end;

procedure TMiniForm.ExportADIExecute(Sender: TObject);
begin
  exportAdifForm.Show;
end;

procedure TMiniForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if not IniSet.BackupADIonClose and not IniSet.BackupDBonClose then
    CloseApp := True;

  if EditCallsign.Text <> '' then
  begin
    if Application.MessageBox(PChar(rQSONotSave), PChar(rWarning),
      MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      CloseAction := caFree
    else
    begin
      CloseAction := caNone;
      Exit;
    end;
  end;
  if not CloseApp then
  begin
    if IniSet.BackupADIonClose then
    begin
      if MainFunc.BackupDataADI('MiniForm') then
        CloseAction := caNone;
    end;
    if IniSet.BackupDBonClose then
    begin
      if MainFunc.BackupDataDB('MiniForm') then
        CloseAction := caNone;
    end;
  end
  else
  begin
    CloseForm;
    CloseAction := caFree;
  end;
end;

procedure TMiniForm.CloseForm;
begin
  MainFunc.SaveWindowPosition(MiniForm);

  if CBBand.ItemIndex <> -1 then
    INIFile.WriteInteger('SetLog', 'PastBand', CBBand.ItemIndex);
  INIFile.WriteString('SetLog', 'PastMode', CBMode.Text);
  INIFile.WriteString('SetLog', 'PastSubMode', CBSubMode.Text);
  INIFile.WriteString('SetLog', 'Language', IniSet.Language);
  INIFile.WriteBool('SetLog', 'UseMAPS', CBMap.Checked);
  INIFile.WriteString('SetLog', 'MainForm', IniSet.MainForm);
  INIFile.WriteString('SetCAT', 'CurrentRIG', IniSet.CurrentRIG);

  GridsForm.SavePosition;
  Earth.SavePosition;
  dxClusterForm.SavePosition;
  TRXForm.SavePosition;
  CWKeysForm.SavePosition;
  viewPhoto.SavePosition;
  if IniSet.Map_Use then
    MapForm.SavePosition
  else
    Earth.SavePosition;

  dxClusterForm.FreeClusterThread;
  dmHamLib.FreeRadio;
  FreeMenuItem;
end;

procedure TMiniForm.SetHotKey;
begin
  SaveQSOinBase.ShortCut := TextToShortCut(IniSet.KeySave);
  ClearEdit.ShortCut := TextToShortCut(IniSet.KeyClear);
  GetReference.ShortCut := TextToShortCut(IniSet.KeyReference);
  ImportADI.ShortCut := TextToShortCut(IniSet.KeyImportADI);
  ExportADI.ShortCut := TextToShortCut(IniSet.KeyExportADI);
  SentSpot.ShortCut := TextToShortCut(IniSet.KeySentSpot);
end;

procedure TMiniForm.FormCreate(Sender: TObject);
var
  Lang: string = '';
  FallbackLang: string = '';
begin
  MiniForm.Caption := rEWLogHAMJournal;
  showForm := False;
  Shape1.Visible := False;
  LBQSL.Visible := False;
  LBWorked.Visible := False;
  LBCfm.Visible := False;
  CloseApp := False;
  UnUsIndex := 0;
  DateEdit1.Date := LazSysUtils.NowUTC;
  DateTimePicker1.Time := NowUTC;
  LBLocalTimeD.Caption := FormatDateTime('hh:mm:ss', Now);
  LBUTCTimeD.Caption := FormatDateTime('hh:mm:ss', NowUTC);
  LoadComboBoxItem;

//  {$IFDEF WINDOWS}
//  if IniSet.WinDarkMode = 2 then
//    uMetaDarkStyle.ApplyMetaDarkStyle(DefaultDark);
//  SetColorsScheme(DefaultDark);
//  MetaDarkFormChanged(self);
//  Invalidate;
//  {$ENDIF}

  GetLanguageIDs(Lang, FallbackLang);

  if IniSet.Language = '' then
    IniSet.Language := FallbackLang;
  SetDefaultLang(IniSet.Language, FilePATH + 'locale');
  MITelnetForm.Checked := IniSet.cShow;
  MiLogbookForm.Checked := IniSet.gShow;
  MIMapForm.Checked := IniSet.eShow;
  MIPhoto.Checked := IniSet.pShow;
  MenuItem85.Checked := IniSet.trxShow;
  MiMainTop.Checked := IniSet.mTop;
  miMapTop.Checked := IniSet.eTop;
  MIClusterTop.Checked := IniSet.cTop;
  MiLogGridTop.Checked := IniSet.gTop;
  MiPhotoTop.Checked := IniSet.pTop;
  if IniSet.pShow then
  begin
    MenuItem111.Checked := IniSet.pShow;
    MiPhotoSeparate.Checked := IniSet.pSeparate;
    MiPhotoSeparateTop.Checked := IniSet.pTop;
  end
  else
  begin
    MenuItem112.Checked := True;
    MiPhotoSeparate.Checked := False;
    MiPhotoSeparateTop.Checked := False;
  end;

  if IniSet.MainForm <> 'MULTI' then
    MenuItem73.Checked := True
  else
    MIMMode.Checked := True;

  SetHotKey;

  MainFunc.StartRadio(IniSet.CurrentRIG);
end;

procedure TMiniForm.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (ssAlt in Shift) and (chr(Key) = 'H') then
    hiddenSettings.Show;
end;

procedure TMiniForm.TMTimeTimer(Sender: TObject);
begin
  LBLocalTimeD.Caption := FormatDateTime('hh:mm:ss', Now);
  {$IFDEF LINUX}
  LBUTCTimeD.Caption := FormatDateTime('hh:mm', NowUTC);
  LBRemoteTimeD.Caption := FormatDateTime('hh:mm', NowUTC + TimeDIF / 24);
  {$ENDIF LINUX}
  {$IFDEF WINDOWS}
  LBUTCTimeD.Caption := FormatDateTime('hh:mm:ss', NowUTC);
  LBRemoteTimeD.Caption := FormatDateTime('hh:mm:ss', NowUTC + TimeDIF / 24);
  {$ENDIF WINDOWS}
  {$IFDEF DARWIN}
  LBUTCTimeD.Caption := FormatDateTime('hh:mm', NowUTC);
  LBRemoteTimeD.Caption := FormatDateTime('hh:mm', NowUTC + TimeDIF / 24);
  {$ENDIF DARWIN}
  if CBRealTime.Checked then
  begin
    DateTimePicker1.DateTime := NowUTC;
    DateEdit1.Date := NowUTC;
  end;
end;

initialization
PreferredAppMode:=pamForceDark;
uMetaDarkStyle.ApplyMetaDarkStyle(DefaultDark);

end.
