unit exportSettingsForm_u;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TexportSettingsForm }

  TexportSettingsForm = class(TForm)
    cbOperator: TCheckBox;
    cbName: TCheckBox;
    cbQth: TCheckBox;
    cbGridsquare: TCheckBox;
    cbPfx: TCheckBox;
    cbDxccPref: TCheckBox;
    cbBand: TCheckBox;
    cbCqz: TCheckBox;
    cbItuz: TCheckBox;
    cbCont: TCheckBox;
    cbQslMsg: TCheckBox;
    cbCall: TCheckBox;
    cbLotwQslSent: TCheckBox;
    cbDxcc: TCheckBox;
    cbEqslQslSent: TCheckBox;
    cbMyGridsquare: TCheckBox;
    cbMyLat: TCheckBox;
    cbMyLon: TCheckBox;
    cbClublogQsoUploadDate: TCheckBox;
    cbClublogQsoUploadStatus: TCheckBox;
    cbHrdlogQsoUploadDate: TCheckBox;
    cbHrdLogQsoUploadStatus: TCheckBox;
    cbQsoDate: TCheckBox;
    cbHamqthQsoUploadDate: TCheckBox;
    cbHamqthQsoUploadStatus: TCheckBox;
    cbFreqRx: TCheckBox;
    cbStationCallsign: TCheckBox;
    cbTimeOn: TCheckBox;
    cbMode: TCheckBox;
    cbSubMode: TCheckBox;
    cbFreq: TCheckBox;
    cbRstSent: TCheckBox;
    cbRstRcvd: TCheckBox;
    cbSrx: TCheckBox;
    cbStxString: TCheckBox;
    cbQslRcvd: TCheckBox;
    cbHamLogQslRcvd: TCheckBox;
    cbState: TCheckBox;
    cbQslRcvdVia: TCheckBox;
    cbQrzComQsoUploadDate: TCheckBox;
    cbWpx: TCheckBox;
    cbQslSentVia: TCheckBox;
    cbQrzComQsoUploadStatus: TCheckBox;
    cbBandRx: TCheckBox;
    cbEqslQslRcvd: TCheckBox;
    cbQslSent: TCheckBox;
    cbHamLogEuQsoUploadDate: TCheckBox;
    cbPropMode: TCheckBox;
    cbLotwQslRcvd: TCheckBox;
    cbHamLogEuQsoUploadStatus: TCheckBox;
    cbSatMode: TCheckBox;
    cbLotwQslRdate: TCheckBox;
    cbHamLogRuQsoUploadDate: TCheckBox;
    cbSatName: TCheckBox;
    cbComment: TCheckBox;
    cbMyState: TCheckBox;
    cbHamLogRuQsoUploadStatus: TCheckBox;
    cbStx: TCheckBox;
    cbQslSdate: TCheckBox;
    cbSotaRef: TCheckBox;
    cbSrxString: TCheckBox;
    cbQslRdate: TCheckBox;
    cbMySotaRef: TCheckBox;
    GroupBox1: TGroupBox;
    procedure cbBandChange(Sender: TObject);
    procedure cbBandRxChange(Sender: TObject);
    procedure cbCallChange(Sender: TObject);
    procedure cbClublogQsoUploadDateChange(Sender: TObject);
    procedure cbClublogQsoUploadStatusChange(Sender: TObject);
    procedure cbCommentChange(Sender: TObject);
    procedure cbContChange(Sender: TObject);
    procedure cbCqzChange(Sender: TObject);
    procedure cbDxccChange(Sender: TObject);
    procedure cbDxccPrefChange(Sender: TObject);
    procedure cbEqslQslRcvdChange(Sender: TObject);
    procedure cbEqslQslSentChange(Sender: TObject);
    procedure cbFreqChange(Sender: TObject);
    procedure cbFreqRxChange(Sender: TObject);
    procedure cbGridsquareChange(Sender: TObject);
    procedure cbHamLogEuQsoUploadDateChange(Sender: TObject);
    procedure cbHamLogEuQsoUploadStatusChange(Sender: TObject);
    procedure cbHamLogQslRcvdChange(Sender: TObject);
    procedure cbHamLogRuQsoUploadDateChange(Sender: TObject);
    procedure cbHamLogRuQsoUploadStatusChange(Sender: TObject);
    procedure cbHamqthQsoUploadDateChange(Sender: TObject);
    procedure cbHamqthQsoUploadStatusChange(Sender: TObject);
    procedure cbHrdlogQsoUploadDateChange(Sender: TObject);
    procedure cbHrdLogQsoUploadStatusChange(Sender: TObject);
    procedure cbItuzChange(Sender: TObject);
    procedure cbLotwQslRcvdChange(Sender: TObject);
    procedure cbLotwQslRdateChange(Sender: TObject);
    procedure cbLotwQslSentChange(Sender: TObject);
    procedure cbModeChange(Sender: TObject);
    procedure cbMyGridsquareChange(Sender: TObject);
    procedure cbMyLatChange(Sender: TObject);
    procedure cbMyLonChange(Sender: TObject);
    procedure cbMySotaRefChange(Sender: TObject);
    procedure cbMyStateChange(Sender: TObject);
    procedure cbNameChange(Sender: TObject);
    procedure cbOperatorChange(Sender: TObject);
    procedure cbPfxChange(Sender: TObject);
    procedure cbPropModeChange(Sender: TObject);
    procedure cbQrzComQsoUploadDateChange(Sender: TObject);
    procedure cbQrzComQsoUploadStatusChange(Sender: TObject);
    procedure cbQslMsgChange(Sender: TObject);
    procedure cbQslRcvdChange(Sender: TObject);
    procedure cbQslRcvdViaChange(Sender: TObject);
    procedure cbQslRdateChange(Sender: TObject);
    procedure cbQslSdateChange(Sender: TObject);
    procedure cbQslSentChange(Sender: TObject);
    procedure cbQslSentViaChange(Sender: TObject);
    procedure cbQsoDateChange(Sender: TObject);
    procedure cbQthChange(Sender: TObject);
    procedure cbRstRcvdChange(Sender: TObject);
    procedure cbRstSentChange(Sender: TObject);
    procedure cbSatModeChange(Sender: TObject);
    procedure cbSatNameChange(Sender: TObject);
    procedure cbSotaRefChange(Sender: TObject);
    procedure cbSrxChange(Sender: TObject);
    procedure cbSrxStringChange(Sender: TObject);
    procedure cbStateChange(Sender: TObject);
    procedure cbStationCallsignChange(Sender: TObject);
    procedure cbStxChange(Sender: TObject);
    procedure cbStxStringChange(Sender: TObject);
    procedure cbSubModeChange(Sender: TObject);
    procedure cbTimeOnChange(Sender: TObject);
    procedure cbWpxChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  exportSettingsForm: TexportSettingsForm;

