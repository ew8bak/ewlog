unit contestForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn, LCLType;

type

  { TContestForm }

  TContestForm = class(TForm)
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
    TETime: TTimeEdit;
    procedure EditCallsignChange(Sender: TObject);
    procedure EditCallsignKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditCallsignKeyPress(Sender: TObject; var Key: char);
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

procedure TContestForm.EditCallsignKeyPress(Sender: TObject; var Key: char);
begin
  if Key = ' ' then
    Key := Chr(0);
end;

end.

