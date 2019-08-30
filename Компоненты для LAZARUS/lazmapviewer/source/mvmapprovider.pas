{
  (c) 2014 ti_dic

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
unit mvMapProvider;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, laz2_xmlwrite, laz2_dom;

type

  { TTileId }

  TTileId = record
    X, Y: int64;
    Z: integer;
  end;

  TGetSvrStr = function (id: integer): string;
  TGetValStr = function (const Tile: TTileId): String;

  { TMapProvider }

  TMapProvider = class
    private
      FLayer: integer;
      idServer: Array of Integer;
      FName: String;
      FUrl: Array of string;
      FNbSvr: Array of integer;
      FGetSvrStr: Array of TGetSvrStr;
      FGetXStr: Array of TGetValStr;
      FGetYStr: Array of TGetValStr;
      FGetZStr: Array of TGetValStr;
      FMinZoom: Array of integer;
      FMaxZoom: Array of integer;
      function GetLayerCount: integer;
      procedure SetLayer(AValue: integer);

    public
      constructor Create(AName: String);
      destructor Destroy; override;
      procedure AddURL(Url: String; NbSvr, aMinZoom, aMaxZoom: integer;
        GetSvrStr: TGetSvrStr; GetXStr: TGetValStr; GetYStr: TGetValStr;
        GetZStr: TGetValStr);
      procedure GetZoomInfos(out AZoomMin, AZoomMax: integer);
      function GetUrlForTile(id: TTileId): String;
      procedure ToXML(ADoc: TXMLDocument; AParentNode: TDOMNode);
      property Name: String read FName;
      property LayerCount: integer read GetLayerCount;
      property Layer: integer read FLayer write SetLayer;
  end;


function GetLetterSvr(id: integer): String;
function GetYahooSvr(id: integer): String;
function GetYahooY(const Tile: TTileId): string;
function GetYahooZ(const Tile: TTileId): string;
function GetQuadKey(const Tile: TTileId): string;


implementation

function GetLetterSvr(id: integer): String;
begin
  Result := Char(Ord('a') + id);
end;

function GetQuadKey(const Tile: TTileId): string;
var
  i, d, m: Longword;
begin
  { Bing Maps Tile System
    http://msdn.microsoft.com/en-us/library/bb259689.aspx }
  Result := '';
  for i := Tile.Z downto 1 do
  begin
    d := 0;
    m := 1 shl (i - 1);
    if (Tile.x and m) <> 0 then
      Inc(d, 1);
    if (Tile.y and m) <> 0 then
      Inc(d, 2);
    Result := Result + IntToStr(d);
  end;
end;

function GetYahooSvr(id: integer): String;
Begin
  Result := IntToStr(id + 1);
end;

function GetYahooY(const Tile : TTileId): string;
begin
  Result := IntToStr( -(Tile.Y - (1 shl Tile.Z) div 2) - 1);
end;

function GetYahooZ(const Tile : TTileId): string;
Begin
  result := IntToStr(Tile.Z + 1);
end;


{ TMapProvider }

function TMapProvider.getLayerCount: integer;
begin
  Result:=length(FUrl);
end;

procedure TMapProvider.SetLayer(AValue: integer);
begin
  if FLayer = AValue then Exit;
  if (aValue < Low(FUrl)) and (aValue > High(FUrl)) then
  Begin
    Raise Exception.Create('bad Layer');
  end;
  FLayer:=AValue;
end;

constructor TMapProvider.Create(aName: String);
begin
  FName := aName;
end;

destructor TMapProvider.Destroy;
begin
  Finalize(idServer);
  Finalize(FName);
  Finalize(FUrl);
  Finalize(FNbSvr);
  Finalize(FGetSvrStr);
  Finalize(FGetXStr);
  Finalize(FGetYStr);
  Finalize(FGetZStr);
  Finalize(FMinZoom);
  Finalize(FMaxZoom);
  inherited;
end;

procedure TMapProvider.AddURL(Url: String; NbSvr: integer;
  aMinZoom: integer; aMaxZoom: integer; GetSvrStr: TGetSvrStr;
  GetXStr: TGetValStr; GetYStr: TGetValStr; GetZStr: TGetValStr);
var
  nb: integer;
begin
  nb := Length(FUrl)+1;
  SetLength(IdServer, nb);
  SetLength(FUrl, nb);
  SetLength(FNbSvr, nb);
  SetLength(FGetSvrStr, nb);
  SetLength(FGetXStr, nb);
  SetLength(FGetYStr, nb);
  SetLength(FGetZStr, nb);
  SetLength(FMinZoom, nb);
  SetLength(FMaxZoom, nb);
  nb := High(FUrl);
  FUrl[nb] := Url;
  FNbSvr[nb] := NbSvr;
  FMinZoom[nb] := aMinZoom;
  FMaxZoom[nb] := aMaxZoom;
  FGetSvrStr[nb] := GetSvrStr;
  FGetXStr[nb] := GetXStr;
  FGetYStr[nb] := GetYStr;
  FGetZStr[nb] := GetZStr;
  FLayer := Low(FUrl);
end;

procedure TMapProvider.GetZoomInfos(out AZoomMin, AZoomMax: integer);
begin
  AZoomMin := FMinZoom[layer];
  AZoomMax := FMaxZoom[layer];
end;

function TMapProvider.GetUrlForTile(id: TTileId): String;
var
  i: integer;
  XVal, yVal, zVal, SvrVal: String;
  idsvr: integer;
begin
  Result := '';
  i := layer;
  if (i > High(idServer)) or (i < Low(idServer)) or (FNbSvr[i] = 0) then
    exit;

  idsvr := idServer[i] mod FNbSvr[i];
  idServer[i] += 1;

  SvrVal := IntToStr(idsvr);
  XVal := IntToStr(id.X);
  YVal := IntToStr(id.Y);
  ZVal := IntToStr(id.Z);
  if Assigned(FGetSvrStr[i]) then
    SvrVal := FGetSvrStr[i](idsvr);
  if Assigned(FGetXStr[i]) then
    XVal := FGetXStr[i](id);
  if Assigned(FGetYStr[i]) then
    YVal := FGetYStr[i](id);
  if Assigned(FGetZStr[i]) then
    ZVal := FGetZStr[i](id);
  Result := StringReplace(FUrl[i], '%serv%', SvrVal, [rfreplaceall]);
  Result := StringReplace(Result, '%x%', XVal, [rfreplaceall]);
  Result := StringReplace(Result, '%y%', YVal, [rfreplaceall]);
  Result := StringReplace(Result, '%z%', ZVal, [rfreplaceall]);
end;

procedure TMapProvider.ToXML(ADoc: TXMLDocument; AParentNode: TDOMNode);
var
  i: Integer;
  node: TDOMElement;
  layerNode: TDOMElement;
  s: String;
begin
  node := ADoc.CreateElement('map_provider');
  node.SetAttribute('name', FName);
  AParentNode.AppendChild(node);
  for i:=0 to LayerCount-1 do begin
    layerNode := ADoc.CreateElement('layer');
    node.AppendChild(layernode);
    layerNode.SetAttribute('url', FUrl[i]);
    layerNode.SetAttribute('minZoom', IntToStr(FMinZoom[i]));
    layerNode.SetAttribute('maxZoom', IntToStr(FMaxZoom[i]));
    layerNode.SetAttribute('serverCount', IntToStr(FNbSvr[i]));

    if FGetSvrStr[i] = @getLetterSvr then s := 'Letter'
      else if FGetSvrStr[i] = @GetYahooSvr then s := 'Yahoo'
      else if FGetSvrstr[i] <> nil then s := 'unknown'
      else s := '';
    if s <> '' then layerNode.SetAttribute('serverProc', s);

    if FGetXStr[i] = @GetQuadKey then s := 'QuadKey'
      else if FGetXStr[i] <> nil then s := '(unknown)'
      else s := '';
    if s <> '' then layerNode.SetAttribute('xProc', s);

    if FGetYStr[i] = @GetQuadKey then s := 'QuadKey'
      else if FGetYStr[i] = @GetYahooY then s := 'YahooY'
      else if FGetYStr[i] <> nil then s := '(unknown)'
      else s := '';
    if s <> '' then layerNode.SetAttribute('yProc', s);

    if FGetZStr[i] = @GetQuadKey then s := 'QuadKey'
      else if FGetZStr[i] = @GetYahooZ then s := 'YahooZ'
      else if FGetZStr[i] <> nil then s := '(unknown)'
      else s := '';
    if s <> '' then layerNode.SetAttribute('zProc', s);
  end;
end;

end.

