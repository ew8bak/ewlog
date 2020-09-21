unit GridsForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, DBGrids, ExtCtrls,
  Grids, Menus, selectQSO_record, foundQSO_record, prefix_record, ResourceStr;

type

  { TGridsForm }

  TGridsForm = class(TForm)
    AddUniqCallItem: TMenuItem;
    CopyToLogItem0: TMenuItem;
    DelRecItem: TMenuItem;
    EditItem: TMenuItem;
    ExportADIFItem: TMenuItem;
    ExportHRDItem: TMenuItem;
    ExportQSLccItem: TMenuItem;
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
    PrefixItem: TMenuItem;
    QEditItem: TMenuItem;
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
    procedure ExportHRDItemClick(Sender: TObject);
    procedure ExportQSLccItemClick(Sender: TObject);
    procedure FilterCancelItemClick(Sender: TObject);
    procedure FilterDNSentItemClick(Sender: TObject);
    procedure FilterItemClick(Sender: TObject);
    procedure FilterNSentQSLItemClick(Sender: TObject);
    procedure FilterQSLPItemClick(Sender: TObject);
    procedure FilterRecQSLItemClick(Sender: TObject);
    procedure FilterSentQSLItemClick(Sender: TObject);
    procedure FinqQSLManItemClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridMenuPopup(Sender: TObject);
    procedure CopyToLogItemClick(Sender: TObject);
    procedure MarkQSOItemClick(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure PrefixItemClick(Sender: TObject);
    procedure PrintQSOManItemClick(Sender: TObject);
    procedure PrintQSOnoMarkItemClick(Sender: TObject);
    procedure PrintQSOwMarkItemClick(Sender: TObject);
    procedure QEditItemClick(Sender: TObject);
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
  if IniSet.MainForm = 'MULTI' then
    if GridsForm.WindowState <> wsMaximized then
    begin
      INIFile.WriteInteger('SetLog', 'gLeft', GridsForm.Left);
      INIFile.WriteInteger('SetLog', 'gTop', GridsForm.Top);
      INIFile.WriteInteger('SetLog', 'gWidth', GridsForm.Width);
      INIFile.WriteInteger('SetLog', 'gHeight', GridsForm.Height);
    end;
end;

procedure TGridsForm.DBGrid1ColumnMoved(Sender: TObject; FromIndex, ToIndex: integer);
begin
  MainFunc.SaveGridsColumnMoved(DBGrid1);
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
    Earth.PaintLine(Lat, Lon, LBRecord.OpLat, LBRecord.OpLon);
    UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
    MiniForm.TextSB('QSO № ' + IntToStr(SelQSOR.NumSelectQSO) +
      rQSOTotal + IntToStr(CountAllRecords), 1);
  end;

end;

procedure TGridsForm.DBGrid1ColumnSized(Sender: TObject);
begin
  MainFunc.SaveGridsColumnSized(DBGrid1);
  MainFunc.SetGrid(DBGrid1);
  MainFunc.SetGrid(DBGrid2);
end;

procedure TGridsForm.DBGrid1DblClick(Sender: TObject);
begin
  if InitRecord.SelectLogbookTable and (DBGrid1.SelectedIndex <> 0) then
  begin
    GridRecordIndex := DBGrid1.DataSource.DataSet.RecNo;
    UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
    EditQSO_Form.Show;
  end;
end;

procedure TGridsForm.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: integer; Column: TColumn; State: TGridDrawState);
begin
  MainFunc.DrawColumnGrid(LOGBookDS.DataSet, Rect, DataCol, Column, State, DBGrid1);
end;

procedure TGridsForm.DBGrid2DblClick(Sender: TObject);
begin
  if InitRecord.SelectLogbookTable and (DBGrid2.SelectedIndex <> 0) then
  begin
    GridRecordIndex := DBGrid2.DataSource.DataSet.RecNo;
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
      EditQSO_Form.Show;
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
    exportAdifForm.Button1.Click;
  end;
