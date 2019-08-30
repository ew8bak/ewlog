unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Buttons, IntfGraphics, ColorBox,
  mvGeoNames, mvMapViewer, mvTypes, mvGpsObj, mvDrawingEngine,
  mvDE_RGBGraphics;

type

  { TMainForm }

  TMainForm = class(TForm)
    Bevel1: TBevel;
    BtnSearch: TButton;
    BtnGoTo: TButton;
    BtnGPSPoints: TButton;
    BtnSaveToFile: TButton;
    BtnLoadGPXFile: TButton;
    BtnPOITextFont: TButton;
    CbDoubleBuffer: TCheckBox;
    CbFoundLocations: TComboBox;
    CbLocations: TComboBox;
    CbProviders: TComboBox;
    CbUseThreads: TCheckBox;
    CbMouseCoords: TGroupBox;
    CbDistanceUnits: TComboBox;
    CbDebugTiles: TCheckBox;
    CbDrawingEngine: TComboBox;
    CbShowPOIImage: TCheckBox;
    cbPOITextBgColor: TColorBox;
    FontDialog: TFontDialog;
    GbCenterCoords: TGroupBox;
    GbScreenSize: TGroupBox;
    GbSearch: TGroupBox;
    GbGPS: TGroupBox;
    InfoCenterLatitude: TLabel;
    InfoViewportHeight: TLabel;
    InfoCenterLongitude: TLabel;
    InfoBtnGPSPoints: TLabel;
    GPSPointInfo: TLabel;
    InfoViewportWidth: TLabel;
    Label1: TLabel;
    LblPOITextBgColor: TLabel;
    LblSelectLocation: TLabel;
    LblCenterLatitude: TLabel;
    LblViewportHeight: TLabel;
    LblViewportWidth: TLabel;
    LblPositionLongitude: TLabel;
    LblPositionLatitude: TLabel;
    InfoPositionLongitude: TLabel;
    InfoPositionLatitude: TLabel;
    LblCenterLongitude: TLabel;
    LblProviders: TLabel;
    LblZoom: TLabel;
    MapView: TMapView;
    GeoNames: TMVGeoNames;
    BtnLoadMapProviders: TSpeedButton;
    BtnSaveMapProviders: TSpeedButton;
    OpenDialog: TOpenDialog;
    PageControl: TPageControl;
    PgData: TTabSheet;
    PgConfig: TTabSheet;
    ZoomTrackBar: TTrackBar;
    procedure BtnGoToClick(Sender: TObject);
    procedure BtnLoadGPXFileClick(Sender: TObject);
    procedure BtnSearchClick(Sender: TObject);
    procedure BtnGPSPointsClick(Sender: TObject);
    procedure BtnSaveToFileClick(Sender: TObject);
    procedure BtnPOITextFontClick(Sender: TObject);
    procedure CbDebugTilesChange(Sender: TObject);
    procedure CbDrawingEngineChange(Sender: TObject);
    procedure CbDoubleBufferChange(Sender: TObject);
    procedure CbFoundLocationsDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure cbPOITextBgColorChange(Sender: TObject);
    procedure CbProvidersChange(Sender: TObject);
    procedure CbShowPOIImageChange(Sender: TObject);
    procedure CbUseThreadsChange(Sender: TObject);
    procedure CbDistanceUnitsChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GeoNamesNameFound(const AName: string; const ADescr: String;
      const ALoc: TRealPoint);
    procedure MapViewChange(Sender: TObject);
    procedure MapViewDrawGpsPoint(Sender: TObject;
      ADrawer: TMvCustomDrawingEngine; APoint: TGpsPoint);
    procedure MapViewMouseLeave(Sender: TObject);
    procedure MapViewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MapViewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MapViewZoomChange(Sender: TObject);
    procedure BtnLoadMapProvidersClick(Sender: TObject);
    procedure BtnSaveMapProvidersClick(Sender: TObject);
    procedure ZoomTrackBarChange(Sender: TObject);

  private
    FRGBGraphicsDrawingEngine: TMvRGBGraphicsDrawingEngine;
    POIImage: TCustomBitmap;
    procedure ClearFoundLocations;
    procedure UpdateCoords(X, Y: Integer);
    procedure UpdateDropdownWidth(ACombobox: TCombobox);
    procedure UpdateLocationHistory(ALocation: String);
    procedure UpdateViewportSize;

  public
    procedure ReadFromIni;
    procedure WriteToIni;

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  LCLType, IniFiles, Math, FPCanvas, FPImage, FpImgCanv, GraphType,
  mvEngine, mvGPX,
  globals, gpslistform;

