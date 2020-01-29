unit ConfigForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, EditBtn, ComCtrls, LazUTF8, LazFileUtils, httpsend, blcksock,
  synautil;

resourcestring
  rMySQLConnectTrue = 'Connection established successfully';
  rCheckNotEdit = 'Not all fields are entered';
  rCheckUpdates = 'Check for Updates';
  rDownload = 'Download?';
  rDownloadFile = 'File Download: ';
  rReferenceBook = 'Internal reference book';
  rNumberOfRecords = 'Number of records: ';
  rReleaseDate = 'Release Date: ';
  rNoReferenceBookFound = 'No reference book found!';
  rNumberOfRecordsNot = 'Number of records: ---';
  rReleaseDateNot = 'Release date: --.--.----';
  rOK = 'OK';
  rByte = ' byte';
  rStatusUpdateCheck = 'Update status: Check version';
  rStatusUpdateRequires = 'Update status: Update required';
  rStatusUpdateActual = 'Update status: Actual';
  rStatusUpdateDownload = 'Update status: Download';
  rStatusUpdateDone = 'Update status: Done';
  rStatusUpdateNotCopy = 'Update status: Can not Copy';

type

  { TConfigForm }

  TConfigForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    Edit1: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    FileNameEdit1: TFileNameEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ProgressBar1: TProgressBar;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    CheckCallBook: TSQLQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SaveINI;
    procedure ReadINI;
    function CheckUpdate: boolean;
    procedure SynaProgress(Sender: TObject; Reason: THookSocketReason;
      const Value: string);
    procedure DownloadCallBookFile;
    function GetSize(URL: string): int64;
  private
    Download: int64;
    { private declarations }
  public
    { public declarations }
  end;

var
  ConfigForm: TConfigForm;

implementation

uses
  MainForm_U, UpdateForm_U, dmFunc_U, editqso_u;

{$R *.lfm}

{ TConfigForm }

procedure TConfigForm.SaveINI;
begin
  IniF.WriteString('DataBases', 'HostAddr', Edit1.Text);
  IniF.WriteString('DataBases', 'Port', Edit2.Text);
  IniF.WriteString('DataBases', 'LoginName', Edit3.Text);
  IniF.WriteString('DataBases', 'Password', Edit4.Text);
  IniF.WriteString('DataBases', 'DataBaseName', Edit5.Text);
  IniF.WriteString('DataBases', 'FileSQLite', FileNameEdit1.Text);

  IniF.WriteString('TelnetCluster', 'Login', Edit11.Text);
  IniF.WriteString('TelnetCluster', 'Password', Edit12.Text);
  IniF.WriteBool('TelnetCluster', 'AutoStart', CheckBox4.Checked);

  if RadioButton1.Checked = True then
    IniF.WriteString('DataBases', 'DefaultDataBase', 'MySQL')
  else
    IniF.WriteString('DataBases', 'DefaultDataBase', 'SQLite');
  if CheckBox1.Checked = True then
    IniF.WriteString('SetLog', 'UseCallBook', 'YES')
  else
    IniF.WriteString('SetLog', 'UseCallBook', 'NO');

  if CheckBox2.Checked = True then
    IniF.WriteString('SetLog', 'ShowBand', 'True')
  else
    IniF.WriteString('SetLog', 'ShowBand', 'False');

  IniF.WriteString('SetLog', 'QRZ_Login', Edit6.Text);
  IniF.WriteString('SetLog', 'QRZ_Pass', Edit7.Text);
  if CheckBox3.Checked = True then
    IniF.WriteString('SetLog', 'Sprav', 'True')
  else
    IniF.WriteString('SetLog', 'Sprav', 'False');
   if CheckBox5.Checked = True then
    IniF.WriteBool('SetLog', 'PrintPrev', True)
  else
    IniF.WriteBool('SetLog', 'PrintPrev', False);
   MainForm.PrintPrev:=CheckBox5.Checked;
end;

