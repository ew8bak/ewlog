unit LogConfigForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Buttons, DBCtrls, Menus, DB, LCLType, resourcestr;

type

  { TLogConfigForm }

  TLogConfigForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    Edit2: TEdit;
    Edit20: TEdit;
    Edit21: TEdit;
    Edit22: TEdit;
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
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ListBox1: TListBox;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    SQLQuery1: TSQLQuery;
    SQLQuery2: TSQLQuery;
    TabSheet3: TTabSheet;
    UpdateConfQuery: TSQLQuery;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit6Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
  private
    procedure SelectCall(SelCall: string);
    { private declarations }
  public
    { public declarations }
  end;

var
  LogConfigForm: TLogConfigForm;
  id: integer;

implementation

uses MainForm_U, CreateJournalForm_U, dmFunc_U, InitDB_dm;

{$R *.lfm}

{ TLogConfigForm }

procedure TLogConfigForm.SelectCall(SelCall: string);
begin
  DefaultFormatSettings.DecimalSeparator := '.';
  if DBRecord.DefaultDB = 'MySQL' then
    LogConfigForm.SQLQuery1.DataBase := MainForm.MySQLLOGDBConnection
  else
    LogConfigForm.SQLQuery1.DataBase := InitDB.SQLiteConnection;

  LogConfigForm.SQLQuery1.Close;
  LogConfigForm.SQLQuery1.SQL.Clear;
  if SelCall = '' then
    LogConfigForm.SQLQuery1.SQL.Add('SELECT * FROM LogBookInfo LIMIT 1');

  LogConfigForm.SQLQuery1.SQL.Add('select * from LogBookInfo where CallName = "' +
    SelCall + '"');
  LogConfigForm.SQLQuery1.Open;
  LogConfigForm.Edit1.Text := LogConfigForm.SQLQuery1.FieldByName(
    'Discription').AsString;
  LogConfigForm.Edit2.Text := LogConfigForm.SQLQuery1.FieldByName('CallName').AsString;
  LogConfigForm.Edit3.Text := LogConfigForm.SQLQuery1.FieldByName('Name').AsString;
  LogConfigForm.Edit4.Text := LogConfigForm.SQLQuery1.FieldByName('QTH').AsString;
  LogConfigForm.Edit5.Text := LogConfigForm.SQLQuery1.FieldByName('ITU').AsString;
  LogConfigForm.Edit6.Text := LogConfigForm.SQLQuery1.FieldByName('Loc').AsString;
  LogConfigForm.Edit7.Text := LogConfigForm.SQLQuery1.FieldByName('CQ').AsString;
  LogConfigForm.Edit8.Text := LogConfigForm.SQLQuery1.FieldByName('Lat').AsString;

  if LogConfigForm.SQLQuery1.FieldByName('Lat').AsString <> '' then
    LBRecord.OpLat := StrToFloat(LogConfigForm.SQLQuery1.FieldByName('Lat').AsString);

  LogConfigForm.Edit9.Text := LogConfigForm.SQLQuery1.FieldByName('Lon').AsString;
  if LogConfigForm.SQLQuery1.FieldByName('Lon').AsString <> '' then
    LBRecord.OpLon := StrToFloat(LogConfigForm.SQLQuery1.FieldByName('Lon').AsString);

  LogConfigForm.Edit10.Text := LogConfigForm.SQLQuery1.FieldByName('QSLInfo').AsString;
  LogConfigForm.Edit11.Text := LogConfigForm.SQLQuery1.FieldByName('EQSLLogin').AsString;
  LogConfigForm.Edit12.Text :=
    LogConfigForm.SQLQuery1.FieldByName('EQSLPassword').AsString;
  LogConfigForm.CheckBox1.Checked :=
    LogConfigForm.SQLQuery1.FieldByName('AutoEQSLcc').AsBoolean;
  LogConfigForm.Edit13.Text :=
    LogConfigForm.SQLQuery1.FieldByName('HRDLogLogin').AsString;
  LogConfigForm.Edit14.Text :=
    LogConfigForm.SQLQuery1.FieldByName('HRDLogPassword').AsString;
  LogConfigForm.CheckBox2.Checked :=
    LogConfigForm.SQLQuery1.FieldByName('AutoHRDLog').AsBoolean;
  LogConfigForm.Edit15.Text :=
    LogConfigForm.SQLQuery1.FieldByName('HamQTHLogin').AsString;
  LogConfigForm.Edit16.Text :=
    LogConfigForm.SQLQuery1.FieldByName('HamQTHPassword').AsString;
  LogConfigForm.CheckBox3.Checked :=
    LogConfigForm.SQLQuery1.FieldByName('AutoHamQTH').AsBoolean;
  LogConfigForm.Edit17.Text :=
    LogConfigForm.SQLQuery1.FieldByName('LoTW_User').AsString;
  LogConfigForm.Edit18.Text :=
    LogConfigForm.SQLQuery1.FieldByName('LoTW_Password').AsString;
  LogConfigForm.Edit19.Text :=
    LogConfigForm.SQLQuery1.FieldByName('ClubLog_User').AsString;
  LogConfigForm.Edit20.Text :=
    LogConfigForm.SQLQuery1.FieldByName('ClubLog_Password').AsString;
  LogConfigForm.CheckBox4.Checked :=
    LogConfigForm.SQLQuery1.FieldByName('AutoClubLog').AsBoolean;
  LogConfigForm.Edit21.Text :=
    LogConfigForm.SQLQuery1.FieldByName('QRZCOM_User').AsString;
  LogConfigForm.Edit22.Text :=
    LogConfigForm.SQLQuery1.FieldByName('QRZCOM_Password').AsString;
  LogConfigForm.CheckBox5.Checked :=
    LogConfigForm.SQLQuery1.FieldByName('AutoQRZCom').AsBoolean;

  id := LogConfigForm.SQLQuery1.FieldByName('id').AsInteger;
