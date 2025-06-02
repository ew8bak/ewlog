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
    btSave: TButton;
    btCancel: TButton;
    cbUploadEqslcc: TCheckBox;
    cbUploadHRDLog: TCheckBox;
    cbUploadHamQTH: TCheckBox;
    cbUploadClubLog: TCheckBox;
    cbUploadQRZcom: TCheckBox;
    cbUploadQSOsu: TCheckBox;
    editAPItokenQSOsu: TEdit;
    cbUploadHAMLogOnline: TCheckBox;
    editAPIkeyHAMLogOnline: TEdit;
    EditDescription: TEdit;
    EditQSLinfo: TEdit;
    editLoginEqslcc: TEdit;
    editPasswordEqslcc: TEdit;
    editLoginHRDLog: TEdit;
    editUploadCodeHRDLog: TEdit;
    editLoginHamQTH: TEdit;
    editPasswordHamQTH: TEdit;
    editLoginLoTW: TEdit;
    editPasswordLoTW: TEdit;
    editLoginClubLog: TEdit;
    EditCallSign: TEdit;
    editPasswordClubLog: TEdit;
    editLoginQRZcom: TEdit;
    editAPIkeyQRZcom: TEdit;
    EditName: TEdit;
    EditQTH: TEdit;
    EditITU: TEdit;
    EditGrid: TEdit;
    EditCQ: TEdit;
    EditLat: TEdit;
    EditLon: TEdit;
    lbAPITokenQRZsu: TLabel;
    lbAPIkeyQRZcom1: TLabel;
    lbAPIkeyHAMLogOnline: TLabel;
    lbQRZsu: TLabel;
    lbLog: TLabel;
    lbCQ: TLabel;
    lbGrid: TLabel;
    lbLat: TLabel;
    lbLon: TLabel;
    lbQRZcom1: TLabel;
    lbHAMLogOnline: TLabel;
    lbQSLinfo: TLabel;
    LBDefaultCall: TLabel;
    lbEqslcc: TLabel;
    lbLoginEqslcc: TLabel;
    lbPasswordEqslcc: TLabel;
    lbHRDLog: TLabel;
    lbDescription: TLabel;
    lbLoginHRDLog: TLabel;
    lbUploadCodeHRDLog: TLabel;
    lbHamQTH: TLabel;
    lbLoginHamQTH: TLabel;
    lbPasswordHamQTH: TLabel;
    lbLoginLoTW: TLabel;
    lbPasswordLoTW: TLabel;
    lbLoTW: TLabel;
    lbClubLog: TLabel;
    lbLoginClubLog: TLabel;
    lbPasswordClubLog: TLabel;
    lbLoginQRZcom: TLabel;
    lbAPIkeyQRZcom: TLabel;
    lbQRZcom: TLabel;
    lbStationDetalis: TLabel;
    lbCallsign: TLabel;
    lbName: TLabel;
    lbQTH: TLabel;
    lbLocationInformation: TLabel;
    lbITU: TLabel;
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
    TabSheet3: TTabSheet;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet4: TTabSheet;
    procedure btSaveClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure EditGridChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LBCallsignsClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
  private
    procedure SelectLogBook(SelectDescription: string);
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

procedure TLogConfigForm.SelectLogBook(SelectDescription: string);
var
  Query: TSQLQuery;
