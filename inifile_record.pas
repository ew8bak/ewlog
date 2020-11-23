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
    _l_multi: integer;
    _t_multi: integer;
    _w_multi: integer;
    _h_multi: integer;
    _l_main: integer;
    _t_main: integer;
    _w_main: integer;
    _h_main: integer;
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
    mTop: boolean;
    gTop: boolean;
    cTop: boolean;
    eTop: boolean;
    mShow: boolean;
    gShow: boolean;
    cShow: boolean;
    eShow: boolean;
    _l_p: integer;
    _t_p: integer;
    _w_p: integer;
    _h_p: integer;
    pShow: boolean;
    pSeparate: boolean;
    _l_trx: integer;
    _t_trx: integer;
    _w_trx: integer;
    _h_trx: integer;
    trxShow: boolean;
    pTop: boolean;
    trxTop: boolean;
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
    ClusterAutoStart: boolean;
    VisibleComment: boolean;
    PathBackupFiles: string;
    BackupDB: Boolean;
    BackupADI: Boolean;
    BackupADIonClose: Boolean;
    BackupDBonClose: Boolean;
    BackupTime: TTime;
  end;

implementation

end.

