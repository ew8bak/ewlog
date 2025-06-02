unit exportFields_record;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TexportRecord = record
    fOPERATOR: boolean;
    fTIME_ON: boolean;
    fFREQ: boolean;
    fNAME: boolean;
    fPFX: boolean;
    fCQZ: boolean;
    fQSLMSG: boolean;
    fEQSL_QSL_SENT: boolean;
    fMY_LON: boolean;
    fHRDLOG_QSO_UPLOAD_DATE: boolean;
    fHAMQTH_QSO_UPLOAD_STATUS: boolean;
    fCALL: boolean;
    fMODE: boolean;
    fRST_SENT: boolean;
    fQTH: boolean;
    fDXCC_PREF: boolean;
    fITUZ: boolean;
    fLOTW_QSL_SENT: boolean;
    fMY_GRIDSQUARE: boolean;
    fCLUBLOG_QSO_UPLOAD_DATE: boolean;
    fHRDLOG_QSO_UPLOAD_STATUS: boolean;
    fFREQ_RX: boolean;
    fQSO_DATE: boolean;
    fSUBMODE: boolean;
    fRST_RCVD: boolean;
    fGRIDSQUARE: boolean;
    fBAND: boolean;
    fCONT: boolean;
    fDXCC: boolean;
    fSRX: boolean;
    fSTX: boolean;
    fSRX_STRING: boolean;
    fSTX_STRING: boolean;
    fSTATE: Boolean;
    fWPX: Boolean;
    fBAND_RX: Boolean;
    fPROP_MODE: Boolean;
    fSAT_MODE: Boolean;
    fSAT_NAME: Boolean;
    fEQSL_QSL_RCVD: Boolean;
    fQSLSDATE: Boolean;
    fQSLRDATE: Boolean;
    fQSL_RCVD: Boolean;
    fQSL_RCVD_VIA: Boolean;
    fQSL_SENT_VIA: Boolean;
    fQSL_SENT: Boolean;
    fLOTW_QSL_RCVD: Boolean;
    fLOTW_QSLRDATE: Boolean;
    fCOMMENT: Boolean;
    fMY_STATE: Boolean;
    fSOTA_REF: Boolean;
    fMY_SOTA_REF: Boolean;
    fHAMLOG_QSL_RCVD: Boolean;
    fQRZCOM_QSO_UPLOAD_DATE: Boolean;
    fQRZCOM_QSO_UPLOAD_STATUS: Boolean;
    fHAMLOGEU_QSO_UPLOAD_DATE: Boolean;
    fHAMLOGEU_QSO_UPLOAD_STATUS: Boolean;
    fHAMLOGONLINE_QSO_UPLOAD_DATE: Boolean;
    fHAMLOGONLINE_QSO_UPLOAD_STATUS: Boolean;
    fMY_LAT: boolean;
    fCLUBLOG_QSO_UPLOAD_STATUS: boolean;
    fHAMQTH_QSO_UPLOAD_DATE: boolean;
    fSTATION_CALLSIGN: boolean;
  end;

implementation

end.
