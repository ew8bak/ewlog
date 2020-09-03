unit miniform_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs;

type

  { TMiniForm }

  TMiniForm = class(TForm)
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  MiniForm: TMiniForm;

implementation
uses MainFuncDM;

{$R *.lfm}

{ TMiniForm }

procedure TMiniForm.FormShow(Sender: TObject);
begin
  IniSet.CurrentForm:='MINI';
end;

end.

