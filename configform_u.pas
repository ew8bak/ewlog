unit ConfigForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, EditBtn, ComCtrls, LazUTF8, LazFileUtils, httpsend, blcksock, ResourceStr,
  synautil, const_u, ImbedCallBookCheckRec;

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
    CheckBox11: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    FileNameEdit1: TFileNameEdit;
    gbIntRef: TGroupBox;
    gbTelnet: TGroupBox;
    GBQRZRU: TGroupBox;
    gbQRZCOM: TGroupBox;
    gbCloudLog: TGroupBox;
    gbHAMQTH: TGroupBox;
    gbMySQL: TGroupBox;
    gbSQLite: TGroupBox;
    gbDefaultDB: TGroupBox;
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
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    PControl: TPageControl;
    ProgressBar1: TProgressBar;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    TSTelnet: TTabSheet;
    TSIntRef: TTabSheet;
    TSOtherSettings: TTabSheet;
    TSRefOnline: TTabSheet;
    TSBase: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox11Change(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox6Change(Sender: TObject);
    procedure CheckBox7Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SaveINI;
    procedure ReadINI;
    function CheckUpdate: boolean;
    procedure SynaProgress(Sender: TObject; Reason: THookSocketReason;
      const Value: string);
    procedure DownloadCallBookFile;
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
  miniform_u, dmFunc_U, editqso_u, InitDB_dm, MainFuncDM, GridsForm_u;

{$R *.lfm}

{ TConfigForm }

procedure TConfigForm.SaveINI;
begin
  INIFile.WriteString('DataBases', 'HostAddr', Edit1.Text);
  INIFile.WriteString('DataBases', 'Port', Edit2.Text);
  INIFile.WriteString('DataBases', 'LoginName', Edit3.Text);
  INIFile.WriteString('DataBases', 'Password', Edit4.Text);
  INIFile.WriteString('DataBases', 'DataBaseName', Edit5.Text);
  INIFile.WriteString('DataBases', 'FileSQLite', FileNameEdit1.Text);
  INIFile.WriteString('TelnetCluster', 'Login', Edit11.Text);
  INIFile.WriteString('TelnetCluster', 'Password', Edit12.Text);
  INIFile.WriteBool('TelnetCluster', 'AutoStart', CheckBox4.Checked);
  INIFile.WriteString('SetLog', 'CloudLogServer', Edit10.Text);
  INIFile.WriteString('SetLog', 'CloudLogApi', Edit13.Text);
  INIFile.WriteBool('SetLog', 'IntCallBook', CheckBox1.Checked);
  INIFile.WriteBool('SetLog', 'StateToQSLInfo', CheckBox6.Checked);
  INIFile.WriteString('SetLog', 'QRZRU_Login', Edit6.Text);
  INIFile.WriteString('SetLog', 'QRZRU_Pass', Edit7.Text);
  INIFile.WriteString('SetLog', 'QRZCOM_Login', Edit8.Text);
  INIFile.WriteString('SetLog', 'QRZCOM_Pass', Edit9.Text);
  INIFile.WriteString('SetLog', 'HAMQTH_Login', Edit14.Text);
  INIFile.WriteString('SetLog', 'HAMQTH_Pass', Edit15.Text);
  INIFile.WriteBool('SetLog', 'ShowBand', CheckBox2.Checked);
  if RadioButton1.Checked then
    INIFile.WriteString('DataBases', 'DefaultDataBase', 'MySQL')
  else
    INIFile.WriteString('DataBases', 'DefaultDataBase', 'SQLite');

  if CheckBox5.Checked then
    INIFile.WriteBool('SetLog', 'PrintPrev', True)
  else
    INIFile.WriteBool('SetLog', 'PrintPrev', False);

  if CheckBox8.Checked then
    INIFile.WriteBool('SetLog', 'AutoCloudLog', True)
  else
    INIFile.WriteBool('SetLog', 'AutoCloudLog', False);

  if CheckBox9.Checked then
    INIFile.WriteBool('SetLog', 'FreqToCloudLog', True)
  else
    INIFile.WriteBool('SetLog', 'FreqToCloudLog', False);
  DBRecord.MySQLDBName := Edit5.Text;
  DBRecord.MySQLHost := Edit1.Text;
  DBRecord.MySQLPort := StrToInt(Edit2.Text);
  DBRecord.MySQLUser := Edit3.Text;
  DBRecord.MySQLPass := Edit4.Text;
  DBRecord.SQLitePATH := FileNameEdit1.Text;
end;

procedure TConfigForm.ReadINI;
begin
  Edit1.Text := INIFile.ReadString('DataBases', 'HostAddr', '');
  if INIFile.ReadString('DataBases', 'Port', '') = '' then
    Edit2.Text := '3306'
  else
    Edit2.Text := INIFile.ReadString('DataBases', 'Port', '');
  Edit3.Text := INIFile.ReadString('DataBases', 'LoginName', '');
  Edit4.Text := INIFile.ReadString('DataBases', 'Password', '');
  Edit5.Text := INIFile.ReadString('DataBases', 'DataBaseName', '');
  Edit11.Text := INIFile.ReadString('TelnetCluster', 'Login', '');
  Edit12.Text := INIFile.ReadString('TelnetCluster', 'Password', '');

  Edit10.Text := INIFile.ReadString('SetLog', 'CloudLogServer', '');
  Edit13.Text := INIFile.ReadString('SetLog', 'CloudLogApi', '');
  CheckBox8.Checked := INIFile.ReadBool('SetLog', 'AutoCloudLog', False);
  CheckBox9.Checked := INIFile.ReadBool('SetLog', 'FreqToCloudLog', False);
  FileNameEdit1.Text := INIFile.ReadString('DataBases', 'FileSQLite', '');
  if INIFile.ReadString('DataBases', 'DefaultDataBase', '') = 'MySQL' then
    RadioButton1.Checked := True
  else
    RadioButton2.Checked := True;

  CheckBox1.Checked := INIFile.ReadBool('SetLog', 'IntCallBook', False);
  CheckBox2.Checked := INIFile.ReadBool('SetLog', 'ShowBand', False);
  Edit6.Text := INIFile.ReadString('SetLog', 'QRZRU_Login', '');
  Edit7.Text := INIFile.ReadString('SetLog', 'QRZRU_Pass', '');
  Edit8.Text := INIFile.ReadString('SetLog', 'QRZCOM_Login', '');
  Edit9.Text := INIFile.ReadString('SetLog', 'QRZCOM_Pass', '');
  Edit14.Text := INIFile.ReadString('SetLog', 'HAMQTH_Login', '');
  Edit15.Text := INIFile.ReadString('SetLog', 'HAMQTH_Pass', '');

  CheckBox6.Checked := INIFile.ReadBool('SetLog', 'StateToQSLInfo', False);
  CheckBox5.Checked := INIFile.ReadBool('SetLog', 'PrintPrev', False);
  CheckBox4.Checked := INIFile.ReadBool('TelnetCluster', 'AutoStart', False);

  if IniSet.CallBookSystem = 'QRZRU' then
    CheckBox3.Checked := True;
  if IniSet.CallBookSystem = 'QRZCOM' then
    CheckBox7.Checked := True;
  if IniSet.CallBookSystem = 'HAMQTH' then
    CheckBox11.Checked := True;
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
      InitDB.MySQLConnection.HostName := Edit1.Text;
      InitDB.MySQLConnection.Port := StrToInt(Edit2.Text);
      InitDB.MySQLConnection.UserName := Edit3.Text;
      InitDB.MySQLConnection.Password := Edit4.Text;
      InitDB.MySQLConnection.DatabaseName := Edit5.Text;
      InitDB.MySQLConnection.Connected := False;
      InitDB.MySQLConnection.Connected := True;
      if InitDB.MySQLConnection.Connected then
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
    InitDB.ImbeddedCallBookInit(False);
    DownloadCallBookFile;
  end;
end;

procedure TConfigForm.CheckBox11Change(Sender: TObject);
begin
  if CheckBox11.Checked then
  begin
    CheckBox7.Checked := False;
    CheckBox3.Checked := False;
  end;
  if CheckBox11.Checked then
  begin
    INIFile.WriteString('SetLog', 'CallBookSystem', 'HAMQTH');
    IniSet.CallBookSystem := 'HAMQTH';
  end
  else
  begin
    INIFile.WriteString('SetLog', 'CallBookSystem', '');
    IniSet.CallBookSystem := '';
  end;
end;

procedure TConfigForm.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked then
  begin
    InitDB.ImbeddedCallBookInit(CheckBox1.Checked);
    IniSet.UseIntCallBook := True;
    INIFile.WriteBool('SetLog', 'IntCallBook', True);
  end
  else
  begin
    InitDB.ImbeddedCallBookInit(CheckBox1.Checked);
    IniSet.UseIntCallBook := False;
    INIFile.WriteBool('SetLog', 'IntCallBook', False);
  end;
end;

procedure TConfigForm.CheckBox2Change(Sender: TObject);
begin
  IniSet.showBand := CheckBox2.Checked;
  INIFile.WriteBool('SetLog', 'ShowBand', CheckBox2.Checked);
  MainFunc.LoadBMSL(MiniForm.CBMode, MiniForm.CBSubMode, MiniForm.CBBand);
  GridsForm.DBGrid1.Invalidate;
  GridsForm.DBGrid2.Invalidate;
  MainFunc.SetGrid(GridsForm.DBGrid1);
  MainFunc.SetGrid(GridsForm.DBGrid2);
  EditQSO_Form.DBGrid1.Invalidate;
end;

procedure TConfigForm.CheckBox3Change(Sender: TObject);
begin
  if CheckBox3.Checked = True then
  begin
    CheckBox7.Checked := False;
    CheckBox11.Checked := False;
  end;
  if CheckBox3.Checked then
  begin
    INIFile.WriteString('SetLog', 'CallBookSystem', 'QRZRU');
    IniSet.CallBookSystem := 'QRZRU';
  end
  else
  begin
    INIFile.WriteString('SetLog', 'CallBookSystem', '');
    IniSet.CallBookSystem := '';
  end;
end;

procedure TConfigForm.CheckBox6Change(Sender: TObject);
begin
  IniSet.StateToQSLInfo := CheckBox6.Checked;
end;

procedure TConfigForm.CheckBox7Change(Sender: TObject);
begin
  if CheckBox7.Checked = True then
  begin
    CheckBox3.Checked := False;
    CheckBox11.Checked := False;
  end;
  if CheckBox7.Checked then
  begin
    INIFile.WriteString('SetLog', 'CallBookSystem', 'QRZCOM');
    IniSet.CallBookSystem := 'QRZCOM';
  end
  else
  begin
    INIFile.WriteString('SetLog', 'CallBookSystem', '');
    IniSet.CallBookSystem := '';
  end;
end;

procedure TConfigForm.FormCreate(Sender: TObject);
begin
  ReadINI;
end;

procedure TConfigForm.FormShow(Sender: TObject);
var
  CheckRec: TImbedCallBookCheckRec;
begin
  ReadINI;
  Button4.Caption := rCheckUpdates;

  CheckRec := InitDB.ImbeddedCallBookCheck(FilePATH + 'callbook.db');
  InitDB.ImbeddedCallBookInit(IniSet.UseIntCallBook);
  if CheckRec.Found then
  begin
    Label11.Caption := rNumberOfRecords + IntToStr(CheckRec.NumberOfRec);
    Label14.Caption := CheckRec.Version;
    Label10.Caption := rReleaseDate + CheckRec.ReleaseDate;
    CheckBox1.Enabled := True;
  end
  else
  begin
    gbIntRef.Caption := rNoReferenceBookFound;
    label11.Caption := rNumberOfRecordsNot;
    Label10.Caption := rReleaseDateNot;
    Label14.Caption := '---';
    InitDB.ImbeddedCallBookInit(False);
    CheckBox1.Checked := False;
    CheckBox1.Enabled := False;
  end;
end;

procedure TConfigForm.Button1Click(Sender: TObject);
begin
  SaveINI;
  IniSet.Cluster_Login := Edit11.Text;
  IniSet.Cluster_Pass := Edit12.Text;
  MainFunc.LoadINIsettings;
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
  updatePATH := FilePATH;
  if not DirectoryExists(updatePATH + 'updates' + DirectorySeparator) then
    ForceDirectories(updatePATH + 'updates' + DirectorySeparator);
  with THTTPSend.Create do
  begin
    Label12.Caption := rStatusUpdateCheck;
    LoadFile := TFileStream.Create(updatePATH + 'updates' +
      DirectorySeparator + 'versioncallbook.info', fmCreate);
    if HTTPMethod('GET', 'http://update.ew8bak.ru/versioncallbook.info') then
    begin
      HttpGetBinary('http://update.ew8bak.ru/versioncallbook.info', LoadFile);
      LoadFile.Free;
    end
    else
    begin
      LoadFile.Seek(0, soFromEnd);
      LoadFile.WriteBuffer('5.5', Length('5.5'));
      LoadFile.Free;
    end;
    Free;
  end;
  AssignFile(VerFile, updatePATH + 'updates' + DirectorySeparator +
    'versioncallbook.info');

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
  CheckRec: TImbedCallBookCheckRec;
begin
  Download := 0;
  MaxSize := 0;
  MaxSize := dmFunc.GetSize(DownIntCallbookURL);
  if MaxSize > 0 then
    ProgressBar1.Max := MaxSize
  else
    ProgressBar1.Max := 0;
  HTTP := THTTPSend.Create;
  HTTP.Sock.OnStatus := @SynaProgress;
  Label12.Caption := rStatusUpdateDownload;
  try
    if HTTP.HTTPMethod('GET', DownIntCallbookURL) then
      HTTP.Document.SaveToFile(FilePATH + 'updates' + DirectorySeparator +
        'callbook.db');
  finally
    HTTP.Free;

    if FileUtil.CopyFile(FilePATH + 'updates' + DirectorySeparator +
      'callbook.db', FilePATH + 'callbook.db', True, True) then
      CheckRec := InitDB.ImbeddedCallBookCheck(FilePATH + 'callbook.db');

    if CheckRec.Found then
    begin
      Label11.Caption := rNumberOfRecords + IntToStr(CheckRec.NumberOfRec);
      Label14.Caption := CheckRec.Version;
      Label10.Caption := rReleaseDate + CheckRec.ReleaseDate;
      InitDB.ImbeddedCallBookInit(True);
      CheckBox1.Checked := True;
      CheckBox1.Enabled := True;
      gbIntRef.Caption := rReferenceBook;
      Button4.Caption := rOK;
    end
    else
    begin
      gbIntRef.Caption := rNoReferenceBookFound;
      label11.Caption := rNumberOfRecordsNot;
      Label10.Caption := rReleaseDateNot;
      Label14.Caption := '---';
      InitDB.ImbeddedCallBookInit(False);
      CheckBox1.Checked := False;
      CheckBox1.Enabled := False;
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
      label17.Caption := rDownloadFile + IntToStr(Trunc(
        (Download / ProgressBar1.Max) * 100)) + '%';
    end
    else
      label17.Caption := rDownloadFile + IntToStr(Download) + rByte;
    Application.ProcessMessages;
  end;
end;

end.