end;

procedure TLogConfigForm.Button2Click(Sender: TObject);
begin
  LogConfigForm.Close;
end;

procedure TLogConfigForm.Button1Click(Sender: TObject);
begin
  if MainForm.MySQLLOGDBConnection.Connected or InitDB.SQLiteConnection.Connected then begin
  with UpdateConfQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('UPDATE LogBookInfo' +
      ' SET `CallName`=:CallName,`Name`=:Name,`QTH`=:QTH, `ITU`=:ITU,' +
      ' `CQ`=:CQ, `Loc`=:Loc, `Lat`=:Lat, `Lon`=:Lon, `Discription`=:Discription,' +
      ' `QSLInfo`=:QSLInfo, `EQSLLogin`=:EQSLLogin, `EQSLPassword`=:EQSLPassword,' +
      ' `AutoEQSLcc`=:AutoEQSLcc, `HRDLogLogin`=:HRDLogLogin,' +
      ' `HRDLogPassword`=:HRDLogPassword, `AutoHRDLog`=:AutoHRDLog,' +
      ' `HamQTHLogin`=:HamQTHLogin, `HamQTHPassword`=:HamQTHPassword, `AutoQRZCom`=:AutoQRZCom,'
      + ' `QRZCOM_User`=:QRZCOM_User, `QRZCOM_Password`=:QRZCOM_Password,' +
      ' `ClubLog_User`=:ClubLog_User, `ClubLog_Password`=:ClubLog_Password,' +
      ' `AutoHamQTH`=:AutoHamQTH, `AutoClubLog`=:AutoClubLog, `LoTW_User`=:LoTW_User,' +
      ' `LoTW_Password`=:LoTW_Password WHERE `id`=:id');
    Params.ParamByName('CallName').AsString := Edit2.Text;
    Params.ParamByName('Name').AsString := Edit3.Text;
    Params.ParamByName('QTH').AsString := Edit4.Text;
    Params.ParamByName('ITU').AsString := Edit5.Text;
    Params.ParamByName('CQ').AsString := Edit7.Text;
    Params.ParamByName('Loc').AsString := Edit6.Text;
    Params.ParamByName('Lat').AsString := Edit8.Text;
    Params.ParamByName('Lon').AsString := Edit9.Text;
    Params.ParamByName('Discription').AsString := Edit1.Text;
    Params.ParamByName('QSLInfo').AsString := Edit10.Text;
    Params.ParamByName('EQSLLogin').AsString := Edit11.Text;
    Params.ParamByName('EQSLPassword').AsString := Edit12.Text;
    Params.ParamByName('AutoEQSLcc').AsBoolean := CheckBox1.Checked;
    Params.ParamByName('HRDLogLogin').AsString := Edit13.Text;
    Params.ParamByName('HRDLogPassword').AsString := Edit14.Text;
    Params.ParamByName('AutoHRDLog').AsBoolean := CheckBox2.Checked;
    Params.ParamByName('HamQTHLogin').AsString := Edit15.Text;
    Params.ParamByName('HamQTHPassword').AsString := Edit16.Text;
    Params.ParamByName('AutoHamQTH').AsBoolean := CheckBox3.Checked;
    Params.ParamByName('LoTW_User').AsString := Edit17.Text;
    Params.ParamByName('LoTW_Password').AsString := Edit18.Text;
    Params.ParamByName('ClubLog_User').AsString := Edit19.Text;
    Params.ParamByName('ClubLog_Password').AsString := Edit20.Text;
    Params.ParamByName('AutoClubLog').AsBoolean := CheckBox4.Checked;
    Params.ParamByName('QRZCOM_User').AsString := Edit21.Text;
    Params.ParamByName('QRZCOM_Password').AsString := Edit22.Text;
    Params.ParamByName('AutoQRZCom').AsBoolean := CheckBox5.Checked;

    Params.ParamByName('id').AsInteger := id;
    ExecSQL;
  end;
  MainForm.SQLTransaction1.Commit;
  MainForm.SelDB(CallLogBook);
  LogConfigForm.Close;
  end;
