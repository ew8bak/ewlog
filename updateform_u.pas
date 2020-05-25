unit UpdateForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, LazUTF8, StdCtrls,
  ComCtrls,{$IFDEF WINDOWS} Windows, ShellApi,{$ENDIF WINDOWS} httpsend,
  blcksock, synautil, ResourceStr, const_u;
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
    procedure DownloadChangeLOGFile;

    { private declarations }
  public
    { public declarations }
  end;

var
  Update_Form: TUpdate_Form;


implementation

uses
  Changelog_Form_U, MainForm_U, DownloadUpdates, dmFunc_U, analyticThread;

{$R *.lfm}

{ TUpdate_Form }

procedure TUpdate_Form.FormCreate(Sender: TObject);
begin
    updatePATH:=MainForm.FilePATH + 'updates' + DirectorySeparator;
  if not DirectoryExists(updatePATH) then
    CreateDir(updatePATH);
end;

procedure TUpdate_Form.FormShow(Sender: TObject);
begin
  Button1.Caption := rButtonCheck;
  Label10.Caption := rSizeFile;
  Label9.Caption := rUpdateStatus;
  Label6.Caption := dmFunc.GetMyVersion;
  ProgressBar1.Position := 0;
end;

function TUpdate_Form.CheckVersion: Boolean;
var
version_curr: Integer;
version_serv: Integer;
version_servStr: String;
version_file: TextFile;
version_file_stream: TFileStream;
begin
    try
       if not FileExists(updatePATH + 'version') then begin
        version_file_stream := TFileStream.Create(updatePATH +'version',fmCreate);
        version_file_stream.Seek(0, soFromEnd);
        version_file_stream.WriteBuffer('1.1.1',Length('1.1.1'));
        version_file_stream.Free;
      end;

      version_curr:=StrToInt(StringReplace(dmFunc.GetMyVersion,'.','',[rfReplaceAll]));
      AssignFile(version_file, updatePATH + 'version');
      Reset(version_file);
      while not EOF(version_file) do
        ReadLn(version_file, version_servStr);
       if (version_servStr = '1.1.1') or (Pos('</html>',version_servStr) > 0) or (Pos('not found', version_servStr) > 0) then begin
      Label8.Caption := rFailedToLoadData;
      Exit;
      end
      else begin
      Label8.Caption := version_servStr;
      version_serv:=StrToInt(StringReplace(version_servStr,'.','',[rfReplaceAll]));
      end;

     if version_curr < version_serv then
      begin
        Label2.Caption := rUpdateRequired;
        Result := True;
        MainForm.Label50.Visible:=True;
        Label9.Caption := rUpdateStatusDownload;
        Button1.Caption := rButtonDownload;
      if dmFunc.GetSize(DownPATHssl+DownEXE) = -1 then
        label10.Caption := rSizeFile + FormatFloat('0.##', dmFunc.GetSize(DownPATH+DownEXE)/1048576) + ' ' + rMBytes else
        label10.Caption := rSizeFile + FormatFloat('0.##', dmFunc.GetSize(DownPATHssl+DownEXE)/1048576) + ' ' + rMBytes
      end
      else
      begin
        Label9.Caption := rUpdateStatusActual;
        Result := False;
        MainForm.Label50.Visible:=False;
      end;

  finally;
    CloseFile(version_file);
  end;
end;

procedure TUpdate_Form.CheckUpdate;
begin
   DownUpdThread := TDownUpdThread.Create;
    if Assigned(DownUpdThread.FatalException) then
      raise DownUpdThread.FatalException;
    with DownUpdThread do
    begin
      name_file := 'version';
      name_directory := updatePATH;
      url_file := DownPATH + 'version';
      urlssl_file := DownPATHssl + 'version';
      Start;
    end;

    analytThread := TanalyticThread.Create;
    if Assigned(analytThread.FatalException) then
      raise analytThread.FatalException;
    with analytThread do
    begin
      if IniF.ReadString('SetLog', 'DefaultCallLogBook', '') <> '' then
      user_call:=IniF.ReadString('SetLog', 'DefaultCallLogBook', '') else
      user_call:='nil';
      user_os:=type_os;
      {$IFDEF WINDOWS}
      user_version_os:=dmFunc.GetWindowsVersion;
      {$ELSE}
      user_version_os:='Linux NoNaMe';
      {$ENDIF WINDOWS}
      user_version:=dmFunc.GetMyVersion;
      num_start:=IniF.ReadInteger('SetLog', 'StartNum', 0);
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
  DownFile: string;
begin
  Download := 0;
  Button1.Enabled:=False;
  {$IFDEF WINDOWS}
  if dmFunc.GetWindowsVersion = 'Windows XP' then
  DownFile:=DownEXEXP else
  {$ENDIF WINDOWS}
  DownFile:=DownEXE;

  if dmFunc.GetSize(DownPATHssl+DownFile) = -1 then
  MaxSize := dmFunc.GetSize(DownPATH+DownFile) else
  MaxSize := dmFunc.GetSize(DownPATHssl+DownFile);

  if MaxSize > 0 then
    ProgressBar1.Max := MaxSize
  else
    ProgressBar1.Max := 0;
  HTTP := THTTPSend.Create;
  HTTP.Sock.OnStatus := @SynaProgress;
  Label9.Caption := rUpdateStatusDownloads;
  try
    if HTTP.HTTPMethod('GET', DownPATHssl+DownFile) then
      HTTP.Document.SaveToFile(updatePATH + DownFile) else
    if HTTP.HTTPMethod('GET', DownPATH+DownFile) then
      HTTP.Document.SaveToFile(updatePATH + DownFile)
  finally
    HTTP.Free;
    DownloadChangeLOGFile;
  end;
end;

procedure TUpdate_Form.DownloadChangeLOGFile;
var
  HTTP: THTTPSend;
  MaxSize: int64;
begin
  Download := 0;
  if dmFunc.GetSize(DownPATHssl+'changelog.txt') = -1 then
  MaxSize := dmFunc.GetSize(DownPATH+'changelog.txt') else
  MaxSize := dmFunc.GetSize(DownPATHssl+'changelog.txt');

  if MaxSize > 0 then
    ProgressBar1.Max := MaxSize
  else
    ProgressBar1.Max := 0;
  HTTP := THTTPSend.Create;
  HTTP.Sock.OnStatus := @SynaProgress;
  Label9.Caption := rUpdateStatusDownloadChanges;
  try
    if HTTP.HTTPMethod('GET', DownPATHssl+'changelog.txt') then
      HTTP.Document.SaveToFile(updatePATH + 'changelog.txt') else
          if HTTP.HTTPMethod('GET', DownPATH+'changelog.txt') then
      HTTP.Document.SaveToFile(updatePATH + 'changelog.txt');
  finally
    HTTP.Free;
    Changelog_Form.Memo1.Lines.LoadFromFile(updatePATH +'changelog.txt');
    Changelog_Form.Show;
    Label9.Caption := rUpdateStatusRequiredInstall;
    Button1.Enabled:=True;
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
    dmFunc.RunProgram(updatePATH + DownEXE, '')
    {$ELSE}
    ShowMessage(rOnlyWindows)
    {$ENDIF WINDOWS}
  else
    DownloadFile;
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

end.
