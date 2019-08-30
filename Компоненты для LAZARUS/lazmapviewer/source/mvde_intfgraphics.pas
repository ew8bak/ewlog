unit mvDE_IntfGraphics;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Types, LazVersion,
  FPImage, FPCanvas, IntfGraphics,
  mvDrawingEngine;

type
  TMvIntfGraphicsDrawingEngine = class(TMvCustomDrawingEngine)
  private
    FBuffer: TLazIntfImage;
    FCanvas: TFPCustomCanvas;
    FFontName: String;
    FFontColor: TColor;
    FFontSize: Integer;
    FFontStyle: TFontStyles;
    procedure CreateLazIntfImageAndCanvas(out ABuffer: TLazIntfImage;
      out ACanvas: TFPCustomCanvas; AWidth, AHeight: Integer);
  protected
    function GetBrushColor: TColor; override;
    function GetBrushStyle: TBrushStyle; override;
    function GetFontColor: TColor; override;
    function GetFontName: String; override;
    function GetFontSize: Integer; override;
    function GetFontStyle: TFontStyles; override;
    function GetPenColor: TColor; override;
    function GetPenWidth: Integer; override;
    procedure SetBrushColor(AValue: TColor); override;
    procedure SetBrushStyle(AValue: TBrushStyle); override;
    procedure SetFontColor(AValue: TColor); override;
    procedure SetFontName(AValue: String); override;
    procedure SetFontSize(AValue: Integer); override;
    procedure SetFontStyle(AValue: TFontStyles); override;
    procedure SetPenColor(AValue: TColor); override;
    procedure SetPenWidth(AValue: Integer); override;
  public
    destructor Destroy; override;
    procedure CreateBuffer(AWidth, AHeight: Integer); override;
    procedure DrawBitmap(X, Y: Integer; ABitmap: TCustomBitmap;
      UseAlphaChannel: Boolean); override;
    procedure DrawLazIntfImage(X, Y: Integer; AImg: TLazIntfImage); override;
    procedure Ellipse(X1, Y1, X2, Y2: Integer); override;
    procedure FillRect(X1, Y1, X2, Y2: Integer); override;
    procedure Line(X1, Y1, X2, Y2: Integer); override;
    procedure PaintToCanvas(ACanvas: TCanvas); override;
    procedure Rectangle(X1, Y1, X2, Y2: Integer); override;
    function SaveToImage(AClass: TRasterImageClass): TRasterImage; override;
    function TextExtent(const AText: String): TSize; override;
    procedure TextOut(X, Y: Integer; const AText: String); override;
  end;


implementation

uses
  LCLType,
  FPImgCanv, GraphType;

{$IF Laz_FullVersion < 1090000}
// Workaround for http://mantis.freepascal.org/view.php?id=27144
procedure CopyPixels(ASource, ADest: TLazIntfImage;
  XDst: Integer = 0; YDst: Integer = 0;
  AlphaMask: Boolean = False; AlphaTreshold: Word = 0);
var
  SrcHasMask, DstHasMask: Boolean;
  x, y, xStart, yStart, xStop, yStop: Integer;
  c: TFPColor;
  SrcRawImage, DestRawImage: TRawImage;
