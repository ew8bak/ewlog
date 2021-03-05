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
  Forms, sdflaz, memdslaz, datetimectrls, dbflaz, printer4lazarus, MainForm_U,
  editqso_u, InformationForm_U, LogConfigForm_U, ConfigForm_U, ExportAdifForm_u,
  CreateJournalForm_U, ImportADIFForm_U, dmFunc_U, eqsl, xmlrpc,
  fldigi, DXCCEditForm_U, ManagerBasePrefixForm_U, azidis3, aziloc,
  QSLManagerForm_U, SettingsCAT_U, uRigControl, TRXForm_U, lnetvisual, hrdlog,
  SettingsProgramForm_U, AboutForm_U, ServiceForm_U, setupForm_U, UpdateForm_U,
  Changelog_Form_U, Earth_Form_U, IOTA_Form_U,
  sendtelnetspot_form_U, ClusterFilter_Form_U, ClusterServer_Form_U,
  WSJT_UDP_Form_U, synDBDate_u, ThanksForm_u, filterForm_U,
  hiddentsettings_u, print_sticker_u, famm_u, mmform_u, hamqth, clublog, qrzcom,
  qso_record, resourcestr, const_u, download_lotw, download_eqslcc,
  DownloadUpdates, SetupSQLquery, flDigiModem,
  GetPhotoFromInternet, GetInfoFromInternetThread, viewPhoto_U,
  LogBookTable_record, DB_record, MainFuncDM, InitDB_dm, prefix_record,
  inifile_record, selectQSO_record, foundQSO_record, cloudlog, init_record,
  WsjtUtils, digi_record, inform_record, infoDM_U, getSession, miniform_u,
  ImbedCallBookCheckRec, serverDM_u, telnetClientThread, dxclusterform_u,
  GridsForm_u, MapForm_u, CopyTableThread, ImportADIThread, ExportADIThread,
  MobileSyncThread, CloudLogCAT, STATE_Form_U, progressForm_u, dmCat;

{$R *.res}

begin
  Application.Title:='EWLog - HAM Journal';
  Application.Scaled := True;
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TInitDB, InitDB);
  Application.CreateForm(TMainFunc, MainFunc);
  Application.CreateForm(TInfoDM, InfoDM);
  Application.CreateForm(TMiniForm, MiniForm);
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TServerDM, ServerDM);
  Application.CreateForm(TGridsForm, GridsForm);
  Application.CreateForm(TEditQSO_Form, EditQSO_Form);
  Application.CreateForm(TInformationForm, InformationForm);
  Application.CreateForm(TLogConfigForm, LogConfigForm);
  Application.CreateForm(TConfigForm, ConfigForm);
  Application.CreateForm(TexportAdifForm, exportAdifForm);
  Application.CreateForm(TCreateJournalForm, CreateJournalForm);
  Application.CreateForm(TImportADIFForm, ImportADIFForm);
  Application.CreateForm(TdmFunc, dmFunc);
  Application.CreateForm(TCountryEditForm, CountryEditForm);
  Application.CreateForm(TManagerBasePrefixForm, ManagerBasePrefixForm);
  Application.CreateForm(TQSLManager_Form, QSLManager_Form);
  Application.CreateForm(TSettingsCAT, SettingsCAT);
  Application.CreateForm(TTRXForm, TRXForm);
  Application.CreateForm(TSettingsProgramForm, SettingsProgramForm);
  Application.CreateForm(TAbout_Form, About_Form);
  Application.CreateForm(TServiceForm, ServiceForm);
  Application.CreateForm(TSetupForm, SetupForm);
  Application.CreateForm(TUpdate_Form, Update_Form);
  Application.CreateForm(TChangeLog_Form, ChangeLog_Form);
  Application.CreateForm(TEarth, Earth);
  Application.CreateForm(TIOTA_Form, IOTA_Form);
  Application.CreateForm(TSTATE_Form, STATE_Form);
  Application.CreateForm(TSendTelnetSpot, SendTelnetSpot);
  Application.CreateForm(TClusterFilter, ClusterFilter);
  Application.CreateForm(TClusterServer_Form, ClusterServer_Form);
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
  Application.Run;
end.
