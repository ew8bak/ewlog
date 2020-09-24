unit ThanksForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TThanks_Form }

  TThanks_Form = class(TForm)
    Bevel1: TBevel;
    Image1: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure Image1Click(Sender: TObject);
  private

  public

  end;

var
  Thanks_Form: TThanks_Form;

implementation

{$R *.lfm}

{ TThanks_Form }

procedure TThanks_Form.Image1Click(Sender: TObject);
begin

end;

end.

