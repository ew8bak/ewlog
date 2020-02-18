unit AboutForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TAbout_Form }

  TAbout_Form = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public

    { public declarations }
  end;

var
  About_Form: TAbout_Form;

implementation
uses
  dmFunc_U;

{$R *.lfm}

{ TAbout_Form }

procedure TAbout_Form.FormShow(Sender: TObject);
begin
  Label5.Caption := dmFunc.GetMyVersion;
end;

end.
