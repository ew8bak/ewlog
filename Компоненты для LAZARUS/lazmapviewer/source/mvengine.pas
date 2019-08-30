{
  (c) 2014 ti_dic
  Parts of this component are based on :
    Map Viewer Copyright (C) 2011 Maciej Kaczkowski / keit.co

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}


unit mvEngine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IntfGraphics, Controls,
  mvTypes, mvJobQueue, mvMapProvider, mvDownloadEngine, mvCache, mvDragObj;

const
  EARTH_RADIUS = 6378137;
  MIN_LATITUDE = -85.05112878;
  MAX_LATITUDE = 85.05112878;
  MIN_LONGITUDE = -180;
  MAX_LONGITUDE = 180;
  SHIFT = 2 * pi * EARTH_RADIUS / 2.0;


Type
  TDrawTileEvent = Procedure (const TileId: TTileId; X,Y: integer;
    TileImg: TLazIntfImage) of object;

  TTileIdArray = Array of TTileId;

  TDistanceUnits = (duMeters, duKilometers, duMiles);

  { TMapWindow }

  TMapWindow = Record
    MapProvider: TMapProvider;
    X: Int64;
    Y: Int64;
    Center: TRealPoint;
    Zoom: integer;
    Height: integer;
    Width: integer;
  end;


  { TMapViewerEngine }

  TMapViewerEngine = Class(TComponent)
    private
      DragObj : TDragObj;
      Cache : TPictureCache;
      FActive: boolean;
      FDownloadEngine: TMvCustomDownloadEngine;
      FDrawTitleInGuiThread: boolean;
      FOnCenterMove: TNotifyEvent;
      FOnChange: TNotifyEvent;
      FOnDrawTile: TDrawTileEvent;
      FOnZoomChange: TNotifyEvent;
      lstProvider : TStringList;
      Queue : TJobQueue;
      MapWin : TMapWindow;
      function GetCacheOnDisk: Boolean;
      function GetCachePath: String;
      function GetCenter: TRealPoint;
      function GetHeight: integer;
      function GetMapProvider: String;
      function GetUseThreads: Boolean;
      function GetWidth: integer;
      function GetZoom: integer;
      function IsValidTile(const aWin: TMapWindow; const aTile: TTIleId): boolean;
      procedure MoveMapCenter(Sender: TDragObj);
      procedure SetActive(AValue: boolean);
      procedure SetCacheOnDisk(AValue: Boolean);
      procedure SetCachePath(AValue: String);
      procedure SetCenter(aCenter: TRealPoint);
      procedure SetDownloadEngine(AValue: TMvCustomDownloadEngine);
      procedure SetHeight(AValue: integer);
      procedure SetMapProvider(AValue: String);
      procedure SetUseThreads(AValue: Boolean);
      procedure SetWidth(AValue: integer);
      procedure SetZoom(AValue: integer);
      function LonLatToMapWin(const aWin: TMapWindow; aPt: TRealPoint): TPoint;
      Function MapWinToLonLat(const aWin: TMapWindow; aPt : TPoint) : TRealPoint;
      Procedure CalculateWin(var aWin: TMapWindow);
      Procedure Redraw(const aWin: TmapWindow);
      function CalculateVisibleTiles(const aWin: TMapWindow) : TArea;
      function IsCurrentWin(const aWin: TMapWindow) : boolean;
    protected
      procedure ConstraintZoom(var aWin: TMapWindow);
      function GetTileName(const Id: TTileId): String;
      procedure evDownload(Data: TObject; Job: TJob);
      procedure TileDownloaded(Data: PtrInt);
      Procedure DrawTile(const TileId: TTileId; X,Y: integer; TileImg: TLazIntfImage);
      Procedure DoDrag(Sender: TDragObj);
    public
      constructor Create(aOwner: TComponent); override;
      destructor Destroy; override;

      function AddMapProvider(OpeName: String; Url: String;
        MinZoom, MaxZoom, NbSvr: integer; GetSvrStr: TGetSvrStr = nil;
        GetXStr: TGetValStr = nil; GetYStr: TGetValStr = nil;
        GetZStr: TGetValStr = nil): TMapProvider;
      procedure CancelCurrentDrawing;
      procedure ClearMapProviders;
      procedure GetMapProviders(AList: TStrings);
      function LonLatToScreen(aPt: TRealPoint): TPoint;
      function LonLatToWorldScreen(aPt: TRealPoint): TPoint;
      function ReadProvidersFromXML(AFileName: String; out AMsg: String): Boolean;
      procedure Redraw;
      Procedure RegisterProviders;
      function ScreenToLonLat(aPt: TPoint): TRealPoint;
      procedure SetSize(aWidth, aHeight: integer);
      function WorldScreenToLonLat(aPt: TPoint): TRealPoint;
      procedure WriteProvidersToXML(AFileName: String);

      procedure DblClick(Sender: TObject);
      procedure MouseDown(Sender: TObject; Button: TMouseButton;
        {%H-}Shift: TShiftState; X, Y: Integer);
      procedure MouseMove(Sender: TObject; {%H-}Shift: TShiftState;
        X, Y: Integer);
      procedure MouseUp(Sender: TObject; Button: TMouseButton;
        {%H-}Shift: TShiftState; X, Y: Integer);
      procedure MouseWheel(Sender: TObject; {%H-}Shift: TShiftState;
        WheelDelta: Integer; {%H-}MousePos: TPoint; var Handled: Boolean);
      procedure ZoomOnArea(const aArea: TRealArea);

      property Center: TRealPoint read GetCenter write SetCenter;

    published
      property Active: Boolean read FActive write SetActive default false;
      property CacheOnDisk: Boolean read GetCacheOnDisk write SetCacheOnDisk;
      property CachePath: String read GetCachePath write SetCachePath;
      property DownloadEngine: TMvCustomDownloadEngine
        read FDownloadEngine write SetDownloadEngine;
      property DrawTitleInGuiThread: boolean
        read FDrawTitleInGuiThread write FDrawTitleInGuiThread;
      property Height: integer read GetHeight write SetHeight;
      property JobQueue: TJobQueue read Queue;
      property MapProvider: String read GetMapProvider write SetMapProvider;
      property UseThreads: Boolean read GetUseThreads write SetUseThreads;
      property Width: integer read GetWidth write SetWidth;
      property Zoom: integer read GetZoom write SetZoom;

      property OnCenterMove: TNotifyEvent read FOnCenterMove write FOnCenterMove;
      property OnChange: TNotifyEvent Read FOnChange write FOnchange; //called when visiable area change
      property OnDrawTile: TDrawTileEvent read FOnDrawTile write FOnDrawTile;
      property OnZoomChange: TNotifyEvent read FOnZoomChange write FOnZoomChange;
  end;

