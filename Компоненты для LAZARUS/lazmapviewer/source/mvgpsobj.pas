{ Map Viewer - basic gps object

  Copyright (C) 2014 ti_dic@hotmail.com

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
}unit mvGpsObj;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,fgl,mvtypes,contnrs,syncobjs;

const
  NO_ELE  = -10000000;
  NO_DATE = 0;

type
  TIdArray = Array of integer;

  { TGPSObj }

  TGPSObj = class
  private
    BBoxSet: Boolean;
    FBoundingBox: TRealArea;
    FExtraData: TObject;
    FName: String;
    FIdOwner: integer;
    function GetBoundingBox: TRealArea;
    procedure SetBoundingBox(AValue: TRealArea);
    procedure SetExtraData(AValue: TObject);
  public
    destructor Destroy; override;
    procedure GetArea(out Area: TRealArea); virtual; abstract;
    property Name: String read FName write FName;
    property ExtraData: TObject read FExtraData write SetExtraData;
    property IdOwner: Integer read FIdOwner;
    property BoundingBox: TRealArea read GetBoundingBox write SetBoundingBox;
  end;

  TGPSObjarray = Array of TGPSObj;

  { TGPSPoint }

  TGPSPoint = class(TGPSObj)
  private
    FRealPt: TRealPoint;
    FEle: Double;
    FDateTime: TDateTime;
    function GetLat: Double;
    function GetLon: Double;
  public
    constructor Create(ALon,ALat: double; AEle: double=NO_ELE; ADateTime: TDateTime=NO_DATE);
    class function CreateFrom(aPt: TRealPoint): TGPSPoint;

    procedure GetArea(out Area: TRealArea);override;
    function HasEle: boolean;
    function HasDateTime: Boolean;
    function DistanceInKmFrom(OtherPt: TGPSPoint; UseEle: boolean=true): double;

    property Lon: Double read GetLon;
    property Lat: Double read GetLat;
    property Ele: double read FEle;
    property DateTime: TDateTime read FDateTime;
    property RealPoint: TRealPoint read FRealPt;
  end;

  TGPSPointList = specialize TFPGObjectList<TGPSPoint>;

  { TGPSTrack }

  TGPSTrack = class(TGPSObj)
  private
    FDateTime: TDateTime;
    FPoints: TGPSPointList;
    function GetDateTime: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;

    procedure GetArea(out Area: TRealArea); override;
    function TrackLengthInKm(UseEle: Boolean=true): double;

    property Points: TGPSPointList read FPoints;
    property DateTime: TDateTime read GetDateTime write FDateTime;
  end;

  TGPSObjList_ = specialize TFPGObjectList<TGPSObj>;

  { TGPSObjList }

  TGPSObjList = class(TGPSObjList_)
  private
    FRef: TObject;
  public
    destructor Destroy; override;
  end;

  { TGPSObjectList }

  TModifiedEvent = procedure (Sender: TObject; objs: TGPSObjList;
    Adding: boolean) of object;

  TGPSObjectList = class(TGPSObj)
  private
    Crit: TCriticalSection;
    FPending: TObjectList;
    FRefCount: integer;
    FOnModified: TModifiedEvent;
    FUpdating: integer;
    FItems: TGPSObjList;
    function GetCount: integer;
    function GetItem(AIndex: Integer): TGpsObj;
  protected
    procedure _Delete(Idx: Integer; var DelLst: TGPSObjList);
    procedure FreePending;
    procedure DecRef;
    procedure Lock;
    procedure UnLock;
    procedure CallModified(lst: TGPSObjList; Adding: boolean);
//    property Items: TGPSObjList read FItems;
    procedure IdsToObj(const Ids: TIdArray; out objs: TGPSObjArray; AIdOwner: integer);
  public
    constructor Create;
    destructor Destroy; override;
    Procedure Clear(OwnedBy: integer);
    procedure ClearExcept(OwnedBy: integer; const ExceptLst: TIdArray;
      out Notfound: TIdArray);
    procedure GetArea(out Area: TRealArea); override;
    function GetObjectsInArea(const Area: TRealArea): TGPSObjList;
    function GetIdsArea(const Ids: TIdArray; AIdOwner: integer): TRealArea;

    function Add(aItem: TGpsObj; AIdOwner: integer): integer;
    procedure DeleteById(const Ids: Array of integer);

    procedure BeginUpdate;
    procedure EndUpdate;

    property Count: integer read GetCount;
    property Items[AIndex: Integer]: TGpsObj read GetItem; default;
    property OnModified: TModifiedEvent read FOnModified write FOnModified;
  end;