begin
  try
    Query := TSQLQuery.Create(nil);
    Query.DataBase := InitDB.SQLiteConnection;

    if SelectDescription = '' then
      Query.SQL.Text := 'SELECT * FROM LogBookInfo LIMIT 1'
    else
      Query.SQL.Text :=
        'SELECT * FROM LogBookInfo WHERE Description = "' + SelectDescription + '"';
    Query.Open;
    if Query.FieldByName('Description').AsString <> '' then
    begin
      EditDescription.Text := Query.FieldByName('Description').AsString;
      EditCallSign.Text := Query.FieldByName('CallName').AsString;
      EditName.Text := Query.FieldByName('Name').AsString;
      EditQTH.Text := Query.FieldByName('QTH').AsString;
      EditITU.Text := Query.FieldByName('ITU').AsString;
      EditGrid.Text := Query.FieldByName('Loc').AsString;
      EditCQ.Text := Query.FieldByName('CQ').AsString;
      EditLat.Text := Query.FieldByName('Lat').AsString;

      if Query.FieldByName('Lat').AsString <> '' then
        TryStrToFloatSafe(Query.FieldByName('Lat').AsString, LBRecord.OpLat);

      EditLon.Text := Query.FieldByName('Lon').AsString;
      if Query.FieldByName('Lon').AsString <> '' then
        TryStrToFloatSafe(Query.FieldByName('Lon').AsString, LBRecord.OpLon);

      EditQSLinfo.Text := Query.FieldByName('QSLInfo').AsString;
      editLoginEqslcc.Text := Query.FieldByName('EQSLLogin').AsString;
      editPasswordEqslcc.Text := Query.FieldByName('EQSLPassword').AsString;
      cbUploadEqslcc.Checked := Query.FieldByName('AutoEQSLcc').AsBoolean;
      editLoginHRDLog.Text := Query.FieldByName('HRDLogLogin').AsString;
      editUploadCodeHRDLog.Text := Query.FieldByName('HRDLogPassword').AsString;
      cbUploadHRDLog.Checked := Query.FieldByName('AutoHRDLog').AsBoolean;
      editLoginHamQTH.Text := Query.FieldByName('HamQTHLogin').AsString;
      editPasswordHamQTH.Text := Query.FieldByName('HamQTHPassword').AsString;
      cbUploadHamQTH.Checked := Query.FieldByName('AutoHamQTH').AsBoolean;
      editLoginLoTW.Text := Query.FieldByName('LoTW_User').AsString;
      editPasswordLoTW.Text := Query.FieldByName('LoTW_Password').AsString;
      editLoginClubLog.Text := Query.FieldByName('ClubLog_User').AsString;
      editPasswordClubLog.Text := Query.FieldByName('ClubLog_Password').AsString;
      cbUploadClubLog.Checked := Query.FieldByName('AutoClubLog').AsBoolean;
      editLoginQRZcom.Text := Query.FieldByName('QRZCOM_User').AsString;
      editAPIkeyQRZcom.Text := Query.FieldByName('QRZCOM_Password').AsString;
      cbUploadQRZcom.Checked := Query.FieldByName('AutoQRZCom').AsBoolean;
      cbUploadQSOsu.Checked := Query.FieldByName('AutoQSOsu').AsBoolean;
      editAPItokenQSOsu.Text := Query.FieldByName('QSOSU_Token').AsString;
      editAPIkeyHAMLogOnline.Text := Query.FieldByName('HAMLogOnline_API').AsString;
      cbUploadHAMLogOnline.Checked := Query.FieldByName('AutoHAMLogOnline').AsBoolean;
      id := Query.FieldByName('id').AsInteger;
    end
    else
      ShowMessage(rTableLogDBError);

  finally
    FreeAndNil(Query);
  end;
end;

procedure TLogConfigForm.btCancelClick(Sender: TObject);
begin
  LogConfigForm.Close;
end;

procedure TLogConfigForm.btSaveClick(Sender: TObject);
var
  Query: TSQLQuery;