function CalcGeoDistance(Lat1, Lon1, Lat2, Lon2: double;
  AUnits: TDistanceUnits = duKilometers): double;

function GPSToDMS(Angle: Double): string;

function LatToStr(ALatitude: Double; DMS: Boolean): String;
function LonToStr(ALongitude: Double; DMS: Boolean): String;
function TryStrToGps(const AValue: String; out ADeg: Double): Boolean;

procedure SplitGps(AValue: Double; out ADegs, AMins, ASecs: Double);

var
  HERE_AppID: String = '';
  HERE_AppCode: String = '';
  OpenWeatherMap_ApiKey: String = '';


implementation

uses
  Math, Forms, laz2_xmlread, laz2_xmlwrite, laz2_dom,
  mvJobs, mvGpsObj;

type

  { TLaunchDownloadJob }

  TLaunchDownloadJob = class(TJob)
  private
    AllRun: boolean;
    Win: TMapWindow;
    Engine: TMapViewerEngine;
    FRunning: boolean;
    FTiles: TTileIdArray;
    FStates: Array of integer;
  protected
    function pGetTask: integer; override;
    procedure pTaskStarted(aTask: integer); override;
    procedure pTaskEnded(aTask: integer; aExcept: Exception); override;
  public
    procedure ExecuteTask(aTask: integer; FromWaiting: boolean); override;
    function Running: boolean; override;
  public
    constructor Create(Eng: TMapViewerEngine; const Tiles: TTileIdArray;
      const aWin: TMapWindow);
  end;


  { TEnvTile }

  TEnvTile = Class
  private
    Tile: TTileId;
    Win: TMapWindow;
  public
    constructor Create(const aTile: TTileId; const aWin: TMapWindow);
  end;


  { TMemObj }

  TMemObj = Class
  private
    FWin: TMapWindow;
  public
    constructor Create(const aWin: TMapWindow);
  end;

  constructor TMemObj.Create(const aWin: TMapWindow);
  begin
    FWin := aWin;
  end;


{ TLaunchDownloadJob }

function TLaunchDownloadJob.pGetTask: integer;
var
  i: integer;
begin
  if not AllRun and not Cancelled then
  begin
    for i:=Low(FStates) to High(FStates) do
      if FStates[i] = 0 then
      begin
        Result := i + 1;
        Exit;
      end;
    AllRun := True;
  end;
  Result := ALL_TASK_COMPLETED;
  for i := Low(FStates) to High(FStates) do
    if FStates[i] = 1 then
    begin
      Result := NO_MORE_TASK;
      Exit;
    end;
end;

procedure TLaunchDownloadJob.pTaskStarted(aTask: integer);
begin
  FRunning := True;
  FStates[aTask-1] := 1;
end;

procedure TLaunchDownloadJob.pTaskEnded(aTask: integer; aExcept: Exception);
begin
  if Assigned(aExcept) then
    FStates[aTask - 1] := 3
  Else
    FStates[aTask - 1] := 2;
end;

procedure TLaunchDownloadJob.ExecuteTask(aTask: integer; FromWaiting: boolean);
var
  iTile: integer;
begin
  iTile := aTask - 1;
  Queue.AddUniqueJob(TEventJob.Create
    (
      @Engine.evDownload,
      TEnvTile.Create(FTiles[iTile], Win),
      false,                                    // owns data
      Engine.GetTileName(FTiles[iTile])
    ),
    Launcher
  );
end;

function TLaunchDownloadJob.Running: boolean;
begin
  Result := FRunning;
end;

constructor TLaunchDownloadJob.Create(Eng: TMapViewerEngine;
  const Tiles: TTileIdArray; const aWin: TMapWindow);
var
  i: integer;
begin
  Engine := Eng;
  SetLength(FTiles, Length(Tiles));
  For i:=Low(FTiles) to High(FTiles) do
    FTiles[i] := Tiles[i];
  SetLength(FStates, Length(Tiles));
  AllRun := false;
  Name := 'LaunchDownload';
  Win := aWin;
end;


{ TEnvTile }

constructor TEnvTile.Create(const aTile: TTileId; const aWin: TMapWindow);
begin
  Tile := aTile;
  Win := aWin;
end;


{ TMapViewerEngine }

constructor TMapViewerEngine.Create(aOwner: TComponent);
begin
  DrawTitleInGuiThread := true;
  DragObj := TDragObj.Create;
  DragObj.OnDrag := @DoDrag;
  Cache := TPictureCache.Create(self);
  lstProvider := TStringList.Create;
  RegisterProviders;
  Queue := TJobQueue.Create(8);
  Queue.OnIdle := @Cache.CheckCacheSize;

  inherited Create(aOwner);

  ConstraintZoom(MapWin);
  CalculateWin(mapWin);
end;

destructor TMapViewerEngine.Destroy;
begin
  ClearMapProviders;
  FreeAndNil(DragObj);
  FreeAndNil(lstProvider);
  FreeAndNil(Cache);
  FreeAndNil(Queue);
  inherited Destroy;
end;

function TMapViewerEngine.AddMapProvider(OpeName: String; Url: String;
  MinZoom, MaxZoom, NbSvr: integer; GetSvrStr: TGetSvrStr; GetXStr: TGetValStr;
  GetYStr: TGetValStr; GetZStr: TGetValStr): TMapProvider;
var
  idx :integer;
Begin
  idx := lstProvider.IndexOf(OpeName);
  if idx = -1 then
  begin
    Result := TMapProvider.Create(OpeName);
    lstProvider.AddObject(OpeName, Result);
  end
  else
    Result := TMapProvider(lstProvider.Objects[idx]);
  Result.AddUrl(Url, NbSvr, MinZoom, MaxZoom, GetSvrStr, GetXStr, GetYStr, GetZStr);
end;

function TMapViewerEngine.CalculateVisibleTiles(const aWin: TMapWindow): TArea;
var
  MaxX, MaxY, startX, startY: int64;
