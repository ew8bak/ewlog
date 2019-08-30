{
 /***************************************************************************
                                RGBGTK3Routines.pas


 ***************************************************************************/

 *****************************************************************************
 *                                                                           *
 *  See the file COPYING.modifiedLGPL, included in this distribution,        *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************

  Author:  Cedric Arnault (ti_dic@hotmail.com)

  Abstract:
    This unit contains routines for GTK3 interfaces.

}
unit rgbgtk3routines;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, LCLType, RGBTypes;

//this function is not multithread ready, because it's temporary swap the red and blue components of the TRGB32BitmapCore
// CAIRO_FORMAT_RGB24 seem to be BGR
procedure WidgetSetDrawRGB32Bitmap(Dest: HDC; DstX, DstY: Integer; SrcX, SrcY, SrcWidth, SrcHeight: Integer; Bitmap: TRGB32BitmapCore);
procedure WidgetSetDrawRGB8Bitmap(Dest: HDC; DstX, DstY: Integer; SrcX, SrcY, SrcWidth, SrcHeight: Integer; Bitmap: TRGB8BitmapCore);


implementation
uses lazcairo1,gtk3objects;

function GetSurface(Bitmap: TRGBBitmapCore;AFormat : cairo_format_t) : Pcairo_surface_t;
var AWidth : integer;
    stride : integer;
begin
  AWidth := Bitmap.Width;
  Stride := cairo_format_stride_for_width(AFormat,AWidth);
  Result := cairo_image_surface_create_for_data(Bitmap.Pixels,
                                                AFormat,
                                                AWidth,
                                                Bitmap.Height,
                                                Stride);
end;

// swap the red and blue component of TRGB32BitmapCore
procedure SwapRB(Const Bitmap: TRGB32BitmapCore;SrcX,SrcY,Width,Height : integer);
var x , y : integer;
    pix : PRGB32PIXEL;
Begin
  For y:=SrcY to pred(Height) do
    For x:=SrcX to pred(Width) do
    Begin
      Pix:=Bitmap.Get32PixelPtr(X,Y);
      Pix^:=(Pix^ and $0000FF00) or (Pix^ and $00FF0000 shr 16) or (Pix^ and $000000FF shl 16);
    end;
end;

procedure WidgetSetDrawRGB32Bitmap(Dest: HDC; DstX, DstY: Integer; SrcX, SrcY,
  SrcWidth, SrcHeight: Integer; Bitmap: TRGB32BitmapCore);
var CairoSurface : Pcairo_surface_t;
    P : TGtk3DeviceContext;
    ToClip : boolean;
begin
  P := TGtk3DeviceContext(Dest);
  SwapRB(Bitmap,SrcX,SrcY,SrcWidth,SrcHeight);
  Try
    CairoSurface:=GetSurface(Bitmap,CAIRO_FORMAT_RGB24);
    try
      ToClip:=(SrcX<>0) or (SrcY<>0) or (SrcWidth<>Bitmap.Width) or (SrcHeight<>Bitmap.Height);
      if toClip then
      begin
        cairo_save(P.Widget);
        cairo_rectangle(P.Widget,DstX,DstY,SrcWidth,srcHeight);
        cairo_clip(P.Widget);
      end;
      try
        cairo_set_source_surface (P.Widget, CairoSurface, DstX-SrcX, DstY-SrcY);
        cairo_paint (P.Widget);
        cairo_show_page (P.Widget);
      finally
        if toClip then
           cairo_restore(P.Widget);
      end;
    finally
      cairo_surface_destroy(CairoSurface);
    end;
  finally
    SwapRB(Bitmap,SrcX,SrcY,SrcWidth,SrcHeight);
  end;
end;

procedure WidgetSetDrawRGB8Bitmap(Dest: HDC; DstX, DstY: Integer; SrcX, SrcY,
  SrcWidth, SrcHeight: Integer; Bitmap: TRGB8BitmapCore);
var CairoSurface : Pcairo_surface_t;
    P : TGtk3DeviceContext;
    ToClip : boolean;
begin
  P := TGtk3DeviceContext(Dest);
  CairoSurface:=GetSurface(Bitmap,CAIRO_FORMAT_A8);
  try
    ToClip:=(SrcX<>0) or (SrcY<>0) or (SrcWidth<>Bitmap.Width) or (SrcHeight<>Bitmap.Height);
    if toClip then
    begin
      cairo_save(P.Widget);
      cairo_rectangle(P.Widget,DstX,DstY,SrcWidth,srcHeight);
      cairo_clip(P.Widget);
    end;
    try
      cairo_set_source_surface (P.Widget, CairoSurface, DstX, DstY);
      cairo_paint (P.Widget);
      cairo_show_page (P.Widget);
    finally
      if toClip then
           cairo_restore(P.Widget);
    end;
  finally
    cairo_surface_destroy(CairoSurface);
  end;
end;

end.

