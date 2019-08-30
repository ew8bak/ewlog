unit mvDE_RGBGraphics;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Graphics, IntfGraphics,
  mvDrawingEngine,
  rgbGraphics;

type

  { TMvRGBGraphicsDrawingEngine }

  TMvRGBGraphicsDrawingEngine = class(TMvCustomDrawingEngine)
  private
    FBuffer: TRGB32Bitmap;
    FBrushStyle: TBrushStyle;
    FFontName: String;
    FFontColor: TColor;
    FFontSize: Integer;
    FFontStyle: TFontStyles;
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

procedure Register;


implementation

uses
  GraphType, LCLType, FPImage,
  mvTypes;

procedure Register;
begin
  RegisterComponents(PALETTE_PAGE, [TMvRGBGraphicsDrawingEngine]);
end;

destructor TMvRGBGraphicsDrawingEngine.Destroy;
begin
  FBuffer.Free;
  inherited;
end;

procedure TMvRGBGraphicsDrawingEngine.CreateBuffer(AWidth, AHeight: Integer);
begin
  FreeAndNil(FBuffer);
  FBuffer := TRGB32Bitmap.Create(AWidth, AHeight);
end;

procedure TMvRGBGraphicsDrawingEngine.DrawBitmap(X,Y: Integer;
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
          cbuf := TColorToFPColor(FBuffer.Canvas.GetColor(i + X, j + Y));
          cbuf.Red := Round(alpha * cimg.Red + (1 - alpha) * cbuf.Red);
          cbuf.Green := Round(alpha * cimg.Green + (1 - alpha) * cbuf.Green);
          cbuf.Blue := Round(alpha * cimg.Blue + (1 - alpha) * cbuf.Blue);
          FBuffer.Canvas.SetColor(i + X, j + Y, FPColorToTColor(cbuf));
        end;
    end else
      for j := 0 to intfImg.Height - 1 do
        for i := 0 to intfImg.Width - 1 do
          FBuffer.Canvas.SetColor(i + X, j + Y, FPColorToTColor(intfImg.Colors[i, j]));
  finally
    intfimg.Free;
  end;
end;

procedure TMvRGBGraphicsDrawingEngine.DrawLazIntfImage(X, Y: Integer;
  AImg: TLazIntfImage);
//http://mantis.freepascal.org/view.php?id=27144
var
  temp: TRGB32Bitmap;
  rawImg: TRawImage;
  intfImg: TLazIntfImage;
begin
  rawImg.Init;
  {$IFDEF DARWIN}
  rawImg.Description.Init_BPP32_A8R8G8B8_BIO_TTB(FBuffer.Width, FBuffer.Height);
  {$ELSE}
  rawImg.Description.Init_BPP32_B8G8R8_BIO_TTB(FBuffer.Width, FBuffer.Height);
  {$ENDIF}
  rawImg.Description.Init_BPP32_B8G8R8A8_BIO_TTB(FBuffer.Width, FBuffer.Height);
  rawImg.Data := FBuffer.Pixels;
  intfImg := TLazIntfImage.Create(rawImg, false);
  try
    intfImg.CopyPixels(AImg, X, Y);
//    rawImg.Init;  // ???
  finally
    intfImg.Free;
  end;
end;

procedure TMvRGBGraphicsDrawingEngine.Ellipse(X1, Y1, X2, Y2: Integer);
begin
  FBuffer.Canvas.Ellipse(X1, Y1, X2, Y2);
end;

procedure TMvRGBGraphicsDrawingEngine.FillRect(X1, Y1, X2, Y2: Integer);
begin
  FBuffer.Canvas.FillRect(X1, Y1, X2, Y2);
end;

function TMvRGBGraphicsDrawingEngine.GetBrushColor: TColor;
begin
  Result := FBuffer.Canvas.FillColor;
end;

function TMvRGBGraphicsDrawingEngine.GetBrushStyle: TBrushStyle;
begin
  Result := FBrushStyle;
end;

function TMvRGBGraphicsDrawingEngine.GetFontColor: TColor;
begin
  Result := FFontColor
end;

function TMvRGBGraphicsDrawingEngine.GetFontName: String;
begin
  Result := FFontName;
end;

function TMvRGBGraphicsDrawingEngine.GetFontSize: Integer;
begin
  Result := FFontSize;
end;

function TMvRGBGraphicsDrawingEngine.GetFontStyle: TFontStyles;
begin
  Result := FFontStyle;
end;

function TMvRGBGraphicsDrawingEngine.GetPenColor: TColor;
begin
  Result := FBuffer.Canvas.OutlineColor;
end;

function TMvRGBGraphicsDrawingEngine.GetPenWidth: Integer;
begin
  Result := 1;  // No pen width support in Rgb32Bitmap
end;

procedure TMvRGBGraphicsDrawingEngine.Line(X1, Y1, X2, Y2: Integer);
begin
  FBuffer.Canvas.Line(X1, Y1, X2, Y2);
end;

procedure TMvRGBGraphicsDrawingEngine.PaintToCanvas(ACanvas: TCanvas);
begin
  FBuffer.Canvas.DrawTo(ACanvas, 0, 0);
end;

procedure TMvRGBGraphicsDrawingEngine.Rectangle(X1, Y1, X2, Y2: Integer);
begin
  FBuffer.Canvas.Rectangle(X1, Y1, X2, Y2);
end;

function TMvRGBGraphicsDrawingEngine.SaveToImage(AClass: TRasterImageClass): TRasterImage;
begin
  Result := AClass.Create;
  Result.Width := FBuffer.Width;
  Result.Height := FBuffer.Height;
  Result.Canvas.FillRect(0, 0, FBuffer.Width, FBuffer.Height);
  FBuffer.Canvas.DrawTo(Result.Canvas, 0, 0);
end;

procedure TMvRGBGraphicsDrawingEngine.SetBrushColor(AValue: TColor);
begin
  FBuffer.Canvas.FillColor := AValue;
end;

procedure TMvRGBGraphicsDrawingEngine.SetBrushStyle(AValue: TBrushStyle);
begin
  FBrushStyle := AValue;
  // No direct brush style support in RGB32Bitmap
end;

procedure TMvRGBGraphicsDrawingEngine.SetFontColor(AValue: TColor);
begin
  FFontColor := AValue;
end;

procedure TMvRGBGraphicsDrawingEngine.SetFontName(AValue: String);
begin
  FFontName := AValue;
end;

procedure TMvRGBGraphicsDrawingEngine.SetFontSize(AValue: Integer);
begin
  FFontSize := AValue;
end;

procedure TMvRGBGraphicsDrawingEngine.SetFontStyle(AValue: TFontStyles);
begin
  FFontStyle := AValue;
end;

procedure TMvRGBGraphicsDrawingEngine.SetPenColor(AValue: TColor);
begin
  FBuffer.Canvas.OutlineColor := AValue;
end;

procedure TMvRGBGraphicsDrawingEngine.SetPenWidth(AValue: Integer);
begin
  // Can't set pen width in TRGB32Bitmap
end;

function TMvRGBGraphicsDrawingEngine.TextExtent(const AText: String): TSize;
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

(*
procedure TMvRGBGraphicsDrawingEngine.TextOut(X, Y: Integer; const AText: String);
var
  bmp: TBitmap;
  ex: TSize;
  img: TLazIntfImage;
  brClr: TFPColor;
  imgClr: TFPColor;
  i, j: Integer;
begin
  if (AText = '') then
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
    bmp.Canvas.Brush.Color := GetBrushColor;
    if GetBrushStyle = bsClear then
      bmp.Canvas.Brush.Style := bsSolid
    else
      bmp.Canvas.Brush.Style := GetBrushStyle;
    bmp.Canvas.FillRect(0, 0, bmp.Width, bmp.Height);
    bmp.Canvas.TextOut(0, 0, AText);
    img := bmp.CreateIntfImage;
    try
      if GetBrushStyle = bsClear then begin
        brClr := TColorToFPColor(GetBrushColor);
        for j := 0 to img.Height - 1 do
          for i := 0 to img.Width - 1 do begin
            imgClr := img.Colors[i, j];
            if (imgClr.Red = brClr.Red) and (imgClr.Green = brClr.Green) and (imgClr.Blue = brClr.Blue) then
              Continue;
            FBuffer.Canvas.SetColor(X + i, Y + j, FPColorToTColor(imgClr));
          end;
      end else
        for j := 0 to img.Height - 1 do
          for i := 0 to img.Width - 1 do
            FBuffer.Canvas.SetColor(X + i, Y + j, FPColorToTColor(img.Colors[i, j]));
    finally
      img.Free;
    end;
  finally
    bmp.Free;
  end;
end;
*)

procedure TMvRGBGraphicsDrawingEngine.TextOut(X, Y: Integer; const AText: String);
var
  bmp: TBitmap;
  ex: TSize;
  img: TLazIntfImage;
  i, j: Integer;
  c: TColor;
  fc, tc: TFPColor;
  intens, intens0: Int64;
  alpha: Double;
  hb, hm: HBitmap;
begin
  if (AText = '') then
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

