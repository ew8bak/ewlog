(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit sendtelnetspot_form_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, const_u,
  LCLType, InitDB_dm;

resourcestring
  rNotAllData = 'Not all data entered';

type

  { TSendTelnetSpot }

  TSendTelnetSpot = class(TForm)
    BtSend: TButton;
    CBFreq: TComboBox;
    CBComment: TComboBox;
    EditDXCall: TEdit;
    LBCallsign: TLabel;
    LBFreq: TLabel;
    LBComment: TLabel;
    procedure BtSendClick(Sender: TObject);
    procedure CBCommentChange(Sender: TObject);
    procedure CBCommentKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure EditDXCallChange(Sender: TObject);
    procedure EditDXCallKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    SelEditNumChar: integer;
    oldComments: array of string;
    procedure LoadOldComments;
    { private declarations }
  public
    { public declarations }
  end;

var
  SendTelnetSpot: TSendTelnetSpot;

implementation

uses
  miniform_u, dmFunc_U, dxclusterform_u;

{$R *.lfm}

{ TSendTelnetSpot }

procedure TSendTelnetSpot.LoadOldComments;
var
  i: integer;
  StringList: TStringList;
begin
  try
    StringList := TStringList.Create;
    for i := 0 to 9 do
      StringList.Add(INIFile.ReadString('Cluster', 'Comment' + IntToStr(i), ''));
  finally
    for i := 0 to 9 do
    begin
      if StringList.Strings[i] <> '' then
        CBComment.Items.Add(StringList.Strings[i]);
    end;
    if CBComment.Items.Count > 0 then
      CBComment.ItemIndex := 0;
    FreeAndNil(StringList);
  end;
end;

procedure TSendTelnetSpot.FormShow(Sender: TObject);
begin
  if Pos('M', MiniForm.CBBand.Text) > 0 then
    CBFreq.Text := FormatFloat(view_freq, dmFunc.GetFreqFromBand(
      MiniForm.CBBand.Text, MiniForm.CBMode.Text))
  else
    CBFreq.Text := MiniForm.CBBand.Text;
  EditDXCall.Text := MiniForm.EditCallsign.Text;
  LoadOldComments;
end;

procedure TSendTelnetSpot.BtSendClick(Sender: TObject);
var
  freq, call, comment: string;
  freq2: double;
begin
  if (EditDXCall.Text <> '') and (CBComment.Text <> '') and (CBFreq.Text <> '') then
  begin
    call := EditDXCall.Text;
    freq := CBFreq.Text;
    comment := CBComment.Text;
    Delete(freq, length(freq) - 2, 1);
    freq2 := StrToFloat(freq);
    dxClusterForm.SendSpot(FloatToStr(freq2 * 1000), call, comment, '', '', '');
    SendTelnetSpot.Close;
  end
  else
    ShowMessage(rNotAllData);
end;

procedure TSendTelnetSpot.CBCommentChange(Sender: TObject);
var
  engText: string;
begin
  CBComment.SelStart := SelEditNumChar;
  engText := dmFunc.RusToEng(CBComment.Text);
  if (engText <> CBComment.Text) then
  begin
    CBComment.Text := engText;
    exit;
  end;
end;

procedure TSendTelnetSpot.CBCommentKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  SelEditNumChar := CBComment.SelStart + 1;
  if (Key = VK_BACK) then
    SelEditNumChar := CBComment.SelStart - 1;
  if (Key = VK_DELETE) then
    SelEditNumChar := CBComment.SelStart;
  if (CBComment.SelLength <> 0) and (Key = VK_BACK) then
    SelEditNumChar := CBComment.SelStart;
end;

procedure TSendTelnetSpot.EditDXCallChange(Sender: TObject);
var
  editButtonLeng: integer;
  engText: string;
begin
  editButtonLeng := Length(EditDXCall.Text);
  EditDXCall.SelStart := SelEditNumChar;
  engText := dmFunc.RusToEng(EditDXCall.Text);
  if (engText <> EditDXCall.Text) then
  begin
    EditDXCall.Text := engText;
    exit;
  end;
end;

procedure TSendTelnetSpot.EditDXCallKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  SelEditNumChar := EditDXCall.SelStart + 1;
  if (Key = VK_BACK) then
    SelEditNumChar := EditDXCall.SelStart - 1;
  if (Key = VK_DELETE) then
    SelEditNumChar := EditDXCall.SelStart;
  if (EditDXCall.SelLength <> 0) and (Key = VK_BACK) then
    SelEditNumChar := EditDXCall.SelStart;
end;

end.
