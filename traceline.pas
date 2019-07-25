unit TraceLine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, GraphType, LCLType, IntfGraphics, FPimage, LResources;

const
  obsimax = 2048;
  obvymax = obsimax shr 1;

const
  obsi: longint = 400;
  obvy: longint = 200;

var
  obsi2, obvy2: extended;

type
  Tplac = array[0..obsimax * obvymax - 1] of byte;

var
  sintab: array[0..1023] of extended;
  costab: array[0..1023] of extended;
  sqtab1: array[-1000 .. 0] of byte;
  sqtab2: array[0 .. 1000] of byte;
  asintab: array[-10010..10010] of longint;

type
  t_coord = record
    longitude, latitude, radius: extended;
    rektaszension, declination: extended;
    parallax: extended;
    elevation, azimuth: extended;
  end;

const
  body_popis_max = 30;

type
  Tcarobod = record
    typ: byte;
    x1, y1, x2, y2: extended;
    popis: string[body_popis_max];
    barva: Tcolor;
    vel_bodu: longint;
  end;

const
  body_max = 128;

var
  star_time_u: extended;

type
  TTraceLine = object
    constructor Init();
    destructor Free;
    procedure SunClock(cas: TDateTime);
    procedure Draw(r: TRect; can: TCanvas);
    procedure DrawTrace(en: boolean; x1, y1, x2, y2: extended);
    procedure body_add(typ: byte; x1, y1, x2, y2: extended; popis: string;
      barva: tcolor; vel_bodu: longint);
    procedure body_smaz;

  private
    nrd: boolean;
    chcipni: boolean;
    ziju: boolean;
    poslednicas: TDateTime;
    q: Tplac;
    declin: longint;
    sideclin, codeclin: extended;
    harr: array[0..obsimax] of longint;
    rold: TRect;
    carax1, carax2, caray1, caray2: extended;
    caraen: boolean;
    obrp: TLazIntfImage;
    obrA, obrT: TLazIntfImage;
    obmap: TBitmap;
    body: array[0..body_max] of Tcarobod;
    body_poc: longint;
    function calc_horizontalx(var coord: t_coord; date: TDateTime;
      z: longint; latitude: extended): longint;
  end;
  PTraceLine = ^TTraceLine;

implementation

uses ah_math, vsop;

const
  julian_offset: extended = 0;
  AU = 149597869;             // astronomical unit in km
  mean_lunation = 29.530589;  // Mean length of a month
  tropic_year = 365.242190;   // Tropic year length
  earth_radius = 6378.15;     // Radius of the earth

function put_in_360(x: extended): extended;
begin
  Result := x - round(x / 360) * 360;
  while Result < 0 do
    Result := Result + 360;
end;

function julian_date(date: TDateTime): extended;
begin
  julian_date := julian_offset + date;
end;

