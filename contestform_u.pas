unit contestForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  LCLType, ExtCtrls, ComCtrls, dmContest_u, MainFuncDM, LCLProc, qso_record,
  LazSysUtils;

type

  { TContestForm }

  TContestForm = class(TForm)
    BtSave: TButton;
    BtResetSession: TButton;
    CBContestName: TComboBox;
    CBMode: TComboBox;
    CBBand: TComboBox;
    CBSubMode: TComboBox;
    DEDate: TDateEdit;
    EditComment: TEdit;
    EditName: TEdit;
    EditExchr: TEdit;
    EditRSTr: TEdit;
    EditExchs: TEdit;
    EditCallsign: TEdit;
    EditRSTs: TEdit;
    EditFreq: TEdit;
    LBSubMode: TLabel;
    LBName: TLabel;
    LBComment: TLabel;
    LBExchs: TLabel;
    LBExchr: TLabel;
    LBRSTr: TLabel;
    LBRSTs: TLabel;
    LBCallsign: TLabel;
    LBFreq: TLabel;
    LBBand: TLabel;
    LBMode: TLabel;
    LBTime: TLabel;
    LBDate: TLabel;
    LBContestName: TLabel;
    LbExchangeType: TLabel;
    RBOther: TRadioButton;
    RBSerial: TRadioButton;
    SBContest: TStatusBar;
    TETime: TTimeEdit;
    TTime: TTimer;
    procedure BtResetSessionClick(Sender: TObject);
    procedure BtSaveClick(Sender: TObject);
    procedure BtSaveKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure CBContestNameChange(Sender: TObject);
    procedure CBModeCloseUp(Sender: TObject);
    procedure EditCallsignChange(Sender: TObject);
    procedure EditCallsignKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditCallsignKeyPress(Sender: TObject; var Key: char);
    procedure EditExchrKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure RBOtherClick(Sender: TObject);
    procedure RBSerialClick(Sender: TObject);
    procedure TTimeTimer(Sender: TObject);
  private
    SelEditNumChar: integer;

  public

  end;

var
  ContestForm: TContestForm;

implementation

uses dmFunc_U, InitDB_dm;

{$R *.lfm}

{ TContestForm }

procedure TContestForm.EditCallsignKeyDown(Sender: TObject; var Key: word;
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
  begin
    if Length(EditCallsign.Text) > 1 then
      EditExchr.SetFocus
    else
      SBContest.Panels[0].Text := 'Callsign not entered';
  end;
end;

procedure TContestForm.EditCallsignChange(Sender: TObject);
var
  engText: string;
begin
  EditCallsign.SelStart := SelEditNumChar;
  engText := dmFunc.RusToEng(EditCallsign.Text);
  if (engText <> EditCallsign.Text) then
  begin
    EditCallsign.Text := engText;
    exit;
  end;
end;

procedure TContestForm.BtSaveClick(Sender: TObject);
var
  SaveQSOrec: TQSO;
begin
  if Length(EditCallsign.Text) > 1 then
  begin
    SaveQSOrec.AwardsEx := dmContest.ContestNameToADIf(CBContestName.Text);
    SaveQSOrec.QSODate := DEDate.Date;
    SaveQSOrec.QSOTime := TimeToStr(TETime.Time);
    SaveQSOrec.QSOMode := CBMode.Text;
    SaveQSOrec.QSOSubMode := CBSubMode.Text;
    SaveQSOrec.QSOBand := CBBand.Text;
    SaveQSOrec.CallSing := EditCallsign.Text;
    SaveQSOrec.QSOReportSent := EditRSTs.Text;
    SaveQSOrec.QSOReportRecived := EditRSTr.Text;
    SaveQSOrec.OmName := EditName.Text;
    SaveQSOrec.ShortNote := EditComment.Text;

    if RBSerial.Checked then
    begin
      try
        SaveQSOrec.SRX := StrToInt(EditExchr.Text);
        SaveQSOrec.STX := StrToInt(EditExchs.Text);
      except
        SBContest.Panels[0].Text := 'ERROR Field not entered';
        EditExchr.SetFocus;
        Exit;
      end;
      SaveQSOrec.SRX_String := '';
      SaveQSOrec.STX_String := '';

    end
    else
    begin
      SaveQSOrec.SRX := 0;
      SaveQSOrec.STX := 0;
      SaveQSOrec.SRX_String := EditExchr.Text;
      SaveQSOrec.STX_String := EditExchs.Text;
    end;
    dmContest.SaveQSOContest(SaveQSOrec);
    SBContest.Panels[0].Text := 'Save ' + EditCallsign.Text + ' OK';
    Inc(IniSet.ContestLastNumber);
    EditExchs.Text := IntToStr(IniSet.ContestLastNumber);
    INIFile.WriteInteger('Contest', 'ContestLastNumber', IniSet.ContestLastNumber);
    INIFile.WriteString('Contest', 'ContestName', IniSet.ContestName);

    EditCallsign.Clear;
    EditExchr.Clear;
    EditName.Clear;
    EditComment.Clear;
  end
  else
    SBContest.Panels[0].Text := 'Nothing to save';
  EditCallsign.SetFocus;
end;

procedure TContestForm.BtResetSessionClick(Sender: TObject);
begin
  IniSet.ContestLastNumber := 1;
  INIFile.WriteInteger('Contest', 'ContestLastNumber', IniSet.ContestLastNumber);
  EditExchs.Text := IntToStr(IniSet.ContestLastNumber);
  CBContestName.ItemIndex := 0;
  IniSet.ContestName := CBContestName.Text;
  INIFile.WriteString('Contest', 'ContestName', IniSet.ContestName);
end;

procedure TContestForm.BtSaveKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) then
    BtSaveClick(Self);
