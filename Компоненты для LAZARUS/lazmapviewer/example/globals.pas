unit globals;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mvEngine;

const
  DistanceUnit_Names: array[TDistanceUnits] of string = ('m', 'km', 'miles');

var
  DistanceUnit: TDistanceUnits = duKilometers;

implementation

end.

