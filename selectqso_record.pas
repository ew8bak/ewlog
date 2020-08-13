unit selectQSO_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TSelQSOR = record
    QSODate: string;
    QSOTime: string;
    QSOBand: string;
    QSOMode: string;
    OMName: string;
  end;

implementation

end.
