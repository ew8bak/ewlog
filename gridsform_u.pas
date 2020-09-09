unit GridsForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, DBGrids, ExtCtrls,
  Grids, selectQSO_record, foundQSO_record, prefix_record;

type

  { TGridsForm }

  TGridsForm = class(TForm)
    FindQSODS: TDataSource;
    LOGBookDS: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
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
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  GridsForm: TGridsForm;

implementation

uses MainFuncDM, dmFunc_U, InitDB_dm, Earth_Form_U, MainForm_U, editqso_u;

{$R *.lfm}

{ TGridsForm }

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
    MainForm.Label17.Caption := IntToStr(FoundQSOR.CountQSO);
    MainForm.Label18.Caption := SelQSOR.QSODate;
    MainForm.Label19.Caption := SelQSOR.QSOTime;
    MainForm.Label20.Caption := SelQSOR.QSOBand;
    MainForm.Label21.Caption := SelQSOR.QSOMode;
    MainForm.Label22.Caption := SelQSOR.OMName;
    MainForm.Label32.Caption := PFXR.Azimuth;
    MainForm.Label37.Caption := PFXR.Distance;
    MainForm.Label40.Caption := PFXR.Latitude;
    MainForm.Label42.Caption := PFXR.Longitude;
    MainForm.Label33.Caption := PFXR.Country;
    MainForm.Label43.Caption := PFXR.Continent;
    MainForm.Label34.Caption := PFXR.ARRLPrefix;
    MainForm.Label38.Caption := PFXR.Prefix;
    MainForm.Label45.Caption := PFXR.CQZone;
    MainForm.Label47.Caption := PFXR.ITUZone;
    timedif := PFXR.TimeDiff;
    dmFunc.GetLatLon(PFXR.Latitude, PFXR.Longitude, Lat, Lon);
    Earth.PaintLine(Lat, Lon, LBRecord.OpLat, LBRecord.OpLon);
    Earth.PaintLine(Lat, Lon, LBRecord.OpLat, LBRecord.OpLon);
    UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
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

procedure TGridsForm.FormCreate(Sender: TObject);
begin
  MainFunc.SetGrid(DBGrid1);
  MainFunc.SetGrid(DBGrid2);
end;

end.
