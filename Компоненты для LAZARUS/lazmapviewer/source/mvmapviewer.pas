{ (c) 2014 ti_dic MapViewer component for lazarus
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

unit mvMapViewer;

{$MODE objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, IntfGraphics, Forms,
  MvTypes, MvGPSObj, MvEngine, MvMapProvider, MvDownloadEngine, MvDrawingEngine;

Type

  TDrawGpsPointEvent = procedure (Sender: TObject;
    ADrawer: TMvCustomDrawingEngine; APoint: TGpsPoint) of object;

  { TMapView }

  TMapView = class(TCustomControl)
    private
      FDownloadEngine: TMvCustomDownloadEngine;
      FBuiltinDownloadEngine: TMvCustomDownloadEngine;
      FEngine: TMapViewerEngine;
      FBuiltinDrawingEngine: TMvCustomDrawingEngine;
      FDrawingEngine: TMvCustomDrawingEngine;
      FActive: boolean;
      FGPSItems: TGPSObjectList;
      FInactiveColor: TColor;
      FPOIImage: TBitmap;
      FPOITextBgColor: TColor;
      FOnDrawGpsPoint: TDrawGpsPointEvent;
      FDebugTiles: Boolean;
      FDefaultTrackColor: TColor;
      FDefaultTrackWidth: Integer;
      FFont: TFont;
      procedure CallAsyncInvalidate;
      procedure DoAsyncInvalidate({%H-}Data: PtrInt);
      procedure DrawObjects(const {%H-}TileId: TTileId; aLeft, aTop, aRight,aBottom: integer);
      procedure DrawPt(const {%H-}Area: TRealArea; aPOI: TGPSPoint);
      procedure DrawTrack(const Area: TRealArea; trk: TGPSTrack);
      function GetCacheOnDisk: boolean;
      function GetCachePath: String;
      function GetCenter: TRealPoint;
      function GetDownloadEngine: TMvCustomDownloadEngine;
      function GetDrawingEngine: TMvCustoMDrawingEngine;
      function GetMapProvider: String;
      function GetOnCenterMove: TNotifyEvent;
      function GetOnChange: TNotifyEvent;
      function GetOnZoomChange: TNotifyEvent;
      function GetUseThreads: boolean;
      function GetZoom: integer;
      function IsCachePathStored: Boolean;
      function IsFontStored: Boolean;
      procedure SetActive(AValue: boolean);
      procedure SetCacheOnDisk(AValue: boolean);
      procedure SetCachePath(AValue: String);
      procedure SetCenter(AValue: TRealPoint);
      procedure SetDebugTiles(AValue: Boolean);
      procedure SetDefaultTrackColor(AValue: TColor);
      procedure SetDefaultTrackWidth(AValue: Integer);
      procedure SetDownloadEngine(AValue: TMvCustomDownloadEngine);
      procedure SetDrawingEngine(AValue: TMvCustomDrawingEngine);
      procedure SetFont(AValue: TFont);
      procedure SetInactiveColor(AValue: TColor);
      procedure SetMapProvider(AValue: String);
      procedure SetOnCenterMove(AValue: TNotifyEvent);
      procedure SetOnChange(AValue: TNotifyEvent);
      procedure SetOnZoomChange(AValue: TNotifyEvent);
      procedure SetPOIImage(AValue: TBitmap);
      procedure SetPOITextBgColor(AValue: TColor);
      procedure SetUseThreads(AValue: boolean);
      procedure SetZoom(AValue: integer);
      procedure UpdateFont(Sender: TObject);
      procedure UpdateImage(Sender: TObject);

    protected
      AsyncInvalidate : boolean;
      procedure ActivateEngine;
      procedure DblClick; override;
      procedure DoDrawTile(const TileId: TTileId; X,Y: integer; TileImg: TLazIntfImage);
      procedure DoDrawTileInfo(const TileID: TTileID; X,Y: Integer);
      function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
        MousePos: TPoint): Boolean; override;
      procedure DoOnResize; override;
      function IsActive: Boolean;
      procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
        X, Y: Integer); override;
      procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
        X, Y: Integer); override;
      procedure MouseMove(Shift: TShiftState; X,Y: Integer); override;
      procedure Paint; override;
      procedure OnGPSItemsModified(Sender: TObject; objs: TGPSObjList;
        Adding: boolean);
    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure ClearBuffer;
      procedure GetMapProviders(lstProviders: TStrings);
      function GetVisibleArea: TRealArea;
      function LonLatToScreen(aPt: TRealPoint): TPoint;
      procedure SaveToFile(AClass: TRasterImageClass; const AFileName: String);
      function SaveToImage(AClass: TRasterImageClass): TRasterImage;
      procedure SaveToStream(AClass: TRasterImageClass; AStream: TStream);
      function ScreenToLonLat(aPt: TPoint): TRealPoint;
      procedure CenterOnObj(obj: TGPSObj);
      procedure ZoomOnArea(const aArea: TRealArea);
      procedure ZoomOnObj(obj: TGPSObj);
      procedure WaitEndOfRendering;
      property Center: TRealPoint read GetCenter write SetCenter;
      property Engine: TMapViewerEngine read FEngine;
      property GPSItems: TGPSObjectList read FGPSItems;
    published
      property Active: boolean read FActive write SetActive default false;
      property Align;
      property CacheOnDisk: boolean read GetCacheOnDisk write SetCacheOnDisk default true;
      property CachePath: String read GetCachePath write SetCachePath stored IsCachePathStored;
      property DebugTiles: Boolean read FDebugTiles write SetDebugTiles default false;
      property DefaultTrackColor: TColor read FDefaultTrackColor write SetDefaultTrackColor default clRed;
      property DefaultTrackWidth: Integer read FDefaultTrackWidth write SetDefaultTrackWidth default 1;
      property DownloadEngine: TMvCustomDownloadEngine read GetDownloadEngine write SetDownloadEngine;
      property DrawingEngine: TMvCustomDrawingEngine read GetDrawingEngine write SetDrawingEngine;
      property Font: TFont read FFont write SetFont stored IsFontStored;
      property Height default 150;
      property InactiveColor: TColor read FInactiveColor write SetInactiveColor default clWhite;
      property MapProvider: String read GetMapProvider write SetMapProvider;
      property POIImage: TBitmap read FPOIImage write SetPOIImage;
      property POITextBgColor: TColor read FPOITextBgColor write SetPOITextBgColor default clNone;
      property PopupMenu;
      property UseThreads: boolean read GetUseThreads write SetUseThreads default false;
      property Width default 150;
      property Zoom: integer read GetZoom write SetZoom;
      property OnCenterMove: TNotifyEvent read GetOnCenterMove write SetOnCenterMove;
      property OnZoomChange: TNotifyEvent read GetOnZoomChange write SetOnZoomChange;
      property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
      property OnDrawGpsPoint: TDrawGpsPointEvent read FOnDrawGpsPoint write FOnDrawGpsPoint;
      property OnMouseDown;
      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseMove;
      property OnMouseUp;
  end;


