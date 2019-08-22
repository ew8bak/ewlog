unit UpdateForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, LazUTF8, StdCtrls,
  ComCtrls,{$IFDEF WINDOWS} Windows, ShellApi,{$ENDIF WINDOWS} httpsend,
  blcksock, synautil;

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
    {$IFDEF WINDOWS}
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    function CheckUpdate: boolean;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function GetSize(URL: string): int64;
    {$ELSE}
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    {$ENDIF WINDOWS}
  private
    Download: int64;//счётчик закачанных данных
    {$IFDEF WINDOWS}
    procedure SynaProgress(Sender: TObject; Reason: THookSocketReason;
      const Value: string);
    procedure DownloadFile;
    procedure DownloadDBFile;
    procedure DownloadCallBookFile;
    procedure DownloadChangeLOGFile;
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
  {$ENDIF}
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
  Changelog_Form_U, MainForm_U;

{$R *.lfm}

{ TUpdate_Form }
{$IFDEF WINDOWS}

function TUpdate_Form.GetSize(URL: string): int64;
var
  i: integer;
  size: string;
  ch: char;
begin
  Result := -1;
  with THTTPSend.Create do
    if HTTPMethod('HEAD', URL) then
    begin
      for I := 0 to Headers.Count - 1 do
      begin
        if pos('content-length', lowercase(Headers[i])) > 0 then
        begin
          size := '';
          for ch in Headers[i] do
            if ch in ['0'..'9'] then
              size := size + ch;
          Result := StrToInt(size) + Length(Headers.Text);
          break;
        end;
      end;
      Free;
    end;
end;


function GetMyVersion: string;
type
  TVerInfo = packed record
    Nevazhno: array[0..47] of byte;
    Minor, Major, Build, Release: word;
  end;
var
  s: TResourceStream;
  v: TVerInfo;
begin
  Result := '';
  try
    s := TResourceStream.Create(HInstance, '#1', RT_VERSION);
    if s.Size > 0 then
    begin
      s.Read(v, SizeOf(v));
      Result := IntToStr(v.Major) + '.' + IntToStr(v.Minor) + '.' +
        IntToStr(v.Release);
    end;
    s.Free;
  except;
  end;
end;


function TUpdate_Form.CheckUpdate: boolean;
var
  VerFile: file of ver;
  VerFiles: ver;
  ver_serverFile: TextFile;
  version_server, last_update: string;
  LoadFile: TFileStream;
  updatePATH: string;
  version_server_INT, version_current_INT: integer;
begin
  try
     {$IFDEF UNIX}
    updatePATH := '/etc/EWLog/';
    {$ELSE}

    updatePATH := SysUtils.GetEnvironmentVariable('SystemDrive') +
      SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
    {$ENDIF UNIX}

    if FileExists(updatePATH + 'updates\version.info') then
    begin
      AssignFile(VerFile, updatePATH + 'updates\version.info');
      Reset(VerFile);
      Read(VerFile, VerFiles);
      last_update := VerFiles.lastupdate;
      Label6.Caption := GetMyVersion;
      Label4.Caption := last_update;
      CloseFile(VerFile);

      with THTTPSend.Create do
      begin
        Label9.Caption :=
          'Процесс обновления: Проверка версии';
        if HTTPMethod('GET', 'http://update.ew8bak.ru/version_server.info') then
        begin
          LoadFile := TFileStream.Create(updatePATH + 'updates\versiononserver.info',
            fmCreate);
          HttpGetBinary('http://update.ew8bak.ru/version_server.info', LoadFile);
          LoadFile.Free;
          //Free;
        end;
        Free;
      end;

      AssignFile(ver_serverFile, updatePATH + 'updates\versiononserver.info');
      Reset(ver_serverFile);
      while not EOF(ver_serverFile) do
        ReadLn(ver_serverFile, version_server);
      Label8.Caption := version_server;
      version_current_INT := StrToInt(StringReplace(GetMyVersion, '.', '', [rfReplaceAll]));
      version_server_INT := StrToInt(StringReplace(version_server, '.', '', [rfReplaceAll]));
      CloseFile(ver_serverFile);

      while Length(IntToStr(version_current_INT)) > Length(IntToStr(version_server_INT)) do
        version_server_INT := version_server_INT * 10;

      if version_current_INT < version_server_INT then
      begin
        Label2.Caption := 'Требует обновления';
        Result := True;
        Label9.Caption := 'Процесс обновления: Загрузить?';
        Button1.Caption := 'Загрузка';
      end
      else
      begin
        Label9.Caption := 'Процесс обновления: Актуально';
        Result := False;
      end;

      AssignFile(VerFile, updatePATH + 'updates\version.info');
      Rewrite(VerFile);
      VerFiles.version := Label8.Caption;
      VerFiles.lastupdate := DateTimeToStr(Now);
      Write(VerFile, VerFiles);
      CloseFile(VerFile);
    end
    else
    begin
      AssignFile(VerFile, updatePATH + 'updates\version.info');
      Rewrite(VerFile);
      VerFiles.version := Label8.Caption;
      VerFiles.lastupdate := DateTimeToStr(Now);
      Write(VerFile, VerFiles);
      CloseFile(VerFile);
    end;

  except
  end;