function HasIntersectArea(const Area1: TRealArea; const Area2: TRealArea): boolean;
function IntersectArea(const Area1: TRealArea; const Area2: TRealArea): TRealArea;
function PtInsideArea(const aPoint: TRealPoint; const Area: TRealArea): boolean;
function AreaInsideArea(const AreaIn: TRealArea; const AreaOut: TRealArea): boolean;
procedure ExtendArea(var AreaToExtend: TRealArea; const Area: TRealArea);
function GetAreaOf(objs: TGPSObjList): TRealArea;


implementation

uses
  mvExtraData;

function hasIntersectArea(const Area1: TRealArea; const Area2: TRealArea): boolean;
begin
  Result := (Area1.TopLeft.Lon <= Area2.BottomRight.Lon) and
            (Area1.BottomRight.Lon >= Area2.TopLeft.Lon) and
            (Area1.TopLeft.Lat >= Area2.BottomRight.Lat) and
            (Area1.BottomRight.Lat <= Area2.TopLeft.Lat);
end;

function IntersectArea(const Area1: TRealArea; const Area2: TRealArea): TRealArea;
begin
  Result := Area1;
  if Result.TopLeft.Lon<Area2.topLeft.Lon then
    Result.TopLeft.Lon:=Area2.topLeft.Lon;
  if Result.TopLeft.Lat>Area2.topLeft.Lat then
    Result.TopLeft.Lat:=Area2.topLeft.Lat;
  if Result.BottomRight.Lon>Area2.BottomRight.Lon then
    Result.BottomRight.Lon:=Area2.BottomRight.Lon;
  if Result.BottomRight.Lat<Area2.BottomRight.Lat then
    Result.BottomRight.Lat:=Area2.BottomRight.Lat;
end;

function PtInsideArea(const aPoint: TRealPoint; const Area: TRealArea): boolean;
begin
  Result := (Area.TopLeft.Lon <= aPoint.Lon) and
            (Area.BottomRight.Lon >= aPoint.Lon) and
            (Area.TopLeft.Lat >= aPoint.Lat) and
            (Area.BottomRight.Lat <= aPoint.Lat);
end;

function AreaInsideArea(const AreaIn: TRealArea; const AreaOut: TRealArea): boolean;
begin
  Result := (AreaIn.TopLeft.Lon >= AreaOut.TopLeft.Lon) and
            (AreaIn.BottomRight.Lon <= AreaOut.BottomRight.Lon) and
            (AreaOut.TopLeft.Lat >= AreaIn.TopLeft.Lat) and
            (AreaOut.BottomRight.Lat <= AreaIn.BottomRight.Lat);
end;

procedure ExtendArea(var AreaToExtend: TRealArea; const Area: TRealArea);
begin
  if AreaToExtend.TopLeft.Lon>Area.TopLeft.Lon then
     AreaToExtend.TopLeft.Lon:=Area.TopLeft.Lon;
  if AreaToExtend.BottomRight.Lon<Area.BottomRight.Lon then
     AreaToExtend.BottomRight.Lon:=Area.BottomRight.Lon;

  if AreaToExtend.TopLeft.Lat<Area.TopLeft.Lat then
     AreaToExtend.TopLeft.Lat:=Area.TopLeft.Lat;
  if AreaToExtend.BottomRight.Lat>Area.BottomRight.Lat then
     AreaToExtend.BottomRight.Lat:=Area.BottomRight.Lat;
end;

function GetAreaOf(objs: TGPSObjList): TRealArea;
var
  i: integer;
begin
  Result.TopLeft.Lon := 0;
  Result.TopLeft.Lat := 0;
  Result.BottomRight.Lon := 0;
  Result.BottomRight.Lat := 0;
  if Objs.Count>0 then
  begin
    Result := Objs[0].BoundingBox;
    for i:=1 to pred(Objs.Count) do
      ExtendArea(Result, Objs[i].BoundingBox);
  end;
end;

{ TGPSObjList }

destructor TGPSObjList.Destroy;
begin
  if Assigned(FRef) then
    TGPSObjectList(FRef).DecRef;
  inherited Destroy;
end;

{ TGPSObj }

procedure TGPSObj.SetExtraData(AValue: TObject);
begin
  if FExtraData=AValue then Exit;
  if Assigned(FExtraData) then
    FreeAndNil(FExtraData);
  FExtraData := AValue;
