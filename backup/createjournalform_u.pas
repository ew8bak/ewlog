unit CreateJournalForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons;

type

  { TCreateJournalForm }

  TCreateJournalForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    CreateTableQuery: TSQLQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit7Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  CreateJournalForm: TCreateJournalForm;

implementation

uses MainForm_U, dmFunc_U;

{$R *.lfm}


procedure TCreateJournalForm.Edit7Change(Sender: TObject);
var
  lat, lon: currency;
begin
  if dmFunc.IsLocOK(Edit7.Text) then
  begin
    dmFunc.CoordinateFromLocator(Edit7.Text, lat, lon);
    Edit8.Text := CurrToStr(lat);
    Edit9.Text := CurrToStr(lon);
  end
  else
  begin
    Edit8.Text := '';
    Edit9.Text := '';
  end;

end;

procedure TCreateJournalForm.FormCreate(Sender: TObject);
begin
  if DefaultDB = 'MySQL' then
    CreateTableQuery.DataBase := MainForm.MySQLLOGDBConnection
  else
    CreateTableQuery.DataBase := MainForm.SQLiteDBConnection;
        if DefaultDB='MySQL' then
      MainForm.MySQLLOGDBConnection.Transaction := MainForm.SQLTransaction1
      else
      MainForm.SQLiteDBConnection.Transaction := MainForm.SQLTransaction1;
end;

procedure TCreateJournalForm.FormShow(Sender: TObject);
begin
    if DefaultDB = 'MySQL' then
    CreateTableQuery.DataBase := MainForm.MySQLLOGDBConnection
  else
    CreateTableQuery.DataBase := MainForm.SQLiteDBConnection;
         if DefaultDB='MySQL' then
      MainForm.MySQLLOGDBConnection.Transaction := MainForm.SQLTransaction1
      else
      MainForm.SQLiteDBConnection.Transaction := MainForm.SQLTransaction1;

end;

procedure TCreateJournalForm.Button2Click(Sender: TObject);
var
  LOG_PREFIX: string;
  CountStr, i: integer;