type
  TLocationParam = class
    Descr: String;
    Loc: TRealPoint;
  end;

const
  MAX_LOCATIONS_HISTORY = 50;
  HOMEDIR = '';
  MAP_PROVIDER_FILENAME = 'map-providers.xml';
  USE_DMS = true;

var
  PointFormatSettings: TFormatsettings;


function CalcIniName: String;
begin
  Result := ChangeFileExt(Application.ExeName, '.ini');
end;


{ TMainForm }

procedure TMainForm.BtnLoadMapProvidersClick(Sender: TObject);
var
  fn: String;
  msg: String;
begin
  fn := Application.Location + MAP_PROVIDER_FILENAME;
  if FileExists(fn) then begin
    if MapView.Engine.ReadProvidersFromXML(fn, msg) then begin
      MapView.GetMapProviders(CbProviders.Items);
      CbProviders.ItemIndex := 0;
      MapView.MapProvider := CbProviders.Text;
    end else
      ShowMessage(msg);
  end;
end;

procedure TMainForm.BtnSaveMapProvidersClick(Sender: TObject);
begin
  MapView.Engine.WriteProvidersToXML(Application.Location + MAP_PROVIDER_FILENAME);
end;

procedure TMainForm.BtnSearchClick(Sender: TObject);
begin
  ClearFoundLocations;
  GeoNames.Search(CbLocations.Text, MapView.DownloadEngine);
  UpdateDropdownWidth(CbFoundLocations);
  UpdateLocationHistory(CbLocations.Text);
  if CbFoundLocations.Items.Count > 0 then CbFoundLocations.ItemIndex := 0;
end;

procedure TMainForm.BtnGPSPointsClick(Sender: TObject);
var
  F: TGpsListViewer;
begin
  F := TGpsListViewer.Create(nil);
  try
    F.MapViewer := MapView;
    F.ShowModal;
  finally
    F.Free;
  end;
end;

procedure TMainForm.BtnGoToClick(Sender: TObject);
var
  s: String;
  P: TLocationParam;
begin
  if CbFoundLocations.ItemIndex = -1 then
    exit;

  // Extract parameters of found locations. We need that to get the coordinates.
  s := CbFoundLocations.Items.Strings[CbFoundLocations.ItemIndex];
  P := TLocationParam(CbFoundLocations.Items.Objects[CbFoundLocations.ItemIndex]);
  if P = nil then
    exit;
  CbFoundLocations.Text := s;

  // Show location in center of mapview
  MapView.Zoom := 12;
  MapView.Center := P.Loc;
  MapView.Invalidate;
end;

procedure TMainForm.BtnLoadGPXFileClick(Sender: TObject);
var
  reader: TGpxReader;
  b: TRealArea;
begin
  if OpenDialog.FileName <> '' then
    OpenDialog.InitialDir := ExtractFileDir(OpenDialog.Filename);
  if OpenDialog.Execute then begin
    reader := TGpxReader.Create;
    try
      reader.LoadFromFile(OpenDialog.FileName, MapView.GPSItems, b);
      MapView.Engine.ZoomOnArea(b);
      MapViewZoomChange(nil);
    finally
      reader.Free;
    end;
  end;
end;

procedure TMainForm.BtnSaveToFileClick(Sender: TObject);
begin
  MapView.SaveToFile(TPortableNetworkGraphic, 'mapview.png');
  ShowMessage('Map saved to "mapview.png".');
end;

procedure TMainForm.BtnPOITextFontClick(Sender: TObject);
begin
  FontDialog.Font.Assign(MapView.Font);
  if FontDialog.Execute then
    MapView.Font.Assign(FontDialog.Font);