end;

procedure TGridsForm.ExportHRDItemClick(Sender: TObject);
begin
  {  if LogBookQuery.RecordCount > 0 then
  begin
    SendHRDThread := TSendHRDThread.Create;
    if Assigned(SendHRDThread.FatalException) then
      raise SendHRDThread.FatalException;
    with SendHRDThread do
    begin
      userid := HRDLogin;
      userpwd := HRDCode;
      call := DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
      startdate := DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsDateTime;
      starttime := DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsDateTime;
      freq := DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
      mode := DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;
      submode := DBGrid1.DataSource.DataSet.FieldByName('QSOSubMode').AsString;
      rsts := DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
      rstr := DBGrid1.DataSource.DataSet.FieldByName('QSOReportRecived').AsString;
      locat := DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;
      qslinf := SetQSLInfo;
      information := 1;
      inform := 1;
      Start;
    end;
  end; }
end;

procedure TGridsForm.ExportQSLccItemClick(Sender: TObject);
begin
  {  if LogBookQuery.RecordCount > 0 then
  begin
    SendEQSLThread := TSendEQSLThread.Create;
    if Assigned(SendEQSLThread.FatalException) then
      raise SendEQSLThread.FatalException;
    with SendEQSLThread do
    begin
      userid := eQSLccLogin;
      userpwd := eQSLccPassword;
      call := DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
      startdate := DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsDateTime;
      starttime := DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsDateTime;
      freq := DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
      mode := DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;
      submode := DBGrid1.DataSource.DataSet.FieldByName('QSOSubMode').AsString;
      rst := DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
      qslinf := SetQSLInfo;
      information := 1;
      Start;
    end;
  end; }
end;

procedure TGridsForm.FilterCancelItemClick(Sender: TObject);
begin
  InitDB.SelectLogbookTable(LBRecord.LogTable);
end;

procedure TGridsForm.FilterDNSentItemClick(Sender: TObject);
begin
  MainFunc.FilterQSO('QSLSentAdv', 'N');
end;

procedure TGridsForm.FilterItemClick(Sender: TObject);
begin

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

procedure TGridsForm.FinqQSLManItemClick(Sender: TObject);
begin

end;

procedure TGridsForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  MainFunc.SaveGrids(DBGrid1);
end;

procedure TGridsForm.FormCreate(Sender: TObject);
begin
  MainFunc.SetGrid(DBGrid1);
  MainFunc.SetGrid(DBGrid2);
  ExportAdifSelect := False;
end;

procedure TGridsForm.FormShow(Sender: TObject);
begin
  if (IniSet._l_g <> 0) and (IniSet._t_g <> 0) and (IniSet._w_g <> 0) and
    (IniSet._h_g <> 0) then
    GridsForm.SetBounds(IniSet._l_g, IniSet._t_g, IniSet._w_g, IniSet._h_g);
end;

procedure TGridsForm.CopyToLogItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
begin
  MenuItem := (Sender as TMenuItem);
  MainFunc.CopyToJournal(DBGrid1, MenuItem.Caption);
end;

procedure TGridsForm.MarkQSOItemClick(Sender: TObject);
begin

end;

