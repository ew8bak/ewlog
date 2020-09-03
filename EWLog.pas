program EWLog;

{$mode objfpc}{$H+}

uses {$DEFINE UseCThreads} {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  sdflaz,
  memdslaz,
  datetimectrls,
  dbflaz,
  printer4lazarus,
  MainForm_U,
  editqso_u,
  InformationForm_U,
  LogConfigForm_U,
  ConfigForm_U,
  ExportAdifForm_u,
  CreateJournalForm_U,
  ImportADIFForm_U,
  dmFunc_U,
  SimpleXML,
  eqsl,
  xmlrpc,
  fldigi,
  DXCCEditForm_U,
  ManagerBasePrefixForm_U,
  azidis3,
  aziloc,
  QSLManagerForm_U,
  SettingsCAT_U,
  uRigControl,
  TRXForm_U,
  lnetvisual,
  hrdlog,
  SettingsProgramForm_U,
  AboutForm_U,
  ServiceForm_U,
  setupForm_U,
  UpdateForm_U,
  Changelog_Form_U,
  Earth_Form_U,
  IOTA_Form_U,
  ConfigGridForm_U,
  sendtelnetspot_form_U,
  ClusterFilter_Form_U,
  ClusterServer_Form_U,
  STATE_Form_U,
  WSJT_UDP_Form_U,
  synDBDate_u,
  ThanksForm_u,
  filterForm_U,
  hiddentsettings_u,
  print_sticker_u,
  famm_u,
  mmform_u,
  hamqth,
  clublog,
  qrzcom,
  qso_record,
  resourcestr,
  const_u,
  download_lotw,
  download_eqslcc,
  DownloadUpdates,
  SetupSQLquery,
  flDigiModem,
  analyticThread,
  GetPhotoFromInternet,
  GetInfoFromInternetThread,
  viewPhoto_U,
  LogBookTable_record,
  DB_record,
  MainFuncDM,
  InitDB_dm,
  prefix_record,
  inifile_record,
  selectQSO_record,
  foundQSO_record,
  cloudlog,
  init_record,
  WsjtUtils,
  digi_record,
  inform_record,
  infoDM_U,
  getSession,
  miniform_u,
  ImbedCallBookCheckRec;

{$R *.res}

begin
  Application.Title := rEWLogHAMJournal;
  Application.Scaled := True;
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TInitDB, InitDB);
  Application.CreateForm(TMainFunc, MainFunc);
  Application.CreateForm(TInfoDM, InfoDM);

  if IniSet.MainForm = 'MAIN' then
  begin
    Application.CreateForm(TMainForm, MainForm);
    Application.CreateForm(TMiniForm, MiniForm);
  end
  else
  begin
    Application.CreateForm(TMiniForm, MiniForm);
    Application.CreateForm(TMainForm, MainForm);
  end;

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
  Application.CreateForm(TConfigGrid_Form, ConfigGrid_Form);
  Application.CreateForm(TSendTelnetSpot, SendTelnetSpot);
  Application.CreateForm(TClusterFilter, ClusterFilter);
  Application.CreateForm(TClusterServer_Form, ClusterServer_Form);
  Application.CreateForm(TSTATE_Form, STATE_Form);
  Application.CreateForm(TWSJT_UDP_Form, WSJT_UDP_Form);
  Application.CreateForm(TSynDBDate, SynDBDate);
  Application.CreateForm(TThanks_Form, Thanks_Form);
  Application.CreateForm(TfilterForm, filterForm);
  Application.CreateForm(ThiddenSettings, hiddenSettings);
  Application.CreateForm(TPrintSticker_Form, PrintSticker_Form);
  Application.CreateForm(TFM_Form, FM_Form);
  Application.CreateForm(TMM_Form, MM_Form);
  Application.CreateForm(TviewPhoto, viewPhoto);
  Application.Run;
end.
