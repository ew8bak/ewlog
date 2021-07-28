(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

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
  MainFunc.SaveWindowPosition(viewPhoto);
end;

procedure TviewPhoto.FormShow(Sender: TObject);
begin
  MainFunc.LoadWindowPosition(viewPhoto);
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
