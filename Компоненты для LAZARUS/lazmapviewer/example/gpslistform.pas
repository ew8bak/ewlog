unit gpslistform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ButtonPanel, ComCtrls,
  ExtCtrls, Buttons, StdCtrls, mvGpsObj, mvMapViewer;

const
  // IDs of GPS items
  _CLICKED_POINTS_ = 10;
  _TRACK_POINTS_ = 20;

type

  { TGPSListViewer }

  TGPSListViewer = class(TForm)
    BtnDeletePoint: TBitBtn;
    BtnGoToPoint: TBitBtn;
    BtnClose: TBitBtn;
    BtnCalcDistance: TButton;
    BtnSavePts: TButton;
    BtnLoadTrack: TButton;
    ListView: TListView;
    OpenDialog: TOpenDialog;
    Panel1: TPanel;
    SaveDialog: TSaveDialog;
    procedure BtnCalcDistanceClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnDeletePointClick(Sender: TObject);
    procedure BtnGoToPointClick(Sender: TObject);
    procedure BtnSavePtsClick(Sender: TObject);
    procedure BtnLoadTrackClick(Sender: TObject);
  private
    FViewer: TMapView;
    FList: TGpsObjList;
    procedure SetViewer(AValue: TMapView);
  protected
    procedure Populate;

  public
    destructor Destroy; override;
    property MapViewer: TMapView read FViewer write SetViewer;

  end;

var
  GPSListViewer: TGPSListViewer;

implementation

{$R *.lfm}

uses
  mvTypes, mvEngine,
  globals;

destructor TGPSListViewer.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TGPSListViewer.Populate;
var
  i: Integer;
  item: TListItem;
  gpsObj: TGpsObj;
  area: TRealArea;
begin
  if FViewer = nil then begin
    ListView.Items.Clear;
    exit;
  end;

  FViewer.GPSItems.GetArea(area);
  FList.Free;
  FList := FViewer.GPSItems.GetObjectsInArea(area);
  ListView.Items.BeginUpdate;
  try
    ListView.Items.Clear;
    for i:=0 to FList.Count-1 do begin
      gpsObj := FList[i];
      item := ListView.Items.Add;
      if gpsObj is TGpsPoint then begin
        item.SubItems.Add(gpsObj.Name);
        item.Subitems.Add(LatToStr(TGpsPoint(gpsObj).Lat, true));
        item.Subitems.Add(LonToStr(TGpsPoint(gpsObj).Lon, true));
      end;
    end;
  finally
    ListView.Items.EndUpdate;
  end;
end;

procedure TGPSListViewer.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TGPSListViewer.BtnCalcDistanceClick(Sender: TObject);
type
  TCoordRec = record
    Lon: Double;
    Lat: Double;
    Name: String;
  end;
var
  i, iChecked: Integer;
  item: TListItem;
  rPt: TRealPoint;
  CoordArr: array[0..1] of TCoordRec;
begin
  // count checked items
  iChecked := 0;
  for i:=0 to ListView.Items.Count - 1 do begin
    if ListView.Items.Item[i].Checked then Inc(iChecked);
  end;

  if iChecked <> 2 then begin
    ShowMessage('Please select 2 items to calculate the distance.');
    exit;
  end;

  iChecked := 0;
  for i:=0 to ListView.Items.Count - 1 do begin
    if ListView.Items.Item[i].Checked then begin
      item := ListView.Items[i];
      if TryStrToGps(item.SubItems[2], rPt.Lon) and TryStrToGps(item.SubItems[1], rPt.Lat) then
      begin
        CoordArr[iChecked].Lon := rPt.Lon;
        CoordArr[iChecked].Lat := rPt.Lat;
        CoordArr[iChecked].Name:= item.SubItems[0];
        Inc(iChecked);
      end;
    end;
  end;
  // show distance between selected items
  ShowMessage(Format('Distance between %s and %s is: %.2n %s.', [
    CoordArr[0].Name, CoordArr[1].Name,
    CalcGeoDistance(CoordArr[0].Lat, CoordArr[0].Lon, CoordArr[1].Lat, CoordArr[1].Lon, DistanceUnit),
    DistanceUnit_Names[DistanceUnit]
    ]));
end;

procedure TGPSListViewer.BtnDeletePointClick(Sender: TObject);
var
  gpsObj: TGpsObj;
  i: Integer;
  rPt: TRealPoint;
  item: TListItem;
