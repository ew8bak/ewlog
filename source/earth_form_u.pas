(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit Earth_Form_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics,
  TraceLine;

type

  { TEarth }

  TEarth = class(TForm)
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    TraceLine: PTraceLine;
    procedure PaintLine(Latitude, Longitude: string; OpLat, OpLon: double);
    procedure SavePosition;

    { public declarations }
  end;

var
  Earth: TEarth;

implementation

uses InitDB_dm, MainFuncDM, miniform_u;

{$R *.lfm}

{ TEarth }

procedure TEarth.SavePosition;
begin
  MainFunc.SaveWindowPosition(Earth);
end;

procedure TEarth.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  MiniForm.CheckFormMenu('EarthForm', False);
end;

procedure TEarth.FormCreate(Sender: TObject);
begin
  TraceLine := new(PTraceLine, init());
end;

procedure TEarth.FormDestroy(Sender: TObject);
begin
  Dispose(TraceLine, Free);
end;

procedure TEarth.FormPaint(Sender: TObject);
begin
  Earth.PaintLine(FloatToStr(LBRecord.OpLat), FloatToStr(LBRecord.OpLon),
    LBRecord.OpLat, LBRecord.OpLon);
end;

procedure TEarth.FormShow(Sender: TObject);
begin
  MainFunc.LoadWindowPosition(Earth);
end;

procedure TEarth.PaintLine(Latitude, Longitude: string; OpLat, OpLon: double);
var
  r: Trect;
  Lat, Lon: double;
  QTH_Latitude: double;
begin
  r.left := 0;
  r.right := Width - 1;
  r.top := 0;
  r.bottom := Width * obvy div obsi - 1;
  TraceLine^.SunClock(Now - (3 / 24));
  TraceLine^.Draw(r, Canvas);

  if TryStrToFloatSafe(Latitude, Lat) then
    if TryStrToFloatSafe(Longitude, Lon) then
    begin
      QTH_Latitude := OpLat;
      QTH_Latitude := QTH_Latitude * -1;
      Lat := Lat * -1;
      TraceLine^.DrawTrace(True, OpLon, QTH_Latitude, Lon, Lat);
    end;
end;

end.
