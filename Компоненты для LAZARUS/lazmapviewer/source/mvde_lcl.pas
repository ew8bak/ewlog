unit mvDE_LCL;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Types, IntfGraphics,
  mvDrawingEngine;

type
  TMvLCLDrawingEngine = class(TMvCustomDrawingEngine)
    private
      FBuffer: TBitmap;
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
  LCLType;

destructor TMvLCLDrawingEngine.Destroy;
begin
  FBuffer.Free;
  inherited;
end;

procedure TMvLCLDrawingEngine.CreateBuffer(AWidth, AHeight: Integer);
begin
  FBuffer.Free;
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32Bit;
  FBuffer.SetSize(AWidth, AHeight);
end;

procedure TMvLCLDrawingEngine.DrawBitmap(X, Y: Integer; ABitmap: TCustomBitmap;
  UseAlphaChannel: Boolean);
begin
  FBuffer.Canvas.Draw(X, Y, ABitmap);
end;

procedure TMvLCLDrawingEngine.DrawLazIntfImage(X, Y: Integer;
  AImg: TLazIntfImage);
var
  bmp: TBitmap;
  h, mh: HBITMAP;
begin
  bmp := TBitmap.Create;
  try
    bmp.PixelFormat := pf32Bit;
    bmp.SetSize(AImg.Width, AImg.Height);
    AImg.CreateBitmaps(h, mh);
    bmp.Handle := h;
    bmp.MaskHandle := mh;
    FBuffer.Canvas.Draw(X, Y, bmp);
  finally
    bmp.Free;
  end;
end;

procedure TMvLCLDrawingEngine.Ellipse(X1, Y1, X2, Y2: Integer);
begin
  FBuffer.Canvas.Ellipse(X1,Y1, X2, Y2);
end;

procedure TMvLCLDrawingEngine.FillRect(X1, Y1, X2, Y2: Integer);
begin
  FBuffer.Canvas.FillRect(X1,Y1, X2, Y2);
end;

function TMvLCLDrawingEngine.GetBrushColor: TColor;
begin
  Result := FBuffer.Canvas.Brush.Color;
end;

function TMvLCLDrawingEngine.GetBrushStyle: TBrushStyle;
begin
  Result := FBuffer.Canvas.Brush.Style
end;

function TMvLCLDrawingEngine.GetFontColor: TColor;
begin
  Result := FBuffer.Canvas.Font.Color
end;

function TMvLCLDrawingEngine.GetFontName: String;
begin
  Result := FBuffer.Canvas.Font.Name;
end;

function TMvLCLDrawingEngine.GetFontSize: Integer;
begin
  Result := FBuffer.Canvas.Font.Size;
end;

function TMvLCLDrawingEngine.GetFontStyle: TFontStyles;
begin
  Result := FBuffer.Canvas.Font.Style;
end;

function TMvLCLDrawingEngine.GetPenColor: TColor;
begin
  Result := FBuffer.Canvas.Pen.Color;
end;

function TMvLCLDrawingEngine.GetPenWidth: Integer;
begin
  Result := FBuffer.Canvas.Pen.Width;
end;

procedure TMvLCLDrawingEngine.Line(X1, Y1, X2, Y2: Integer);
begin
  FBuffer.Canvas.Line(X1, Y1, X2, Y2);
end;

procedure TMvLCLDrawingEngine.PaintToCanvas(ACanvas: TCanvas);
begin
  ACanvas.Draw(0, 0, FBuffer);
end;

procedure TMvLCLDrawingEngine.Rectangle(X1, Y1, X2, Y2: Integer);
begin
  FBuffer.Canvas.Rectangle(X1,Y1, X2, Y2);
end;

function TMvLCLDrawingEngine.SaveToImage(AClass: TRasterImageClass): TRasterImage;
begin
  Result := AClass.Create;
  Result.Width := FBuffer.Width;
  Result.Height := FBuffer.Height;
  Result.Canvas.FillRect(0, 0, Result.Width, Result.Height);
  Result.Canvas.Draw(0, 0, FBuffer);
end;

procedure TMvLCLDrawingEngine.SetBrushColor(AValue: TColor);
begin
  FBuffer.Canvas.Brush.Color := AValue;
end;

procedure TMvLCLDrawingEngine.SetBrushStyle(AValue: TBrushStyle);
begin
  FBuffer.Canvas.Brush.Style := AValue;
end;

procedure TMvLCLDrawingEngine.SetFontColor(AValue: TColor);
begin
  FBuffer.Canvas.Font.Color := AValue;
end;

procedure TMvLCLDrawingEngine.SetFontName(AValue: String);
begin
  FBuffer.Canvas.Font.Name := AValue;
end;

procedure TMvLCLDrawingEngine.SetFontSize(AValue: Integer);
begin
  FBuffer.Canvas.Font.Size := AValue;
end;

procedure TMvLCLDrawingEngine.SetFontStyle(AValue: TFontStyles);
begin
  FBuffer.Canvas.Font.Style := AValue;
end;

procedure TMvLCLDrawingEngine.SetPenColor(AValue: TColor);
begin
  FBuffer.Canvas.Pen.Color := AValue;
end;

procedure TMvLCLDrawingEngine.SetPenWidth(AValue: Integer);
begin
  FBuffer.Canvas.Pen.Width := AValue;
end;

function TMvLCLDrawingEngine.TextExtent(const AText: String): TSize;
begin
  Result := FBuffer.Canvas.TextExtent(AText)
end;

procedure TMvLCLDrawingEngine.TextOut(X, Y: Integer; const AText: String);
begin
  if (AText <> '') then
    FBuffer.Canvas.TextOut(X, Y, AText);
end;

end.