begin
  if ListView.Selected <> nil then begin
    gpsObj := FList[ListView.Selected.Index];
    ListView.Selected.Free;
    FViewer.GpsItems.Clear(_CLICKED_POINTS_);
    for i:=0 to ListView.Items.Count-1 do begin
      item := ListView.Items[i];
      if TryStrToGps(item.SubItems[2], rPt.Lon) and TryStrToGps(item.SubItems[1], rPt.Lat) then
      begin
        gpsObj := TGpsPoint.CreateFrom(rPt);
        gpsObj.Name := item.SubItems[0];
        FViewer.GPSItems.Add(gpsObj, _CLICKED_POINTS_);
      end;
    end;
  end;
end;

procedure TGPSListViewer.BtnGoToPointClick(Sender: TObject);
var
  gpsPt: TGpsPoint;
  gpsObj: TGpsObj;
begin
  if ListView.Selected <> nil then begin
    gpsObj := FList[ListView.Selected.Index];
    if gpsObj is TGpsPoint then begin
      gpsPt := TGpsPoint(gpsObj);
      if Assigned(FViewer) then FViewer.Center := gpsPt.RealPoint;
    end;
  end;
end;

procedure TGPSListViewer.BtnSavePtsClick(Sender: TObject);
var
  i: Integer;
  gpsPt: TGpsPoint;
  gpsObj: TGpsObj;
  L: TStrings;
  s: String;
begin
  if (OpenDialog.FileName <> '') and (SaveDialog.FileName = '') then
    SaveDialog.FileName := OpenDialog.FileName;
  if SaveDialog.FileName <> '' then
    SaveDialog.InitialDir := ExtractFileDir(SaveDialog.FileName);
  if not SaveDialog.Execute then exit;

  L := TStringList.Create;
  try
    s := 'Index'#9'Name'#9'Longitude'#9'Latitude';
    L.Add(s);
    for i:=0 to FList.Count-1 do begin
      gpsObj := FList[i];
      if gpsObj is TGpsPoint then begin
        gpsPt := TGpsPoint(gpsObj);
        s := Format('%d'#9'%s'#9'%s'#9'%s', [
          i, gpsPt.Name, LonToStr(gpsPt.Lon, true), LatToStr(gpsPt.Lat, true)
        ]);
        L.Add(s);
      end;
      L.SaveToFile(SaveDialog.FileName);
    end;
  finally
    L.Free;
  end;
end;

procedure TGPSListViewer.BtnLoadTrackClick(Sender: TObject);
var
  L: TStrings;
  gpsTrack: TGpsTrack;
  gpsPt: TGpsPoint;
  sa: TStringArray;
  lon, lat: Double;
  i: Integer;
  item: TListItem;
begin
  if (SaveDialog.FileName <> '') and (OpenDialog.FileName = '') then
    OpenDialog.FileName := SaveDialog.FileName;
  if OpenDialog.FileName <> '' then
    OpenDialog.InitialDir := ExtractFileDir(OpenDialog.FileName);
  if not OpenDialog.Execute then exit;

  gpsTrack := TGpsTrack.Create;
  L := TStringList.Create;
  try
    L.LoadFromFile(OpenDialog.FileName);
    for i := 1 to L.Count - 1 do begin  // i=1 --> skip header line
      if L[i] = '' then Continue;
      sa := L[i].Split(#9);
      if TryStrToGps(sa[2], lon) and TryStrToGps(sa[3], lat) then begin
        gpsPt := TGpsPoint.Create(lon, lat);
        gpsPt.Name := sa[1];
        gpsTrack.Points.Add(gpsPt);
      end;
    end;
    FViewer.GPSItems.Add(gpsTrack, _TRACK_POINTS_);
    FViewer.Center := gpsPt.RealPoint;
  finally
    L.Free;
  end;

  ListView.Items.BeginUpdate;
  try
    ListView.Items.Clear;
    for i:=0 to gpsTrack.Points.Count - 1 do begin
      gpsPt := gpsTrack.Points[i];
      item := ListView.Items.Add;
      item.SubItems.Add(gpsPt.Name);
      item.SubItems.Add(LatToStr(gpsPt.Lat, true));
      item.SubItems.Add(LonToStr(gpsPt.Lon, true));
    end;
  finally
    ListView.Items.EndUpdate;
  end;
end;

procedure TGPSListViewer.SetViewer(AValue: TMapView);
begin
  if FViewer = AValue then
    exit;
  FViewer := AValue;
  Populate;
end;

end.

