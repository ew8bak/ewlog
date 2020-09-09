unit miniform_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  EditBtn, Buttons, DateTimePicker;

type

  { TMiniForm }

  TMiniForm = class(TForm)
    Bevel1: TBevel;
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
    DateEdit1: TDateEdit;
    DateTimePicker1: TDateTimePicker;
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
    TTLocalTimeLabel: TLabel;
    TTUTCLabel: TLabel;
    RemoteTimeLabel: TLabel;
    TTRemoteLabel: TLabel;
    UTCLabel: TLabel;
    LocalTimeLabel: TLabel;
    Panel1: TPanel;
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  MiniForm: TMiniForm;

implementation
uses MainFuncDM;

{$R *.lfm}

{ TMiniForm }

procedure TMiniForm.FormShow(Sender: TObject);
begin
  IniSet.CurrentForm:='MINI';
end;

end.

