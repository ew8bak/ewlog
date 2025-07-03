(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit inifile_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TINIR = record
    UniqueID: string;
    UseIntCallBook: boolean;
    PhotoDir: string;
    StateToQSLInfo: boolean;
    Fl_PATH: string;
    WSJT_PATH: string;
    FLDIGI_USE: boolean;
    WSJT_USE: boolean;
    mTop: boolean;
    gTop: boolean;
    cTop: boolean;
    eTop: boolean;
    mShow: boolean;
    gShow: boolean;
    cShow: boolean;
    eShow: boolean;
    pShow: boolean;
    pSeparate: boolean;
    trxShow: boolean;
    pTop: boolean;
    trxTop: boolean;
    PastMode: string;
    PastSubMode: string;
    showBand: boolean;
    PastBand: integer;
    Language: string;
    Map_Use: boolean;
    PrintPrev: boolean;
    FormState: string;
    CloudLogServer: string;
    CloudLogApiKey: string;
    CloudLogStationId: string;
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
    BackupDB: boolean;
    BackupADI: boolean;
    BackupADIonClose: boolean;
    BackupDBonClose: boolean;
    BackupTime: TTime;
    rigctldStartUp: boolean;
    rigctldExtra: string;
    rigctldPath: string;
    KeySave: string;
    KeyClear: string;
    KeyReference: string;
    KeyImportADI: string;
    KeyExportADI: string;
    KeySentSpot: string;
    ContestLastNumber: integer;
    ContestLastMSG: string;
    ContestName: string;
    ContestTourTime: integer;
    ContestSession: string;
    ContestExchangeType: string;
    WorkOnLAN: boolean;
    WOLAddress: string;
    WOLPort: integer;
    CWDaemonAddr: string;
    CWDaemonPort: integer;
    CWDaemonEnable: boolean;
    CWOverTCI: boolean;
    CWWPM: integer;
    CWManager: string;
    CWTypeEnable: boolean;
    InterfaceMobileSync: string;
    ViewFreq: integer;
    CurrentRIG: string;
    RIGConnected: boolean;
    VHFProp: string;
    TXFreq: string;
    SATName: string;
    SATMode: string;
    LoTW_Path: string;
    LoTW_QTH: string;
    LoTW_Key: string;
    WinDarkMode: integer;
  end;

implementation

end.