begin
  MaxX := (Int64(aWin.Width) div TILE_SIZE) + 1;
  MaxY := (Int64(aWin.Height) div TILE_SIZE) + 1;
  startX := -aWin.X div TILE_SIZE;
  startY := -aWin.Y div TILE_SIZE;
  Result.Left := startX;
  Result.Right := startX + MaxX;
  Result.Top := startY;
  Result.Bottom := startY + MaxY;
end;

procedure TMapViewerEngine.CalculateWin(var aWin: TMapWindow);
var
  mx, my: Extended;
  res: Extended;
  px, py: Int64;
begin
  mx := aWin.Center.Lon * SHIFT / 180.0;
  my := ln( tan((90 - aWin.Center.Lat) * pi / 360.0 )) / (pi / 180.0);
  my := my * SHIFT / 180.0;

  res := (2 * pi * EARTH_RADIUS) / (TILE_SIZE * (1 shl aWin.Zoom));
  px := Round((mx + shift) / res);
  py := Round((my + shift) / res);

  aWin.X := aWin.Width div 2 - px;
  aWin.Y := aWin.Height div 2 - py;
end;

procedure TMapViewerEngine.CancelCurrentDrawing;
var
  Jobs: TJobArray;
begin
  Jobs := Queue.CancelAllJob(self);
  Queue.WaitForTerminate(Jobs);
end;

procedure TMapViewerEngine.ClearMapProviders;
var
  i: Integer;
begin
  for i:=0 to lstProvider.Count-1 do
    TObject(lstProvider.Objects[i]).Free;
  lstProvider.Clear;
end;

procedure TMapViewerEngine.ConstraintZoom(var aWin: TMapWindow);
var
  zMin, zMax: integer;
begin
  if Assigned(aWin.MapProvider) then
  begin
    aWin.MapProvider.GetZoomInfos(zMin, zMax);
    if aWin.Zoom < zMin then
      aWin.Zoom := zMin;
    if aWin.Zoom > zMax then
      aWin.Zoom := zMax;
  end;
end;

procedure TMapViewerEngine.DblClick(Sender: TObject);
var
  pt: TPoint;
begin
  pt.X := DragObj.MouseX;
  pt.Y := DragObj.MouseY;
  SetCenter(ScreenToLonLat(pt));
end;

procedure TMapViewerEngine.DoDrag(Sender: TDragObj);
begin
  if Sender.DragSrc = self then
    MoveMapCenter(Sender);
end;

procedure TMapViewerEngine.DrawTile(const TileId: TTileId; X, Y: integer;
  TileImg: TLazIntfImage);
begin
  if Assigned(FOnDrawTile) then
    FOnDrawTile(TileId, X, Y, TileImg);
end;

procedure TMapViewerEngine.evDownload(Data: TObject; Job: TJob);
var
  Id: TTileId;
  Url: String;
  Env: TEnvTile;
  MapO: TMapProvider;
  lStream: TMemoryStream;
begin
  Env := TEnvTile(Data);
  Id := Env.Tile;
  MapO := Env.Win.MapProvider;
  if Assigned(MapO) then
  begin
    if not Cache.InCache(MapO, Id) then
    begin
      if Assigned(FDownloadEngine) then
      begin
        Url := MapO.GetUrlForTile(Id);
        if Url <> '' then
        begin
          lStream := TMemoryStream.Create;
          try
            try
              FDownloadEngine.DownloadFile(Url, lStream);
              Cache.Add(MapO, Id, lStream);
            except
            end;
          finally
            FreeAndNil(lStream);
          end;
        end;
      end;
    end;
  end;

  if Job.Cancelled then
    Exit;

  if DrawTitleInGuiThread then
    Queue.QueueAsyncCall(@TileDownloaded, PtrInt(Env))
  else
    TileDownloaded(PtrInt(Env));
end;

function TMapViewerEngine.GetCacheOnDisk: Boolean;
begin
  Result := Cache.UseDisk;
end;

function TMapViewerEngine.GetCachePath: String;
begin
  Result := Cache.BasePath;
end;

function TMapViewerEngine.GetCenter: TRealPoint;
begin
  Result := MapWin.Center;
end;

function TMapViewerEngine.GetHeight: integer;
begin
  Result := MapWin.Height
end;

function TMapViewerEngine.GetMapProvider: String;
begin
  if Assigned(MapWin.MapProvider) then
    Result := MapWin.MapProvider.Name
  else
    Result := '';
end;

procedure TMapViewerEngine.GetMapProviders(AList: TStrings);
begin
  AList.Assign(lstProvider);
end;

function TMapViewerEngine.GetTileName(const Id: TTileId): String;
begin
  Result := IntToStr(Id.X) + '.' + IntToStr(Id.Y) + '.' + IntToStr(Id.Z);
end;

function TMapViewerEngine.GetUseThreads: Boolean;
begin
  Result := Queue.UseThreads;
end;

function TMapViewerEngine.GetWidth: integer;
begin
  Result := MapWin.Width;
end;

function TMapViewerEngine.GetZoom: integer;
begin
  Result := MapWin.Zoom;
end;

function TMapViewerEngine.IsCurrentWin(const aWin: TMapWindow): boolean;
begin
  Result := (aWin.Zoom = MapWin.Zoom) and
            (aWin.Center.Lat = MapWin.Center.Lat) and
            (aWin.Center.Lon = MapWin.Center.Lon) and
            (aWin.Width = MapWin.Width) and
            (aWin.Height = MapWin.Height);
end;

function TMapViewerEngine.IsValidTile(const aWin: TMapWindow;
  const aTile: TTileId): boolean;
var
  tiles: int64;
begin
  tiles := 1 shl aWin.Zoom;
  Result := (aTile.X >= 0) and (aTile.X <= tiles-1) and
            (aTile.Y >= 0) and (aTile.Y <= tiles-1);
end;

function TMapViewerEngine.LonLatToMapWin(const aWin: TMapWindow;
  aPt: TRealPoint): TPoint;
var
  tiles: Int64;
  circumference: Int64;
  res: Extended;
  tmpX,tmpY : Double;
begin
  tiles := 1 shl aWin.Zoom;
  circumference := tiles * TILE_SIZE;
  tmpX := ((aPt.Lon+ 180.0)*circumference)/360.0;

  res := (2 * pi * EARTH_RADIUS) / circumference;

  tmpY := -aPt.Lat;
  tmpY := ln(tan((degToRad(tmpY) + pi / 2.0) / 2)) *180 / pi;
  tmpY:= (((tmpY / 180.0) * SHIFT) + SHIFT) / res;

  tmpX := tmpX + aWin.X;
  tmpY := tmpY + aWin.Y;
  Result.X := trunc(tmpX);
  Result.Y := trunc(tmpY);
