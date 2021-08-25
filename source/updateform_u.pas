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
    procedure DownloadVersionFile;
    function CheckVersion: boolean;
  private
    updatePATH: string;
    procedure DownloadFile(OnProgress: TOnProgress);
    procedure DownloadChangeLOGFile(OnProgress: TOnProgress);
    procedure Progress(Sender: TObject; Percent: integer);

    { private declarations }
  public
    procedure DataFromDownloadThread(status: TdataThread);
    { public declarations }
  end;

var
  Update_Form: TUpdate_Form;


implementation

uses
  Changelog_Form_U, dmFunc_U, InitDB_dm, miniform_u;

{$R *.lfm}

{ TUpdate_Form }

procedure TUpdate_Form.DataFromDownloadThread(status: TdataThread);
begin

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

function TUpdate_Form.CheckVersion: boolean;
var
  version_curr: integer;
  version_serv: integer;
  version_servStr: string;
  version_file: TextFile;
  version_file_stream: TFileStream;
begin
  Result := False;
  try
    if not FileExists(updatePATH + 'version') then
    begin
      version_file_stream := TFileStream.Create(updatePATH + 'version', fmCreate);
      version_file_stream.Seek(0, soFromEnd);
      version_file_stream.WriteBuffer('1.1.1', Length('1.1.1'));
      version_file_stream.Free;
    end;

    version_curr := StrToInt(StringReplace(dmFunc.GetMyVersion, '.',
      '', [rfReplaceAll]));
    AssignFile(version_file, updatePATH + 'version');
    Reset(version_file);
    while not EOF(version_file) do
      ReadLn(version_file, version_servStr);
    if (version_servStr = '1.1.1') or (Pos('</html>', version_servStr) > 0) or
      (Pos('not found', version_servStr) > 0) then
    begin
      LBCurrServerVersion.Caption := rFailedToLoadData;
      Exit;
    end
    else
    begin
      LBCurrServerVersion.Caption := version_servStr;
      version_serv := StrToInt(StringReplace(version_servStr, '.', '', [rfReplaceAll]));
    end;

    if version_curr < version_serv then
    begin
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
    end
    else
    begin
      LBUpdateProcess.Caption := rUpdateStatusActual;
      MiniForm.TextSB('', 0);
      Result := False;
    end;

  finally;
    CloseFile(version_file);
  end;
end;

procedure TUpdate_Form.DownloadVersionFile;
const
  fileName = 'version';
begin
  DownloadFilesTThread := TDownloadFilesThread.Create;
  if Assigned(DownloadFilesTThread.FatalException) then
    raise DownloadFilesTThread.FatalException;
  with DownloadFilesTThread do
  begin
    DataFromForm.FromForm := 'UpdateForm';
    DataFromForm.Other := 'CheckVersion';
    DataFromForm.ShowStatus := False;
    DataFromForm.URLDownload := DownPATHssl + fileName;
    DataFromForm.PathSaveFile := updatePATH + fileName;
    Start;
  end;
end;

procedure TUpdate_Form.BtCancelClick(Sender: TObject);
begin
  Update_Form.Close;
end;

procedure TUpdate_Form.DownloadFile(OnProgress: TOnProgress);
var
  Stream: TStreamAdapter;
  HTTP: TFPHTTPClient;
  MaxSize: int64;
  DownFile: string;
begin
  BtCheck.Enabled := False;
  {$IFDEF WINDOWS}
  if dmFunc.GetWindowsVersion = 'Windows XP' then
    DownFile := DownEXEXP
  else
  {$ENDIF WINDOWS}
    DownFile := DownEXE;

  try
    HTTP := TFPHTTPClient.Create(nil);
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; ewlog)');

    if dmFunc.GetSize(DownPATHssl + DownFile) = -1 then
      MaxSize := dmFunc.GetSize(DownPATH + DownFile)
    else
      MaxSize := dmFunc.GetSize(DownPATHssl + DownFile);

    if MaxSize = -1 then
      exit;

    LBUpdateProcess.Caption := rUpdateStatusDownloads;
    Stream := TStreamAdapter.Create(TFileStream.Create(updatePATH +
      DownFile, fmCreate), MaxSize);
    Stream.OnProgress := OnProgress;
    HTTP.HTTPMethod('GET', DownPATHssl + DownFile, Stream, [200]);

  finally
    FreeAndNil(HTTP);
    FreeAndNil(Stream);
    DownloadChangeLOGFile(@Progress);
  end;
end;

procedure TUpdate_Form.DownloadChangeLOGFile(OnProgress: TOnProgress);
var
  HTTP: TFPHttpClient;
  Stream: TStreamAdapter;
  MaxSize: int64;
begin
  if dmFunc.GetSize(DownPATHssl + 'changelog.txt') = -1 then
    MaxSize := dmFunc.GetSize(DownPATH + 'changelog.txt')
  else
    MaxSize := dmFunc.GetSize(DownPATHssl + 'changelog.txt');

  if MaxSize = -1 then
    exit;

  LBUpdateProcess.Caption := rUpdateStatusDownloadChanges;
  try
    HTTP := TFPHttpClient.Create(nil);
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; ewlog)');
    Stream := TStreamAdapter.Create(TFileStream.Create(updatePATH +
      'changelog.txt', fmCreate), MaxSize);
    Stream.OnProgress := OnProgress;
    HTTP.HTTPMethod('GET', DownPATHssl + 'changelog.txt', Stream, [200]);

  finally
    FreeAndNil(HTTP);
    FreeAndNil(Stream);
    Changelog_Form.Memo1.Lines.LoadFromFile(updatePATH + 'changelog.txt');
    Changelog_Form.Show;
    LBUpdateProcess.Caption := rUpdateStatusRequiredInstall;
    BtCheck.Enabled := True;
    BtCheck.Caption := rButtonInstall;
  end;
end;

procedure TUpdate_Form.BtCheckClick(Sender: TObject);
var
  DownFile: string;
begin
  if BtCheck.Caption = rButtonCheck then
    DownloadVersionFile
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
    DownloadFile(@Progress);
end;

procedure TUpdate_Form.Progress(Sender: TObject; Percent: integer);
begin
  PBDownload.Position := Percent;
  PBDownload.Update;
  LBFileSize.Caption := IntToStr(Percent) + '%';
  Application.ProcessMessages;
end;

end.
