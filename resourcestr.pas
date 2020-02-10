unit ResourceStr;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

resourcestring
  rQSL = 'QSL';
  rQSLs = 'QSLs';
  rQSODate = 'Date';
  rQSOTime = 'Time';
  rQSOBand = 'Band';
  rQSOBandFreq = 'Frequency';
  rCallSign = 'Callsign';
  rQSOMode = 'Mode';
  rQSOSubMode = 'SubMode';
  rOMName = 'Name';
  rOMQTH = 'QTH';
  rState = 'State';
  rGrid = 'Grid';
  rQSOReportSent = 'RSTs';
  rQSOReportRecived = 'RSTr';
  rIOTA = 'IOTA';
  rQSLManager = 'Manager';
  rQSLSentDate = 'QSLs Date';
  rQSLRecDate = 'QSLr Date';
  rLoTWRecDate = 'LOTWr Date';
  rMainPrefix = 'Prefix';
  rDXCCPrefix = 'DXCC';
  rCQZone = 'CQ Zone';
  rITUZone = 'ITU Zone';
  rManualSet = 'Manual Set';
  rContinent = 'Continent';
  rValidDX = 'Valid DX';
  rQSL_RCVD_VIA = 'QSL r VIA';
  rQSL_SENT_VIA = 'QSL s VIA';
  rUSERS = 'User';
  rNoCalcDXCC = 'No Calc DXCC';
  rMySQLHasGoneAway =
    'NO connection to MySQL database! Check the connection or connection settings. Connect to SQLite';
  rWelcomeMessageMySQL = 'MySQL database selected! Welcome!';
  rWelcomeMessageSQLIte = 'SQLite database selected! Welcome!';
  rCheckSettingsMySQL = 'Check MySQL DB Settings';
  rCheckSettingsSQLIte = 'Check SQLite DB Settings';
  rDataBaseFault = 'Something went wrong ... Check the settings';
  rWarning = 'Warning!';
  rQSONotSave = 'QSO not saved, quit anyway ?!';
  rDXClusterDisconnect = 'You are disconnected from the DX cluster';
  rSwitchDBSQLIte = 'Switch base to SQLite';
  rSwitchDBMySQL = 'Switch base to MySQL';
  rDBNotInit = 'The database is not initialized, go to the settings?';
  rClientConnected = 'Client Connected:';
  rPhotoFromQRZru = 'Photo from QRZ.RU';
  rDeleteRecord = 'Delete Record ';
  rDuplicates = 'Duplicates ';
  rSyncOK = 'Done! Number of duplicates ';
  rSync = ', in sync ';
  rQSOsync = 'QSO';
  rDBError = 'Error while working with the database. Check connection and settings';
  rMySQLNotSet = 'MySQL database settings not configured';
  rNotCallsign = 'No callsign entered to view';
  rDXClusterConnecting = 'Connect to Telnet Cluster';
  rDXClusterDisconnecting = 'Disconnect from Telnet Cluster';
  rDXClusterWindowClear = 'Clear DX Cluster window';
  rSendSpot = 'Send spot';
  rEnCall = 'You must enter a callsign';
  rSaveQSO = 'Save QSO';
  rClearQSO = 'Clear QSO input window';
  rLogConWSJT = 'EWLog connected to WSJT';
  rLogNConWSJT = 'EWLog not connected to WSJT';
  rQSOTotal = ' Total ';
  rLanguageComplite = 'Translation files download successfully';
  rCleanUpJournal = 'Are you sure you want to clear all entries?';
  rErrorXMLAPI = 'Error XML API:';
  rNotConfigQRZRU =
    'Specify the Login and Password for accessing the XML API QRZ.ru in the settings';
  rInformationFromQRZRU = 'Information from QRZ.ru';
  rInformationFromQRZCOM = 'Information from QRZ.com';
  rInformationFromHamQTH = 'Information from HAMQTH';
  rDeleteLog = 'Are you sure you want to delete the log ?!';
  rCannotDelDef = 'Cannot delete default log';
  rDefaultLogSel = 'Default log selected';
  rNotDataForConnect =
    'The log configuration, do not specify the data to connect to eQSL.cc';
  rStatusConnecteQSL = 'Status: Connceting to eQSL.cc';
  rStatusDownloadeQSL = 'Status: Download eQSL.cc';
  rStatusSaveFile = 'Status: Saving file';
  rStatusNotData = 'Status: Not data';
  rStatusDone = 'Status: Done';
  rProcessedData = 'Processed data:';
  rDone = 'Done';
  rImport = 'Import';
  rImportRecord = 'Imported Records';
  rFileError = 'Error file:';
  rImportErrors = 'Import Errors';
  rNumberDup = 'Number of duplicates';
  rNothingImport = 'Nothing to import';
  rProcessing = 'Processing';

implementation

end.