begin
  ASource.GetRawImage(SrcRawImage);
  ADest.GetRawImage(DestRawImage);

  if DestRawImage.Description.IsEqual(SrcRawImage.Description) and (XDst =  0) and (YDst = 0) then
  begin
    // same description -> copy
    if DestRawImage.Data <> nil then
      System.Move(SrcRawImage.Data^, DestRawImage.Data^, DestRawImage.DataSize);
    if DestRawImage.Mask <> nil then
      System.Move(SrcRawImage.Mask^, DestRawImage.Mask^, DestRawImage.MaskSize);
    Exit;
  end;

  // copy pixels
  XStart := IfThen(XDst < 0, -XDst, 0);
  YStart := IfThen(YDst < 0, -YDst, 0);
  XStop := IfThen(ADest.Width - XDst < ASource.Width, ADest.Width - XDst, ASource.Width) - 1;
  YStop := IfTHen(ADest.Height - YDst < ASource.Height, ADest.Height - YDst, ASource.Height) - 1;

  SrcHasMask := SrcRawImage.Description.MaskBitsPerPixel > 0;
  DstHasMask := DestRawImage.Description.MaskBitsPerPixel > 0;

  if DstHasMask then begin
    for y:= yStart to yStop do
      for x:=xStart to xStop do
        ADest.Masked[x+XDst,y+YDst] := SrcHasMask and ASource.Masked[x,y];
  end;

  for y:=yStart to yStop do
    for x:=xStart to xStop do
    begin
      c := ASource.Colors[x,y];
      if not DstHasMask and SrcHasMask and (c.alpha = $FFFF) then // copy mask to alpha channel
        if ASource.Masked[x,y] then
          c.alpha := 0;

      ADest.Colors[x+XDst,y+YDst] := c;
      if AlphaMask and (c.alpha < AlphaTreshold) then
        ADest.Masked[x+XDst,y+YDst] := True;
    end;
end;
{$IFEND}


destructor TMvIntfGraphicsDrawingEngine.Destroy;
begin
  FCanvas.Free;
  FBuffer.Free;
  inherited;
end;

procedure TMvIntfGraphicsDrawingEngine.CreateBuffer(AWidth, AHeight: Integer);
begin
  FCanvas.Free;
  FBuffer.Free;
  CreateLazIntfImageAndCanvas(FBuffer, FCanvas, AWidth, AHeight);
end;

procedure TMvIntfGraphicsDrawingEngine.CreateLazIntfImageAndCanvas(
  out ABuffer: TLazIntfImage;
  out ACanvas: TFPCustomCanvas; AWidth, AHeight: Integer);
var
  rawImg: TRawImage;
begin
  rawImg.Init;
  {$IFDEF DARWIN}
  rawImg.Description.Init_BPP32_A8R8G8B8_BIO_TTB(AWidth, AHeight);
  {$ELSE}
  rawImg.Description.Init_BPP32_B8G8R8_BIO_TTB(AWidth, AHeight);
//  rawImg.Description.Init_BPP32_B8G8R8A8_BIO_TTB(AWidth, AHeight);
  {$ENDIF}
  rawImg.CreateData(True);
  ABuffer := TLazIntfImage.Create(rawImg, true);
  ACanvas := TFPImageCanvas.Create(ABuffer);
  ACanvas.Brush.FPColor := colWhite;
  ACanvas.FillRect(0, 0, AWidth, AHeight);
end;

procedure TMvIntfGraphicsDrawingEngine.DrawBitmap(X, Y: Integer;
  ABitmap: TCustomBitmap; UseAlphaChannel: Boolean);
var
  intfImg: TLazIntfImage;
  i, j: Integer;
  cimg, cbuf: TFPColor;
  alpha: Double;
begin
  intfImg := ABitmap.CreateIntfImage;
  try
    if UseAlphaChannel then begin
      for j := 0 to intfImg.Height - 1 do
        for i := 0 to intfImg.Width - 1 do begin
          cimg := intfImg.Colors[i, j];
          alpha := cimg.Alpha / word($FFFF);
          cbuf := FBuffer.Colors[i + X, j + Y];
          cbuf.Red := Round(alpha * cimg.Red + (1 - alpha) * cbuf.Red);
          cbuf.Green := Round(alpha * cimg.Green + (1 - alpha) * cbuf.Green);
          cbuf.Blue := Round(alpha * cimg.Blue + (1 - alpha) * cbuf.Blue);
          FBuffer.Colors[i + X, j + Y] := cbuf;
        end;
    end else
      for j := 0 to intfImg.Height - 1 do
        for i := 0 to intfImg.Width - 1 do
          FBuffer.Colors[i + X, j + Y] := intfImg.Colors[i, j];
  finally
    intfimg.Free;
  end;
end;

procedure TMvIntfGraphicsDrawingEngine.DrawLazIntfImage(X, Y: Integer;
  AImg: TLazIntfImage);
