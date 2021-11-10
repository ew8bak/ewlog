(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

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
    Freq: Double;
    Mode: string;
    SubMode: string;
    RSTr: string;
    RSTs: string;
    OmName: string;
    Comment: string;
    QTH: string;
    State: string;
    Save: Boolean;
  end;

implementation

end.