implementation

uses MainFuncDM, InitDB_dm;

  {$R *.lfm}

  { TexportSettingsForm }

procedure TexportSettingsForm.FormShow(Sender: TObject);
begin
  cbOperator.Checked := exportAdiSet.fOPERATOR;
  cbTimeOn.Checked := exportAdiSet.fTIME_ON;
  cbFreq.Checked := exportAdiSet.fFREQ;
  cbName.Checked := exportAdiSet.fNAME;
  cbPfx.Checked := exportAdiSet.fPFX;
  cbCqz.Checked := exportAdiSet.fCQZ;
  cbQslMsg.Checked := exportAdiSet.fQSLMSG;
  cbEqslQslSent.Checked := exportAdiSet.fEQSL_QSL_SENT;
  cbMyLon.Checked := exportAdiSet.fMY_LON;
  cbHrdlogQsoUploadDate.Checked := exportAdiSet.fHRDLOG_QSO_UPLOAD_DATE;
  cbHrdLogQsoUploadStatus.Checked := exportAdiSet.fHRDLOG_QSO_UPLOAD_STATUS;
  cbCall.Checked := exportAdiSet.fCALL;
  cbMode.Checked := exportAdiSet.fMODE;
  cbRstSent.Checked := exportAdiSet.fRST_SENT;
  cbQth.Checked := exportAdiSet.fQTH;
  cbDxccPref.Checked := exportAdiSet.fDXCC_PREF;
  cbItuz.Checked := exportAdiSet.fITUZ;
  cbLotwQslSent.Checked := exportAdiSet.fLOTW_QSL_SENT;
  cbMyGridsquare.Checked := exportAdiSet.fMY_GRIDSQUARE;
  cbClublogQsoUploadDate.Checked := exportAdiSet.fCLUBLOG_QSO_UPLOAD_DATE;
  cbHrdLogQsoUploadStatus.Checked := exportAdiSet.fCLUBLOG_QSO_UPLOAD_STATUS;
  cbFreqRx.Checked := exportAdiSet.fFREQ_RX;
  cbQsoDate.Checked := exportAdiSet.fQSO_DATE;
  cbSubMode.Checked := exportAdiSet.fSUBMODE;
  cbRstRcvd.Checked := exportAdiSet.fRST_RCVD;
  cbGridsquare.Checked := exportAdiSet.fGRIDSQUARE;
  cbBand.Checked := exportAdiSet.fBAND;
  cbCont.Checked := exportAdiSet.fCONT;
  cbDxcc.Checked := exportAdiSet.fDXCC;
  cbMyLat.Checked := exportAdiSet.fMY_LAT;
  cbClublogQsoUploadStatus.Checked := exportAdiSet.fCLUBLOG_QSO_UPLOAD_STATUS;
  cbHamqthQsoUploadDate.Checked := exportAdiSet.fHAMQTH_QSO_UPLOAD_DATE;
  cbHamqthQsoUploadStatus.Checked := exportAdiSet.fHAMQTH_QSO_UPLOAD_STATUS;
  cbStationCallsign.Checked := exportAdiSet.fSTATION_CALLSIGN;
  cbSrx.Checked := exportAdiSet.fSRX;
  cbStx.Checked := exportAdiSet.fSTX;
  cbSrxString.Checked := exportAdiSet.fSRX_STRING;
  cbStxString.Checked := exportAdiSet.fSTX_STRING;
  cbState.Checked := exportAdiSet.fSTATE;
  cbWpx.Checked := exportAdiSet.fWPX;
  cbBandRx.Checked := exportAdiSet.fBAND_RX;
  cbPropMode.Checked := exportAdiSet.fPROP_MODE;
  cbSatMode.Checked := exportAdiSet.fSAT_MODE;
  cbSatName.Checked := exportAdiSet.fSAT_NAME;
  cbEqslQslRcvd.Checked := exportAdiSet.fEQSL_QSL_RCVD;
  cbQslSdate.Checked := exportAdiSet.fQSLSDATE;
  cbQslRdate.Checked := exportAdiSet.fQSLRDATE;
  cbQslRcvd.Checked := exportAdiSet.fQSL_RCVD;
  cbQslRcvdVia.Checked := exportAdiSet.fQSL_RCVD_VIA;
  cbQslSentVia.Checked := exportAdiSet.fQSL_SENT_VIA;
  cbQslSent.Checked := exportAdiSet.fQSL_SENT;
  cbLotwQslRcvd.Checked := exportAdiSet.fLOTW_QSL_RCVD;
  cbLotwQslRdate.Checked := exportAdiSet.fLOTW_QSLRDATE;
  cbComment.Checked := exportAdiSet.fCOMMENT;
  cbMyState.Checked := exportAdiSet.fMY_STATE;
  cbSotaRef.Checked := exportAdiSet.fSOTA_REF;
  cbMySotaRef.Checked := exportAdiSet.fMY_SOTA_REF;
  cbHamLogQslRcvd.Checked := exportAdiSet.fHAMLOG_QSL_RCVD;
  cbQrzComQsoUploadDate.Checked := exportAdiSet.fQRZCOM_QSO_UPLOAD_DATE;
  cbQrzComQsoUploadStatus.Checked := exportAdiSet.fQRZCOM_QSO_UPLOAD_STATUS;
  cbHamLogEuQsoUploadDate.Checked := exportAdiSet.fHAMLOGEU_QSO_UPLOAD_DATE;
  cbHamLogEuQsoUploadStatus.Checked := exportAdiSet.fHAMLOGEU_QSO_UPLOAD_STATUS;
  cbHamLogRuQsoUploadDate.Checked := exportAdiSet.fHAMLOGRU_QSO_UPLOAD_DATE;
  cbHamLogRuQsoUploadStatus.Checked := exportAdiSet.fHAMLOGRU_QSO_UPLOAD_STATUS;
