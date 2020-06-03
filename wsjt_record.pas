unit wsjt_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TWSJTR = record
    Call: string;
    Grid: string;
    Freq: string;
    Mode: string;
    SubMode: string;
    RSTs: string;
    RSTr: string;
    Name: string;
    Date: TDateTime;
    Comment: string;
  end;

implementation

end.