end;

function TMapViewerEngine.LonLatToScreen(aPt: TRealPoint): TPoint;
Begin
  Result := LonLatToMapWin(MapWin, aPt);
end;

function TMapViewerEngine.LonLatToWorldScreen(aPt: TRealPoint): TPoint;
begin
  Result := LonLatToScreen(aPt);
  Result.X := Result.X + MapWin.X;
  Result.Y := Result.Y + MapWin.Y;
end;

function TMapViewerEngine.MapWinToLonLat(const aWin: TMapWindow;
  aPt: TPoint): TRealPoint;
var
  tiles: Int64;
  circumference: Int64;
  lat: Extended;
  res: Extended;
  mPoint : TPoint;
begin
  tiles := 1 shl aWin.Zoom;
  circumference := tiles * TILE_SIZE;

  mPoint.X := aPt.X - aWin.X;
  mPoint.Y := aPt.Y - aWin.Y;

  if mPoint.X < 0 then
    mPoint.X := 0
  else
  if mPoint.X > circumference then
    mPoint.X := circumference;

  if mPoint.Y < 0 then
    mPoint.Y := 0
  else
  if mPoint.Y > circumference then
    mPoint.Y := circumference;

  Result.Lon := ((mPoint.X * 360.0) / circumference) - 180.0;

  res := (2 * pi * EARTH_RADIUS) / circumference;
  lat := ((mPoint.Y * res - SHIFT) / SHIFT) * 180.0;

  lat := radtodeg (2 * arctan( exp( lat * pi / 180.0)) - pi / 2.0);
  Result.Lat := -lat;

  if Result.Lat > MAX_LATITUDE then
    Result.Lat := MAX_LATITUDE
  else
  if Result.Lat < MIN_LATITUDE then
    Result.Lat := MIN_LATITUDE;

  if Result.Lon > MAX_LONGITUDE then
    Result.Lon := MAX_LONGITUDE
  else
  if Result.Lon < MIN_LONGITUDE then
    Result.Lon := MIN_LONGITUDE;
end;

procedure TMapViewerEngine.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    DragObj.MouseDown(self,X,Y);
end;

procedure TMapViewerEngine.MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  DragObj.MouseMove(X,Y);
end;

procedure TMapViewerEngine.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    DragObj.MouseUp(X,Y);
end;

procedure TMapViewerEngine.MouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var
  Val: Integer;
  nZoom: integer;
begin
  Val := 0;
  if WheelDelta > 0 then
    Val := 1;
  if WheelDelta < 0 then
    Val := -1;
  nZoom := Zoom + Val;
  if (nZoom > 0) and (nZoom < 20) then
    Zoom := nZoom;
  Handled := true;
end;

procedure TMapViewerEngine.MoveMapCenter(Sender: TDragObj);
var
  old: TMemObj;
  nCenter: TRealPoint;
  aPt: TPoint;
Begin
  if Sender.LnkObj = nil then
    Sender.LnkObj := TMemObj.Create(MapWin);
  old := TMemObj(Sender.LnkObj);
  aPt.X := old.FWin.Width DIV 2-Sender.OfsX;
  aPt.Y := old.FWin.Height DIV 2-Sender.OfsY;
  nCenter := MapWinToLonLat(old.FWin,aPt);
  SetCenter(nCenter);
end;

function TMapViewerEngine.ReadProvidersFromXML(AFileName: String;
  out AMsg: String): Boolean;

  function GetSvrStr(AName: String): TGetSvrStr;
  var
    lcName: String;
  begin
    lcName := LowerCase(AName);
    case lcName of
      'letter': Result := @GetLetterSvr;
      'yahoo': Result := @GetYahooSvr;
      else Result := nil;
    end;
  end;

  function GetValStr(AName: String): TGetValStr;
  var
    lcName: String;
  begin
    lcName := Lowercase(AName);
    case lcName of
      'quadkey': Result := @GetQuadKey;
      'yahooy': Result := @GetYahooY;
      'yahooz': Result := @GetYahooZ;
      else Result := nil;
    end;
  end;

  function GetAttrValue(ANode: TDOMNode; AttrName: String): String;
  var
    node: TDOMNode;
  begin
    Result := '';
    if ANode.HasAttributes then begin
      node := ANode.Attributes.GetNamedItem(AttrName);
      if Assigned(node) then Result := node.NodeValue;
    end;
  end;

var
  stream: TFileStream;
  doc: TXMLDocument = nil;
  node, layerNode: TDOMNode;
  providerName: String;
  url: String;
  minZoom: Integer;
  maxZoom: Integer;
  svrCount: Integer;
  s: String;
  svrProc: String;
  xProc: String;
  yProc: String;
  zProc: String;
  first: Boolean;
begin
  Result := false;
  AMsg := '';
  stream := TFileStream.Create(AFileName, fmOpenread or fmShareDenyWrite);
  try
    ReadXMLFile(doc, stream, [xrfAllowSpecialCharsInAttributeValue, xrfAllowLowerThanInAttributeValue]);
    node := doc.FindNode('map_providers');
    if node = nil then begin
      AMsg := 'No map providers in file.';
      exit;
    end;

    first := true;
    node := node.FirstChild;
    while node <> nil do begin
      providerName := GetAttrValue(node, 'name');
      layerNode := node.FirstChild;
      while layerNode <> nil do begin
        url := GetAttrValue(layerNode, 'url');
        if url = '' then
          continue;
        s := GetAttrValue(layerNode, 'minZom');
        if s = '' then minZoom := 0
          else minZoom := StrToInt(s);
        s := GetAttrValue(layerNode, 'maxZoom');
        if s = '' then maxzoom := 9
          else maxZoom := StrToInt(s);
        s := GetAttrValue(layerNode, 'serverCount');
        if s = '' then svrCount := 1
          else svrCount := StrToInt(s);
        svrProc := GetAttrValue(layerNode, 'serverProc');
        xProc := GetAttrValue(layerNode, 'xProc');
        yProc := GetAttrValue(layerNode, 'yProc');
        zProc := GetAttrValue(layerNode, 'zProc');
        layerNode := layerNode.NextSibling;
      end;
      if first then begin
        ClearMapProviders;
        first := false;
      end;
      AddMapProvider(providerName,
        url, minZoom, maxZoom, svrCount,
        GetSvrStr(svrProc), GetValStr(xProc), GetValStr(yProc), GetValStr(zProc)
      );
      node := node.NextSibling;
    end;
    Result := true;
  finally
    stream.Free;
    doc.Free;
  end;
