unit miniform_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  EditBtn, Buttons, ComCtrls, DateTimePicker, LazSysUtils;

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
    TMTime: TTimer;
    TTLocalTimeLabel: TLabel;
    TTUTCLabel: TLabel;
    RemoteTimeLabel: TLabel;
    TTRemoteLabel: TLabel;
    UTCLabel: TLabel;
    LocalTimeLabel: TLabel;
    Panel1: TPanel;
    procedure FormShow(Sender: TObject);
    procedure TMTimeTimer(Sender: TObject);
  private

  public

  end;

var
  MiniForm: TMiniForm;
  TimeDIF: Integer;

implementation

uses MainFuncDM;

{$R *.lfm}

{ TMiniForm }

procedure TMiniForm.FormShow(Sender: TObject);
begin
  IniSet.CurrentForm := 'MINI';
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
