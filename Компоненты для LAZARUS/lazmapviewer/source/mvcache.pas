{
  Picture cache manager (c) 2014 ti_dic

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
unit mvCache;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IntfGraphics, syncObjs,
  mvMapProvider, mvTypes;

Type

   { TPictureCache }

   TPictureCache = Class(TComponent)
   private
     FMemMaxElem: integer;
     Crit: TCriticalSection;
     Cache: TStringList;
     FBasePath: String;
     FUseDisk: Boolean;
     FUseThreads: Boolean;
     procedure SetUseThreads(AValue: Boolean);
     Procedure EnterCrit;
     Procedure LeaveCrit;
   protected
     function GetNewImgFor(aStream: TStream): TLazIntfImage;
     procedure FreeCache;
     Function MapProvider2FileName(MapProvider: TMapProvider): String;
     Function DiskCached(const aFileName: String): Boolean;
     procedure LoadFromDisk(const aFileName: String; out img: TLazIntfImage);
     Function GetFileName(MapProvider: TMapProvider; const TileId: TTileId): String;
   public
     Procedure CheckCacheSize(Sender: TObject);
     constructor Create(aOwner: TComponent); override;
     destructor Destroy; override;
     Procedure Add(MapProvider: TMapProvider; const TileId: TTileId; Stream: TMemoryStream);
     Procedure GetFromCache(MapProvider: TMapProvider; const TileId: TTileId; out img: TLazIntfImage);
     function InCache(MapProvider: TMapProvider; const TileId: TTileId): Boolean;

     property UseDisk: Boolean read FUseDisk write FUseDisk;
     property BasePath: String read FBasePath write FBasePath;
     property UseThreads: Boolean read FUseThreads write SetUseThreads;
   end;


implementation

uses
  FPimage, GraphType, FPReadJPEG;


{ TPictureCache }

function IsValidPNG(AStream: TStream): Boolean;
var
  s: string;
  y: Int64;
begin
  if Assigned(AStream) then
  begin
    SetLength(s, 3);
    y := AStream.Position;
    AStream.Position := 1;
    AStream.Read(s[1], 3);
    AStream.Position := y;
    Result := (s = 'PNG');
  end
  else
    Result := false;
end;

function IsValidJPEG(AStream: TStream): Boolean;
var
  s: string;
  y: Int64;
begin
  if Assigned(AStream) then
  begin
    SetLength(s, 4);
    y := AStream.Position;
    AStream.Position := 6;
    AStream.Read(s[1], 4);
    AStream.Position := y;
    Result := (s = 'JFIF') or (s = 'Exif');
  end
  else
    Result := false;
end;

constructor TPictureCache.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FMemMaxElem := 2048 div 256;
  Cache := TStringList.create;
end;

destructor TPictureCache.Destroy;
begin
  inherited;
  FreeCache;
  FreeAndNil(Crit);
end;

procedure TPictureCache.SetUseThreads(AValue: Boolean);
begin
  if FUseThreads = AValue then Exit;
  FUseThreads := AValue;
  if aValue then
    Crit := TCriticalSection.Create
  else
    FreeAndNil(Crit);
end;

procedure TPictureCache.EnterCrit;
begin
  if Assigned(Crit) then
    Crit.Enter;
end;

procedure TPictureCache.LeaveCrit;
begin
  if Assigned(Crit) then
    Crit.Leave;
end;

function TPictureCache.GetNewImgFor(aStream: TStream): TLazIntfImage;
var
  reader: TFPCustomImageReader;
  rawImg: TRawImage;
begin
  Result := nil;
  Reader := nil;
  if not Assigned(aStream) then
     exit;
  if IsValidJPEG(astream) then
    Reader := TFPReaderJPEG.create
  else
  if IsValidPNG(astream) then
    Reader  := TLazReaderPNG.create;
  if Assigned(reader) then
  begin
    try
      rawImg.Init;
      rawImg.Description.Init_BPP24_B8G8R8_BIO_TTB(TILE_SIZE, TILE_SIZE);
      Result := TLazIntfImage.Create(rawImg, true);
      try
         Result.LoadFromStream(aStream, reader);
      except
         FreeAndNil(Result);
      end;
    finally
      FreeAndNil(Reader)
    end;
  end;
end;

procedure TPictureCache.FreeCache;
var
  i: integer;
begin
  EnterCrit;
  try
    for i := 0 to pred(Cache.Count) do
      Cache.Objects[i].Free;
    Cache.Clear;
    Cache.Free;
  finally
    LeaveCrit;
  end;
end;

function TPictureCache.MapProvider2FileName(MapProvider: TMapProvider): String;
var
  i: integer;
begin
  Result := '';
  if Assigned(MapProvider) then
  begin
    Result := MapProvider.Name;
    for i := 1 to Length(Result) do
      if not (Result[i] in ['a'..'z', 'A'..'Z', '0'..'9', '_', '.']) then
        Result[i] := '-';
  end;
end;

function TPictureCache.DiskCached(const aFileNAme: String): Boolean;
var
  FullFileName: string;
begin
  if UseDisk then
  begin
    FullFileName := BasePath + aFileName;
    Result := FileExists(FullFileName);
  end
  else
    Result := False;
end;

procedure TPictureCache.LoadFromDisk(const aFileName: String;
  out img: TLazIntfImage);
var
  FullFileName: String;
  lStream: TFileStream;
begin
  img := nil;
  FullFileName := BasePath + aFileName;
  if FileExists(fullFileName) then
  begin
    lStream := TFileStream.Create(FullFileName, fmOpenRead);
    try
      try
        img := GetNewImgFor(lStream);
      except
        FreeAndNil(img);
      end;
      if Assigned(img) then
      begin
        EnterCrit;
        try
          Cache.AddObject(aFileName, img);
        finally
          LeaveCrit;
        end;
      end;
    finally
      lStream.Free;
    end;
  end;
end;

function TPictureCache.GetFileName(MapProvider: TMapProvider;
  const  TileId: TTileId): String;
begin
  Result := Format('%s_%d_%d_%d',
    [MapProvider2FileName(MapProvider), TileId.X, TileId.Y, TileId.Z]
  );
end;

procedure TPictureCache.CheckCacheSize(Sender: TObject);
var
  i, idx: integer;
begin
  EnterCrit;
  try
    if Cache.Count > FMemMaxElem then
    begin
      for i:=1 to 10 do
      begin
        idx := pred(Cache.Count);
        if idx > 1 then
        begin
          Cache.Objects[idx].Free;
          Cache.Delete(idx);
        end;
      end;
    end;
  finally
    LeaveCrit;
  end;
end;

procedure TPictureCache.Add(MapProvider: TMapProvider;
  const TileId: TTileId; Stream: TMemoryStream);
var
  FileName: String;
  img: TLazIntfImage;
  lFile: TFileStream;
  idx: integer;
begin
  FileName := GetFileName(MapProvider, TileId);
  EnterCrit;
  try
    idx := Cache.IndexOf(FileName);
    if idx <> -1 then
      Cache.Objects[idx].Free
    else
    begin
      Cache.Insert(0, FileName);
      idx := 0;
    end;
    img:= GetNewImgFor(Stream);
    Cache.Objects[idx]:=img;
  finally
    LeaveCrit;
  end;

  if UseDisk then
  begin
    if Assigned(img) then
    begin
      lFile := TFileStream.Create(BasePath + FileName, fmCreate);
      try
        Stream.Position := 0;
        lFile.CopyFrom(Stream, 0);
      finally
        FreeAndNil(lFile);
      end;
    end;
  end;

  if not FUseThreads then
    CheckCacheSize(self);
end;

procedure TPictureCache.GetFromCache(MapProvider: TMapProvider;
  const TileId: TTileId; out img: TLazIntfImage);
var
  FileName: String;
  idx: integer;
begin
  img := nil;
  FileName := GetFileName(MapProvider, TileId);
  EnterCrit;
  try
    idx := Cache.IndexOf(FileName);
    if idx <> -1 then
    begin
      img := TLazIntfImage(Cache.Objects[idx]);
      if Idx > FMemMaxElem div 2 then
      begin
        Cache.Delete(idx);
        Cache.Insert(0, FileName);
        Cache.Objects[0] := img;
      end;
    end;

  finally
    LeaveCrit;
  end;
  if idx = -1 then
  begin
    if UseDisk then
       LoadFromDisk(FileName, img);
  end;
end;

function TPictureCache.InCache(MapProvider: TMapProvider;
  const TileId: TTileId): Boolean;
var
  FileName: String;
  idx: integer;
begin
  FileName := GetFileName(MapProvider, TileId);
  EnterCrit;
  try
    idx := Cache.IndexOF(FileNAme);
  finally
    LeaveCrit;
  end;
  if idx <> -1 then
     Result := True
  else
     Result := DiskCached(FileName);
end;

end.