procedure TGridsForm.MenuItem4Click(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSLRec', '1');
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

procedure TGridsForm.QEditItemClick(Sender: TObject);
begin
  {if (DBRecord.InitDB = 'YES') and (LOGBookDS.DataSet.Fields[0].AsString <> '') then
  begin
    EditFlag := True;
    CheckBox1.Checked := False;
    CheckBox2.Checked := True;
    EditButton1.Font.Color := clBlack;
    EditButton1.Color := clRed;
    EditButton1.Text := DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
    Edit1.Text := DBGrid1.DataSource.DataSet.FieldByName('OMName').AsString;
    Edit2.Text := DBGrid1.DataSource.DataSet.FieldByName('OMQTH').AsString;
    Edit3.Text := DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;
    Edit4.Text := DBGrid1.DataSource.DataSet.FieldByName('State').AsString;
    Edit5.Text := DBGrid1.DataSource.DataSet.FieldByName('IOTA').AsString;
    Edit6.Text := DBGrid1.DataSource.DataSet.FieldByName('QSLManager').AsString;
    ComboBox1.Text := DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
    ComboBox2.Items.IndexOf(DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString);
    DateTimePicker1.Time := DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsDateTime;
    DateEdit1.Date := DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsDateTime;
    Edit11.Text := DBGrid1.DataSource.DataSet.FieldByName('QSOAddInfo').AsString;
    Edit10.Text := DBGrid1.DataSource.DataSet.FieldByName('State1').AsString;
    Edit9.Text := DBGrid1.DataSource.DataSet.FieldByName('State2').AsString;
    Edit8.Text := DBGrid1.DataSource.DataSet.FieldByName('State3').AsString;
    Edit7.Text := DBGrid1.DataSource.DataSet.FieldByName('State4').AsString;
    case DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString of
      '': ComboBox6.ItemIndex := 0;
      'B': ComboBox6.ItemIndex := 1;
      'D': ComboBox6.ItemIndex := 2;
      'E': ComboBox6.ItemIndex := 3;
      'M': ComboBox6.ItemIndex := 4;
      'G': ComboBox6.ItemIndex := 5;
    end;

    ComboBox4.Text := DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
    ComboBox5.Text := DBGrid1.DataSource.DataSet.FieldByName(
      'QSOReportRecived').AsString;
  end;    }
end;

procedure TGridsForm.QSLInfoItemClick(Sender: TObject);
begin

end;

procedure TGridsForm.QSLnsItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSLSentAdv', 'N');
end;

procedure TGridsForm.QSLPrintedItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSLSentAdv', 'P');
end;

procedure TGridsForm.QSLQueuedItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSLPrint', 'Q');
end;

procedure TGridsForm.QSLReceivedItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSLSentAdv', 'Q');
end;

procedure TGridsForm.QSLSentItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSLSentAdv', 'T');
end;

procedure TGridsForm.QSLwnsItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSLSentAdv', 'F');
end;

procedure TGridsForm.QSLwrvBItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSL_RCVD_VIA', 'B');
end;

procedure TGridsForm.QSLwrvDItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSL_RCVD_VIA', 'D');
end;

procedure TGridsForm.QSLwrvEItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSL_RCVD_VIA', 'E');
end;

procedure TGridsForm.QSLwrvGItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSL_RCVD_VIA', 'G');
end;

procedure TGridsForm.QSLwrvMItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSL_RCVD_VIA', 'M');
end;

procedure TGridsForm.QSLwsvBItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSL_SENT_VIA', 'B');
end;

procedure TGridsForm.QSLwsvDItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSL_SENT_VIA', 'D');
end;

procedure TGridsForm.QSLwsvEItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSL_SENT_VIA', 'E');
end;

procedure TGridsForm.QSLwsvGItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSL_SENT_VIA', 'G');
end;

procedure TGridsForm.QSLwsvMItemClick(Sender: TObject);
begin
  MainFunc.UpdateQSO(DBGrid1, 'QSL_SENT_VIA', 'M');
end;

procedure TGridsForm.SelectAllItemClick(Sender: TObject);
begin
  MainFunc.SelectAllQSO(DBGrid1);
end;

procedure TGridsForm.SendClusterItemClick(Sender: TObject);
var
  freq: string;
  freq2: double;
begin
  SendTelnetSpot.Show;
  SendTelnetSpot.Edit1.Text :=
    DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
  freq := DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
  Delete(freq, length(freq) - 2, 1);
  freq2 := StrToFloat(freq);
  SendTelnetSpot.ComboBox1.Text := FloatToStr(freq2);
end;

procedure TGridsForm.GridMenuPopup(Sender: TObject);
var
  LogItem: TMenuItem;
  i: integer;
begin
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
  end;
end;

end.
