(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit CreateJournalForm_U;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, Forms, Controls, Graphics, Dialogs,
  StdCtrls, LCLType, prefix_record, dmmigrate_u, Classes;

type

  { TCreateJournalForm }

  TCreateJournalForm = class(TForm)
    BtClose: TButton;
    BtCreate: TButton;
    EditDescription: TEdit;
    EditQSLInfo: TEdit;
    EditCallName: TEdit;
    EditQTH: TEdit;
    EditName: TEdit;
    EditITU: TEdit;
    EditCQ: TEdit;
    EditGrid: TEdit;
    EditLat: TEdit;
    EditLon: TEdit;
    GBInformation: TGroupBox;
    GBLocation: TGroupBox;
    GBQSLInfo: TGroupBox;
    LBDescription: TLabel;
    LBLon: TLabel;
    LBCallName: TLabel;
    LBQTH: TLabel;
    LBName: TLabel;
    LBITU: TLabel;
    LBCQ: TLabel;
    LBGrid: TLabel;
    LBLat: TLabel;
    procedure BtCloseClick(Sender: TObject);
    procedure BtCreateClick(Sender: TObject);
    procedure EditCallNameChange(Sender: TObject);
    procedure EditDescriptionChange(Sender: TObject);
    procedure EditGridChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  CreateJournalForm: TCreateJournalForm;

implementation

uses miniform_u, dmFunc_U, ResourceStr, SetupSQLquery,
  InitDB_dm, MainFuncDM, databasesettingsform_u;

  {$R *.lfm}

procedure TCreateJournalForm.EditGridChange(Sender: TObject);
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

procedure TCreateJournalForm.BtCreateClick(Sender: TObject);
var
  LOG_PREFIX: string;
  newLogBookname: string;
  CreateTableQuery: TSQLQuery;
begin
  if (EditDescription.Text = '') or (EditCallName.Text = '') or
    (EditQTH.Text = '') or (EditName.Text = '') or (EditITU.Text = '') or
    (EditCQ.Text = '') or (EditGrid.Text = '') then
    ShowMessage(rAllfieldsmustbefilled)
  else
  begin
    if InitDB.SQLiteConnection.Connected then
    begin
      try
        CreateTableQuery := TSQLQuery.Create(nil);
        CreateTableQuery.DataBase := InitDB.SQLiteConnection;
        CreateTableQuery.Transaction := InitDB.DefTransaction;
        LOG_PREFIX := FormatDateTime('DDMMYYYY_HHNNSS', Now);
        CreateTableQuery.Close;

        CreateTableQuery.SQL.Text := Insert_Table_LogBookInfo;
        CreateTableQuery.ParamByName('LogTable').AsString := 'Log_TABLE_' + LOG_PREFIX;
        CreateTableQuery.ParamByName('Description').AsString := EditDescription.Text;
        CreateTableQuery.ParamByName('CallName').AsString := EditCallName.Text;
        CreateTableQuery.ParamByName('Name').AsString := EditName.Text;
        CreateTableQuery.ParamByName('QTH').AsString := EditQTH.Text;
        CreateTableQuery.ParamByName('ITU').AsString := EditITU.Text;
        CreateTableQuery.ParamByName('CQ').AsString := EditCQ.Text;
        CreateTableQuery.ParamByName('Loc').AsString := EditGrid.Text;
        CreateTableQuery.ParamByName('Lat').AsString := EditLat.Text;
        CreateTableQuery.ParamByName('Lon').AsString := EditLon.Text;
        CreateTableQuery.ParamByName('QSLInfo').AsString := EditQSLInfo.Text;
        CreateTableQuery.ParamByName('Table_version').AsString := Current_Table;
        CreateTableQuery.ExecSQL;
        InitDB.DefTransaction.Commit;


        InitDB.SQLiteConnection.ExecuteDirect(
          dmSQL.Table_Log_Table(LOG_PREFIX));
        InitDB.SQLiteConnection.ExecuteDirect(dmSQL.CreateIndex(LOG_PREFIX));

        InitDB.DefTransaction.Commit;
      finally
        newLogBookName := EditDescription.Text;
        EditDescription.Clear;
        EditCallName.Clear;
        EditQTH.Clear;
        EditName.Clear;
        EditITU.Clear;
        EditCQ.Clear;
        EditGrid.Clear;
        EditLat.Clear;
        EditLon.Clear;
        if Application.MessageBox(PChar(rSetAsDefaultJournal),
          PChar(rWarning), MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
        begin
          INIFile.WriteString('SetLog', 'DefaultCallLogBook', newLogBookName);
          DBRecord.DefaultLogTable := newLogBookName;
        end;

        if InitDB.GetLogBookTable(DBRecord.CurrentLogTable) then
          if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
            ShowMessage(rDBError);

        MainFunc.LoadBMSL(MiniForm.CBMode, MiniForm.CBSubMode,
          MiniForm.CBBand, MiniForm.CBCurrentLog);

        if Application.MessageBox(PChar(rSwitchToANewLog), PChar(rWarning),
          MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
        begin
          MiniForm.CBCurrentLog.SetFocus;
          MiniForm.CBCurrentLog.DroppedDown := True;
        end;
        FreeAndNil(CreateTableQuery);
      end;
    end
    else
    if Application.MessageBox(PChar(rDBNotinit), PChar(rWarning),
      MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      DataBaseSettingsForm.Show;
  end;
end;

procedure TCreateJournalForm.EditCallNameChange(Sender: TObject);
var
  PFXR: TPFXR;
  Lat: string = '';
  Lon: string = '';
begin
  if Length(EditCallName.Text) > 2 then
  begin
    PFXR := MainFunc.SearchPrefix(EditCallName.Text, '');
    EditITU.Text := PFXR.ITUZone;
    EditCQ.Text := PFXR.CQZone;
    dmFunc.GetLatLon(PFXR.Latitude, PFXR.Longitude, Lat, Lon);
    EditLat.Text := Lat;
    EditLon.Text := Lon;
  end;
end;

procedure TCreateJournalForm.EditDescriptionChange(Sender: TObject);
begin
  if MiniForm.CBCurrentLog.Items.IndexOf(EditDescription.Text) >= 0 then
  begin
    EditDescription.Color := clRed;
    BtCreate.Enabled := False;
  end
  else
  begin
    EditDescription.Color := clDefault;
    BtCreate.Enabled := True;
  end;
end;

procedure TCreateJournalForm.BtCloseClick(Sender: TObject);
begin
  CreateJournalForm.Close;
end;

end.
