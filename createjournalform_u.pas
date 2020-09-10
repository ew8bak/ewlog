unit CreateJournalForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, LCLType;

type

  { TCreateJournalForm }

  TCreateJournalForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
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
    procedure Edit2Change(Sender: TObject);
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

uses miniform_u, dmFunc_U, ResourceStr, SetupSQLquery, setupForm_U,
  InitDB_dm, MainFuncDM;

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
  if DBRecord.CurrentDB = 'MySQL' then
  begin
    CreateTableQuery.DataBase := InitDB.MySQLConnection;
    //MainForm.MySQLLOGDBConnection.Transaction := MainForm.SQLTransaction1;
  end
  else
  begin
    CreateTableQuery.DataBase := InitDB.SQLiteConnection;
    // MainForm.SQLiteDBConnection.Transaction := MainForm.SQLTransaction1;
  end;
end;

procedure TCreateJournalForm.FormShow(Sender: TObject);
begin
  if DBRecord.CurrentDB = 'MySQL' then
  begin
    CreateTableQuery.DataBase := InitDB.MySQLConnection;
    // MainForm.MySQLLOGDBConnection.Transaction := MainForm.SQLTransaction1;
    CreateTableQuery.Transaction := InitDB.DefTransaction;
  end
  else
  begin
    CreateTableQuery.DataBase := InitDB.SQLiteConnection;
    // MainForm.SQLiteDBConnection.Transaction := MainForm.SQLTransaction1;
    CreateTableQuery.Transaction := InitDB.DefTransaction;
  end;
end;

procedure TCreateJournalForm.Button2Click(Sender: TObject);
var
  LOG_PREFIX: string;
  CountStr: integer;
  newLogBookname: string;
begin
  if (Edit1.Text = '') or (Edit2.Text = '') or (Edit3.Text = '') or
    (Edit4.Text = '') or (Edit5.Text = '') or (Edit6.Text = '') or (Edit7.Text = '') then
    ShowMessage(rAllfieldsmustbefilled)
  else
  begin
    if InitDB.MySQLConnection.Connected or InitDB.SQLiteConnection.Connected then
    begin
      try
        LOG_PREFIX := FormatDateTime('DDMMYYYY_HHNNSS', Now);
        CreateTableQuery.Close;
       // CreateTableQuery.SQL.Text := 'SELECT COUNT(*) FROM LogBookInfo';
       // CreateTableQuery.Open;
      //  CountStr := CreateTableQuery.Fields[0].AsInteger + 1;
       // CreateTableQuery.Close;

        CreateTableQuery.SQL.Text := Insert_Table_LogBookInfo;
       // CreateTableQuery.ParamByName('id').AsInteger := CountStr;
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
        CreateTableQuery.ParamByName('Table_version').AsString := Table_version;
        CreateTableQuery.ExecSQL;
        InitDB.DefTransaction.Commit;

        if DBRecord.CurrentDB = 'MySQL' then
        begin
          InitDB.MySQLConnection.ExecuteDirect(
            dmSQL.Table_Log_Table(LOG_PREFIX, 'MySQL'));
          InitDB.MySQLConnection.ExecuteDirect(dmSQL.CreateIndex(
            LOG_PREFIX, 'MySQL'));
        end
        else
        begin
          InitDB.SQLiteConnection.ExecuteDirect(
            dmSQL.Table_Log_Table(LOG_PREFIX, 'SQLite'));
          InitDB.SQLiteConnection.ExecuteDirect(dmSQL.CreateIndex(
            LOG_PREFIX, 'SQLite'));
        end;
        InitDB.DefTransaction.Commit;
      finally
        newLogBookName := Edit2.Text;
        Edit1.Clear;
        Edit2.Clear;
        Edit3.Clear;
        Edit4.Clear;
        Edit5.Clear;
        Edit6.Clear;
        Edit7.Clear;
        Edit8.Clear;
        Edit9.Clear;
        if Application.MessageBox(PChar(rSetAsDefaultJournal),
          PChar(rWarning), MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
        begin
          INIFile.WriteString('SetLog', 'DefaultCallLogBook', newLogBookName);
          DBRecord.DefCall:=newLogBookName;
        end;

        if InitDB.GetLogBookTable(DBRecord.CurrCall, DBRecord.CurrentDB) then
          if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
            ShowMessage(rDBError);

        MainFunc.LoadBMSL(MiniForm.CBMode, MiniForm.CBSubMode, MiniForm.CBBand, MiniForm.CBCurrentLog);

        if Application.MessageBox(PChar(rSwitchToANewLog), PChar(rWarning),
          MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
        begin
          MiniForm.CBCurrentLog.SetFocus;
          MiniForm.CBCurrentLog.DroppedDown := True;
        end;
      end;
    end
    else
    if Application.MessageBox(PChar(rDBNotinit), PChar(rWarning),
      MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      SetupForm.Show;
  end;
end;

procedure TCreateJournalForm.Edit2Change(Sender: TObject);
begin
  if MiniForm.CBCurrentLog.Items.IndexOf(Edit2.Text) >= 0 then
  begin
    Edit2.Color := clRed;
    Button2.Enabled := False;
  end
  else
  begin
    Edit2.Color := clDefault;
    Button2.Enabled := True;
  end;
end;

procedure TCreateJournalForm.Button1Click(Sender: TObject);
begin
  CreateJournalForm.Close;
end;

end.