implementation

uses
  GraphType, Types,
  mvJobQueue, mvExtraData, mvDLEFpc, mvDE_IntfGraphics;

type

  { TDrawObjJob }

  TDrawObjJob = class(TJob)
  private
    AllRun: boolean;
    Viewer: TMapView;
    FRunning: boolean;
    FLst: TGPSObjList;
    FStates: Array of integer;
    FArea: TRealArea;
  protected
    function pGetTask: integer; override;
    procedure pTaskStarted(aTask: integer); override;
    procedure pTaskEnded(aTask: integer; aExcept: Exception); override;
  public
    procedure ExecuteTask(aTask: integer; FromWaiting: boolean); override;
    function Running: boolean;override;
  public
    constructor Create(aViewer: TMapView; aLst: TGPSObjList; const aArea: TRealArea);
    destructor Destroy; override;
  end;

{ TDrawObjJob }

function TDrawObjJob.pGetTask: integer;
var
  i: integer;
begin
  if not(AllRun) and not(Cancelled) then
  begin
    for i := Low(FStates) to High(FStates) do
      if FStates[i]=0 then
      begin
        result := i+1;
        Exit;
      end;
    AllRun:=True;
  end;

  Result := ALL_TASK_COMPLETED;
  for i := Low(FStates) to High(FStates) do
    if FStates[i]=1 then
    begin
      Result := NO_MORE_TASK;
      Exit;
    end;