begin
  {$IF Laz_FullVersion < 1090000}
  { Workaround for //http://mantis.freepascal.org/view.php?id=27144 }
  CopyPixels(AImg, Buffer, X, Y);
  {$ELSE}
  FBuffer.CopyPixels(AImg, X, Y);
  {$IFEND}
end;

procedure TMvIntfGraphicsDrawingEngine.Ellipse(X1, Y1, X2, Y2: Integer);
begin
  if FCanvas <> nil then
    FCanvas.Ellipse(X1,Y1, X2, Y2);
end;

procedure TMvIntfGraphicsDrawingEngine.FillRect(X1, Y1, X2, Y2: Integer);
begin
  if FCanvas <> nil then
    FCanvas.FillRect(X1,Y1, X2, Y2);
end;

function TMvIntfGraphicsDrawingEngine.GetBrushColor: TColor;
begin
  if FCanvas <> nil then
    Result := FPColorToTColor(FCanvas.Brush.FPColor)
  else
    Result := 0;
end;

function TMvIntfGraphicsDrawingEngine.GetBrushStyle: TBrushStyle;
begin
  if FCanvas <> nil then
    Result := FCanvas.Brush.Style
  else
    Result := bsSolid;
end;

function TMvIntfGraphicsDrawingEngine.GetFontColor: TColor;
begin
  Result := FFontColor
end;

function TMvIntfGraphicsDrawingEngine.GetFontName: String;
begin
  Result := FFontName;
end;

function TMvIntfGraphicsDrawingEngine.GetFontSize: Integer;
begin
  Result := FFontSize;
end;

function TMvIntfGraphicsDrawingEngine.GetFontStyle: TFontStyles;
begin
  Result := FFontStyle;
end;

function TMvIntfGraphicsDrawingEngine.GetPenColor: TColor;
begin
  if FCanvas <> nil then
    Result := FPColorToTColor(FCanvas.Pen.FPColor)
  else
    Result := 0;
end;

function TMvIntfGraphicsDrawingEngine.GetPenWidth: Integer;
begin
  if FCanvas <> nil then
    Result := FCanvas.Pen.Width
  else
    Result := 0;
end;

procedure TMvIntfGraphicsDrawingEngine.Line(X1, Y1, X2, Y2: Integer);
begin
  if FCanvas <> nil then
    FCanvas.Line(X1, Y1, X2, Y2);
end;

procedure TMvIntfGraphicsDrawingEngine.PaintToCanvas(ACanvas: TCanvas);
var
  bmp: TBitmap;
begin
  if FCanvas <> nil then begin
    bmp := TBitmap.Create;
    try
      bmp.PixelFormat := pf32Bit;
      bmp.SetSize(FBuffer.Width, FBuffer.Height);
      bmp.LoadFromIntfImage(FBuffer);
      ACanvas.Draw(0, 0, bmp);
    finally
      bmp.Free;
    end;
  end;
end;

procedure TMvIntfGraphicsDrawingEngine.Rectangle(X1, Y1, X2, Y2: Integer);
begin
  if FCanvas <> nil then
    FCanvas.Rectangle(X1,Y1, X2, Y2);
end;

function TMvIntfGraphicsDrawingEngine.SaveToImage(AClass: TRasterImageClass): TRasterImage;
begin
  Result := AClass.Create;
  Result.Width := FBuffer.Width;
  Result.Height := FBuffer.Height;
  Result.Canvas.FillRect(0, 0, Result.Width, Result.Height);
  Result.LoadFromIntfImage(FBuffer);
end;

procedure TMvIntfGraphicsDrawingEngine.SetBrushColor(AValue: TColor);
begin
  if FCanvas <> nil then
    FCanvas.Brush.FPColor := TColorToFPColor(AValue);
end;

procedure TMvIntfGraphicsDrawingEngine.SetBrushStyle(AValue: TBrushStyle);
begin
  if FCanvas <> nil then
    FCanvas.Brush.Style := AValue;
end;

procedure TMvIntfGraphicsDrawingEngine.SetFontColor(AValue: TColor);
begin
  FFontColor := AValue;
end;

procedure TMvIntfGraphicsDrawingEngine.SetFontName(AValue: String);
begin
  FFontName := AValue;
end;

procedure TMvIntfGraphicsDrawingEngine.SetFontSize(AValue: Integer);
begin
  FFontSize := AValue;
end;

procedure TMvIntfGraphicsDrawingEngine.SetFontStyle(AValue: TFontStyles);
begin
  FFontStyle := AValue;
end;

procedure TMvIntfGraphicsDrawingEngine.SetPenColor(AValue: TColor);
begin
  if FCanvas <> nil then
    FCanvas.Pen.FPColor := TColorToFPColor(AValue);
end;

procedure TMvIntfGraphicsDrawingEngine.SetPenWidth(AValue: Integer);
begin
  if FCanvas <> nil then
    FCanvas.Pen.Width := AValue;
end;

function TMvIntfGraphicsDrawingEngine.TextExtent(const AText: String): TSize;
var
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  try
    bmp.SetSize(1, 1);
    bmp.Canvas.Font.Name := FFontName;
    bmp.Canvas.Font.Size := FFontSize;
    bmp.Canvas.Font.Style := FFontStyle;
    Result := bmp.Canvas.TextExtent(AText);
  finally
    bmp.Free;
  end;
end;

procedure TMvIntfGraphicsDrawingEngine.TextOut(X, Y: Integer; const AText: String);
var
  bmp: TBitmap;
  ex: TSize;
  img: TLazIntfImage;
  i, j: Integer;
  hb, hm: HBitmap;
  c: TColor;
  fc, tc: TFPColor;
  intens, intens0: Int64;
  alpha: Double;
begin
  if (FCanvas = nil) or (AText = '') then
    exit;

  bmp := TBitmap.Create;
  try
    bmp.PixelFormat := pf32Bit;
    bmp.SetSize(1, 1);
    bmp.Canvas.Font.Name := FFontName;
    bmp.Canvas.Font.Size := FFontSize;
    bmp.Canvas.Font.Style := FFontStyle;
    bmp.Canvas.Font.Color := FFontColor;
    ex := bmp.Canvas.TextExtent(AText);
    bmp.SetSize(ex.CX, ex.CY);
    if GetBrushStyle <> bsClear then begin
      bmp.Canvas.Brush.Color := GetBrushColor;
      bmp.Canvas.FillRect(0, 0, bmp.Width, bmp.Height);
      bmp.Canvas.TextOut(0, 0, AText);
      DrawBitmap(X, Y, bmp, false);
    end else
    begin
      if FFontColor = clWhite then
        bmp.Canvas.Brush.Color := clBlack
      else
        bmp.Canvas.Brush.Color := clWhite;
      bmp.Canvas.FillRect(0, 0, bmp.Width, bmp.Height);
      bmp.Canvas.TextOut(0, 0, AText);

      img := bmp.CreateIntfImage;
      try
        fc := TColorToFPColor(bmp.Canvas.Font.Color);
        intens0 := (fc.Red + fc.Green + fc.Blue);
        for j := 0 to img.Height - 1 do
          for i := 0 to img.Width - 1 do begin
            c := bmp.Canvas.Pixels[i, j];
            tc := TColorToFPColor(c);
            if c = bmp.Canvas.Brush.Color then
              tc.Alpha := alphaTransparent
            else if c = FFontColor then
              tc.Alpha := alphaOpaque
            else begin
              intens := tc.Red + tc.Green + tc.Blue;
              if intens0 = 0 then
                alpha := (3 * alphaopaque - intens) / (3 * alphaOpaque - intens0)
              else
                alpha := intens / intens0;
              tc.Alpha := round(alphaOpaque * alpha);
            end;
            img.Colors[i, j] := tc;
          end;
        img.CreateBitmaps(hb, hm);
        bmp.Handle := hb;
        bmp.MaskHandle := hm;
        DrawBitmap(X, Y, bmp, true);
      finally
        img.Free;
      end;
    end;
  finally
    bmp.Free;
  end;
end;

end.