procedure calc_epsilon_phi(date: TDateTime; var delta_phi, epsilon: extended);
const
  arg_mul: array[0..30, 0..4] of shortint = (
    (0, 0, 0, 0, 1),
    (-2, 0, 0, 2, 2),
    (0, 0, 0, 2, 2),
    (0, 0, 0, 0, 2),
    (0, 1, 0, 0, 0),
    (0, 0, 1, 0, 0),
    (-2, 1, 0, 2, 2),
    (0, 0, 0, 2, 1),
    (0, 0, 1, 2, 2),
    (-2, -1, 0, 2, 2),
    (-2, 0, 1, 0, 0),
    (-2, 0, 0, 2, 1),
    (0, 0, -1, 2, 2),
    (2, 0, 0, 0, 0),
    (0, 0, 1, 0, 1),
    (2, 0, -1, 2, 2),
    (0, 0, -1, 0, 1),
    (0, 0, 1, 2, 1),
    (-2, 0, 2, 0, 0),
    (0, 0, -2, 2, 1),
    (2, 0, 0, 2, 2),
    (0, 0, 2, 2, 2),
    (0, 0, 2, 0, 0),
    (-2, 0, 1, 2, 2),
    (0, 0, 0, 2, 0),
    (-2, 0, 0, 2, 0),
    (0, 0, -1, 2, 1),
    (0, 2, 0, 0, 0),
    (2, 0, -1, 0, 1),
    (-2, 2, 0, 2, 2),
    (0, 1, 0, 0, 1)
    );

  arg_phi: array[0..30, 0..1] of longint = (
    (-171996, -1742),
    (-13187, -16),
    (-2274, -2),
    (2062, 2),
    (1426, -34),
    (712, 1),
    (-517, 12),
    (-386, -4),
    (-301, 0),
    (217, -5),
    (-158, 0),
    (129, 1),
    (123, 0),
    (63, 0),
    (63, 1),
    (-59, 0),
    (-58, -1),
    (-51, 0),
    (48, 0),
    (46, 0),
    (-38, 0),
    (-31, 0),
    (29, 0),
    (29, 0),
    (26, 0),
    (-22, 0),
    (21, 0),
    (17, -1),
    (16, 0),
    (-16, 1),
    (-15, 0)
    );
  arg_eps: array[0..30, 0..1] of longint = (
    (92025, 89),
    (5736, -31),
    (977, -5),
    (-895, 5),
    (54, -1),
    (-7, 0),
    (224, -6),
    (200, 0),
    (129, -1),
    (-95, 3),
    (0, 0),
    (-70, 0),
    (-53, 0),
    (0, 0),
    (-33, 0),
    (26, 0),
    (32, 0),
    (27, 0),
    (0, 0),
    (-24, 0),
    (16, 0),
    (13, 0),
    (0, 0),
    (-12, 0),
    (0, 0),
    (0, 0),
    (-10, 0),
    (0, 0),
    (-8, 0),
    (7, 0),
    (9, 0)
    );
var
  t, omega: extended;
  l, ls: extended;
  d, m, ms, f, s: extended;
  i: longint;
  epsilon_0, delta_epsilon: extended;
begin
  t := (julian_date(date) - 2451545.0) / 36525;
  omega := put_in_360(125.04452 + (-1934.136261 + (0.0020708 + 1 / 450000 * t) * t) * t);
  l := 280.4665 + 36000.7698 * t;
  ls := 218.3165 + 481267.8813 * t;
  delta_epsilon := 9.20 * cos_d(omega) + 0.57 * cos_d(2 * l) + 0.10 *
    cos_d(2 * ls) - 0.09 * cos_d(2 * omega);
  delta_phi := (-17.20 * sin_d(omega) - 1.32 * sin_d(2 * l) - 0.23 *
    sin_d(2 * ls) + 0.21 * sin_d(2 * omega)) / 3600;
  d := put_in_360(297.85036 + (445267.111480 + (-0.0019142 + t / 189474) * t) * t);
  m := put_in_360(357.52772 + (35999.050340 + (-0.0001603 - t / 300000) * t) * t);
  ms := put_in_360(134.96298 + (477198.867398 + (0.0086972 + t / 56250) * t) * t);
  f := put_in_360(93.27191 + (483202.017538 + (-0.0036825 + t / 327270) * t) * t);

  delta_phi := 0;
  delta_epsilon := 0;

  for i := 0 to 30 do
  begin
    s := arg_mul[i, 0] * d + arg_mul[i, 1] * m + arg_mul[i, 2] *
      ms + arg_mul[i, 3] * f + arg_mul[i, 4] * omega;
    delta_phi := delta_phi + (arg_phi[i, 0] + arg_phi[i, 1] * t * 0.1) * sin_d(s);
    delta_epsilon := delta_epsilon + (arg_eps[i, 0] + arg_eps[i, 1] *
      t * 0.1) * cos_d(s);
  end;

  delta_phi := delta_phi * 0.0001 / 3600;
  delta_epsilon := delta_epsilon * 0.0001 / 3600;
  epsilon_0 := 84381.448 + (-46.8150 + (-0.00059 + 0.001813 * t) * t) * t;
  epsilon := (epsilon_0 + delta_epsilon) / 3600;
end;


function delphi_date(juldat: extended): TDateTime;
begin
  delphi_date := juldat - julian_offset;
end;

function star_time(date: TDateTime): extended;
var
  jd, t: extended;
  delta_phi, epsilon: extended;
