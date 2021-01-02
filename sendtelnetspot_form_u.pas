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
  LCLType;

resourcestring
  rNotAllData = 'Not all data entered';

type

  { TSendTelnetSpot }

  TSendTelnetSpot = class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    EditDXCall: TEdit;
    EditComment: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure EditDXCallChange(Sender: TObject);
    procedure EditDXCallKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure EditCommentChange(Sender: TObject);
    procedure EditCommentKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    SelEditNumChar: integer;
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

procedure TSendTelnetSpot.FormShow(Sender: TObject);
begin
  if Pos('M', MiniForm.CBBand.Text) > 0 then
    ComboBox1.Text := FormatFloat(view_freq, dmFunc.GetFreqFromBand(
      MiniForm.CBBand.Text, MiniForm.CBMode.Text))
  else
    ComboBox1.Text := MiniForm.CBBand.Text;
  EditDXCall.Text := MiniForm.EditCallsign.Text;
end;

procedure TSendTelnetSpot.Button1Click(Sender: TObject);
var
  freq, call, comment: string;
  freq2: double;
begin
  if (EditDXCall.Text <> '') and (EditComment.Text <> '') and (ComboBox1.Text <> '') then
  begin
    call := EditDXCall.Text;
    freq := ComboBox1.Text;
    comment := EditComment.Text;
    Delete(freq, length(freq) - 2, 1);
    freq2 := StrToFloat(freq);
    dxClusterForm.SendSpot(FloatToStr(freq2 * 1000), call, comment, '', '', '');
    SendTelnetSpot.Close;
  end
  else
    ShowMessage(rNotAllData);
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

procedure TSendTelnetSpot.EditCommentChange(Sender: TObject);
var
  engText: string;
begin
  EditComment.SelStart := SelEditNumChar;
  engText := dmFunc.RusToEng(EditComment.Text);
  if (engText <> EditComment.Text) then
  begin
    EditComment.Text := engText;
    exit;
  end;
end;

procedure TSendTelnetSpot.EditCommentKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  SelEditNumChar := EditComment.SelStart + 1;
  if (Key = VK_BACK) then
    SelEditNumChar := EditComment.SelStart - 1;
  if (Key = VK_DELETE) then
    SelEditNumChar := EditComment.SelStart;
  if (EditComment.SelLength <> 0) and (Key = VK_BACK) then
    SelEditNumChar := EditComment.SelStart;
end;

end.
