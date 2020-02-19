unit UpdateForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, LazUTF8, StdCtrls,
  ComCtrls,{$IFDEF WINDOWS} Windows, ShellApi,{$ENDIF WINDOWS} httpsend,
  blcksock, synautil, ResourceStr;

type

  { TUpdate_Form }

  TUpdate_Form = class(TForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ProgressBar1: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckUpdate;
    function CheckVersion: Boolean;
  private
    Download: int64;//счётчик закачанных данных
    updatePATH: string;

    procedure SynaProgress(Sender: TObject; Reason: THookSocketReason;
      const Value: string);
    procedure DownloadFile;
    procedure DownloadDBFile;
    procedure DownloadCallBookFile;
    procedure DownloadChangeLOGFile;
    {$IFDEF WINDOWS}
    function RunAsAdmin(const Handler: Hwnd; const Path, Params: string): boolean;
    {$ENDIF WINDOWS}
    { private declarations }
  public
    {$IFDEF WIN64}
  const
    DownPATH: string = 'http://update.ew8bak.ru/EWLog_x64.exe';
  {$ELSE}
  const
    DownPATH: string = 'http://update.ew8bak.ru/EWLog_x86.exe';
  {$ENDIF WIN64}
    { public declarations }
  end;

var
  Update_Form: TUpdate_Form;

type
  ver = record
    version, lastupdate, changelog: string[20];
  end;


implementation

uses
  Changelog_Form_U, MainForm_U, DownloadUpdates, dmFunc_U;

{$R *.lfm}

{ TUpdate_Form }

procedure TUpdate_Form.FormCreate(Sender: TObject);
var
  VerFile: file of ver;
  VerFiles: ver;
begin
  VerFiles.version:='0.0.0';
  VerFiles.lastupdate:=DateTimeToStr(Now);
  VerFiles.changelog:='';
    {$IFDEF UNIX}
  updatePATH := SysUtils.GetEnvironmentVariable('HOME') + '/EWLog/';
    {$ELSE}
  updatePATH := SysUtils.GetEnvironmentVariable('SystemDrive') +
   SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
    {$ENDIF UNIX}

  if DirectoryExists(updatePATH + 'updates') = False then
    CreateDir(updatePATH + 'updates');

  if FileExists(updatePATH + 'updates' + DirectorySeparator + 'version.info') = False then begin
   AssignFile(VerFile, updatePATH + 'updates' + DirectorySeparator + 'version.info');
   Rewrite(VerFile);
   Write(VerFile,VerFiles);
   CloseFile(VerFile);
  end;

  if FileExists(updatePATH + 'updates' + DirectorySeparator + 'versioncallbook.info') = False then begin
    AssignFile(VerFile, updatePATH + 'updates' + DirectorySeparator + 'versioncallbook.info');
    Rewrite(VerFile);
    Write(VerFile,VerFiles);
    CloseFile(VerFile);
  end;
end;

procedure TUpdate_Form.FormShow(Sender: TObject);
var
  VerFile: file of ver;
  VerFiles: ver;
begin
  if FileExists(updatePATH + 'updates'+DirectorySeparator+'version.info') then
  begin
    AssignFile(VerFile, updatePATH + 'updates'+DirectorySeparator+'version.info');
    Reset(VerFile);
    Read(VerFile, VerFiles);
    Label4.Caption := VerFiles.lastupdate;
    CloseFile(VerFile);
  end;

  Button1.Caption := rButtonCheck;
  Label10.Caption := rSizeFile;
  Label9.Caption := rUpdateStatus;
  Label6.Caption := dmFunc.GetMyVersion;
  ProgressBar1.Position := 0;
end;

function TUpdate_Form.CheckVersion: Boolean;
var
  VerFile: file of ver;
  VerFiles: ver;
  ver_serverFile: TextFile;
  version_server, last_update: string;
  LoadFile: TFileStream;
  version_server_INT, version_current_INT: integer;
begin
    try
    if FileExists(updatePATH + 'updates'+DirectorySeparator+'version.info') then
    begin
      AssignFile(VerFile, updatePATH + 'updates'+DirectorySeparator+'version.info');
      Reset(VerFile);
      Read(VerFile, VerFiles);
      last_update := VerFiles.lastupdate;
      Label6.Caption := dmFunc.GetMyVersion;
      Label4.Caption := last_update;
      CloseFile(VerFile);

      if not FileExists(updatePATH + 'updates'+DirectorySeparator+'versiononserver.info') then begin
        LoadFile := TFileStream.Create(updatePATH + 'updates'+DirectorySeparator+'versiononserver.info',fmCreate);
        LoadFile.Seek(0, soFromEnd);
        LoadFile.WriteBuffer('1.1.1',Length('1.1.1'));
        LoadFile.Free;
      end;

      AssignFile(ver_serverFile, updatePATH + 'updates'+DirectorySeparator+'versiononserver.info');
      Reset(ver_serverFile);
      while not EOF(ver_serverFile) do
        ReadLn(ver_serverFile, version_server);

      if (version_server = '1.1.1') or (Pos('</html>',version_server) > 0) then begin
      Label8.Caption := rFailedToLoadData;
      CloseFile(ver_serverFile);
      Exit;
      end
      else
      Label8.Caption := version_server;

      version_current_INT := StrToInt(StringReplace(dmFunc.GetMyVersion, '.',
        '', [rfReplaceAll]));
      version_server_INT := StrToInt(StringReplace(version_server,
        '.', '', [rfReplaceAll]));
      CloseFile(ver_serverFile);

      while Length(IntToStr(version_current_INT)) >
        Length(IntToStr(version_server_INT)) do
        version_server_INT := version_server_INT * 10;

      if version_current_INT < version_server_INT then
      begin
        Label2.Caption := rUpdateRequired;
        Result := True;
        MainForm.Label50.Visible:=True;
        Label9.Caption := rUpdateStatusDownload;
        Button1.Caption := rButtonDownload;
      end
      else
      begin
        Label9.Caption := rUpdateStatusActual;
        Result := False;
        MainForm.Label50.Visible:=False;
      end;

      AssignFile(VerFile, updatePATH + 'updates'+DirectorySeparator+'version.info');
      Rewrite(VerFile);
      VerFiles.version := Label8.Caption;
      VerFiles.lastupdate := DateTimeToStr(Now);
      Write(VerFile, VerFiles);
      CloseFile(VerFile);
    end
    else
    begin
      AssignFile(VerFile, updatePATH + 'updates'+DirectorySeparator+'version.info');
      Rewrite(VerFile);
      VerFiles.version := Label8.Caption;
      VerFiles.lastupdate := DateTimeToStr(Now);
      Write(VerFile, VerFiles);
      CloseFile(VerFile);
    end;

  except
  end;
end;

procedure TUpdate_Form.CheckUpdate;
begin
    DownUpdThread := TDownUpdThread.Create;
    if Assigned(DownUpdThread.FatalException) then
      raise DownUpdThread.FatalException;
    with DownUpdThread do
    begin
      name_file := 'versiononserver.info';
      name_directory := updatePATH + 'updates'+DirectorySeparator;
      url_file := 'http://update.ew8bak.ru/version_server.info';
      Start;
    end;
end;

procedure TUpdate_Form.Button2Click(Sender: TObject);
begin
  Update_Form.Close;
end;

procedure TUpdate_Form.DownloadFile;
var
  HTTP: THTTPSend;
  MaxSize: int64;
begin
  Download := 0;
  MaxSize := dmFunc.GetSize(DownPATH);
  if MaxSize > 0 then
    ProgressBar1.Max := MaxSize
  else
    ProgressBar1.Max := 0;
  HTTP := THTTPSend.Create;
  HTTP.Sock.OnStatus := @SynaProgress;
  Label9.Caption := rUpdateStatusDownloads;
  try
    if HTTP.HTTPMethod('GET', DownPATH) then
      HTTP.Document.SaveToFile(updatePATH + 'updates'+DirectorySeparator+'EWLog.exe');
  finally
    HTTP.Free;
    DownloadDBFile;
  end;
end;

procedure TUpdate_Form.DownloadDBFile;
var
  HTTP: THTTPSend;
  MaxSize: int64;
begin
  Download := 0;
  MaxSize := dmFunc.GetSize('http://update.ew8bak.ru/serviceLOG.db');
  if MaxSize > 0 then
    ProgressBar1.Max := MaxSize
  else
    ProgressBar1.Max := 0;
  HTTP := THTTPSend.Create;
  HTTP.Sock.OnStatus := @SynaProgress;
  Label9.Caption := rUpdateStatusDownloadBase;
  try
    if HTTP.HTTPMethod('GET', 'http://update.ew8bak.ru/serviceLOG.db') then
      HTTP.Document.SaveToFile(updatePATH + 'updates'+DirectorySeparator+'serviceLOG.db');
  finally
    HTTP.Free;
    DownloadCallBookFile;
  end;
end;

procedure TUpdate_Form.DownloadCallBookFile;
var
  HTTP: THTTPSend;
  MaxSize: int64;
begin
  Download := 0;
  MaxSize := dmFunc.GetSize('http://update.ew8bak.ru/callbook.db');
  if MaxSize > 0 then
    ProgressBar1.Max := MaxSize
  else
    ProgressBar1.Max := 0;
  HTTP := THTTPSend.Create;
  HTTP.Sock.OnStatus := @SynaProgress;
  Label9.Caption := rUpdateStatusDownloadCallbook;
  try
    if HTTP.HTTPMethod('GET', 'http://update.ew8bak.ru/callbook.db') then
      HTTP.Document.SaveToFile(updatePATH + 'updates'+DirectorySeparator+'callbook.db');
  finally
    HTTP.Free;
    MainForm.CallBookLiteConnection.DatabaseName := updatePATH + 'callbook.db';
    MainForm.CallBookLiteConnection.Connected := False;
    UseCallBook := 'NO';
    if FileUtil.CopyFile(updatePATH + 'updates'+DirectorySeparator+'callbook.db', updatePATH +
      'callbook.db', True, True) then
    begin
      DeleteFile(PChar(updatePATH + 'updates'+DirectorySeparator+'callbook.db'));
      MainForm.CallBookLiteConnection.DatabaseName := updatePATH + 'callbook.db';
      MainForm.CallBookLiteConnection.Connected := True;
      UseCallBook := 'YES';
    end
    else
      Label9.Caption := rUpdateDontCopy;
    DownloadChangeLOGFile;
  end;
end;

procedure TUpdate_Form.DownloadChangeLOGFile;
var
  HTTP: THTTPSend;
  MaxSize: int64;
begin
  Download := 0;
  MaxSize := dmFunc.GetSize('http://update.ew8bak.ru/changelog.txt');
  if MaxSize > 0 then
    ProgressBar1.Max := MaxSize
  else
    ProgressBar1.Max := 0;
  HTTP := THTTPSend.Create;
  HTTP.Sock.OnStatus := @SynaProgress;
  Label9.Caption := rUpdateStatusDownloadChanges;
  try
    if HTTP.HTTPMethod('GET', 'http://update.ew8bak.ru/changelog.txt') then
      HTTP.Document.SaveToFile(updatePATH + 'updates'+DirectorySeparator+'changelog.txt');
  finally
    HTTP.Free;
    Changelog_Form.Memo1.Lines.LoadFromFile(updatePATH + 'updates'+DirectorySeparator+'changelog.txt');
    Changelog_Form.Show;
    Label9.Caption := rUpdateStatusRequiredInstall;
    Button1.Caption := rButtonInstall;
  end;
end;

procedure TUpdate_Form.Button1Click(Sender: TObject);
begin
  if Button1.Caption = rButtonCheck then
    CheckUpdate
  else
  if Button1.Caption = rButtonInstall then
    {$IFDEF WINDOWS}
    RunAsAdmin(MainForm.Handle, 'UPDATE_EWLog.exe', '')
    {$ELSE}
    ShowMessage(rOnlyWindows)
    {$ENDIF WINDOWS}
  else
  begin
    DownloadFile;
  end;

end;

procedure TUpdate_Form.SynaProgress(Sender: TObject; Reason: THookSocketReason;
  const Value: string);
begin
  if Reason = HR_ReadCount then
  begin
    Download := Download + StrToInt(Value);
    if ProgressBar1.Max > 0 then
    begin
      ProgressBar1.Position := Download;
      label10.Caption := IntToStr(Trunc((Download / ProgressBar1.Max) * 100)) + '%';
    end
    else
      label10.Caption := rSizeFile + IntToStr(Download) + rBytes;
    Application.ProcessMessages;
  end;
end;
{$IFDEF WINDOWS}
function TUpdate_Form.RunAsAdmin(const Handler: Hwnd;
  const Path, Params: string): boolean;
var
  sei: TShellExecuteInfoA;
begin
  FillChar(sei, SizeOf(sei), 0);
  sei.cbSize := SizeOf(sei);
  sei.Wnd := Handler;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := 'runas';
  sei.lpFile := PAnsiChar(Path);
  sei.lpParameters := PAnsiChar(Params);
  sei.nShow := SW_SHOWNORMAL;
  Result := ShellExecuteExA(@sei);
end;
{$ENDIF WINDOWS}

end.
