unit viewPhoto_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TviewPhoto }

  TviewPhoto = class(TForm)
    Image1: TImage;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  viewPhoto: TviewPhoto;

implementation

uses MainForm_U;

{$R *.lfm}

{ TviewPhoto }

procedure TviewPhoto.FormShow(Sender: TObject);
begin
  viewPhoto.Left := IniF.ReadInteger('SetLog', 'PhotoFormLeft', 0);
  viewPhoto.Top := IniF.ReadInteger('SetLog', 'PhotoFormTop', 0);
end;

procedure TviewPhoto.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IniF.WriteInteger('SetLog', 'PhotoFormLeft', viewPhoto.Left);
  IniF.WriteInteger('SetLog', 'PhotoFormTop', viewPhoto.Top);
end;

end.
