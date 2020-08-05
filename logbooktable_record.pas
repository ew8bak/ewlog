unit LogBookTable_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
type
  TLBRecord = record
    Discription: string[20];
    CallSign: string[20];
    OpName: string[30];
    OpQTH: string[50];
    OpITU: string[2];
    OpCQ: string[2];
    OpLoc: string[6];
    //OpLat: string[15];
    //OpLon: string[15];
    OpLat: Double;
    OpLon: Double;
    QSLInfo: string[100];
    LogTable: string[30];
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
  end;

implementation

end.

