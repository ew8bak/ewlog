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
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, EditBtn, ComCtrls, LazUTF8, LazFileUtils, httpsend, blcksock,
  ResourceStr, synautil, const_u, ImbedCallBookCheckRec, LCLProc, ColorBox,
  Spin, Buttons, dmCat, serverDM_u, Types;

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
    btApplyColor: TButton;
    btDefaultColor: TButton;
    CBCatDataBit: TComboBox;
    CBCatRTSState: TComboBox;
    CBCatParity: TComboBox;
    CBCatHandshake: TComboBox;
    CBCatDTRState: TComboBox;
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
    DEBackupPath: TDirectoryEdit;
    Edit1: TEdit;
    Edit10: TEdit;
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
    LVTelnet: TListView;
    MWOLLog: TMemo;
    PCCat: TPageControl;
    PControl2: TPageControl;
    PControl: TPageControl;
    ProgressBar1: TProgressBar;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    PColors: TTabSheet;
    PGrids: TTabSheet;
    SBTelnetDone: TSpeedButton;
    SpinEdit1: TSpinEdit;
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
    procedure btDefaultColorClick(Sender: TObject);
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
    procedure EditTelnetAdressChange(Sender: TObject);
    procedure EditTelnetNameChange(Sender: TObject);
    procedure EditTelnetPortChange(Sender: TObject);
    procedure FNPathRigctldChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LVTelnetSelectItem(Sender: TObject; Item: TListItem;
      Selected: boolean);
    procedure SaveINI;
    procedure ReadINI;
    function CheckUpdate: boolean;
    procedure SBTelnetDoneClick(Sender: TObject);
    procedure SynaProgress(Sender: TObject; Reason: THookSocketReason;
      const Value: string);
    procedure DownloadCallBookFile;
    procedure TSTelnetShow(Sender: TObject);
  private
    Download: int64;
    LVSelectedItem: boolean;
    procedure SaveGridColumns;
    procedure SaveGridColors;
    procedure ReadGridColumns;
    procedure ReadGridColors;
    procedure LoadRIGSettings;
    procedure SaveRIGSettings;
    procedure EnableTelnetBTDone;
    procedure SaveTelnetAddress;
    procedure LoadTelnetAddress;
    { private declarations }
  public
    { public declarations }
  end;

var
  ConfigForm: TConfigForm;

implementation

uses
  miniform_u, dmFunc_U, editqso_u, InitDB_dm, MainFuncDM, GridsForm_u, TRXForm_U;

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

  INIFile.WriteString('WorkOnLAN', 'Address', EditWOLAddress.Text);
  INIFile.WriteString('WorkOnLAN', 'Port', EditWOLPort.Text);
  INIFile.WriteBool('WorkOnLAN', 'Enable', CBWOLEnable.Checked);

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
  EditTelnetLogin.Text := INIFile.ReadString('TelnetCluster', 'Login', '');
  EditTelnetPassword.Text := INIFile.ReadString('TelnetCluster', 'Password', '');

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

  EditWOLAddress.Text := INIFile.ReadString('WorkOnLAN', 'Address', '0.0.0.0');
  EditWOLPort.Text := INIFile.ReadString('WorkOnLAN', 'Port', '2238');
  CBWOLEnable.Checked := INIFile.ReadBool('WorkOnLAN', 'Enable', False);

  ReadGridColumns;
  ReadGridColors;
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
end;

procedure TConfigForm.LoadRIGSettings;
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
  CATdm.LoadCATini(1);
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
end;

procedure TConfigForm.SaveRIGSettings;
var
  TrscvName: string;
begin
  if Length(CBTransceiverModel.Text) > 1 then
  begin
    TrscvName := CBTransceiverModel.Text;
    Delete(TrscvName, 1, pos(' ', TrscvName));
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
    CatSettings.TransceiverName := TrscvName;
    CatSettings.Address := EditCATAddress.Text;
    CatSettings.Port := StrToInt(EditCATport.Text);
    CatSettings.Extracmd := EditExtraCmd.Text;
    CatSettings.StartRigctld := CBrigctldStart.Checked;
    CatSettings.RigctldPath := FNPathRigctld.Text;
    CATdm.SaveCATini(1);
    TRXForm.InicializeRig;
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
  LoadRIGSettings;
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
  end
  else
  begin
    EditTelnetName.Clear;
    EditTelnetAdress.Clear;
    EditTelnetPort.Clear;
    LVSelectedItem := False;
  end;
end;

procedure TConfigForm.LoadTelnetAddress;
var
  SLAddress: TStringList;
  i: integer;
begin
  try
    SLAddress := TStringList.Create;
    for i:=0 to 9 do
    if INIFile.ReadString('TelnetCluster', 'Server' + IntToStr(i), '') <> '' then
    SLAddress.Add(INIFile.ReadString('TelnetCluster', 'Server' + IntToStr(i), ''));

  finally
    FreeAndNil(SLAddress);
  end;
end;

procedure TConfigForm.SaveTelnetAddress;
begin
  if LVSelectedItem then
  begin
    LVTelnet.Selected.Caption := EditTelnetName.Text;
    LVTelnet.Selected.SubItems[0] := EditTelnetAdress.Text;
    LVTelnet.Selected.SubItems[1] := EditTelnetPort.Text;
    INIFile.WriteString('TelnetCluster', 'Server' + IntToStr(LVTelnet.Selected.Index),
      EditTelnetName.Text + ',' + EditTelnetAdress.Text + ',' + EditTelnetPort.Text);
  end;
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

procedure TConfigForm.Button1Click(Sender: TObject);
begin
  SaveINI;
  IniSet.Cluster_Login := EditTelnetLogin.Text;
  IniSet.Cluster_Pass := EditTelnetPassword.Text;
  SaveGridColumns;
  SaveGridColors;
  SaveRIGSettings;
  MainFunc.LoadINIsettings;
  MiniForm.SetHotKey;
  ServerDM.StartWOL;
  MainFunc.SetGrid(GridsForm.DBGrid1);
  MainFunc.SetGrid(GridsForm.DBGrid2);
  ConfigForm.Close;
end;

procedure TConfigForm.btApplyColorClick(Sender: TObject);
begin
  SaveGridColors;
  MainFunc.SetGrid(GridsForm.DBGrid1);
  MainFunc.SetGrid(GridsForm.DBGrid2);
end;

procedure TConfigForm.btDefaultColorClick(Sender: TObject);
begin
  cbTextSizeGrid.ItemIndex := 0;
  cbTextColorGrid.ItemIndex := cbTextColorGrid.Items.IndexOf('clBlack');
  cbBackColorGrid.ItemIndex := cbBackColorGrid.Items.IndexOf('clForm');
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

procedure TConfigForm.SBTelnetDoneClick(Sender: TObject);
begin
  SaveTelnetAddress;
  if LVSelectedItem then
    LVTelnet.Selected.Selected := False;
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

procedure TConfigForm.TSTelnetShow(Sender: TObject);
begin
  LVSelectedItem := False;
  SBTelnetDone.Enabled := False;
  LoadTelnetAddress;
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
