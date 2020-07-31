unit inifile_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
type
   TINIR = record
   UseIntCallBook: string[3];
   PhotoDir: string;
   StateToQSLInfo: Boolean;
   Fl_PATH: string;
   WSJT_PATH: string;
   FLDIGI_USE: Boolean;
   WSJT_USE: Boolean;
   ShowTRXForm: Boolean;
   _l: Integer;
   _t: Integer;
   _w: Integer;
   _h: Integer;
   PastMode: string;
   PastSubMode: string;
   showBand: string;
   PastBand: Integer;
  end;

implementation

end.

