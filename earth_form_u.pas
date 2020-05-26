unit Earth_Form_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  TraceLine;

type

  { TEarth }

  TEarth = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
  public
    TraceLine: PTraceLine;
    procedure PaintLine(Latitude, Longitude: string);
    { public declarations }
  end;

var
  Earth: TEarth;

implementation

uses MainForm_U, dmFunc_U;

{$R *.lfm}

{ TEarth }

procedure TEarth.FormCreate(Sender: TObject);
begin
  TraceLine := new(PTraceLine, init());
end;

procedure TEarth.FormDestroy(Sender: TObject);
begin
  Dispose(TraceLine, Free);
end;

procedure TEarth.PaintLine(Latitude, Longitude: string);
var
  r: Trect;
  Lat, Lon: extended;
  Err: integer;
  QTH_Latitude: Extended;
begin
  r.left := 0;
  r.right := Width - 1;
  r.top := 0;
  r.bottom := Width * obvy div obsi - 1;
  // TraceLine^.SunClock(Now-(dmFunc.GrayLineOffset/24));
  TraceLine^.Draw(r, Canvas);
  val(Latitude, Lat, Err);
  if Err = 0 then
    val(Longitude, Lon, Err);
  if Err = 0 then
  begin
    QTH_Latitude := QTH_LAT;
    QTH_Latitude := QTH_Latitude * -1;
    Lat := Lat * -1;
    TraceLine^.DrawTrace(True, QTH_LON, QTH_Latitude, Lon, Lat);
  end;
end;

end.
