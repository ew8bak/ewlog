unit sendtelnetspot_form_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, const_u;

resourcestring
  rNotAllData = 'Not all data entered';

type

  { TSendTelnetSpot }

  TSendTelnetSpot = class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
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
  if (Edit1.Text <> '') and (Edit2.Text <> '') and (ComboBox1.Text <> '') then
  begin
    call := Edit1.Text;
    freq := ComboBox1.Text;
    comment := Edit2.Text;
    Delete(freq, length(freq) - 2, 1);
    freq2 := StrToFloat(freq);
    dxClusterForm.SendSpot(FloatToStr(freq2 * 1000), call, comment, '', '', '');
    SendTelnetSpot.Close;
  end
  else
    ShowMessage(rNotAllData);
end;

end.