begin
  try
    Query := TSQLQuery.Create(nil);
    if InitDB.SQLiteConnection.Connected then
    begin
      with Query do
      begin
        DataBase := InitDB.SQLiteConnection;
        SQL.Text := 'UPDATE LogBookInfo' +
          ' SET `CallName`=:CallName,`Name`=:Name,`QTH`=:QTH, `ITU`=:ITU,' +
          ' `CQ`=:CQ, `Loc`=:Loc, `Lat`=:Lat, `Lon`=:Lon, `Description`=:Description,' +
          ' `QSLInfo`=:QSLInfo, `EQSLLogin`=:EQSLLogin, `EQSLPassword`=:EQSLPassword,' +
          ' `AutoEQSLcc`=:AutoEQSLcc, `HRDLogLogin`=:HRDLogLogin,' +
          ' `HRDLogPassword`=:HRDLogPassword, `AutoHRDLog`=:AutoHRDLog,' +
          ' `HamQTHLogin`=:HamQTHLogin, `HamQTHPassword`=:HamQTHPassword, `AutoQRZCom`=:AutoQRZCom,' +
          ' `AutoQSOsu`=:AutoQSOsu, `QSOSU_Token`=:QSOSU_Token,'
          + ' `QRZCOM_User`=:QRZCOM_User, `QRZCOM_Password`=:QRZCOM_Password,' +
          ' `HAMLogOnline_API`=:HAMLogOnline_API, `AutoHAMLogOnline`=:AutoHAMLogOnline,' +
          ' `ClubLog_User`=:ClubLog_User, `ClubLog_Password`=:ClubLog_Password,' +
          ' `AutoHamQTH`=:AutoHamQTH, `AutoClubLog`=:AutoClubLog, `LoTW_User`=:LoTW_User,'
          + ' `LoTW_Password`=:LoTW_Password WHERE `id`=:id';
        Params.ParamByName('CallName').AsString := EditCallSign.Text;
        Params.ParamByName('Name').AsString := EditName.Text;
        Params.ParamByName('QTH').AsString := EditQTH.Text;
        Params.ParamByName('ITU').AsString := EditITU.Text;
        Params.ParamByName('CQ').AsString := EditCQ.Text;
        Params.ParamByName('Loc').AsString := EditGrid.Text;
        Params.ParamByName('Lat').AsString := EditLat.Text;
        Params.ParamByName('Lon').AsString := EditLon.Text;
        Params.ParamByName('Description').AsString := EditDescription.Text;
        Params.ParamByName('QSLInfo').AsString := EditQSLinfo.Text;
        Params.ParamByName('EQSLLogin').AsString := editLoginEqslcc.Text;
        Params.ParamByName('EQSLPassword').AsString := editPasswordEqslcc.Text;
        Params.ParamByName('AutoEQSLcc').AsBoolean := cbUploadEqslcc.Checked;
        Params.ParamByName('HRDLogLogin').AsString := editLoginHRDLog.Text;
        Params.ParamByName('HRDLogPassword').AsString := editUploadCodeHRDLog.Text;
        Params.ParamByName('AutoHRDLog').AsBoolean := cbUploadHRDLog.Checked;
        Params.ParamByName('HamQTHLogin').AsString := editLoginHamQTH.Text;
        Params.ParamByName('HamQTHPassword').AsString := editPasswordHamQTH.Text;
        Params.ParamByName('AutoHamQTH').AsBoolean := cbUploadHamQTH.Checked;
        Params.ParamByName('LoTW_User').AsString := editLoginLoTW.Text;
        Params.ParamByName('LoTW_Password').AsString := editPasswordLoTW.Text;
        Params.ParamByName('ClubLog_User').AsString := editLoginClubLog.Text;
        Params.ParamByName('ClubLog_Password').AsString := editPasswordClubLog.Text;
        Params.ParamByName('AutoClubLog').AsBoolean := cbUploadClubLog.Checked;
        Params.ParamByName('QRZCOM_User').AsString := editLoginQRZcom.Text;
        Params.ParamByName('QRZCOM_Password').AsString := editAPIkeyQRZcom.Text;
        Params.ParamByName('AutoQRZCom').AsBoolean := cbUploadQRZcom.Checked;
        Params.ParamByName('QSOSU_Token').AsString := editAPItokenQSOsu.Text;
        Params.ParamByName('AutoQSOsu').AsBoolean := cbUploadQSOsu.Checked;
        Params.ParamByName('HAMLogOnline_API').AsString := editAPIkeyHAMLogOnline.Text;
        Params.ParamByName('AutoHAMLogOnline').AsBoolean := cbUploadHAMLogOnline.Checked;
        Params.ParamByName('id').AsInteger := id;
        ExecSQL;
      end;
      InitDB.DefTransaction.Commit;
      if LBDefaultCall.IsVisible then
      begin
        DBRecord.DefaultLogTable := EditDescription.Text;
        INIFile.WriteString('SetLog', 'DefaultCallLogBook', EditDescription.Text);
      end;
      if (not InitDB.GetLogBookTable(DBRecord.DefaultLogTable)) and
        (DBRecord.InitDB = 'YES') then
        ShowMessage('LogBook Table ERROR')
      else
      if (not InitDB.SelectLogbookTable(LBRecord.LogTable)) and
        (DBRecord.InitDB = 'YES') then
        ShowMessage(rDBError);
      MainFunc.LoadBMSL(MiniForm.CBMode, MiniForm.CBSubMode, MiniForm.CBBand,
        MiniForm.CBCurrentLog);
      MiniForm.CBCurrentLogChange(LogConfigForm);
      LogConfigForm.Close;
    end;

  finally
    FreeAndNil(Query);
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
  Query: TSQLQuery;
