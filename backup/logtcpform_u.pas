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
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  LogTCP_Form: TLogTCP_Form;

implementation
 uses mainform_u;
{$R *.lfm}

{ TLogTCP_Form }

procedure TLogTCP_Form.Button1Click(Sender: TObject);
var
  i:integer;
begin
         LogTCP_Form.Label2.Caption :=
        'Принято строк:' + IntToStr(MainForm.AdifFromMobileString.Count);

      for i := 0 to MainForm.AdifFromMobileString.Count - 1 do
        LogTCP_Form.Memo2.Lines.add(MainForm.AdifFromMobileString[i]);
end;

end.