end;

procedure TDrawObjJob.pTaskStarted(aTask: integer);
begin
  FRunning := True;
  FStates[aTask-1] := 1;
end;

procedure TDrawObjJob.pTaskEnded(aTask: integer; aExcept: Exception);
begin
  if Assigned(aExcept) then
    FStates[aTask-1] := 3
  else
    FStates[aTask-1] := 2;
end;

procedure TDrawObjJob.ExecuteTask(aTask: integer; FromWaiting: boolean);
var
  iObj: integer;
  Obj: TGpsObj;
begin
  iObj := aTask-1;
  Obj := FLst[iObj];
  if Obj.InheritsFrom(TGPSTrack) then
    Viewer.DrawTrack(FArea, TGPSTrack(Obj));
  if Obj.InheritsFrom(TGPSPoint) then
    Viewer.DrawPt(FArea, TGPSPoint(Obj));
end;

function TDrawObjJob.Running: boolean;
begin
  Result := FRunning;
end;

constructor TDrawObjJob.Create(aViewer: TMapView; aLst: TGPSObjList;
  const aArea: TRealArea);
begin
  FArea := aArea;
  FLst := aLst;
  SetLEngth(FStates,FLst.Count);
  Viewer := aViewer;
  AllRun := false;
  Name := 'DrawObj';
end;

destructor TDrawObjJob.Destroy;
begin
  inherited Destroy;
  FreeAndNil(FLst);
  if not(Cancelled) then
    Viewer.CallAsyncInvalidate;
end;


{ TMapView }

procedure TMapView.SetActive(AValue: boolean);
begin
  if FActive = AValue then Exit;
  FActive := AValue;
  if FActive then
    ActivateEngine
  else
    Engine.Active := false;
end;

function TMapView.GetCacheOnDisk: boolean;
begin
  Result := Engine.CacheOnDisk;
end;

function TMapView.GetCachePath: String;
begin
  Result := Engine.CachePath;
end;

function TMapView.GetCenter: TRealPoint;
begin
  Result := Engine.Center;
end;

function TMapView.GetDownloadEngine: TMvCustomDownloadEngine;
begin
  if FDownloadEngine = nil then
    Result := FBuiltinDownloadEngine
  else
    Result := FDownloadEngine;
end;

function TMapView.GetDrawingEngine: TMvCustomDrawingEngine;
begin
  if FDrawingEngine = nil then
    Result := FBuiltinDrawingEngine
  else
    Result := FDrawingEngine;
end;

function TMapView.GetMapProvider: String;
begin
  result := Engine.MapProvider;
end;

function TMapView.GetOnCenterMove: TNotifyEvent;
begin
  result := Engine.OnCenterMove;
end;

function TMapView.GetOnChange: TNotifyEvent;
begin
  Result := Engine.OnChange;
end;

function TMapView.GetOnZoomChange: TNotifyEvent;
begin
  Result := Engine.OnZoomChange;
end;

function TMapView.GetUseThreads: boolean;
begin
  Result := Engine.UseThreads;
end;

function TMapView.GetZoom: integer;
begin
  result := Engine.Zoom;
end;

function TMapView.IsCachePathStored: Boolean;
begin
  Result := not SameText(CachePath, 'cache/');
end;

function TMapView.IsFontStored: Boolean;
begin
  Result := SameText(FFont.Name, 'default') and (FFont.Size = 0) and
    (FFont.Style = []) and (FFont.Color = clBlack);
end;

procedure TMapView.SetCacheOnDisk(AValue: boolean);
begin
  Engine.CacheOnDisk := AValue;
end;

