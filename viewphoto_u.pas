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

uses MainForm_U, InitDB_dm;

{$R *.lfm}

{ TviewPhoto }

procedure TviewPhoto.FormShow(Sender: TObject);
begin
  viewPhoto.Left := INIFile.ReadInteger('SetLog', 'PhotoFormLeft', 0);
  viewPhoto.Top := INIFile.ReadInteger('SetLog', 'PhotoFormTop', 0);
end;

procedure TviewPhoto.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  INIFile.WriteInteger('SetLog', 'PhotoFormLeft', viewPhoto.Left);
  INIFile.WriteInteger('SetLog', 'PhotoFormTop', viewPhoto.Top);
end;

end.