end;

procedure TexportSettingsForm.cbOperatorChange(Sender: TObject);
begin
  exportAdiSet.fOPERATOR := cbOperator.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'OPERATOR', cbOperator.Checked);
end;

procedure TexportSettingsForm.cbPfxChange(Sender: TObject);
begin
  exportAdiSet.fPFX := cbPfx.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'PFX', cbPfx.Checked);
end;

procedure TexportSettingsForm.cbPropModeChange(Sender: TObject);
begin
  exportAdiSet.fPROP_MODE := cbPropMode.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'PROP_MODE', cbPropMode.Checked);
end;

procedure TexportSettingsForm.cbQrzComQsoUploadDateChange(Sender: TObject);
begin
  exportAdiSet.fQRZCOM_QSO_UPLOAD_DATE := cbQrzComQsoUploadDate.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'QRZCOM_QSO_UPLOAD_DATE',
    cbQrzComQsoUploadDate.Checked);
end;

procedure TexportSettingsForm.cbQrzComQsoUploadStatusChange(Sender: TObject);
begin
  exportAdiSet.fQRZCOM_QSO_UPLOAD_STATUS := cbQrzComQsoUploadStatus.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'QRZCOM_QSO_UPLOAD_STATUS',
    cbQrzComQsoUploadStatus.Checked);
