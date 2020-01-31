unit setupForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mysql56conn, sqlite3conn, sqldb, FileUtil, Forms, Controls,
  Graphics, Dialogs, ComCtrls, StdCtrls, ExtCtrls, Buttons, Types;
resourcestring
rCreateTableLogBookInfo = 'Create table LogBookInfo';
rIchooseNumberOfRecords = 'I choose the number of records';
rFillInLogTable = 'Fill in the Log_Table_';
rFillInlogBookInfo = 'Fill in the LogBookInfo table';
rAddIndexInLogTable = 'Add index in Log_TABLE_';
rAddKeyInLogTable = 'Add key in Log_TABLE_';
rSuccessful = 'Successful';
rWait = 'Wait';
rNotConnected = 'No connection to the server. Go back to the connection settings step and check all the settings';
rNotUser = 'No database was found for this user. Check the user and database settings in the connection settings step';
rSuccessfulNext = 'Successful! Click NEXT';
rValueEmpty = 'One or more values are empty! Check';
rCheckPath = 'Check SQLite database path';
rValueCorr = 'One or more fields are not filled or are filled incorrectly! All fields and the correct locator must be filled. Longitude and latitude are set automatically';

type

  { TSetupForm }

  TSetupForm = class(TForm)
    Bevel1: TBevel;
    Button1: TButton;
    Button10: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
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
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    MySQL_Connector: TMySQL56Connection;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    ProgressBar1: TProgressBar;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    SaveDialog1: TSaveDialog;
    SpeedButton1: TSpeedButton;
    SQLite_Connector: TSQLite3Connection;
    SQL_Query: TSQLQuery;
    SQL_Transaction: TSQLTransaction;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    procedure Button10Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox4Change(Sender: TObject);
    procedure Edit11Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioButton1Change(Sender: TObject);
    procedure RadioButton2Change(Sender: TObject);
    procedure RadioButton3Change(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure InitializedDB;
  private
    MySQL_BaseName: string;
    MySQL_HostName: string;
    MySQL_LoginName: string;
    MySQL_Password: string;
    MySQL_Port: integer;
    SQLitePATH: string;
    CheckedDB: integer;
    Journal_Description: string;
    New_CallSign: string;
    New_QTH: string;
    New_Name: string;
    New_Grid: string;
    New_Latitude: string;
    New_Longitude: string;
    New_ITU: string;
    New_CQ: string;
    New_QSLInfo: string;
    LOG_PREFIX: string;
    Default_DataBase: string;
    Test_Connection: boolean;
    { private declarations }
  public
    { public declarations }
  end;

var
  SetupForm: TSetupForm;

implementation

uses dmFunc_U, MainForm_U;

var
  MySQL_Current: boolean;
  SQLite_Current: boolean;

{$R *.lfm}

{ TSetupForm }

procedure TSetupForm.InitializedDB;
var
  CountStr: integer;
begin
  try
  if (CheckedDB = 1) and (MySQL_Current = False) then
  begin
    try
      try
        Button4.Enabled := False;
        Button8.Enabled := False;
        MySQL_Connector.HostName := MySQL_HostName;
        MySQL_Connector.Port := MySQL_Port;
        MySQL_Connector.UserName := MySQL_LoginName;
        MySQL_Connector.Password := MySQL_Password;
        MySQL_Connector.DatabaseName := MySQL_BaseName;
        MySQL_Connector.Transaction := SQL_Transaction;
        SQL_Query.DataBase := MySQL_Connector;
        MySQL_Connector.Connected := True;
        SQL_Transaction.Active := True;
        Application.ProcessMessages;
        Label24.Caption := rCreateTableLogBookInfo;
        SQL_Query.Close;
        SQL_Query.SQL.Text := 'CREATE TABLE IF NOT EXISTS `LogBookInfo` ( ' +
          '`id` int(11) NOT NULL, ' + '`LogTable` varchar(100) NOT NULL, ' +
          '`CallName` varchar(15) NOT NULL, ' + '`Name` varchar(100) NOT NULL, ' +
          '`QTH` varchar(100) NOT NULL, ' + '`ITU` int(11) NOT NULL, ' +
          '`CQ` int(11) NOT NULL, ' + '`Loc` varchar(32) NOT NULL, ' +
          '`Lat` varchar(20) NOT NULL, ' + '`Lon` varchar(20) NOT NULL, ' +
          '`Discription` varchar(150) NOT NULL, ' +
          '`QSLInfo` varchar(200) NOT NULL DEFAULT ''TNX For QSO TU 73!'', ' +
          '`EQSLLogin` varchar(200) DEFAULT NULL, ' +
          '`EQSLPassword` varchar(200) DEFAULT NULL, ' + '`AutoEQSLcc` tinyint(1) DEFAULT NULL, ' +
          '`HRDLogLogin` varchar(200) DEFAULT NULL, ' + '`HRDLogPassword` varchar(200) DEFAULT NULL, ' +
          '`AutoHRDLog` tinyint(1) DEFAULT NULL, `LoTW_User` varchar(20), `LoTW_Password` varchar(50) ' + ') ENGINE=InnoDB DEFAULT CHARSET=utf8;';
        SQL_Query.ExecSQL;
        SQL_Query.Close;
        SQL_Query.SQL.Text := 'ALTER TABLE `LogBookInfo` ADD PRIMARY KEY (`id`)';
        SQL_Query.ExecSQL;
        ProgressBar1.Position := 35;
        Application.ProcessMessages;
        ProgressBar1.Position := 56;

        SQL_Query.Transaction := SQL_Transaction;
        LOG_PREFIX := FormatDateTime('DDMMYYYY_HHNNSS', Now);
        SQL_Query.Close;
        Application.ProcessMessages;
        Label24.Caption := rIchooseNumberOfRecords;
        SQL_Query.SQL.Text := 'SELECT COUNT(*) FROM LogBookInfo';
        SQL_Query.Open;
        ProgressBar1.Position := 63;
        CountStr := SQL_Query.Fields[0].AsInteger + 1;
        SQL_Query.Close;
        Application.ProcessMessages;
        Label24.Caption := rFillInLogBookInfo;
        SQL_Query.SQL.Text :=
          'INSERT INTO LogBookInfo ' +
          '(id,LogTable,CallName,Name,QTH,ITU,CQ,Loc,Lat,Lon,Discription,QSLInfo,EQSLLogin,EQSLPassword)'
          + ' VALUES (:id,:LogTable,:CallName,:Name,:QTH,:ITU,:CQ,:Loc,:Lat,:Lon,:Discription,:QSLInfo,:EQSLLogin,:EQSLPassword)';
        SQL_Query.ParamByName('id').AsInteger := CountStr;
        SQL_Query.ParamByName('LogTable').AsString := 'Log_TABLE_' + LOG_PREFIX;
        SQL_Query.ParamByName('CallName').AsString := New_CallSign;
        SQL_Query.ParamByName('Name').AsString := New_Name;
        SQL_Query.ParamByName('QTH').AsString := New_QTH;
        SQL_Query.ParamByName('ITU').AsString := New_ITU;
        SQL_Query.ParamByName('CQ').AsString := New_CQ;
        SQL_Query.ParamByName('Loc').AsString := New_Grid;
        SQL_Query.ParamByName('Lat').AsString := New_Latitude;
        SQL_Query.ParamByName('Lon').AsString := New_Longitude;
        SQL_Query.ParamByName('Discription').AsString := Journal_Description;
        SQL_Query.ParamByName('QSLInfo').AsString := New_QSLInfo;
        SQL_Query.ParamByName('EQSLLogin').AsString := '';
        SQL_Query.ParamByName('EQSLPassword').AsString := '';
        SQL_Query.ExecSQL;
        ProgressBar1.Position := 70;
        SQL_Transaction.Commit;
        SQL_Query.Close;
        Application.ProcessMessages;
        Label24.Caption := rFillInLogTable + LOG_PREFIX;
        SQL_Query.SQL.Text :=
          'CREATE TABLE IF NOT EXISTS `Log_TABLE_' + LOG_PREFIX + '` ' +
          '(' + ' `UnUsedIndex` int(11) NOT NULL,' +
          ' `CallSign` varchar(20) DEFAULT NULL,' + ' `QSODate` datetime DEFAULT NULL,' +
          ' `QSOTime` varchar(5) DEFAULT NULL,' + ' `QSOBand` varchar(20) DEFAULT NULL,' +
          ' `QSOMode` varchar(7) DEFAULT NULL,' +
          ' `QSOSubMode` varchar(15) DEFAULT NULL,' +
          ' `QSOReportSent` varchar(15) DEFAULT NULL,' +
          ' `QSOReportRecived` varchar(15) DEFAULT NULL,' +
          ' `OMName` varchar(30) DEFAULT NULL,' + ' `OMQTH` varchar(50) DEFAULT NULL,' +
          ' `State` varchar(25) DEFAULT NULL,' + ' `Grid` varchar(6) DEFAULT NULL,' +
          ' `IOTA` varchar(6) DEFAULT NULL,' + ' `QSLManager` varchar(9) DEFAULT NULL,' +
          ' `QSLSent` tinyint(1) DEFAULT NULL,' +
          ' `QSLSentAdv` varchar(1) DEFAULT NULL,' +
          ' `QSLSentDate` datetime DEFAULT NULL,' + ' `QSLRec` tinyint(1) DEFAULT NULL,' +
          ' `QSLRecDate` datetime DEFAULT NULL,' +
          ' `MainPrefix` varchar(5) DEFAULT NULL,' +
          ' `DXCCPrefix` varchar(5) DEFAULT NULL,' + ' `CQZone` varchar(2) DEFAULT NULL,' +
          ' `ITUZone` varchar(2) DEFAULT NULL,' + ' `QSOAddInfo` longtext,' +
          ' `Marker` int(11) DEFAULT NULL,' + ' `ManualSet` tinyint(1) DEFAULT NULL,' +
          ' `DigiBand` double DEFAULT NULL,' + ' `Continent` varchar(2) DEFAULT NULL,' +
          ' `ShortNote` varchar(200) DEFAULT NULL,' +
          ' `QSLReceQSLcc` tinyint(1) DEFAULT NULL,' +
          ' `LoTWRec` tinyint(1) DEFAULT 0,' + ' `LoTWRecDate` datetime DEFAULT NULL,' +
          ' `QSLInfo` varchar(100) DEFAULT NULL,' + ' `Call` varchar(20) DEFAULT NULL,' +
          ' `State1` varchar(25) DEFAULT NULL,' + ' `State2` varchar(25) DEFAULT NULL,' +
          ' `State3` varchar(25) DEFAULT NULL,' + ' `State4` varchar(25) DEFAULT NULL,' +
          ' `WPX` varchar(10) DEFAULT NULL,' + ' `AwardsEx` longtext,' +
          ' `ValidDX` tinyint(1) DEFAULT 1,' + ' `SRX` int(11) DEFAULT NULL,' +
          ' `SRX_STRING` varchar(15) DEFAULT NULL,' + ' `STX` int(11) DEFAULT NULL,' +
          ' `STX_STRING` varchar(15) DEFAULT NULL,' +
          ' `SAT_NAME` varchar(20) DEFAULT NULL,' +
          ' `SAT_MODE` varchar(20) DEFAULT NULL,' +
          ' `PROP_MODE` varchar(20) DEFAULT NULL,' + ' `LoTWSent` tinyint(1) DEFAULT 0,' +
          ' `QSL_RCVD_VIA` varchar(1) DEFAULT NULL,' +
          ' `QSL_SENT_VIA` varchar(1) DEFAULT NULL,' +
          ' `DXCC` varchar(5) DEFAULT NULL,' + ' `USERS` varchar(5) DEFAULT NULL,' +
          ' `NoCalcDXCC` tinyint(1) DEFAULT 0, `MY_STATE` varchar(15), '+
          ' `MY_GRIDSQUARE` varchar(15), `MY_LAT` varchar(15),`MY_LON` varchar(15)'+' )';
        SQL_Query.ExecSQL;
        ProgressBar1.Position := 77;
        SQL_Transaction.Commit;
        SQL_Query.Close;
        Application.ProcessMessages;
        Label24.Caption := rAddIndexInLogTable + LOG_PREFIX;
        SQL_Query.SQL.Text :=
          'ALTER TABLE `Log_TABLE_' + LOG_PREFIX + '` ' +
          ' ADD PRIMARY KEY (`UnUsedIndex`),' + ' ADD KEY `Call` (`Call`),' +
          ' ADD KEY `CallSign` (`CallSign`),' +
          ' ADD KEY `QSODate` (`QSODate`,`QSOTime`),' +
          ' ADD KEY `DigiBand` (`DigiBand`),' + ' ADD KEY `DXCC` (`DXCC`),' +
          ' ADD KEY `DXCCPrefix` (`DXCCPrefix`),' + ' ADD KEY `IOTA` (`IOTA`),' +
          ' ADD KEY `MainPrefix` (`MainPrefix`),' + ' ADD KEY `QSOMode` (`QSOMode`),' +
          ' ADD KEY `State` (`State`),' + ' ADD KEY `State1` (`State1`),' +
          ' ADD KEY `State2` (`State2`),' + ' ADD KEY `State3` (`State3`),' +
          ' ADD KEY `State4` (`State4`),' + ' ADD KEY `WPX` (`WPX`),'+
          ' ADD UNIQUE `Dupe_index` (`CallSign`, `QSODate`, `QSOTime`, `QSOBand`);';
        SQL_Query.ExecSQL;
        ProgressBar1.Position := 84;
        SQL_Transaction.Commit;
        SQL_Query.Close;
        Application.ProcessMessages;
        Label24.Caption := rAddKeyInLogTable + LOG_PREFIX;
        SQL_Query.SQL.Text :=
          'ALTER TABLE `Log_TABLE_' + LOG_PREFIX + '` ' +
          ' MODIFY `UnUsedIndex` int(11) NOT NULL AUTO_INCREMENT;';
        SQL_Query.ExecSQL;
        ProgressBar1.Position := 100;
        SQL_Transaction.Commit;
        Label24.Caption := rSuccessful;
      except
        on E: ESQLDatabaseError do
        begin
          if Pos('Server connect failed', E.Message) > 0 then
          begin
            ShowMessage(rNotConnected);
            Button8.Enabled := True;
          end;
          if Pos('Access denied for user', E.Message) > 0 then
          begin
            ShowMessage(rNotUser);
            Button8.Enabled := True;
          end;
          Button8.Enabled := True;
        end;
      end;
    finally
      SQL_Transaction.Commit;
      Button4.Enabled := True;
      IniF.WriteString('SetLog', 'DefaultCallLogBook', New_CallSign);
      IniF.WriteString('DataBases', 'HostAddr', MySQL_HostName);
      IniF.WriteString('DataBases', 'Port', IntToStr(MySQL_Port));
      IniF.WriteString('DataBases', 'LoginName', MySQL_LoginName);
      IniF.WriteString('DataBases', 'Password', MySQL_Password);
      IniF.WriteString('DataBases', 'DataBaseName', MySQL_BaseName);
      IniF.WriteString('SetLog', 'LogBookInit', 'YES');
      IniF.WriteString('DataBases', 'DefaultDataBase', 'MySQL');
    end;
  end;

  if (CheckedDB = 1) and (MySQL_Current = True) then
  begin
    IniF.WriteString('SetLog', 'DefaultCallLogBook', New_CallSign);
    IniF.WriteString('DataBases', 'HostAddr', MySQL_HostName);
    IniF.WriteString('DataBases', 'Port', IntToStr(MySQL_Port));
    IniF.WriteString('DataBases', 'LoginName', MySQL_LoginName);
    IniF.WriteString('DataBases', 'Password', MySQL_Password);
    IniF.WriteString('DataBases', 'DataBaseName', MySQL_BaseName);
    IniF.WriteString('SetLog', 'LogBookInit', 'YES');
    IniF.WriteString('DataBases', 'DefaultDataBase', 'MySQL');
    ProgressBar1.Position := 100;
    Label24.Caption := rSuccessful;
    Button4.Enabled := True;
  end;

  if (CheckedDB = 2) and (SQLite_Current = False) then
  begin
    try
      Button4.Enabled := False;
      Button8.Enabled := False;

      SQLite_Connector.DatabaseName := SQLitePATH;
      SQLite_Connector.Transaction := SQL_Transaction;
      SQL_Query.DataBase := SQLite_Connector;
      SQLite_Connector.Connected := True;
      SQL_Transaction.Active := True;
      Application.ProcessMessages;
      Label24.Caption := rCreateTableLogBookInfo;
      SQL_Query.Close;
      SQL_Query.SQL.Text := 'CREATE TABLE IF NOT EXISTS `LogBookInfo` ( ' +
        '`id` int(11) NOT NULL, ' + '`LogTable` varchar(100) NOT NULL, ' +
        '`CallName` varchar(15) NOT NULL, ' + '`Name` varchar(100) NOT NULL, ' +
        '`QTH` varchar(100) NOT NULL, ' + '`ITU` int(11) NOT NULL, ' +
        '`CQ` int(11) NOT NULL, ' + '`Loc` varchar(32) NOT NULL, ' +
        '`Lat` varchar(20) NOT NULL, ' + '`Lon` varchar(20) NOT NULL, ' +
        '`Discription` varchar(150) NOT NULL, ' +
        '`QSLInfo` varchar(200) NOT NULL DEFAULT `TNX For QSO TU 73!`, ' +
        '`EQSLLogin` varchar(200) DEFAULT NULL, ' +
        '`EQSLPassword` varchar(200) DEFAULT NULL, ' +
        '`AutoEQSLcc` tinyint(1) DEFAULT NULL, ' + '`HRDLogLogin` varchar(200) DEFAULT NULL, ' +
        '`HRDLogPassword` varchar(200) DEFAULT NULL, ' +
        '`AutoHRDLog` tinyint(1) DEFAULT NULL, `LoTW_User` varchar(20), `LoTW_Password` varchar(50))';
      SQL_Query.ExecSQL;
      ProgressBar1.Position := 35;
      Application.ProcessMessages;
      ProgressBar1.Position := 56;

      SQL_Query.Transaction := SQL_Transaction;
      LOG_PREFIX := FormatDateTime('DDMMYYYY_HHNNSS', Now);
      SQL_Query.Close;
      Application.ProcessMessages;
      Label24.Caption := rIchooseNumberOfRecords;
      SQL_Query.SQL.Text := 'SELECT COUNT(*) FROM LogBookInfo';
      SQL_Query.Open;
      ProgressBar1.Position := 63;
      CountStr := SQL_Query.Fields[0].AsInteger + 1;
      SQL_Query.Close;
      Application.ProcessMessages;
      Label24.Caption := rFillInlogBookInfo;
      SQL_Query.SQL.Text :=
        'INSERT INTO LogBookInfo ' +
        '(id,LogTable,CallName,Name,QTH,ITU,CQ,Loc,Lat,Lon,Discription,QSLInfo,EQSLLogin,EQSLPassword)'
        + ' VALUES (:id,:LogTable,:CallName,:Name,:QTH,:ITU,:CQ,:Loc,:Lat,:Lon,:Discription,:QSLInfo,:EQSLLogin,:EQSLPassword)';
      SQL_Query.ParamByName('id').AsInteger := CountStr;
      SQL_Query.ParamByName('LogTable').AsString := 'Log_TABLE_' + LOG_PREFIX;
      SQL_Query.ParamByName('CallName').AsString := New_CallSign;
      SQL_Query.ParamByName('Name').AsString := New_Name;
      SQL_Query.ParamByName('QTH').AsString := New_QTH;
      SQL_Query.ParamByName('ITU').AsString := New_ITU;
      SQL_Query.ParamByName('CQ').AsString := New_CQ;
      SQL_Query.ParamByName('Loc').AsString := New_Grid;
      SQL_Query.ParamByName('Lat').AsString := New_Latitude;
      SQL_Query.ParamByName('Lon').AsString := New_Longitude;
      SQL_Query.ParamByName('Discription').AsString := Journal_Description;
      SQL_Query.ParamByName('QSLInfo').AsString := New_QSLInfo;
      SQL_Query.ParamByName('EQSLLogin').AsString := '';
      SQL_Query.ParamByName('EQSLPassword').AsString := '';
      SQL_Query.ExecSQL;
      ProgressBar1.Position := 70;
      SQL_Transaction.Commit;
      SQL_Query.Close;
      Application.ProcessMessages;
      Label24.Caption := rFillInLogTable + LOG_PREFIX;
      SQL_Query.SQL.Text :=
        'CREATE TABLE IF NOT EXISTS `Log_TABLE_' + LOG_PREFIX + '` ' +
        '(' + ' `UnUsedIndex` integer UNIQUE PRIMARY KEY,' +
        ' `CallSign` varchar(20) DEFAULT NULL,' + ' `QSODate` datetime DEFAULT NULL,' +
        ' `QSOTime` varchar(5) DEFAULT NULL,' + ' `QSOBand` varchar(20) DEFAULT NULL,' +
        ' `QSOMode` varchar(7) DEFAULT NULL,' +
        ' `QSOSubMode` varchar(15) DEFAULT NULL,' +
        ' `QSOReportSent` varchar(15) DEFAULT NULL,' +
        ' `QSOReportRecived` varchar(15) DEFAULT NULL,' +
        ' `OMName` varchar(30) DEFAULT NULL,' + ' `OMQTH` varchar(50) DEFAULT NULL,' +
        ' `State` varchar(25) DEFAULT NULL,' + ' `Grid` varchar(6) DEFAULT NULL,' +
        ' `IOTA` varchar(6) DEFAULT NULL,' + ' `QSLManager` varchar(9) DEFAULT NULL,' +
        ' `QSLSent` tinyint(1) DEFAULT NULL,' +
        ' `QSLSentAdv` varchar(1) DEFAULT NULL,' +
        ' `QSLSentDate` datetime DEFAULT NULL,' + ' `QSLRec` tinyint(1) DEFAULT NULL,' +
        ' `QSLRecDate` datetime DEFAULT NULL,' +
        ' `MainPrefix` varchar(5) DEFAULT NULL,' +
        ' `DXCCPrefix` varchar(5) DEFAULT NULL,' + ' `CQZone` varchar(2) DEFAULT NULL,' +
        ' `ITUZone` varchar(2) DEFAULT NULL,' + ' `QSOAddInfo` longtext,' +
        ' `Marker` int(11) DEFAULT NULL,' + ' `ManualSet` tinyint(1) DEFAULT NULL,' +
        ' `DigiBand` double DEFAULT NULL,' + ' `Continent` varchar(2) DEFAULT NULL,' +
        ' `ShortNote` varchar(200) DEFAULT NULL,' +
        ' `QSLReceQSLcc` tinyint(1) DEFAULT NULL,' +
        ' `LoTWRec` tinyint(1) DEFAULT 0,' + ' `LoTWRecDate` datetime DEFAULT NULL,' +
        ' `QSLInfo` varchar(100) DEFAULT NULL,' + ' `Call` varchar(20) DEFAULT NULL,' +
        ' `State1` varchar(25) DEFAULT NULL,' + ' `State2` varchar(25) DEFAULT NULL,' +
        ' `State3` varchar(25) DEFAULT NULL,' + ' `State4` varchar(25) DEFAULT NULL,' +
        ' `WPX` varchar(10) DEFAULT NULL,' + ' `AwardsEx` longtext,' +
        ' `ValidDX` tinyint(1) DEFAULT 1,' + ' `SRX` int(11) DEFAULT NULL,' +
        ' `SRX_STRING` varchar(15) DEFAULT NULL,' + ' `STX` int(11) DEFAULT NULL,' +
        ' `STX_STRING` varchar(15) DEFAULT NULL,' +
        ' `SAT_NAME` varchar(20) DEFAULT NULL,' +
        ' `SAT_MODE` varchar(20) DEFAULT NULL,' +
        ' `PROP_MODE` varchar(20) DEFAULT NULL,' + ' `LoTWSent` tinyint(1) DEFAULT 0,' +
        ' `QSL_RCVD_VIA` varchar(1) DEFAULT NULL,' +
        ' `QSL_SENT_VIA` varchar(1) DEFAULT NULL,' +
        ' `DXCC` varchar(5) DEFAULT NULL,' + ' `USERS` varchar(5) DEFAULT NULL,' +
        ' `NoCalcDXCC` tinyint(1) DEFAULT 0, `MY_STATE` varchar(15), '+
        ' `MY_GRIDSQUARE` varchar(15), `MY_LAT` varchar(15),`MY_LON` varchar(15)'+' )';
      SQL_Query.ExecSQL;
      SQL_Query.SQL.Text := 'CREATE UNIQUE INDEX `Dupe_index` ON `Log_TABLE_'+LOG_PREFIX+'` '+
      '(`CallSign`, `QSODate`, `QSOTime`, `QSOBand`)';
      SQL_Query.ExecSQL;
      SQL_Query.SQL.Text:='CREATE INDEX `Call_index` ON `Log_TABLE_'+LOG_PREFIX+'` (`Call`);';
      SQL_Query.ExecSQL;
      ProgressBar1.Position := 77;
      SQL_Transaction.Commit;
      SQL_Query.Close;
      ProgressBar1.Position := 84;
      ProgressBar1.Position := 100;
      Label24.Caption := rSuccessful;
    finally
      SQL_Transaction.Commit;
      Button4.Enabled := True;
      IniF.WriteString('SetLog', 'DefaultCallLogBook', New_CallSign);
      IniF.WriteString('DataBases', 'HostAddr', '');
      IniF.WriteString('DataBases', 'Port', '');
      IniF.WriteString('DataBases', 'LoginName', '');
      IniF.WriteString('DataBases', 'Password', '');
      IniF.WriteString('DataBases', 'DataBaseName', '');
      IniF.WriteString('DataBases', 'FileSQLite', SQLitePATH);
      IniF.WriteString('SetLog', 'LogBookInit', 'YES');
      IniF.WriteString('DataBases', 'DefaultDataBase', 'SQLite');
    end;
  end;

  if (CheckedDB = 2) and (SQLite_Current = True) then
  begin
    IniF.WriteString('SetLog', 'DefaultCallLogBook', New_CallSign);
    IniF.WriteString('DataBases', 'HostAddr', '');
    IniF.WriteString('DataBases', 'Port', '');
    IniF.WriteString('DataBases', 'LoginName', '');
    IniF.WriteString('DataBases', 'Password', '');
    IniF.WriteString('DataBases', 'DataBaseName', '');
    IniF.WriteString('DataBases', 'FileSQLite', SQLitePATH);
    IniF.WriteString('SetLog', 'LogBookInit', 'YES');
    IniF.WriteString('DataBases', 'DefaultDataBase', 'SQLite');
    ProgressBar1.Position := 100;
    Label24.Caption := rSuccessful;
    Button4.Enabled := True;
  end;

  if CheckedDB = 3 then
  begin
    if MySQL_Current = False then
    begin
      try
        try
          Button4.Enabled := False;
          Button8.Enabled := False;
          MySQL_Connector.HostName := MySQL_HostName;
          MySQL_Connector.Port := MySQL_Port;
          MySQL_Connector.UserName := MySQL_LoginName;
          MySQL_Connector.Password := MySQL_Password;
          MySQL_Connector.DatabaseName := MySQL_BaseName;
          MySQL_Connector.Transaction := SQL_Transaction;
          SQL_Query.DataBase := MySQL_Connector;
          MySQL_Connector.Connected := True;
          SQL_Transaction.Active := True;
          Application.ProcessMessages;
          Label24.Caption := rCreateTableLogBookInfo;
          SQL_Query.Close;
          SQL_Query.SQL.Text := 'CREATE TABLE IF NOT EXISTS `LogBookInfo` ( ' +
            '`id` int(11) NOT NULL, ' + '`LogTable` varchar(100) NOT NULL, ' +
            '`CallName` varchar(15) NOT NULL, ' + '`Name` varchar(100) NOT NULL, ' +
            '`QTH` varchar(100) NOT NULL, ' + '`ITU` int(11) NOT NULL, ' +
            '`CQ` int(11) NOT NULL, ' + '`Loc` varchar(32) NOT NULL, ' +
            '`Lat` varchar(20) NOT NULL, ' + '`Lon` varchar(20) NOT NULL, ' +
            '`Discription` varchar(150) NOT NULL, ' +
            '`QSLInfo` varchar(200) NOT NULL DEFAULT ''TNX For QSO TU 73!'', ' +
            '`EQSLLogin` varchar(200) DEFAULT NULL, ' +
            '`EQSLPassword` varchar(200) DEFAULT NULL, ' + '`AutoEQSLcc` tinyint(1) DEFAULT NULL, ' +
            '`HRDLogLogin` varchar(200) DEFAULT NULL, ' + '`HRDLogPassword` varchar(200) DEFAULT NULL, ' +
            '`AutoHRDLog` tinyint(1) DEFAULT NULL, `LoTW_User` varchar(20), `LoTW_Password` varchar(50) ' + ') ENGINE=InnoDB DEFAULT CHARSET=utf8;';
          SQL_Query.ExecSQL;
          SQL_Query.Close;
          SQL_Query.SQL.Text := 'ALTER TABLE `LogBookInfo` ADD PRIMARY KEY (`id`)';
          SQL_Query.ExecSQL;
          ProgressBar1.Position := 35;
          Application.ProcessMessages;
          ProgressBar1.Position := 56;

          SQL_Query.Transaction := SQL_Transaction;
          LOG_PREFIX := FormatDateTime('DDMMYYYY_HHNNSS', Now);
          SQL_Query.Close;
          Application.ProcessMessages;
          Label24.Caption := rIchooseNumberOfRecords;
          SQL_Query.SQL.Text := 'SELECT COUNT(*) FROM LogBookInfo';
          SQL_Query.Open;
          ProgressBar1.Position := 63;
          CountStr := SQL_Query.Fields[0].AsInteger + 1;
          SQL_Query.Close;
          Application.ProcessMessages;
          Label24.Caption := rFillInlogBookInfo;
          SQL_Query.SQL.Text :=
            'INSERT INTO LogBookInfo ' +
            '(id,LogTable,CallName,Name,QTH,ITU,CQ,Loc,Lat,Lon,Discription,QSLInfo,EQSLLogin,EQSLPassword)'
            + ' VALUES (:id,:LogTable,:CallName,:Name,:QTH,:ITU,:CQ,:Loc,:Lat,:Lon,:Discription,:QSLInfo,:EQSLLogin,:EQSLPassword)';
          SQL_Query.ParamByName('id').AsInteger := CountStr;
          SQL_Query.ParamByName('LogTable').AsString := 'Log_TABLE_' + LOG_PREFIX;
          SQL_Query.ParamByName('CallName').AsString := New_CallSign;
          SQL_Query.ParamByName('Name').AsString := New_Name;
          SQL_Query.ParamByName('QTH').AsString := New_QTH;
          SQL_Query.ParamByName('ITU').AsString := New_ITU;
          SQL_Query.ParamByName('CQ').AsString := New_CQ;
          SQL_Query.ParamByName('Loc').AsString := New_Grid;
          SQL_Query.ParamByName('Lat').AsString := New_Latitude;
          SQL_Query.ParamByName('Lon').AsString := New_Longitude;
          SQL_Query.ParamByName('Discription').AsString := Journal_Description;
          SQL_Query.ParamByName('QSLInfo').AsString := New_QSLInfo;
          SQL_Query.ParamByName('EQSLLogin').AsString := '';
          SQL_Query.ParamByName('EQSLPassword').AsString := '';
          SQL_Query.ExecSQL;
          ProgressBar1.Position := 70;
          SQL_Transaction.Commit;
          SQL_Query.Close;
          Application.ProcessMessages;
          Label24.Caption := rFillInLogTable + LOG_PREFIX;
          SQL_Query.SQL.Text :=
            'CREATE TABLE IF NOT EXISTS `Log_TABLE_' + LOG_PREFIX + '` ' +
            '(' + ' `UnUsedIndex` int(11) NOT NULL,' +
            ' `CallSign` varchar(20) DEFAULT NULL,' + ' `QSODate` datetime DEFAULT NULL,' +
            ' `QSOTime` varchar(5) DEFAULT NULL,' + ' `QSOBand` varchar(20) DEFAULT NULL,' +
            ' `QSOMode` varchar(7) DEFAULT NULL,' +
            ' `QSOSubMode` varchar(15) DEFAULT NULL,' +
            ' `QSOReportSent` varchar(15) DEFAULT NULL,' +
            ' `QSOReportRecived` varchar(15) DEFAULT NULL,' +
            ' `OMName` varchar(30) DEFAULT NULL,' + ' `OMQTH` varchar(50) DEFAULT NULL,' +
            ' `State` varchar(25) DEFAULT NULL,' + ' `Grid` varchar(6) DEFAULT NULL,' +
            ' `IOTA` varchar(6) DEFAULT NULL,' + ' `QSLManager` varchar(9) DEFAULT NULL,' +
            ' `QSLSent` tinyint(1) DEFAULT NULL,' +
            ' `QSLSentAdv` varchar(1) DEFAULT NULL,' +
            ' `QSLSentDate` datetime DEFAULT NULL,' + ' `QSLRec` tinyint(1) DEFAULT NULL,' +
            ' `QSLRecDate` datetime DEFAULT NULL,' +
            ' `MainPrefix` varchar(5) DEFAULT NULL,' +
            ' `DXCCPrefix` varchar(5) DEFAULT NULL,' + ' `CQZone` varchar(2) DEFAULT NULL,' +
            ' `ITUZone` varchar(2) DEFAULT NULL,' + ' `QSOAddInfo` longtext,' +
            ' `Marker` int(11) DEFAULT NULL,' + ' `ManualSet` tinyint(1) DEFAULT NULL,' +
            ' `DigiBand` double DEFAULT NULL,' + ' `Continent` varchar(2) DEFAULT NULL,' +
            ' `ShortNote` varchar(200) DEFAULT NULL,' +
            ' `QSLReceQSLcc` tinyint(1) DEFAULT NULL,' +
            ' `LoTWRec` tinyint(1) DEFAULT 0,' + ' `LoTWRecDate` datetime DEFAULT NULL,' +
            ' `QSLInfo` varchar(100) DEFAULT NULL,' + ' `Call` varchar(20) DEFAULT NULL,' +
            ' `State1` varchar(25) DEFAULT NULL,' + ' `State2` varchar(25) DEFAULT NULL,' +
            ' `State3` varchar(25) DEFAULT NULL,' + ' `State4` varchar(25) DEFAULT NULL,' +
            ' `WPX` varchar(10) DEFAULT NULL,' + ' `AwardsEx` longtext,' +
            ' `ValidDX` tinyint(1) DEFAULT 1,' + ' `SRX` int(11) DEFAULT NULL,' +
            ' `SRX_STRING` varchar(15) DEFAULT NULL,' + ' `STX` int(11) DEFAULT NULL,' +
            ' `STX_STRING` varchar(15) DEFAULT NULL,' +
            ' `SAT_NAME` varchar(20) DEFAULT NULL,' +
            ' `SAT_MODE` varchar(20) DEFAULT NULL,' +
            ' `PROP_MODE` varchar(20) DEFAULT NULL,' + ' `LoTWSent` tinyint(1) DEFAULT 0,' +
            ' `QSL_RCVD_VIA` varchar(1) DEFAULT NULL,' +
            ' `QSL_SENT_VIA` varchar(1) DEFAULT NULL,' +
            ' `DXCC` varchar(5) DEFAULT NULL,' + ' `USERS` varchar(5) DEFAULT NULL,' +
            ' `NoCalcDXCC` tinyint(1) DEFAULT 0, `MY_STATE` varchar(15), '+
            ' `MY_GRIDSQUARE` varchar(15), `MY_LAT` varchar(15),`MY_LON` varchar(15)'+' )';
          SQL_Query.ExecSQL;
          ProgressBar1.Position := 77;
          SQL_Transaction.Commit;
          SQL_Query.Close;
          Application.ProcessMessages;
          Label24.Caption := rAddIndexInLogTable + LOG_PREFIX;
          SQL_Query.SQL.Text :=
            'ALTER TABLE `Log_TABLE_' + LOG_PREFIX + '` ' +
            ' ADD PRIMARY KEY (`UnUsedIndex`),' + ' ADD KEY `Call` (`Call`),' +
            ' ADD KEY `CallSign` (`CallSign`),' +
            ' ADD KEY `QSODate` (`QSODate`,`QSOTime`),' +
            ' ADD KEY `DigiBand` (`DigiBand`),' + ' ADD KEY `DXCC` (`DXCC`),' +
            ' ADD KEY `DXCCPrefix` (`DXCCPrefix`),' + ' ADD KEY `IOTA` (`IOTA`),' +
            ' ADD KEY `MainPrefix` (`MainPrefix`),' + ' ADD KEY `QSOMode` (`QSOMode`),' +
            ' ADD KEY `State` (`State`),' + ' ADD KEY `State1` (`State1`),' +
            ' ADD KEY `State2` (`State2`),' + ' ADD KEY `State3` (`State3`),' +
            ' ADD KEY `State4` (`State4`),' + ' ADD KEY `WPX` (`WPX`),'+
            ' ADD UNIQUE `Dupe_index` (`CallSign`, `QSODate`, `QSOTime`, `QSOBand`);';
          SQL_Query.ExecSQL;
          ProgressBar1.Position := 84;
          SQL_Transaction.Commit;
          SQL_Query.Close;
          Application.ProcessMessages;
          Label24.Caption := rAddKeyInLogTable + LOG_PREFIX;
          SQL_Query.SQL.Text :=
            'ALTER TABLE `Log_TABLE_' + LOG_PREFIX + '` ' +
            ' MODIFY `UnUsedIndex` int(11) NOT NULL AUTO_INCREMENT;';
          SQL_Query.ExecSQL;
          ProgressBar1.Position := 100;
          SQL_Transaction.Commit;
          Label24.Caption := rSuccessful;

        except
          on E: ESQLDatabaseError do
          begin
            if Pos('Server connect failed', E.Message) > 0 then
            begin
              ShowMessage(rNotConnected);
              Button8.Enabled := True;
            end;
            if Pos('Access denied for user', E.Message) > 0 then
            begin
              ShowMessage(rNotUser);
              Button8.Enabled := True;
            end;
            Button8.Enabled := True;
          end;
        end;

      finally
        SQL_Transaction.Commit;
        IniF.WriteString('SetLog', 'DefaultCallLogBook', New_CallSign);
        IniF.WriteString('DataBases', 'HostAddr', MySQL_HostName);
        IniF.WriteString('DataBases', 'Port', IntToStr(MySQL_Port));
        IniF.WriteString('DataBases', 'LoginName', MySQL_LoginName);
        IniF.WriteString('DataBases', 'Password', MySQL_Password);
        IniF.WriteString('DataBases', 'DataBaseName', MySQL_BaseName);
        IniF.WriteString('SetLog', 'LogBookInit', 'YES');
        IniF.WriteString('DataBases', 'DefaultDataBase', 'MySQL');

      end;
    end;

    if MySQL_Current = True then
    begin
      IniF.WriteString('SetLog', 'DefaultCallLogBook', New_CallSign);
      IniF.WriteString('DataBases', 'HostAddr', MySQL_HostName);
      IniF.WriteString('DataBases', 'Port', IntToStr(MySQL_Port));
      IniF.WriteString('DataBases', 'LoginName', MySQL_LoginName);
      IniF.WriteString('DataBases', 'Password', MySQL_Password);
      IniF.WriteString('DataBases', 'DataBaseName', MySQL_BaseName);
      IniF.WriteString('SetLog', 'LogBookInit', 'YES');
      IniF.WriteString('DataBases', 'DefaultDataBase', 'MySQL');
      ProgressBar1.Position := 100;
      Label24.Caption := rSuccessful;
    end;

    if SQLite_Current = False then
    begin
      try
        MySQL_Connector.Connected := False;
        SQLite_Connector.DatabaseName := SQLitePATH;
        SQLite_Connector.Transaction := SQL_Transaction;
        SQL_Query.DataBase := SQLite_Connector;
        SQLite_Connector.Connected := True;
        SQL_Transaction.Active := True;
        Application.ProcessMessages;
        Label24.Caption := rCreateTableLogBookInfo;
        SQL_Query.Close;
        SQL_Query.SQL.Text := 'CREATE TABLE IF NOT EXISTS `LogBookInfo` ( ' +
          '`id` int(11) NOT NULL, ' + '`LogTable` varchar(100) NOT NULL, ' +
          '`CallName` varchar(15) NOT NULL, ' + '`Name` varchar(100) NOT NULL, ' +
          '`QTH` varchar(100) NOT NULL, ' + '`ITU` int(11) NOT NULL, ' +
          '`CQ` int(11) NOT NULL, ' + '`Loc` varchar(32) NOT NULL, ' +
          '`Lat` varchar(20) NOT NULL, ' + '`Lon` varchar(20) NOT NULL, ' +
          '`Discription` varchar(150) NOT NULL, ' +
          '`QSLInfo` varchar(200) NOT NULL DEFAULT `TNX For QSO TU 73!`, ' +
          '`EQSLLogin` varchar(200) DEFAULT NULL, ' +
          '`EQSLPassword` varchar(200) DEFAULT NULL, ' +
          '`AutoEQSLcc` tinyint(1) DEFAULT NULL, ' + '`HRDLogLogin` varchar(200) DEFAULT NULL, ' +
          '`HRDLogPassword` varchar(200) DEFAULT NULL, ' +
          '`AutoHRDLog` tinyint(1) DEFAULT NULL, `LoTW_User` varchar(20), `LoTW_Password` varchar(50));';
        SQL_Query.ExecSQL;
        ProgressBar1.Position := 35;
        Application.ProcessMessages;
        ProgressBar1.Position := 56;

        SQL_Query.Transaction := SQL_Transaction;
        LOG_PREFIX := FormatDateTime('DDMMYYYY_HHNNSS', Now);
        SQL_Query.Close;
        Application.ProcessMessages;
        Label24.Caption := rIchooseNumberOfRecords;
        SQL_Query.SQL.Text := 'SELECT COUNT(*) FROM LogBookInfo';
        SQL_Query.Open;
        ProgressBar1.Position := 63;
        CountStr := SQL_Query.Fields[0].AsInteger + 1;
        SQL_Query.Close;
        Application.ProcessMessages;
        Label24.Caption := rFillInlogBookInfo;
        SQL_Query.SQL.Text :=
          'INSERT INTO LogBookInfo ' +
          '(id,LogTable,CallName,Name,QTH,ITU,CQ,Loc,Lat,Lon,Discription,QSLInfo,EQSLLogin,EQSLPassword)'
          + ' VALUES (:id,:LogTable,:CallName,:Name,:QTH,:ITU,:CQ,:Loc,:Lat,:Lon,:Discription,:QSLInfo,:EQSLLogin,:EQSLPassword)';
        SQL_Query.ParamByName('id').AsInteger := CountStr;
        SQL_Query.ParamByName('LogTable').AsString := 'Log_TABLE_' + LOG_PREFIX;
        SQL_Query.ParamByName('CallName').AsString := New_CallSign;
        SQL_Query.ParamByName('Name').AsString := New_Name;
        SQL_Query.ParamByName('QTH').AsString := New_QTH;
        SQL_Query.ParamByName('ITU').AsString := New_ITU;
        SQL_Query.ParamByName('CQ').AsString := New_CQ;
        SQL_Query.ParamByName('Loc').AsString := New_Grid;
        SQL_Query.ParamByName('Lat').AsString := New_Latitude;
        SQL_Query.ParamByName('Lon').AsString := New_Longitude;
        SQL_Query.ParamByName('Discription').AsString := Journal_Description;
        SQL_Query.ParamByName('QSLInfo').AsString := New_QSLInfo;
        SQL_Query.ParamByName('EQSLLogin').AsString := '';
        SQL_Query.ParamByName('EQSLPassword').AsString := '';
        SQL_Query.ExecSQL;
        ProgressBar1.Position := 70;
        SQL_Transaction.Commit;
        SQL_Query.Close;
        Application.ProcessMessages;
        Label24.Caption := rFillInLogTable + LOG_PREFIX + ' in SQLite';
        SQL_Query.SQL.Text :=
          'CREATE TABLE IF NOT EXISTS `Log_TABLE_' + LOG_PREFIX + '` ' +
          '(' + ' `UnUsedIndex` integer UNIQUE PRIMARY KEY,' +
          ' `CallSign` varchar(20) DEFAULT NULL,' + ' `QSODate` datetime DEFAULT NULL,' +
          ' `QSOTime` varchar(5) DEFAULT NULL,' + ' `QSOBand` varchar(20) DEFAULT NULL,' +
          ' `QSOMode` varchar(7) DEFAULT NULL,' +
          ' `QSOSubMode` varchar(15) DEFAULT NULL,' +
          ' `QSOReportSent` varchar(15) DEFAULT NULL,' +
          ' `QSOReportRecived` varchar(15) DEFAULT NULL,' +
          ' `OMName` varchar(30) DEFAULT NULL,' + ' `OMQTH` varchar(50) DEFAULT NULL,' +
          ' `State` varchar(25) DEFAULT NULL,' + ' `Grid` varchar(6) DEFAULT NULL,' +
          ' `IOTA` varchar(6) DEFAULT NULL,' + ' `QSLManager` varchar(9) DEFAULT NULL,' +
          ' `QSLSent` tinyint(1) DEFAULT NULL,' +
          ' `QSLSentAdv` varchar(1) DEFAULT NULL,' +
          ' `QSLSentDate` datetime DEFAULT NULL,' + ' `QSLRec` tinyint(1) DEFAULT NULL,' +
          ' `QSLRecDate` datetime DEFAULT NULL,' +
          ' `MainPrefix` varchar(5) DEFAULT NULL,' +
          ' `DXCCPrefix` varchar(5) DEFAULT NULL,' + ' `CQZone` varchar(2) DEFAULT NULL,' +
          ' `ITUZone` varchar(2) DEFAULT NULL,' + ' `QSOAddInfo` longtext,' +
          ' `Marker` int(11) DEFAULT NULL,' + ' `ManualSet` tinyint(1) DEFAULT NULL,' +
          ' `DigiBand` double DEFAULT NULL,' + ' `Continent` varchar(2) DEFAULT NULL,' +
          ' `ShortNote` varchar(200) DEFAULT NULL,' +
          ' `QSLReceQSLcc` tinyint(1) DEFAULT NULL,' +
          ' `LoTWRec` tinyint(1) DEFAULT 0,' + ' `LoTWRecDate` datetime DEFAULT NULL,' +
          ' `QSLInfo` varchar(100) DEFAULT NULL,' + ' `Call` varchar(20) DEFAULT NULL,' +
          ' `State1` varchar(25) DEFAULT NULL,' + ' `State2` varchar(25) DEFAULT NULL,' +
          ' `State3` varchar(25) DEFAULT NULL,' + ' `State4` varchar(25) DEFAULT NULL,' +
          ' `WPX` varchar(10) DEFAULT NULL,' + ' `AwardsEx` longtext,' +
          ' `ValidDX` tinyint(1) DEFAULT 1,' + ' `SRX` int(11) DEFAULT NULL,' +
          ' `SRX_STRING` varchar(15) DEFAULT NULL,' + ' `STX` int(11) DEFAULT NULL,' +
          ' `STX_STRING` varchar(15) DEFAULT NULL,' +
          ' `SAT_NAME` varchar(20) DEFAULT NULL,' +
          ' `SAT_MODE` varchar(20) DEFAULT NULL,' +
          ' `PROP_MODE` varchar(20) DEFAULT NULL,' + ' `LoTWSent` tinyint(1) DEFAULT 0,' +
          ' `QSL_RCVD_VIA` varchar(1) DEFAULT NULL,' +
          ' `QSL_SENT_VIA` varchar(1) DEFAULT NULL,' +
          ' `DXCC` varchar(5) DEFAULT NULL,' + ' `USERS` varchar(5) DEFAULT NULL,' +
          ' `NoCalcDXCC` tinyint(1) DEFAULT 0, `MY_STATE` varchar(15), '+
          ' `MY_GRIDSQUARE` varchar(15), `MY_LAT` varchar(15),`MY_LON` varchar(15)'+' )';
        SQL_Query.ExecSQL;
        SQL_Query.SQL.Text := 'CREATE UNIQUE INDEX `Dupe_index` ON `Log_TABLE_'+LOG_PREFIX+'` '+
          '(`CallSign`, `QSODate`, `QSOTime`, `QSOBand`)';
      SQL_Query.ExecSQL;
            SQL_Query.SQL.Text:='CREATE INDEX `Call_index` ON `Log_TABLE_'+LOG_PREFIX+'` (`Call`);';
      SQL_Query.ExecSQL;
        ProgressBar1.Position := 77;
        SQL_Transaction.Commit;
        SQL_Query.Close;
        ProgressBar1.Position := 84;
        ProgressBar1.Position := 100;
        Label24.Caption := rSuccessful;
      finally
        SQL_Transaction.Commit;
        IniF.WriteString('DataBases', 'FileSQLite', SQLitePATH);
        IniF.WriteString('SetLog', 'LogBookInit', 'YES');
        IniF.WriteString('DataBases', 'DefaultDataBase', Default_DataBase);
      end;
    end;

    if SQLite_Current = True then
    begin
      IniF.WriteString('DataBases', 'FileSQLite', SQLitePATH);
      IniF.WriteString('SetLog', 'LogBookInit', 'YES');
      IniF.WriteString('DataBases', 'DefaultDataBase', Default_DataBase);
      ProgressBar1.Position := 100;
      Label24.Caption := rSuccessful;
    end;
    Button4.Enabled := True;
  end;

  finally
 // IniF.Free;
  end;

end;

procedure TSetupForm.FormShow(Sender: TObject);
begin
  Test_Connection := False;
  PageControl1.ActivePageIndex := 0;
  RadioButton2.Checked := True;
  ProgressBar1.Position := 0;
  MySQL_Current := False;
  SQLite_Current := False;
  Label24.Caption := rWait;
    Edit1.Enabled := False;
    Edit2.Enabled := False;
    Edit3.Enabled := False;
    Edit4.Enabled := False;
    Edit5.Enabled := False;
    Edit6.Enabled := True;
    SpeedButton1.Enabled := True;
    CheckBox4.Checked := True;
    CheckBox4.Enabled := False;
    CheckBox3.Enabled := False;
    CheckBox3.Checked := False;
    CheckBox2.Enabled := True;
    CheckBox1.Enabled := False;
    CheckBox1.Checked := False;
    Button2.Enabled := True;
    Button10.Enabled := False;

end;

procedure TSetupForm.RadioButton1Change(Sender: TObject);
begin
  if RadioButton1.Checked = True then
  begin
    Edit1.Enabled := True;
    Edit2.Enabled := True;
    Edit3.Enabled := True;
    Edit4.Enabled := True;
    Edit5.Enabled := True;
    Edit6.Enabled := False;
    SpeedButton1.Enabled := False;
    CheckBox3.Checked := True;
    CheckBox3.Enabled := False;
    CheckBox4.Enabled := False;
    CheckBox4.Checked := False;
    CheckBox1.Enabled := True;
    CheckBox2.Enabled := False;
    CheckBox2.Checked := False;
    Button10.Enabled := True;
    Button2.Enabled := False;
  end;
end;

procedure TSetupForm.RadioButton2Change(Sender: TObject);
begin
  if RadioButton2.Checked = True then
  begin
    Edit1.Enabled := False;
    Edit2.Enabled := False;
    Edit3.Enabled := False;
    Edit4.Enabled := False;
    Edit5.Enabled := False;
    Edit6.Enabled := True;
    SpeedButton1.Enabled := True;
    CheckBox4.Checked := True;
    CheckBox4.Enabled := False;
    CheckBox3.Enabled := False;
    CheckBox3.Checked := False;
    CheckBox2.Enabled := True;
    CheckBox1.Enabled := False;
    CheckBox1.Checked := False;
    Button2.Enabled := True;
    Button10.Enabled := False;
  end;
end;

procedure TSetupForm.RadioButton3Change(Sender: TObject);
begin
  if RadioButton3.Checked = True then
  begin
    Edit1.Enabled := True;
    Edit2.Enabled := True;
    Edit3.Enabled := True;
    Edit4.Enabled := True;
    Edit5.Enabled := True;
    Edit6.Enabled := True;
    SpeedButton1.Enabled := True;
    CheckBox3.Enabled := True;
    CheckBox4.Enabled := True;
    CheckBox1.Enabled := True;
    CheckBox2.Enabled := True;
    Button10.Enabled := True;
    Button2.Enabled := False;
  end;
end;

procedure TSetupForm.SpeedButton1Click(Sender: TObject);
begin
  if CheckBox2.Checked=False then begin
 if SaveDialog1.Execute then
  Edit6.Text := SaveDialog1.FileName;
  end
  else begin
 if OpenDialog1.Execute then
  Edit6.Text := OpenDialog1.FileName;
  end;
end;

procedure TSetupForm.Button1Click(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 1;
end;

procedure TSetupForm.Button10Click(Sender: TObject);
begin
  if (RadioButton1.Checked = True) or (RadioButton3.Checked = True) then
  begin
    try
      MySQL_Connector.HostName := Edit1.Text;
      MySQL_Connector.Port := StrToInt(Edit2.Text);
      MySQL_Connector.UserName := Edit3.Text;
      MySQL_Connector.Password := Edit4.Text;
      MySQL_Connector.DatabaseName := Edit5.Text;
      MySQL_Connector.Connected := True;
      if MySQL_Connector.Connected = True then begin
        Button2.Enabled := True;
        ShowMessage(rSuccessfulNext);
        end
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  end;
end;

procedure TSetupForm.Button2Click(Sender: TObject);
var
  State: boolean = False;
begin
  if RadioButton1.Checked = True then
    if (Edit1.Text = '') or (Edit2.Text = '') or (Edit3.Text = '') or
      (Edit4.Text = '') or (Edit5.Text = '') then
      ShowMessage(rValueEmpty)
    else
      State := True;

  if RadioButton2.Checked = True then
    if Edit6.Text = '' then
      ShowMessage(rCheckPath)
    else
      State := True;

  if RadioButton3.Checked = True then
    if (Edit6.Text = '') or (Edit1.Text = '') or (Edit2.Text = '') or
      (Edit3.Text = '') or (Edit4.Text = '') or (Edit5.Text = '') then
      ShowMessage(rValueEmpty)
    else
      State := True;

  if State = True then
  begin
    if RadioButton1.Checked = True then
      CheckedDB := 1;
    if RadioButton2.Checked = True then
      CheckedDB := 2;
    if RadioButton3.Checked = True then
      CheckedDB := 3;
    MySQL_HostName := Edit1.Text;
    if Edit2.Text <> '' then
      MySQL_Port := StrToInt(Edit2.Text);
    MySQL_LoginName := Edit3.Text;
    MySQL_Password := Edit4.Text;
    MySQL_BaseName := Edit5.Text;
    SQLitePATH := Edit6.Text;
    MySQL_Current := CheckBox1.Checked;
    SQLite_Current := CheckBox2.Checked;
    if CheckBox3.Checked = True then
      Default_DataBase := 'MySQL';
    if CheckBox4.Checked = True then
      Default_DataBase := 'SQLite';
    PageControl1.ActivePageIndex := 2;
  end;
end;

procedure TSetupForm.Button3Click(Sender: TObject);
begin
  if (Edit7.Text = '') or (Edit8.Text = '') or (Edit9.Text = '') or
    (Edit10.Text = '') or (Edit11.Text = '') or (Edit12.Text = '') or
    (Edit13.Text = '') or (Edit14.Text = '') or (Edit15.Text = '') or
    (dmFunc.IsLocOK(Edit11.Text) = False) then
    ShowMessage(rValueCorr)
  else
  begin
    Journal_Description := Edit7.Text;
    New_CallSign := Edit8.Text;
    New_QTH := Edit9.Text;
    New_Name := Edit10.Text;
    New_Grid := Edit11.Text;
    New_Latitude := Edit12.Text;
    New_Longitude := Edit13.Text;
    New_ITU := Edit14.Text;
    New_CQ := Edit15.Text;
    New_QSLInfo := Edit16.Text;
    PageControl1.ActivePageIndex := 3;
    InitializedDB;
  end;
end;

procedure TSetupForm.Button4Click(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 4;
end;

procedure TSetupForm.Button5Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TSetupForm.Button6Click(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
end;

procedure TSetupForm.Button7Click(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 1;
end;

procedure TSetupForm.Button8Click(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 2;
end;

procedure TSetupForm.Button9Click(Sender: TObject);
begin
  SetupForm.Close;
end;

procedure TSetupForm.CheckBox3Change(Sender: TObject);
begin
  if CheckBox3.Checked = True then
    CheckBox4.Checked := False;
end;

procedure TSetupForm.CheckBox4Change(Sender: TObject);
begin
  if CheckBox4.Checked = True then
    CheckBox3.Checked := False;
end;

procedure TSetupForm.Edit11Change(Sender: TObject);
var
  lat, lon: currency;
begin
  FormatSettings.DecimalSeparator:='.';
  if dmFunc.IsLocOK(Edit11.Text) then
  begin
    dmFunc.CoordinateFromLocator(Edit11.Text, lat, lon);
    Edit12.Text := CurrToStr(lat);
    Edit13.Text := CurrToStr(lon);
  end
  else
  begin
    Edit12.Text := '';
    Edit13.Text := '';
  end;
end;

end.