end;

procedure TMainForm.CbDebugTilesChange(Sender: TObject);
begin
  MapView.DebugTiles := CbDebugTiles.Checked;
end;

procedure TMainForm.CbDrawingEngineChange(Sender: TObject);
begin
  case CbDrawingEngine.ItemIndex of
    0: MapView.DrawingEngine := nil;
    1: begin
         if FRGBGraphicsDrawingEngine = nil then
           FRGBGraphicsDrawingEngine := TMvRGBGraphicsDrawingEngine.Create(self);
         MapView.DrawingEngine := FRGBGraphicsDrawingEngine;
       end;
  end;
end;

procedure TMainForm.CbDoubleBufferChange(Sender: TObject);
begin
  MapView.DoubleBuffered := CbDoubleBuffer.Checked;
end;

procedure TMainForm.CbFoundLocationsDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  s: String;
  P: TLocationParam;
  combo: TCombobox;
  x, y: Integer;
begin
  combo := TCombobox(Control);
  if (State * [odSelected, odFocused] <> []) then begin
    combo.Canvas.Brush.Color := clHighlight;
    combo.Canvas.Font.Color := clHighlightText;
  end else begin
    combo.Canvas.Brush.Color := clWindow;
    combo.Canvas.Font.Color := clWindowText;
  end;
  combo.Canvas.FillRect(ARect);
  combo.Canvas.Brush.Style := bsClear;
  s := combo.Items.Strings[Index];
  P := TLocationParam(combo.Items.Objects[Index]);
  x := ARect.Left + 2;
  y := ARect.Top + 2;
  combo.Canvas.Font.Style := [fsBold];
  combo.Canvas.TextOut(x, y, s);
  inc(y, combo.Canvas.TextHeight('Tg'));
  combo.Canvas.Font.Style := [];
  combo.Canvas.TextOut(x, y, P.Descr);
end;

procedure TMainForm.cbPOITextBgColorChange(Sender: TObject);
begin
  MapView.POITextBgColor := cbPOITextBgColor.Selected;
end;

procedure TMainForm.CbProvidersChange(Sender: TObject);
begin
  MapView.MapProvider := CbProviders.Text;
end;

procedure TMainForm.CbShowPOIImageChange(Sender: TObject);
begin
  if CbShowPOIImage.Checked then
    MapView.POIImage.Assign(POIImage)
  else
    MapView.POIImage.Clear;
end;

procedure TMainForm.CbUseThreadsChange(Sender: TObject);
begin
  MapView.UseThreads := CbUseThreads.Checked;
end;

procedure TMainForm.CbDistanceUnitsChange(Sender: TObject);
begin
  DistanceUnit := TDistanceUnits(CbDistanceUnits.ItemIndex);
  UpdateViewPortSize;
end;

procedure TMainForm.ClearFoundLocations;
var
  i: Integer;
  P: TLocationParam;
begin
  for i:=0 to CbFoundLocations.Items.Count-1 do begin
    P := TLocationParam(CbFoundLocations.Items.Objects[i]);
    P.Free;
  end;
  CbFoundLocations.Items.Clear;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
//  FMapMarker := CreateMapMarker(32, clRed, clBlack);
  POIImage := TPortableNetworkGraphic.Create;
  POIImage.PixelFormat := pf32bit;
  POIImage.LoadFromFile('../../mapmarker.png');

  ForceDirectories(HOMEDIR + 'cache/');
  MapView.CachePath := HOMEDIR + 'cache/';
  MapView.GetMapProviders(CbProviders.Items);
  CbProviders.ItemIndex := CbProviders.Items.Indexof(MapView.MapProvider);
  MapView.DoubleBuffered := true;
  MapView.Zoom := 1;
  CbUseThreads.Checked := MapView.UseThreads;
  CbDoubleBuffer.Checked := MapView.DoubleBuffered;
  CbPOITextBgColor.Selected := MapView.POITextBgColor;

  InfoPositionLongitude.Caption := '';
  InfoPositionLatitude.Caption := '';
  InfoCenterLongitude.Caption := '';
  InfoCenterLatitude.Caption := '';
  InfoViewportWidth.Caption := '';
  InfoViewportHeight.Caption := '';
  GPSPointInfo.caption := '';

  ReadFromIni;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  WriteToIni;
  ClearFoundLocations;
  FreeAndNil(POIImage)
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  MapView.Active := true;
end;