procedure TConfigForm.ReadINI;
begin
  Edit1.Text := IniF.ReadString('DataBases', 'HostAddr', '');
  if IniF.ReadString('DataBases', 'Port', '') = '' then
    Edit2.Text := '3306'
  else
    Edit2.Text := IniF.ReadString('DataBases', 'Port', '');
  Edit3.Text := IniF.ReadString('DataBases', 'LoginName', '');
  Edit4.Text := IniF.ReadString('DataBases', 'Password', '');
  Edit5.Text := IniF.ReadString('DataBases', 'DataBaseName', '');
  Edit11.Text := IniF.ReadString('TelnetCluster', 'Login', '');
  Edit12.Text := IniF.ReadString('TelnetCluster', 'Password', '');
  CheckBox4.Checked := IniF.ReadBool('TelnetCluster', 'AutoStart', False);
  FileNameEdit1.Text := IniF.ReadString('DataBases', 'FileSQLite', '');
  if IniF.ReadString('DataBases', 'DefaultDataBase', '') = 'MySQL' then
    RadioButton1.Checked := True
  else
    RadioButton2.Checked := True;
  if IniF.ReadString('SetLog', 'UseCallBook', '') = 'YES' then
    CheckBox1.Checked := True
  else
    CheckBox1.Checked := False;

  if IniF.ReadString('SetLog', 'ShowBand', '') = 'True' then
    CheckBox2.Checked := True
  else
    CheckBox2.Checked := False;

  Edit6.Text := IniF.ReadString('SetLog', 'QRZ_Login', '');
  Edit7.Text := IniF.ReadString('SetLog', 'QRZ_Pass', '');

  if IniF.ReadString('SetLog', 'Sprav', '') = 'True' then
    CheckBox3.Checked := True
  else
    CheckBox3.Checked := False;

  if IniF.ReadBool('SetLog', 'PrintPrev', False) = True then
    CheckBox5.Checked := True
  else
    CheckBox5.Checked := False;
end;

procedure TConfigForm.Button2Click(Sender: TObject);
begin
  ConfigForm.Close;
end;

procedure TConfigForm.Button3Click(Sender: TObject);
begin
  try
    if (Edit1.Text <> '') and (Edit2.Text <> '') and (Edit3.Text <> '') and
      (Edit4.Text <> '') and (Edit5.Text <> '') then
    begin
      MainForm.MySQLLOGDBConnection.HostName := Edit1.Text;
      MainForm.MySQLLOGDBConnection.Port := StrToInt(Edit2.Text);
      MainForm.MySQLLOGDBConnection.UserName := Edit3.Text;
      MainForm.MySQLLOGDBConnection.Password := Edit4.Text;
      MainForm.MySQLLOGDBConnection.DatabaseName := Edit5.Text;
      MainForm.MySQLLOGDBConnection.Connected := False;
      MainForm.MySQLLOGDBConnection.Connected := True;
      if MainForm.MySQLLOGDBConnection.Connected = True then
        ShowMessage(rMySQLConnectTrue);
    end
    else
      ShowMessage(rCheckNotEdit);
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TConfigForm.Button4Click(Sender: TObject);
begin
  if Button4.Caption = rCheckUpdates then
    CheckUpdate
  else
  if Button4.Caption = rDownload then
  begin
    MainForm.CallBookLiteConnection.Connected := False;
    UseCallBook := 'NO';
    DownloadCallBookFile;
  end;
end;

procedure TConfigForm.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked = True then begin
    CheckBox3.Checked := False;
    MainForm.CallBookLiteConnection.Connected:=True;
  end;
  if CheckBox1.Checked = True then
    IniF.WriteString('SetLog', 'UseCallBook', 'YES')
  else
    IniF.WriteString('SetLog', 'UseCallBook', 'NO');
end;

procedure TConfigForm.CheckBox2Change(Sender: TObject);
begin
      if InitLog_DB = 'YES' then
    begin
  if CheckBox2.Checked = True then
  begin
      IniF.WriteString('SetLog', 'ShowBand', 'True');
      MainForm.addBands(IniF.ReadString('SetLog', 'ShowBand', ''),MainForm.ComboBox2.Text);
  end
  else begin
  if CheckBox2.Checked = False then
  begin
     IniF.WriteString('SetLog', 'ShowBand', 'False');
     MainForm.addBands(IniF.ReadString('SetLog', 'ShowBand', ''),MainForm.ComboBox2.Text);
  end;
  end;
  MainForm.DBGrid1.Invalidate;
  MainForm.DBGrid2.Invalidate;
  MainForm.SetGrid;
  EditQSO_Form.DBGrid1.Invalidate;
    end;
