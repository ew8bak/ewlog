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
    _l_m: integer;
    _t_m: integer;
    _w_m: integer;
    _h_m: integer;
    _l_g: integer;
    _t_g: integer;
    _w_g: integer;
    _h_g: integer;
    _l_c: integer;
    _t_c: integer;
    _w_c: integer;
    _h_c: integer;
    _l_e: integer;
    _t_e: integer;
    _w_e: integer;
    _h_e: integer;
    mTop: Boolean;
    gTop: Boolean;
    cTop: Boolean;
    eTop: Boolean;
    mShow: Boolean;
    gShow: Boolean;
    cShow: Boolean;
    eShow: Boolean;
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
    HAMQTH_Login: string;
    HAMQTH_Pass: string;
    QRZRU_Login: string;
    QRZRU_Pass: string;
    CallBookSystem: string;
    MainForm: string;
    CurrentForm: string;
    Cluster_Login: string;
    Cluster_Pass: string;
    Cluster_Host: string;
    Cluster_Port: string;
  end;

implementation

end.