procedure TMainForm.GeoNamesNameFound(const AName: string;
  const ADescr: String; const ALoc: TRealPoint);
var
  P: TLocationParam;
begin
  P := TLocationParam.Create;
  P.Descr := ADescr;
  P.Loc := ALoc;
  CbFoundLocations.Items.AddObject(AName, P);
end;

procedure TMainForm.MapViewChange(Sender: TObject);
begin
  UpdateViewportSize;
end;

procedure TMainForm.MapViewDrawGpsPoint(Sender: TObject;
  ADrawer: TMvCustomDrawingEngine; APoint: TGpsPoint);
const
  R = 5;
var
  P: TPoint;
  ext: TSize;
begin
  // Screen coordinates of the GPS point
  P := TMapView(Sender).LonLatToScreen(APoint.RealPoint);

  // Draw the GPS point with MapMarker bitmap
  {
  if CbShowPOIImage.Checked and not MapView.POIImage.Empty then begin
    ADrawer.DrawBitmap(P.X - MapView.POIImage.Width div 2, P.Y - MapView.POIImage.Height, MapView.POIImage, true);
  end else begin
  }
    // Draw the GPS point as a circle
    ADrawer.BrushColor := clRed;
    ADrawer.BrushStyle := bsSolid;
    ADrawer.Ellipse(P.X - R, P.Y - R, P.X + R, P.Y + R);
    P.Y := P.Y + R;
  //end;
    {
  // Draw the caption of the GPS point
  ext := ADrawer.TextExtent(APoint.Name);
  ADrawer.BrushColor := clWhite;
  ADrawer.BrushStyle := bsClear;
  ADrawer.TextOut(P.X - ext.CX div 2, P.Y + 5, APoint.Name);
  }
end;

procedure TMainForm.MapViewMouseLeave(Sender: TObject);
begin
  UpdateCoords(MaxInt, MaxInt);
end;

procedure TMainForm.MapViewMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
const
  DELTA = 3;
var
  rArea: TRealArea;
  gpsList: TGpsObjList;
  L: TStrings;
  i: Integer;
begin
  UpdateCoords(X, Y);

  rArea.TopLeft := MapView.ScreenToLonLat(Point(X-DELTA, Y-DELTA));
  rArea.BottomRight := MapView.ScreenToLonLat(Point(X+DELTA, Y+DELTA));
  gpsList := MapView.GpsItems.GetObjectsInArea(rArea);
  try
    if gpsList.Count > 0 then begin
      L := TStringList.Create;
      try
        for i:=0 to gpsList.Count-1 do
          if gpsList[i] is TGpsPoint then
            with TGpsPoint(gpsList[i]) do
              L.Add(Format('%s (%s / %s)', [
                Name, LatToStr(Lat, USE_DMS), LonToStr(Lon, USE_DMS)
              ]));
        GPSPointInfo.Caption := L.Text;
      finally
        L.Free;
      end;
    end else
      GPSPointInfo.Caption := '';
  finally
    gpsList.Free;
  end;
end;

procedure TMainForm.MapViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  rPt: TRealPoint;
  gpsPt: TGpsPoint;
  gpsName: String;
begin
  if (Button = mbRight) then begin
    if not InputQuery('Name of GPS location', 'Please enter name', gpsName) then
      exit;
    rPt := MapView.ScreenToLonLat(Point(X, Y));
    gpsPt := TGpsPoint.CreateFrom(rPt);
    gpsPt.Name := gpsName;
    MapView.GpsItems.Add(gpsPt, _CLICKED_POINTS_);
  end;
end;

procedure TMainForm.MapViewZoomChange(Sender: TObject);
begin
  ZoomTrackbar.Position := MapView.Zoom;
