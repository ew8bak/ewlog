unit Earth_Form_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  TraceLine;

type

  { TEarth }

  TEarth = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    TraceLine: PTraceLine;
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

procedure TEarth.FormPaint(Sender: TObject);
var
  r: Trect;
  lat: currency;
  lat1, long1: currency;
begin
  if (la1 = '......') or (la1 = '') or (lo1 = '......') or
    (lo1 = '') then
  begin
    la1 := CurrToStr(QTH_LAT);
    lo1 := CurrToStr(QTH_LON);
  end
  else
  begin
    lat1 := StrToCurr(la1);
    long1 := StrToCurr(lo1);
    r.left := 0;
    r.right := Width - 1;
    r.top := 0;
    r.bottom := Width * obvy div obsi - 1;
    // TraceLine^.SunClock(Now-(dmFunc.GrayLineOffset/24));
    TraceLine^.Draw(r, Canvas);
    lat := QTH_LAT;
    lat := lat * -1;
    lat1 := lat1 * -1;
    TraceLine^.DrawTrace(True, QTH_LON, lat, long1, lat1);
  end;
end;

procedure TEarth.Timer1Timer(Sender: TObject);
begin
  Refresh;
end;

end.