end;

procedure TLogConfigForm.Edit6Change(Sender: TObject);
var
  lat, lon: currency;
begin
  if dmFunc.IsLocOK(Edit6.Text) then
  begin
    dmFunc.CoordinateFromLocator(Edit6.Text, lat, lon);
    Edit8.Text := CurrToStr(lat);
    Edit9.Text := CurrToStr(lon);
  end
  else
  begin
    Edit8.Text := '';
    Edit9.Text := '';
  end;
end;

procedure TLogConfigForm.FormCreate(Sender: TObject);
begin
  if DBRecord.InitDB = 'YES' then
  begin
    if DBRecord.DefaultDB = 'MySQL' then
      UpdateConfQuery.DataBase := MainForm.MySQLLOGDBConnection
    else
      UpdateConfQuery.DataBase := InitDB.SQLiteConnection;
    if MainForm.DBLookupComboBox1.Text <> '' then
      SelectCall(MainForm.DBLookupComboBox1.KeyValue);
  end;
end;

procedure TLogConfigForm.FormShow(Sender: TObject);
var
  i: integer;
begin
  if MainForm.MySQLLOGDBConnection.Connected or
    InitDB.SQLiteConnection.Connected then
  begin
    try
      if DBRecord.InitDB = 'YES' then
      begin

        if DBRecord.DefaultDB = 'MySQL' then
          SQLQuery2.DataBase := MainForm.MySQLLOGDBConnection
        else
          SQLQuery2.DataBase := InitDB.SQLiteConnection;


        if DBRecord.DefaultDB = 'MySQL' then
          UpdateConfQuery.DataBase := MainForm.MySQLLOGDBConnection
        else
          UpdateConfQuery.DataBase := InitDB.SQLiteConnection;
        SelectCall(MainForm.DBLookupComboBox1.KeyValue);
      end;

      ListBox1.Clear;
      SQLQuery2.SQL.Clear;
      SQLQuery2.SQL.Add('SELECT * FROM LogBookInfo');
      SQLQuery2.Open;
      SQLQuery2.First;
      for i := 0 to SQLQuery2.RecordCount - 1 do
      begin
        ListBox1.Items.Add(SQLQuery2.FieldByName('CallName').Value);
        SQLQuery2.Next;
      end;
      for i := 0 to ListBox1.Count - 1 do
        if Pos(MainForm.DBLookupComboBox1.KeyValue, ListBox1.Items[i]) > 0 then
        begin
          ListBox1.Selected[i] := True;
          exit;
        end;

      if CallLogBook = ListBox1.Items.Text then
        Label15.Visible := True
      else
        Label15.Visible := False;
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  end;
end;

