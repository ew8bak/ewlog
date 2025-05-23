(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit LogBookTable_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TLBRecord = record
    Description: string;
    CallSign: string[20];
    OpName: string[30];
    OpQTH: string[50];
    OpITU: string[2];
    OpCQ: string[2];
    OpLoc: string[6];
    OpLat: double;
    OpLon: double;
    QSLInfo: string[100];
    LogTable: string;
    eQSLccLogin: string[20];
    eQSLccPassword: string[20];
    AutoEQSLcc: boolean;
    LoTWLogin: string[20];
    LoTWPassword: string[20];
    HRDLogin: string[20];
    HRDCode: string[20];
    AutoHRDLog: boolean;
    HamQTHLogin: string[20];
    HamQTHPassword: string[20];
    AutoHamQTH: boolean;
    ClubLogLogin: string[20];
    ClubLogPassword: string[20];
    AutoClubLog: boolean;
    QRZComLogin: string[20];
    QRZComPassword: string[20];
    AutoQRZCom: boolean;
    HAMLogOnline_API: string;
    AutoHAMLogOnline: boolean;
  end;

implementation

end.
