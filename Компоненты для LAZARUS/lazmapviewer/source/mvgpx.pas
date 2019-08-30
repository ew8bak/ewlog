{ Reads/writes GPX files }

unit mvGPX;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, laz2_DOM, laz2_XMLRead, DateUtils,
  mvTypes, mvGpsObj;

type
  TGpxReader = class
  private
    ID: Integer;
    FMinLat, FMinLon, FMaxLat, FMaxLon: Double;
  protected
    procedure ReadExtensions(ANode: TDOMNode; ATrack: TGpsTrack);
    function ReadPoint(ANode: TDOMNode): TGpsPoint;
    procedure ReadRoute(ANode: TDOMNode; AList: TGpsObjectlist);
    procedure ReadTrack(ANode: TDOMNode; AList: TGpsObjectList);
    procedure ReadTracks(ANode: TDOMNode; AList: TGpsObjectList);
    procedure ReadTrackSegment(ANode: TDOMNode; ATrack: TGpsTrack);
    procedure ReadWayPoints(ANode: TDOMNode; AList: TGpsObjectList);
  public
    procedure LoadFromFile(AFileName: String; AList: TGpsObjectList; out ABounds: TRealArea);
    procedure LoadFromStream(AStream: TStream; AList: TGpsObjectList; out ABounds: TRealArea);
  end;


implementation

uses
  Math,
  mvExtraData;

var
  PointSettings: TFormatSettings;

function ExtractISODateTime(AText: String): TDateTime;
type
  TISODateRec = packed record
    Y: array[0..3] of ansichar;
    SepYM: ansichar;
    M: array[0..1] of ansichar;
    SepMD: ansichar;
    D: array[0..1] of ansichar;
  end;
  PISODateRec = ^TISODateRec;
  TISOTimeRec = packed record
    H: array[0..1] of ansichar;
    SepHM: ansichar;
    M: array[0..1] of ansichar;
    SepMS: ansiChar;
    S: array[0..1] of ansichar;
    DecSep: ansichar;
    MS: array[0..2] of ansichar;
  end;
  PISOTimeRec = ^TISOTimeRec;
const
  NUMBER: array['0'..'9'] of Integer = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
var
  yr,mon,dy, hr,mn,sec,s1000: Integer;
begin
  if Pos('T', AText) = 11 then begin
    with PISODateRec(PChar(@AText[1]))^ do begin
      yr := 1000*NUMBER[Y[0]] + 100*NUMBER[Y[1]] + 10*NUMBER[Y[2]] + NUMBER[Y[3]];
      mon := 10*NUMBER[M[0]] + NUMBER[M[1]];
      dy := 10*NUMBER[D[0]] + NUMBER[D[1]];
    end;
    with PISOTimeRec(PChar(@AText[12]))^ do begin
      hr := 10*NUMBER[H[0]] + NUMBER[H[1]];
      mn := 10*NUMBER[M[0]] + NUMBER[M[1]];
      sec := 10*NUMBER[S[0]] + NUMBER[S[1]];
      s1000 := 100*NUMBER[MS[0]] + 10*NUMBER[MS[1]] + NUMBER[MS[2]];
    end;
    Result := EncodeDate(yr, mon, dy) + EncodeTime(hr, mn, sec, s1000);
  end else
  if not TryStrToDateTime(AText, Result) then
    Result := NO_DATE;
end;

function GetAttrValue(ANode: TDOMNode; AAttrName: string) : string;
var
  i: LongWord;
  Found: Boolean;
begin
  Result := '';
  if (ANode = nil) or (ANode.Attributes = nil) then
    exit;

  Found := false;
  i := 0;
  while not Found and (i < ANode.Attributes.Length) do begin
    if ANode.Attributes.Item[i].NodeName = AAttrName then begin
      Found := true;
      Result := ANode.Attributes.Item[i].NodeValue;
    end;
    inc(i);
  end;
end;

function GetNodeValue(ANode: TDOMNode): String;
var
  child: TDOMNode;
begin
  Result := '';
  child := ANode.FirstChild;
  if Assigned(child) and (child.NodeName = '#text') then
    Result := child.NodeValue;
end;