procedure TLogConfigForm.ListBox1Click(Sender: TObject);
begin
  if MainForm.MySQLLOGDBConnection.Connected or
    InitDB.SQLiteConnection.Connected then
  begin
    SelectCall(ListBox1.Items[ListBox1.ItemIndex]);
    if CallLogBook = ListBox1.Items[ListBox1.ItemIndex] then
      Label15.Visible := True
    else
      Label15.Visible := False;
  end;
end;

procedure TLogConfigForm.MenuItem1Click(Sender: TObject);
begin
  CreateJournalForm.Show;
  LogConfigForm.Close;
end;

procedure TLogConfigForm.MenuItem3Click(Sender: TObject);
var
  droptablename: string;
  i: integer;
begin
  if MainForm.MySQLLOGDBConnection.Connected or
    InitDB.SQLiteConnection.Connected then
  begin
    if Application.MessageBox(PChar(rDeleteLog), PChar(rWarning),
      MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
    begin
      if CallLogBook = ListBox1.Items[ListBox1.ItemIndex] then
      begin
        ShowMessage(rCannotDelDef);
        exit;
      end;

      SQLQuery2.Close;
      SQLQuery2.SQL.Clear;
      SQLQuery2.SQL.Add('select * from LogBookInfo where CallName = "' +
        ListBox1.Items[ListBox1.ItemIndex] + '"');
      SQLQuery2.Open;
      droptablename := SQLQuery2.FieldByName('LogTable').Value;
      SQLQuery2.Close;
      SQLQuery2.SQL.Clear;
      SQLQuery2.SQL.Add('DROP TABLE "' + droptablename + '"');
      SQLQuery2.ExecSQL;
      SQLQuery2.SQL.Clear;
      SQLQuery2.SQL.Add('delete from LogBookInfo where CallName = "' +
        ListBox1.Items[ListBox1.ItemIndex] + '"');
      SQLQuery2.ExecSQL;
      SQLQuery2.SQLTransaction.Commit;
      SQLQuery2.SQL.Clear;
      ListBox1.Clear;
      SQLQuery2.SQL.Clear;
      SQLQuery2.SQL.Add('SELECT * FROM LogBookInfo');
      SQLQuery2.Open;
      SQLQuery2.First;
      for i := 0 to SQLQuery2.RecordCount - 1 do
      begin
        ListBox1.Items.Add(SQLQuery2.FieldByName('CallName').Value);
        SQLQuery2.Next;
      end;
      MainForm.SelDB(CallLogBook);
      for i := 0 to ListBox1.Count - 1 do
        if Pos(MainForm.DBLookupComboBox1.KeyValue, ListBox1.Items[i]) > 0 then
        begin
          ListBox1.Selected[i] := True;
          exit;
        end;
    end
    else
      Exit;
  end;
end;

procedure TLogConfigForm.MenuItem4Click(Sender: TObject);
begin
  if MainForm.MySQLLOGDBConnection.Connected or
    InitDB.SQLiteConnection.Connected then
  begin
    INIFile.WriteString('SetLog', 'DefaultCallLogBook', ListBox1.Items[ListBox1.ItemIndex]);
    ShowMessage(rDefaultLogSel + ' ' + ListBox1.Items[ListBox1.ItemIndex]);
    MainForm.DBLookupComboBox1.KeyValue := ListBox1.Items[ListBox1.ItemIndex];
    MainForm.DBLookupComboBox1CloseUp(Self);
    if ListBox1.Items[ListBox1.ItemIndex] = MainForm.DBLookupComboBox1.KeyValue then
      Label15.Visible := True
    else
      Label15.Visible := False;
  end;
end;

end.
