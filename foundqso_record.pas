unit foundQSO_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TFoundQSOR = record
    OMName: string;
    OMQTH: string;
    QSODate: string;
    QSOTime: string;
    QSOBand: string;
    QSOMode: string;
    Grid: string;
    State: string;
    IOTA: string;
    QSLManager: string;
    CountQSO: integer;
    Found: boolean;
  end;

implementation

end.