end;

procedure TMainForm.ReadFromIni;
var
  ini: TCustomIniFile;
  List: TStringList;
  L, T, W, H: Integer;
  R: TRect;
  i: Integer;
  s: String;
  pt: TRealPoint;
  du: TDistanceUnits;
begin
  ini := TMemIniFile.Create(CalcIniName);
  try
    HERE_AppID := ini.ReadString('HERE', 'APP_ID', '');
    HERE_AppCode := ini.ReadString('HERE', 'APP_CODE', '');
    OpenWeatherMap_ApiKey := ini.ReadString('OpenWeatherMap', 'API_Key', '');

    if ((HERE_AppID <> '') and (HERE_AppCode <> '')) or
       (OpenWeatherMap_ApiKey <> '') then
    begin
      MapView.Engine.ClearMapProviders;
      MapView.Engine.RegisterProviders;
      MapView.GetMapProviders(CbProviders.Items);
    end;

    R := Screen.DesktopRect;
    L := ini.ReadInteger('MainForm', 'Left', Left);
    T := ini.ReadInteger('MainForm', 'Top', Top);
    W := ini.ReadInteger('MainForm', 'Width', Width);
    H := ini.ReadInteger('MainForm', 'Height', Height);
    if L + W > R.Right then L := R.Right - W;
    if L < R.Left then L := R.Left;
    if T + H > R.Bottom then T := R.Bottom - H;
    if T < R.Top then T := R.Top;
    SetBounds(L, T, W, H);

    s := ini.ReadString('MapView', 'Provider', MapView.MapProvider);
    if CbProviders.Items.IndexOf(s) = -1 then begin
      MessageDlg('Map provider "' + s + '" not found.', mtError, [mbOK], 0);
      s := CbProviders.Items[0];
    end;
    MapView.MapProvider := s;
    CbProviders.Text := MapView.MapProvider;

    MapView.Zoom := ini.ReadInteger('MapView', 'Zoom', MapView.Zoom);
    pt.Lon := StrToFloatDef(ini.ReadString('MapView', 'Center.Longitude', ''), 0.0, PointFormatSettings);
    pt.Lat := StrToFloatDef(ini.ReadString('MapView', 'Center.Latitude', ''), 0.0, PointFormatSettings);
    MapView.Center := pt;

    s := ini.ReadString('MapView', 'DistanceUnits', '');
    if s <> '' then begin
      for du in TDistanceUnits do
        if DistanceUnit_Names[du] = s then begin
          DistanceUnit := du;
          CbDistanceUnits.ItemIndex := ord(du);
          break;
        end;
    end;

    List := TStringList.Create;
    try
      ini.ReadSection('Locations', List);
      for i:=0 to List.Count-1 do begin
        s := ini.ReadString('Locations', List[i], '');
        if s <> '' then
          CbLocations.Items.Add(s);
      end;
    finally
      List.Free;
    end;

  finally
    ini.Free;
  end;
end;

procedure TMainForm.UpdateCoords(X, Y: Integer);
var
  rPt: TRealPoint;
begin
  rPt := MapView.Center;
  InfoCenterLongitude.Caption := LonToStr(rPt.Lon, USE_DMS);
  InfoCenterLatitude.Caption := LatToStr(rPt.Lat, USE_DMS);

  if (X <> MaxInt) and (Y <> MaxInt) then begin
    rPt := MapView.ScreenToLonLat(Point(X, Y));
    InfoPositionLongitude.Caption := LonToStr(rPt.Lon, USE_DMS);
    InfoPositionLatitude.Caption := LatToStr(rPt.Lat, USE_DMS);
  end else begin
    InfoPositionLongitude.Caption := '-';
    InfoPositionLatitude.Caption := '-';
  end;
end;

procedure TMainForm.UpdateDropdownWidth(ACombobox: TCombobox);
var
  cnv: TControlCanvas;
  i, w: Integer;
  s: String;
  P: TLocationParam;
