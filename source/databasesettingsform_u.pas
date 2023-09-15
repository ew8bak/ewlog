(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit databasesettingsform_u;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, SQLite3Conn, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, LCLType, prefix_record, ResourceStr;

type

  { TDataBaseSettingsForm }

  TDataBaseSettingsForm = class(TForm)
    btOk: TButton;
    btCancel: TButton;
    cbUseExDatabase: TCheckBox;
    editLongitude: TEdit;
    editGrid: TEdit;
    editLatitude: TEdit;
    editName: TEdit;
    editITU: TEdit;
    editQTH: TEdit;
    editQSLinfo: TEdit;
    editDescription: TEdit;
    editCallsign: TEdit;
    editCQ: TEdit;
    EditSQLPath: TEdit;
    gbDataBase: TGroupBox;
    gbMainSettings: TGroupBox;
    lbCallsign: TLabel;
    lbDiscription: TLabel;
    lbCQ: TLabel;
    lbLongitude: TLabel;
    lbGrid: TLabel;
    lbLatitude: TLabel;
    lbName: TLabel;
    lbITU: TLabel;
    lbQTH: TLabel;
    lbQSLinfo: TLabel;
    lbSQLPath: TLabel;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    sbOpenDialog: TSpeedButton;
    SQLite_Connector: TSQLite3Connection;
    SQL_Transaction: TSQLTransaction;
    procedure btCancelClick(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure editCallsignChange(Sender: TObject);
    procedure editGridChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbOpenDialogClick(Sender: TObject);
  private
    SQLitePATH: string;
    function CheckEmptyDB: boolean;
    function CheckEdit: boolean;
  public

  end;

var
  DataBaseSettingsForm: TDataBaseSettingsForm;

implementation

uses dmFunc_U, SetupSQLquery, InitDB_dm, MainFuncDM, dmmigrate_u, miniform_u;

  {$R *.lfm}

{ TDataBaseSettingsForm }

procedure TDataBaseSettingsForm.editCallsignChange(Sender: TObject);
var
  PFXR: TPFXR;
  Lat: string = '';
  Lon: string = '';
begin
  if Length(editCallsign.Text) > 0 then
  begin
    PFXR := MainFunc.SearchPrefix(editCallsign.Text, '');
    editITU.Text := PFXR.ITUZone;
    editCQ.Text := PFXR.CQZone;
    dmFunc.GetLatLon(PFXR.Latitude, PFXR.Longitude, Lat, Lon);
    editLatitude.Text := Lat;
    editLongitude.Text := Lon;
  end;
end;

function TDataBaseSettingsForm.CheckEdit: boolean;
begin
  Result := False;
  if Length(editDescription.Text) < 1 then
  begin
    ShowMessage(rDescription + ' ' + rFieldMissing);
    Exit;
  end;
  if Length(editCallsign.Text) < 1 then
  begin
    ShowMessage(rCallSign + ' ' + rFieldMissing);
    Exit;
  end;
  if Length(editName.Text) < 1 then
  begin
    ShowMessage(rName + ' ' + rFieldMissing);
    Exit;
  end;
  if Length(editQTH.Text) < 1 then
  begin
    ShowMessage('QTH ' + rFieldMissing);
    Exit;
  end;
  if Length(editGrid.Text) < 1 then
  begin
    ShowMessage(rGrid + ' ' + rFieldMissing);
    Exit;
  end;
  if Length(editLatitude.Text) < 1 then
  begin
    ShowMessage(rLatitude + ' ' + rFieldMissing);
    Exit;
  end;
  if Length(editLongitude.Text) < 1 then
  begin
    ShowMessage(rLongitude + ' ' + rFieldMissing);
    Exit;
  end;
  if Length(editQSLinfo.Text) < 1 then
  begin
    ShowMessage(rQslInfo + ' ' + rFieldMissing);
    Exit;
  end;
  if Length(editCQ.Text) < 1 then
  begin
    ShowMessage('CQ ' + rFieldMissing);
    Exit;
  end;
  if Length(editITU.Text) < 1 then
  begin
    ShowMessage('ITU ' + rFieldMissing);
    Exit;
  end;

  Result := True;

end;

procedure TDataBaseSettingsForm.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TDataBaseSettingsForm.btOkClick(Sender: TObject);
var
  Query: TSQLQuery;
  logTableName: string;
begin
  if not CheckEdit then Exit;
  try
    Query := TSQLQuery.Create(nil);
    if cbUseExDatabase.Checked then
      Exit
    else
    begin
      SQLite_Connector.DatabaseName := EditSQLPath.Text;
      SQLite_Connector.Transaction := SQL_Transaction;
      Query.DataBase := SQLite_Connector;
      SQLite_Connector.Connected := True;
      SQL_Transaction.Active := True;
      SQLite_Connector.ExecuteDirect(Table_LogBookInfo);
      Query.Transaction := SQL_Transaction;
      logTableName := FormatDateTime('DDMMYYYY_HHNNSS', Now);
      Query.Close;
      Query.SQL.Text := Insert_Table_LogBookInfo;
      Query.ParamByName('LogTable').AsString := 'Log_TABLE_' + logTableName;
      Query.ParamByName('CallName').AsString := editCallsign.Text;
      Query.ParamByName('Name').AsString := editName.Text;
      Query.ParamByName('QTH').AsString := editQTH.Text;
      Query.ParamByName('ITU').AsString := editITU.Text;
      Query.ParamByName('CQ').AsString := editCQ.Text;
      Query.ParamByName('Loc').AsString := editGrid.Text;
      Query.ParamByName('Lat').AsString := editLatitude.Text;
      Query.ParamByName('Lon').AsString := editLongitude.Text;
      Query.ParamByName('Description').AsString := editDescription.Text;
      Query.ParamByName('QSLInfo').AsString := editQSLinfo.Text;
      Query.ParamByName('Table_version').AsString := Current_Table;
      Query.ExecSQL;
      SQL_Transaction.Commit;
      Query.Close;
      SQLite_Connector.ExecuteDirect(dmSQL.Table_Log_Table(logTableName));
      SQLite_Connector.ExecuteDirect(dmSQL.CreateIndex(logTableName));
    end;

  finally
    SQL_Transaction.Commit;
    INIFile.WriteString('SetLog', 'LogBookInit', 'YES');
    INIFile.WriteString('DataBases', 'FileSQLite', EditSQLPath.Text);
    INIFile.WriteString('SetLog', 'DefaultCallLogBook', editDescription.Text);
    SQLite_Connector.Connected := False;
    FreeAndNil(Query);
    InitDB.AllFree;
    InitDB.DataModuleCreate(DataBaseSettingsForm);
    MiniForm.LoadComboBoxItem;
    Close;
  end;
end;

procedure TDataBaseSettingsForm.editGridChange(Sender: TObject);
var
  lat, lon: currency;
begin
  if dmFunc.IsLocOK(editGrid.Text) then
  begin
    dmFunc.CoordinateFromLocator(editGrid.Text, lat, lon);
    editLatitude.Text := StringReplace(CurrToStr(lat), ',', '.', [rfReplaceAll]);
    editLongitude.Text := StringReplace(CurrToStr(lon), ',', '.', [rfReplaceAll]);
  end
  else
  begin
    editLatitude.Clear;
    editLongitude.Clear;
  end;
end;

procedure TDataBaseSettingsForm.FormShow(Sender: TObject);
begin
  if Length(DBRecord.SQLitePATH) > 9 then
    SQLitePATH := DBRecord.SQLitePATH
  else
    SQLitePATH := FilePATH + 'logbook.db';
  EditSQLPath.Text := SQLitePATH;

  if CheckEmptyDB then
    cbUseExDatabase.Checked := True;
end;

procedure TDataBaseSettingsForm.sbOpenDialogClick(Sender: TObject);
begin
  editDescription.Clear;
  editCallsign.Clear;
  editName.Clear;
  editQTH.Clear;
  editGrid.Clear;
  editCQ.Clear;
  editITU.Clear;
  if not cbUseExDatabase.Checked then
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
  if OpenDialog1.Execute then
  begin
    EditSQLPath.Text := OpenDialog1.FileName;
    SQLitePATH := EditSQLPath.Text;
    CheckEmptyDB;
  end;
end;

function TDataBaseSettingsForm.CheckEmptyDB: boolean;
var
  Query: TSQLQuery;
begin
  Result := False;
  try
    Query := TSQLQuery.Create(nil);
    editDescription.Clear;
    editCallsign.Clear;
    editName.Clear;
    editQTH.Clear;
    editGrid.Clear;
    editCQ.Clear;
    editITU.Clear;

    if not FileExists(SQLitePATH) then
      Exit
    else
    begin
      try
        SQLite_Connector.DatabaseName := SQLitePATH;
        SQLite_Connector.Transaction := SQL_Transaction;
        SQLite_Connector.Connected := True;
        Query.DataBase := SQLite_Connector;
        Query.SQL.Text := 'SELECT * FROM LogBookInfo LIMIT 1';
        Query.Open;
        if Query.FieldByName('CallName').AsString <> '' then
        begin
          editDescription.Text := Query.FieldByName('Description').AsString;
          editCallsign.Text := Query.FieldByName('CallName').AsString;
          editQTH.Text := Query.FieldByName('QTH').AsString;
          editName.Text := Query.FieldByName('Name').AsString;
          editGrid.Text := Query.FieldByName('Loc').AsString;
          editITU.Text := Query.FieldByName('ITU').AsString;
          editCQ.Text := Query.FieldByName('CQ').AsString;
          editQSLinfo.Text := Query.FieldByName('QSLInfo').AsString;
        end;
        Query.Close;
        Result := True;

      except
        on E: Exception do
        begin
          ShowMessage(rItsNoEWLogDatabase);
          WriteLn(ExceptFile, 'TSetupForm.CheckEmptyDB:' + E.ClassName +
            ':' + E.Message);
          SQLite_Connector.Connected := False;
        end;
      end;
    end;

  finally
    SQLite_Connector.Connected := False;
    FreeAndNil(Query);
  end;
end;

end.