end;

procedure TUpdate_Form.FormCreate(Sender: TObject);
begin
      {$IFDEF WINDOWS}
  MainForm.CheckUpdatesTimer.Enabled := True;
    {$ENDIF WINDOWS}
end;

procedure TUpdate_Form.FormShow(Sender: TObject);
var
  VerFile: file of ver;
  VerFiles: ver;
  updatePATH: string;
begin
   {$IFDEF UNIX}
  updatePATH := '/etc/EWLog/';
    {$ELSE}
  updatePATH := SysUtils.GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
    {$ENDIF UNIX}
  AssignFile(VerFile, updatePATH + 'updates\version.info');
  Reset(VerFile);
  Read(VerFile, VerFiles);
  Label4.Caption := VerFiles.lastupdate;
  CloseFile(VerFile);
  Button1.Caption := 'Проверить';
  Label10.Caption := 'Размер файла: ';
  Label9.Caption := 'Процесс обновления: ';
  Label6.Caption := GetMyVersion;
  ProgressBar1.Position := 0;
end;

procedure TUpdate_Form.Button2Click(Sender: TObject);
begin
  Update_Form.Close;
end;

procedure TUpdate_Form.DownloadFile;
var
  HTTP: THTTPSend;
  MaxSize: int64;
  updatePATH: string;
begin

     {$IFDEF UNIX}
  updatePATH := '/etc/EWLog/';
    {$ELSE}
  updatePATH := SysUtils.GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
    {$ENDIF UNIX}
  Download := 0;
  MaxSize := GetSize(DownPATH);
  if MaxSize > 0 then
    ProgressBar1.Max := MaxSize
  else
    ProgressBar1.Max := 0;
  HTTP := THTTPSend.Create;
  HTTP.Sock.OnStatus := @SynaProgress;
  Label9.Caption := 'Процесс обновления: Загрузка';
  try
    if HTTP.HTTPMethod('GET', DownPATH) then
      HTTP.Document.SaveToFile(updatePATH + 'updates\EWLog.exe');
  finally
    HTTP.Free;
    DownloadDBFile;
  end;
end;

procedure TUpdate_Form.DownloadDBFile;
var
  HTTP: THTTPSend;
  MaxSize: int64;
  updatePATH: string;
begin
     {$IFDEF UNIX}
  updatePATH := '/etc/EWLog/';
    {$ELSE}
  updatePATH := SysUtils.GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
    {$ENDIF UNIX}
  Download := 0;
  MaxSize := GetSize('http://update.ew8bak.ru/serviceLOG.db');
  if MaxSize > 0 then
    ProgressBar1.Max := MaxSize
  else
    ProgressBar1.Max := 0;
  HTTP := THTTPSend.Create;
  HTTP.Sock.OnStatus := @SynaProgress;
  Label9.Caption := 'Процесс обновления: Загрузка базы';
  try
    if HTTP.HTTPMethod('GET', 'http://update.ew8bak.ru/serviceLOG.db') then
      HTTP.Document.SaveToFile(updatePATH + 'updates\serviceLOG.db');
  finally
    HTTP.Free;
    DownloadCallBookFile;
  end;