begin
  jd := julian_date(date);
  t := (jd - 2451545.0) / 36525;
  epsilon := 0;
  delta_phi := 0;
  calc_epsilon_phi(date, delta_phi, epsilon);
  Result := put_in_360(280.46061837 + 360.98564736629 * (jd - 2451545.0) +
    t * t * (0.000387933 - t / 38710000) + delta_phi * cos_d(epsilon));
end;


procedure calc_geocentric(var coord: t_coord; date: TDateTime);
var
  epsilon: extended;
  delta_phi: extended;
  alpha, delta: extended;
begin
  calc_epsilon_phi(date, delta_phi, epsilon);
  coord.longitude := put_in_360(coord.longitude + delta_phi);
  alpha := arctan2_d(sin_d(coord.longitude) * cos_d(epsilon) -
    tan_d(coord.latitude) * sin_d(epsilon), cos_d(coord.longitude));
  delta := arcsin_d(sin_d(coord.latitude) * cos_d(epsilon) +
    cos_d(coord.latitude) * sin_d(epsilon) * sin_d(coord.longitude));

  coord.rektaszension := alpha;
  coord.declination := delta;
end;

procedure calc_coord(date: TDateTime; obj_class: TCVSOP; var l, b, r: extended);
var
  obj: TVSOP;
begin
  obj := nil;
  try
    obj := obj_class.Create;
    obj.date := date;
    r := obj.radius;
    l := obj.longitude;
    b := obj.latitude;
    obj.DynamicToFK5(l, b);
  finally
    obj.Free;
  end;
  l := put_in_360(rad2deg(l));
  b := rad2deg(b);
end;


procedure earth_coord(date: TdateTime; var l, b, r: extended);
begin
  calc_coord(date, TVSOPEarth, l, b, r);
end;


function sun_coordinate(date: TDateTime): t_coord;
var
  l, b, r: extended;
  lambda, t: extended;
begin
  earth_coord(date, l, b, r);
  l := l + 180;
  b := -b;
  t := (julian_date(date) - 2451545.0) / 365250.0 * 10;
  lambda := l + (-1.397 - 0.00031 * t) * t;
  l := l - 0.09033 / 3600;
  b := b + 0.03916 / 3600 * (cos_d(lambda) - sin_d(lambda));
  l := l - 20.4898 / 3600 / r;
  Result.longitude := put_in_360(l);
  Result.latitude := b;
  Result.radius := r * AU;
  calc_geocentric(Result, date);
end;

function TTraceLine.calc_horizontalx(var coord: t_coord; date: TDateTime;
  z: longint; latitude: extended): longint;
var
  h: longint;
  la: longint;
begin
  h := harr[z];
  la := round(latitude * 512) div 180 and 1023;
  calc_horizontalx := asintab[round(
    (sintab[la] * sideclin + costab[la] * codeclin * costab[h]) * 999)];
end;

constructor TTraceLine.Init();
var
  e, z: longint;
  a: extended;
  ImgFormatDescription: TRawImageDescription;
  obrtmp: TLazIntfImage;
  bitm: TBitmap;
begin
  chcipni := False;
  caraen := False;
  bitm := TBitmap.Create;

  with TPicture.Create do
    try
      LoadFromLazarusResource('earth');
      bitm.Assign(Graphic);
    finally
      Free;
    end;

  obrtmp := TLazIntfImage.Create(0, 0);
  obrtmp.LoadFromBitmap(bitm.Handle, bitm.MaskHandle);
  obsi := obrtmp.Width;
  obvy := obrtmp.Height;
  obrtmp.Free;
  obmap := TBitmap.Create;
  obrp := TLazIntfImage.Create(0, 0);
  ImgFormatDescription.Init_BPP32_B8G8R8_BIO_TTB(obsi, obvy);
  obrp.DataDescription := ImgFormatDescription;
  obrp.LoadFromBitmap(bitm.Handle, bitm.MaskHandle);
  obra := TLazIntfImage.Create(0, 0);
  ImgFormatDescription.Init_BPP32_B8G8R8_BIO_TTB(obsi, obvy);
  obrA.DataDescription := ImgFormatDescription;

  obrA.CopyPixels(obrP);
  obmap.Width := obrp.Width;
  obmap.Height := obrp.Height;
  obrT := obmap.CreateIntfImage;
  obrT.CopyPixels(obrA);
  obmap.LoadFromIntfImage(obrT);
  obsi2 := 360 / obsi;
  obvy2 := 180 / obvy;
  if obsi > obsimax then
  begin
    chcipni := True;
  end;
  if obvy > obvymax then
  begin
    chcipni := True;
  end;

  for z := 0 to 1023 do
  begin
    a := sin(z * pi / 512);
    sintab[z] := a;
    costab[(z - 256) and 1023] := a;
  end;

  for z := 0 to 901 do
  begin
    e := -round(sqrt(z) * 2.84604989415154) + 100 + 10;
    if e < 2 then
      sqtab1[-z] := 2
    else
      sqtab1[-z] := e;
  end;

  fillchar(sqtab2[50], 855, 199);
  for z := 0 to 50 do
    sqtab2[z] := round(sqrt(sqrt(z)) * 56.2341325190) + 100;

  for z := 0 to 10010 do
  begin
    asintab[z] := round(arcsin(z / 1000) * 1800 / pi);
    asintab[-z] := -asintab[z];
  end;

  body_poc := 0;

  poslednicas := now - 1000000;
  nrd := False;
  bitm.Free;
