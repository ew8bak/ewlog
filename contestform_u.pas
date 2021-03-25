unit contestForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  LCLType, ExtCtrls, ComCtrls;

type

  { TContestForm }

  TContestForm = class(TForm)
    BtSave: TButton;
    CBContestName: TComboBox;
    CBMode: TComboBox;
    CBBand: TComboBox;
    DEDate: TDateEdit;
    EditComment: TEdit;
    EditName: TEdit;
    EditExchr: TEdit;
    EditRSTr: TEdit;
    EditExchs: TEdit;
    EditCallsign: TEdit;
    EditRSTs: TEdit;
    EditFreq: TEdit;
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
    procedure BtSaveClick(Sender: TObject);
    procedure BtSaveKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure EditCallsignChange(Sender: TObject);
    procedure EditCallsignKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditCallsignKeyPress(Sender: TObject; var Key: char);
    procedure EditExchrKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure TTimeTimer(Sender: TObject);
  private
    SelEditNumChar: integer;

  public

  end;

var
  ContestForm: TContestForm;

implementation

uses dmFunc_U;

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
begin
  if Length(EditCallsign.Text) > 1 then
  begin
    SBContest.Panels[0].Text := 'Save ' + EditCallsign.Text + ' OK';
    EditCallsign.Clear;
  end
  else
    SBContest.Panels[0].Text := 'Nothing to save';
  EditCallsign.SetFocus;
end;

procedure TContestForm.BtSaveKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) then
    BtSaveClick(Self);
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
  EditCallsign.SetFocus;
end;

procedure TContestForm.TTimeTimer(Sender: TObject);
begin
  TETime.Time := Now;
  DEDate.Date := Now;
end;

end.
