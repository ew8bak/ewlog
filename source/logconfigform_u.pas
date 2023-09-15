(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit LogConfigForm_U;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, Forms, Controls, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Menus, DB, LCLType, resourcestr;

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
    EditDescription: TEdit;
    EditQSLinfo: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    EditCallSign: TEdit;
    Edit20: TEdit;
    Edit21: TEdit;
    Edit22: TEdit;
    EditName: TEdit;
    EditQTH: TEdit;
    EditITU: TEdit;
    EditGrid: TEdit;
    EditCQ: TEdit;
    EditLat: TEdit;
    EditLon: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    LBDefaultCall: TLabel;
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
    LBCallsigns: TListBox;
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
    procedure EditGridChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LBCallsignsClick(Sender: TObject);
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

uses miniform_u, CreateJournalForm_U, dmFunc_U, InitDB_dm, MainFuncDM;

{$R *.lfm}

{ TLogConfigForm }

procedure TLogConfigForm.SelectCall(SelCall: string);
begin
    SQLQuery1.DataBase := InitDB.SQLiteConnection;

  SQLQuery1.Close;
  SQLQuery1.SQL.Clear;
  if SelCall = '' then
    SQLQuery1.SQL.Text := 'SELECT * FROM LogBookInfo LIMIT 1'
  else
    SQLQuery1.SQL.Text :=
      'SELECT * FROM LogBookInfo WHERE CallName = "' + SelCall + '"';
  SQLQuery1.Open;
  if SQLQuery1.FieldByName('CallName').AsString <> '' then
  begin
    EditDescription.Text := SQLQuery1.FieldByName('Discription').AsString;
    EditCallSign.Text := SQLQuery1.FieldByName('CallName').AsString;
    EditName.Text := SQLQuery1.FieldByName('Name').AsString;
    EditQTH.Text := SQLQuery1.FieldByName('QTH').AsString;
    EditITU.Text := SQLQuery1.FieldByName('ITU').AsString;
    EditGrid.Text := SQLQuery1.FieldByName('Loc').AsString;
    EditCQ.Text := SQLQuery1.FieldByName('CQ').AsString;
    EditLat.Text := SQLQuery1.FieldByName('Lat').AsString;

    if SQLQuery1.FieldByName('Lat').AsString <> '' then
      TryStrToFloatSafe(SQLQuery1.FieldByName('Lat').AsString, LBRecord.OpLat);

    EditLon.Text := SQLQuery1.FieldByName('Lon').AsString;
    if SQLQuery1.FieldByName('Lon').AsString <> '' then
      TryStrToFloatSafe(SQLQuery1.FieldByName('Lon').AsString, LBRecord.OpLon);

    EditQSLinfo.Text := SQLQuery1.FieldByName('QSLInfo').AsString;
    Edit11.Text := SQLQuery1.FieldByName('EQSLLogin').AsString;
    Edit12.Text := SQLQuery1.FieldByName('EQSLPassword').AsString;
    CheckBox1.Checked := SQLQuery1.FieldByName('AutoEQSLcc').AsBoolean;
    Edit13.Text := SQLQuery1.FieldByName('HRDLogLogin').AsString;
    Edit14.Text := SQLQuery1.FieldByName('HRDLogPassword').AsString;
    CheckBox2.Checked := SQLQuery1.FieldByName('AutoHRDLog').AsBoolean;
    Edit15.Text := SQLQuery1.FieldByName('HamQTHLogin').AsString;
    Edit16.Text := SQLQuery1.FieldByName('HamQTHPassword').AsString;
    CheckBox3.Checked := SQLQuery1.FieldByName('AutoHamQTH').AsBoolean;
    Edit17.Text := SQLQuery1.FieldByName('LoTW_User').AsString;
    Edit18.Text := SQLQuery1.FieldByName('LoTW_Password').AsString;
    Edit19.Text := SQLQuery1.FieldByName('ClubLog_User').AsString;
    Edit20.Text := SQLQuery1.FieldByName('ClubLog_Password').AsString;
    CheckBox4.Checked := SQLQuery1.FieldByName('AutoClubLog').AsBoolean;
    Edit21.Text := SQLQuery1.FieldByName('QRZCOM_User').AsString;
    Edit22.Text := SQLQuery1.FieldByName('QRZCOM_Password').AsString;
    CheckBox5.Checked := SQLQuery1.FieldByName('AutoQRZCom').AsBoolean;
    id := SQLQuery1.FieldByName('id').AsInteger;
  end
  else
    ShowMessage(rTableLogDBError);
end;

procedure TLogConfigForm.Button2Click(Sender: TObject);
begin
  LogConfigForm.Close;
end;

procedure TLogConfigForm.Button1Click(Sender: TObject);
begin
  if InitDB.SQLiteConnection.Connected then
  begin
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
        ' `AutoHamQTH`=:AutoHamQTH, `AutoClubLog`=:AutoClubLog, `LoTW_User`=:LoTW_User,'
        +
        ' `LoTW_Password`=:LoTW_Password WHERE `id`=:id');
      Params.ParamByName('CallName').AsString := EditCallSign.Text;
      Params.ParamByName('Name').AsString := EditName.Text;
      Params.ParamByName('QTH').AsString := EditQTH.Text;
      Params.ParamByName('ITU').AsString := EditITU.Text;
      Params.ParamByName('CQ').AsString := EditCQ.Text;
      Params.ParamByName('Loc').AsString := EditGrid.Text;
      Params.ParamByName('Lat').AsString := EditLat.Text;
      Params.ParamByName('Lon').AsString := EditLon.Text;
      Params.ParamByName('Discription').AsString := EditDescription.Text;
      Params.ParamByName('QSLInfo').AsString := EditQSLinfo.Text;
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
    InitDB.DefTransaction.Commit;
 //   if LBDefaultCall.IsVisible then
 //   begin
 //     DBRecord.DefCall := EditCallSign.Text;
 //     INIFile.WriteString('SetLog', 'DefaultCallLogBook', EditCallSign.Text);
 //   end;
 //   if (not InitDB.GetLogBookTable(DBRecord.DefCall)) and
 //     (DBRecord.InitDB = 'YES') then
 //     ShowMessage('LogBook Table ERROR')
 //   else
 //   if (not InitDB.SelectLogbookTable(LBRecord.LogTable)) and
 //     (DBRecord.InitDB = 'YES') then
 //     ShowMessage(rDBError);
 //   MainFunc.LoadBMSL(MiniForm.CBMode, MiniForm.CBSubMode, MiniForm.CBBand,
 //     MiniForm.CBCurrentLog);
 //   MiniForm.CBCurrentLogChange(LogConfigForm);
 //   LogConfigForm.Close;
  end;
