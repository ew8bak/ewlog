(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit GridsForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Dialogs, DBGrids, ExtCtrls,
  Grids, Menus, selectQSO_record, foundQSO_record, prefix_record,
  ResourceStr, qso_record, serverDM_u,
  LCLType;

type

  { TGridsForm }

  TGridsForm = class(TForm)
    AddUniqCallItem: TMenuItem;
    CopyToLogItem0: TMenuItem;
    DelRecItem: TMenuItem;
    EditItem: TMenuItem;
    ExportADIFItem: TMenuItem;
    FilterCancelItem: TMenuItem;
    FilterDNSentItem: TMenuItem;
    FilterItem: TMenuItem;
    FilterNSentQSLItem: TMenuItem;
    FilterQSLPItem: TMenuItem;
    FilterRecQSLItem: TMenuItem;
    FilterSentQSLItem: TMenuItem;
    FindQSODS: TDataSource;
    LOGBookDS: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    GridMenu: TPopupMenu;
    MarkQSOItem: TMenuItem;
    FilterMarkedQSO: TMenuItem;
    ExportHRDItem: TMenuItem;
    ExportQSLccItem: TMenuItem;
    ExportClubLogItem: TMenuItem;
    ExportHamQTHItem: TMenuItem;
    ExportCloudLogItem: TMenuItem;
    MenuItem1: TMenuItem;
    ExportHAMLogOnlineItem: TMenuItem;
    Separator1: TMenuItem;
    miExportToService: TMenuItem;
    MISendOnLAN: TMenuItem;
    MISendOnLANANY: TMenuItem;
    N1: TMenuItem;
    PrefixItem: TMenuItem;
    QSLnsItem: TMenuItem;
    FinqQSLManItem: TMenuItem;
    PrintQSOItem: TMenuItem;
    PrintQSOManItem: TMenuItem;
    PrintQSOwMarkItem: TMenuItem;
    PrintQSOnoMarkItem: TMenuItem;
    QSLwrvEItem: TMenuItem;
    QSLwrvGItem: TMenuItem;
    QSLwrvItem: TMenuItem;
    QSLwrvBItem: TMenuItem;
    QSLwrvDItem: TMenuItem;
    QSLwrvMItem: TMenuItem;
    QSLwsvBItem: TMenuItem;
    QSLwsvDItem: TMenuItem;
    QSLwsvEItem: TMenuItem;
    QSLwsvGItem: TMenuItem;
    QSLwsvMItem: TMenuItem;
    Sep1Item: TMenuItem;
    QSLwsvItem: TMenuItem;
    QSLReceivedItem: TMenuItem;
    MenuItem4: TMenuItem;
    QSLQueuedItem: TMenuItem;
    QSLPrintedItem: TMenuItem;
    QSLSentItem: TMenuItem;
    QSLInfoItem: TMenuItem;
    QSLwnsItem: TMenuItem;
    SaveExcelItem: TMenuItem;
    SelectAllItem: TMenuItem;
    SendClusterItem: TMenuItem;
    Sep2Item: TMenuItem;
    Sep3Item: TMenuItem;
    Sep4Item: TMenuItem;
    Sep5Item: TMenuItem;
    Sep6Item: TMenuItem;
    Sep7Item: TMenuItem;
    Sep8Item: TMenuItem;
    Sep9Item: TMenuItem;
    Splitter1: TSplitter;
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1ColumnMoved(Sender: TObject; FromIndex, ToIndex: integer);
    procedure DBGrid1ColumnSized(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure DBGrid2DblClick(Sender: TObject);
    procedure DBGrid2DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure DelRecItemClick(Sender: TObject);
    procedure EditItemClick(Sender: TObject);
    procedure ExportADIFItemClick(Sender: TObject);
    procedure ExportCloudLogItemClick(Sender: TObject);
    procedure ExportClubLogItemClick(Sender: TObject);
    procedure ExportHAMLogOnlineItemClick(Sender: TObject);
    procedure ExportHamQTHItemClick(Sender: TObject);
    procedure ExportHRDItemClick(Sender: TObject);
    procedure ExportQSLccItemClick(Sender: TObject);
    procedure FilterCancelItemClick(Sender: TObject);
    procedure FilterDNSentItemClick(Sender: TObject);
    procedure FilterMarkedQSOClick(Sender: TObject);
    procedure FilterNSentQSLItemClick(Sender: TObject);
    procedure FilterQSLPItemClick(Sender: TObject);
    procedure FilterRecQSLItemClick(Sender: TObject);
    procedure FilterSentQSLItemClick(Sender: TObject);
    procedure FindQSODSDataChange(Sender: TObject; Field: TField);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridMenuPopup(Sender: TObject);
    procedure CopyToLogItemClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure SendToLogBroadcastItemClick(Sender: TObject);
    procedure LOGBookDSDataChange(Sender: TObject; Field: TField);
    procedure MarkQSOItemClick(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MISendOnLANANYClick(Sender: TObject);
    procedure PrefixItemClick(Sender: TObject);
    procedure PrintQSOManItemClick(Sender: TObject);
    procedure PrintQSOnoMarkItemClick(Sender: TObject);
    procedure PrintQSOwMarkItemClick(Sender: TObject);
    procedure QSLInfoItemClick(Sender: TObject);
    procedure QSLnsItemClick(Sender: TObject);
    procedure QSLPrintedItemClick(Sender: TObject);
    procedure QSLQueuedItemClick(Sender: TObject);
    procedure QSLReceivedItemClick(Sender: TObject);
    procedure QSLSentItemClick(Sender: TObject);
    procedure QSLwnsItemClick(Sender: TObject);
    procedure QSLwrvBItemClick(Sender: TObject);
    procedure QSLwrvDItemClick(Sender: TObject);
    procedure QSLwrvEItemClick(Sender: TObject);
    procedure QSLwrvGItemClick(Sender: TObject);
    procedure QSLwrvMItemClick(Sender: TObject);
    procedure QSLwsvBItemClick(Sender: TObject);
    procedure QSLwsvDItemClick(Sender: TObject);
    procedure QSLwsvEItemClick(Sender: TObject);
    procedure QSLwsvGItemClick(Sender: TObject);
    procedure QSLwsvMItemClick(Sender: TObject);
    procedure SelectAllItemClick(Sender: TObject);
    procedure SendClusterItemClick(Sender: TObject);
  private

  public
    ExportAdifSelect: boolean;
    ExportAdifArray: array of integer;
    procedure SavePosition;
  end;

var
  GridsForm: TGridsForm;

implementation

uses MainFuncDM, dmFunc_U, InitDB_dm, Earth_Form_U, miniform_u,
  editqso_u, ExportAdifForm_u, ManagerBasePrefixForm_U, print_sticker_u,
  sendtelnetspot_form_U;

{$R *.lfm}

{ TGridsForm }

procedure TGridsForm.SavePosition;
begin
  MainFunc.SaveWindowPosition(GridsForm);
  MainFunc.SaveGrids(DBGrid1);
end;

procedure TGridsForm.DBGrid1ColumnMoved(Sender: TObject; FromIndex, ToIndex: integer);
begin
  MainFunc.SaveGrids(DBGrid1);
  MainFunc.SetGrid(DBGrid1);
  MainFunc.SetGrid(DBGrid2);
end;

procedure TGridsForm.DBGrid1CellClick(Column: TColumn);
var
  SelQSOR: TSelQSOR;
  FoundQSOR: TFoundQSOR;
  PFXR: TPFXR;
  Lat, Lon: string;
begin
  if LOGBookDS.DataSet.Fields[0].AsString <> '' then
  begin
    GridRecordIndex := DBGrid1.DataSource.DataSet.RecNo;
    SelQSOR := MainFunc.SelectQSO(LOGBookDS);
    FoundQSOR := MainFunc.FindQSO(DBGrid1.DataSource.DataSet.FieldByName(
      'Call').AsString);
    PFXR := MainFunc.SearchPrefix(
      DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString,
      DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString);
    MiniForm.LBCount.Caption := IntToStr(FoundQSOR.CountQSO);
    MiniForm.LBDateQSO.Caption := SelQSOR.QSODate;
    MiniForm.LBTimeQSO.Caption := SelQSOR.QSOTime;
    MiniForm.LBBandQSO.Caption := SelQSOR.QSOBand;
    MiniForm.LBModeQSO.Caption := SelQSOR.QSOMode;
    MiniForm.LBNameQSO.Caption := SelQSOR.OMName;
    MiniForm.LBAzimuthD.Caption := PFXR.Azimuth;
    MiniForm.LBDistanceD.Caption := PFXR.Distance;
    MiniForm.LBLatitudeD.Caption := PFXR.Latitude;
    MiniForm.LBLongitudeD.Caption := PFXR.Longitude;
    MiniForm.LBTerritoryD.Caption := PFXR.Country;
    MiniForm.LBCont.Caption := PFXR.Continent;
    MiniForm.LBDXCCD.Caption := PFXR.ARRLPrefix;
    MiniForm.LBPrefixD.Caption := PFXR.Prefix;
    MiniForm.LBCQD.Caption := PFXR.CQZone;
    MiniForm.LBITUD.Caption := PFXR.ITUZone;
    TimeDIF := PFXR.TimeDiff;
    dmFunc.GetLatLon(PFXR.Latitude, PFXR.Longitude, Lat, Lon);
    Earth.PaintLine(Lat, Lon, LBRecord.OpLat, LBRecord.OpLon);
    Earth.Invalidate;
    UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
    MiniForm.TextSB('QSO № ' + IntToStr(SelQSOR.NumSelectQSO) +
      rQSOTotal + IntToStr(CountAllRecords), 1);
  end;

end;

procedure TGridsForm.DBGrid1ColumnSized(Sender: TObject);
begin
  MainFunc.SaveGrids(DBGrid1);
  MainFunc.SaveGrids(DBGrid1);
  MainFunc.SetGrid(DBGrid1);
  MainFunc.SetGrid(DBGrid2);
end;

procedure TGridsForm.DBGrid1DblClick(Sender: TObject);
begin
  if InitRecord.SelectLogbookTable and (LOGBookDS.DataSet.Fields[0].AsString <> '') then
  begin
    GridRecordIndex := DBGrid1.DataSource.DataSet.RecNo;
    UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
    EditQSO_Form.ShowModal;
  end;
end;

procedure TGridsForm.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: integer; Column: TColumn; State: TGridDrawState);
begin
  MainFunc.DrawColumnGrid(LOGBookDS.DataSet, Rect, DataCol, Column, State, DBGrid1);
end;

procedure TGridsForm.DBGrid2DblClick(Sender: TObject);
begin
  if InitRecord.SelectLogbookTable and (LOGBookDS.DataSet.Fields[0].AsString <> '') then
  begin
    //GridRecordIndex := DBGrid2.DataSource.DataSet.RecNo;
    UnUsIndex := DBGrid2.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
    EditQSO_Form.Show;
  end;
end;

procedure TGridsForm.DBGrid2DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: integer; Column: TColumn; State: TGridDrawState);
begin
  MainFunc.DrawColumnGrid(FindQSODS.DataSet, Rect, DataCol, Column, State, DBGrid2);
end;

procedure TGridsForm.DelRecItemClick(Sender: TObject);
begin
  MainFunc.DeleteQSO(DBGrid1);
end;

procedure TGridsForm.EditItemClick(Sender: TObject);
begin
  if InitRecord.SelectLogbookTable then
  begin
    if (DBRecord.InitDB = 'YES') and (LOGBookDS.DataSet.Fields[0].AsString <> '') then
    begin
      GridRecordIndex := DBGrid1.DataSource.DataSet.RecNo;
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      EditQSO_Form.ShowModal;
    end;
  end;
end;

procedure TGridsForm.ExportADIFItemClick(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    exportAdifForm.Show;
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      SetLength(ExportAdifArray, DBGrid1.SelectedRows.Count);
      ExportAdifArray[i] := DBGrid1.DataSource.DataSet.FieldByName(
        'UnUsedIndex').AsInteger;
    end;
    ExportAdifSelect := True;
    exportAdifForm.ExportADIArray;
  end;
end;

procedure TGridsForm.ExportCloudLogItemClick(Sender: TObject);
var
  SelQSO: TQSO;
begin
  if InitRecord.SelectLogbookTable and (DBGrid1.SelectedIndex <> 0) then
  begin
    SelQSO := MainFunc.SelectEditQSO(UnUsIndex);
    SelQSO.Auto := False;
    MainFunc.SendQSOto('cloudlog', SelQSO);
  end;
end;

procedure TGridsForm.ExportClubLogItemClick(Sender: TObject);
var
  SelQSO: TQSO;
begin
  if InitRecord.SelectLogbookTable and (DBGrid1.SelectedIndex <> 0) then
  begin
    SelQSO := MainFunc.SelectEditQSO(UnUsIndex);
    SelQSO.Auto := False;
    MainFunc.SendQSOto('clublog', SelQSO);
  end;
end;

procedure TGridsForm.ExportHAMLogOnlineItemClick(Sender: TObject);
var
  SelQSO: TQSO;
begin
  if InitRecord.SelectLogbookTable and (DBGrid1.SelectedIndex <> 0) then
  begin
    SelQSO := MainFunc.SelectEditQSO(UnUsIndex);
    SelQSO.Auto := False;
    MainFunc.SendQSOto('hamlogonline', SelQSO);
  end;

end;

procedure TGridsForm.ExportHamQTHItemClick(Sender: TObject);
var
  SelQSO: TQSO;
begin
  if InitRecord.SelectLogbookTable and (DBGrid1.SelectedIndex <> 0) then
  begin
    SelQSO := MainFunc.SelectEditQSO(UnUsIndex);
    SelQSO.Auto := False;
    MainFunc.SendQSOto('hamqth', SelQSO);
  end;
end;

procedure TGridsForm.ExportHRDItemClick(Sender: TObject);
var
  SelQSO: TQSO;
begin
  if InitRecord.SelectLogbookTable and (DBGrid1.SelectedIndex <> 0) then
  begin
    SelQSO := MainFunc.SelectEditQSO(UnUsIndex);
    SelQSO.Auto := False;
    MainFunc.SendQSOto('hrdlog', SelQSO);
  end;
end;

procedure TGridsForm.FilterCancelItemClick(Sender: TObject);
begin
  InitDB.SelectLogbookTable(LBRecord.LogTable);
end;

procedure TGridsForm.FilterDNSentItemClick(Sender: TObject);
begin
  MainFunc.FilterQSO('QSLSentAdv', 'N');
end;

procedure TGridsForm.FilterMarkedQSOClick(Sender: TObject);
begin
  MainFunc.FilterQSO('Marker', '1');
end;

procedure TGridsForm.FilterNSentQSLItemClick(Sender: TObject);
begin
  MainFunc.FilterQSO('QSLSent', '0');
end;

procedure TGridsForm.FilterQSLPItemClick(Sender: TObject);
begin
  MainFunc.FilterQSO('QSLSentAdv', 'P');
end;

procedure TGridsForm.FilterRecQSLItemClick(Sender: TObject);
begin
  MainFunc.FilterQSO('QSLRec', '1');
end;

procedure TGridsForm.FilterSentQSLItemClick(Sender: TObject);
begin
  MainFunc.FilterQSO('QSLSent', '1');
end;

procedure TGridsForm.FindQSODSDataChange(Sender: TObject; Field: TField);
begin
 // MainFunc.SetGrid(DBGrid2);
end;

procedure TGridsForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  MainFunc.SaveGrids(DBGrid1);
  if Application.MessageBox(PChar(rShowNextStart), PChar(rWarning),
    MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
    INIFile.WriteBool('SetLog', 'gShow', True)
  else
    INIFile.WriteBool('SetLog', 'gShow', False);
  MiniForm.CheckFormMenu('GridsForm', False);
  IniSet.gShow := False;
  CloseAction := caHide;
end;

procedure TGridsForm.FormCreate(Sender: TObject);
begin

  ExportAdifSelect := False;
end;

procedure TGridsForm.FormShow(Sender: TObject);
begin
  MainFunc.SetGrid(DBGrid1);
  MainFunc.SetGrid(DBGrid2);
  MainFunc.LoadWindowPosition(GridsForm);

end;

procedure TGridsForm.CopyToLogItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
begin
  MenuItem := (Sender as TMenuItem);
  MainFunc.CopyToJournal(DBGrid1, MenuItem.Caption);
end;

procedure TGridsForm.MenuItem1Click(Sender: TObject);
var
  SelQSO: TQSO;
begin
  if InitRecord.SelectLogbookTable and (DBGrid1.SelectedIndex <> 0) then
  begin
    SelQSO := MainFunc.SelectEditQSO(UnUsIndex);
    SelQSO.Auto := False;
    MainFunc.SendQSOto('qsosu', SelQSO);
  end;

end;

procedure TGridsForm.ExportQSLccItemClick(Sender: TObject);
var
  SelQSO: TQSO;
begin
  if InitRecord.SelectLogbookTable and (DBGrid1.SelectedIndex <> 0) then
  begin
    SelQSO := MainFunc.SelectEditQSO(UnUsIndex);
    SelQSO.Auto := False;
    MainFunc.SendQSOto('eqslcc', SelQSO);
  end;
end;

procedure TGridsForm.SendToLogBroadcastItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
begin
  MenuItem := (Sender as TMenuItem);
  if InitRecord.SelectLogbookTable and (DBGrid1.SelectedIndex <> 0) then
  begin
    if IniSet.WorkOnLAN then
      ServerDM.SendBroadcastADI(ServerDM.CreateADIBroadcast(
        MainFunc.SelectEditQSO(UnUsIndex), MenuItem.Caption, 'TRUE'));
  end;
end;

procedure TGridsForm.LOGBookDSDataChange(Sender: TObject; Field: TField);
begin
//  MainFunc.SetGrid(DBGrid1);
//  MainFunc.SetGrid(DBGrid2);
end;

procedure TGridsForm.MarkQSOItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'Marker', '1');
end;

procedure TGridsForm.MenuItem4Click(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSLRec', '1');
end;

procedure TGridsForm.MISendOnLANANYClick(Sender: TObject);
begin
  if InitRecord.SelectLogbookTable and (DBGrid1.SelectedIndex <> 0) then
  begin
    if IniSet.WorkOnLAN then
      ServerDM.SendBroadcastADI(ServerDM.CreateADIBroadcast(
        MainFunc.SelectEditQSO(UnUsIndex), 'ANY', 'TRUE'));
  end;
end;

procedure TGridsForm.PrefixItemClick(Sender: TObject);
begin
  ManagerBasePrefixForm.Show;
end;

procedure TGridsForm.PrintQSOManItemClick(Sender: TObject);
begin
  PrintSticker_Form.Show;
end;

procedure TGridsForm.PrintQSOnoMarkItemClick(Sender: TObject);
var
  i: integer;
  PrintArray: array of integer;
  PrintOK: boolean;
  numberToPrint: string;
  NumberCopies: integer;
  ind: integer;
  // resStream: TLazarusResourceStream;
begin
{  PrintOK := False;
  PrintQuery.Close;
  numberToPrint := '';
  resStream := TLazarusResourceStream.Create('report', nil);
  try
    if DBRecord.DefaultDB = 'MySQL' then
      PrintQuery.DataBase := InitDB.MySQLConnection
    else
      PrintQuery.DataBase := InitDB.SQLiteConnection;

    if (UnUsIndex <> 0) then
    begin
      for i := 0 to DBGrid1.SelectedRows.Count - 1 do
      begin
        DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
        SetLength(PrintArray, DBGrid1.SelectedRows.Count);
        PrintArray[i] := DBGrid1.DataSource.DataSet.FieldByName(
          'UnUsedIndex').AsInteger;
      end;
      PrintOK := True;
    end;

    if PrintOK then
    begin
      for i := 0 to High(PrintArray) do
      begin
        if i > 0 then
          numberToPrint := numberToPrint + ', ';
        numberToPrint := numberToPrint + IntToStr(PrintArray[i]);
      end;
      for i := 0 to Length(PrintArray) - 1 do
      begin
        PrintQuery.SQL.Text :=
          'SELECT * FROM ' + LBRecord.LogTable + ' WHERE `UnUsedIndex` in (' +
          numberToPrint + ')' + ' ORDER BY UnUsedIndex ASC';
      end;
    end;
    PrintOK := False;
    PrintQuery.Open;
    resStream.SaveToFile(FilePATH + 'rep.lrf');
    frReport1.LoadFromFile(FilePATH + 'rep.lrf');


    if PrintPrev = True then
      frReport1.ShowReport
    else
    begin
      ind := Printer.PrinterIndex;
      if not frReport1.PrepareReport then
        Exit;

      with PrintDialog1 do
      begin
        Options := [poPageNums];
        Copies := 1;
        Collate := True;
        FromPage := 1;
        ToPage := frReport1.EMFPages.Count;
        MaxPage := frReport1.EMFPages.Count;
        if Execute then
        begin
          if (Printer.PrinterIndex <> ind) or frReport1.CanRebuild or
            frReport1.ChangePrinter(ind, Printer.PrinterIndex) then
            frReport1.PrepareReport
          else
            exit;
          if PrintDialog1.PrintRange = prPageNums then
          begin
            FromPage := PrintDialog1.FromPage;
            ToPage := PrintDialog1.ToPage;
          end;
          NumberCopies := PrintDialog1.Copies;
          frReport1.PrintPreparedReport(IntToStr(FromPage) + '-' + IntToStr(ToPage),
            NumberCopies);
        end;
      end;
    end;
  finally
    resStream.Free;
  end; }
end;

procedure TGridsForm.PrintQSOwMarkItemClick(Sender: TObject);
var
  i: integer;
  PrintArray: array of integer;
  PrintOK: boolean;
  numberToPrint: string;
  NumberCopies: integer;
  ind: integer;
  // resStream: TLazarusResourceStream;
begin
 { PrintOK := False;
  PrintQuery.Close;
  numberToPrint := '';
  resStream := TLazarusResourceStream.Create('report', nil);
  try
    if DBRecord.DefaultDB = 'MySQL' then
      PrintQuery.DataBase := InitDB.MySQLConnection
    else
      PrintQuery.DataBase := InitDB.SQLiteConnection;

    if (UnUsIndex <> 0) then
    begin
      for i := 0 to DBGrid1.SelectedRows.Count - 1 do
      begin
        DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
        SetLength(PrintArray, DBGrid1.SelectedRows.Count);
        PrintArray[i] := DBGrid1.DataSource.DataSet.FieldByName(
          'UnUsedIndex').AsInteger;
      end;
      PrintOK := True;
    end;

    if (UnUsIndex <> 0) then
    begin
      for i := 0 to DBGrid1.SelectedRows.Count - 1 do
      begin
        DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
        UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
     {   with EditQSO_Form.UPDATE_Query do
        begin
          Close;
          SQL.Clear;
          SQL.Add('UPDATE ' + LBRecord.LogTable +
            ' SET `QSLSentAdv`=:QSLSentAdv WHERE `UnUsedIndex`=:UnUsedIndex');
          Params.ParamByName('QSLSentAdv').AsString := 'P';
          Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
          ExecSQL;
        end; }
      end;
      InitDB.DefTransaction.Commit;
      if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
        ShowMessage(rDBError);
      DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
    end;

    if PrintOK then
    begin
      for i := 0 to High(PrintArray) do
      begin
        if i > 0 then
          numberToPrint := numberToPrint + ', ';
        numberToPrint := numberToPrint + IntToStr(PrintArray[i]);
      end;
      for i := 0 to Length(PrintArray) - 1 do
      begin
        PrintQuery.SQL.Text :=
          'SELECT * FROM ' + LBRecord.LogTable + ' WHERE `UnUsedIndex` in (' +
          numberToPrint + ')' + ' ORDER BY UnUsedIndex ASC';
      end;
    end;
    PrintOK := False;
    PrintQuery.Open;
    resStream.SaveToFile(FilePATH + 'rep.lrf');
    frReport1.LoadFromFile(FilePATH + 'rep.lrf');
    if PrintPrev = True then
      frReport1.ShowReport
    else
    begin
      ind := Printer.PrinterIndex;
      if not frReport1.PrepareReport then
        Exit;

      with PrintDialog1 do
      begin
        Options := [poPageNums];
        Copies := 1;
        Collate := True;
        FromPage := 1;
        ToPage := frReport1.EMFPages.Count;
        MaxPage := frReport1.EMFPages.Count;
        if Execute then
        begin
          if (Printer.PrinterIndex <> ind) or frReport1.CanRebuild or
            frReport1.ChangePrinter(ind, Printer.PrinterIndex) then
            frReport1.PrepareReport
          else
            exit;
          if PrintDialog1.PrintRange = prPageNums then
          begin
            FromPage := PrintDialog1.FromPage;
            ToPage := PrintDialog1.ToPage;
          end;
          NumberCopies := PrintDialog1.Copies;
          frReport1.PrintPreparedReport(IntToStr(FromPage) + '-' + IntToStr(ToPage),
            NumberCopies);
        end;
      end;
    end;
  finally
    resStream.Free;
  end;   }

end;

procedure TGridsForm.QSLInfoItemClick(Sender: TObject);
var
  Str: string = '';
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  if InputQuery(rPleaseQSLInfo, rEnterMesQSLInf, Str) then
    MainFunc.UpdateQSO((Caller as TDBGrid), 'QSLInfo', Str);
end;

procedure TGridsForm.QSLnsItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSLSentAdv', 'N');
end;

procedure TGridsForm.QSLPrintedItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSLSentAdv', 'P');
end;

procedure TGridsForm.QSLQueuedItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSLPrint', 'Q');
end;

procedure TGridsForm.QSLReceivedItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSLSentAdv', 'Q');
end;

procedure TGridsForm.QSLSentItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSLSentAdv', 'T');
end;

procedure TGridsForm.QSLwnsItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSLSentAdv', 'F');
end;

procedure TGridsForm.QSLwrvBItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSL_RCVD_VIA', 'B');
end;

procedure TGridsForm.QSLwrvDItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSL_RCVD_VIA', 'D');
end;

procedure TGridsForm.QSLwrvEItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSL_RCVD_VIA', 'E');
end;

procedure TGridsForm.QSLwrvGItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSL_RCVD_VIA', 'G');
end;

procedure TGridsForm.QSLwrvMItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSL_RCVD_VIA', 'M');
end;

procedure TGridsForm.QSLwsvBItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSL_SENT_VIA', 'B');
end;

procedure TGridsForm.QSLwsvDItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSL_SENT_VIA', 'D');
end;

procedure TGridsForm.QSLwsvEItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSL_SENT_VIA', 'E');
end;

procedure TGridsForm.QSLwsvGItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSL_SENT_VIA', 'G');
end;

procedure TGridsForm.QSLwsvMItemClick(Sender: TObject);
var
  Caller: TObject;
begin
  Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  MainFunc.UpdateQSO((Caller as TDBGrid), 'QSL_SENT_VIA', 'M');
end;

procedure TGridsForm.SelectAllItemClick(Sender: TObject);
begin
  MainFunc.SelectAllQSO(DBGrid1);
end;

procedure TGridsForm.SendClusterItemClick(Sender: TObject);
begin
  SendTelnetSpot.Show;
  SendTelnetSpot.EditDXCall.Text :=
    DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
  SendTelnetSpot.CBFreq.Text :=
    DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
end;

procedure TGridsForm.GridMenuPopup(Sender: TObject);
var
  LogItem: TMenuItem;
  i: integer;
  Caller: TObject;
begin
  Caller := (Sender as TPopupMenu).PopupComponent;

  for i := 0 to GridMenu.Items.Count - 1 do
  begin
    if (Caller as TDBGrid).Name = 'DBGrid1' then GridMenu.Items[i].Visible := True;

    if ((Caller as TDBGrid).Name = 'DBGrid2') and (GridMenu.Items[i].Tag = 0) then
      GridMenu.Items[i].Visible := False;

  end;

  if DBRecord.InitDB = 'YES' then
  begin
    for i := GridsForm.ComponentCount - 1 downto 0 do
      if (GridsForm.Components[i] is TMenuItem) then
        if (GridsForm.Components[i] as TMenuItem).Tag = 98 then
          (GridsForm.Components[i] as TMenuItem).Free;
    for i := 0 to High(MainFunc.GetAllCallsign) do
    begin
      LogItem := TMenuItem.Create(Self);
      LogItem.Name := 'LogItem' + IntToStr(i);
      LogItem.Caption := MainFunc.GetAllCallsign[i];
      LogItem.OnClick := @CopyToLogItemClick;
      LogItem.Tag := 98;
      if LogItem.Caption = LBRecord.CallSign then
        LogItem.Enabled := False;
      CopyToLogItem0.Insert(i, LogItem);
    end;

    for i := 0 to FoundBroadcastLog.Count - 1 do
    begin
      LogItem := TMenuItem.Create(Self);
      LogItem.Name := 'LogItemBroadcast' + IntToStr(i);
      LogItem.Caption := FoundBroadcastLog.Names[i];
      LogItem.OnClick := @SendToLogBroadcastItemClick;
      LogItem.Tag := 98;
      MISendOnLAN.Insert(i, LogItem);
    end;

  end;
end;

end.
