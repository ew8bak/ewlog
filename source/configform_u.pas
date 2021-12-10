(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit ConfigForm_U;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF WINDOWS}registry,{$ENDIF}
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, EditBtn, ComCtrls, LazUTF8, LazFileUtils,
  ResourceStr, const_u, ImbedCallBookCheckRec, LCLProc, ColorBox,
  Spin, Buttons, ExtCtrls, dmCat, serverDM_u, CWDaemonDM_u, IdStack,
  DownloadFilesThread, process;

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
    BtSave: TButton;
    BtCancel: TButton;
    BtCATDeafult: TButton;
    BtTCIDefault: TButton;
    Button3: TButton;
    Button4: TButton;
    btApplyColor: TButton;
    btDefaultColor: TButton;
    CBCatDataBit: TComboBox;
    CBCatRTSState: TComboBox;
    CBCatParity: TComboBox;
    CBCatHandshake: TComboBox;
    CBCatDTRState: TComboBox;
    CBRigNumberTCI: TComboBox;
    CheckBox1: TCheckBox;
    cbBackupDB: TCheckBox;
    cbBackupCloseDB: TCheckBox;
    cbQSL: TCheckBox;
    CBrigctldStart: TCheckBox;
    CBWOLEnable: TCheckBox;
    CheckBox11: TCheckBox;
    cbADIfiles: TCheckBox;
    cbBackupCloseADI: TCheckBox;
    cbQSLs: TCheckBox;
    cbDate: TCheckBox;
    cbTime: TCheckBox;
    cbBand: TCheckBox;
    cbCall: TCheckBox;
    cbMode: TCheckBox;
    cbName: TCheckBox;
    cbQTH: TCheckBox;
    CheckBox2: TCheckBox;
    cbState: TCheckBox;
    cbGrid: TCheckBox;
    cbRSTs: TCheckBox;
    cbRSTr: TCheckBox;
    cbIOTA: TCheckBox;
    cbManager: TCheckBox;
    cbQSLsDate: TCheckBox;
    cbQSLrDate: TCheckBox;
    cbLOTWrDate: TCheckBox;
    cbPrefix: TCheckBox;
    CheckBox3: TCheckBox;
    cbSubMode: TCheckBox;
    cbDXCC: TCheckBox;
    cbCQZone: TCheckBox;
    cbITUZone: TCheckBox;
    cbManualSet: TCheckBox;
    cbContinent: TCheckBox;
    cbValidDX: TCheckBox;
    cbQSLrVIA: TCheckBox;
    cbQSLsVIA: TCheckBox;
    cbUser: TCheckBox;
    CBTelnetStartUp: TCheckBox;
    cbNoCalcDXCC: TCheckBox;
    CBCWDaemon: TCheckBox;
    CBTCIEnable: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    cbTextColorGrid: TColorBox;
    cbBackColorGrid: TColorBox;
    cbTextSizeGrid: TComboBox;
    CBTransceiverModel: TComboBox;
    CBCatComPort: TComboBox;
    CBCatSpeed: TComboBox;
    CBCatStopBit: TComboBox;
    CBIntMobileSync: TComboBox;
    CBViewFreq: TComboBox;
    CBRigNumberHL: TComboBox;
    DEBackupPath: TDirectoryEdit;
    Edit1: TEdit;
    Edit10: TEdit;
    EditLoTWQTH: TEdit;
    EditLoTWKey: TEdit;
    EditRIGNameHL: TEdit;
    EditRIGNameTCI: TEdit;
    EditTCIAddress: TEdit;
    EditTCIPort: TEdit;
    EditSentSpotKey: TEdit;
    EditCwDaemonPort: TEdit;
    EditCwDaemonAddress: TEdit;
    EditTelnetName: TEdit;
    EditTelnetAdress: TEdit;
    EditTelnetPort: TEdit;
    EditTelnetLogin: TEdit;
    EditTelnetPassword: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    EditWOLPort: TEdit;
    EditWOLAddress: TEdit;
    EditExportKey: TEdit;
    EditImportKey: TEdit;
    EditCATAddress: TEdit;
    EditCATport: TEdit;
    EditCATCIaddress: TEdit;
    EditExtraCmd: TEdit;
    EditReferenceKey: TEdit;
    EditClearKey: TEdit;
    EditSaveKey: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    FileNameEdit1: TFileNameEdit;
    FNLoTWEdit: TFileNameEdit;
    FNPathRigctld: TFileNameEdit;
    gbIntRef: TGroupBox;
    gbTelnet: TGroupBox;
    GBQRZRU: TGroupBox;
    gbQRZCOM: TGroupBox;
    gbCloudLog: TGroupBox;
    gbHAMQTH: TGroupBox;
    gbMySQL: TGroupBox;
    gbSQLite: TGroupBox;
    gbDefaultDB: TGroupBox;
    gbGridsColor: TGroupBox;
    GBTelnetEdit: TGroupBox;
    GBCWDaemon: TGroupBox;
    GBLoTW: TGroupBox;
    LBLoTWWarning: TLabel;
    LBLoTWKey: TLabel;
    LBLoTWQTH: TLabel;
    LBLoTWPath: TLabel;
    LBRigNameHL: TLabel;
    LBRigNameHL1: TLabel;
    LBRigNumberHL: TLabel;
    LBRigNumberHL1: TLabel;
    LBViewFreq: TLabel;
    LBSyncMobile: TLabel;
    LBTCIAddress: TLabel;
    LBTCIPort: TLabel;
    LBKeySendSpot: TLabel;
    LBCwDaemonAddress: TLabel;
    LBCwDaemonWPM: TLabel;
    LBCwDaemonPort: TLabel;
    LBTelnetName: TLabel;
    LBTelnetPort: TLabel;
    LBTelnetAddress: TLabel;
    LBCallWOL: TLabel;
    LBWOLLog: TLabel;
    LBWOLPort: TLabel;
    LBWOLAddress: TLabel;
    LBKeyExport: TLabel;
    LBKeyImport: TLabel;
    LBPoll: TLabel;
    LBCatRTSState: TLabel;
    LBCatCIVaddress: TLabel;
    LBCatParity: TLabel;
    LBCatDTRState: TLabel;
    LBCatStopBit: TLabel;
    LBCatSpeed: TLabel;
    LBCatHandshake: TLabel;
    LBComCATPort: TLabel;
    LBCATPort: TLabel;
    LBCATAddress: TLabel;
    LBCatDataBit: TLabel;
    LBExtraCmd: TLabel;
    LBPathRigctld: TLabel;
    LBTransceiverModel: TLabel;
    lbTextColor: TLabel;
    lbBackColor: TLabel;
    Label7: TLabel;
    lbTextSize: TLabel;
    LBGetReference: TLabel;
    lbClearQSO: TLabel;
    lbSaveQSO: TLabel;
    lbTimeBackup: TLabel;
    lbPathBackup: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    LBTelnetLogin: TLabel;
    LBTelnetPassword: TLabel;
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
    LBWOLCall: TListBox;
    LVSettings: TListView;
    LVTelnet: TListView;
    MWOLLog: TMemo;
    PanelBottom: TPanel;
    PCCat: TPageControl;
    PControl2: TPageControl;
    PControl: TPageControl;
    ProgressBar1: TProgressBar;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    PColors: TTabSheet;
    PGrids: TTabSheet;
    SBTelnetDone: TSpeedButton;
    SBTelnetDelete: TSpeedButton;
    SpinEdit1: TSpinEdit;
    SECWDaemonWPM: TSpinEdit;
    TSLoTW: TTabSheet;
    TSCW: TTabSheet;
    TSWorkLAN: TTabSheet;
    TSHamlib: TTabSheet;
    TSTCI: TTabSheet;
    TSCAT: TTabSheet;
    TColorandGrids: TTabSheet;
    THotKey: TTabSheet;
    timeEdit: TTimeEdit;
    TSBackup: TTabSheet;
    TSTelnet: TTabSheet;
    TSIntRef: TTabSheet;
    TSOtherSettings: TTabSheet;
    TSRefOnline: TTabSheet;
    TSBase: TTabSheet;
    procedure btApplyColorClick(Sender: TObject);
    procedure BtCATDeafultClick(Sender: TObject);
    procedure btDefaultColorClick(Sender: TObject);
    procedure BtSaveClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtTCIDefaultClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CBRigNumberHLSelect(Sender: TObject);
    procedure CBRigNumberTCISelect(Sender: TObject);
    procedure CBTransceiverModelSelect(Sender: TObject);
    procedure CBViewFreqChange(Sender: TObject);
    procedure CheckBox11Change(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox6Change(Sender: TObject);
    procedure CheckBox7Change(Sender: TObject);
    procedure EditClearKeyKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditExportKeyKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditImportKeyKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditReferenceKeyKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditSaveKeyKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditSentSpotKeyKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditTelnetAdressChange(Sender: TObject);
    procedure EditTelnetNameChange(Sender: TObject);
    procedure EditTelnetPortChange(Sender: TObject);
    procedure FNPathRigctldChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LVSettingsClick(Sender: TObject);
    procedure LVTelnetSelectItem(Sender: TObject; Item: TListItem;
      Selected: boolean);
    procedure PControlChange(Sender: TObject);
    procedure SBTelnetDeleteClick(Sender: TObject);
    procedure SBTelnetDoneClick(Sender: TObject);
    procedure TSHamlibShow(Sender: TObject);
    procedure TSIntRefShow(Sender: TObject);
    procedure TSLoTWShow(Sender: TObject);
    procedure TSOtherSettingsShow(Sender: TObject);
    procedure TSTCIShow(Sender: TObject);
    procedure TSTelnetShow(Sender: TObject);
  private
    LVSelectedItem: boolean;
    updatePATH: string;
    procedure SaveGridColumns;
    procedure SaveGridColors;
    procedure ReadGridColumns;
    procedure ReadGridColors;
    procedure LoadRIGSettings(RIGid: integer);
    procedure SaveRIGSettings;
    procedure LoadTCISettings(RIGid: integer);
    procedure SaveTCISettings;
    procedure EnableTelnetBTDone;
    procedure SaveTelnetAddress;
    procedure LoadTelnetAddressToVLTelnet;
    function SearchLVTelnet(SearchText: string): boolean;
    procedure LoadLVSettingName;
    procedure SetDefaultRadio(radio: string);
    procedure SaveINI;
    procedure ReadINI;
    procedure DownloadCallBookFile;
    procedure CheckServerVersionFile;
    function CheckVersion(ServerVersion: string): boolean;
    { private declarations }
  public
    procedure DataFromDownloadThread(status: TdataThread);

    { public declarations }
  end;

var
  ConfigForm: TConfigForm;

implementation

uses
  miniform_u, dmFunc_U, editqso_u, InitDB_dm, MainFuncDM, GridsForm_u,
  TRXForm_U, dmTCI_u;

{$R *.lfm}

{ TConfigForm }

procedure TConfigForm.DataFromDownloadThread(status: TdataThread);
var
  CheckRec: TImbedCallBookCheckRec;
begin
  if status.ShowStatus then
  begin
    ProgressBar1.Position := status.DownloadedPercent;
  end;

  if (status.Version) and (status.Message <> '') then
    CheckVersion(status.Message);

  if (status.StatusDownload) and (status.Other = 'DownloadCallBookFile') then
  begin
    if FileUtil.CopyFile(updatePATH + 'callbook.db', FilePATH +
      'callbook.db', True, True) then
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

procedure TConfigForm.CheckServerVersionFile;
const
  fileName = 'versioncallbook';
begin
  DownloadFilesTThread := TDownloadFilesThread.Create;
  if Assigned(DownloadFilesTThread.FatalException) then
    raise DownloadFilesTThread.FatalException;
  with DownloadFilesTThread do
  begin
    DataFromForm.FromForm := 'ConfigForm';
    DataFromForm.Version := True;
    DataFromForm.URLDownload := DownPATHssl + fileName;
    DataFromForm.PathSaveFile := updatePATH + fileName;
    Start;
  end;
end;

procedure TConfigForm.DownloadCallBookFile;
const
  fileName = 'callbook.db';
begin
  DownloadFilesTThread := TDownloadFilesThread.Create;
  if Assigned(DownloadFilesTThread.FatalException) then
    raise DownloadFilesTThread.FatalException;
  with DownloadFilesTThread do
  begin
    DataFromForm.FromForm := 'ConfigForm';
    DataFromForm.ShowStatus := True;
    DataFromForm.Other := 'DownloadCallBookFile';
    DataFromForm.URLDownload := DownPATHssl + fileName;
    DataFromForm.PathSaveFile := updatePATH + fileName;
    Start;
  end;
end;

function TConfigForm.CheckVersion(ServerVersion: string): boolean;
var
  LocalVersion: string;
begin
  Result := False;
  Label12.Caption := rStatusUpdateactual;

  if Label14.Caption <> '---' then
  begin
    LocalVersion := StringReplace(Label14.Caption, ',', '.', [rfReplaceAll]);
    if MainFunc.CompareVersion(LocalVersion, ServerVersion) then
    begin
      Label12.Caption := rStatusUpdateRequires;
      Result := True;
      Button4.Caption := rDownload;
    end;
  end
  else
  begin
    Label12.Caption := rStatusUpdateRequires;
    Result := True;
    Button4.Caption := rDownload;
  end;
end;

procedure TConfigForm.Button4Click(Sender: TObject);
begin
  if Button4.Caption = rCheckUpdates then
    CheckServerVersionFile
  else
  if Button4.Caption = rDownload then
  begin
    InitDB.ImbeddedCallBookInit(False);
    DownloadCallBookFile;
  end;
end;

procedure TConfigForm.SetDefaultRadio(radio: string);
begin
  INIFile.WriteString('SetCAT', 'CurrentRIG', radio);
  IniSet.CurrentRIG := radio;
end;

procedure TConfigForm.LoadLVSettingName;
var
  ListItem: TListItem;
  i: integer;
begin
  LVSettings.Clear;
  PControl.PageCount;
  for i := 0 to PControl.PageCount - 1 do
  begin
    ListItem := LVSettings.Items.Add;
    ListItem.Caption := PControl.Pages[i].Caption;
  end;
end;

procedure TConfigForm.SaveINI;
begin
  INIFile.WriteString('DataBases', 'HostAddr', Edit1.Text);
  INIFile.WriteString('DataBases', 'Port', Edit2.Text);
  INIFile.WriteString('DataBases', 'LoginName', Edit3.Text);
  INIFile.WriteString('DataBases', 'Password', Edit4.Text);
  INIFile.WriteString('DataBases', 'DataBaseName', Edit5.Text);
  INIFile.WriteString('DataBases', 'FileSQLite', FileNameEdit1.Text);
  INIFile.WriteString('TelnetCluster', 'Login', EditTelnetLogin.Text);
  INIFile.WriteString('TelnetCluster', 'Password', EditTelnetPassword.Text);
  INIFile.WriteBool('TelnetCluster', 'AutoStart', CBTelnetStartUp.Checked);
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

  INIFile.WriteBool('SetLog', 'PrintPrev', CheckBox5.Checked);
  INIFile.WriteBool('SetLog', 'AutoCloudLog', CheckBox8.Checked);
  INIFile.WriteBool('SetLog', 'FreqToCloudLog', CheckBox9.Checked);

  DBRecord.MySQLDBName := Edit5.Text;
  DBRecord.MySQLHost := Edit1.Text;
  DBRecord.MySQLPort := StrToInt(Edit2.Text);
  DBRecord.MySQLUser := Edit3.Text;
  DBRecord.MySQLPass := Edit4.Text;
  DBRecord.SQLitePATH := FileNameEdit1.Text;

  INIFile.WriteString('SetBackup', 'PathBackupFiles', DEBackupPath.Directory);
  INIFile.WriteBool('SetBackup', 'BackupDB', cbBackupDB.Checked);
  INIFile.WriteBool('SetBackup', 'BackupADI', cbADIfiles.Checked);
  INIFile.WriteBool('SetBackup', 'BackupADIonClose', cbBackupCloseADI.Checked);
  INIFile.WriteBool('SetBackup', 'BackupDBonClose', cbBackupCloseDB.Checked);
  INIFile.WriteTime('SetBackup', 'BackupTime', timeEdit.Time);

  INIFile.WriteString('Key', 'Save', EditSaveKey.Text);
  INIFile.WriteString('Key', 'Clear', EditClearKey.Text);
  INIFile.WriteString('Key', 'Reference', EditReferenceKey.Text);
  INIFile.WriteString('Key', 'ImportADI', EditImportKey.Text);
  INIFile.WriteString('Key', 'ExportADI', EditExportKey.Text);
  INIFile.WriteString('Key', 'SentSpot', EditSentSpotKey.Text);

  INIFile.WriteString('WorkOnLAN', 'Address', EditWOLAddress.Text);
  INIFile.WriteString('WorkOnLAN', 'Port', EditWOLPort.Text);
  INIFile.WriteBool('WorkOnLAN', 'Enable', CBWOLEnable.Checked);

  INIFile.WriteString('CWDaemon', 'Address', EditCwDaemonAddress.Text);
  INIFile.WriteInteger('CWDaemon', 'Port', StrToInt(EditCwDaemonPort.Text));
  INIFile.WriteInteger('CWDaemon', 'WPM', SECWDaemonWPM.Value);
  INIFile.WriteBool('CWDaemon', 'Enable', CBCWDaemon.Checked);
  if CBIntMobileSync.Text <> '' then
    INIFile.WriteString('SetLog', 'InterfaceMobileSync', CBIntMobileSync.Text);
  INIFile.WriteInteger('SetLog', 'ViewFreq', CBViewFreq.ItemIndex);

  INIFile.WriteString('LoTW', 'Path', FNLoTWEdit.Text);
  INIFile.WriteString('LoTW', 'QTH', EditLoTWQTH.Text);
  INIFile.WriteString('LoTW', 'Key', EditLoTWKey.Text);

  IniSet.Cluster_Login := EditTelnetLogin.Text;

end;

procedure TConfigForm.ReadINI;
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings.TimeSeparator := ':';
  FormatSettings.ShortTimeFormat := 'hh:mm';
  Edit1.Text := INIFile.ReadString('DataBases', 'HostAddr', '');
  if INIFile.ReadString('DataBases', 'Port', '') = '' then
    Edit2.Text := '3306'
  else
    Edit2.Text := INIFile.ReadString('DataBases', 'Port', '');
  Edit3.Text := INIFile.ReadString('DataBases', 'LoginName', '');
  Edit4.Text := INIFile.ReadString('DataBases', 'Password', '');
  Edit5.Text := INIFile.ReadString('DataBases', 'DataBaseName', '');
  EditTelnetLogin.Text := IniSet.Cluster_Login;
  EditTelnetPassword.Text := IniSet.Cluster_Pass;

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
  CBTelnetStartUp.Checked := INIFile.ReadBool('TelnetCluster', 'AutoStart', False);

  if IniSet.CallBookSystem = 'QRZRU' then
    CheckBox3.Checked := True;
  if IniSet.CallBookSystem = 'QRZCOM' then
    CheckBox7.Checked := True;
  if IniSet.CallBookSystem = 'HAMQTH' then
    CheckBox11.Checked := True;

  DEBackupPath.Directory := INIFile.ReadString('SetBackup', 'PathBackupFiles', '');
  cbBackupDB.Checked := INIFile.ReadBool('SetBackup', 'BackupDB', False);
  cbADIfiles.Checked := INIFile.ReadBool('SetBackup', 'BackupADI', False);
  cbBackupCloseADI.Checked := INIFile.ReadBool('SetBackup', 'BackupADIonClose', False);
  cbBackupCloseDB.Checked := INIFile.ReadBool('SetBackup', 'BackupDBonClose', False);
  timeEdit.Time := INIFile.ReadTime('SetBackup', 'BackupTime',
    StrToTime('12:00', FormatSettings));

  EditSaveKey.Text := INIFile.ReadString('Key', 'Save', 'Alt+S');
  EditClearKey.Text := INIFile.ReadString('Key', 'Clear', 'Alt+C');
  EditReferenceKey.Text := INIFile.ReadString('Key', 'Reference', 'Enter');
  EditImportKey.Text := INIFile.ReadString('Key', 'ImportADI', 'Alt+I');
  EditExportKey.Text := INIFile.ReadString('Key', 'ExportADI', 'Alt+E');
  EditSentSpotKey.Text := INIFile.ReadString('Key', 'SentSpot', 'Alt+D');

  EditWOLAddress.Text := INIFile.ReadString('WorkOnLAN', 'Address', '0.0.0.0');
  EditWOLPort.Text := INIFile.ReadString('WorkOnLAN', 'Port', '2238');
  CBWOLEnable.Checked := INIFile.ReadBool('WorkOnLAN', 'Enable', False);

  EditCwDaemonAddress.Text := INIFile.ReadString('CWDaemon', 'Address', '127.0.0.1');
  EditCwDaemonPort.Text := IntToStr(INIFile.ReadInteger('CWDaemon', 'Port', 6789));
  SECWDaemonWPM.Value := INIFile.ReadInteger('CWDaemon', 'WPM', 24);
  CBCWDaemon.Checked := INIFile.ReadBool('CWDaemon', 'Enable', False);

  CBViewFreq.ItemIndex := INIFile.ReadInteger('SetLog', 'ViewFreq', 0);

  FNLoTWEdit.Text := INIFile.ReadString('LoTW', 'Path', '');
  EditLoTWQTH.Text := INIFile.ReadString('LoTW', 'QTH', '');
  EditLoTWKey.Text := INIFile.ReadString('LoTW', 'Key', '');

  ReadGridColumns;
  ReadGridColors;
end;

procedure TConfigForm.BtCancelClick(Sender: TObject);
begin
  ConfigForm.Close;
end;

procedure TConfigForm.BtTCIDefaultClick(Sender: TObject);
begin
  if CBRigNumberTCI.ItemIndex <> -1 then
    SetDefaultRadio('TCI' + CBRigNumberTCI.Text);
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

procedure TConfigForm.CBRigNumberHLSelect(Sender: TObject);
begin
  LoadRIGSettings(StrToInt(CBRigNumberHL.Text));
end;

procedure TConfigForm.CBRigNumberTCISelect(Sender: TObject);
begin
  LoadTCISettings(StrToInt(CBRigNumberTCI.Text));
end;

procedure TConfigForm.CBTransceiverModelSelect(Sender: TObject);
var
  TrscvName: string;
begin
  TrscvName := CBTransceiverModel.Text;
  Delete(TrscvName, 1, pos(' ', TrscvName));
  EditRIGNameHL.Text := TrimRight(TrscvName);
end;

procedure TConfigForm.CBViewFreqChange(Sender: TObject);
begin
  IniSet.ViewFreq := CBViewFreq.ItemIndex;
  MainFunc.LoadBMSL(MiniForm.CBMode, MiniForm.CBSubMode, MiniForm.CBBand);
  GridsForm.DBGrid1.Invalidate;
  GridsForm.DBGrid2.Invalidate;
  MainFunc.SetGrid(GridsForm.DBGrid1);
  MainFunc.SetGrid(GridsForm.DBGrid2);
  EditQSO_Form.DBGrid1.Invalidate;
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

procedure TConfigForm.EditClearKeyKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  EditClearKey.Text := KeyAndShiftStateToKeyString(Key, Shift);
  Key := 0;
  EditClearKey.SelStart := EditClearKey.GetTextLen;
end;

procedure TConfigForm.EditExportKeyKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  EditExportKey.Text := KeyAndShiftStateToKeyString(Key, Shift);
  Key := 0;
  EditExportKey.SelStart := EditExportKey.GetTextLen;
end;

procedure TConfigForm.EditImportKeyKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  EditImportKey.Text := KeyAndShiftStateToKeyString(Key, Shift);
  Key := 0;
  EditImportKey.SelStart := EditImportKey.GetTextLen;
end;

procedure TConfigForm.EditReferenceKeyKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  EditReferenceKey.Text := KeyAndShiftStateToKeyString(Key, Shift);
  Key := 0;
  EditReferenceKey.SelStart := EditReferenceKey.GetTextLen;
end;

procedure TConfigForm.EditSaveKeyKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  EditSaveKey.Text := KeyAndShiftStateToKeyString(Key, Shift);
  Key := 0;
  EditSaveKey.SelStart := EditSaveKey.GetTextLen;
end;

procedure TConfigForm.EditSentSpotKeyKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  EditSentSpotKey.Text := KeyAndShiftStateToKeyString(Key, Shift);
  Key := 0;
  EditSentSpotKey.SelStart := EditSentSpotKey.GetTextLen;
end;

procedure TConfigForm.EnableTelnetBTDone;
begin
  if (Length(EditTelnetName.Text) > 0) and (Length(EditTelnetAdress.Text) > 0) and
    (Length(EditTelnetPort.Text) > 0) then
    SBTelnetDone.Enabled := True
  else
    SBTelnetDone.Enabled := False;
end;

procedure TConfigForm.EditTelnetAdressChange(Sender: TObject);
begin
  EnableTelnetBTDone;
end;

procedure TConfigForm.EditTelnetNameChange(Sender: TObject);
begin
  EnableTelnetBTDone;
end;

procedure TConfigForm.EditTelnetPortChange(Sender: TObject);
begin
  EnableTelnetBTDone;
end;

procedure TConfigForm.FNPathRigctldChange(Sender: TObject);
begin
  if Length(FNPathRigctld.Text) > 0 then
    CBTransceiverModel.Items.CommaText := CATdm.LoadRIGs(FNPathRigctld.Text, 1);
end;

procedure TConfigForm.FormCreate(Sender: TObject);
begin
  ReadINI;
  {$IFDEF WINDOWS}
  FNLoTWEdit.Filter := 'tqsl.exe|tqsl.exe';
  {$ELSE}
  FNLoTWEdit.Filter := 'tqsl|tqsl';
  {$ENDIF}
end;

procedure TConfigForm.LoadRIGSettings(RIGid: integer);
begin
  CBCatComPort.Items.CommaText := CATdm.GetSerialPortNames;
  FNPathRigctld.Text := IniSet.rigctldPath;
  {$IFDEF WINDOWS}
  FNPathRigctld.Filter := 'rigctld.exe|rigctld.exe';
  {$ELSE}
  FNPathRigctld.Filter := 'rigctld|rigctld';
  if Length(CatSettings.RigctldPath) = 0 then
    FNPathRigctld.Text := CATdm.SearchRigctld;
  CatSettings.RigctldPath := CATdm.SearchRigctld;
  {$ENDIF}
  CBrigctldStart.Checked := IniSet.rigctldStartUp;
  CBTransceiverModel.Items.CommaText := CATdm.LoadRIGs(FNPathRigctld.Text, 1);
  CATdm.LoadCATini(RIGid);
  CBRigNumberHL.ItemIndex := RIGid - 1;
  CBCatComPort.Text := CatSettings.COMPort;
  CBCatSpeed.ItemIndex := CatSettings.Speed;
  CBCatStopBit.ItemIndex := CatSettings.StopBit;
  CBCatDataBit.ItemIndex := CatSettings.DataBit;
  CBCatParity.ItemIndex := CatSettings.Parity;
  CBCatHandshake.ItemIndex := CatSettings.Handshake;
  CBCatRTSState.ItemIndex := CatSettings.RTSstate;
  CBCatDTRState.ItemIndex := CatSettings.DTRstate;
  EditCATCIaddress.Text := CatSettings.CIVaddress;
  EditCATAddress.Text := CatSettings.Address;
  EditCATport.Text := IntToStr(CatSettings.Port);
  EditExtraCmd.Text := CatSettings.Extracmd;
  CBrigctldStart.Checked := CatSettings.StartRigctld;
  CBTransceiverModel.Text := IntToStr(CatSettings.TransceiverNum) +
    ' ' + CatSettings.TransceiverName;
  EditRIGNameHL.Text := CatSettings.TransceiverName;
end;

procedure TConfigForm.SaveRIGSettings;
var
  TrscvName: string;
begin
  if Length(CBTransceiverModel.Text) > 1 then
  begin
    if Length(EditRIGNameHL.Text) > 0 then
      CatSettings.TransceiverName := EditRIGNameHL.Text
    else
    begin
      TrscvName := CBTransceiverModel.Text;
      Delete(TrscvName, 1, pos(' ', TrscvName));
      CatSettings.TransceiverName := TrscvName;
    end;

    CatSettings.COMPort := CBCatComPort.Text;
    CatSettings.Speed := CBCatSpeed.ItemIndex;
    CatSettings.StopBit := CBCatStopBit.ItemIndex;
    CatSettings.DataBit := CBCatDataBit.ItemIndex;
    CatSettings.Parity := CBCatParity.ItemIndex;
    CatSettings.Handshake := CBCatHandshake.ItemIndex;
    CatSettings.RTSstate := CBCatRTSState.ItemIndex;
    CatSettings.DTRstate := CBCatDTRState.ItemIndex;
    CatSettings.CIVaddress := EditCATCIaddress.Text;
    CatSettings.TransceiverNum :=
      dmFunc.GetRigIdFromComboBoxItem(CBTransceiverModel.Text);
    CatSettings.Address := EditCATAddress.Text;
    CatSettings.Port := StrToInt(EditCATport.Text);
    CatSettings.Extracmd := EditExtraCmd.Text;
    CatSettings.StartRigctld := CBrigctldStart.Checked;
    CatSettings.RigctldPath := FNPathRigctld.Text;
    CATdm.SaveCATini(CBRigNumberHL.ItemIndex + 1);
  end;
end;

procedure TConfigForm.LoadTCISettings(RIGid: integer);
begin
  dmTCI.LoadTCIini(RIGid);
  CBRigNumberTCI.ItemIndex := RIGid - 1;
  EditTCIAddress.Text := TCISettings.Address;
  EditTCIPort.Text := IntToStr(TCISettings.Port);
  EditRIGNameTCI.Text := TCISettings.Name;
  CBTCIEnable.Checked := TCISettings.Enable;
end;

procedure TConfigForm.SaveTCISettings;
begin
  if Length(EditRIGNameTCI.Text) > 1 then
  begin
    TCISettings.Address := EditTCIAddress.Text;
    TCISettings.Port := StrToInt(EditTCIPort.Text);
    TCISettings.Name := EditRIGNameTCI.Text;
    TCISettings.Enable := CBTCIEnable.Checked;
    dmTCI.SaveTCIini(CBRigNumberTCI.ItemIndex + 1);
    // dmTCI.InicializeTCI(CBRigNumberTCI.ItemIndex + 1);
  end;
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
  LoadLVSettingName;
end;

procedure TConfigForm.LVSettingsClick(Sender: TObject);
begin
  try
    if LVSettings.Selected.Selected then
      PControl.PageIndex := LVSettings.Selected.Index;
  except
  end;
end;

procedure TConfigForm.LVTelnetSelectItem(Sender: TObject; Item: TListItem;
  Selected: boolean);
begin
  if Selected then
  begin
    EditTelnetName.Text := LVTelnet.Selected.Caption;
    EditTelnetAdress.Text := LVTelnet.Selected.SubItems[0];
    EditTelnetPort.Text := LVTelnet.Selected.SubItems[1];
    LVSelectedItem := True;
    SBTelnetDelete.Enabled := True;
  end;
end;

procedure TConfigForm.PControlChange(Sender: TObject);
begin
  LVSettings.ItemIndex := PControl.PageIndex;
end;

function TConfigForm.SearchLVTelnet(SearchText: string): boolean;
var
  i: integer;
begin
  Result := False;
  for i := 0 to LVTelnet.Items.Count - 1 do
    if Pos(LowerCase(SearchText), LowerCase(LVTelnet.Items.Item[i].Caption)) > 0 then
      Result := True;
end;

procedure TConfigForm.LoadTelnetAddressToVLTelnet;
var
  i: integer;
  ListItem: TListItem;
begin
  LVTelnet.Items.Clear;
  for i := 0 to High(TARecord) do
  begin
    if Length(TARecord[i].Name) <> 0 then
    begin
      ListItem := LVTelnet.Items.Add;
      ListItem.Caption := TARecord[i].Name;
      ListItem.SubItems.Add(TARecord[i].Address);
      ListItem.SubItems.Add(IntToStr(TARecord[i].Port));
    end;
  end;
end;

procedure TConfigForm.SaveTelnetAddress;
var
  ListItem: TListItem;
  i: integer;
begin
  if LVSelectedItem then
  begin
    LVTelnet.Selected.Caption := EditTelnetName.Text;
    LVTelnet.Selected.SubItems[0] := EditTelnetAdress.Text;
    LVTelnet.Selected.SubItems[1] := EditTelnetPort.Text;
    INIFile.WriteString('TelnetCluster', 'Server' + IntToStr(LVTelnet.Selected.Index),
      EditTelnetName.Text + ',' + EditTelnetAdress.Text + ',' + EditTelnetPort.Text);
  end
  else
  begin
    if not SearchLVTelnet(EditTelnetName.Text) then
    begin
      ListItem := LVTelnet.Items.Add;
      ListItem.Caption := EditTelnetName.Text;
      ListItem.SubItems.Add(EditTelnetAdress.Text);
      ListItem.SubItems.Add(EditTelnetPort.Text);
      for i := 0 to LVTelnet.Items.Count - 1 do
        INIFile.WriteString('TelnetCluster', 'Server' + IntToStr(i),
          LVTelnet.Items.Item[i].Caption + ',' + LVTelnet.Items.Item[i].SubItems[0] +
          ',' + LVTelnet.Items.Item[i].SubItems[1]);
    end
    else
      ShowMessage(rThisNameAlreadyExists);
  end;
  EditTelnetName.Clear;
  EditTelnetAdress.Clear;
  EditTelnetPort.Clear;
  LVSelectedItem := False;
  MainFunc.LoadTelnetAddress;
end;

procedure TConfigForm.ReadGridColumns;
begin
  cbQSL.Checked := INIFile.ReadBool('GridSettings', 'ColVisible0', True);
  cbQSLs.Checked := INIFile.ReadBool('GridSettings', 'ColVisible1', True);
  cbDate.Checked := INIFile.ReadBool('GridSettings', 'ColVisible2', True);
  cbTime.Checked := INIFile.ReadBool('GridSettings', 'ColVisible3', True);
  cbBand.Checked := INIFile.ReadBool('GridSettings', 'ColVisible4', True);
  cbCall.Checked := INIFile.ReadBool('GridSettings', 'ColVisible5', True);
  cbMode.Checked := INIFile.ReadBool('GridSettings', 'ColVisible6', True);
  cbSubMode.Checked := INIFile.ReadBool('GridSettings', 'ColVisible7', True);
  cbName.Checked := INIFile.ReadBool('GridSettings', 'ColVisible8', True);
  cbQTH.Checked := INIFile.ReadBool('GridSettings', 'ColVisible9', True);
  cbState.Checked := INIFile.ReadBool('GridSettings', 'ColVisible10', True);
  cbGrid.Checked := INIFile.ReadBool('GridSettings', 'ColVisible11', True);
  cbRSTs.Checked := INIFile.ReadBool('GridSettings', 'ColVisible12', True);
  cbRSTr.Checked := INIFile.ReadBool('GridSettings', 'ColVisible13', True);
  cbIOTA.Checked := INIFile.ReadBool('GridSettings', 'ColVisible14', True);
  cbManager.Checked := INIFile.ReadBool('GridSettings', 'ColVisible15', True);
  cbQSLsDate.Checked := INIFile.ReadBool('GridSettings', 'ColVisible16', True);
  cbQSLrDate.Checked := INIFile.ReadBool('GridSettings', 'ColVisible17', True);
  cbLOTWrDate.Checked := INIFile.ReadBool('GridSettings', 'ColVisible18', True);
  cbPrefix.Checked := INIFile.ReadBool('GridSettings', 'ColVisible19', True);
  cbDXCC.Checked := INIFile.ReadBool('GridSettings', 'ColVisible20', True);
  cbCQZone.Checked := INIFile.ReadBool('GridSettings', 'ColVisible21', True);
  cbITUZone.Checked := INIFile.ReadBool('GridSettings', 'ColVisible22', True);
  cbManualSet.Checked := INIFile.ReadBool('GridSettings', 'ColVisible23', True);
  cbContinent.Checked := INIFile.ReadBool('GridSettings', 'ColVisible24', True);
  cbValidDX.Checked := INIFile.ReadBool('GridSettings', 'ColVisible25', True);
  cbQSLrVIA.Checked := INIFile.ReadBool('GridSettings', 'ColVisible26', True);
  cbQSLsVIA.Checked := INIFile.ReadBool('GridSettings', 'ColVisible27', True);
  cbUser.Checked := INIFile.ReadBool('GridSettings', 'ColVisible28', True);
  cbNoCalcDXCC.Checked := INIFile.ReadBool('GridSettings', 'ColVisible29', True);
end;

procedure TConfigForm.SaveGridColors;
begin
  INIFile.WriteInteger('GridSettings', 'TextColor', cbTextColorGrid.Selected);
  INIFile.WriteInteger('GridSettings', 'BackColor', cbBackColorGrid.Selected);
  case cbTextSizeGrid.ItemIndex of
    0: INIFile.WriteInteger('GridSettings', 'TextSize', 8);
    1: INIFile.WriteInteger('GridSettings', 'TextSize', 10);
    2: INIFile.WriteInteger('GridSettings', 'TextSize', 12);
    3: INIFile.WriteInteger('GridSettings', 'TextSize', 14);
  end;
end;

procedure TConfigForm.ReadGridColors;
begin
  cbTextColorGrid.Selected := INIFile.ReadInteger('GridSettings', 'TextColor', 0);
  cbBackColorGrid.Selected :=
    INIFile.ReadInteger('GridSettings', 'BackColor', -2147483617);

  case INIFile.ReadInteger('GridSettings', 'TextSize', 8) of
    8: cbTextSizeGrid.ItemIndex := 0;
    10: cbTextSizeGrid.ItemIndex := 1;
    12: cbTextSizeGrid.ItemIndex := 2;
    14: cbTextSizeGrid.ItemIndex := 3;
  end;
end;

procedure TConfigForm.SaveGridColumns;
begin
  INIFile.WriteBool('GridSettings', 'ColVisible0', cbQSL.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible1', cbQSLs.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible2', cbDate.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible3', cbTime.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible4', cbBand.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible5', cbCall.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible6', cbMode.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible7', cbSubMode.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible8', cbName.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible9', cbQTH.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible10', cbState.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible11', cbGrid.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible12', cbRSTs.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible13', cbRSTr.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible14', cbIOTA.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible15', cbManager.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible16', cbQSLsDate.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible17', cbQSLrDate.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible18', cbLOTWrDate.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible19', cbPrefix.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible20', cbDXCC.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible21', cbCQZone.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible22', cbITUZone.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible23', cbManualSet.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible24', cbContinent.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible25', cbValidDX.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible26', cbQSLrVIA.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible27', cbQSLsVIA.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible28', cbUser.Checked);
  INIFile.WriteBool('GridSettings', 'ColVisible29', cbNoCalcDXCC.Checked);
end;

procedure TConfigForm.BtSaveClick(Sender: TObject);
begin
  SaveINI;
  IniSet.Cluster_Login := EditTelnetLogin.Text;
  IniSet.Cluster_Pass := EditTelnetPassword.Text;
  SaveGridColumns;
  SaveGridColors;
  SaveRIGSettings;
  SaveTCISettings;
  MainFunc.LoadINIsettings;
  MiniForm.SetHotKey;
  ServerDM.StartWOL;
  CWDaemonDM.StartCWDaemon;
  MainFunc.SetGrid(GridsForm.DBGrid1);
  MainFunc.SetGrid(GridsForm.DBGrid2);
  if CBIntMobileSync.Text <> '' then
    if IniSet.InterfaceMobileSync <> CBIntMobileSync.Text then
    begin
      IniSet.InterfaceMobileSync := CBIntMobileSync.Text;
      ServerDM.RestartMobileSync;
    end;
  ConfigForm.Close;
end;

procedure TConfigForm.btApplyColorClick(Sender: TObject);
begin
  SaveGridColors;
  MainFunc.SetGrid(GridsForm.DBGrid1);
  MainFunc.SetGrid(GridsForm.DBGrid2);
end;

procedure TConfigForm.BtCATDeafultClick(Sender: TObject);
begin
  if CBRigNumberHL.ItemIndex <> -1 then
    SetDefaultRadio('TRX' + CBRigNumberHL.Text);
end;

procedure TConfigForm.btDefaultColorClick(Sender: TObject);
begin
  cbTextSizeGrid.ItemIndex := 0;
  cbTextColorGrid.ItemIndex := cbTextColorGrid.Items.IndexOf('clBlack');
  cbBackColorGrid.ItemIndex := cbBackColorGrid.Items.IndexOf('clForm');
end;

procedure TConfigForm.SBTelnetDeleteClick(Sender: TObject);
var
  i: integer;
begin
  if LVSelectedItem then
  begin
    LVTelnet.Items.Delete(LVTelnet.Selected.Index);
    for i := 0 to 9 do
      INIFile.DeleteKey('TelnetCluster', 'Server' + IntToStr(i));
    for i := 0 to LVTelnet.Items.Count - 1 do
      INIFile.WriteString('TelnetCluster', 'Server' + IntToStr(i),
        LVTelnet.Items.Item[i].Caption + ',' + LVTelnet.Items.Item[i].SubItems[0] +
        ',' + LVTelnet.Items.Item[i].SubItems[1]);
    EditTelnetName.Clear;
    EditTelnetAdress.Clear;
    EditTelnetPort.Clear;
    LVSelectedItem := False;
    MainFunc.LoadTelnetAddress;
    SBTelnetDelete.Enabled := False;
  end;
end;

procedure TConfigForm.SBTelnetDoneClick(Sender: TObject);
begin
  SaveTelnetAddress;
  if LVSelectedItem then
    LVTelnet.Selected.Selected := False;
end;

procedure TConfigForm.TSHamlibShow(Sender: TObject);
begin
  try
    if IniSet.CurrentRIG <> '' then
      LoadRIGSettings(StrToInt(IniSet.CurrentRIG[4]));
  except
    LoadRIGSettings(1);
  end;
end;

procedure TConfigForm.TSIntRefShow(Sender: TObject);
begin
  updatePATH := FilePATH + 'updates' + DirectorySeparator;
  if not DirectoryExists(updatePATH) then
    ForceDirectories(updatePATH);
end;

procedure TConfigForm.TSLoTWShow(Sender: TObject);
var
  s: string;
  {$IFDEF WINDOWS}
  Reg: TRegistry;
  {$ENDIF}
begin
  LBLoTWWarning.Visible := False;
  if Length(FNLoTWEdit.Text) < 3 then
  begin
   {$IFDEF LINUX}
    if RunCommand('/bin/bash', ['-c', 'which tqsl'], s) then
    begin
      s := StringReplace(s, #10, '', [rfReplaceAll]);
      s := StringReplace(s, #13, '', [rfReplaceAll]);
      if Length(s) <> 0 then
        FNLoTWEdit.Text := s
      else
        LBLoTWWarning.Visible := True;
    end;
   {$ENDIF}
   {$IFDEF WINDOWS}
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.OpenKey('\Software\TrustedQSL', True) then
        s := Reg.ReadString('InstallPath');
    finally
      Reg.CloseKey;
      Reg.Free;
      if Length(s) <> 0 then
        FNLoTWEdit.Text := s
      else
        LBLoTWWarning.Visible := True;
    end;
   {$ENDIF}
  end;
end;

procedure TConfigForm.TSOtherSettingsShow(Sender: TObject);
begin
  CBIntMobileSync.Items.Clear;
  CBIntMobileSync.Items.AddStrings(GStack.LocalAddresses);
  if CBIntMobileSync.Items.IndexOf(IniSet.InterfaceMobileSync) <> -1 then
    CBIntMobileSync.ItemIndex :=
      CBIntMobileSync.Items.IndexOf(IniSet.InterfaceMobileSync)
  else
  if CBIntMobileSync.Items.Count > 0 then
    CBIntMobileSync.ItemIndex := 0;
end;

procedure TConfigForm.TSTCIShow(Sender: TObject);
begin
  if IniSet.CurrentRIG <> '' then
    LoadTCISettings(StrToInt(IniSet.CurrentRIG[4]));
end;

procedure TConfigForm.TSTelnetShow(Sender: TObject);
begin
  LVSelectedItem := False;
  SBTelnetDone.Enabled := False;
  SBTelnetDelete.Enabled := False;
  LoadTelnetAddressToVLTelnet;
end;

end.