end;

procedure TMapViewerEngine.Redraw;
begin
  Redraw(MapWin);
end;

procedure TMapViewerEngine.Redraw(const aWin: TmapWindow);
var
  TilesVis: TArea;
  x, y : Integer; //int64;
  Tiles: TTileIdArray;
  iTile: Integer;
begin
  if not(Active) then
    Exit;
  Queue.CancelAllJob(self);
  TilesVis := CalculateVisibleTiles(aWin);
  SetLength(Tiles, (TilesVis.Bottom - TilesVis.Top + 1) * (TilesVis.Right - TilesVis.Left + 1));
  iTile := Low(Tiles);
  for y := TilesVis.Top to TilesVis.Bottom do
    for X := TilesVis.Left to TilesVis.Right do
    begin
      Tiles[iTile].X := X;
      Tiles[iTile].Y := Y;
      Tiles[iTile].Z := aWin.Zoom;
      if IsValidTile(aWin, Tiles[iTile]) then
        iTile += 1;
    end;
  SetLength(Tiles, iTile);
  if Length(Tiles) > 0 then
    Queue.AddJob(TLaunchDownloadJob.Create(self, Tiles, aWin), self);
end;

procedure TMapViewerEngine.RegisterProviders;
var
  HERE1, HERE2: String;