end;

procedure TexportSettingsForm.cbQslMsgChange(Sender: TObject);
begin
  exportAdiSet.fQSLMSG := cbQslMsg.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'QSLMSG', cbQslMsg.Checked);
end;

procedure TexportSettingsForm.cbQslRcvdChange(Sender: TObject);
begin
  exportAdiSet.fQSL_RCVD := cbQslRcvd.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'QSL_RCVD', cbQslRcvd.Checked);
end;

procedure TexportSettingsForm.cbQslRcvdViaChange(Sender: TObject);
begin
  exportAdiSet.fQSL_RCVD_VIA := cbQslRcvdVia.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'QSL_RCVD_VIA', cbQslRcvdVia.Checked);
end;

procedure TexportSettingsForm.cbQslRdateChange(Sender: TObject);
begin
  exportAdiSet.fQSLRDATE := cbQslRdate.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'QSLRDATE', cbQslRdate.Checked);
end;

procedure TexportSettingsForm.cbQslSdateChange(Sender: TObject);
begin
  exportAdiSet.fQSLSDATE := cbQslSdate.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'QSLSDATE', cbQslSdate.Checked);
end;

procedure TexportSettingsForm.cbQslSentChange(Sender: TObject);
begin
  exportAdiSet.fQSL_SENT := cbQslSent.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'QSL_SENT', cbQslSent.Checked);
end;

procedure TexportSettingsForm.cbQslSentViaChange(Sender: TObject);
begin
  exportAdiSet.fQSL_SENT_VIA := cbQslSentVia.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'QSL_SENT_VIA', cbQslSentVia.Checked);
end;

procedure TexportSettingsForm.cbQsoDateChange(Sender: TObject);
begin
  exportAdiSet.fQSO_DATE := cbQsoDate.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'QSO_DATE', cbQsoDate.Checked);
end;

procedure TexportSettingsForm.cbQthChange(Sender: TObject);
begin
  exportAdiSet.fQTH := cbQth.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'QTH', cbQth.Checked);
end;