end;

procedure TConfigForm.CheckBox3Change(Sender: TObject);
begin
  if CheckBox3.Checked = True then begin
    CheckBox1.Checked := False;
    MainForm.CallBookLiteConnection.Connected:=False;
  end;
  if CheckBox3.Checked = True then
    IniF.WriteString('SetLog', 'Sprav', 'True')
  else
    IniF.WriteString('SetLog', 'Sprav', 'False');
end;

procedure TConfigForm.FormCreate(Sender: TObject);
begin
  ReadINI;
end;

procedure TConfigForm.FormShow(Sender: TObject);
var
  sDBPath: string;
begin
  ReadINI;
  Button4.Caption := rCheckUpdates;
  {$IFDEF UNIX}
  sDBPath := GetEnvironmentVariable('HOME') + '/EWLog/';
    {$ELSE}
  sDBPath := GetEnvironmentVariable('SystemDrive') +
    GetEnvironmentVariable('HOMEPATH') + '\EWLog\';
    {$ENDIF UNIX}

  if FileExistsUTF8(sDBPath + 'callbook.db') then
  begin
    GroupBox2.Caption := rReferenceBook;
    CheckCallBook.Close;
    CheckCallBook.SQL.Clear;
    MainForm.CallBookLiteConnection.DatabaseName := sDBPath + 'callbook.db';
    CheckCallBook.SQL.Add('SELECT COUNT(*) as Count FROM Callbook');
    CheckCallBook.Open;
    Label11.Caption := rNumberOfRecords +
      IntToStr(CheckCallBook.FieldByName('Count').AsInteger);
    CheckCallBook.Close;
    CheckCallBook.SQL.Clear;
    CheckCallBook.SQL.Add('SELECT * FROM inform');
    CheckCallBook.Open;
    Label10.Caption := rReleaseDate +
      CheckCallBook.FieldByName('date').AsString;
    Label14.Caption := CheckCallBook.FieldByName('version').AsString;
    CheckCallBook.Close;
  end
  else
  begin
    GroupBox2.Caption := rNoReferenceBookFound;
    label11.Caption := rNumberOfRecordsNot;
    Label10.Caption := rReleaseDateNot;
    Label14.Caption := '---';
  end;
end;

procedure TConfigForm.Button1Click(Sender: TObject);
begin
  SaveINI;
  LoginCluster:=Edit11.Text;
  PasswordCluster:=Edit12.Text;
  ConfigForm.Close;
end;

function TConfigForm.CheckUpdate: boolean;
var
  VerFile: TextFile;
  a: string;
  LoadFile: TFileStream;
  updatePATH: string;
  serV, locV: double;
begin
  {$IFDEF UNIX}
  updatePATH := GetEnvironmentVariable('HOME') + '/EWLog/';
  if not DirectoryExists(updatePATH + 'updates/') then
    ForceDirectories(updatePATH + 'updates/');
    {$ELSE}
  updatePATH := SysUtils.GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
    {$ENDIF UNIX}
  with THTTPSend.Create do
  begin
    Label12.Caption := rStatusUpdateCheck;
    if HTTPMethod('GET', 'http://update.ew8bak.ru/versioncallbook.info') then
    begin
  {$IFDEF UNIX}
      LoadFile := TFileStream.Create(updatePATH + 'updates/versioncallbook.info',
        fmCreate);
  {$ELSE}
      LoadFile := TFileStream.Create(updatePATH + 'updates\versioncallbook.info',
        fmCreate);
  {$ENDIF UNIX}
      HttpGetBinary('http://update.ew8bak.ru/versioncallbook.info', LoadFile);
      LoadFile.Free;
      Free;
    end;
  end;

    {$IFDEF UNIX}
  AssignFile(VerFile, updatePATH + 'updates/versioncallbook.info');
  {$ELSE}
  AssignFile(VerFile, updatePATH + 'updates\versioncallbook.info');
  {$ENDIF UNIX}

  Reset(VerFile);
  Read(VerFile, a);
  CloseFile(VerFile);
  if Label14.Caption <> '---' then
  begin
    serV := StrToFloat(a);
    locV := StrToFloat(Label14.Caption);
    if locV < serV then
    begin
      Label12.Caption := rStatusUpdateRequires;
      Result := True;
      Button4.Caption := rDownload;
    end
    else
    begin
      Label12.Caption := rStatusUpdateactual;
      Result := False;
    end;
  end
  else
  begin
    Label12.Caption := rStatusUpdateRequires;
    Result := True;
    Button4.Caption := rDownload;
  end;