begin
//  AddMapProvider('Aucun','',0,30, 0);  ???

  AddMapProvider('Google Normal',
    'http://mt%serv%.google.com/vt/lyrs=m@145&v=w2.104&x=%x%&y=%y%&z=%z%',
    0, 19, 4, nil);
  AddMapProvider('Google Hybrid',
    'http://mt%serv%.google.com/vt/lyrs=h@145&v=w2.104&x=%x%&y=%y%&z=%z%',
    0, 19, 4, nil);
  AddMapProvider('Google Physical',
    'http://mt%serv%.google.com/vt/lyrs=t@145&v=w2.104&x=%x%&y=%y%&z=%z%',
    0, 19, 4, nil);

  {
  AddMapProvider('Google Hybrid','http://khm%d.google.com/kh/v=82&x=%x%&y=%y%&z=%z%&s=Ga',4);
  AddMapProvider('Google Hybrid','http://mt%d.google.com/vt/lyrs=h@145&v=w2.104&x=%d&y=%d&z=%z%',4);
  AddMapProvider('Google physical','http://mt%d.google.com/vt/lyrs=t@145&v=w2.104&x=%d&y=%d&z=%z%',4);
  AddMapProvider('Google Physical Hybrid','http://mt%d.google.com/vt/lyrs=t@145&v=w2.104&x=%x%&y=%y%&z=%z%',4);
  AddMapProvider('Google Physical Hybrid','http://mt%d.google.com/vt/lyrs=h@145&v=w2.104&x=%x%&y=%y%&z=%z%',4);
  }
  //AddMapProvider('OpenStreetMap Osmarender','http://%serv%.tah.openstreetmap.org/Tiles/tile/%z%/%x%/%y%.png',0,20,3, @getLetterSvr); // [Char(Ord('a')+Random(3)), Z, X, Y]));
  //AddMapProvider('Yahoo Normal','http://maps%serv%.yimg.com/hx/tl?b=1&v=4.3&.intl=en&x=%x%&y=%y%d&z=%d&r=1'        , 0,20,3,@GetYahooSvr, nil, @getYahooY, @GetYahooZ); //(Z+1]));
  //AddMapProvider('Yahoo Satellite','http://maps%serv%.yimg.com/ae/ximg?v=1.9&t=a&s=256&.intl=en&x=%d&y=%d&z=%d&r=1', 0,20,3,@GetYahooSvr, nil, @getYahooY, @GetYahooZ); //[Random(3)+1, X, YahooY(Y), Z+1]));
  //AddMapProvider('Yahoo Hybrid','http://maps%serv%.yimg.com/ae/ximg?v=1.9&t=a&s=256&.intl=en&x=%x%&y=%y%&z=%z%&r=1', 0,20,3,@GetYahooSvr, nil, @getYahooY, @GetYahooZ); //[Random(3)+1, X, YahooY(Y), Z+1]));
  //AddMapProvider('Yahoo Hybrid','http://maps%serv%.yimg.com/hx/tl?b=1&v=4.3&t=h&.intl=en&x=%x%&y=%y%&z=%z%&r=1'    , 0,20,3,@GetYahooSvr, nil, @getYahooY, @GetYahooZ); //[Random(3)+1, X, YahooY(Y), Z+1]));

  // opeName, Url, MinZoom, MaxZoom, NbSvr, GetSvrStr, GetXStr, GetYStr, GetZStr
  MapWin.MapProvider := AddMapProvider('OpenStreetMap Mapnik',
    'http://%serv%.tile.openstreetmap.org/%z%/%x%/%y%.png',
    0, 19, 3, @GetLetterSvr);
  AddMapProvider('Open Cycle Map',
    'http://%serv%.tile.opencyclemap.org/cycle/%z%/%x%/%y%.png',
    0, 18, 3, @getLetterSvr);
  AddMapProvider('Open Topo Map',
    'http://%serv%.tile.opentopomap.org/%z%/%x%/%y%.png',
    0, 19, 3, @getLetterSvr);
  AddMapProvider('Virtual Earth Bing',
    'http://ecn.t%serv%.tiles.virtualearth.net/tiles/r%x%?g=671&mkt=en-us&lbl=l1&stl=h&shading=hill',
    1, 19, 8, nil, @GetQuadKey);
  AddMapProvider('Virtual Earth Road',
    'http://r%serv%.ortho.tiles.virtualearth.net/tiles/r%x%.png?g=72&shading=hill',
    1, 19, 4, nil, @GetQuadKey);
  AddMapProvider('Virtual Earth Aerial',
    'http://a%serv%.ortho.tiles.virtualearth.net/tiles/a%x%.jpg?g=72&shading=hill',
    1, 19, 4, nil, @GetQuadKey);
  AddMapProvider('Virtual Earth Hybrid',
    'http://h%serv%.ortho.tiles.virtualearth.net/tiles/h%x%.jpg?g=72&shading=hill',
    1, 19, 4, nil, @GetQuadKey);

  if (HERE_AppID <> '') and (HERE_AppCode <> '') then begin
    // Registration required to access HERE maps:
    //   https://developer.here.com/?create=Freemium-Basic&keepState=true&step=account
    // Store the APP_ID and APP_CODE obtained after registration in the
    // ini file of the demo under key [HERE] as items APP_ID and APP_CODE and
    // restart the demo.
    HERE1 := 'http://%serv%.base.maps.api.here.com/maptile/2.1/maptile/newest/';
    HERE2 := '/%z%/%x%/%y%/256/png8?app_id=' + HERE_AppID + '&app_code=' + HERE_AppCode;
    AddMapProvider('Here Maps', HERE1 + 'normal.day' + HERE2,
      1, 19, 4, @GetYahooSvr);
    AddMapProvider('Here Maps Grey', HERE1 + 'normal.day.grey' + HERE2,
      1, 19, 4, @GetYahooSvr);
    AddMapProvider('Here Maps Reduced', HERE1 + 'reduced.day' + HERE2,
      1, 19, 4, @GetYahooSvr);
    AddMapProvider('Here Maps Transit', HERE1 + 'normal.day.transit' + HERE2,
      1, 19, 4, @GetYahooSvr);
    AddMapProvider('Here POI Maps', HERE1 + 'normal.day' + HERE2 + '&pois',
      1, 19, 4, @GetYahooSvr);
    AddMapProvider('Here Pedestrian Maps', HERE1 + 'pedestrian.day' + HERE2,
      1, 19, 4, @GetYahooSvr);
    AddMapProvider('Here DreamWorks Maps', HERE1 + 'normal.day' + HERE2 + '&style=dreamworks',
      1, 19, 4, @GetYahooSvr);
  end;

  if (OpenWeatherMap_ApiKey <> '') then begin
    // Registration required to access OpenWeatherMaps
    //   https://home.openweathermap.org/users/sign_up
    // Store the API key found on the website in the ini file of the demo under
    // key [OpenWeatherMap] and API_Key and restart the demo
    AddMapProvider('OpenWeatherMap Clouds',
      'https://tile.openweathermap.org/map/clouds_new/%z%/%x%/%y%.png?appid=' + OpenWeatherMap_ApiKey,
      1, 19, 1, nil);
    AddMapProvider('OpenWeatherMap Precipitation',
      'https://tile.openweathermap.org/map/precipitation_new/%z%/%x%/%y%.png?appid=' + OpenWeatherMap_ApiKey,
      1, 19, 1, nil);
    AddMapProvider('OpenWeatherMap Pressure',
      'https://tile.openweathermap.org/map/pressure_new/%z%/%x%/%y%.png?appid=' + OpenWeatherMap_ApiKey,
      1, 19, 1, nil);
    AddMapProvider('OpenWeatherMap Temperature',
      'https://tile.openweathermap.org/map/temp_new/%z%/%x%/%y%.png?appid=' + OpenWeatherMap_ApiKey,
      1, 19, 1, nil);
    AddMapProvider('OpenWeatherMap Wind',
      'https://tile.openweathermap.org/map/wind_new/%z%/%x%/%y%.png?appid=' + OpenWeatherMap_ApiKey,
      1, 19, 1, nil);
  end;

  { The Ovi Maps (former Nokia maps) are no longer available.

  AddMapProvider('Ovi Normal',
    'http://%serv%.maptile.maps.svc.ovi.com/maptiler/v2/maptile/newest/normal.day/%z%/%x%/%y%/256/png8',
    0, 20, 5, @GetLetterSvr);
  AddMapProvider('Ovi Satellite',
    'http://%serv%.maptile.maps.svc.ovi.com/maptiler/v2/maptile/newest/satellite.day/%z%/%x%/%y%/256/png8',
    0, 20, 5, @GetLetterSvr);
  AddMapProvider('Ovi Hybrid',
    'http://%serv%.maptile.maps.svc.ovi.com/maptiler/v2/maptile/newest/hybrid.day/%z%/%x%/%y%/256/png8',
    0, 20, 5, @GetLetterSvr);
  AddMapProvider('Ovi Physical',
    'http://%serv%.maptile.maps.svc.ovi.com/maptiler/v2/maptile/newest/terrain.day/%z%/%x%/%y%/256/png8',
    0, 20, 5, @GetLetterSvr);
  }

  {
  AddMapProvider('Yahoo Normal','http://maps%serv%.yimg.com/hx/tl?b=1&v=4.3&.intl=en&x=%x%&y=%y%d&z=%d&r=1'        , 0,20,3,@GetYahooSvr, nil, @getYahooY, @GetYahooZ); //(Z+1]));
  AddMapProvider('Yahoo Satellite','http://maps%serv%.yimg.com/ae/ximg?v=1.9&t=a&s=256&.intl=en&x=%d&y=%d&z=%d&r=1', 0,20,3,@GetYahooSvr, nil, @getYahooY, @GetYahooZ); //[Random(3)+1, X, YahooY(Y), Z+1]));
  AddMapProvider('Yahoo Hybrid','http://maps%serv%.yimg.com/ae/ximg?v=1.9&t=a&s=256&.intl=en&x=%x%&y=%y%&z=%z%&r=1', 0,20,3,@GetYahooSvr, nil, @getYahooY, @GetYahooZ); //[Random(3)+1, X, YahooY(Y), Z+1]));
  AddMapProvider('Yahoo Hybrid','http://maps%serv%.yimg.com/hx/tl?b=1&v=4.3&t=h&.intl=en&x=%x%&y=%y%&z=%z%&r=1'    , 0,20,3,@GetYahooSvr, nil, @getYahooY, @GetYahooZ); //[Random(3)+1, X, YahooY(Y), Z+1]));
  }
end;

function TMapViewerEngine.ScreenToLonLat(aPt: TPoint): TRealPoint;
begin
  Result := MapWinToLonLat(MapWin, aPt);
end;

procedure TMapViewerEngine.SetActive(AValue: boolean);
begin
  if FActive = AValue then Exit;
  FActive := AValue;
  if not(FActive) then
    Queue.CancelAllJob(self)
  else begin
    if Cache.UseDisk then ForceDirectories(Cache.BasePath);
    Redraw(MapWin);
  end;
end;

procedure TMapViewerEngine.SetCacheOnDisk(AValue: Boolean);
begin
  if Cache.UseDisk = AValue then Exit;
  Cache.UseDisk := AValue;
end;