end;

destructor TTraceLine.Free;
begin
  obra.Free;
  obrp.Free;
  obrt.Free;
  obmap.Free;
end;

procedure TTraceLine.SunClock(cas: Tdatetime);
const
  ko = 10;
var
  z, c: longint;
  ce: extended;
  datum: TDateTime;
  datum2: extended;
  pos1: T_Coord;
  vere, vere1: longint;

  function vr1(z, x: longint): longint;
  begin
    vr1 := calc_horizontalx(pos1, datum, z, (x - obvy shr 1) * obvy2);
  end;


  procedure put(x1, y1: longint; b: byte);
  begin
    q[x1 + y1 * obsi] := b;
  end;

  function get(x1, y1: longint): byte;
  var
    e2: longint;
    o, g: longint;
  begin
    o := x1 + y1 * obsi;
    if q[o] = 0 then
    begin
      e2 := vr1(x1, y1);
      if e2 = 0 then
        g := 100
      else
      if e2 < 0 then
        g := sqtab1[e2]
      else
        g := sqtab2[e2];
      if g > 199 then
        g := 199;
      if g <= 0 then
        g := 1;
      q[o] := g and 254;
      get := g and 254;
    end
    else
      get := q[o];
  end;


  procedure prolez(x1, y1, x2, y2, u: longint);
  var
    c, v, z, x: longint;
    px, py: longint;
  begin
    if chcipni then
      exit;
    if u < 0 then
      exit;
    v := get(x1, y1);
    if (v = get(x1, y2)) and (v = get(x2, y1)) and (v = get(x2, y1)) and (u < 3) then

      for x := y1 to y2 do
      begin
        c := x * obsi + x1;
        for z := x1 to x2 do
        begin
          q[c] := v;
          Inc(c);
        end;
      end
    else
    begin
      if x2 - x1 > 2 then
        px := (x2 + x1) div 2
      else if x2 - x1 = 2 then
        px := x1 + 1
      else
        px := x1;
      if y2 - y1 > 2 then
        py := (y2 + y1) div 2
      else if y2 - y1 = 2 then
        py := y1 + 1
      else
        py := y1;
      if (x2 - x1 > 2) and (y2 - y1 > 2) then
      begin
        prolez(x1, y1, px, py, u - 1);
        prolez(x1, py + 1, px, y2, u - 1);
        prolez(px + 1, y1, x2, py, u - 1);
        prolez(px + 1, py + 1, x2, y2, u - 1);
      end
      else
      if y2 - y1 > 2 then
      begin
        prolez(x1, y1, x2, py, u - 1);
        prolez(x1, py + 1, x2, y2, u - 1);
      end
      else
      if x2 - x1 > 2 then
      begin
        prolez(x1, y1, px, y2, u - 1);
        prolez(px + 1, y1, x2, y2, u - 1);
      end
      else
      begin
        for z := x1 to x2 do
          for x := y1 to y2 do
            get(z, x);
      end;
    end;

  end;


  procedure prolez1(x1, y1, x2, y2, u: longint);
  begin

  end;

