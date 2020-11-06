unit viewPhoto_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, LCLType, ResourceStr;

type

  { TviewPhoto }

  TviewPhoto = class(TForm)
    ImPhoto: TImage;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private

  public
    procedure SavePosition;

  end;

var
  viewPhoto: TviewPhoto;

implementation

uses MainForm_U, InitDB_dm, MainFuncDM, miniform_u;

{$R *.lfm}

{ TviewPhoto }

procedure TviewPhoto.SavePosition;
begin
  if (((IniSet.MainForm = 'MULTI') or IniSet.pSeparate)) and IniSet.pShow then
    if viewPhoto.WindowState <> wsMaximized then
    begin
      INIFile.WriteInteger('SetLog', 'pLeft', viewPhoto.Left);
      INIFile.WriteInteger('SetLog', 'pTop', viewPhoto.Top);
      INIFile.WriteInteger('SetLog', 'pWidth', viewPhoto.Width);
      INIFile.WriteInteger('SetLog', 'pHeight', viewPhoto.Height);
    end;
end;

procedure TviewPhoto.FormShow(Sender: TObject);
begin
  if (IniSet.MainForm = 'MULTI') or IniSet.pSeparate then
    if (IniSet._l_p <> 0) and (IniSet._t_p <> 0) and (IniSet._w_p <> 0) and
      (IniSet._h_p <> 0) then
      viewPhoto.SetBounds(IniSet._l_p, IniSet._t_p, IniSet._w_p, IniSet._h_p);
  ImPhoto.Picture.LoadFromLazarusResource('no-photo');
end;

procedure TviewPhoto.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Application.MessageBox(PChar(rShowNextStart), PChar(rWarning),
    MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
    INIFile.WriteBool('SetLog', 'pShow', True)
  else
    INIFile.WriteBool('SetLog', 'pShow', False);
  SavePosition;
  IniSet.pShow := False;
  MiniForm.CheckFormMenu('viewPhoto', False);
  CloseAction := caHide;
end;

end.