procedure TexportSettingsForm.cbRstRcvdChange(Sender: TObject);
begin
  exportAdiSet.fRST_RCVD := cbRstRcvd.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'RST_RCVD', cbRstRcvd.Checked);
end;

procedure TexportSettingsForm.cbRstSentChange(Sender: TObject);
begin
  exportAdiSet.fRST_SENT := cbRstSent.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'RST_SENT', cbRstSent.Checked);
end;

procedure TexportSettingsForm.cbSatModeChange(Sender: TObject);
begin
  exportAdiSet.fSAT_MODE := cbSatMode.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'SAT_MODE', cbSatMode.Checked);
end;

procedure TexportSettingsForm.cbSatNameChange(Sender: TObject);
begin
  exportAdiSet.fSAT_NAME := cbSatName.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'SAT_NAME', cbSatName.Checked);
end;

procedure TexportSettingsForm.cbSotaRefChange(Sender: TObject);
begin
  exportAdiSet.fSOTA_REF := cbSotaRef.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'SOTA_REF', cbSotaRef.Checked);
end;

procedure TexportSettingsForm.cbSrxChange(Sender: TObject);
begin
  exportAdiSet.fSRX := cbSrx.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'SRX', cbSrx.Checked);
end;

procedure TexportSettingsForm.cbSrxStringChange(Sender: TObject);
begin
  exportAdiSet.fSRX_STRING := cbSrxString.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'SRX_STRING', cbSrxString.Checked);
end;

procedure TexportSettingsForm.cbStateChange(Sender: TObject);
begin
  exportAdiSet.fSTATE := cbState.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'STATE', cbState.Checked);
end;

procedure TexportSettingsForm.cbStationCallsignChange(Sender: TObject);
begin
  exportAdiSet.fSTATION_CALLSIGN := cbStationCallsign.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'STATION_CALLSIGN', cbStationCallsign.Checked);
end;

procedure TexportSettingsForm.cbStxChange(Sender: TObject);
begin
  exportAdiSet.fSTX := cbStx.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'STX', cbStx.Checked);
end;

procedure TexportSettingsForm.cbStxStringChange(Sender: TObject);
begin
  exportAdiSet.fSTX_STRING := cbStxString.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'STX_STRING', cbStxString.Checked);
end;

procedure TexportSettingsForm.cbSubModeChange(Sender: TObject);
begin
  exportAdiSet.fSUBMODE := cbSubMode.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'SUBMODE', cbSubMode.Checked);
end;

procedure TexportSettingsForm.cbFreqChange(Sender: TObject);
begin
  exportAdiSet.fFREQ := cbFreq.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'FREQ', cbFreq.Checked);
end;

procedure TexportSettingsForm.cbFreqRxChange(Sender: TObject);
begin
  exportAdiSet.fFREQ_RX := cbFreqRx.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'FREQ_RX', cbFreqRx.Checked);
end;

procedure TexportSettingsForm.cbGridsquareChange(Sender: TObject);
begin
  exportAdiSet.fGRIDSQUARE := cbGridsquare.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'GRIDSQUARE', cbGridsquare.Checked);
end;

procedure TexportSettingsForm.cbHamLogEuQsoUploadDateChange(Sender: TObject);
begin
  exportAdiSet.fHAMLOGEU_QSO_UPLOAD_DATE := cbHamLogEuQsoUploadDate.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'HAMLOGEU_QSO_UPLOAD_DATE',
    cbHamLogEuQsoUploadDate.Checked);
end;

procedure TexportSettingsForm.cbHamLogEuQsoUploadStatusChange(Sender: TObject);
begin
  exportAdiSet.fHAMLOGEU_QSO_UPLOAD_STATUS := cbHamLogEuQsoUploadStatus.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'HAMLOGEU_QSO_UPLOAD_STATUS',
    cbHamLogEuQsoUploadStatus.Checked);
end;

procedure TexportSettingsForm.cbHamLogQslRcvdChange(Sender: TObject);
begin
  exportAdiSet.fHAMLOG_QSL_RCVD := cbHamLogQslRcvd.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'HAMLOG_QSL_RCVD', cbHamLogQslRcvd.Checked);
