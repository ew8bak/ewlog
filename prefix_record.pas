unit prefix_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
type
   TPFXR = record
    Country: string[100];
    ARRLPrefix: string[5];
    Prefix: string[5];
    CQZone: string[2];
    ITUZone: string[2];
    Continent: string[2];
    Latitude: string[15];
    Longitude: string[15];
    DXCCNum: integer;
    TimeDiff: integer;
    Distance: string;
    Azimuth: string;
  end;

implementation

end.

