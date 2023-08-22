(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

program EWLog;

{$mode objfpc}{$H+}

uses {$DEFINE UseCThreads} {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, sdflaz, datetimectrls, dbflaz, printer4lazarus, MainForm_U, editqso_u,
  InformationForm_U, LogConfigForm_U, ConfigForm_U, ExportAdifForm_u,
  CreateJournalForm_U, ImportADIFForm_U, dmFunc_U, eqsl, xmlrpc, fldigi,
  DXCCEditForm_U, ManagerBasePrefixForm_U, azidis3, aziloc, QSLManagerForm_U,
  uRigControl, TRXForm_U, hrdlog, SettingsProgramForm_U, AboutForm_U,
  UpdateForm_U, Changelog_Form_U, Earth_Form_U,
  IOTA_Form_U, sendtelnetspot_form_U, ClusterFilter_Form_U, WSJT_UDP_Form_U,
  synDBDate_u, ThanksForm_u, filterForm_U, hiddentsettings_u, print_sticker_u,
  famm_u, mmform_u, hamqth, clublog, qrzcom, qso_record, resourcestr, const_u,
  SetupSQLquery, flDigiModem, GetPhotoFromInternet, GetInfoFromInternetThread,
  viewPhoto_U, LogBookTable_record, DB_record, MainFuncDM, InitDB_dm,
  prefix_record, inifile_record, selectQSO_record, foundQSO_record, cloudlog,
  init_record, WsjtUtils, digi_record, inform_record, infoDM_U, getSession,
  miniform_u, ImbedCallBookCheckRec, serverDM_u, telnetClientThread,
  dxclusterform_u, GridsForm_u, MapForm_u, ImportADIThread,
  ExportADIThread, MobileSyncThread, CloudLogCAT, STATE_Form_U, progressForm_u,
  dmCat, contestForm_u, dmContest_u, FMS_record, dmmigrate_u, ExportSOTAThread,
  CWDaemonDM_u, CWKeysForm_u, MacroEditorForm_u, CWKeysDM_u, CWTypeForm_u,
  dmTCI_u, StreamAdapter_u, DownloadFilesThread, dmHamLib_u,
  satForm_u, SatEditorForm_u, ServiceEqslForm_u, eQSLservice_u,
  ServiceLoTWForm_u, LoTWservice_u, wizardForm_u;

{$R *.res}

begin
  Application.Scaled:=True;
  Application.Title:='EWLog - HAM Journal';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TInitDB, InitDB);
  Application.CreateForm(TdmFunc, dmFunc);
  Application.CreateForm(TMainFunc, MainFunc);
  Application.CreateForm(TInfoDM, InfoDM);
  Application.CreateForm(TdmHamLib, dmHamLib);
  Application.CreateForm(TdmTCI, dmTCI);
  Application.CreateForm(TMiniForm, MiniForm);
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TTRXForm, TRXForm);
  Application.CreateForm(TServerDM, ServerDM);
  Application.CreateForm(TCWKeysDM, CWKeysDM);
  Application.CreateForm(TCWDaemonDM, CWDaemonDM);
  Application.CreateForm(TGridsForm, GridsForm);
  Application.CreateForm(TEditQSO_Form, EditQSO_Form);
  Application.CreateForm(TInformationForm, InformationForm);
  Application.CreateForm(TLogConfigForm, LogConfigForm);
  Application.CreateForm(TConfigForm, ConfigForm);
  Application.CreateForm(TexportAdifForm, exportAdifForm);
  Application.CreateForm(TCreateJournalForm, CreateJournalForm);
  Application.CreateForm(TImportADIFForm, ImportADIFForm);
  Application.CreateForm(TCountryEditForm, CountryEditForm);
  Application.CreateForm(TManagerBasePrefixForm, ManagerBasePrefixForm);
  Application.CreateForm(TQSLManager_Form, QSLManager_Form);
  Application.CreateForm(TSettingsProgramForm, SettingsProgramForm);
  Application.CreateForm(TAbout_Form, About_Form);
  Application.CreateForm(TUpdate_Form, Update_Form);
  Application.CreateForm(TChangeLog_Form, ChangeLog_Form);
  Application.CreateForm(TEarth, Earth);
  Application.CreateForm(TIOTA_Form, IOTA_Form);
  Application.CreateForm(TSTATE_Form, STATE_Form);
  Application.CreateForm(TSendTelnetSpot, SendTelnetSpot);
  Application.CreateForm(TClusterFilter, ClusterFilter);
  Application.CreateForm(TWSJT_UDP_Form, WSJT_UDP_Form);
  Application.CreateForm(TSynDBDate, SynDBDate);
  Application.CreateForm(TThanks_Form, Thanks_Form);
  Application.CreateForm(TfilterForm, filterForm);
  Application.CreateForm(ThiddenSettings, hiddenSettings);
  Application.CreateForm(TPrintSticker_Form, PrintSticker_Form);
  Application.CreateForm(TFM_Form, FM_Form);
  Application.CreateForm(TMM_Form, MM_Form);
  Application.CreateForm(TviewPhoto, viewPhoto);
  Application.CreateForm(TdxClusterForm, dxClusterForm);
  Application.CreateForm(TMapForm, MapForm);
  Application.CreateForm(TProgressBackupForm, ProgressBackupForm);
  Application.CreateForm(TContestForm, ContestForm);
  Application.CreateForm(TCWKeysForm, CWKeysForm);
  Application.CreateForm(TMacroEditorForm, MacroEditorForm);
  Application.CreateForm(TCWTypeForm, CWTypeForm);
  Application.CreateForm(TSATForm, SATForm);
  Application.CreateForm(TSATEditorForm, SATEditorForm);
  Application.CreateForm(TServiceEqslForm, ServiceEqslForm);
  Application.CreateForm(TServiceLoTWForm, ServiceLoTWForm);
  Application.CreateForm(TWizardForm, WizardForm);
  Application.Run;
end.