end;

procedure TexportSettingsForm.cbHamLogRuQsoUploadDateChange(Sender: TObject);
begin
  exportAdiSet.fHAMLOGRU_QSO_UPLOAD_DATE := cbHamLogRuQsoUploadDate.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'HAMLOGRU_QSO_UPLOAD_DATE',
    cbHamLogRuQsoUploadDate.Checked);
end;

procedure TexportSettingsForm.cbHamLogRuQsoUploadStatusChange(Sender: TObject);
begin
  exportAdiSet.fHAMLOGRU_QSO_UPLOAD_STATUS := cbHamLogRuQsoUploadStatus.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'HAMLOGRU_QSO_UPLOAD_STATUS',
    cbHamLogRuQsoUploadStatus.Checked);
end;

procedure TexportSettingsForm.cbHamqthQsoUploadDateChange(Sender: TObject);
begin
  exportAdiSet.fHAMQTH_QSO_UPLOAD_DATE := cbHamqthQsoUploadDate.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'HAMQTH_QSO_UPLOAD_DATE',
    cbHamqthQsoUploadDate.Checked);
end;

procedure TexportSettingsForm.cbHamqthQsoUploadStatusChange(Sender: TObject);
begin
  exportAdiSet.fHAMQTH_QSO_UPLOAD_STATUS := cbHamqthQsoUploadStatus.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'HAMQTH_QSO_UPLOAD_STATUS',
    cbHamqthQsoUploadStatus.Checked);
end;

procedure TexportSettingsForm.cbHrdlogQsoUploadDateChange(Sender: TObject);
begin
  exportAdiSet.fHRDLOG_QSO_UPLOAD_DATE := cbHrdlogQsoUploadDate.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'HRDLOG_QSO_UPLOAD_DATE',
    cbHrdlogQsoUploadDate.Checked);
end;

procedure TexportSettingsForm.cbHrdLogQsoUploadStatusChange(Sender: TObject);
begin
  exportAdiSet.fHRDLOG_QSO_UPLOAD_STATUS := cbHrdLogQsoUploadStatus.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'HRDLOG_QSO_UPLOAD_STATUS',
    cbHrdLogQsoUploadStatus.Checked);
end;

procedure TexportSettingsForm.cbItuzChange(Sender: TObject);
begin
  exportAdiSet.fITUZ := cbItuz.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'ITUZ', cbItuz.Checked);
end;

procedure TexportSettingsForm.cbLotwQslRcvdChange(Sender: TObject);
begin
  exportAdiSet.fLOTW_QSL_RCVD := cbLotwQslRcvd.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'LOTW_QSL_RCVD', cbLotwQslRcvd.Checked);
end;

procedure TexportSettingsForm.cbLotwQslRdateChange(Sender: TObject);
begin
  exportAdiSet.fLOTW_QSLRDATE := cbLotwQslRdate.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'LOTW_QSLRDATE', cbLotwQslRdate.Checked);
end;

procedure TexportSettingsForm.cbLotwQslSentChange(Sender: TObject);
begin
  exportAdiSet.fLOTW_QSL_SENT := cbLotwQslSent.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'LOTW_QSL_SENT', cbLotwQslSent.Checked);
end;

procedure TexportSettingsForm.cbModeChange(Sender: TObject);
begin
  exportAdiSet.fMODE := cbMode.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'MODE', cbMode.Checked);
end;

procedure TexportSettingsForm.cbMyGridsquareChange(Sender: TObject);
begin
  exportAdiSet.fMY_GRIDSQUARE := cbMyGridsquare.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'MY_GRIDSQUARE', cbMyGridsquare.Checked);
end;

procedure TexportSettingsForm.cbMyLatChange(Sender: TObject);
begin
  exportAdiSet.fMY_LAT := cbMyLat.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'MY_LAT', cbMyLat.Checked);
end;