function TryStrToGpxColor(AGpxText: String; out AColor: LongInt): Boolean;
type
  PGpxColorRec = ^TGpxColorRec;
  TGpxColorRec = record
    r: array[0..1] of char;
    g: array[0..1] of char;
    b: array[0..1] of char;
  end;
var
  rv, gv, bv: Integer;
  ch: Char;
begin
  Result := false;
  if Length(AGpxText) <> 6 then
    exit;
  for ch in AGpxText do
    if not (ch in ['0'..'9', 'A'..'F', 'a'..'f']) then exit;

  with PGpxColorRec(@AGpxText[1])^ do begin
    rv := (ord(r[0]) - ord('0')) * 16 + ord(r[1]) - ord('0');
    gv := (ord(g[0]) - ord('0')) * 16 + ord(g[1]) - ord('0');
    bv := (ord(b[0]) - ord('0')) * 16 + ord(b[1]) - ord('0');
  end;
  AColor := rv + gv shl 8 + bv shl 16;
  Result := true;
end;


{ TGpxReader }

procedure TGpxReader.LoadFromFile(AFileName: String; AList: TGpsObjectList;
  out ABounds: TRealArea);
var
  stream: TStream;
begin
  stream := TFileStream.Create(AFileName, fmOpenRead + fmShareDenyNone);
  try
    LoadFromStream(stream, AList, ABounds);
  finally
    stream.Free;
  end;
end;

procedure TGpxReader.LoadFromStream(AStream: TStream; AList: TGpsObjectList;
  out ABounds: TRealArea);
var
  doc: TXMLDocument = nil;
begin
  try
    ID := random(MaxInt - 1000) + 1000;
    FMinLon := 9999; FMinLat := 9999;
    FMaxLon := -9999; FMaxLat := -9999;
    ReadXMLFile(doc, AStream);
    ReadWayPoints(doc.DocumentElement.FindNode('wpt'), AList);
    ReadTracks(doc.DocumentElement.FindNode('trk'), AList);
    ReadRoute(doc.DocumentElement.FindNode('rte'), AList);
    ABounds.TopLeft.Lon := FMinLon;
    ABounds.TopLeft.Lat := FMaxLat;
    ABounds.BottomRight.Lon := FMaxLon;
    ABounds.BottomRight.Lat := FMinLat;
  finally
    doc.Free;
  end;
end;

procedure TGpxReader.ReadExtensions(ANode: TDOMNode; ATrack: TGpsTrack);
var
  linenode: TDOMNode;
  childNode: TDOMNode;
  nodeName: string;
  color: LongInt;
  w: Double = -1;
  colorUsed: Boolean = false;
  s: String;
begin
  if ANode = nil then
    exit;

  lineNode := ANode.FirstChild;
  while lineNode <> nil do begin
    nodeName := lineNode.NodeName;
    if nodeName = 'line' then begin
      childNode := lineNode.FirstChild;
      while childNode <> nil do begin
        nodeName := childNode.NodeName;
        s := GetNodeValue(childNode);
        case nodeName of
          'color':
            if TryStrToGpxColor(s, color) then colorUsed := true;
          'width':
            TryStrToFloat(s, w, PointSettings);
        end;
        childNode := childNode.NextSibling;
      end;
    end;
    lineNode := lineNode.NextSibling;
  end;

  if (w <> -1) or colorUsed then begin
    if ATrack.ExtraData = nil then
      ATrack.ExtraData := TTrackExtraData.Create(ID);
    if (ATrack.ExtraData is TTrackExtraData) then begin
      TTrackExtraData(ATrack.ExtraData).Width := w;
      TTrackExtraData(ATrack.ExtraData).Color := color;
    end;
  end;
end;

function TGpxReader.ReadPoint(ANode: TDOMNode): TGpsPoint;
var
  s, slon, slat, sName: String;
  lon, lat, ele: Double;
  dt: TDateTime;
  node: TDOMNode;
  nodeName: String;
