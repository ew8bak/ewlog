(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit contestForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  LCLType, ExtCtrls, ComCtrls, dmContest_u, MainFuncDM, LCLProc, qso_record,
  LazSysUtils, const_u, infoDM_U, inform_record;

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
    EditQTH: TEdit;
    EditGrid: TEdit;
    EditState: TEdit;
    EditComment: TEdit;
    EditName: TEdit;
    EditExchr: TEdit;
    EditRSTr: TEdit;
    EditExchs: TEdit;
    EditCallsign: TEdit;
    EditRSTs: TEdit;
    EditFreq: TEdit;
    LBQTH: TLabel;
    LBGrid: TLabel;
    LBState: TLabel;
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
    procedure CBBandChange(Sender: TObject);
    procedure CBContestNameChange(Sender: TObject);
    procedure EditCallsignChange(Sender: TObject);
    procedure EditCallsignEditingDone(Sender: TObject);
    procedure EditCallsignKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditCallsignKeyPress(Sender: TObject; var Key: char);
    procedure EditExchrKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RBOtherClick(Sender: TObject);
    procedure RBSerialClick(Sender: TObject);
    procedure TTimeTimer(Sender: TObject);
  private
    SelEditNumChar: integer;
    function AddZero(number: integer): string;

  public
    procedure LoadFromInternetCallBook(info: TInformRecord);

  end;

var
  ContestForm: TContestForm;

implementation

uses dmFunc_U, InitDB_dm, miniform_u;

{$R *.lfm}

{ TContestForm }

procedure TContestForm.LoadFromInternetCallBook(info: TInformRecord);
begin
  if Length(info.Name) > 0 then
  begin
    EditName.Text := info.Name;
    EditQTH.Text := info.City;
    EditGrid.Text := info.Grid;
    EditState.Text := info.State;
  end;
  if Length(info.Error) > 0 then
    SBContest.Panels[0].Text := info.Error
  else
    SBContest.Panels[0].Text := '';
end;

function TContestForm.AddZero(number: integer): string;
begin
  if (Length(IntToStr(number)) > 0) and (Length(IntToStr(number)) <= 1) then
  begin
    Result := '00' + IntToStr(number);
    Exit;
  end;

  if (Length(IntToStr(number)) > 1) and (Length(IntToStr(number)) <= 2) then
  begin
    Result := '0' + IntToStr(number);
    Exit;
  end;

  if Length(IntToStr(number)) > 2 then
  begin
    Result := IntToStr(number);
    Exit;
  end;
end;

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

procedure TContestForm.EditCallsignEditingDone(Sender: TObject);
begin
  InfoDM.GetInformation(dmFunc.ExtractCallsign(EditCallsign.Text), 'ContestForm');
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
    SaveQSOrec.QSOBand := FormatFloat(view_freq, StrToFloat(EditFreq.Text));
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
    EditExchs.Text := AddZero(IniSet.ContestLastNumber);
    //IntToStr(IniSet.ContestLastNumber);
    INIFile.WriteInteger('Contest', 'ContestLastNumber', IniSet.ContestLastNumber);
    INIFile.WriteString('Contest', 'ContestName', IniSet.ContestName);

    EditCallsign.Clear;
    EditExchr.Clear;
    EditName.Clear;
    EditQTH.Clear;
    EditGrid.Clear;
    EditState.Clear;
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
  EditExchs.Text := AddZero(IniSet.ContestLastNumber);
  // IntToStr(IniSet.ContestLastNumber);
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

procedure TContestForm.CBBandChange(Sender: TObject);
begin
  if FMS.Freq = 0 then
  begin
    EditFreq.Text := FloatToStr(dmFunc.GetFreqFromBand(CBBand.Text, CBMode.Text));
  end;
end;

procedure TContestForm.CBContestNameChange(Sender: TObject);
begin
  IniSet.ContestName := CBContestName.Text;
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

procedure TContestForm.FormCreate(Sender: TObject);
begin
  dmContest.LoadBands(CBMode.Text, CBBand);
end;

procedure TContestForm.FormShow(Sender: TObject);
begin
  if RBSerial.Checked then
  begin
    EditExchr.NumbersOnly := True;
    EditExchs.NumbersOnly := True;
  end;
  dmContest.LoadContestName(CBContestName);
  EditExchs.Text := AddZero(IniSet.ContestLastNumber);
  // IntToStr(IniSet.ContestLastNumber);
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
  CBMode.Text := FMS.Mode;
  CBSubMode.Text := FMS.SubMode;
  if FMS.Freq <> 0 then
  begin
    CBBand.Text := dmFunc.GetBandFromFreq(IntToStr(FMS.Freq));
    EditFreq.Text := IntToStr(FMS.Freq);
  end;
end;

end.