end;

procedure TUpdate_Form.DownloadCallBookFile;
var
  HTTP: THTTPSend;
  MaxSize: int64;
  updatePATH: string;
begin
     {$IFDEF UNIX}
  updatePATH := '/etc/EWLog/';
    {$ELSE}
  updatePATH := SysUtils.GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
    {$ENDIF UNIX}
  Download := 0;
  MaxSize := GetSize('http://update.ew8bak.ru/callbook.db');
  if MaxSize > 0 then
    ProgressBar1.Max := MaxSize
  else
    ProgressBar1.Max := 0;
  HTTP := THTTPSend.Create;
  HTTP.Sock.OnStatus := @SynaProgress;
  Label9.Caption := 'Процесс обновления: Загрузка CallBook';
  try
    if HTTP.HTTPMethod('GET', 'http://update.ew8bak.ru/callbook.db') then
      HTTP.Document.SaveToFile(updatePATH + 'updates\callbook.db');
  finally
    HTTP.Free;
    MainForm.CallBookLiteConnection.DatabaseName := updatePATH + 'callbook.db';
    MainForm.CallBookLiteConnection.Connected := False;
    UseCallBook := 'NO';
    if FileUtil.CopyFile(updatePATH + 'updates\callbook.db', updatePATH + 'callbook.db',
      True, True) then
    begin
      DeleteFile(PChar(updatePATH + 'updates\callbook.db'));
      MainForm.CallBookLiteConnection.DatabaseName := updatePATH + 'callbook.db';
      MainForm.CallBookLiteConnection.Connected := True;
      UseCallBook := 'YES';
    end
    else
      Label9.Caption := 'Не могу скопировать';
    DownloadChangeLOGFile;
  end;
end;

procedure TUpdate_Form.DownloadChangeLOGFile;
var
  HTTP: THTTPSend;
  MaxSize: int64;
  updatePATH: string;
begin
     {$IFDEF UNIX}
  updatePATH := '/etc/EWLog/';
    {$ELSE}
  updatePATH := SysUtils.GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
    {$ENDIF UNIX}
  Download := 0;
  MaxSize := GetSize('http://update.ew8bak.ru/changelog.txt');
  if MaxSize > 0 then
    ProgressBar1.Max := MaxSize
  else
    ProgressBar1.Max := 0;
  HTTP := THTTPSend.Create;
  HTTP.Sock.OnStatus := @SynaProgress;
  Label9.Caption :=
    'Процесс обновления: Загрузка изменений';
  try
    if HTTP.HTTPMethod('GET', 'http://update.ew8bak.ru/changelog.txt') then
      HTTP.Document.SaveToFile(updatePATH + 'updates\changelog.txt');
  finally
    HTTP.Free;
    Changelog_Form.Memo1.Lines.LoadFromFile(updatePATH + 'updates\changelog.txt');
    Changelog_Form.Show;
    Label9.Caption :=
      'Процесс обновления: Требуется установка';
    Button1.Caption := 'Установить';
  end;
end;

procedure TUpdate_Form.Button1Click(Sender: TObject);
begin
  if Button1.Caption = 'Проверить' then
    CheckUpdate
  else
  if Button1.Caption = 'Установить' then
    RunAsAdmin(MainForm.Handle, 'UPDATE_EWLog.exe', '')
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
      label10.Caption := 'Размер файла: ' + IntToStr(Download) + ' байт';
    Application.ProcessMessages;
  end;
end;

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

 {$ELSE}
procedure TUpdate_Form.FormShow(Sender: TObject);
begin

end;

procedure TUpdate_Form.Button1Click(Sender: TObject);
begin

end;

procedure TUpdate_Form.Button2Click(Sender: TObject);
begin

end;

procedure TUpdate_Form.FormCreate(Sender: TObject);
begin

end;

{$ENDIF WINDOWS}
end.