procedure TMapView.SetCachePath(AValue: String);
begin
  Engine.CachePath := AValue; //CachePath;
end;

procedure TMapView.SetCenter(AValue: TRealPoint);
begin
  Engine.Center := AValue;
end;

procedure TMapView.SetDebugTiles(AValue: Boolean);
begin
  if FDebugTiles = AValue then exit;
  FDebugTiles := AValue;
  Engine.Redraw;
end;

procedure TMapView.SetDefaultTrackColor(AValue: TColor);
begin
  if FDefaultTrackColor = AValue then exit;
  FDefaultTrackColor := AValue;
  Engine.Redraw;
end;

procedure TMapView.SetDefaultTrackWidth(AValue: Integer);
begin
  if FDefaultTrackWidth = AValue then exit;
  FDefaultTrackWidth := AValue;
  Engine.Redraw;
end;

procedure TMapView.SetDownloadEngine(AValue: TMvCustomDownloadEngine);
begin
  FDownloadEngine := AValue;
  FEngine.DownloadEngine := GetDownloadEngine;
end;

procedure TMapView.SetDrawingEngine(AValue: TMvCustomDrawingEngine);
begin
  FDrawingEngine := AValue;
  if AValue = nil then
    FBuiltinDrawingEngine.CreateBuffer(ClientWidth, ClientHeight)
  else begin
    FBuiltinDrawingEngine.CreateBuffer(0, 0);
    FDrawingEngine.CreateBuffer(ClientWidth, ClientHeight);
  end;
  UpdateFont(nil);
end;

procedure TMapView.SetFont(AValue: TFont);
begin
  FFont.Assign(AValue);
  UpdateFont(nil);
end;

procedure TMapView.SetInactiveColor(AValue: TColor);
begin
  if FInactiveColor = AValue then
    exit;
  FInactiveColor := AValue;
  if not IsActive then
    Invalidate;
end;

procedure TMapView.ActivateEngine;
begin
  Engine.SetSize(ClientWidth,ClientHeight);
  Engine.Active := IsActive;
end;

procedure TMapView.SetMapProvider(AValue: String);
begin
  Engine.MapProvider := AValue;
end;

procedure TMapView.SetOnCenterMove(AValue: TNotifyEvent);
begin
  Engine.OnCenterMove := AValue;
end;

procedure TMapView.SetOnChange(AValue: TNotifyEvent);
begin
  Engine.OnChange := AValue;
end;

procedure TMapView.SetOnZoomChange(AValue: TNotifyEvent);
begin
  Engine.OnZoomChange := AValue;
end;

procedure TMapView.SetPOIImage(AValue: TBitmap);
begin
  if FPOIImage = AValue then exit;
  FPOIImage := AValue;
  Engine.Redraw;
end;

procedure TMapView.SetPOITextBgColor(AValue: TColor);
begin
  if FPOITextBgColor = AValue then exit;
  FPOITextBgColor := AValue;
  Engine.Redraw;
end;

procedure TMapView.SetUseThreads(AValue: boolean);
begin
  Engine.UseThreads := aValue;
end;

procedure TMapView.SetZoom(AValue: integer);
begin
  Engine.Zoom := AValue;
end;

function TMapView.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  Result:=inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  if IsActive then
    Engine.MouseWheel(self,Shift,WheelDelta,MousePos,Result);
end;

procedure TMapView.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if IsActive then
    Engine.MouseDown(self,Button,Shift,X,Y);
end;

procedure TMapView.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if IsActive then
    Engine.MouseUp(self,Button,Shift,X,Y);
end;

procedure TMapView.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if IsActive then
    Engine.MouseMove(self,Shift,X,Y);
end;

procedure TMapView.DblClick;
begin
  inherited DblClick;
  if IsActive then
    Engine.DblClick(self);
end;

procedure TMapView.DoOnResize;
begin
  inherited DoOnResize;
  //cancel all rendering threads
  Engine.CancelCurrentDrawing;
  DrawingEngine.CreateBuffer(ClientWidth, ClientHeight);
  if IsActive then
    Engine.SetSize(ClientWidth, ClientHeight);