end;

function TGPSObj.GetBoundingBox: TRealArea;
begin
  if not(BBoxSet) then
  begin
    GetArea(FBoundingBox);
    BBoxSet := true;
  end;
  Result := FBoundingBox;
end;

procedure TGPSObj.SetBoundingBox(AValue: TRealArea);
begin
  FBoundingBox := AValue;
  BBoxSet := true;
end;

destructor TGPSObj.Destroy;
begin
  FreeAndNil(FExtraData);
  inherited Destroy;
end;

{ TGPSObjectList }

function TGPSObjectList.GetCount: integer;
begin
  Result := FItems.Count
end;

function TGPSObjectList.GetItem(AIndex: Integer): TGpsObj;
begin
  Result := FItems[AIndex];
end;

procedure TGPSObjectList._Delete(Idx: Integer; var DelLst: TGPSObjList);   // wp: was "out"
var
  Item: TGpsObj;
begin
  Lock;
  try
    if not(Assigned(DelLst)) then
    begin
      DelLst := TGpsObjList.Create(False);
      DelLst.FRef := Self;
      inc(FRefCount);
    end;
    if not Assigned(FPending) then
      FPending := TObjectList.Create(true);
    Item := FItems.Extract(FItems[Idx]);
    FPending.Add(Item);
  finally
    UnLock;
  end;
  DelLst.Add(Item);
end;

procedure TGPSObjectList.FreePending;
begin
  if Assigned(FPending) then
  begin
    Lock;
    try
      FreeAndNil(FPending);
    finally
      UnLock;
    end;
  end;
end;

procedure TGPSObjectList.DecRef;
begin
  FRefCount-=1;
  if FRefCount=0 then
    FreePending;
end;

procedure TGPSObjectList.Lock;
begin
  if Assigned(Crit) then
    Crit.Enter;
end;

procedure TGPSObjectList.UnLock;
begin
  if Assigned(Crit) then
    Crit.Leave;
end;

procedure TGPSObjectList.CallModified(lst: TGPSObjList; Adding: boolean);
begin
  if (FUpdating=0) and Assigned(FOnModified) then
    FOnModified(self, lst, Adding)
  else
    lst.Free;
end;

procedure TGPSObjectList.IdsToObj(const Ids: TIdArray; out objs: TGPSObjArray;
  AIdOwner: integer);

  function ToSelect(aId: integer): boolean;
  var
    i: integer;
  begin
    result := false;
    for i:=low(Ids) to high(Ids) do
      if Ids[i]=aId then
      begin
        result := true;
        break;
      end;
  end;

var
  i,nb : integer;
begin
  SetLength(objs, Length(Ids));
  nb := 0;
  Lock;
  try
    for i:=0 to pred(FItems.Count) do
    begin
      if (AIdOwner = 0) or (AIdOwner = FItems[i].FIdOwner) then
        if Assigned(FItems[i].ExtraData) and FItems[i].ExtraData.InheritsFrom(TDrawingExtraData) then
        begin
          if ToSelect(TDrawingExtraData(FItems[i].ExtraData).Id) then
          begin
            objs[nb] := FItems[i];
            nb+=1;
          end;
        end;
    end;
  finally
    Unlock;
  end;
  SetLength(objs, nb);
end;

procedure TGPSObjectList.GetArea(out Area: TRealArea);
var
  i: integer;
  ptArea: TRealArea;
begin
  Area.BottomRight.lon := 0;
  Area.BottomRight.lat := 0;
  Area.TopLeft.lon := 0;
  Area.TopLeft.lat := 0;
  Lock;
  try
    if Count > 0 then
    begin
      Area := Items[0].BoundingBox;
      for i:=1 to pred(Count) do
      begin
        ptArea := Items[i].BoundingBox;
        ExtendArea(Area, ptArea);
      end;
    end;
  finally
    Unlock;
  end;
end;

function TGPSObjectList.GetObjectsInArea(const Area: TRealArea): TGPSObjList;
var
  i: integer;
  ItemArea: TRealArea;
begin
  Result := TGPSObjList.Create(false);
  Lock;
  try
    Inc(FRefCount);
    for i:=0 to pred(Count) do
    begin
      ItemArea := Items[i].BoundingBox;
      if hasIntersectArea(Area,ItemArea) then
        Result.Add(Items[i]);
    end;
    if Result.Count > 0 then
      Result.FRef := Self
    else
      Dec(FRefCount);
  finally
    Unlock;
  end;