end;

procedure TContestForm.CBContestNameChange(Sender: TObject);
begin
  IniSet.ContestName := CBContestName.Text;
end;

procedure TContestForm.CBModeCloseUp(Sender: TObject);
var
  i: integer;
begin
  CBSubMode.Items.Clear;
  for i := 0 to High(MainFunc.LoadSubModes(CBMode.Text)) do
    CBSubMode.Items.Add(MainFunc.LoadSubModes(CBMode.Text)[i]);

  if CBMode.Text <> 'SSB' then
    CBSubMode.Text := '';

  if StrToDouble(MainFunc.FormatFreq(CBBand.Text, CBMode.Text)) >= 10 then
    CBSubMode.ItemIndex := CBSubMode.Items.IndexOf('USB')
  else
    CBSubMode.ItemIndex := CBSubMode.Items.IndexOf('LSB');
end;

procedure TContestForm.EditCallsignKeyPress(Sender: TObject; var Key: char);
begin
  if Key = ' ' then
    Key := Chr(0);
end;

procedure TContestForm.EditExchrKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) then
    BtSave.SetFocus;
end;

procedure TContestForm.FormShow(Sender: TObject);
begin
  if RBSerial.Checked then
  begin
    EditExchr.NumbersOnly := True;
    EditExchs.NumbersOnly := True;
  end;
  dmContest.LoadContestName(CBContestName);
  MainFunc.LoadBMSL(CBMode, CBSubMode, CBBand);
  CBModeCloseUp(nil);
  EditExchs.Text := IntToStr(IniSet.ContestLastNumber);
  EditCallsign.SetFocus;
end;

procedure TContestForm.RBOtherClick(Sender: TObject);
begin
  if RBOther.Checked then
  begin
    EditExchr.NumbersOnly := False;
    EditExchs.NumbersOnly := False;
  end;
end;

procedure TContestForm.RBSerialClick(Sender: TObject);
begin
  if RBSerial.Checked then
  begin
    EditExchr.NumbersOnly := True;
    EditExchs.NumbersOnly := True;
  end;
end;

procedure TContestForm.TTimeTimer(Sender: TObject);
begin
  TETime.Time := NowUTC;
  DEDate.Date := NowUTC;
end;

end.