end;

procedure TLogConfigForm.EditGridChange(Sender: TObject);
var
  lat, lon: currency;
begin
  if dmFunc.IsLocOK(EditGrid.Text) then
  begin
    dmFunc.CoordinateFromLocator(EditGrid.Text, lat, lon);
    EditLat.Text := StringReplace(CurrToStr(lat), ',', '.', [rfReplaceAll]);
    EditLon.Text := StringReplace(CurrToStr(lon), ',', '.', [rfReplaceAll]);
  end
  else
  begin
    EditLat.Text := '';
    EditLon.Text := '';
  end;
end;

procedure TLogConfigForm.FormShow(Sender: TObject);
var
  i: integer;
begin
  SQLQuery2.Close;
  UpdateConfQuery.Close;

  if InitDB.SQLiteConnection.Connected then
  begin
    try
      if DBRecord.InitDB = 'YES' then
      begin
          SQLQuery2.DataBase := InitDB.SQLiteConnection;
          UpdateConfQuery.DataBase := InitDB.SQLiteConnection;
        end;
      //  SelectCall(DBRecord.CurrCall);

      LBCallsigns.Clear;
      SQLQuery2.SQL.Clear;
      SQLQuery2.SQL.Add('SELECT * FROM LogBookInfo');
      SQLQuery2.Open;
      SQLQuery2.First;
      for i := 0 to SQLQuery2.RecordCount - 1 do
      begin
        LBCallsigns.Items.Add(SQLQuery2.FieldByName('CallName').AsString);
        SQLQuery2.Next;
      end;
      for i := 0 to LBCallsigns.Count - 1 do
        if Pos(MiniForm.CBCurrentLog.Text, LBCallsigns.Items[i]) > 0 then
        begin
          LBCallsigns.Selected[i] := True;
          //exit;
          Break;
        end;

 //     if LBCallsigns.Items[LBCallsigns.ItemIndex] = DBRecord.DefCall then
 //       LBDefaultCall.Visible := True
 //     else
 //       LBDefaultCall.Visible := False;

    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  end;
