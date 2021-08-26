(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit UpdateForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls,{$IFDEF WINDOWS} Windows,{$ENDIF WINDOWS} fphttpclient,
  synautil, ResourceStr, const_u, StreamAdapter_u, DownloadFilesThread;

const
  {$IFDEF WIN64}
  type_os = 'Windows x64';
  {$ENDIF WIN64}
  {$IFDEF WIN32}
  type_os = 'Windows x86';
  {$ENDIF WIN32}
  {$IFDEF LINUX}
  type_os = 'Linux';
  {$ENDIF LINUX}
  {$IFDEF DARWIN}
  type_os = 'MacOS';
  {$ENDIF DARWIN}


type

  { TUpdate_Form }

  TUpdate_Form = class(TForm)
    BtCheck: TButton;
    BtCancel: TButton;
    GBUpdate: TGroupBox;
    LBVersionStatus: TLabel;
    LBFileSize: TLabel;
    LBCurrVersionStatus: TLabel;
    LBLastCheck: TLabel;
    LBCurrLastCheck: TLabel;
    LBProgramVersion: TLabel;
    LBCurrProgramVersion: TLabel;
    LBServerVersion: TLabel;
    LBCurrServerVersion: TLabel;
    LBUpdateProcess: TLabel;
    PBDownload: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtCheckClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
  private
    updatePATH: string;
    procedure DownloadUpdateFile;
    procedure DownloadChangeLOGFile;
    function CheckVersion(ServerVersion: string): boolean;
    { private declarations }
  public
    procedure CheckServerVersionFile;
    procedure DataFromDownloadThread(status: TdataThread);
    { public declarations }
  end;

var
  Update_Form: TUpdate_Form;


implementation

uses
  Changelog_Form_U, dmFunc_U, InitDB_dm, miniform_u, MainFuncDM;

{$R *.lfm}

{ TUpdate_Form }

procedure TUpdate_Form.DataFromDownloadThread(status: TdataThread);
begin
  if status.ShowStatus then
  begin
    PBDownload.Position := status.DownloadedPercent;
    if (status.StatusDownload) and (status.Other = 'DownloadUpdateFile') then
      DownloadChangeLOGFile;
    if (status.StatusDownload) and (status.Other = 'DownloadChangeLOGFile') then
    begin
      Changelog_Form.MChangeLog.Lines.LoadFromFile(updatePATH + 'changelog.txt');
      Changelog_Form.Show;
      LBUpdateProcess.Caption := rUpdateStatusRequiredInstall;
      BtCheck.Enabled := True;
      BtCheck.Caption := rButtonInstall;
    end;
  end;

  if (status.Version) and (status.Message <> '') then
    CheckVersion(status.Message);
end;

procedure TUpdate_Form.FormCreate(Sender: TObject);
begin
  updatePATH := FilePATH + 'updates' + DirectorySeparator;
  if not DirectoryExists(updatePATH) then
    CreateDir(updatePATH);
end;

procedure TUpdate_Form.FormShow(Sender: TObject);
begin
  BtCheck.Caption := rButtonCheck;
  LBFileSize.Caption := rSizeFile;
  LBUpdateProcess.Caption := rUpdateStatus;
  LBCurrProgramVersion.Caption := dmFunc.GetMyVersion;
  PBDownload.Position := 0;
end;

function TUpdate_Form.CheckVersion(ServerVersion: string): boolean;
begin
  Result := False;
  LBUpdateProcess.Caption := rUpdateStatusActual;
  LBCurrServerVersion.Caption := ServerVersion;
  MiniForm.TextSB('', 0);
  if MainFunc.CompareVersion(dmFunc.GetMyVersion, ServerVersion) then
  begin
    LBCurrServerVersion.Caption := ServerVersion;
    LBCurrVersionStatus.Caption := rUpdateRequired;
    MiniForm.TextSB(rUpdateRequired, 0);
    Result := True;
    LBUpdateProcess.Caption := rUpdateStatusDownload;
    BtCheck.Caption := rButtonDownload;
    if dmFunc.GetSize(DownPATHssl + DownEXE) = -1 then
      LBFileSize.Caption := rSizeFile + FormatFloat('0.##',
        dmFunc.GetSize(DownPATH + DownEXE) / 1048576) + ' ' + rMBytes
    else
      LBFileSize.Caption := rSizeFile + FormatFloat('0.##',
        dmFunc.GetSize(DownPATHssl + DownEXE) / 1048576) + ' ' + rMBytes;
  end;
end;

procedure TUpdate_Form.CheckServerVersionFile;
const
  fileName = 'version';
begin
  DownloadFilesTThread := TDownloadFilesThread.Create;
  if Assigned(DownloadFilesTThread.FatalException) then
    raise DownloadFilesTThread.FatalException;
  with DownloadFilesTThread do
  begin
    DataFromForm.FromForm := 'UpdateForm';
    DataFromForm.Version := True;
    DataFromForm.URLDownload := DownPATHssl + fileName;
    Start;
  end;
end;

procedure TUpdate_Form.DownloadUpdateFile;
var
  DownFile: string;
begin
  BtCheck.Enabled := False;
  {$IFDEF WINDOWS}
  if dmFunc.GetWindowsVersion = 'Windows XP' then
    DownFile := DownEXEXP
  else
  {$ENDIF WINDOWS}
    DownFile := DownEXE;

  DownloadFilesTThread := TDownloadFilesThread.Create;
  if Assigned(DownloadFilesTThread.FatalException) then
    raise DownloadFilesTThread.FatalException;
  with DownloadFilesTThread do
  begin
    DataFromForm.FromForm := 'UpdateForm';
    DataFromForm.PathSaveFile := updatePATH + DownFile;
    DataFromForm.URLDownload := DownPATHssl + DownFile;
    DataFromForm.Other := 'DownloadUpdateFile';
    DataFromForm.ShowStatus := True;
    Start;
  end;
end;

procedure TUpdate_Form.DownloadChangeLOGFile;
const
  fileName = 'changelog.txt';
begin
  DownloadFilesTThread := TDownloadFilesThread.Create;
  if Assigned(DownloadFilesTThread.FatalException) then
    raise DownloadFilesTThread.FatalException;
  with DownloadFilesTThread do
  begin
    DataFromForm.FromForm := 'UpdateForm';
    DataFromForm.PathSaveFile := updatePATH + fileName;
    DataFromForm.URLDownload := DownPATHssl + fileName;
    DataFromForm.ShowStatus := True;
    DataFromForm.Other := 'DownloadChangeLOGFile';
    Start;
  end;
end;

procedure TUpdate_Form.BtCancelClick(Sender: TObject);
begin
  Update_Form.Close;
end;

procedure TUpdate_Form.BtCheckClick(Sender: TObject);
var
  DownFile: string;
begin
  if BtCheck.Caption = rButtonCheck then
    CheckServerVersionFile
  else
  if BtCheck.Caption = rButtonInstall then
  begin
    {$IFDEF WINDOWS}
    if dmFunc.GetWindowsVersion = 'Windows XP' then
      DownFile := DownEXEXP
    else
      DownFile := DownEXE;
    dmFunc.RunProgram(updatePATH + DownFile, '');
    {$ELSE}
    ShowMessage(rOnlyWindows);
    {$ENDIF WINDOWS}
  end
  else
    DownloadUpdateFile;
end;

end.
