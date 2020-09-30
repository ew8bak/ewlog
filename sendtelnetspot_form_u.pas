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
    Edit1: TEdit;
    EditComment: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure EditCommentChange(Sender: TObject);
    procedure EditCommentKeyDown(Sender: TObject; var Key: Word;
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
  Edit1.Text := MiniForm.EditCallsign.Text;
end;

procedure TSendTelnetSpot.Button1Click(Sender: TObject);
var
  freq, call, comment: string;
  freq2: double;
begin
  if (Edit1.Text <> '') and (EditComment.Text <> '') and (ComboBox1.Text <> '') then
  begin
    call := Edit1.Text;
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

procedure TSendTelnetSpot.EditCommentKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
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
