unit mvDrawingEngine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Types, IntfGraphics;

type
  TMvCustomDrawingEngine = class(TComponent)
  protected
    function GetBrushColor: TColor; virtual; abstract;
    function GetBrushStyle: TBrushStyle; virtual; abstract;
    function GetFontColor: TColor; virtual; abstract;
    function GetFontName: String; virtual; abstract;
    function GetFontSize: Integer; virtual; abstract;
    function GetFontStyle: TFontStyles; virtual; abstract;
    function GetPenColor: TColor; virtual; abstract;
    function GetPenWidth: Integer; virtual; abstract;
    procedure SetBrushColor(AValue: TColor); virtual; abstract;
    procedure SetBrushStyle(AValue: TBrushStyle); virtual; abstract;
    procedure SetFontColor(AValue: TColor); virtual; abstract;
    procedure SetFontName(AValue: String); virtual; abstract;
    procedure SetFontSize(AValue: Integer); virtual; abstract;
    procedure SetFontStyle(AValue: TFontStyles); virtual; abstract;
    procedure SetPenColor(AValue: TColor); virtual; abstract;
    procedure SetPenWidth(AValue: Integer); virtual; abstract;

  public
    procedure CreateBuffer(AWidth, AHeight: Integer); virtual; abstract;
    procedure DrawBitmap(X, Y: Integer; ABitmap: TCustomBitmap;
      UseAlphaChannel: Boolean); virtual; abstract;
    procedure DrawLazIntfImage(X, Y: Integer; AImg: TLazIntfImage); virtual; abstract;
    procedure Ellipse(X1, Y1, X2, Y2: Integer); virtual; abstract;
    procedure FillRect(X1, Y1, X2, Y2: Integer); virtual; abstract;
    procedure Line(X1, Y1, X2, Y2: Integer); virtual; virtual; abstract;
    procedure PaintToCanvas(ACanvas: TCanvas); virtual; abstract;
    procedure Rectangle(X1, Y1, X2, Y2: Integer); virtual; abstract;
    function SaveToImage(AClass: TRasterImageClass): TRasterImage; virtual; abstract;
    function TextExtent(const AText: String): TSize; virtual; abstract;
    function TextHeight(const AText: String): Integer;
    procedure TextOut(X, Y: Integer; const AText: String); virtual; abstract;
    function TextWidth(const AText: String): Integer;

    property BrushColor: TColor read GetBrushColor write SetBrushColor;
    property BrushStyle: TBrushStyle read GetBrushStyle write SetBrushStyle;
    property FontColor: TColor read GetFontColor write SetFontColor;
    property FontName: String read GetFontName write SetFontName;
    property FontSize: Integer read GetFontSize write SetFontSize;
    property FontStyle: TFontStyles read GetFontStyle write SetFontStyle;
    property PenColor: TColor read GetPenColor write SetPenColor;
    property PenWidth: Integer read GetPenWidth write SetPenWidth;
  end;

implementation

function TMvCustomDrawingEngine.TextHeight(const AText: String): Integer;
begin
  Result := TextExtent(AText).CX;
end;

function TMvCustomDrawingEngine.TextWidth(const AText: String): Integer;
begin
  Result := TextExtent(AText).CY;
end;


end.

