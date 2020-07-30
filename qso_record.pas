unit qso_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
type
    TQSO = record
    CallSing: string[20];
    QSODate: TDateTime;
    QSOTime: string[5];
    QSOBand: string[20];
    QSOMode: string[15];
    QSOSubMode: string[15];
    QSOReportSent: string[8];
    QSOReportRecived: string[8];
    OmName: string[50];
    OmQTH: string[50];
    State0: string[25];
    Grid: string[6];
    IOTA: string[6];
    QSLManager: string[20];
    QSLSent: string[1];
    QSLSentAdv: string[1];
    QSLSentDate: string;
    QSLRec: string[1];
    QSLRecDate: string;
    MainPrefix: string[5];
    DXCCPrefix: string[5];
    CQZone: string[2];
    ITUZone: string[2];
    QSOAddInfo: string;
    Marker: string[1];
    ManualSet: integer;
    DigiBand: string;
    Continent: string[2];
    ShortNote: string[30];
    QSLReceQSLcc: integer;
    LotWRec: string[1];
    LotWRecDate: string;
    QSLInfo: string[100];
    Call: string[20];
    State1: string[25];
    State2: string[25];
    State3: string[25];
    State4: string[25];
    WPX: string[10];
    AwardsEx: string;
    ValidDX: string[1];
    SRX: integer;
    SRX_String: string[15];
    STX: integer;
    STX_String: string[15];
    SAT_NAME: string[20];
    SAT_MODE: string[20];
    PROP_MODE: string[20];
    LotWSent: integer;
    QSL_RCVD_VIA: string[1];
    QSL_SENT_VIA: string[1];
    DXCC: string[5];
    USERS: string[5];
    NoCalcDXCC: integer;
    My_State: string[15];
    My_Grid: string[15];
    My_Lat: string[15];
    My_Lon: string[15];
    SYNC: integer;
    NLogDB: string;
  end;

implementation

end.