procedure TexportSettingsForm.cbMyLonChange(Sender: TObject);
begin
  exportAdiSet.fMY_LON := cbMyLon.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'MY_LON', cbMyLon.Checked);
end;

procedure TexportSettingsForm.cbMySotaRefChange(Sender: TObject);
begin
  exportAdiSet.fMY_SOTA_REF := cbMySotaRef.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'MY_SOTA_REF', cbMySotaRef.Checked);
end;

procedure TexportSettingsForm.cbMyStateChange(Sender: TObject);
begin
  exportAdiSet.fMY_STATE := cbMyState.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'MY_STATE', cbMyState.Checked);
end;

procedure TexportSettingsForm.cbCqzChange(Sender: TObject);
begin
  exportAdiSet.fCQZ := cbCqz.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'CQZ', cbCqz.Checked);
end;

procedure TexportSettingsForm.cbDxccChange(Sender: TObject);
begin
  exportAdiSet.fDXCC := cbDxcc.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'DXCC', cbDxcc.Checked);
end;

procedure TexportSettingsForm.cbDxccPrefChange(Sender: TObject);
begin
  exportAdiSet.fDXCC_PREF := cbDxccPref.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'DXCC_PREF', cbDxccPref.Checked);
end;

procedure TexportSettingsForm.cbEqslQslRcvdChange(Sender: TObject);
begin
  exportAdiSet.fEQSL_QSL_RCVD := cbEqslQslRcvd.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'EQSL_QSL_RCVD', cbEqslQslRcvd.Checked);
end;

procedure TexportSettingsForm.cbCallChange(Sender: TObject);
begin
  exportAdiSet.fCALL := cbCall.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'CALL', cbCall.Checked);
end;

procedure TexportSettingsForm.cbBandChange(Sender: TObject);
begin
  exportAdiSet.fBAND := cbBand.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'BAND', cbBand.Checked);
end;

procedure TexportSettingsForm.cbBandRxChange(Sender: TObject);
begin
  exportAdiSet.fBAND_RX := cbBandRx.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'BAND_RX', cbBandRx.Checked);
end;

procedure TexportSettingsForm.cbClublogQsoUploadDateChange(Sender: TObject);
begin
  exportAdiSet.fCLUBLOG_QSO_UPLOAD_DATE := cbClublogQsoUploadDate.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'CLUBLOG_QSO_UPLOAD_DATE',
    cbClublogQsoUploadDate.Checked);
end;

procedure TexportSettingsForm.cbClublogQsoUploadStatusChange(Sender: TObject);
begin
  exportAdiSet.fCLUBLOG_QSO_UPLOAD_STATUS := cbClublogQsoUploadStatus.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'CLUBLOG_QSO_UPLOAD_STATUS',
    cbClublogQsoUploadStatus.Checked);
end;

procedure TexportSettingsForm.cbCommentChange(Sender: TObject);
begin
  exportAdiSet.fCOMMENT := cbComment.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'COMMENT', cbComment.Checked);
end;

procedure TexportSettingsForm.cbContChange(Sender: TObject);
begin
  exportAdiSet.fCONT := cbCont.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'CONT', cbCont.Checked);
end;

procedure TexportSettingsForm.cbEqslQslSentChange(Sender: TObject);
begin
  exportAdiSet.fEQSL_QSL_SENT := cbEqslQslSent.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'EQSL_QSL_SENT', cbEqslQslSent.Checked);
end;

procedure TexportSettingsForm.cbNameChange(Sender: TObject);
begin
  exportAdiSet.fNAME := cbName.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'NAME', cbName.Checked);
end;

procedure TexportSettingsForm.cbTimeOnChange(Sender: TObject);
begin
  exportAdiSet.fTIME_ON := cbTimeOn.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'TIME_ON', cbTimeOn.Checked);
end;

procedure TexportSettingsForm.cbWpxChange(Sender: TObject);
begin
  exportAdiSet.fWPX := cbWpx.Checked;
  iniFile.WriteBool('ExportFieldsADI', 'WPX', cbWpx.Checked);
end;

end.