end;

procedure TLogConfigForm.LBCallsignsClick(Sender: TObject);
begin
  if LBCallsigns.ItemIndex <> -1 then
  begin
    if InitDB.SQLiteConnection.Connected then
    begin
 //     SelectCall(LBCallsigns.Items[LBCallsigns.ItemIndex]);
 //     if LBCallsigns.Items[LBCallsigns.ItemIndex] = DBRecord.DefCall then
 //       LBDefaultCall.Visible := True
 //     else
 //       LBDefaultCall.Visible := False;
    end;
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
  if LBCallsigns.ItemIndex <> -1 then
  begin
    if InitDB.SQLiteConnection.Connected then
    begin
      if Application.MessageBox(PChar(rDeleteLog), PChar(rWarning),
        MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      begin
  //      if (DBRecord.DefCall = LBCallsigns.Items[LBCallsigns.ItemIndex]) or
  //        (DBRecord.CurrCall = LBCallsigns.Items[LBCallsigns.ItemIndex]) then
  //      begin
  //        ShowMessage(rCannotDelDef);
  //        exit;
  //      end;

        SQLQuery2.Close;
        SQLQuery2.SQL.Clear;
        SQLQuery2.SQL.Add('SELECT * FROM LogBookInfo WHERE CallName = "' +
          LBCallsigns.Items[LBCallsigns.ItemIndex] + '"');
        SQLQuery2.Open;
        droptablename := SQLQuery2.FieldByName('LogTable').Value;
        SQLQuery2.Close;
        SQLQuery2.SQL.Clear;
        SQLQuery2.SQL.Add('DROP TABLE "' + droptablename + '"');
        SQLQuery2.ExecSQL;
        SQLQuery2.SQL.Clear;
        SQLQuery2.SQL.Add('DELETE FROM LogBookInfo WHERE CallName = "' +
          LBCallsigns.Items[LBCallsigns.ItemIndex] + '"');
        SQLQuery2.ExecSQL;
        SQLQuery2.SQLTransaction.Commit;
        SQLQuery2.SQL.Clear;
        LBCallsigns.Clear;
        SQLQuery2.SQL.Clear;
        SQLQuery2.SQL.Add('SELECT * FROM LogBookInfo');
        SQLQuery2.Open;
        SQLQuery2.First;
        for i := 0 to SQLQuery2.RecordCount - 1 do
        begin
          LBCallsigns.Items.Add(SQLQuery2.FieldByName('CallName').AsString);
          SQLQuery2.Next;
        end;
        if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
          ShowMessage(rDBError);
    //    for i := 0 to LBCallsigns.Count - 1 do
    //      if Pos(DBRecord.CurrCall, LBCallsigns.Items[i]) > 0 then
    //      begin
    //        LBCallsigns.Selected[i] := True;
    //        MainFunc.LoadJournalItem(MiniForm.CBCurrentLog);
    //        exit;
    //      end;
      end
      else
        Exit;
    end;
  end;
end;

procedure TLogConfigForm.MenuItem4Click(Sender: TObject);
begin
  if LBCallsigns.ItemIndex <> -1 then
  begin
    if InitDB.SQLiteConnection.Connected then
    begin
      INIFile.WriteString('SetLog', 'DefaultCallLogBook',
        LBCallsigns.Items[LBCallsigns.ItemIndex]);
 //     DBRecord.DefCall := LBCallsigns.Items[LBCallsigns.ItemIndex];
      ShowMessage(rDefaultLogSel + ' ' + LBCallsigns.Items[LBCallsigns.ItemIndex]);
 //     if LBCallsigns.Items[LBCallsigns.ItemIndex] = DBRecord.DefCall then
 //       LBDefaultCall.Visible := True
  //    else
  //      LBDefaultCall.Visible := False;
    end;
  end;
end;

end.