end;

constructor TGPSObjectList.Create;
begin
  Crit := TCriticalSection.Create;
  FItems := TGPSObjList.Create(true);
end;

destructor TGPSObjectList.Destroy;
begin
  inherited Destroy;
  FreeAndNil(FItems);
  FreeAndNil(FPending);
  FreeAndNil(Crit);
end;

procedure TGPSObjectList.Clear(OwnedBy: integer);
var
  i: integer;
  DelObj: TGPSObjList;
begin
  DelObj := nil;
  Lock;
  try
    for i:=pred(FItems.Count) downto 0 do
      if (OwnedBy = 0) or (FItems[i].FIdOwner = OwnedBy) then
        _Delete(i,DelObj);
  finally
    Unlock;
  end;
  if Assigned(DelObj) then
    CallModified(DelObj, false);
end;

procedure TGPSObjectList.ClearExcept(OwnedBy: integer;
  const ExceptLst: TIdArray; out Notfound: TIdArray);

var
  Found: TIdArray;

  function ToDel(aIt: TGPsObj): boolean;
  var
    i,Id: integer;
  begin
    if (aIt.ExtraData=nil) or not(aIt.ExtraData.InheritsFrom(TDrawingExtraData)) then
      Result := true
    else
    Begin
      Result := true;
      Id := TDrawingExtraData(aIt.ExtraData).Id;
      for i := Low(ExceptLst) to High(ExceptLst) do
       if Id = ExceptLst[i] then
       begin
         Result := false;
         SetLength(Found, Length(Found)+1);
         Found[high(Found)] := Id;
         exit;
       end;
    end;
  end;

var
  i,j: integer;
  IsFound: boolean;
  DelLst: TGPSObjList;
begin
  DelLst := nil;
  SetLength(NotFound, 0);
  SetLength(Found, 0);
  Lock;
  try
    for i := pred(FItems.Count) downto 0 do
    begin
      if (FItems[i].FIdOwner = OwnedBy) or (OwnedBy = 0) then
      Begin
         if ToDel(FItems[i]) then
           _Delete(i,DelLst);
      end;
    end;
  finally
    Unlock;
  end;
  for i:=low(ExceptLst) to high(ExceptLst) do
  begin
    IsFound := false;
    for j:=Low(Found) to High(Found) do
      if Found[j] = ExceptLst[i] then
      begin
        IsFound := true;
        break;
      end;
    if not IsFound then
    begin
      SetLength(NotFound, Length(NotFound)+1);
      NotFound[high(NotFound)] := ExceptLst[i];
    end;
  end;
  if Assigned(DelLst) then
    CallModified(DelLst, false);
end;

function TGPSObjectList.GetIdsArea(const Ids: TIdArray; AIdOwner: integer): TRealArea;
var
  Objs: TGPSObjarray;
  i: integer;
begin
  Result.BottomRight.Lat := 0;
  Result.BottomRight.Lon := 0;
  Result.TopLeft.Lat := 0;
  Result.TopLeft.Lon := 0;
  Lock;
  try
    IdsToObj(Ids, Objs, AIdOwner);
    if Length(Objs) > 0 then
    begin
      Result := Objs[0].BoundingBox;
      for i:=succ(Low(Objs)) to High(Objs) do
        ExtendArea(Result, Objs[i].BoundingBox);
    end;
  finally
    Unlock;
  end;
end;

function TGPSObjectList.Add(aItem: TGpsObj; AIdOwner: integer): integer;
var
  mList: TGPSObjList;
begin
  aItem.FIdOwner := AIdOwner;
  Lock;
  try
    Result := FItems.Add(aItem);
    mList := TGPSObjList.Create(false);
    mList.Add(aItem);
    inc(FRefCount);
    mList.FRef := Self;
  finally
    Unlock;
  end;
  CallModified(mList, true);
end;

procedure TGPSObjectList.DeleteById(const Ids: array of integer);

  function ToDelete(const AId: integer): Boolean;
  var
    i: integer;
  begin
    result := false;
    For i:=Low(Ids) to High(Ids) do
      if Ids[i] = AId then
      begin
        result := true;
        exit;
      end;
  end;

var
  Extr: TDrawingExtraData;
  i: integer;
  DelLst: TGPSObjList;
