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
  private
    { private declarations }
  public

    { public declarations }
  end;

var
  About_Form: TAbout_Form;

implementation

{$R *.lfm}

{ TAbout_Form }


end.

