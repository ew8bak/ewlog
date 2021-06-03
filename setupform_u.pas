(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit setupForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mysql56conn, sqlite3conn, sqldb, FileUtil, Forms, Controls,
  Graphics, Dialogs, ComCtrls, StdCtrls, ExtCtrls, Buttons, ResourceStr, LCLType,
  LResources, prefix_record, dmmigrate_u;

type

  { TSetupForm }

  TSetupForm = class(TForm)
    Bevel1: TBevel;
    Button1: TButton;
    BtCheck: TButton;
    BtNext: TButton;
    Button3: TButton;
    Button4: TButton;
    BtBack: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CBExpertMode: TCheckBox;
    EditHost: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    EditPort: TEdit;
    EditUser: TEdit;
    EditPasswd: TEdit;
    EditNameDB: TEdit;
    EditSQLPath: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Label1: TLabel;
    LBSQLPath: TLabel;
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
    Label3: TLabel;
    LBSelectDB: TLabel;
    LBHost: TLabel;
    LBPort: TLabel;
    LBUsername: TLabel;
    LBPassword: TLabel;
    LBNameDB: TLabel;
    Memo1: TMemo;
    MySQL_Connector: TMySQL56Connection;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
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
    procedure BtCheckClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BtNextClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure BtBackClick(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox4Change(Sender: TObject);
    procedure Edit11Change(Sender: TObject);
    procedure Edit8Change(Sender: TObject);
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
    function CheckEmptyDB: boolean;
    { private declarations }
  public
    { public declarations }
  end;

var
  SetupForm: TSetupForm;

implementation

uses dmFunc_U, SetupSQLquery, InitDB_dm, MainFuncDM, miniform_u;

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
          MySQL_Connector.ExecuteDirect(Table_LogBookInfoMySQL);
          ProgressBar1.Position := 56;
          SQL_Query.Transaction := SQL_Transaction;
          LOG_PREFIX := FormatDateTime('DDMMYYYY_HHNNSS', Now);
          ProgressBar1.Position := 63;
          Label24.Caption := rFillInLogBookInfo;
          SQL_Query.SQL.Text := Insert_Table_LogBookInfo;
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
          SQL_Query.ParamByName('Table_version').AsString := Current_Table;
          SQL_Query.ExecSQL;
          ProgressBar1.Position := 70;
          SQL_Transaction.Commit;
          SQL_Query.Close;
          Label24.Caption := rFillInLogTable + LOG_PREFIX;
          MySQL_Connector.ExecuteDirect(dmSQL.Table_Log_Table(LOG_PREFIX, 'MySQL'));
          ProgressBar1.Position := 77;
          Label24.Caption := rAddIndexInLogTable + LOG_PREFIX;
          MySQL_Connector.ExecuteDirect(dmSQL.CreateIndex(LOG_PREFIX, 'MySQL'));
          ProgressBar1.Position := 84;
          Label24.Caption := rAddKeyInLogTable + LOG_PREFIX;
          ProgressBar1.Position := 100;
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
        INIFile.WriteString('SetLog', 'DefaultCallLogBook', New_CallSign);
        INIFile.WriteString('DataBases', 'HostAddr', MySQL_HostName);
        INIFile.WriteString('DataBases', 'Port', IntToStr(MySQL_Port));
        INIFile.WriteString('DataBases', 'LoginName', MySQL_LoginName);
        INIFile.WriteString('DataBases', 'Password', MySQL_Password);
        INIFile.WriteString('DataBases', 'DataBaseName', MySQL_BaseName);
        INIFile.WriteString('SetLog', 'LogBookInit', 'YES');
        INIFile.WriteString('DataBases', 'DefaultDataBase', 'MySQL');
        INIFile.WriteString('DataBases', 'FileSQLite', '');
      end;
    end;

    if (CheckedDB = 1) and (MySQL_Current = True) then
    begin
      INIFile.WriteString('SetLog', 'DefaultCallLogBook', New_CallSign);
      INIFile.WriteString('DataBases', 'HostAddr', MySQL_HostName);
      INIFile.WriteString('DataBases', 'Port', IntToStr(MySQL_Port));
      INIFile.WriteString('DataBases', 'LoginName', MySQL_LoginName);
      INIFile.WriteString('DataBases', 'Password', MySQL_Password);
      INIFile.WriteString('DataBases', 'DataBaseName', MySQL_BaseName);
      INIFile.WriteString('SetLog', 'LogBookInit', 'YES');
      INIFile.WriteString('DataBases', 'DefaultDataBase', 'MySQL');
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
        Label24.Caption := rCreateTableLogBookInfo;
        SQLite_Connector.ExecuteDirect(Table_LogBookInfo);
        ProgressBar1.Position := 56;
        SQL_Query.Transaction := SQL_Transaction;
        LOG_PREFIX := FormatDateTime('DDMMYYYY_HHNNSS', Now);
        SQL_Query.Close;
        ProgressBar1.Position := 63;
        Label24.Caption := rFillInlogBookInfo;
        SQL_Query.SQL.Text := Insert_Table_LogBookInfo;
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
        SQL_Query.ParamByName('Table_version').AsString := Current_Table;
        SQL_Query.ExecSQL;
        ProgressBar1.Position := 70;
        SQL_Transaction.Commit;
        SQL_Query.Close;
        Label24.Caption := rFillInLogTable + LOG_PREFIX;
        SQLite_Connector.ExecuteDirect(dmSQL.Table_Log_Table(LOG_PREFIX, 'SQLite'));
        SQLite_Connector.ExecuteDirect(dmSQL.CreateIndex(LOG_PREFIX, 'SQLite'));
        ProgressBar1.Position := 100;
        Label24.Caption := rSuccessful;
      finally
        SQL_Transaction.Commit;
        Button4.Enabled := True;
        INIFile.WriteString('SetLog', 'DefaultCallLogBook', New_CallSign);
        INIFile.WriteString('DataBases', 'HostAddr', '');
        INIFile.WriteString('DataBases', 'Port', '');
        INIFile.WriteString('DataBases', 'LoginName', '');
        INIFile.WriteString('DataBases', 'Password', '');
        INIFile.WriteString('DataBases', 'DataBaseName', '');
        INIFile.WriteString('DataBases', 'FileSQLite', SQLitePATH);
        INIFile.WriteString('SetLog', 'LogBookInit', 'YES');
        INIFile.WriteString('DataBases', 'DefaultDataBase', 'SQLite');
      end;
    end;

    if (CheckedDB = 2) and (SQLite_Current = True) then
    begin
      INIFile.WriteString('SetLog', 'DefaultCallLogBook', New_CallSign);
      INIFile.WriteString('DataBases', 'HostAddr', '');
      INIFile.WriteString('DataBases', 'Port', '');
      INIFile.WriteString('DataBases', 'LoginName', '');
      INIFile.WriteString('DataBases', 'Password', '');
      INIFile.WriteString('DataBases', 'DataBaseName', '');
      INIFile.WriteString('DataBases', 'FileSQLite', SQLitePATH);
      INIFile.WriteString('SetLog', 'LogBookInit', 'YES');
      INIFile.WriteString('DataBases', 'DefaultDataBase', 'SQLite');
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
            Label24.Caption := rCreateTableLogBookInfo;
            SQL_Query.Close;
            MySQL_Connector.ExecuteDirect(Table_LogBookInfoMySQL);
            ProgressBar1.Position := 56;
            SQL_Query.Transaction := SQL_Transaction;
            LOG_PREFIX := FormatDateTime('DDMMYYYY_HHNNSS', Now);
            ProgressBar1.Position := 63;
            SQL_Query.Close;
            Label24.Caption := rFillInlogBookInfo;
            SQL_Query.SQL.Text := Insert_Table_LogBookInfo;
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
            SQL_Query.ParamByName('Table_version').AsString := Current_Table;
            SQL_Query.ExecSQL;
            ProgressBar1.Position := 70;
            SQL_Transaction.Commit;
            SQL_Query.Close;
            Label24.Caption := rFillInLogTable + LOG_PREFIX;
            MySQL_Connector.ExecuteDirect(dmSQL.Table_Log_Table(LOG_PREFIX, 'MySQL'));
            Label24.Caption := rAddIndexInLogTable + LOG_PREFIX;
            MySQL_Connector.ExecuteDirect(dmSQL.CreateIndex(LOG_PREFIX, 'MySQL'));
            ProgressBar1.Position := 84;
            Label24.Caption := rAddKeyInLogTable + LOG_PREFIX;
            ProgressBar1.Position := 100;
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
          INIFile.WriteString('SetLog', 'DefaultCallLogBook', New_CallSign);
          INIFile.WriteString('DataBases', 'HostAddr', MySQL_HostName);
          INIFile.WriteString('DataBases', 'Port', IntToStr(MySQL_Port));
          INIFile.WriteString('DataBases', 'LoginName', MySQL_LoginName);
          INIFile.WriteString('DataBases', 'Password', MySQL_Password);
          INIFile.WriteString('DataBases', 'DataBaseName', MySQL_BaseName);
          INIFile.WriteString('SetLog', 'LogBookInit', 'YES');
          INIFile.WriteString('DataBases', 'DefaultDataBase', 'MySQL');

        end;
      end;

      if MySQL_Current = True then
      begin
        INIFile.WriteString('SetLog', 'DefaultCallLogBook', New_CallSign);
        INIFile.WriteString('DataBases', 'HostAddr', MySQL_HostName);
        INIFile.WriteString('DataBases', 'Port', IntToStr(MySQL_Port));
        INIFile.WriteString('DataBases', 'LoginName', MySQL_LoginName);
        INIFile.WriteString('DataBases', 'Password', MySQL_Password);
        INIFile.WriteString('DataBases', 'DataBaseName', MySQL_BaseName);
        INIFile.WriteString('SetLog', 'LogBookInit', 'YES');
        INIFile.WriteString('DataBases', 'DefaultDataBase', 'MySQL');
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
          SQLite_Connector.ExecuteDirect(Table_LogBookInfo);
          SQL_Query.Transaction := SQL_Transaction;
          LOG_PREFIX := FormatDateTime('DDMMYYYY_HHNNSS', Now);
          ProgressBar1.Position := 63;
          SQL_Query.Close;
          Label24.Caption := rFillInlogBookInfo;
          SQL_Query.SQL.Text := Insert_Table_LogBookInfo;
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
          SQL_Query.ParamByName('Table_version').AsString := Current_Table;
          SQL_Query.ExecSQL;
          ProgressBar1.Position := 70;
          // SQL_Transaction.Commit;
          SQL_Query.Close;
          Label24.Caption := rFillInLogTable + LOG_PREFIX + ' in SQLite';
          SQLite_Connector.ExecuteDirect(dmSQL.Table_Log_Table(LOG_PREFIX, 'SQLite'));
          SQLite_Connector.ExecuteDirect(dmSQL.CreateIndex(LOG_PREFIX, 'SQLite'));
          ProgressBar1.Position := 100;
          Label24.Caption := rSuccessful;
        finally
          SQL_Transaction.Commit;
          INIFile.WriteString('DataBases', 'FileSQLite', SQLitePATH);
          INIFile.WriteString('SetLog', 'LogBookInit', 'YES');
          INIFile.WriteString('DataBases', 'DefaultDataBase', Default_DataBase);
        end;
      end;

      if SQLite_Current = True then
      begin
        INIFile.WriteString('DataBases', 'FileSQLite', SQLitePATH);
        INIFile.WriteString('SetLog', 'LogBookInit', 'YES');
        INIFile.WriteString('DataBases', 'DefaultDataBase', Default_DataBase);
        ProgressBar1.Position := 100;
        Label24.Caption := rSuccessful;
      end;
      Button4.Enabled := True;
    end;

  finally
    SQL_Transaction.Commit;
    SQL_Transaction.EndTransaction;
    MySQL_Connector.Connected := False;
    SQLite_Connector.Connected := False;
    SQL_Transaction.Active := False;
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
  EditHost.Enabled := False;
  EditPort.Enabled := False;
  EditUser.Enabled := False;
  EditPasswd.Enabled := False;
  EditNameDB.Enabled := False;
  EditSQLPath.Enabled := True;
  SpeedButton1.Enabled := True;
  CheckBox4.Checked := True;
  CheckBox4.Enabled := False;
  CheckBox3.Enabled := False;
  CheckBox3.Checked := False;
  CheckBox2.Enabled := True;
  CheckBox1.Enabled := False;
  CheckBox1.Checked := False;
  BtNext.Enabled := True;
  BtCheck.Enabled := False;
  EditSQLPath.Text := '';
end;

procedure TSetupForm.RadioButton1Change(Sender: TObject);
begin
  if RadioButton1.Checked = True then
  begin
    EditHost.Enabled := True;
    EditPort.Enabled := True;
    EditUser.Enabled := True;
    EditPasswd.Enabled := True;
    EditNameDB.Enabled := True;
    EditSQLPath.Enabled := False;
    SpeedButton1.Enabled := False;
    CheckBox3.Checked := True;
    CheckBox3.Enabled := False;
    CheckBox4.Enabled := False;
    CheckBox4.Checked := False;
    CheckBox1.Enabled := True;
    CheckBox2.Enabled := False;
    CheckBox2.Checked := False;
    BtCheck.Enabled := True;
    BtNext.Enabled := False;
  end;
end;

procedure TSetupForm.RadioButton2Change(Sender: TObject);
begin
  if RadioButton2.Checked = True then
  begin
    EditHost.Enabled := False;
    EditPort.Enabled := False;
    EditUser.Enabled := False;
    EditPasswd.Enabled := False;
    EditNameDB.Enabled := False;
    EditSQLPath.Enabled := True;
    SpeedButton1.Enabled := True;
    CheckBox4.Checked := True;
    CheckBox4.Enabled := False;
    CheckBox3.Enabled := False;
    CheckBox3.Checked := False;
    CheckBox2.Enabled := True;
    CheckBox1.Enabled := False;
    CheckBox1.Checked := False;
    BtNext.Enabled := True;
    BtCheck.Enabled := False;
  end;
end;

procedure TSetupForm.RadioButton3Change(Sender: TObject);
begin
  if RadioButton3.Checked = True then
  begin
    EditHost.Enabled := True;
    EditPort.Enabled := True;
    EditUser.Enabled := True;
    EditPasswd.Enabled := True;
    EditNameDB.Enabled := True;
    EditSQLPath.Enabled := True;
    SpeedButton1.Enabled := True;
    CheckBox3.Enabled := True;
    CheckBox4.Enabled := True;
    CheckBox1.Enabled := True;
    CheckBox2.Enabled := True;
    BtCheck.Enabled := True;
    BtNext.Enabled := False;
  end;
end;

procedure TSetupForm.SpeedButton1Click(Sender: TObject);
begin
  if CheckBox2.Checked = False then
  begin
    if SaveDialog1.Execute then
    begin
      if FileExists(SaveDialog1.FileName) then
        if Application.MessageBox(PChar(rFileExist), PChar(rWarning),
          MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
        begin
          if not DeleteFile(SaveDialog1.FileName) then
          begin
            ShowMessage(rFileUsed);
            Exit;
          end;
        end
        else
        begin
          Exit;
        end;
      EditSQLPath.Text := SaveDialog1.FileName;
    end;
  end
  else
  begin
    if OpenDialog1.Execute then
      EditSQLPath.Text := OpenDialog1.FileName;
  end;
end;

procedure TSetupForm.Button1Click(Sender: TObject);
begin
  if CBExpertMode.Checked then
    PageControl1.ActivePageIndex := 1
  else
  begin
    CheckedDB := 2;
    SQLitePATH := FilePATH + 'logbook.db';
    Default_DataBase := 'SQLite';
    if CheckEmptyDB then
      PageControl1.ActivePageIndex := 2;
  end;
end;

function TSetupForm.CheckEmptyDB: boolean;
var
  Query: TSQLQuery;
begin
  Result := False;
  try
    Query := TSQLQuery.Create(nil);
    Edit7.Clear;
    Edit8.Clear;
    Edit9.Clear;
    Edit10.Clear;
    Edit11.Clear;
    Edit14.Clear;
    Edit15.Clear;

    if not FileExists(SQLitePATH) then
    begin
      Result := True;
      Exit;
    end
    else
    begin
      try
        if Application.MessageBox(PChar(rFileDBExist), PChar(rWarning),
          MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
        begin
          SQLite_Current := True;
          SQLite_Connector.DatabaseName := SQLitePATH;
          SQLite_Connector.Transaction := SQL_Transaction;
          SQLite_Connector.Connected := True;
          Query.DataBase := SQLite_Connector;
          Query.SQL.Text := 'SELECT * FROM LogBookInfo LIMIT 1';
          Query.Open;
          if Query.FieldByName('CallName').AsString <> '' then
          begin
            Edit7.Text := Query.FieldByName('Discription').AsString;
            Edit8.Text := Query.FieldByName('CallName').AsString;
            Edit9.Text := Query.FieldByName('QTH').AsString;
            Edit10.Text := Query.FieldByName('Name').AsString;
            Edit11.Text := Query.FieldByName('Loc').AsString;
            Edit14.Text := Query.FieldByName('ITU').AsString;
            Edit15.Text := Query.FieldByName('CQ').AsString;
            Edit16.Text := Query.FieldByName('QSLInfo').AsString;
          end;
          Query.Close;
          Result := True;
        end
        else
        begin
          if Application.MessageBox(PChar(rDeleteDBFile), PChar(rWarning),
            MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
          begin
            SQLite_Current := False;
            DeleteFile(SQLitePATH);
            Result := True;
          end
          else
          begin
            Exit;
          end;
        end;
      except
        on E: Exception do
        begin
          WriteLn(ExceptFile, 'TSetupForm.CheckEmptyDB:' + E.ClassName +
            ':' + E.Message);
          SQLite_Connector.Connected := False;
          SQLite_Current := False;
        end;
      end;
    end;

  finally
    SQLite_Connector.Connected := False;
    FreeAndNil(Query);
  end;
end;

procedure TSetupForm.BtCheckClick(Sender: TObject);
begin
  if (RadioButton1.Checked = True) or (RadioButton3.Checked = True) then
  begin
    try
      MySQL_Connector.HostName := EditHost.Text;
      MySQL_Connector.Port := StrToInt(EditPort.Text);
      MySQL_Connector.UserName := EditUser.Text;
      MySQL_Connector.Password := EditPasswd.Text;
      MySQL_Connector.DatabaseName := EditNameDB.Text;
      MySQL_Connector.Connected := True;
      if MySQL_Connector.Connected = True then
      begin
        BtNext.Enabled := True;
        ShowMessage(rSuccessfulNext);
      end
    except
      on E: Exception do
      begin
        WriteLn(ExceptFile, 'SetupForm.Button10Click: Error: ' +
          E.ClassName + ':' + E.Message);
        ShowMessage(rDatabaseNotConnected);
      end;
    end;
  end;
end;

procedure TSetupForm.BtNextClick(Sender: TObject);
var
  State: boolean = False;
begin
  if RadioButton1.Checked = True then
    if (EditHost.Text = '') or (EditPort.Text = '') or (EditUser.Text = '') or
      (EditPasswd.Text = '') or (EditNameDB.Text = '') then
      ShowMessage(rValueEmpty)
    else
      State := True;

  if RadioButton2.Checked = True then
    if EditSQLPath.Text = '' then
      ShowMessage(rCheckPath)
    else
      State := True;

  if RadioButton3.Checked = True then
    if (EditSQLPath.Text = '') or (EditHost.Text = '') or (EditPort.Text = '') or
      (EditUser.Text = '') or (EditPasswd.Text = '') or (EditNameDB.Text = '') then
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
    MySQL_HostName := EditHost.Text;
    if EditPort.Text <> '' then
      MySQL_Port := StrToInt(EditPort.Text);
    MySQL_LoginName := EditUser.Text;
    MySQL_Password := EditPasswd.Text;
    MySQL_BaseName := EditNameDB.Text;
    SQLitePATH := EditSQLPath.Text;
    MySQL_Current := CheckBox1.Checked;
    SQLite_Current := CheckBox2.Checked;

    if SQLite_Current then
      CheckEmptyDB;

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
  InitDB.AllFree;
  InitDB.DataModuleCreate(SetupForm);
  MiniForm.LoadComboBoxItem;
  Close;
end;

procedure TSetupForm.BtBackClick(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
end;

procedure TSetupForm.Button7Click(Sender: TObject);
begin
  if CBExpertMode.Checked then
    PageControl1.ActivePageIndex := 1
  else
    PageControl1.ActivePageIndex := 0;
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
  FormatSettings.DecimalSeparator := '.';
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

procedure TSetupForm.Edit8Change(Sender: TObject);
var
  PFXR: TPFXR;
  Lat: string = '';
  Lon: string = '';
begin
  if Length(Edit8.Text) > 0 then
  begin
    PFXR := MainFunc.SearchPrefix(Edit8.Text, '');
    Edit14.Text := PFXR.ITUZone;
    Edit15.Text := PFXR.CQZone;
    dmFunc.GetLatLon(PFXR.Latitude, PFXR.Longitude, Lat, Lon);
    Edit12.Text := Lat;
    Edit13.Text := Lon;
  end;
end;

end.