end;

procedure TConfigForm.DownloadCallBookFile;
var
  HTTP: THTTPSend;
  MaxSize: int64;
  updatePATH: string;
  sDBPath: string;
begin
     {$IFDEF UNIX}
  updatePATH := GetEnvironmentVariable('HOME') + '/EWLog/';
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
  Label12.Caption := rStatusUpdateDownload;
  try
    if HTTP.HTTPMethod('GET', 'http://update.ew8bak.ru/callbook.db') then
    {$IFDEF UNIX}
      HTTP.Document.SaveToFile(updatePATH + 'updates/callbook.db');
    {$ELSE}
    HTTP.Document.SaveToFile(updatePATH + 'updates\callbook.db');
    {$ENDIF UNIX}

  finally
    HTTP.Free;
    {$IFDEF UNIX}
    if FileUtil.CopyFile(updatePATH + 'updates/callbook.db', updatePATH +
      'callbook.db', True, True) then
    {$ELSE}
      if FileUtil.CopyFile(updatePATH + 'updates\callbook.db',
        updatePATH + 'callbook.db', True, True) then
    {$ENDIF UNIX}

      begin
        {$IFDEF UNIX}
        sDBPath := GetEnvironmentVariable('HOME') + '/EWLog/';
    {$ELSE}
        sDBPath := GetEnvironmentVariable('SystemDrive') +
          GetEnvironmentVariable('HOMEPATH') + '\EWLog\';
    {$ENDIF UNIX}
        if FileExistsUTF8(sDBPath + 'callbook.db') then
        begin
          MainForm.CallBookLiteConnection.DatabaseName := sDBPath + 'callbook.db';
          GroupBox2.Caption := rReferenceBook;
          CheckCallBook.Close;
          CheckCallBook.SQL.Clear;
          CheckCallBook.SQL.Add('SELECT COUNT(*) as Count FROM Callbook');
          CheckCallBook.Open;
          Label11.Caption := rNumberOfRecords +
            IntToStr(CheckCallBook.FieldByName('Count').AsInteger);
          CheckCallBook.Close;
          CheckCallBook.SQL.Clear;
          CheckCallBook.SQL.Add('SELECT * FROM inform');
          CheckCallBook.Open;
          Label10.Caption := rReleaseDate +
            CheckCallBook.FieldByName('date').AsString;
          Label14.Caption := CheckCallBook.FieldByName('version').AsString;
          CheckCallBook.Close;
        end
        else
        begin
          GroupBox2.Caption := rNoReferenceBookFound;
          label11.Caption := rNumberOfRecordsNot;
          Label10.Caption := rReleaseDateNot;
          Label14.Caption := '---';
        end;
       {$IFDEF UNIX}
        DeleteFileUTF8(updatePATH + 'updates/callbook.db');
       {$ELSE}
        DeleteFileUTF8(updatePATH + 'updates\callbook.db');
      {$ENDIF UNIX}

        MainForm.CallBookLiteConnection.DatabaseName := updatePATH + 'callbook.db';
        MainForm.CallBookLiteConnection.Connected := True;
        UseCallBook := 'YES';
        Button4.Caption := rOK;
        Label12.Caption := rstatusUpdateDone;
      end
      else
        Label12.Caption := rStatusUpdateNotCopy;
  end;
end;

function TConfigForm.GetSize(URL: string): int64;
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
    end;
end;

procedure TConfigForm.SynaProgress(Sender: TObject; Reason: THookSocketReason;
  const Value: string);
begin
  if Reason = HR_ReadCount then
  begin
    Download := Download + StrToInt(Value);
    if ProgressBar1.Max > 0 then
    begin
      ProgressBar1.Position := Download;
      label17.Caption := rDownloadFile +
        IntToStr(Trunc((Download / ProgressBar1.Max) * 100)) + '%';
    end
    else
      label17.Caption := rDownloadFile + IntToStr(Download) +
        rByte;
    Application.ProcessMessages;
  end;
end;

end.