begin
  DelLst := nil;
  Lock;
  try
    for i:=pred(Count) downto 0 do
    begin
      if Assigned(Items[i].ExtraData) then
      begin
        if Items[i].ExtraData.InheritsFrom(TDrawingExtraData) then
        begin
          Extr := TDrawingExtraData(Items[i]);
          // !!! wp: There is a warning that TGPSObj and TDrawingExtraData are not related !!!
          if ToDelete(Extr.Id) then
            _Delete(i, DelLst);
          // !!! wp: DelLst is a local var and was created by _Delete but is
          //     not destroyed anywhere here !!!
        end;
      end;
    end;
  finally
    Unlock;
  end;
  if Assigned(DelLst) then
// wp: is this missing here:    DelLst.Free;
end;

procedure TGPSObjectList.BeginUpdate;
begin
  inc(FUpdating);
end;

procedure TGPSObjectList.EndUpdate;
begin
  if FUpdating > 0 then
  begin
    Dec(FUpdating);
    if FUpdating = 0 then
      CallModified(nil, true);
  end;
end;


{ TGPSTrack }

function TGPSTrack.GetDateTime: TDateTime;
begin
  if FDateTime = 0 then
  Begin
    if FPoints.Count > 0 then
      FDateTime := FPoints[0].DateTime;
  end;
  Result := FDateTime;
end;

constructor TGPSTrack.Create;
begin
  FPoints := TGPSPointList.Create(true);
end;

destructor TGPSTrack.Destroy;
begin
  inherited Destroy;
  FreeAndNil(FPoints);
end;

procedure TGPSTrack.GetArea(out Area: TRealArea);
var
  i: integer;
  ptArea: TRealArea;
begin
  Area.BottomRight.lon := 0;
  Area.BottomRight.lat := 0;
  Area.TopLeft.lon := 0;
  Area.TopLeft.lat := 0;
  if FPoints.Count > 0 then
  begin
    Area := FPoints[0].BoundingBox;
    for i:=1 to pred(FPoints.Count) do
    begin
      ptArea := FPoints[i].BoundingBox;
      ExtendArea(Area, ptArea);
    end;
  end;
end;

function TGPSTrack.TrackLengthInKm(UseEle: Boolean): double;
var
  i: integer;
begin
  Result := 0;
  for i:=1 to pred(FPoints.Count) do
    result += FPoints[i].DistanceInKmFrom(FPoints[pred(i)], UseEle);
end;


{ TGPSPoint }

function TGPSPoint.GetLat: Double;
begin
  result := FRealPt.Lat;
end;

function TGPSPoint.GetLon: Double;
begin
  result := FRealPt.Lon;
end;

procedure TGPSPoint.GetArea(out Area: TRealArea);
begin
  Area.TopLeft := FRealPt;
  Area.BottomRight := FRealPt;
end;

function TGPSPoint.HasEle: boolean;
begin
  Result := FEle <> NO_ELE;
end;

function TGPSPoint.HasDateTime: Boolean;
begin
  Result := FDateTime <> NO_DATE;
end;

function TGPSPoint.DistanceInKmFrom(OtherPt: TGPSPoint; UseEle: boolean): double;
var
  a: double;
  lat1, lat2, lon1, lon2, t1, t2, t3, t4, t5, rad_dist: double;
  DiffEle: Double;
begin
  a := PI / 180;
  lat1 := lat * a;
  lat2 := OtherPt.lat * a;
  lon1 := lon * a;
  lon2 := OtherPt.lon * a;

  t1 := sin(lat1) * sin(lat2);
  t2 := cos(lat1) * cos(lat2);
  t3 := cos(lon1 - lon2);
  t4 := t2 * t3;
  t5 := t1 + t4;
  rad_dist := arctan(-t5/sqrt(-t5 * t5 +1)) + 2 * arctan(1);
  result := (rad_dist * 3437.74677 * 1.1508) * 1.6093470878864446;
  if UseEle and (FEle<>OtherPt.FEle) then
    if (HasEle) and (OtherPt.HasEle) then
    begin
      //FEle is assumed in Metter
      DiffEle := (FEle-OtherPt.Ele)/1000;
      Result := sqrt(DiffEle*DiffEle+result*result);
    end;
end;

constructor TGPSPoint.Create(ALon, ALat: double; AEle: double;
  ADateTime: TDateTime);
begin
  FRealPt.Lon := ALon;
  FRealPt.Lat := ALat;
  FEle := AEle;
  FDateTime := ADateTime;
end;

class function TGPSPoint.CreateFrom(aPt: TRealPoint): TGPSPoint;
begin
  Result := Create(aPt.Lon,aPt.Lat);
end;

end.