begin
  if chcipni then
    exit;
  if round(poslednicas * 24 * 60) = round(cas * 24 * 60) then
    exit;
  poslednicas := cas;
  datum := cas - 3.5 / 24;
  c := 0;
  ce := (datum - trunc(datum)) * 24 + c;
  datum2 := (datum - trunc(datum) + ce / 24) * 360;
  begin
    fillchar(q, obvy * obsi, 0);
    pos1 := sun_coordinate(trunc(datum));
    declin := round(pos1.declination * 512) div 180 and 1023;
    sideclin := sintab[declin];
    codeclin := costab[declin];
    star_time_u := star_time(datum);
    ziju := True;
    for z := 0 to obsi - 1 do
      harr[z] := (round(star_time_u - pos1.rektaszension - (datum2 + z * obsi2)) shl
        9 div 180) and 1023;
    vere := 0;
    vere1 := obsi;
    while vere1 > 2 do
    begin
      vere1 := vere1 shr 1;
      Inc(vere);
    end;
    prolez(0, 0, obsi - 1, obvy - 1, vere);
    ziju := False;
  end;
  nrd := True;
end;


procedure TTraceLine.Draw(r: Trect; can: TCanvas);
var
  z, x, c: longint;
  ze, zez, ze2, zez2, ze2s, zez2s: extended;
var
  xptr: ^byte;

  procedure cmarniu(x1, y1, x2, y2: longint);
  begin
    can.pen.color := clblack;
    can.pen.Width := 0;
    can.moveto(x1, y1);
    can.lineto(x2, y2);
    can.pen.color := clred;
    can.pen.Width := 2;
    can.moveto(x1, y1);
    can.lineto(x2, y2);
  end;

  procedure cmarni(x1, y1, x2, y2: extended; roh: boolean);
  var
    dx, dy, ax, ay: extended;
  begin
    if (abs(x1 - x2) > 180) and (roh) then
    begin
      can.pen.Style := psdash;
      cmarni(x1 + 360, y1, x2, y2, False);
      cmarni(x1, y1, x2 - 360, y2, False);
      can.pen.Style := pssolid;
      cmarni(x1, y1, x2, y2, False);
    end
    else
    begin
      dx := r.right - r.left + 1;
      dy := r.bottom - r.top + 1;

      ax := (r.left + r.right) / 2;
      ay := (r.top + r.bottom) / 2;

      cmarniu(round(ax + round(x1 * dx / 360)), round(ay + round(y1 * dy / 180)),
        round(ax + round(x2 * dx / 360)), round(ay + round(y2 * dy / 180)));
    end;
  end;

  procedure bod_cmarniu(x1, y1, x2, y2: longint; b: Tcarobod);
  var
    vb: longint;
  begin
    vb := b.vel_bodu;
    if b.typ = 3 then
    begin
      can.pen.color := clblack;
      can.pen.Width := 5;
      can.moveto(x1 - vb, y1 - vb);
      can.lineto(x1 + vb, y1 + vb);
      can.moveto(x1 - vb, y1 + vb);
      can.lineto(x1 + vb, y1 - vb);
      can.pen.color := b.barva;
      can.pen.Width := 2;
      can.moveto(x1 - vb, y1 - vb);
      can.lineto(x1 + vb, y1 + vb);
      can.moveto(x1 - vb, y1 + vb);
      can.lineto(x1 + vb, y1 - vb);
    end;
    if b.typ = 2 then
    begin
      can.pen.color := clblack;
      can.pen.Width := 5;
      can.moveto(x1 - vb, y1 - vb);
      can.lineto(x1 - vb, y1 + vb);
      can.lineto(x1 + vb, y1 + vb);
      can.lineto(x1 + vb, y1 - vb);
      can.lineto(x1 - vb, y1 - vb);
      can.pen.color := b.barva;
      can.pen.Width := 2;
      can.moveto(x1 - vb, y1 - vb);
      can.lineto(x1 - vb, y1 + vb);
      can.lineto(x1 + vb, y1 + vb);
      can.lineto(x1 + vb, y1 - vb);
      can.lineto(x1 - vb, y1 - vb);
    end;
    if b.typ = 1 then
    begin
      can.pen.color := clblack;
      can.pen.Width := 5;
      can.moveto(x1, y1);
      can.lineto(x2, y2);
      can.pen.color := b.barva;
      can.pen.Width := 2;
      can.moveto(x1, y1);
      can.lineto(x2, y2);
    end;
  end;



  procedure bod_cmarni(b: Tcarobod);
  var
    dx, dy, ax, ay: extended;
  begin
    dx := r.right - r.left + 1;
    dy := r.bottom - r.top + 1;

    ax := (r.left + r.right) / 2;
    ay := (r.top + r.bottom) / 2;

    bod_cmarniu(round(ax + round(b.x1 * dx / 360)), round(ay + round(b.y1 * dy / 180)),
      round(ax + round(b.x2 * dx / 360)), round(ay + round(b.y2 * dy / 180)), b);
  end;