begin
  Result := nil;
  if ANode = nil then
    exit;

  slon := GetAttrValue(ANode, 'lon');
  slat := GetAttrValue(ANode, 'lat');
  if (slon = '') or (slat = '') then
    exit;

  if not TryStrToFloat(slon, lon, PointSettings) then
    exit;
  if not TryStrToFloat(slat, lat, PointSettings) then
    exit;

  sName := '';
  dt := NO_DATE;
  ele := NO_ELE;
  node := ANode.FirstChild;
  while node <> nil do begin
    nodeName := node.NodeName;
    case nodeName of
      'ele' :
        begin
          s := GetNodeValue(node);
          if s <> '' then
            TryStrToFloat(s, ele, PointSettings);
        end;
      'name':
        sName := GetNodeValue(node);
      'time':
        begin
          s := GetNodeValue(node);
          if s <> '' then
            dt := ExtractISODateTime(s);
        end;
    end;
    node := node.NextSibling;
  end;
  Result := TGpsPoint.Create(lon, lat, ele, dt);
  Result.Name := sname;
  FMinLon := Min(FMinLon, lon);
  FMaxLon := Max(FMaxLon, lon);
  FMinLat := Min(FMinLat, lat);
  FMaxLat := Max(FMaxLat, lat);
end;

procedure TGpxReader.ReadRoute(ANode: TDOMNode; AList: TGpsObjectlist);
var
  trk: TGpsTrack;
  nodeName: string;
  pt: TGpsPoint;
  trkName: String;
begin
  if ANode = nil then
    exit;
  ANode := ANode.FirstChild;
  if ANode = nil then
    exit;
  trk := TGpsTrack.Create;
  while ANode <> nil do begin
    nodeName := ANode.NodeName;
    case nodeName of
      'name':
        trkName := GetNodeValue(ANode);
      'rtept':
        begin
          pt := ReadPoint(ANode);
          if pt <> nil then trk.Points.Add(pt);
        end;
    end;
    ANode := ANode.NextSibling;
  end;
  trk.Name := trkName;
  AList.Add(trk, ID);
end;

procedure TGpxReader.ReadTrack(ANode: TDOMNode; AList: TGpsObjectList);
var
  trk: TGpsTrack;
  nodeName: string;
  pt: TGpsPoint;
  trkName: String = '';
begin
  if ANode = nil then
    exit;
  ANode := ANode.FirstChild;
  if ANode = nil then
    exit;

  trk := TGpsTrack.Create;
  while ANode <> nil do begin
    nodeName := ANode.NodeName;
    case nodeName of
      'name':
        trkName := GetNodeValue(ANode);
      'trkseg':
        ReadTrackSegment(ANode.FirstChild, trk);
      'trkpt':
        begin
          pt := ReadPoint(ANode);
          if pt <> nil then trk.Points.Add(pt);
        end;
      'extensions':
        ReadExtensions(ANode, trk);
    end;
    ANode := ANode.NextSibling;
  end;
  trk.Name := trkName;
  AList.Add(trk, ID);
end;

procedure TGpxReader.ReadTracks(ANode: TDOMNode; AList: TGpsObjectList);
var
  nodeName: String;
begin
  while ANode <> nil do begin
    nodeName := ANode.NodeName;
    if nodeName = 'trk' then
      ReadTrack(ANode, AList);
    ANode := ANode.NextSibling;
  end;
end;

procedure TGpxReader.ReadTrackSegment(ANode: TDOMNode; ATrack: TGpsTrack);
var
  gpsPt: TGpsPoint;
  nodeName: String;
begin
  while ANode <> nil do begin
    nodeName := ANode.NodeName;
    if nodeName = 'trkpt' then begin
      gpsPt := ReadPoint(ANode);
      if gpsPt <> nil then
        ATrack.Points.Add(gpsPt);
    end;
    ANode := ANode.NextSibling;
  end;
end;

procedure TGpxReader.ReadWayPoints(ANode: TDOMNode; AList: TGpsObjectList);
var
  nodeName: String;
  gpsPt: TGpsPoint;
begin
  while ANode <> nil do begin
    nodeName := ANode.NodeName;
    if nodeName = 'wpt' then begin
      gpsPt := ReadPoint(ANode);
      if gpsPt <> nil then
        AList.Add(gpsPt, ID);
    end;
    ANode := ANode.NextSibling;
  end;
end;

initialization
  PointSettings := DefaultFormatSettings;
  PointSettings.DecimalSeparator := '.';

end.