end;

procedure TMapView.Paint;
begin
  inherited Paint;
  if IsActive then
    DrawingEngine.PaintToCanvas(Canvas)
  else
  begin
    Canvas.Brush.Color := InactiveColor;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(0, 0, ClientWidth, ClientHeight);
  end;
end;

procedure TMapView.OnGPSItemsModified(Sender: TObject; objs: TGPSObjList;
  Adding: boolean);
var
  Area,ObjArea,vArea: TRealArea;
begin
  if Adding and Assigned(Objs) then
  begin
    ObjArea := GetAreaOf(Objs);
    vArea := GetVisibleArea;
    if hasIntersectArea(ObjArea,vArea) then
    begin
      Area := IntersectArea(ObjArea, vArea);
      Engine.Jobqueue.AddJob(TDrawObjJob.Create(self, Objs, Area), Engine);
    end
    else
      objs.Free;
  end
  else
  begin
    Engine.Redraw;
    Objs.free;
  end;
end;

procedure TMapView.DrawTrack(const Area: TRealArea; trk: TGPSTrack);
var
  Old,New: TPoint;
  i: integer;
  aPt: TRealPoint;
  LastInside, IsInside: boolean;
  trkColor: TColor;
  trkWidth: Integer;
begin
  if trk.Points.Count > 0 then
  begin
    trkColor := FDefaultTrackColor;
    trkWidth := FDefaultTrackWidth;
    if trk.ExtraData <> nil then
    begin
      if trk.ExtraData.InheritsFrom(TDrawingExtraData) then
        trkColor := TDrawingExtraData(trk.ExtraData).Color;
      if trk.ExtraData.InheritsFrom(TTrackExtraData) then
        trkWidth := round(ScreenInfo.PixelsPerInchX * TTrackExtraData(trk.ExtraData).Width / 25.4);
    end;
    if trkWidth < 1 then trkWidth := 1;
    LastInside := false;
    DrawingEngine.PenColor := trkColor;
    DrawingEngine.PenWidth := trkWidth;
    for i:=0 to pred(trk.Points.Count) do
    begin
      aPt := trk.Points[i].RealPoint;
      IsInside := PtInsideArea(aPt,Area);
      if IsInside or LastInside then
      begin
        New := Engine.LonLatToScreen(aPt);
        if i > 0 then
        begin
          if not LastInside then
            Old := Engine.LonLatToScreen(trk.Points[pred(i)].RealPoint);
          DrawingEngine.Line(Old.X, Old.Y, New.X, New.Y);
        end;
        Old := New;
        LastInside := IsInside;
      end;
    end;
  end;
end;

procedure TMapView.DrawPt(const Area: TRealArea; aPOI: TGPSPoint);
var
  Pt: TPoint;
  PtColor: TColor;
  extent: TSize;
  s: String;
begin
  if Assigned(FOnDrawGpsPoint) then begin
    FOnDrawGpsPoint(Self, DrawingEngine, aPOI);
    exit;
  end;

  Pt := Engine.LonLatToScreen(aPOI.RealPoint);
  PtColor := clRed;
  if aPOI.ExtraData <> nil then
  begin
    if aPOI.ExtraData.inheritsFrom(TDrawingExtraData) then
      PtColor := TDrawingExtraData(aPOI.ExtraData).Color;
  end;

  // Draw point marker
  if Assigned(FPOIImage) and not (FPOIImage.Empty) then
    DrawingEngine.DrawBitmap(Pt.X - FPOIImage.Width div 2, Pt.Y - FPOIImage.Height, FPOIImage, true)
  else begin
    DrawingEngine.PenColor := ptColor;
    DrawingEngine.Line(Pt.X, Pt.Y - 5, Pt.X, Pt.Y + 5);
    DrawingEngine.Line(Pt.X - 5, Pt.Y, Pt.X + 5, Pt.Y);
    Pt.Y := Pt.Y + 5;
  end;

  // Draw point text
  s := aPOI.Name;
  if FPOITextBgColor = clNone then
    DrawingEngine.BrushStyle := bsClear
  else begin
    DrawingEngine.BrushStyle := bsSolid;
    DrawingEngine.BrushColor := FPOITextBgColor;
    s := ' ' + s + ' ';
  end;
  extent := DrawingEngine.TextExtent(s);
  DrawingEngine.Textout(Pt.X - extent.CX div 2, Pt.Y + 5, s);