procedure TMapViewerEngine.SetCachePath(AValue: String);
begin
  Cache.BasePath := aValue;
end;

procedure TMapViewerEngine.SetCenter(aCenter: TRealPoint);
begin
  if (MapWin.Center.Lon <> aCenter.Lon) and (MapWin.Center.Lat <> aCenter.Lat) then
  begin
    Mapwin.Center := aCenter;
    CalculateWin(MapWin);
    Redraw(MapWin);
    if assigned(OnCenterMove) then
      OnCenterMove(Self);
    if Assigned(OnChange) then
      OnChange(Self);
  end;
end;

procedure TMapViewerEngine.SetDownloadEngine(AValue: TMvCustomDownloadEngine);
begin
  if FDownloadEngine = AValue then Exit;
  FDownloadEngine := AValue;
  if Assigned(FDownloadEngine) then
    FDownloadEngine.FreeNotification(self);
end;

procedure TMapViewerEngine.SetHeight(AValue: integer);
begin
  if MapWin.Height = AValue then Exit;
  MapWin.Height := AValue;
  CalculateWin(MapWin);
  Redraw(MapWin);
end;

procedure TMapViewerEngine.SetMapProvider(AValue: String);
var
  idx: integer;
begin
  idx := lstProvider.IndexOf(aValue);
  if not ((aValue = '') or (idx <> -1)) then
    raise Exception.Create('Unknow Provider: ' + aValue);
  if Assigned(MapWin.MapProvider) and (MapWin.MapProvider.Name = AValue) then Exit;
  if idx <> -1 then
  begin
    MapWin.MapProvider := TMapProvider(lstProvider.Objects[idx]);
    ConstraintZoom(MapWin);
  end
  else
    MapWin.MapProvider := nil;
  if Assigned(MapWin.MapProvider) then
    Redraw(MapWin);
end;

procedure TMapViewerEngine.SetSize(aWidth, aHeight: integer);
begin
  if (MapWin.Width = aWidth) and (MapWin.Height = aHeight) then Exit;
  CancelCurrentDrawing;
  MapWin.Width := aWidth;
  MapWin.Height := aHeight;
  CalculateWin(MapWin);
  Redraw(MapWin);
  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TMapViewerEngine.SetUseThreads(AValue: Boolean);
begin
  if Queue.UseThreads = AValue then Exit;
  Queue.UseThreads := AValue;
  Cache.UseThreads := AValue;
end;

procedure TMapViewerEngine.SetWidth(AValue: integer);
begin
  if MapWin.Width = AValue then Exit;
  MapWin.Width := AValue;
  CalculateWin(MapWin);
  Redraw(MapWin);
end;

procedure TMapViewerEngine.SetZoom(AValue: integer);
begin
  if MapWin.Zoom = AValue then Exit;
  MapWin.Zoom := AValue;
  ConstraintZoom(MapWin);
  CalculateWin(MapWin);
  Redraw(MapWin);
  if Assigned(OnZoomChange) then
    OnZoomChange(Self);
  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TMapViewerEngine.TileDownloaded(Data: PtrInt);
var
  EnvTile: TEnvTile;
  img: TLazIntfImage;
  X, Y: integer;
begin
  EnvTile := TEnvTile(Data);
  try
    if IsCurrentWin(EnvTile.Win)then
    begin
       Cache.GetFromCache(EnvTile.Win.MapProvider, EnvTile.Tile, img);
       X := EnvTile.Win.X + EnvTile.Tile.X * TILE_SIZE; // begin of X
       Y := EnvTile.Win.Y + EnvTile.Tile.Y * TILE_SIZE; // begin of X
       DrawTile(EnvTile.Tile, X, Y, img);
    end;
  finally
    FreeAndNil(EnvTile);
  end;
end;

function TMapViewerEngine.WorldScreenToLonLat(aPt: TPoint): TRealPoint;
begin
  aPt.X := aPt.X - MapWin.X;
  aPt.Y := aPt.Y - MapWin.Y;
  Result := ScreenToLonLat(aPt);
end;

procedure TMapViewerEngine.WriteProvidersToXML(AFileName: String);
var
  doc: TXMLDocument;
  root: TDOMNode;
  i: Integer;
  prov: TMapProvider;
begin
  doc := TXMLDocument.Create;
  try
    root := doc.CreateElement('map_providers');
    doc.AppendChild(root);
    for i := 0 to lstProvider.Count - 1 do begin
      prov := TMapProvider(lstProvider.Objects[i]);
      prov.ToXML(doc, root);
    end;
    WriteXMLFile(doc, AFileName);
  finally
    doc.Free;
  end;
end;

procedure TMapViewerEngine.ZoomOnArea(const aArea: TRealArea);
var
  tmpWin: TMapWindow;
  visArea: TRealArea;
  TopLeft, BottomRight: TPoint;
begin
  tmpWin := MapWin;
  tmpWin.Center.Lon := (aArea.TopLeft.Lon + aArea.BottomRight.Lon) / 2;
  tmpWin.Center.Lat := (aArea.TopLeft.Lat + aArea.BottomRight.Lat) / 2;
  tmpWin.Zoom := 18;
  TopLeft.X := 0;
  TopLeft.Y := 0;
  BottomRight.X := tmpWin.Width;
  BottomRight.Y := tmpWin.Height;
  Repeat
    CalculateWin(tmpWin);
    visArea.TopLeft := MapWinToLonLat(tmpWin, TopLeft);
    visArea.BottomRight := MapWinToLonLat(tmpWin, BottomRight);
    if AreaInsideArea(aArea, visArea) then
      break;
    dec(tmpWin.Zoom);
  until (tmpWin.Zoom = 2);
  MapWin := tmpWin;
  Redraw(MapWin);
end;


//------------------------------------------------------------------------------

procedure SplitGps(AValue: Double; out ADegs, AMins: Double);
begin
  AValue := abs(AValue);
  AMins := frac(AValue) * 60;
  ADegs := trunc(AValue);
end;

procedure SplitGps(AValue: Double; out ADegs, AMins, ASecs: Double);
begin
  SplitGps(AValue, ADegs, AMins);
  ASecs := frac(AMins) * 60;
  AMins := trunc(AMins);
end;

function GPSToDMS(Angle: Double): string;
var
  deg, min, sec: Double;
begin
  SplitGPS(Angle, deg, min, sec);
  Result := Format('%.0f° %.0f'' %.1f"', [deg, min, sec]);
