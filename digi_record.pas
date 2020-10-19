unit digi_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TDigiR = record
    DXCall: string;
    date: TDateTime;
    time: string;
    DXGrid: string;
    Freq: string;
    Mode: string;
    SubMode: string;
    RSTr: string;
    RSTs: string;
    OmName: string;
    Comment: string;
    QTH: string;
    Save: Boolean;
    Band: string;
  end;

implementation

end.