end;

procedure TMapView.CallAsyncInvalidate;
Begin
  if not(AsyncInvalidate) then
  begin
    AsyncInvalidate := true;
    Engine.Jobqueue.QueueAsyncCall(@DoAsyncInvalidate, 0);
  end;
end;

procedure TMapView.DrawObjects(const TileId: TTileId;
  aLeft, aTop,aRight,aBottom: integer);
var
  aPt: TPoint;
  Area: TRealArea;
  lst: TGPSObjList;
begin
  aPt.X := aLeft;
  aPt.Y := aTop;
  Area.TopLeft := Engine.ScreenToLonLat(aPt);
  aPt.X := aRight;
  aPt.Y := aBottom;
  Area.BottomRight := Engine.ScreenToLonLat(aPt);
  if GPSItems.Count > 0 then
  begin
    lst := GPSItems.GetObjectsInArea(Area);
    if lst.Count > 0 then
      Engine.Jobqueue.AddJob(TDrawObjJob.Create(self, lst, Area), Engine)
    else
    begin
      FreeAndNil(Lst);
      CallAsyncInvalidate;
    end;
  end
  else
    CallAsyncInvalidate;
end;

procedure TMapView.DoAsyncInvalidate(Data: PtrInt);
Begin
  Invalidate;
  AsyncInvalidate := false;
end;

procedure TMapView.DoDrawTile(const TileId: TTileId; X, Y: integer;
  TileImg: TLazIntfImage);
begin
  if Assigned(TileImg) then begin
    DrawingEngine.DrawLazIntfImage(X, Y, TileImg);
  end
  else begin
    DrawingEngine.BrushColor := clWhite;
    DrawingEngine.BrushStyle := bsSolid;
    DrawingEngine.FillRect(X, Y, X + TILE_SIZE, Y + TILE_SIZE);
  end;

  if FDebugTiles then
    DoDrawTileInfo(TileID, X, Y);

  DrawObjects(TileId, X, Y, X + TILE_SIZE, Y + TILE_SIZE);
end;

procedure TMapView.DoDrawTileInfo(const TileID: TTileID; X, Y: Integer);
begin
  DrawingEngine.PenColor := clGray;
  DrawingEngine.PenWidth := 1;
  DrawingEngine.Line(X, Y, X, Y + TILE_SIZE);
  DrawingEngine.Line(X, Y, X + TILE_SIZE, Y);
  DrawingEngine.Line(X + TILE_SIZE, Y, X + TILE_SIZE, Y + TILE_SIZE);
  DrawingEngine.Line(X, Y + TILE_SIZE, X + TILE_SIZE, Y + TILE_SIZE);
end;

function TMapView.IsActive: Boolean;
begin
  if not(csDesigning in ComponentState) then
    Result := FActive
  else
    Result := false;
end;

constructor TMapView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 150;
  Height := 150;

  FActive := false;
  FDefaultTrackColor := clRed;
  FDefaultTrackWidth := 1;
  FInactiveColor := clWhite;

  FGPSItems := TGPSObjectList.Create;
  FGPSItems.OnModified := @OnGPSItemsModified;

  FBuiltinDownloadEngine := TMvDEFpc.Create(self);
  FBuiltinDownloadEngine.Name := 'BuiltInDLE';

  FEngine := TMapViewerEngine.Create(self);
  FEngine.CachePath := 'cache/';
  FEngine.CacheOnDisk := true;
  FEngine.OnDrawTile := @DoDrawTile;
  FEngine.DrawTitleInGuiThread := false;
  FEngine.DownloadEngine := FBuiltinDownloadEngine;

  FBuiltinDrawingEngine := TMvIntfGraphicsDrawingEngine.Create(self);
  FBuiltinDrawingEngine.Name := 'BuiltInDE';
  FBuiltinDrawingEngine.CreateBuffer(Width, Height);

  FFont := TFont.Create;
  FFont.Name := 'default';
  FFont.Size := 0;
  FFont.Style := [];
  FFont.Color := clBlack;
  FFont.OnChange := @UpdateFont;

  FPOIImage := TBitmap.Create;
  FPOIImage.OnChange := @UpdateImage;
  FPOITextBgColor := clNone;
