unit inifile_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TINIR = record
    UseIntCallBook: boolean;
    PhotoDir: string;
    StateToQSLInfo: boolean;
    Fl_PATH: string;
    WSJT_PATH: string;
    FLDIGI_USE: boolean;
    WSJT_USE: boolean;
    ShowTRXForm: boolean;
    _l: integer;
    _t: integer;
    _w: integer;
    _h: integer;
    PastMode: string;
    PastSubMode: string;
    showBand: boolean;
    PastBand: integer;
    NumStart: integer;
    Language: string;
    Map_Use: boolean;
    PrintPrev: boolean;
    FormState: string;
    CloudLogServer: string;
    CloudLogApiKey: string;
    AutoCloudLog: boolean;
    FreqToCloudLog: boolean;
    QRZCOM_Login: string;
    QRZCOM_Pass: string;
    QRZRU_Login: string;
    QRZRU_Pass: string;
  end;

implementation

end.

