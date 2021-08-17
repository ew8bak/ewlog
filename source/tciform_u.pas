unit TCIForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  lclintf, StdCtrls;

type

  { TTCIForm }

  TTCIForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit3: TEdit;
    Edit4: TEdit;
    Memo1: TMemo;
  private

  public

  end;

var
  TCIForm: TTCIForm;

implementation

{$R *.lfm}

{ TTCIForm }

end.
