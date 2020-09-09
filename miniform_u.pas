unit miniform_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  EditBtn, Buttons, ComCtrls, DateTimePicker, LazSysUtils, foundQSO_record,
  prefix_record, LCLType;

type

  { TMiniForm }

  TMiniForm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
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
    DateEdit1: TDateEdit;
    DateTimePicker1: TDateTimePicker;
    CBMyGrid: TEdit;
    CBMyState: TEdit;
    EditState1: TEdit;
    EditComment: TEdit;
    EditState4: TEdit;
    EditState3: TEdit;
    EditState2: TEdit;
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
    LBSubState: TLabel;
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
    SBSave: TSpeedButton;
    SBNew: TSpeedButton;
    SBState: TSpeedButton;
    SBIOTA: TSpeedButton;
    SBMGR: TSpeedButton;
    SBState4: TSpeedButton;
    SBState3: TSpeedButton;
    SBState2: TSpeedButton;
    SBState1: TSpeedButton;
    SBCopy: TSpeedButton;
    SBInfo: TSpeedButton;
    Shape1: TShape;
    TMTime: TTimer;
    TTLocalTimeLabel: TLabel;
    TTUTCLabel: TLabel;
    RemoteTimeLabel: TLabel;
    TTRemoteLabel: TLabel;
    UTCLabel: TLabel;
    LocalTimeLabel: TLabel;
    Panel1: TPanel;
    procedure EditCallsignButtonClick(Sender: TObject);
    procedure EditCallsignChange(Sender: TObject);
    procedure EditCallsignKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure TMTimeTimer(Sender: TObject);
  private
    SelEditNumChar: integer;

  public

  end;

var
  MiniForm: TMiniForm;
  TimeDIF: integer;

implementation

uses MainFuncDM, InitDB_dm, dmFunc_U, infoDM_U, Earth_Form_U;

{$R *.lfm}

{ TMiniForm }

procedure TMiniForm.FormShow(Sender: TObject);
begin
  IniSet.CurrentForm := 'MINI';
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

//  if EditFlag then
//    Exit;

  if CBFilter.Checked then
  begin
    MainFunc.FilterQSO('Call', editButtonText + '%');
    Exit;
  end;

  if editButtonText = '' then
  begin
    //Clr;

    LBAzimuthD.Caption := '.......';
    LBDistanceD.Caption := '.......';
    LBLatitudeD.Caption := '.......';
    LBLongitudeD.Caption := '.......';
    LBTerritoryD.Caption := '.......';
    LBCont.Caption := '.......';
    LBDXCCD.Caption := '.......';
    LBPrefixD.Caption := '..';
    LBCQD.Caption := '..';
    LBITUD.Caption := '.......';
    Earth.PaintLine(FloatToStr(LBRecord.OpLat), FloatToStr(LBRecord.OpLon),
      LBRecord.OpLat, LBRecord.OpLon);
    Earth.PaintLine(FloatToStr(LBRecord.OpLat), FloatToStr(LBRecord.OpLon),
      LBRecord.OpLat, LBRecord.OpLon);
    Exit;
  end;

  if editButtonLeng > 1 then
  begin
    MainFunc.CheckDXCC(editButtonText, CBMode.Text, CBBand.Text,
      DMode, DBand, DCall);
    QSL := MainFunc.CheckQSL(editButtonText, CBBand.Text, CBMode.Text);
    LBWorked.Visible := MainFunc.FindWorkedCall(editButtonText,
      CBBand.Text, CBMode.Text);
    LBQSL.Visible := MainFunc.WorkedQSL(editButtonText, CBBand.Text,
      CBMode.Text);
    LBCfm.Visible := MainFunc.WorkedLoTW(editButtonText, CBBand.Text,
      CBMode.Text);
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

  if (editButtonLeng > 0) and (editButtonLeng < 5) then
  begin
    PFXR := MainFunc.SearchPrefix(editButtonText, EditMGR.Text);
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
  Earth.PaintLine(Lat, Lon, LBRecord.OpLat, LBRecord.OpLon);
  //MapView
  // if PFXR.Found and CBMap.Checked then
 //   MainFunc.LoadMaps(Lat, Lon, MapView1);

  FoundQSOR := MainFunc.FindQSO(dmfunc.ExtractCallsign(editButtonText));
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

  if FoundQSOR.Found then
    EditCallsign.Color := clMoneyGreen
  else
    EditCallsign.Color := clDefault;

  if not FoundQSOR.Found and IniSet.UseIntCallBook then
  begin
    FoundQSOR := MainFunc.FindInCallBook(dmfunc.ExtractCallsign(editButtonText));
    EditName.Text := FoundQSOR.OMName;
    EditQTH.Text := FoundQSOR.OMQTH;
    EditGrid.Text := FoundQSOR.Grid;
    EditState.Text := FoundQSOR.State;
    EditMGR.Text := FoundQSOR.QSLManager;
  end;
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
  if (Key = VK_RETURN) then
    InfoDM.GetInformation(dmFunc.ExtractCallsign(EditCallsign.Text), 'MainForm');
end;

procedure TMiniForm.TMTimeTimer(Sender: TObject);
begin
  TTLocalTimeLabel.Caption := FormatDateTime('hh:mm:ss', Now);
  TTUTCLabel.Caption := FormatDateTime('hh:mm:ss', NowUTC);
  TTRemoteLabel.Caption := FormatDateTime('hh:mm:ss', NowUTC + TimeDIF / 24);
  if CBRealTime.Checked then
  begin
    DateTimePicker1.Time := NowUTC;
    DateEdit1.Date := NowUTC;
  end;
end;

end.
