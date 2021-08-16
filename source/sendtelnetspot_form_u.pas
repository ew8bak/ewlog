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
    procedure BtSendKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CBCommentChange(Sender: TObject);
    procedure CBCommentKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure CBFreqSelect(Sender: TObject);
    procedure EditDXCallChange(Sender: TObject);
    procedure EditDXCallKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    SelEditNumChar: integer;
    SLComments: TStringList;
    procedure LoadComments;
    procedure SaveComments;
    { private declarations }
  public
    { public declarations }
  end;

var
  SendTelnetSpot: TSendTelnetSpot;

implementation

uses
  miniform_u, dmFunc_U, dxclusterform_u, MainFuncDM;

{$R *.lfm}

{ TSendTelnetSpot }

procedure TSendTelnetSpot.LoadComments;
var
  i: integer;
  LastComment: string;
begin
  CBComment.Items.Clear;
  SLComments.Clear;
  for i := 0 to 9 do
    if INIFile.ReadString('Cluster', 'Comment' + IntToStr(i), '') <> '' then
      SLComments.Add(INIFile.ReadString('Cluster', 'Comment' + IntToStr(i), ''));
  LastComment := INIFile.ReadString('Cluster', 'CommentLast', 'TNX for QSO! 73!');
  SLComments.Insert(0, LastComment);
  for i := 0 to SLComments.Count - 1 do
    CBComment.Items.Add(SLComments.Strings[i]);
  CBComment.ItemIndex := CBComment.Items.IndexOf(LastComment);
end;

procedure TSendTelnetSpot.SaveComments;
var
  i: integer;
begin
  INIFile.WriteString('Cluster', 'CommentLast', CBComment.Text);
  if CBComment.Items.IndexOf(CBComment.Text) = -1 then
  begin
    SLComments.Insert(0, CBComment.Text);
    if SLComments.Count > 10 then
      SLComments.Delete(SLComments.Count - 1);
    CBComment.Items.Clear;
    for i := 0 to SLComments.Count - 1 do begin
      INIFile.WriteString('Cluster', 'Comment' + IntToStr(i), SLComments.Strings[i]);
      CBComment.Items.Add(SLComments.Strings[i]);
    end;
  end;
end;

procedure TSendTelnetSpot.FormShow(Sender: TObject);
var
  i : integer;
begin
  CBFreq.Items.Clear;
  for i := 0 to High(MainFunc.LoadBands('')) do
    CBFreq.Items.Add(MainFunc.LoadBands('')[i]);
  CBFreq.Text := MainFunc.ConvertFreqToShow(MiniForm.CBBand.Text);
  EditDXCall.Text := MiniForm.EditCallsign.Text;
  LoadComments;
end;

procedure TSendTelnetSpot.BtSendClick(Sender: TObject);
var
  freq, call, comment: string;
  freq2: double;
begin
  SaveComments;
  if (EditDXCall.Text <> '') and (CBComment.Text <> '') and (CBFreq.Text <> '') then
  begin
    call := EditDXCall.Text;
    freq := CBFreq.Text;
    comment := CBComment.Text;
    freq := MainFunc.ConvertFreqToSave(freq);
    Delete(freq, length(freq) - 2, 1);
    TryStrToFloatSafe(freq, freq2);
    dxClusterForm.SendSpot(FloatToStr(freq2 * 1000), call, comment, '', '', '');
    SendTelnetSpot.Close;
  end
  else
    ShowMessage(rNotAllData);
end;

procedure TSendTelnetSpot.BtSendKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (Key = VK_RETURN) then
    BtSendClick(Self);
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
    CBComment.SelStart := SelEditNumChar;
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

procedure TSendTelnetSpot.CBFreqSelect(Sender: TObject);
begin
  CBFreq.Text := MainFunc.ConvertFreqToShow(CBFreq.Items.Strings[CBFreq.ItemIndex]);
end;

procedure TSendTelnetSpot.EditDXCallChange(Sender: TObject);
var
  engText: string;
begin
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

    if (Key = VK_RETURN) and (Length(EditDXCall.Text) > 1) then
      BtSend.SetFocus
end;

procedure TSendTelnetSpot.FormCreate(Sender: TObject);
begin
  SLComments := TStringList.Create;
end;

procedure TSendTelnetSpot.FormDestroy(Sender: TObject);
begin
  FreeAndNil(SLComments);
end;

end.
