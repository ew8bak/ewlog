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
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  TraceLine, LCLType, ResourceStr;

type

  { TEarth }

  TEarth = class(TForm)
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

uses dmFunc_U, InitDB_dm, MainFuncDM;

{$R *.lfm}

{ TEarth }

procedure TEarth.SavePosition;
begin
  if IniSet.MainForm = 'MULTI' then
    if Earth.WindowState <> wsMaximized then
    begin
      INIFile.WriteInteger('SetLog', 'eLeft', Earth.Left);
      INIFile.WriteInteger('SetLog', 'eTop', Earth.Top);
      INIFile.WriteInteger('SetLog', 'eWidth', Earth.Width);
      INIFile.WriteInteger('SetLog', 'eHeight', Earth.Height);
    end;
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
  if (IniSet.MainForm = 'MULTI') and IniSet.eShow then
    if (IniSet._l_e <> 0) and (IniSet._t_e <> 0) and (IniSet._w_e <> 0) and
      (IniSet._h_e <> 0) then
      Earth.SetBounds(IniSet._l_e, IniSet._t_e, IniSet._w_e, IniSet._h_e);
end;

procedure TEarth.PaintLine(Latitude, Longitude: string; OpLat, OpLon: double);
var
  r: Trect;
  Lat, Lon: double;
  Err: integer;
  QTH_Latitude: double;
begin
  r.left := 0;
  r.right := Width - 1;
  r.top := 0;
  r.bottom := Width * obvy div obsi - 1;
  TraceLine^.SunClock(Now - (3 / 24));
  TraceLine^.Draw(r, Canvas);
  val(Latitude, Lat, Err);
  if Err = 0 then
    val(Longitude, Lon, Err);
  if Err = 0 then
  begin
    QTH_Latitude := OpLat;
    QTH_Latitude := QTH_Latitude * -1;
    Lat := Lat * -1;
    TraceLine^.DrawTrace(True, OpLon, QTH_Latitude, Lon, Lat);
  end;
end;

end.