begin
  if chcipni then
    exit;

  if ((r.left - r.right <> rold.left - rold.right) or
    (r.top - r.bottom <> rold.top - rold.bottom)) and (r.right - r.left + 1 > obsi) then
    nrd := True;

  if nrd then
  begin

    obrA.CopyPixels(obrP);
    ze2 := 1.7;
    zez2 := 1.0;

    if ze2 <= 0 then
      ze2 := 0.0000001;
    if zez2 <= 0 then
      zez2 := 0.0000001;
    ze2s := 100 / ze2 * 2 - 200;
    zez2s := 100 / zez2 * 2 - 200;
    for x := 0 to obvy - 1 do
    begin
      c := (obvy - 1 - x) * obsi;
      xptr := obrA.GetDataLineStart(x);
      for z := 0 to obsi - 1 do
      begin
        if q[c] < 100 then
        begin
          ze := (q[c] - ze2s) / 200;
          zez := (q[c] - zez2s) / 200;
          if ze <= 0 then
            ze := 0;

          xptr^ := round(longint(xptr^) * (zez));
          Inc(xptr);
          xptr^ := round(longint(xptr^) * ze);
          Inc(xptr);
          xptr^ := round(longint(xptr^) * ze);
          Inc(xptr);
          Inc(xptr);
        end
        else
          Inc(xptr, 4);
        Inc(c);
      end;
    end;
    obrT.CopyPixels(obrA);
    obmap.LoadFromIntfImage(obrT);

  end;
  if r.left = r.right then
  begin
    r.Right := r.left + obsi - 1;
    r.bottom := r.top + obvy - 1;
    Can.Draw(r.left, r.top, obmap);
  end
  else
    Can.StretchDraw(r, obmap);

  if caraen then
  begin
    cmarni(carax1, caray1, carax2, caray2, True);
  end;
  for z := 0 to body_poc - 1 do
  begin
    bod_cmarni(body[z]);
  end;
  nrd := False;
end;

procedure TTraceLine.DrawTrace(en: boolean; x1, y1, x2, y2: extended);
begin
  if chcipni then
    exit;
  caraen := en;
  if (abs(y1) > 90) or (abs(y2) > 90) then
  begin
    caraen := False;
    exit;
  end;
  while x1 > 180 do
    x1 := x1 - 360;
  while x1 < -180 do
    x1 := x1 + 360;
  while x2 > 180 do
    x2 := x2 - 360;
  while x2 < -180 do
    x2 := x2 + 360;

  if x1 > x2 then
  begin
    carax1 := x2;
    carax2 := x1;
    caray1 := y2;
    caray2 := y1;
  end
  else
  begin
    carax1 := x1;
    carax2 := x2;
    caray1 := y1;
    caray2 := y2;
  end;
end;

procedure TTraceLine.body_add(typ: byte; x1, y1, x2, y2: extended;
  popis: string; barva: tcolor; vel_bodu: longint);
begin
  if chcipni then
    exit;
  if body_poc < body_max - 1 then
  begin
    body[body_poc].typ := typ;
    body[body_poc].x1 := x1;
    body[body_poc].y1 := y1;
    body[body_poc].x2 := x2;
    body[body_poc].y2 := y2;
    body[body_poc].popis := copy(popis, 1, body_popis_max);
    body[body_poc].barva := barva;
    body[body_poc].vel_bodu := vel_bodu;
    Inc(body_poc);
  end;
end;

procedure TTraceLine.body_smaz;
begin
  body_poc := 0;
end;

initialization
{$I earth.lrs}
end.