begin
  w := 0;
  cnv := TControlCanvas.Create;
  try
    cnv.Control := ACombobox;
    cnv.Font.Assign(ACombobox.Font);
    for i:=0 to ACombobox.Items.Count-1 do begin
      cnv.Font.Style := [fsBold];
      s := ACombobox.Items.Strings[i];
      w := Max(w, cnv.TextWidth(s));
      P := TLocationParam(ACombobox.Items.Objects[i]);
      cnv.Font.Style := [];
      w := Max(w, cnv.TextWidth(P.Descr));
    end;
    ACombobox.ItemWidth := w + 16;
    ACombobox.ItemHeight := 2 * cnv.TextHeight('Tg') + 6;
  finally
    cnv.Free;
  end;
end;

procedure TMainForm.UpdateLocationHistory(ALocation: String);
var
  idx: Integer;
begin
  idx := CbLocations.Items.IndexOf(ALocation);
  if idx <> -1 then
    CbLocations.Items.Delete(idx);
  CbLocations.Items.Insert(0, ALocation);
  while CbLocations.Items.Count > MAX_LOCATIONS_HISTORY do
    CbLocations.Items.Delete(Cblocations.items.Count-1);
  CbLocations.Text := ALocation;
end;

procedure TMainForm.UpdateViewportSize;
begin
  InfoViewportWidth.Caption := Format('%.2n %s', [
    CalcGeoDistance(
      MapView.GetVisibleArea.TopLeft.Lat,
      MapView.GetVisibleArea.TopLeft.Lon,
      MapView.GetVisibleArea.TopLeft.Lat,
      MapView.GetVisibleArea.BottomRight.Lon,
      DistanceUnit
    ),
    DistanceUnit_Names[DistanceUnit]
  ]);
  InfoViewportHeight.Caption := Format('%.2n %s', [
    CalcGeoDistance(
      MapView.GetVisibleArea.TopLeft.Lat,
      MapView.GetVisibleArea.TopLeft.Lon,
      MapView.GetVisibleArea.BottomRight.Lat,
      MapView.GetVisibleArea.TopLeft.Lon,
      DistanceUnit
    ),
    DistanceUnit_Names[DistanceUnit]
  ]);
end;

procedure TMainForm.WriteToIni;
var
  ini: TCustomIniFile;
  L: TStringList;
  i: Integer;
begin
  ini := TMemIniFile.Create(CalcIniName);
  try
    ini.WriteInteger('MainForm', 'Left', Left);
    ini.WriteInteger('MainForm', 'Top', Top);
    ini.WriteInteger('MainForm', 'Width', Width);
    ini.WriteInteger('MainForm', 'Height', Height);

    ini.WriteString('MapView', 'Provider', MapView.MapProvider);
    ini.WriteInteger('MapView', 'Zoom', MapView.Zoom);
    ini.WriteString('MapView', 'Center.Longitude', FloatToStr(MapView.Center.Lon, PointFormatSettings));
    ini.WriteString('MapView', 'Center.Latitude', FloatToStr(MapView.Center.Lat, PointFormatSettings));

    ini.WriteString('MapView', 'DistanceUnits', DistanceUnit_Names[DistanceUnit]);

    if HERE_AppID <> '' then
      ini.WriteString('HERE', 'APP_ID', HERE_AppID);
    if HERE_AppCode <> '' then
      ini.WriteString('HERE', 'APP_CODE', HERE_AppCode);

    if OpenWeatherMap_ApiKey <> '' then
      ini.WriteString('OpenWeatherMap', 'API_Key', OpenWeatherMap_ApiKey);

    ini.EraseSection('Locations');
    for i := 0 to CbLocations.Items.Count-1 do
      ini.WriteString('Locations', 'Item'+IntToStr(i), CbLocations.Items[i]);

  finally
    ini.Free;
  end;
end;

procedure TMainForm.ZoomTrackBarChange(Sender: TObject);
begin
  MapView.Zoom := ZoomTrackBar.Position;
  LblZoom.Caption := Format('Zoom (%d):', [ZoomTrackbar.Position]);
end;


initialization
  PointFormatSettings.DecimalSeparator := '.';

end.