end;

destructor TMapView.Destroy;
begin
  FFont.Free;
  FreeAndNil(FPOIImage);
  FreeAndNil(FGPSItems);
  inherited Destroy;
end;

procedure TMapView.SaveToFile(AClass: TRasterImageClass; const AFileName: String);
var
  stream: TFileStream;
begin
  stream := TFileStream.Create(AFileName, fmCreate + fmShareDenyNone);
  try
    SaveToStream(AClass, stream);
  finally
    stream.Free;
  end;
end;

function TMapView.SaveToImage(AClass: TRasterImageClass): TRasterImage;
begin
  Result := DrawingEngine.SaveToImage(AClass);
end;

procedure TMapView.SaveToStream(AClass: TRasterImageClass; AStream: TStream);
var
  img: TRasterImage;
begin
  img := SaveToImage(AClass);
  try
    img.SaveToStream(AStream);
  finally
    img.Free;
  end;
end;

function TMapView.ScreenToLonLat(aPt: TPoint): TRealPoint;
begin
  Result:=Engine.ScreenToLonLat(aPt);
end;

function TMapView.LonLatToScreen(aPt: TRealPoint): TPoint;
begin
  Result:=Engine.LonLatToScreen(aPt);
end;

procedure TMapView.GetMapProviders(lstProviders: TStrings);
begin
  Engine.GetMapProviders(lstProviders);
end;

procedure TMapView.WaitEndOfRendering;
begin
  Engine.Jobqueue.WaitAllJobTerminated(Engine);
end;

procedure TMapView.CenterOnObj(obj: TGPSObj);
var
  Area: TRealArea;
  Pt: TRealPoint;
begin
  obj.GetArea(Area);
  Pt.Lon := (Area.TopLeft.Lon + Area.BottomRight.Lon) /2;
  Pt.Lat := (Area.TopLeft.Lat + Area.BottomRight.Lat) /2;
  Center := Pt;
end;

procedure TMapView.ZoomOnObj(obj: TGPSObj);
var
  Area: TRealArea;
begin
  obj.GetArea(Area);
  Engine.ZoomOnArea(Area);
end;

procedure TMapView.ZoomOnArea(const aArea: TRealArea);
begin
  Engine.ZoomOnArea(aArea);
end;

function TMapView.GetVisibleArea: TRealArea;
var
  aPt: TPoint;
begin
  aPt.X := 0;
  aPt.Y := 0;
  Result.TopLeft := Engine.ScreenToLonLat(aPt);
  aPt.X := Width;
  aPt.Y := Height;
  Result.BottomRight := Engine.ScreenToLonLat(aPt);;
end;

procedure TMapView.ClearBuffer;
begin
  DrawingEngine.CreateBuffer(ClientWidth, ClientHeight);       // ???
end;

procedure TMapView.UpdateFont(Sender: TObject);
begin
  if SameText(FFont.Name, 'default') then
    DrawingEngine.FontName := Screen.SystemFont.Name
  else
    DrawingEngine.FontName := FFont.Name;
  if FFont.Size = 0 then
    DrawingEngine.FontSize := Screen.SystemFont.Size
  else
    DrawingEngine.FontSize := FFont.Size;
  DrawingEngine.FontStyle := FFont.Style;
  DrawingEngine.FontColor := ColorToRGB(FFont.Color);
  Engine.Redraw;
end;

procedure TMapView.UpdateImage(Sender: TObject);
begin
  Engine.Redraw;
end;

end.