end;

function LatToStr(ALatitude: Double; DMS: Boolean): String;
begin
  if DMS then
    Result := GPSToDMS(abs(ALatitude))
  else
    Result := Format('%.6f°',[abs(ALatitude)]);
  if ALatitude > 0 then
    Result := Result + ' N'
  else
  if ALatitude < 0 then
    Result := Result + 'E';
end;

function LonToStr(ALongitude: Double; DMS: Boolean): String;
begin
  if DMS then
    Result := GPSToDMS(abs(ALongitude))
  else
    Result := Format('%.6f°', [abs(ALongitude)]);
  if ALongitude > 0 then
    Result := Result + ' E'
  else if ALongitude < 0 then
    Result := Result + ' W';
end;

{ Combines up to three parts of a GPS coordinate string (degrees, minutes, seconds)
  to a floating-point degree value. The parts are separated by non-numeric
  characters:

  three parts ---> d m s ---> d and m must be integer, s can be float
  two parts   ---> d m   ---> d must be integer, s can be float
  one part    ---> d     ---> d can be float

  Each part can exhibit a unit identifier, such as °, ', or ". BUT: they are
  ignored. This means that an input string 50°30" results in the output value 50.5
  although the second part is marked as seconds, not minutes! 
  
  Hemisphere suffixes ('N', 'S', 'E', 'W') are supported at the end of the input string.
}
function TryStrToGps(const AValue: String; out ADeg: Double): Boolean;
const
  NUMERIC_CHARS = ['0'..'9', '.', ',', '-', '+'];
var
  mins, secs: Double;
  i, j, len: Integer;
  n: Integer;
  s: String;
  res: Integer;
  sgn: Double;
begin
  Result := false;

  ADeg := NaN;
  mins := 0;
  secs := 0;

  if AValue = '' then
    exit;

  len := Length(AValue);
  i := len;
  while (i >= 1) and (AValue[i] = ' ') do dec(i);
  sgn := 1.0;
  if (AValue[i] in ['S', 's', 'W', 'w']) then sgn := -1;

  // skip leading non-numeric characters
  i := 1;
  while (i <= len) and not (AValue[i] in NUMERIC_CHARS) do
    inc(i);

  // extract first value: degrees
  SetLength(s, len);
  j := 1;
  n := 0;
  while (i <= len) and (AValue[i] in NUMERIC_CHARS) do begin
    if AValue[i] = ',' then s[j] := '.' else s[j] := AValue[i];
    inc(i);
    inc(j);
    inc(n);
  end;
  if n > 0 then begin
    SetLength(s, n);
    val(s, ADeg, res);
    if res <> 0 then
      exit;
  end;

  // skip non-numeric characters between degrees and minutes
  while (i <= len) and not (AValue[i] in NUMERIC_CHARS) do
    inc(i);

  // extract second value: minutes
  SetLength(s, len);
  j := 1;
  n := 0;
  while (i <= len) and (AValue[i] in NUMERIC_CHARS) do begin
    if AValue[i] = ',' then s[j] := '.' else s[j] := AValue[i];
    inc(i);
    inc(j);
    inc(n);
  end;
  if n > 0 then begin
    SetLength(s, n);
    val(s, mins, res);
    if (res <> 0) or (mins < 0) then
      exit;
  end;

  // skip non-numeric characters between minutes and seconds
  while (i <= len) and not (AValue[i] in NUMERIC_CHARS) do
    inc(i);

  // extract third value: seconds
  SetLength(s, len);
  j := 1;
  n := 0;
  while (i <= len) and (AValue[i] in NUMERIC_CHARS) do begin
    if AValue[i] = ',' then s[j] := '.' else s[j] := AValue[i];
    inc(i);
    inc(j);
    inc(n);
  end;
  if n > 0 then begin
    SetLength(s, n);
    val(s, secs, res);
    if (res <> 0) or (secs < 0) then
      exit;
  end;

  // If the string contains seconds then minutes and deegrees must be integers
  if (secs <> 0) and ((frac(ADeg) > 0) or (frac(mins) > 0)) then
    exit;
  // If the string does not contain seconds then degrees must be integer.
  if (secs = 0) and (mins <> 0) and (frac(ADeg) > 0) then
    exit;

  // If the string contains minutes, but no seconds, then the degrees must be integer.
  Result := (mins >= 0) and (mins < 60) and (secs >= 0) and (secs < 60);

  // A similar check should be made for the degrees range, but since this is
  // different for latitude and longitude the check is skipped here.
  if Result then
    ADeg := sgn * (abs(ADeg) + mins / 60 + secs / 3600);
end;

{ Returns the direct distance (air-line) between two geo coordinates
 If latitude NOT between -90°..+90° and longitude NOT between -180°..+180°
 the function returns -1.
 Usage: FindDistance(51.53323, -2.90130, 51.29442, -2.27275, duKilometers);
}
function CalcGeoDistance(Lat1, Lon1, Lat2, Lon2: double;
  AUnits: TDistanceUnits = duKilometers): double;
const
  EPS = 1E-12;
var
  d_radians: double; // distance in radians
  lat1r, lon1r, lat2r, lon2r: double;
  arg: Double;
begin
  // Validate
  if (Lat1 < -90.0) or (Lat1 > 90.0) then exit(NaN);
//  if (Lon1 < -180.0) or (Lon1 > 180.0) then exit(NaN);
  if (Lat2 < -90.0) or (Lat2 > 90.0) then exit(NaN);
//  if (Lon2 < -180.0) or (Lon2 > 180.0) then exit(NaN);

  // Turn lat and lon into radian measures
  lat1r := (PI / 180.0) * Lat1;
  lon1r := (PI / 180.0) * Lon1;
  lat2r := (PI / 180.0) * Lat2;
  lon2r := (PI / 180.0) * Lon2;

  // calc
  arg := sin(lat1r) * sin(lat2r) + cos(lat1r) * cos(lat2r) * cos(lon1r - lon2r);
  if (arg < -1) or (arg > +1) then
    exit(NaN);
  if SameValue(abs(Lon1-Lon2), 360, EPS) and SameValue(abs(arg), 1.0, EPS) then
    d_radians := PI * 2.0
  else
    d_radians := arccos(arg);
  Result := EARTH_RADIUS * d_radians;

  case AUnits of
    duMeters: ;
    duKilometers: Result := Result * 1E-3;
    duMiles: Result := Result * 0.62137E-3;
  end;
end;

end.

