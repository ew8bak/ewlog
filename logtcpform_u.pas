unit logtcpform_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TLogTCP_Form }

  TLogTCP_Form = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
  private

  public

  end;

var
  LogTCP_Form: TLogTCP_Form;

implementation
 uses mainform_u;
{$R *.lfm}

end.