begin
  try
    Query := TSQLQuery.Create(nil);

    if InitDB.SQLiteConnection.Connected then
    begin
      try
        if DBRecord.InitDB = 'YES' then
        begin
          Query.DataBase := InitDB.SQLiteConnection;
          SelectLogBook(DBRecord.CurrentLogTable);
          LBCallsigns.Clear;
          Query.SQL.Text := 'SELECT * FROM LogBookInfo';
          Query.Open;
          Query.First;
          for i := 0 to Query.RecordCount - 1 do
          begin
            LBCallsigns.Items.Add(Query.FieldByName('Description').AsString);
            Query.Next;
          end;
          for i := 0 to LBCallsigns.Count - 1 do
            if Pos(MiniForm.CBCurrentLog.Text, LBCallsigns.Items[i]) > 0 then
            begin
              LBCallsigns.Selected[i] := True;
              //exit;
              Break;
            end;

          if LBCallsigns.Items[LBCallsigns.ItemIndex] = DBRecord.DefaultLogTable then
            LBDefaultCall.Visible := True
          else
            LBDefaultCall.Visible := False;
        end;
      except
        on E: Exception do begin
          ShowMessage('Error: ' + E.ClassName + ':' + E.Message );
          WriteLn(ExceptFile, 'TLogConfigForm.FormShow: Error: ' + E.ClassName + ':' + E.Message);
        end;
      end;
    end;

  finally
    FreeAndNil(Query);
  end;
end;

procedure TLogConfigForm.LBCallsignsClick(Sender: TObject);
begin
  if LBCallsigns.ItemIndex <> -1 then
  begin
    if InitDB.SQLiteConnection.Connected then
    begin
      SelectLogBook(LBCallsigns.Items[LBCallsigns.ItemIndex]);
      if LBCallsigns.Items[LBCallsigns.ItemIndex] = DBRecord.DefaultLogTable then
        LBDefaultCall.Visible := True
      else
        LBDefaultCall.Visible := False;
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
  dropTableName: string;
  i: integer;
  Query: TSQLQuery;
begin
  try
    Query := TSQLQuery.Create(nil);

    if LBCallsigns.ItemIndex <> -1 then
    begin
      if InitDB.SQLiteConnection.Connected then
      begin
        Query.DataBase := InitDB.SQLiteConnection;
        if Application.MessageBox(PChar(rDeleteLog), PChar(rWarning),
          MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
        begin
          if (DBRecord.DefaultLogTable = LBCallsigns.Items[LBCallsigns.ItemIndex]) or
            (DBRecord.CurrentLogTable = LBCallsigns.Items[LBCallsigns.ItemIndex]) then
          begin
            ShowMessage(rCannotDelDef);
            Exit;
          end;

          Query.SQL.Text := 'SELECT * FROM LogBookInfo WHERE Description = "' +
            LBCallsigns.Items[LBCallsigns.ItemIndex] + '"';
          Query.Open;
          dropTableName := Query.FieldByName('LogTable').AsString;
          Query.Close;
          Query.SQL.Text := 'DROP TABLE "' + dropTableName + '"';
          Query.ExecSQL;
          Query.SQL.Text := 'DELETE FROM LogBookInfo WHERE Description = "' +
            LBCallsigns.Items[LBCallsigns.ItemIndex] + '"';
          Query.ExecSQL;
          Query.SQLTransaction.Commit;
          LBCallsigns.Clear;
          Query.SQL.Text := 'SELECT * FROM LogBookInfo';
          Query.Open;
          Query.First;
          for i := 0 to Query.RecordCount - 1 do
          begin
            LBCallsigns.Items.Add(Query.FieldByName('Description').AsString);
            Query.Next;
          end;
          if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
            ShowMessage(rDBError);
          for i := 0 to LBCallsigns.Count - 1 do
            if Pos(DBRecord.CurrentLogTable, LBCallsigns.Items[i]) > 0 then
            begin
              LBCallsigns.Selected[i] := True;
              MainFunc.LoadJournalItem(MiniForm.CBCurrentLog);
              Exit;
            end;
        end
        else
          Exit;
      end;
    end;
  finally
    FreeAndNil(Query);
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
      DBRecord.DefaultLogTable := LBCallsigns.Items[LBCallsigns.ItemIndex];
      ShowMessage(rDefaultLogSel + ' ' + LBCallsigns.Items[LBCallsigns.ItemIndex]);
      if LBCallsigns.Items[LBCallsigns.ItemIndex] = DBRecord.DefaultLogTable then
        LBDefaultCall.Visible := True
      else
        LBDefaultCall.Visible := False;
    end;
  end;
end;

end.