begin
  if (Edit1.Text = '') or (Edit2.Text = '') or (Edit3.Text = '') or
    (Edit4.Text = '') or (Edit5.Text = '') or (Edit6.Text = '') or (Edit7.Text = '') or
    (Edit8.Text = '') or (Edit9.Text = '') then
    ShowMessage('Все поля должны быть заполнены!')
  else
    try
      LOG_PREFIX := FormatDateTime('DDMMYYYY_HHNNSS', Now);
      CreateTableQuery.Close;
      CreateTableQuery.SQL.Text := 'SELECT COUNT(*) FROM LogBookInfo';
      CreateTableQuery.Open;
      CountStr := CreateTableQuery.Fields[0].AsInteger + 1;
      CreateTableQuery.Close;

      CreateTableQuery.SQL.Text :=
        'INSERT INTO LogBookInfo ' +
        '(id,LogTable,CallName,Name,QTH,ITU,CQ,Loc,Lat,Lon,Discription,QSLInfo,EQSLLogin,EQSLPassword)'
        + ' VALUES (:id,:LogTable,:CallName,:Name,:QTH,:ITU,:CQ,:Loc,:Lat,:Lon,:Discription,:QSLInfo,:EQSLLogin,:EQSLPassword)';
      CreateTableQuery.ParamByName('id').AsInteger := CountStr;
      CreateTableQuery.ParamByName('LogTable').AsString := 'Log_TABLE_' + LOG_PREFIX;
      CreateTableQuery.ParamByName('CallName').AsString := Edit2.Text;
      CreateTableQuery.ParamByName('Name').AsString := Edit4.Text;
      CreateTableQuery.ParamByName('QTH').AsString := Edit3.Text;
      CreateTableQuery.ParamByName('ITU').AsString := Edit5.Text;
      CreateTableQuery.ParamByName('CQ').AsString := Edit6.Text;
      CreateTableQuery.ParamByName('Loc').AsString := Edit7.Text;
      CreateTableQuery.ParamByName('Lat').AsString := Edit8.Text;
      CreateTableQuery.ParamByName('Lon').AsString := Edit9.Text;
      CreateTableQuery.ParamByName('Discription').AsString := Edit1.Text;
      CreateTableQuery.ParamByName('QSLInfo').AsString := Edit10.Text;
      CreateTableQuery.ParamByName('EQSLLogin').AsString := '';
      CreateTableQuery.ParamByName('EQSLPassword').AsString := '';
      CreateTableQuery.ExecSQL;
      MainForm.SQLTransaction1.Commit;
      CreateTableQuery.Close;
      if DefaultDB = 'MySQL' then
      CreateTableQuery.SQL.Text :=
        'CREATE TABLE IF NOT EXISTS `Log_TABLE_' + LOG_PREFIX + '` ' +
       '(' + ' `UnUsedIndex` integer NOT NULL,' +
        ' `CallSign` varchar(20) DEFAULT NULL,' + ' `QSODate` datetime DEFAULT NULL,' +
        ' `QSOTime` varchar(5) DEFAULT NULL,' + ' `QSOBand` varchar(10) DEFAULT NULL,' +
        ' `QSOMode` varchar(7) DEFAULT NULL,' +
        ' `QSOReportSent` varchar(15) DEFAULT NULL,' +
        ' `QSOReportRecived` varchar(15) DEFAULT NULL,' +
        ' `OMName` varchar(20) DEFAULT NULL,' + ' `OMQTH` varchar(25) DEFAULT NULL,' +
        ' `State` varchar(25) DEFAULT NULL,' + ' `Grid` varchar(6) DEFAULT NULL,' +
        ' `IOTA` varchar(6) DEFAULT NULL,' + ' `QSLManager` varchar(9) DEFAULT NULL,' +
        ' `QSLSent` tinyint(1) DEFAULT NULL,' + ' `QSLSentAdv` varchar(1) DEFAULT NULL,' +
        ' `QSLSentDate` datetime DEFAULT NULL,' + ' `QSLRec` tinyint(1) DEFAULT NULL,' +
        ' `QSLRecDate` datetime DEFAULT NULL,' + ' `MainPrefix` varchar(5) DEFAULT NULL,' +
        ' `DXCCPrefix` varchar(5) DEFAULT NULL,' + ' `CQZone` varchar(2) DEFAULT NULL,' +
        ' `ITUZone` varchar(2) DEFAULT NULL,' + ' `QSOAddInfo` longtext,' +
        ' `Marker` int(11) DEFAULT NULL,' + ' `ManualSet` tinyint(1) DEFAULT NULL,' +
        ' `DigiBand` double DEFAULT NULL,' + ' `Continent` varchar(2) DEFAULT NULL,' +
        ' `ShortNote` varchar(30) DEFAULT NULL,' +
        ' `QSLReceQSLcc` tinyint(1) DEFAULT NULL,' +
        ' `LoTWRec` tinyint(1) DEFAULT NULL,' + ' `LoTWRecDate` datetime DEFAULT NULL,' +
        ' `QSLInfo` varchar(100) DEFAULT NULL,' + ' `Call` varchar(20) DEFAULT NULL,' +
        ' `State1` varchar(25) DEFAULT NULL,' + ' `State2` varchar(25) DEFAULT NULL,' +
        ' `State3` varchar(25) DEFAULT NULL,' + ' `State4` varchar(25) DEFAULT NULL,' +
        ' `WPX` varchar(10) DEFAULT NULL,' + ' `AwardsEx` longtext,' +
        ' `ValidDX` tinyint(1) DEFAULT NULL,' + ' `SRX` int(11) DEFAULT NULL,' +
        ' `SRX_STRING` varchar(15) DEFAULT NULL,' + ' `STX` int(11) DEFAULT NULL,' +
        ' `STX_STRING` varchar(15) DEFAULT NULL,' +
        ' `SAT_NAME` varchar(20) DEFAULT NULL,' + ' `SAT_MODE` varchar(20) DEFAULT NULL,' +
        ' `PROP_MODE` varchar(20) DEFAULT NULL,' + ' `LoTWSent` tinyint(1) DEFAULT NULL,' +
        ' `QSL_RCVD_VIA` varchar(1) DEFAULT NULL,' +
        ' `QSL_SENT_VIA` varchar(1) DEFAULT NULL,' + ' `DXCC` varchar(5) DEFAULT NULL,' +
        ' `USERS` varchar(5) DEFAULT NULL,' + ' `NoCalcDXCC` tinyint(1) DEFAULT NULL' +
        ' )'
        else
        CreateTableQuery.SQL.Text :=
        'CREATE TABLE IF NOT EXISTS `Log_TABLE_' + LOG_PREFIX + '` ' +
        '(' + ' `UnUsedIndex` integer PRIMARY KEY AUTOINCREMENT NOT NULL,' +
        ' `CallSign` varchar(20) DEFAULT NULL,' + ' `QSODate` datetime DEFAULT NULL,' +
        ' `QSOTime` varchar(5) DEFAULT NULL,' + ' `QSOBand` varchar(10) DEFAULT NULL,' +
        ' `QSOMode` varchar(7) DEFAULT NULL,' +
        ' `QSOReportSent` varchar(15) DEFAULT NULL,' +
        ' `QSOReportRecived` varchar(15) DEFAULT NULL,' +
        ' `OMName` varchar(20) DEFAULT NULL,' + ' `OMQTH` varchar(25) DEFAULT NULL,' +
        ' `State` varchar(25) DEFAULT NULL,' + ' `Grid` varchar(6) DEFAULT NULL,' +
        ' `IOTA` varchar(6) DEFAULT NULL,' + ' `QSLManager` varchar(9) DEFAULT NULL,' +
        ' `QSLSent` tinyint(1) DEFAULT NULL,' + ' `QSLSentAdv` varchar(1) DEFAULT NULL,' +
        ' `QSLSentDate` datetime DEFAULT NULL,' + ' `QSLRec` tinyint(1) DEFAULT NULL,' +
        ' `QSLRecDate` datetime DEFAULT NULL,' + ' `MainPrefix` varchar(5) DEFAULT NULL,' +
        ' `DXCCPrefix` varchar(5) DEFAULT NULL,' + ' `CQZone` varchar(2) DEFAULT NULL,' +
        ' `ITUZone` varchar(2) DEFAULT NULL,' + ' `QSOAddInfo` longtext,' +
        ' `Marker` int(11) DEFAULT NULL,' + ' `ManualSet` tinyint(1) DEFAULT NULL,' +
        ' `DigiBand` double DEFAULT NULL,' + ' `Continent` varchar(2) DEFAULT NULL,' +
        ' `ShortNote` varchar(30) DEFAULT NULL,' +
        ' `QSLReceQSLcc` tinyint(1) DEFAULT NULL,' +
        ' `LoTWRec` tinyint(1) DEFAULT NULL,' + ' `LoTWRecDate` datetime DEFAULT NULL,' +
        ' `QSLInfo` varchar(100) DEFAULT NULL,' + ' `Call` varchar(20) DEFAULT NULL,' +
        ' `State1` varchar(25) DEFAULT NULL,' + ' `State2` varchar(25) DEFAULT NULL,' +
        ' `State3` varchar(25) DEFAULT NULL,' + ' `State4` varchar(25) DEFAULT NULL,' +
        ' `WPX` varchar(10) DEFAULT NULL,' + ' `AwardsEx` longtext,' +
        ' `ValidDX` tinyint(1) DEFAULT NULL,' + ' `SRX` int(11) DEFAULT NULL,' +
        ' `SRX_STRING` varchar(15) DEFAULT NULL,' + ' `STX` int(11) DEFAULT NULL,' +
        ' `STX_STRING` varchar(15) DEFAULT NULL,' +
        ' `SAT_NAME` varchar(20) DEFAULT NULL,' + ' `SAT_MODE` varchar(20) DEFAULT NULL,' +
        ' `PROP_MODE` varchar(20) DEFAULT NULL,' + ' `LoTWSent` tinyint(1) DEFAULT NULL,' +
        ' `QSL_RCVD_VIA` varchar(1) DEFAULT NULL,' +
        ' `QSL_SENT_VIA` varchar(1) DEFAULT NULL,' + ' `DXCC` varchar(5) DEFAULT NULL,' +
        ' `USERS` varchar(5) DEFAULT NULL,' + ' `NoCalcDXCC` tinyint(1) DEFAULT NULL' +
        ' )';
      CreateTableQuery.ExecSQL;
      MainForm.SQLTransaction1.Commit;
      if DefaultDB = 'MySQL' then
      begin
        CreateTableQuery.Close;
        CreateTableQuery.SQL.Text :=
          'ALTER TABLE `Log_TABLE_' + LOG_PREFIX + '` ' +
          ' ADD PRIMARY KEY (`UnUsedIndex`),' + ' ADD KEY `Call` (`Call`),' +
          ' ADD KEY `CallSign` (`CallSign`),' + ' ADD KEY `QSODate` (`QSODate`,`QSOTime`),' +
          ' ADD KEY `DigiBand` (`DigiBand`),' + ' ADD KEY `DXCC` (`DXCC`),' +
          ' ADD KEY `DXCCPrefix` (`DXCCPrefix`),' + ' ADD KEY `IOTA` (`IOTA`),' +
          ' ADD KEY `MainPrefix` (`MainPrefix`),' + ' ADD KEY `QSOMode` (`QSOMode`),' +
          ' ADD KEY `State` (`State`),' + ' ADD KEY `State1` (`State1`),' +
          ' ADD KEY `State2` (`State2`),' + ' ADD KEY `State3` (`State3`),' +
          ' ADD KEY `State4` (`State4`),' + ' ADD KEY `WPX` (`WPX`);';
        CreateTableQuery.ExecSQL;
        MainForm.SQLTransaction1.Commit;
        CreateTableQuery.Close;
        CreateTableQuery.SQL.Text :=
          'ALTER TABLE `Log_TABLE_' + LOG_PREFIX + '` ' +
          ' MODIFY `UnUsedIndex` int(11) NOT NULL AUTO_INCREMENT;';
        CreateTableQuery.ExecSQL;
        MainForm.SQLTransaction1.Commit;
      end;
    finally
      IniF.WriteString('SetLog', 'DefaultCallLogBook', Edit2.Text);
      MainForm.TrayIcon1.BalloonHint := 'Журнал успешно добавлен';
      MainForm.TrayIcon1.ShowBalloonHint;
      Edit1.Clear;
      Edit2.Clear;
      Edit3.Clear;
      Edit4.Clear;
      Edit5.Clear;
      Edit6.Clear;
      Edit7.Clear;
      Edit8.Clear;
      Edit9.Clear;
      //MainForm.SelDB(CallLogBook);
      ShowMessage('Работа программы будет завершена, запустите заново!');
      Application.Terminate;
      //InitDB_Form.Close;
    end;
end;

procedure TCreateJournalForm.Button1Click(Sender: TObject);
begin
  CreateJournalForm.Close;
end;

end.
