unit MainForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mysql56conn, sqldb, sqldblib, sqlite3conn, DB, BufDataset,
  dbf, FileUtil, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls, DBGrids,
  ComCtrls, StdCtrls, EditBtn, Buttons, DBCtrls, DateTimePicker, DateUtils,
  lazutf8sysutils, RegExpr, IdIPWatch, LazUTF8, LCLProc, ActnList, Grids,
  kcMapViewer, INIFiles, md5, pingsend, kcMapViewerGLGeoNames, LCLType,
  Tlntsend
  {$IFDEF UNIX}, kcMapViewerDESynapse, process, {$ELSE}, kcMapViewerDEWin32,
  {$ENDIF UNIX} lNetComponents, LCLIntf, lNet, StrUtils;

const
  constColumnName: array [0..28] of string =
    ('QSL', 'QSLs', 'QSODate', 'QSOTime', 'QSOBand', 'CallSign', 'QSOMode', 'OMName',
    'OMQTH', 'State', 'Grid', 'QSOReportSent', 'QSOReportRecived', 'IOTA', 'QSLManager',
    'QSLSentDate', 'QSLRecDate', 'LoTWRecDate', 'MainPrefix', 'DXCCPrefix', 'CQZone',
    'ITUZone', 'ManualSet', 'Continent', 'ValidDX', 'QSL_RCVD_VIA', 'QSL_SENT_VIA',
    'USERS', 'NoCalcDXCC');
  constColumnWidth: array[0..28] of integer =
    (30, 35, 65, 45, 65, 65, 50, 70, 90, 40, 50, 35, 35, 50, 64, 64,
    64, 64, 55, 55, 55, 55,
    64, 70, 64, 64, 64, 64, 64);
  constBandName: array [0..12] of string =
     ('160M','80M','60M','40M','30M','20M','17M','15M','12M','10M','6M','2M',
     '70CM');
  constKhzBandName: array [0..12] of string =
     ('1.800.00','3.500.00','5.000.00','7.000.00','10.000.00','14.000.00',
     '18.000.00','21.000.00','24.000.00','28.000.00','54.000.00','144.000.00',
     '430.000.00');
type

  { TMainForm }
  TExplodeArray = array of string;

  TMainForm = class(TForm)
    CallBookLiteConnection: TSQLite3Connection;
    CheckBox6: TCheckBox;
    CheckMySQL_Connect: TTimer;
    ClearEdit: TAction;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox8: TComboBox;
    Edit12: TEdit;
    Edit13: TEdit;
    IdIPWatch1: TIdIPWatch;
    Label49: TLabel;
    Label50: TLabel;
    LTCPComponent1: TLTCPComponent;
    LUDPComponent1: TLUDPComponent;
    // LTelnetClientComponent1: TLTelnetClientComponent;
    Memo1: TMemo;
    MenuItem10: TMenuItem;
    MenuItem100: TMenuItem;
    MenuItem101: TMenuItem;
    MenuItem102: TMenuItem;
    MenuItem103: TMenuItem;
    MenuItem104: TMenuItem;
    MenuItem105: TMenuItem;
    MenuItem106: TMenuItem;
    MenuItem107: TMenuItem;
    MenuItem108: TMenuItem;
    MenuItem109: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    MenuItem33: TMenuItem;
    MenuItem34: TMenuItem;
    MenuItem35: TMenuItem;
    MenuItem36: TMenuItem;
    MenuItem37: TMenuItem;
    MenuItem38: TMenuItem;
    MenuItem39: TMenuItem;
    MenuItem40: TMenuItem;
    MenuItem41: TMenuItem;
    MenuItem42: TMenuItem;
    MenuItem43: TMenuItem;
    MenuItem44: TMenuItem;
    MenuItem45: TMenuItem;
    MenuItem46: TMenuItem;
    MenuItem47: TMenuItem;
    MenuItem48: TMenuItem;
    MenuItem49: TMenuItem;
    MenuItem50: TMenuItem;
    MenuItem51: TMenuItem;
    MenuItem52: TMenuItem;
    MenuItem53: TMenuItem;
    MenuItem54: TMenuItem;
    MenuItem55: TMenuItem;
    MenuItem56: TMenuItem;
    MenuItem57: TMenuItem;
    MenuItem58: TMenuItem;
    MenuItem59: TMenuItem;
    MenuItem60: TMenuItem;
    MenuItem61: TMenuItem;
    MenuItem62: TMenuItem;
    MenuItem63: TMenuItem;
    MenuItem64: TMenuItem;
    MenuItem65: TMenuItem;
    MenuItem66: TMenuItem;
    MenuItem67: TMenuItem;
    MenuItem68: TMenuItem;
    MenuItem69: TMenuItem;
    MenuItem70: TMenuItem;
    MenuItem71: TMenuItem;
    MenuItem72: TMenuItem;
    MenuItem73: TMenuItem;
    MenuItem74: TMenuItem;
    MenuItem75: TMenuItem;
    MenuItem76: TMenuItem;
    MenuItem77: TMenuItem;
    MenuItem78: TMenuItem;
    MenuItem79: TMenuItem;
    MenuItem80: TMenuItem;
    MenuItem81: TMenuItem;
    MenuItem82: TMenuItem;
    MenuItem83: TMenuItem;
    MenuItem84: TMenuItem;
    MenuItem85: TMenuItem;
    MenuItem86: TMenuItem;
    MenuItem87: TMenuItem;
    MenuItem88: TMenuItem;
    MenuItem89: TMenuItem;
    MenuItem9: TMenuItem;
    DeleteQSOQuery: TSQLQuery;
    MenuItem90: TMenuItem;
    MenuItem91: TMenuItem;
    MenuItem92: TMenuItem;
    MenuItem93: TMenuItem;
    MenuItem94: TMenuItem;
    MenuItem95: TMenuItem;
    MenuItem96: TMenuItem;
    MenuItem97: TMenuItem;
    MenuItem98: TMenuItem;
    MenuItem99: TMenuItem;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel9: TPanel;
    PopupMenu2: TPopupMenu;
    SpeedButton24: TSpeedButton;
    SpeedButton25: TSpeedButton;
    SpeedButton26: TSpeedButton;
    SpeedButton27: TSpeedButton;
    SpeedButton28: TSpeedButton;
    SpeedButton29: TSpeedButton;
    TabSheet2: TTabSheet;
    WSJT_Timer: TTimer;
    TrayPopup: TPopupMenu;
    sgCluster: TStringGrid;
    SpeedButton18: TSpeedButton;
    SpeedButton19: TSpeedButton;
    SpeedButton20: TSpeedButton;
    SpeedButton21: TSpeedButton;
    SpeedButton22: TSpeedButton;
    SpeedButton23: TSpeedButton;
    ServiceDBConnection: TSQLite3Connection;
    SQLiteDBConnection: TSQLite3Connection;
    CopySQLQuery: TSQLQuery;
    SQLiteTr: TSQLTransaction;
    DUPEQuery: TSQLQuery;
    CopySQLQuery2: TSQLQuery;
    DUPEQuery2: TSQLQuery;
    SQLServiceTransaction: TSQLTransaction;
    StatusBar1: TStatusBar;
    Timer2: TTimer;
    Fl_Timer: TTimer;
    CheckUpdatesTimer: TTimer;
    Timer3: TTimer;
    VHFTypeDS: TDataSource;
    MapViewer1: TMapViewer;
    MenuItem8: TMenuItem;
    MVGLGeoNames1: TMVGLGeoNames;
    PopupMenu1: TPopupMenu;
    SaveQSOinBase: TAction;
    ActionList1: TActionList;
    Bevel1: TBevel;
    Bevel10: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel6: TBevel;
    Bevel7: TBevel;
    Bevel8: TBevel;
    Bevel9: TBevel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox5: TCheckBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    ComboBox6: TComboBox;
    ComboBox7: TComboBox;
    LOGBookDS: TDataSource;
    DataSource2: TDataSource;
    SearchRACDS: TDataSource;
    DBLookupComboBox1: TDBLookupComboBox;
    LogBookInfoDS: TDataSource;
    DateEdit1: TDateEdit;
    DateTimePicker1: TDateTimePicker;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    EditButton1: TEditButton;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label4: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LOGBookQuery: TSQLQuery;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MySQLLOGDBConnection: TMySQL56Connection;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel13: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    PrefixARRLQuery: TSQLQuery;
    PrefixProvinceQuery: TSQLQuery;
    PrefixQuery: TSQLQuery;
    SpeedButton1: TSpeedButton;
    SpeedButton14: TSpeedButton;
    SpeedButton15: TSpeedButton;
    SpeedButton16: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    LogBookInfoQuery: TSQLQuery;
    SearchCallBookQuery: TSQLQuery;
    LogBookFieldQuery: TSQLQuery;
    SaveQSOQuery: TSQLQuery;
    VHFTypeQuery: TSQLQuery;
    SQLQuery2: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    CallBookTransaction: TSQLTransaction;
    TabSheet1: TTabSheet;
    Timer1: TTimer;
    TrayIcon1: TTrayIcon;
    procedure Button1Click(Sender: TObject);
    procedure CallBookLiteConnectionAfterDisconnect(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox6Change(Sender: TObject);
    procedure CheckMySQL_ConnectTimer(Sender: TObject);
    //{$IfDef WINDOWS}
    procedure CheckUpdatesTimerStartTimer(Sender: TObject);
    procedure CheckUpdatesTimerTimer(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    //{$ENDIF WINDOWS}
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure ComboBox8Change(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1ColumnMoved(Sender: TObject; FromIndex, ToIndex: integer);
    procedure DBGrid1ColumnSized(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure DBGrid1KeyPress(Sender: TObject; var Key: char);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure DBGrid2DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure DBLookupComboBox1Change(Sender: TObject);
    procedure DBLookupComboBox1CloseUp(Sender: TObject);
    procedure Edit12KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure Edit1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure EditButton1ButtonClick(Sender: TObject);
    procedure EditButton1Change(Sender: TObject);
    procedure Fl_TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label50Click(Sender: TObject);
    procedure LogBookInfoDSDataChange(Sender: TObject; Field: TField);
    procedure LTCPComponent1Accept(aSocket: TLSocket);
    procedure LTCPComponent1CanSend(aSocket: TLSocket);
    procedure LTCPComponent1Error(const msg: string; aSocket: TLSocket);
    procedure LTCPComponent1Receive(aSocket: TLSocket);
    procedure LUDPComponent1Receive(aSocket: TLSocket);
    procedure MenuItem101Click(Sender: TObject);
    procedure MenuItem102Click(Sender: TObject);
    procedure MenuItem103Click(Sender: TObject);
    procedure MenuItem104Click(Sender: TObject);
    procedure MenuItem105Click(Sender: TObject);
    procedure MenuItem106Click(Sender: TObject);
    procedure MenuItem107Click(Sender: TObject);
    procedure MenuItem108Click(Sender: TObject);
    procedure MenuItem109Click(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem13Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure MenuItem17Click(Sender: TObject);
    procedure MenuItem21Click(Sender: TObject);
    procedure MenuItem22Click(Sender: TObject);
    procedure MenuItem23Click(Sender: TObject);
    procedure MenuItem24Click(Sender: TObject);
    procedure MenuItem25Click(Sender: TObject);
    procedure MenuItem27Click(Sender: TObject);
    procedure MenuItem28Click(Sender: TObject);
    procedure MenuItem29Click(Sender: TObject);
    procedure MenuItem30Click(Sender: TObject);
    procedure MenuItem31Click(Sender: TObject);
    procedure MenuItem35Click(Sender: TObject);
    procedure MenuItem36Click(Sender: TObject);
    procedure MenuItem37Click(Sender: TObject);
    procedure MenuItem38Click(Sender: TObject);
    procedure MenuItem40Click(Sender: TObject);
    procedure MenuItem41Click(Sender: TObject);
    procedure MenuItem42Click(Sender: TObject);
    procedure MenuItem43Click(Sender: TObject);
    procedure MenuItem46Click(Sender: TObject);
    procedure MenuItem48Click(Sender: TObject);
    procedure MenuItem49Click(Sender: TObject);
    procedure MenuItem51Click(Sender: TObject);
    procedure MenuItem52Click(Sender: TObject);
    procedure MenuItem53Click(Sender: TObject);
    procedure MenuItem55Click(Sender: TObject);
    procedure MenuItem56Click(Sender: TObject);
    procedure MenuItem60Click(Sender: TObject);
    procedure MenuItem63Click(Sender: TObject);
    procedure MenuItem65Click(Sender: TObject);
    procedure MenuItem66Click(Sender: TObject);
    procedure MenuItem69Click(Sender: TObject);
    procedure MenuItem70Click(Sender: TObject);
    procedure MenuItem72Click(Sender: TObject);
    procedure MenuItem73Click(Sender: TObject);
    procedure MenuItem74Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem82Click(Sender: TObject);
    procedure MenuItem83Click(Sender: TObject);
    procedure MenuItem84Click(Sender: TObject);
    procedure MenuItem86Click(Sender: TObject);
    procedure MenuItem87Click(Sender: TObject);
    procedure MenuItem88Click(Sender: TObject);
    procedure MenuItem89Click(Sender: TObject);
    procedure MenuItem91Click(Sender: TObject);
    procedure MenuItem92Click(Sender: TObject);
    procedure MenuItem94Click(Sender: TObject);
    procedure MenuItem95Click(Sender: TObject);
    procedure MenuItem96Click(Sender: TObject);
    procedure MenuItem98Click(Sender: TObject);
    procedure MenuItem99Click(Sender: TObject);
    procedure MySQLLOGDBConnectionAfterConnect(Sender: TObject);
    procedure Panel10Click(Sender: TObject);
    procedure sgClusterDblClick(Sender: TObject);
    procedure SpeedButton16Click(Sender: TObject);
    procedure SpeedButton17Click(Sender: TObject);
    procedure SpeedButton18Click(Sender: TObject);
    procedure SpeedButton18MouseLeave(Sender: TObject);
    procedure SpeedButton18MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure SpeedButton19Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton20Click(Sender: TObject);
    procedure SpeedButton20MouseLeave(Sender: TObject);
    procedure SpeedButton20MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure SpeedButton21Click(Sender: TObject);
    procedure SpeedButton21MouseLeave(Sender: TObject);
    procedure SpeedButton21MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure SpeedButton22Click(Sender: TObject);
    procedure SpeedButton22MouseLeave(Sender: TObject);
    procedure SpeedButton22MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure SpeedButton23Click(Sender: TObject);
    procedure SpeedButton26Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton8MouseLeave(Sender: TObject);
    procedure SpeedButton8MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure SpeedButton9Click(Sender: TObject);
    procedure SpeedButton9MouseLeave(Sender: TObject);
    procedure SpeedButton9MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure SQLiteDBConnectionAfterConnect(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure WSJT_TimerTimer(Sender: TObject);

  private
    { private declarations }
    FDownloader: TCustomDownloadEngine;
    cluster: TTelnetSend;
    formmode: integer;
    showinfo: boolean;
    loginmsg: string;
    procedure DoBeforeDownload(Url: string; str: TStream; var CanHandle: boolean);
    procedure DoAfterDownload(Url: string; str: TStream);

  public
    { public declarations }
    ColorTextGrid: integer;
    ColorBackGrid: integer;
    SizeTextGrid: integer;
    columnsGrid: array[0..28] of string;
    columnsWidth: array[0..28] of integer;
    columnsVisible: array[0..28] of boolean;
    RegisterLog, LoginLog, PassLog: string;
    PhotoDir: string;
    ExportAdifSelect: boolean;
    ExportAdifArray: array of integer;
    ExportAdifMobile: boolean;
    ImportAdifMobile: boolean;
    AdifMobileString: TStringList;
    AdifFromMobileString: TStringList;
    Stream: TMemoryStream;
    AdifFromMobileSyncStart: boolean;
    AdifMobileStringApply: boolean;
    ready: boolean;
    AdifDataSyncAll: boolean;
    AdifDataSyncDate: boolean;
    AdifDataDate: string;
    BuffToSend: string;
    freqchange: Boolean;

    inupdate: boolean;
    function Login(host, port, userid, passwd: string): boolean;
    procedure SendSpot(freq, call, cname, mode, rsts, grid: string);
    procedure SelectLogDatabase(LogDB: string);
    procedure SelDB(calllbook: string);
    procedure SearchCallLog(callNameS: string; ind: integer);
    procedure Clr();
    procedure SaveQSO(CallSing: string; QSODate: TDateTime;
      QSOTime, QSOBand, QSOMode, QSOReportSent, QSOReportRecived,
      OmName, OmQTH, State0, Grid, IOTA, QSLManager, QSLSent, QSLSentAdv,
      QSLSentDate, QSLRec, QSLRecDate, MainPrefix, DXCCPrefix, CQZone,
      ITUZone, QSOAddInfo, Marker: string; ManualSet: integer;
      DigiBand, Continent, ShortNote: string; QSLReceQSLcc: integer;
      LotWRec, LotWRecDate, QSLInfo, Call, State1, State2, State3,
      State4, WPX, AwardsEx, ValidDX: string; SRX: integer; SRX_String: string;
      STX: integer; STX_String, SAT_NAME, SAT_MODE, PROP_MODE: string;
      LotWSent: integer; QSL_RCVD_VIA, QSL_SENT_VIA, DXCC, USERS: string;
      NoCalcDXCC: integer; NLogDB: string);//, Index: string);
    procedure SearchCallInCallBook(CallName: string);
    procedure SearchPrefix(CallName: string; gridloc: boolean);
    procedure InitializeDB(dbS: string);
    procedure SelectQSO;
    procedure SetGrid;
    function GetNewChunk: string;

  end;

var
  MainForm: TMainForm;
  QTH_LAT: currency;
  QTH_LON: currency;
  PrefixProvinceCount: integer;
  PrefixARRLCount: integer;
  PrefixProvinceList: TStringList;
  PrefixARRLList: TStringList;
  PrefixExp: TRegExpr;
  IniF: TINIFile;
  CallLogBook: string;
  SetCallName, LogTable, SetDiscription, SetNameC, SetQTH, SetITU,
  SetLoc, SetCQ, SetLat, SetLon, SetQSLInfo: string;
  DXCCNum: integer;
  CallLAT, CallLON, la1, lo1: string;
  UnUsIndex: integer;
  LoginBD, PasswdDB, NameDB, HostDB, PortDB, DefaultDB, SQLiteFILE: string;
  LoginCallBook, PasswdCallBook, NameCallBook, HostCallBook, PortCallBook: string;
  UseCallBook: string;
  InitLog_DB: string;
  LoginCluster, PasswordCluster, HostCluster, PortCluster: string;
  eQSLccLogin, eQSLccPassword, HRDLogin, HRDCode: string;
  AutoEQSLcc, AutoHRDLog: boolean;
  tx, txWSJT: boolean;
  connected, connectedWSJT: boolean;
  usefldigi: boolean = True;
  usewsjt: boolean = True;
  fldigiactive: boolean = False;
  wsjtactive: boolean = False;
  fldigiversion: string;
  fldigikeepontop: boolean = False;
  timedif: integer;
  lastID: integer;
  fl_path, XMLRPC_FL_USE, FLDIGI_USE, wsjt_path, WSJT_USE: string;
  myLocator: string;
  dbSel: string;
  useMAPS: string;
  StayForm: boolean;
  EditFlag: boolean;
  TelStr: array[1..9] of string;
  TelServ, TelPort, TelName: string;
  exportSelectADIF: boolean = False;
  showTRXform: boolean;
  CheckForm: string;
  sprav: string;



implementation

uses
  ConfigForm_U, ManagerBasePrefixForm_U, ExportAdifForm_u, CreateJournalForm_U,
  ImportADIFForm_U, dmFunc_U, eqsl, xmlrpc, fldigi, aziloc,
  QSLManagerForm_U, SettingsCAT_U,
  TRXForm_U, editqso_u, InformationForm_U, LogConfigForm_U, hrdlog,
  SettingsProgramForm_U, AboutForm_U, ServiceForm_U, setupForm_U,
  UpdateForm_U, Earth_Form_U,
  IOTA_Form_U, ConfigGridForm_U, SendTelnetSpot_Form_U, ClusterFilter_Form_U,
  ClusterServer_Form_U, STATE_Form_U, WSJT_UDP_Form_U, synDBDate_u,
  ThanksForm_u, register_form_u,
  logtcpform_u, filterForm_U, hiddentsettings_u;


{$R *.lfm}

{ TMainForm }

procedure TMainForm.SetGrid;
var
  i: integer;
begin
  for i := 0 to 28 do
  begin
    columnsGrid[i] := IniF.ReadString('GridSettings', 'Columns' +
      IntToStr(i), constColumnName[i]);
    columnsWidth[i] := IniF.ReadInteger('GridSettings', 'ColWidth' +
      IntToStr(i), constColumnWidth[i]);
    columnsVisible[i] := IniF.ReadBool('GridSettings', 'ColVisible' + IntToStr(i), True);
  end;

  ColorTextGrid := IniF.ReadInteger('GridSettings', 'TextColor', 0);
  SizeTextGrid := IniF.ReadInteger('GridSettings', 'TextSize', 8);
  ColorBackGrid := IniF.ReadInteger('GridSettings', 'BackColor', -2147483617);
  DBGrid1.Font.Size := SizeTextGrid;
  DBGrid1.Color := ColorBackGrid;
   DBGrid2.Font.Size := SizeTextGrid;
  DBGrid2.Color := ColorBackGrid;

  //Для первого грида
  for i := 0 to 28 do
  begin
    DBGrid1.Columns.Items[i].FieldName := columnsGrid[i];
    DBGrid1.Columns.Items[i].Width := columnsWidth[i];
    case columnsGrid[i] of
      'QSL': DBGrid1.Columns.Items[i].Title.Caption := 'QSL';
      'QSLs': DBGrid1.Columns.Items[i].Title.Caption := 'QSLs';
      'QSODate': DBGrid1.Columns.Items[i].Title.Caption := 'Дата';
      'QSOTime': DBGrid1.Columns.Items[i].Title.Caption := 'Время';
      'QSOBand': DBGrid1.Columns.Items[i].Title.Caption := 'Диапазон';
      'CallSign': DBGrid1.Columns.Items[i].Title.Caption := 'Позывной';
      'QSOMode': DBGrid1.Columns.Items[i].Title.Caption := 'Мода';
      'OMName': DBGrid1.Columns.Items[i].Title.Caption := 'Имя';
      'OMQTH': DBGrid1.Columns.Items[i].Title.Caption := 'QTH';
      'State': DBGrid1.Columns.Items[i].Title.Caption := 'State';
      'Grid': DBGrid1.Columns.Items[i].Title.Caption := 'Локатор';
      'QSOReportSent': DBGrid1.Columns.Items[i].Title.Caption := 'RSTs';
      'QSOReportRecived': DBGrid1.Columns.Items[i].Title.Caption := 'RSTr';
      'IOTA': DBGrid1.Columns.Items[i].Title.Caption := 'IOTA';
      'QSLManager': DBGrid1.Columns.Items[i].Title.Caption := 'Менеджер';
      'QSLSentDate': DBGrid1.Columns.Items[i].Title.Caption := 'QSLs Date';
      'QSLRecDate': DBGrid1.Columns.Items[i].Title.Caption := 'QSLr Date';
      'LoTWRecDate': DBGrid1.Columns.Items[i].Title.Caption := 'LOTWr Date';
      'MainPrefix': DBGrid1.Columns.Items[i].Title.Caption := 'Префикс';
      'DXCCPrefix': DBGrid1.Columns.Items[i].Title.Caption := 'DXCC';
      'CQZone': DBGrid1.Columns.Items[i].Title.Caption := 'CQ Zone';
      'ITUZone': DBGrid1.Columns.Items[i].Title.Caption := 'ITU Zone';
      'ManualSet': DBGrid1.Columns.Items[i].Title.Caption := 'Manual Set';
      'Continent': DBGrid1.Columns.Items[i].Title.Caption := 'Континент';
      'ValidDX': DBGrid1.Columns.Items[i].Title.Caption := 'Valid DX';
      'QSL_RCVD_VIA': DBGrid1.Columns.Items[i].Title.Caption := 'QSL r VIA';
      'QSL_SENT_VIA': DBGrid1.Columns.Items[i].Title.Caption := 'QSL s VIA';
      'USERS': DBGrid1.Columns.Items[i].Title.Caption := 'User';
      'NoCalcDXCC': DBGrid1.Columns.Items[i].Title.Caption := 'No Calc DXCC';
    end;

    case columnsGrid[i] of
      'QSL': DBGrid1.Columns.Items[i].Visible := columnsVisible[0];
      'QSLs': DBGrid1.Columns.Items[i].Visible := columnsVisible[1];
      'QSODate': DBGrid1.Columns.Items[i].Visible := columnsVisible[2];
      'QSOTime': DBGrid1.Columns.Items[i].Visible := columnsVisible[3];
      'QSOBand': DBGrid1.Columns.Items[i].Visible := columnsVisible[4];
      'CallSign': DBGrid1.Columns.Items[i].Visible := columnsVisible[5];
      'QSOMode': DBGrid1.Columns.Items[i].Visible := columnsVisible[6];
      'OMName': DBGrid1.Columns.Items[i].Visible := columnsVisible[7];
      'OMQTH': DBGrid1.Columns.Items[i].Visible := columnsVisible[8];
      'State': DBGrid1.Columns.Items[i].Visible := columnsVisible[9];
      'Grid': DBGrid1.Columns.Items[i].Visible := columnsVisible[10];
      'QSOReportSent': DBGrid1.Columns.Items[i].Visible := columnsVisible[11];
      'QSOReportRecived': DBGrid1.Columns.Items[i].Visible := columnsVisible[12];
      'IOTA': DBGrid1.Columns.Items[i].Visible := columnsVisible[13];
      'QSLManager': DBGrid1.Columns.Items[i].Visible := columnsVisible[14];
      'QSLSentDate': DBGrid1.Columns.Items[i].Visible := columnsVisible[15];
      'QSLRecDate': DBGrid1.Columns.Items[i].Visible := columnsVisible[16];
      'LoTWRecDate': DBGrid1.Columns.Items[i].Visible := columnsVisible[17];
      'MainPrefix': DBGrid1.Columns.Items[i].Visible := columnsVisible[18];
      'DXCCPrefix': DBGrid1.Columns.Items[i].Visible := columnsVisible[19];
      'CQZone': DBGrid1.Columns.Items[i].Visible := columnsVisible[20];
      'ITUZone': DBGrid1.Columns.Items[i].Visible := columnsVisible[21];
      'ManualSet': DBGrid1.Columns.Items[i].Visible := columnsVisible[22];
      'Continent': DBGrid1.Columns.Items[i].Visible := columnsVisible[23];
      'ValidDX': DBGrid1.Columns.Items[i].Visible := columnsVisible[24];
      'QSL_RCVD_VIA': DBGrid1.Columns.Items[i].Visible := columnsVisible[25];
      'QSL_SENT_VIA': DBGrid1.Columns.Items[i].Visible := columnsVisible[26];
      'USERS': DBGrid1.Columns.Items[i].Visible := columnsVisible[27];
      'NoCalcDXCC': DBGrid1.Columns.Items[i].Visible := columnsVisible[28];
    end;
  end;
  //Для второго грида
  for i := 0 to 28 do
  begin
    DBGrid2.Columns.Items[i].FieldName := columnsGrid[i];
    DBGrid2.Columns.Items[i].Width := columnsWidth[i];
    case columnsGrid[i] of
      'QSL': DBGrid2.Columns.Items[i].Title.Caption := 'QSL';
      'QSLs': DBGrid2.Columns.Items[i].Title.Caption := 'QSLs';
      'QSODate': DBGrid2.Columns.Items[i].Title.Caption := 'Дата';
      'QSOTime': DBGrid2.Columns.Items[i].Title.Caption := 'Время';
      'QSOBand': DBGrid2.Columns.Items[i].Title.Caption := 'Диапазон';
      'CallSign': DBGrid2.Columns.Items[i].Title.Caption := 'Позывной';
      'QSOMode': DBGrid2.Columns.Items[i].Title.Caption := 'Мода';
      'OMName': DBGrid2.Columns.Items[i].Title.Caption := 'Имя';
      'OMQTH': DBGrid2.Columns.Items[i].Title.Caption := 'QTH';
      'State': DBGrid2.Columns.Items[i].Title.Caption := 'State';
      'Grid': DBGrid2.Columns.Items[i].Title.Caption := 'Локатор';
      'QSOReportSent': DBGrid2.Columns.Items[i].Title.Caption := 'RSTs';
      'QSOReportRecived': DBGrid2.Columns.Items[i].Title.Caption := 'RSTr';
      'IOTA': DBGrid2.Columns.Items[i].Title.Caption := 'IOTA';
      'QSLManager': DBGrid2.Columns.Items[i].Title.Caption := 'Менеджер';
      'QSLSentDate': DBGrid2.Columns.Items[i].Title.Caption := 'QSLs Date';
      'QSLRecDate': DBGrid2.Columns.Items[i].Title.Caption := 'QSLr Date';
      'LoTWRecDate': DBGrid2.Columns.Items[i].Title.Caption := 'LOTWr Date';
      'MainPrefix': DBGrid2.Columns.Items[i].Title.Caption := 'Префикс';
      'DXCCPrefix': DBGrid2.Columns.Items[i].Title.Caption := 'DXCC';
      'CQZone': DBGrid2.Columns.Items[i].Title.Caption := 'CQ Zone';
      'ITUZone': DBGrid2.Columns.Items[i].Title.Caption := 'ITU Zone';
      'ManualSet': DBGrid2.Columns.Items[i].Title.Caption := 'Manual Set';
      'Continent': DBGrid2.Columns.Items[i].Title.Caption := 'Континент';
      'ValidDX': DBGrid2.Columns.Items[i].Title.Caption := 'Valid DX';
      'QSL_RCVD_VIA': DBGrid2.Columns.Items[i].Title.Caption := 'QSL r VIA';
      'QSL_SENT_VIA': DBGrid2.Columns.Items[i].Title.Caption := 'QSL s VIA';
      'USERS': DBGrid2.Columns.Items[i].Title.Caption := 'User';
      'NoCalcDXCC': DBGrid2.Columns.Items[i].Title.Caption := 'No Calc DXCC';
    end;

    case columnsGrid[i] of
      'QSL': DBGrid2.Columns.Items[i].Visible := columnsVisible[0];
      'QSLs': DBGrid2.Columns.Items[i].Visible := columnsVisible[1];
      'QSODate': DBGrid2.Columns.Items[i].Visible := columnsVisible[2];
      'QSOTime': DBGrid2.Columns.Items[i].Visible := columnsVisible[3];
      'QSOBand': DBGrid2.Columns.Items[i].Visible := columnsVisible[4];
      'CallSign': DBGrid2.Columns.Items[i].Visible := columnsVisible[5];
      'QSOMode': DBGrid2.Columns.Items[i].Visible := columnsVisible[6];
      'OMName': DBGrid2.Columns.Items[i].Visible := columnsVisible[7];
      'OMQTH': DBGrid2.Columns.Items[i].Visible := columnsVisible[8];
      'State': DBGrid2.Columns.Items[i].Visible := columnsVisible[9];
      'Grid': DBGrid2.Columns.Items[i].Visible := columnsVisible[10];
      'QSOReportSent': DBGrid2.Columns.Items[i].Visible := columnsVisible[11];
      'QSOReportRecived': DBGrid2.Columns.Items[i].Visible := columnsVisible[12];
      'IOTA': DBGrid2.Columns.Items[i].Visible := columnsVisible[13];
      'QSLManager': DBGrid2.Columns.Items[i].Visible := columnsVisible[14];
      'QSLSentDate': DBGrid2.Columns.Items[i].Visible := columnsVisible[15];
      'QSLRecDate': DBGrid2.Columns.Items[i].Visible := columnsVisible[16];
      'LoTWRecDate': DBGrid2.Columns.Items[i].Visible := columnsVisible[17];
      'MainPrefix': DBGrid2.Columns.Items[i].Visible := columnsVisible[18];
      'DXCCPrefix': DBGrid2.Columns.Items[i].Visible := columnsVisible[19];
      'CQZone': DBGrid2.Columns.Items[i].Visible := columnsVisible[20];
      'ITUZone': DBGrid2.Columns.Items[i].Visible := columnsVisible[21];
      'ManualSet': DBGrid2.Columns.Items[i].Visible := columnsVisible[22];
      'Continent': DBGrid2.Columns.Items[i].Visible := columnsVisible[23];
      'ValidDX': DBGrid2.Columns.Items[i].Visible := columnsVisible[24];
      'QSL_RCVD_VIA': DBGrid2.Columns.Items[i].Visible := columnsVisible[25];
      'QSL_SENT_VIA': DBGrid2.Columns.Items[i].Visible := columnsVisible[26];
      'USERS': DBGrid2.Columns.Items[i].Visible := columnsVisible[27];
      'NoCalcDXCC': DBGrid2.Columns.Items[i].Visible := columnsVisible[28];
    end;
  end;

  case SizeTextGrid of
    8: DBGrid1.DefaultRowHeight := 15;
    10: DBGrid1.DefaultRowHeight := DBGrid1.Font.Size + 12;
    12: DBGrid1.DefaultRowHeight := DBGrid1.Font.Size + 12;
    14: DBGrid1.DefaultRowHeight := DBGrid1.Font.Size + 12;
  end;

  case SizeTextGrid of
    8: DBGrid2.DefaultRowHeight := 15;
    10: DBGrid2.DefaultRowHeight := DBGrid2.Font.Size + 12;
    12: DBGrid2.DefaultRowHeight := DBGrid2.Font.Size + 12;
    14: DBGrid2.DefaultRowHeight := DBGrid2.Font.Size + 12;
  end;
end;

procedure TMainForm.SelectQSO;
begin
  try
    SearchCallLog(DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString, 0);
    SearchPrefix(DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString, True);
    Label17.Caption := IntToStr(DBGrid2.DataSource.DataSet.RecordCount);
    Label18.Caption := DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsString;
    Label19.Caption := DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsString;
    Label20.Caption := DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
    Label21.Caption := DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;
    Label22.Caption := DBGrid1.DataSource.DataSet.FieldByName('OMName').AsString;
    UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
    StatusBar1.Panels.Items[1].Text :=
      'QSO № ' + IntToStr(DBGrid1.DataSource.DataSet.RecNo) +
      ' из ' + IntToStr(MainForm.LOGBookQuery.RecordCount);
  except
    on E: Exception do
    begin
      if Pos('has gone away', E.Message) > 0 then
      begin
        ShowMessage(
          'НЕТ подключения к базе данных MySQL! Проверьте подключение или параметры соединения. Соединяемся с базой SQLite');
        UseCallBook := 'NO';
        DefaultDB := 'SQLite';
        InitializeDB('SQLite');
        dbSel := 'SQLite';
      end;
    end;
  end;
end;

procedure TMainForm.InitializeDB(dbS: string);
var
  i: integer;
  sDBPath: string;
begin
     {$IFDEF UNIX}
  sDBPath := GetEnvironmentVariable('HOME') + '/EWLog/';
    {$ELSE}
  sDBPath := GetEnvironmentVariable('SystemDrive') +
    GetEnvironmentVariable('HOMEPATH') + '\EWLog\';
    {$ENDIF UNIX}
  if (FileExists(sDBPath + 'callbook.db')) and (UseCallBook = 'YES') then
  begin
    CallBookLiteConnection.DatabaseName := sDBPath + 'callbook.db';
    CallBookLiteConnection.Connected := True;
  end;

  if not (FileExists(sDBPath + 'callbook.db')) and (UseCallBook = 'YES') then
  begin
    ShowMessage(
      'Не найден файл справочника, продолжу работать без его. Зайдите в настройки программы для загрузки');
    CallBookLiteConnection.Connected := False;
    UseCallBook := 'NO';
  end;

  MySQLLOGDBConnection.Connected := False;
  SQLiteDBConnection.Connected := False;
  ServiceDBConnection.DatabaseName := sDBPath + 'serviceLOG.db';
  ServiceDBConnection.Connected := True;

  if dbS = 'MySQL' then
  begin
    DefaultDB := 'MySQL';
    dbSel := 'MySQL';
    MenuItem83.Enabled := False;
    MenuItem82.Enabled := True;
    try
      SQLTransaction1.DataBase := MySQLLOGDBConnection;
      MySQLLOGDBConnection.Transaction := SQLTransaction1;
      MySQLLOGDBConnection.HostName := HostDB;
      MySQLLOGDBConnection.Port := StrToInt(PortDB);
      MySQLLOGDBConnection.UserName := LoginBD;
      MySQLLOGDBConnection.Password := PasswdDB;
      MySQLLOGDBConnection.DatabaseName := NameDB;
      MySQLLOGDBConnection.Connected := True;
      DeleteQSOQuery.DataBase := MySQLLOGDBConnection;
      LogBookFieldQuery.DataBase := MySQLLOGDBConnection;
      LOGBookQuery.DataBase := MySQLLOGDBConnection;
      SaveQSOQuery.DataBase := MySQLLOGDBConnection;
      DeleteQSOQuery.DataBase := MySQLLOGDBConnection;
      LogBookInfoQuery.DataBase := MySQLLOGDBConnection;
      SQLQuery2.DataBase := MySQLLOGDBConnection;
      {$IFDEF WINDOWS}
      TrayIcon1.BalloonHint :=
        'Выбрана БД MySQL! Добро пожаловать!';
      TrayIcon1.ShowBalloonHint;
      {$ELSE}
      SysUtils.ExecuteProcess('/usr/bin/notify-send',
        ['EWLog', 'Выбрана БД MySQL! Добро пожаловать!']);
      {$ENDIF}
    except
      ShowMessage('Проверьте настройки БД MySQL');
      InitializeDB('SQLite');
    end;
  end
  else
  begin
    DefaultDB := 'SQLite';
    dbSel := 'SQLite';
    MenuItem82.Enabled := False;
    MenuItem83.Enabled := True;
    try
      SQLiteDBConnection.DatabaseName := SQLiteFILE;
      SQLTransaction1.DataBase := SQLiteDBConnection;
      SQLiteDBConnection.Transaction := SQLTransaction1;
      DeleteQSOQuery.DataBase := SQLiteDBConnection;
      LogBookFieldQuery.DataBase := SQLiteDBConnection;
      LOGBookQuery.DataBase := SQLiteDBConnection;
      SaveQSOQuery.DataBase := SQLiteDBConnection;
      DeleteQSOQuery.DataBase := SQLiteDBConnection;
      LogBookInfoQuery.DataBase := SQLiteDBConnection;
      SQLQuery2.DataBase := SQLiteDBConnection;
      {$IFDEF WINDOWS}
      TrayIcon1.BalloonHint :=
        'Выбрана БД SQLite! Добро пожаловать!';
      TrayIcon1.ShowBalloonHint;
      {$ELSE}
      SysUtils.ExecuteProcess('/usr/bin/notify-send',
        ['EWLog', 'Выбрана БД SQLite! Добро пожаловать!']);
      {$ENDIF}
    except
      ShowMessage('Проверьте настройки БД SQLite');
      InitializeDB('MySQL');
    end;
  end;

  VHFTypeQuery.DataBase := ServiceDBConnection;
  PrefixProvinceQuery.DataBase := ServiceDBConnection;
  PrefixQuery.DataBase := ServiceDBConnection;
  PrefixARRLQuery.DataBase := ServiceDBConnection;

  try
    LogBookInfoQuery.Active := True;
    LogBookFieldQuery.Active := True;
    PrefixProvinceQuery.Active := True;
    PrefixARRLQuery.Active := True;

    DBLookupComboBox1.KeyValue := CallLogBook;
    SelDB(CallLogBook);

    PrefixProvinceList := TStringList.Create;
    PrefixARRLList := TStringList.Create;
    PrefixProvinceCount := PrefixProvinceQuery.RecordCount;
    PrefixARRLCount := PrefixARRLQuery.RecordCount;
    DBGrid1.DataSource.DataSet.Last;
    PrefixProvinceQuery.First;
    PrefixARRLQuery.First;
    for i := 0 to PrefixProvinceCount do
    begin
      PrefixProvinceList.Add(PrefixProvinceQuery.FieldByName('PrefixList').AsString);
      PrefixProvinceQuery.Next;
    end;
    for i := 0 to PrefixARRLCount do
    begin
      PrefixARRLList.Add(PrefixARRLQuery.FieldByName('PrefixList').AsString);
      PrefixARRLQuery.Next;
    end;
  except
    ShowMessage('Что то пошло не так... Проверьте настройки');
    SetupForm.Show;
  end;
end;

procedure TMainForm.SearchCallLog(callNameS: string; ind: integer);
begin
  SQLQuery2.Close;
  SQLQuery2.SQL.Clear;

  if DefaultDB = 'MySQL' then
    SQLQuery2.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,' +
      '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
      + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE CallSign = "' +
      callNameS + '"')
  else
    SQLQuery2.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,' +
      '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) as `QSL`, (`QSLSent`||'
      + '`LoTWSent`) as `QSLs` FROM ' + LogTable + ' WHERE CallSign = "' +
      callNameS + '"');
  Application.ProcessMessages;
  SQLQuery2.Open;

  if (callNameS = SQLQuery2.FieldByName('CallSign').AsString) and
    (ind = 1) and (EditButton1.Text <> '') then
    EditButton1.Color := clMoneyGreen
  else
    EditButton1.Color := clDefault;

  //Поиск и заполнение из внутриней базы
  if (EditButton1.Text <> '') and (EditButton1.Text =
    SQLQuery2.FieldByName('CallSign').AsString) then
  begin
    if UseCallBook <> 'YES' then begin
     Edit1.Text := SQLQuery2.FieldByName('OMName').AsString;
      Edit2.Text := SQLQuery2.FieldByName('OMQTH').AsString;
      Edit3.Text := SQLQuery2.FieldByName('Grid').AsString;
      Edit4.Text := SQLQuery2.FieldByName('State').AsString;
      Edit5.Text := SQLQuery2.FieldByName('IOTA').AsString;
      Edit6.Text := SQLQuery2.FieldByName('QSLManager').AsString;
    end else begin
     if SQLQuery2.FieldByName('OMName').AsString <> '' then
     Edit1.Text := SQLQuery2.FieldByName('OMName').AsString;
     if SQLQuery2.FieldByName('OMQTH').AsString <> '' then
     Edit2.Text := SQLQuery2.FieldByName('OMQTH').AsString;
     if SQLQuery2.FieldByName('Grid').AsString <> '' then
     Edit3.Text := SQLQuery2.FieldByName('Grid').AsString;
     if SQLQuery2.FieldByName('State').AsString <> '' then
     Edit4.Text := SQLQuery2.FieldByName('State').AsString;
     if SQLQuery2.FieldByName('IOTA').AsString <> '' then
     Edit5.Text := SQLQuery2.FieldByName('IOTA').AsString;
     if SQLQuery2.FieldByName('QSLManager').AsString <> '' then
     Edit6.Text := SQLQuery2.FieldByName('QSLManager').AsString;
    end;
  end;
end;

procedure TMainForm.DoBeforeDownload(Url: string; str: TStream; var CanHandle: boolean);
var
  x: string;
  f: TFileStream;
  doc: string;
begin
{$IFDEF UNIX}
  doc := GetEnvironmentVariable('HOME');
  x := doc + '/EWLog/cache/' + MDPrint(MD5String(Url));
  {$ELSE}
  doc := GetEnvironmentVariable('SystemDrive') + GetEnvironmentVariable('HOMEPATH');
  x := doc + '\EWLog\cache\' + MDPrint(MD5String(Url));
  {$ENDIF UNIX}

  if FileExists(x) then
  begin
    f := TFileStream.Create(x, fmOpenRead);
    try
      str.Position := 0;
      str.CopyFrom(f, f.Size);
      str.Position := 0;
      CanHandle := True;
    finally
      f.Free;
    end;
  end
  else
    CanHandle := False;
end;

procedure TMainForm.DoAfterDownload(Url: string; str: TStream);
var
  x: string;
  f: TFileStream;
  doc: string;
begin
  {$IFDEF UNIX}
  doc := GetEnvironmentVariable('HOME');
  if not DirectoryExists(doc + '/EWLog/cache/') then
    ForceDirectories(doc + '/EWLog/cache\');
  x := doc + '/EWLog/cache/' + MDPrint(MD5String(Url));
  {$ELSE}
  doc := GetEnvironmentVariable('SystemDrive') + GetEnvironmentVariable('HOMEPATH');
  if not DirectoryExists(doc + '\EWLog\cache\') then
    ForceDirectories(doc + '\EWLog\cache\');
  x := doc + '\EWLog\cache\' + MDPrint(MD5String(Url));
  {$ENDIF UNIX}
  if (not FileExists(x)) and (not (str.Size = 0)) then
  begin
    f := TFileStream.Create(x, fmCreate);
    try
      str.Position := 0;
      f.CopyFrom(str, str.Size);
    finally
      f.Free;
    end;
  end;
end;

procedure TMainForm.Clr();
begin
  MainForm.EditButton1.Clear;
  MainForm.EditButton1.Color := clDefault;
  MainForm.Edit1.Clear;
  MainForm.Edit2.Clear;
  MainForm.Edit3.Clear;
  MainForm.Edit4.Clear;
  MainForm.Edit5.Clear;
  MainForm.Edit6.Clear;
  MainForm.Edit10.Clear;
  MainForm.Edit9.Clear;
  MainForm.Edit8.Clear;
  MainForm.Edit11.Clear;
  MainForm.Edit13.Clear;
  MainForm.ComboBox4.ItemIndex := 0;
  MainForm.ComboBox5.ItemIndex := 0;
  EditFlag := False;
  //CheckBox1.Checked := True;
  ComboBox6.Text := '';
end;

procedure TMainForm.SaveQSO(CallSing: string; QSODate: TDateTime;
  QSOTime, QSOBand, QSOMode, QSOReportSent, QSOReportRecived, OmName,
  OmQTH, State0, Grid, IOTA, QSLManager, QSLSent, QSLSentAdv,
  QSLSentDate, QSLRec, QSLRecDate, MainPrefix, DXCCPrefix, CQZone,
  ITUZone, QSOAddInfo, Marker: string; ManualSet: integer;
  DigiBand, Continent, ShortNote: string; QSLReceQSLcc: integer;
  LotWRec, LotWRecDate, QSLInfo, Call, State1, State2, State3, State4,
  WPX, AwardsEx, ValidDX: string; SRX: integer; SRX_String: string;
  STX: integer; STX_String, SAT_NAME, SAT_MODE, PROP_MODE: string;
  LotWSent: integer; QSL_RCVD_VIA, QSL_SENT_VIA, DXCC, USERS: string;
  NoCalcDXCC: integer; NLogDB: string);//, Index: string);
begin
  with MainForm.SaveQSOQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('INSERT INTO ' + NLogDB +
      //'(`UnUsedIndex`, `CallSign`, `QSODate`, `QSOTime`, `QSOBand`, `QSOMode`, ' +
      '(`CallSign`, `QSODate`, `QSOTime`, `QSOBand`, `QSOMode`, ' +
      '`QSOReportSent`, `QSOReportRecived`, `OMName`, `OMQTH`, `State`, `Grid`, `IOTA`,'
      +
      '`QSLManager`, `QSLSent`, `QSLSentAdv`, `QSLSentDate`, `QSLRec`, `QSLRecDate`,' +
      '`MainPrefix`, `DXCCPrefix`, `CQZone`, `ITUZone`, `QSOAddInfo`, `Marker`, `ManualSet`,'
      + '`DigiBand`, `Continent`, `ShortNote`, `QSLReceQSLcc`, `LoTWRec`, `LoTWRecDate`,'
      + '`QSLInfo`, `Call`, `State1`, `State2`, `State3`, `State4`, `WPX`, `AwardsEx`, '
      + '`ValidDX`, `SRX`, `SRX_STRING`, `STX`, `STX_STRING`, `SAT_NAME`, `SAT_MODE`,'
      + '`PROP_MODE`, `LoTWSent`, `QSL_RCVD_VIA`, `QSL_SENT_VIA`, `DXCC`, `USERS`, `NoCalcDXCC`)'
      //+ 'VALUES (:IUnUsedIndex, :ICallSign, :IQSODate, :IQSOTime, :IQSOBand, :IQSOMode, :IQSOReportSent,'
      + 'VALUES (:ICallSign, :IQSODate, :IQSOTime, :IQSOBand, :IQSOMode, :IQSOReportSent,'
      + ':IQSOReportRecived, :IOMName, :IOMQTH, :IState, :IGrid, :IIOTA, :IQSLManager, :IQSLSent,'
      + ':IQSLSentAdv, :IQSLSentDate, :IQSLRec, :IQSLRecDate, :IMainPrefix, :IDXCCPrefix, :ICQZone,'
      + ':IITUZone, :IQSOAddInfo, :IMarker, :IManualSet, :IDigiBand, :IContinent, :IShortNote,'
      + ':IQSLReceQSLcc, :ILoTWRec, :ILoTWRecDate, :IQSLInfo, :ICall, :IState1, :IState2, :IState3, :IState4,'
      + ':IWPX, :IAwardsEx, :IValidDX, :ISRX, :ISRX_STRING, :ISTX, :ISTX_STRING, :ISAT_NAME,'
      + ':ISAT_MODE, :IPROP_MODE, :ILoTWSent, :IQSL_RCVD_VIA, :IQSL_SENT_VIA, :IDXCC, :IUSERS, :INoCalcDXCC)');

    //Params.ParamByName('IUnUsedIndex').AsInteger := StrToInt(Index);
    Params.ParamByName('ICallSign').AsString := CallSing;
    Params.ParamByName('IQSODate').AsDateTime := QSODate;
    Params.ParamByName('IQSOTime').AsString := QSOTime;
    Params.ParamByName('IQSOBand').AsString := QSOBand;
    Params.ParamByName('IQSOMode').AsString := QSOMode;
    Params.ParamByName('IQSOReportSent').AsString := QSOReportSent;
    Params.ParamByName('IQSOReportRecived').AsString := QSOReportRecived;
    Params.ParamByName('IOMName').AsString := OmName;
    Params.ParamByName('IOMQTH').AsString := OmQTH;
    Params.ParamByName('IState').AsString := State0;
    Params.ParamByName('IGrid').AsString := Grid;
    Params.ParamByName('IIOTA').AsString := IOTA;
    Params.ParamByName('IQSLManager').AsString := QSLManager;
    Params.ParamByName('IQSLSent').AsString := QSLSent;
    Params.ParamByName('IQSLSentAdv').AsString := QSLSentAdv;
    if QSLSentDate = 'NULL' then
      Params.ParamByName('IQSLSentDate').IsNull
    else
      Params.ParamByName('IQSLSentDate').AsString := QSLSentDate;
    Params.ParamByName('IQSLRec').AsString := QSLRec;
    if QSLRecDate = 'NULL' then
      Params.ParamByName('IQSLRecDate').IsNull
    else
      Params.ParamByName('IQSLRecDate').AsString := QSLRecDate;
    Params.ParamByName('IMainPrefix').AsString := MainPrefix;
    Params.ParamByName('IDXCCPrefix').AsString := DXCCPrefix;
    Params.ParamByName('ICQZone').AsString := CQZone;
    Params.ParamByName('IITUZone').AsString := ITUZone;
    Params.ParamByName('IQSOAddInfo').AsString := QSOAddInfo;
    Params.ParamByName('IMarker').AsString := Marker;
    Params.ParamByName('IManualSet').AsInteger := ManualSet;
    Params.ParamByName('IDigiBand').AsString := DigiBand;
    Params.ParamByName('IContinent').AsString := Continent;
    Params.ParamByName('IShortNote').AsString := ShortNote;
    Params.ParamByName('IQSLReceQSLcc').AsInteger := QSLReceQSLcc;
    if LotWRec = '' then
      Params.ParamByName('ILoTWRec').AsInteger := 0
    else
      Params.ParamByName('ILoTWRec').AsInteger := 1;
    if LotWRecDate = 'NULL' then
      Params.ParamByName('ILoTWRecDate').IsNull
    else
      Params.ParamByName('ILoTWRecDate').AsString := LotWRecDate;
    Params.ParamByName('IQSLInfo').AsString := QSLInfo;
    Params.ParamByName('ICall').AsString := Call;
    Params.ParamByName('IState1').AsString := State1;
    Params.ParamByName('IState2').AsString := State2;
    Params.ParamByName('IState3').AsString := State3;
    Params.ParamByName('IState4').AsString := State4;
    Params.ParamByName('IWPX').AsString := WPX;
    Params.ParamByName('IAwardsEx').AsString := AwardsEx;
    Params.ParamByName('IValidDX').AsString := ValidDX;
    Params.ParamByName('ISRX').AsInteger := SRX;
    Params.ParamByName('ISRX_STRING').AsString := SRX_String;
    Params.ParamByName('ISTX').AsInteger := STX;
    Params.ParamByName('ISTX_STRING').AsString := STX_String;
    Params.ParamByName('ISAT_NAME').AsString := SAT_NAME;
    Params.ParamByName('ISAT_MODE').AsString := SAT_MODE;
    Params.ParamByName('IPROP_MODE').AsString := PROP_MODE;
    Params.ParamByName('ILoTWSent').AsInteger := LotWSent;
    if QSL_RCVD_VIA = '' then
      Params.ParamByName('IQSL_RCVD_VIA').IsNull
    else
      Params.ParamByName('IQSL_RCVD_VIA').AsString := QSL_RCVD_VIA;
    if QSL_SENT_VIA = '' then
      Params.ParamByName('IQSL_SENT_VIA').IsNull
    else
      Params.ParamByName('IQSL_SENT_VIA').AsString := QSL_SENT_VIA;
    Params.ParamByName('IDXCC').AsString := DXCC;
    Params.ParamByName('IUSERS').AsString := USERS;
    Params.ParamByName('INoCalcDXCC').AsInteger := NoCalcDXCC;
    ExecSQL;
  end;
  MainForm.SQLTransaction1.Commit;
end;

procedure TMainForm.SearchCallInCallBook(CallName: string);
begin
  try
    Application.ProcessMessages;
    if (CallBookLiteConnection.Connected = True) or
      (SearchCallBookQuery.Active = True) then
    begin
      with SearchCallBookQuery do
      begin
        Close;
        SQL.Clear;
        SQL.Add('SELECT * FROM Callbook WHERE `Call` = "' + CallName + '"');
        Application.ProcessMessages;
        Open;
      end;

      Edit1.Text := SearchCallBookQuery.FieldByName('Name').AsString;
      Edit2.Text := SearchCallBookQuery.FieldByName('QTH').AsString;
      Edit3.Text := SearchCallBookQuery.FieldByName('Grid').AsString;
      Edit6.Text := SearchCallBookQuery.FieldByName('Manager').AsString;
      Edit11.Text := SearchCallBookQuery.FieldByName('Note').AsString;
    end;
  except
    CallBookLiteConnection.Connected := True;
  end;
end;

procedure TMainForm.SelectLogDatabase(LogDB: string);
begin
  LogBookQuery.Close;
  LogBookQuery.SQL.Clear;

  if DefaultDB = 'MySQL' then
  begin
    LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,' +
      '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
      // + '`LoTWSent`) AS QSLs FROM ' + LogDB + ' WHERE 1 ORDER BY `UnUsedIndex`');
      + '`LoTWSent`) AS QSLs FROM ' + LogDB +
      ' ORDER BY YEAR(QSODate), MONTH(QSODate), DAY(QSODate), QSOTime ASC');
  end
  else
  begin
    LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,' +
      '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
      //+ '`LoTWSent`) AS QSLs FROM ' + LogDB + ' WHERE 1 ORDER BY `UnUsedIndex`');
      + '`LoTWSent`) AS QSLs FROM ' + LogDB +
      ' ORDER BY date(QSODate), time(QSOTime) ASC');
  end;

  LogBookQuery.Open;
  LOGBookQuery.Last;
  lastID := MainForm.DBGrid1.DataSource.DataSet.RecNo;
  StatusBar1.Panels.Items[1].Text :=
    'QSO № ' + IntToStr(lastID) + ' из ' +
    IntToStr(MainForm.LOGBookQuery.RecordCount);
end;

procedure TMainForm.SelDB(calllbook: string);
begin
  with MainForm.LogBookInfoQuery do
  begin
    Close;
    SQL.Clear;
    if calllbook = '' then
      SQL.Add('SELECT * FROM LogBookInfo LIMIT 1')
    else
      SQL.Add('select * from LogBookInfo where CallName = "' + calllbook + '"');
    Open;

    SetDiscription := MainForm.LogBookInfoQuery.FieldByName('Discription').AsString;
    SetCallName := MainForm.LogBookInfoQuery.FieldByName('CallName').AsString;
    SetNameC := MainForm.LogBookInfoQuery.FieldByName('Name').AsString;
    SetQTH := MainForm.LogBookInfoQuery.FieldByName('QTH').AsString;
    SetITU := MainForm.LogBookInfoQuery.FieldByName('ITU').AsString;
    SetLoc := MainForm.LogBookInfoQuery.FieldByName('Loc').AsString;
    SetCQ := MainForm.LogBookInfoQuery.FieldByName('CQ').AsString;
    SetLat := MainForm.LogBookInfoQuery.FieldByName('Lat').AsString;
    SetLon := MainForm.LogBookInfoQuery.FieldByName('Lon').AsString;
    SetQSLInfo := MainForm.LogBookInfoQuery.FieldByName('QSLInfo').AsString;
    LogTable := MainForm.LogBookInfoQuery.FieldByName('LogTable').AsString;
    eQSLccLogin := MainForm.LogBookInfoQuery.FieldByName('EQSLLogin').AsString;
    eQSLccPassword := MainForm.LogBookInfoQuery.FieldByName('EQSLPassword').AsString;
    AutoEQSLcc := MainForm.LogBookInfoQuery.FieldByName('AutoEQSLcc').AsBoolean;
    HRDLogin := MainForm.LogBookInfoQuery.FieldByName('HRDLogLogin').AsString;
    HRDCode := MainForm.LogBookInfoQuery.FieldByName('HRDLogPassword').AsString;
    AutoHRDLog := MainForm.LogBookInfoQuery.FieldByName('AutoHRDLog').AsBoolean;
    MainForm.SelectLogDatabase(LogTable);
    MainForm.DBGrid1.DataSource.DataSet.Last;
  end;
  SetGrid();
       LogBookFieldQuery.Open;
     DBLookupComboBox1.KeyValue:=calllbook;
end;

procedure TMainForm.SearchPrefix(CallName: string; gridloc: boolean);
var
  i, j: integer;
  BoolPrefix: boolean;
  R: extended;
  la, lo: currency;
  azim, azim2, qra, myloc, loc: string;
begin
  PrefixExp := TRegExpr.Create;
  BoolPrefix := False;
  // loc:='';

  with MainForm.SQLQuery2 do
  begin
    Close;
    SQL.Clear;
    if DefaultDB = 'MySQL' then
      SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
        ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
        + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
        + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
        + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
        + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
        + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
        + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
        + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
        + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE CallSign = "' +
        CallName + '"')
    else
      SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
        ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
        + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
        + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
        + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
        + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
        + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
        + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
        + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) as `QSL`, (`QSLSent`||'
        + '`LoTWSent`) as `QSLs` FROM ' + LogTable + ' WHERE CallSign = "' +
        CallName + '"');
    Open;
  end;


  for i := 0 to PrefixProvinceCount do
  begin
    PrefixExp.Expression := PrefixProvinceList.Strings[i];
    if (PrefixExp.Exec(CallName)) and (PrefixExp.Match[0] = CallName) then
    begin
      BoolPrefix := True;
      with MainForm.PrefixQuery do
      begin
        Close;
        SQL.Clear;
        // SQL.Add('select * from Province where _id = "' + IntToStr(i + 1) + '"');
        SQL.Add('select * from Province where _id = "' + IntToStr(i) + '"');
        Open;
      end;
      MainForm.Label33.Caption := MainForm.PrefixQuery.FieldByName('Country').AsString;
      MainForm.Label34.Caption :=
        MainForm.PrefixQuery.FieldByName('ARRLPrefix').AsString;
      MainForm.Label38.Caption := MainForm.PrefixQuery.FieldByName('Prefix').AsString;
      MainForm.Label45.Caption := MainForm.PrefixQuery.FieldByName('CQZone').AsString;
      MainForm.Label47.Caption := MainForm.PrefixQuery.FieldByName('ITUZone').AsString;
      MainForm.Label43.Caption :=
        MainForm.PrefixQuery.FieldByName('Continent').AsString;
      MainForm.Label40.Caption := MainForm.PrefixQuery.FieldByName('Latitude').AsString;
      CallLAT := MainForm.PrefixQuery.FieldByName('Latitude').AsString;
      MainForm.Label42.Caption :=
        MainForm.PrefixQuery.FieldByName('Longitude').AsString;
      CallLON := MainForm.PrefixQuery.FieldByName('Longitude').AsString;
      DXCCNum := MainForm.PrefixQuery.FieldByName('DXCC').AsInteger;
      timedif := MainForm.PrefixQuery.FieldByName('TimeDiff').AsInteger;

      if gridloc = True then
        loc := MainForm.DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;

      la1 := CallLAT;
      lo1 := CallLON;

      if (UTF8Pos('W', lo1) <> 0) then
        lo1 := '-' + lo1;
      if (UTF8Pos('S', la1) <> 0) then
        la1 := '-' + la1;
      Delete(la1, length(la1), 1);
      Delete(lo1, length(lo1), 1);

      if gridloc = True then
      begin
        if MainForm.Edit3.Text <> '' then
          loc := MainForm.Edit3.Text;
      end
      else
        loc := MainForm.Edit3.Text;

      if (loc <> '') and dmFunc.IsLocOK(loc) then
      begin
        dmFunc.CoordinateFromLocator(loc, la, lo);

        la1 := CurrToStr(la);
        lo1 := CurrToStr(lo);

        if loc = SetLoc then
          R := dmFunc.Vincenty(QTH_LAT, QTH_LON, la, lo) / 10000000
        else
          R := dmFunc.Vincenty(QTH_LAT, QTH_LON, la, lo) / 1000;
      end
      else
      begin
        R := dmFunc.Vincenty(QTH_LAT, QTH_LON, StrToFloat(la1),
          StrToFloat(lo1)) / 1000;
      end;
      MainForm.Label37.Caption := FormatFloat('0.00', R) + ' КМ';
      ///////АЗИМУТ
      dmFunc.DistanceFromCoordinate(SetLoc, StrToFloat(la1),
        strtofloat(lo1), qra, azim);
      azim2 := IntToStr(StrToInt(azim) + 180);
      MainForm.Label32.Caption := azim;// +'/'+azim2;
    end;
  end;

  if BoolPrefix = False then
  begin
    for j := 0 to PrefixARRLCount do
    begin
      PrefixExp.Expression := PrefixARRLList.Strings[j];
      if (PrefixExp.Exec(CallName)) and (PrefixExp.Match[0] = CallName) then
      begin
        with MainForm.PrefixQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add('select * from CountryDataEx where _id = "' + IntToStr(j) + '"');
          Open;
          if (FieldByName('Status').AsString = 'Deleted')
          then
          begin
            PrefixExp.ExecNext;
            Exit;
          end;
        end;
        MainForm.Label33.Caption := MainForm.PrefixQuery.FieldByName('Country').AsString;
        MainForm.Label34.Caption :=
          MainForm.PrefixQuery.FieldByName('ARRLPrefix').AsString;
        MainForm.Label38.Caption :=
          MainForm.PrefixQuery.FieldByName('ARRLPrefix').AsString;
        MainForm.Label45.Caption := MainForm.PrefixQuery.FieldByName('CQZone').AsString;
        MainForm.Label47.Caption := MainForm.PrefixQuery.FieldByName('ITUZone').AsString;
        MainForm.Label43.Caption :=
          MainForm.PrefixQuery.FieldByName('Continent').AsString;
        MainForm.Label40.Caption :=
          MainForm.PrefixQuery.FieldByName('Latitude').AsString;
        CallLAT := MainForm.PrefixQuery.FieldByName('Latitude').AsString;
        MainForm.Label42.Caption :=
          MainForm.PrefixQuery.FieldByName('Longitude').AsString;

        CallLON := MainForm.PrefixQuery.FieldByName('Longitude').AsString;
        DXCCNum := MainForm.PrefixQuery.FieldByName('DXCC').AsInteger;
        timedif := MainForm.PrefixQuery.FieldByName('TimeDiff').AsInteger;
        loc := MainForm.DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;

        la1 := CallLAT;
        lo1 := CallLON;

        if (UTF8Pos('W', lo1) <> 0) then
          lo1 := '-' + lo1;
        if (UTF8Pos('S', la1) <> 0) then
          la1 := '-' + la1;
        Delete(la1, length(la1), 1);
        Delete(lo1, length(lo1), 1);

        if gridloc = True then
        begin
          if MainForm.Edit3.Text <> '' then
            loc := MainForm.Edit3.Text;
        end
        else
          loc := MainForm.Edit3.Text;

        if (loc <> '') and dmFunc.IsLocOK(loc) then
        begin
          dmFunc.CoordinateFromLocator(loc, la, lo);

          la1 := CurrToStr(la);
          lo1 := CurrToStr(lo);
          if loc = SetLoc then
            R := dmFunc.Vincenty(QTH_LAT, QTH_LON, la, lo) / 10000000
          else
            R := dmFunc.Vincenty(QTH_LAT, QTH_LON, la, lo) / 1000;
        end
        else
        begin
          R := dmFunc.Vincenty(QTH_LAT, QTH_LON, StrToFloat(la1),
            StrToFloat(lo1)) / 1000;
        end;

        MainForm.Label37.Caption := FormatFloat('0.00', R) + ' КМ';
        ////Азимут
        dmFunc.DistanceFromCoordinate(SetLoc, StrToFloat(la1),
          strtofloat(lo1), qra, azim);
        azim2 := IntToStr(StrToInt(azim) - 180);
        MainForm.Label32.Caption := azim;// +'/'+azim2;
      end;
    end;
  end;
  PrefixExp.Free;
end;

procedure TMainForm.EditButton1Change(Sender: TObject);
var
  Centre: TRealPoint;
  Lat, Long: real;
  Error: integer;
  CallSignE: string;
  engText : string;
begin
 // EditButton1.SelStart := UTF8Length(EditButton1.Text);
  engText := dmFunc.RusToEng(EditButton1.Text);
  if (engText <> EditButton1.Text) then begin
   EditButton1.Text:=engText;
  exit;
  end;

  if EditFlag = False then
  begin
    if EditButton1.Text <> '' then
    begin
      if (CallBookLiteConnection.Connected = True) and (IniF.ReadString('SetLog', 'Sprav', '') = 'False') then
        SearchCallInCallBook(dmFunc.ExtractCallsign(EditButton1.Text));
      if (CallBookLiteConnection.Connected = False) and (IniF.ReadString('SetLog', 'Sprav', '') = 'True') then         InformationForm.QRZRUsprav(EditButton1.Text);

      if CheckBox6.Checked = False then
      SearchCallLog(dmFunc.ExtractCallsign(EditButton1.Text), 1);
     SearchPrefix(dmFunc.ExtractCallsign(EditButton1.Text), False);
      if CheckBox3.Checked = True then
      begin
        val(lo1, Long, Error);
        if Error = 0 then
        begin
          Centre.X := Long;
          val(la1, Lat, Error);
          if Error = 0 then
          begin
            Application.ProcessMessages;
            Centre.Y := Lat;
            MapViewer1.BeginUpdate;
            MapViewer1.Zoom := 9;
            MapViewer1.CenterLongLat := Centre;
            MapViewer1.EndUpdate;
          end;
        end;
      end;
    end
    else
    begin
      clr();
      label32.Caption := '.......';
      label33.Caption := '.......';
      label34.Caption := '.......';
      label37.Caption := '.......';
      label38.Caption := '.......';
      label40.Caption := '.......';
      label43.Caption := '.......';
      label45.Caption := '..';
      label47.Caption := '..';
      label42.Caption := '.......';
      MapViewer1.Zoom := 1;
      MapViewer1.Center;
    end;

    if CheckBox6.Checked = True then
    begin
      LogBookQuery.Close;
      LogBookQuery.SQL.Clear;

      if DefaultDB = 'MySQL' then
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable +
          ' WHERE `CallSign` LIKE ' + QuotedStr(EditButton1.Text + '%') +
          ' ORDER BY `UnUsedIndex`' + '');
      end
      else
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable +
          ' WHERE `CallSign` LIKE ' + QuotedStr(EditButton1.Text + '%') +
          ' ORDER BY `UnUsedIndex`' + '');
      end;
      LogBookQuery.Open;
      LOGBookQuery.Last;
      lastID := MainForm.DBGrid1.DataSource.DataSet.RecNo;
      StatusBar1.Panels.Items[1].Text :=
        'QSO № ' + IntToStr(lastID) + ' из ' +
        IntToStr(MainForm.LOGBookQuery.RecordCount);
    end;
  end;

end;

procedure TMainForm.Fl_TimerTimer(Sender: TObject);
var
  stmp: string;
  currfreq: string;
  currmode: string;
  mode: string;
  curr_f: extended;
  lstrfreq: string;
  carr: integer;
begin

  if Fldigi_IsRunning then
  begin
    if Fl_Timer.Interval > 1000 then
    begin
      Fl_Timer.Interval := 1000;
      fldigiactive := usefldigi;
      if fldigiactive then
      begin
        fldigiversion := Fldigi_GetVersion;
        if not connected then
        begin

      {$IFDEF WINDOWS}
          TrayIcon1.BalloonHint := 'EWLog подключен к Fldigi';
          TrayIcon1.ShowBalloonHint;
      {$ELSE}
          SysUtils.ExecuteProcess('/usr/bin/notify-send',
            ['EWLog', 'подключен к Fldigi']);
      {$ENDIF}

          MenuItem43.Enabled := False;
          ComboBox2.Text := Fldigi_GetMode;
          ComboBox2Change(Sender);
        end;
      end;
    end;
  end
  else if Fl_Timer.Interval = 1000 then
  begin
    Fl_Timer.Interval := 10000;
    fldigiactive := False;
    if not connected then
    begin
      {$IFDEF WINDOWS}
      TrayIcon1.BalloonHint := 'EWLog не подключен к Fldigi';
      TrayIcon1.ShowBalloonHint;
      {$ELSE}
      SysUtils.ExecuteProcess('/usr/bin/notify-send',
        ['EWLog', 'не подключен к Fldigi']);
      {$ENDIF}
      ComboBox2.ItemIndex := 0;
      ComboBox2Change(Sender);
      MenuItem43.Enabled := True;
    end;
    Exit;
  end;
  if fldigiactive then
    // use Fldigi XML-RPC communication
  begin
    if not connected then
    begin
      stmp := Format('%.11d', [Trunc(Fldigi_GetFrequency)]);
      mode := Fldigi_GetMode;
      carr := Fldigi_GetCarrier;

      EditButton1.Text := Fldigi_GetCall_Log;
      if Fldigi_GetName_Log <> '' then
        Edit1.Text := Fldigi_GetName_Log;
      if Fldigi_GetQTH_Log <> '' then
        Edit2.Text := Fldigi_GetQTH_Log;

      if (Fldigi_GetRSTout_Log <> '') and (Fldigi_GetRSTout_Log <> ComboBox4.Text) then
        ComboBox4.Text := Fldigi_GetRSTout_Log
      else
        Fldigi_SetRSTs(ComboBox4.Text);

      if (Fldigi_GetRSTin_Log <> '') and (Fldigi_GetRSTin_Log <> ComboBox5.Text) then
        ComboBox5.Text := Fldigi_GetRSTin_Log
      else
        Fldigi_SetRSTr(ComboBox5.Text);

      if Fldigi_GetLocator_Log <> '' then
        Edit3.Text := Fldigi_GetLocator_Log;

      if mode <> currmode then
      begin
        mode := Fldigi_GetMode;
        if mode <> currmode then
        begin
          currmode := mode;
          mode := Fldigi_GetMode;
          Combobox2.Text := mode;
        end;
      end;

      if stmp <> currfreq then
      begin
        stmp := Format('%.11d', [Trunc(Fldigi_GetFrequency + carr)]);

        if stmp <> currfreq then
        begin
          currfreq := stmp;
          curr_f := dmFunc.StrToFreq(stmp);
          stmp := FormatFloat('0.000"."00', curr_f / 1000);
          ComboBox1.Text := stmp;
          lstrfreq := stmp;
        end;
      end;
    end;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i: integer;
begin
  if EditButton1.Text <> '' then
  begin
    if Application.MessageBox(
      PChar('QSO не сохранено, действительной выйти ?!'),
      'Внимание!', MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
    begin
      Application.Terminate;
    end
    else
      CloseAction := caNone;
  end;

  //Сохранение размещения колонок
  for i := 0 to 28 do
  begin
    IniF.WriteString('GridSettings', 'Columns' + IntToStr(i),
      DBGrid1.Columns.Items[i].FieldName);
  end;

  for i := 0 to 28 do
  begin
    if DBGrid1.Columns.Items[i].Width <> 0 then
      IniF.WriteInteger('GridSettings', 'ColWidth' + IntToStr(i),
        DBGrid1.Columns.Items[i].Width)
    else
      IniF.WriteInteger('GridSettings', 'ColWidth' + IntToStr(i), columnsWidth[i]);
  end;

  if MainForm.WindowState <> wsMaximized then
  begin
    IniF.WriteInteger('SetLog', 'Width', MainForm.Width);
    IniF.WriteInteger('SetLog', 'Height', MainForm.Height);
    IniF.WriteString('SetLog', 'FormState', 'Normal');
  end;

  if MainForm.WindowState = wsMaximized then
    IniF.WriteString('SetLog', 'FormState', 'Maximized');

  IniF.WriteString('TelnetCluster', 'ServerDef', ComboBox3.Text);
  IniF.WriteBool('SetLog', 'TRXForm', ShowTRXForm);
  IniF.WriteString('SetLog', 'PastBand', ComboBox1.Text);
  TRXForm.Close;
end;

procedure TMainForm.DBGrid1CellClick(Column: TColumn);
begin
  SelectQSO;
end;

procedure TMainForm.DBGrid1ColumnMoved(Sender: TObject; FromIndex, ToIndex: integer);
var
  i: integer;
begin
  //Сохранение размещения колонок
  for i := 0 to 28 do
  begin
    IniF.WriteString('GridSettings', 'Columns' + IntToStr(i),
      DBGrid1.Columns.Items[i].FieldName);
  end;
  SetGrid();
end;

procedure TMainForm.DBGrid1ColumnSized(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to 28 do
  begin
    if DBGrid1.Columns.Items[i].Width <> 0 then
      IniF.WriteInteger('GridSettings', 'ColWidth' + IntToStr(i),
        DBGrid1.Columns.Items[i].Width)
    else
      IniF.WriteInteger('GridSettings', 'ColWidth' + IntToStr(i), columnsWidth[i]);
  end;
  SetGrid();
end;

procedure TMainForm.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked = False then
  begin
    EditButton1.Font.Color := clRed;
    DateTimePicker1.Font.Color := clRed;
    DateEdit1.Font.Color := clRed;
    CheckBox2.Enabled := True;
    DateTimePicker1.ReadOnly := False;
  end
  else
  begin
    EditButton1.Font.Color := clDefault;
    DateTimePicker1.Font.Color := clDefault;
    DateEdit1.Font.Color := clDefault;
    CheckBox2.Enabled := False;
    CheckBox2.Checked := False;
    DateTimePicker1.ReadOnly := True;
  end;
end;

procedure TMainForm.CallBookLiteConnectionAfterDisconnect(Sender: TObject);
begin
  Application.ProcessMessages;
  if MainForm.CloseQuery = False then
    CallBookLiteConnection.Connected := True;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin

end;



procedure TMainForm.CheckBox2Change(Sender: TObject);
begin
  if CheckBox2.Checked = True then
    Label4.Caption := 'Время (Local)'
  else
    Label4.Caption := 'Время (UTC)';
end;

procedure TMainForm.CheckBox3Change(Sender: TObject);
begin
  if CheckBox3.Checked = True then
  begin
  {$IFDEF WINDOWS}
  FDownloader := TMVDEWin32.Create(Self);
  MapViewer1.UseThreads := True;
  FDownloader.OnAfterDownload := @DoAfterDownload;
  FDownloader.OnBeforeDownload := @DoBeforeDownload;
  MapViewer1.DownloadEngine := FDownloader;
  MapViewer1.Center;
    MapViewer1.Visible := True;
    MapViewer1.Parent := Panel10;
    Earth.Hide;
    {$ENDIF}
  end
  else
  begin
    MapViewer1.Visible := False;
    Earth.Parent := Panel10;
    Earth.BorderStyle := bsNone;
    Earth.Align := alClient;
    Earth.Show;
  end;
end;

procedure TMainForm.CheckBox6Change(Sender: TObject);
begin
  if CheckBox6.Checked = False then
    SelectLogDatabase(LogTable);
end;

procedure TMainForm.CheckMySQL_ConnectTimer(Sender: TObject);
begin
 // try
 //   Application.ProcessMessages;
 //   if MySQLLOGDBConnection.Connected = False then
  //    MySQLLOGDBConnection.Connected := True;
 // except
 // end;
end;

procedure TMainForm.CheckUpdatesTimerStartTimer(Sender: TObject);
begin
  {$IFDEF WINDOWS}
  if Update_Form.CheckUpdate = True then
    Label50.Visible := True
  else
    Label50.Visible := False;

  //end;
 {$ENDIF WINDOWS}
end;



procedure TMainForm.CheckUpdatesTimerTimer(Sender: TObject);
begin
  {$IFDEF WINDOWS}
  if Update_Form.CheckUpdate = True then
    Label50.Visible := True
  else
    Label50.Visible := False;
  {$ENDIF WINDOWS}
end;

procedure TMainForm.ComboBox1Change(Sender: TObject);
begin
  freqchange:=True;
end;

procedure TMainForm.ComboBox2Change(Sender: TObject);
var
  RSdigi: array[0..4] of string = ('599', '589', '579', '569', '559');
  RSssb: array[0..6] of string = ('59', '58', '57', '56', '55', '54', '53');
begin

{  if ComboBox2.Text = 'LSB' then
    TRXForm.SetMode('LSB', StrToInt(TRXForm.bwith));
  if ComboBox2.Text = 'USB' then
    TRXForm.SetMode('USB', StrToInt(TRXForm.bwith));
  if ComboBox2.Text = 'FM' then
    TRXForm.SetMode('FM', StrToInt(TRXForm.bwith));
  if ComboBox2.Text = 'AM' then
    TRXForm.SetMode('AM', StrToInt(TRXForm.bwith));
  if ComboBox2.Text = 'CW' then
    TRXForm.SetMode('CW', StrToInt(TRXForm.bwith));
 }

  if (ComboBox2.Text <> 'SSB') or (ComboBox2.Text <> 'AM') or
    (ComboBox2.Text <> 'FM') or (ComboBox2.Text <> 'LSB') or
    (ComboBox2.Text <> 'USB') or (ComboBox2.Text <> 'JT44') or
    (ComboBox2.Text <> 'JT65') or (ComboBox2.Text <> 'JT6M') or
    (ComboBox2.Text <> 'JT9') or (ComboBox2.Text <> 'ROS') then
  begin
    ComboBox4.Items.Clear;
    ComboBox4.Items.AddStrings(RSdigi);
    ComboBox4.ItemIndex := 0;
    ComboBox5.Items.Clear;
    ComboBox5.Items.AddStrings(RSdigi);
    ComboBox5.ItemIndex := 0;
  end;

  if (ComboBox2.Text = 'SSB') or (ComboBox2.Text = 'AM') or
    (ComboBox2.Text = 'FM') or (ComboBox2.Text = 'LSB') or
    (ComboBox2.Text = 'USB') then
  begin
    ComboBox4.Items.Clear;
    ComboBox4.Items.AddStrings(RSssb);
    ComboBox4.ItemIndex := 0;
    ComboBox5.Items.Clear;
    ComboBox5.Items.AddStrings(RSssb);
    ComboBox5.ItemIndex := 0;
  end;

  if (ComboBox2.Text = 'ROS') or (ComboBox2.Text = 'JT44') or
    (ComboBox2.Text = 'JT65') or (ComboBox2.Text = 'JT6M') or
    (ComboBox2.Text = 'JT9') or (ComboBox2.Text = 'FT8') then
  begin
    ComboBox4.Items.Clear;
    ComboBox4.Text := '-10';
    ComboBox5.Items.Clear;
    ComboBox5.Text := '-10';
  end;
 freqchange:=True;
end;

procedure TMainForm.ComboBox3Change(Sender: TObject);
var
  i, j: integer;
begin
  ComboBox8.ItemIndex := ComboBox3.ItemIndex;
  i := pos('>', ComboBox3.Text);
  j := pos(':', ComboBox3.Text);
  //Сервер
  HostCluster := copy(ComboBox3.Text, i + 1, j - i - 1);
  Delete(HostCluster, 1, 1);
  //Порт
  PortCluster := copy(ComboBox3.Text, j + 1, Length(ComboBox3.Text) - i);
end;

procedure TMainForm.ComboBox8Change(Sender: TObject);
var
  i, j: integer;
begin
  ComboBox3.ItemIndex := ComboBox8.ItemIndex;
  i := pos('>', ComboBox8.Text);
  j := pos(':', ComboBox8.Text);
  //Сервер
  HostCluster := copy(ComboBox8.Text, i + 1, j - i - 1);
  Delete(HostCluster, 1, 1);
  //Порт
  PortCluster := copy(ComboBox8.Text, j + 1, Length(ComboBox8.Text) - i);
end;

procedure TMainForm.DBGrid1DblClick(Sender: TObject);
begin
  if DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString <> '' then
  begin
    UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
    EditQSO_Form.Edit1.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
    EditQSO_Form.DateEdit1.Date :=
      DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsDateTime;
    EditQSO_Form.DateTimePicker1.Time :=
      StrToTime(DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsString);
    EditQSO_Form.Edit1.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
    EditQSO_Form.Edit4.Text := DBGrid1.DataSource.DataSet.FieldByName('OMName').AsString;
    EditQSO_Form.Edit5.Text := DBGrid1.DataSource.DataSet.FieldByName('OMQTH').AsString;
    EditQSO_Form.Edit17.Text := DBGrid1.DataSource.DataSet.FieldByName('State').AsString;
    EditQSO_Form.Edit14.Text := DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;
    EditQSO_Form.Edit2.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
    EditQSO_Form.Edit3.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('QSOReportRecived').AsString;
    EditQSO_Form.Edit18.Text := DBGrid1.DataSource.DataSet.FieldByName('IOTA').AsString;
    EditQSO_Form.DateEdit3.Date :=
      DBGrid1.DataSource.DataSet.FieldByName('QSLSentDate').AsDateTime;
    EditQSO_Form.DateEdit2.Date :=
      DBGrid1.DataSource.DataSet.FieldByName('QSLRecDate').AsDateTime;
    EditQSO_Form.DateEdit4.Date :=
      DBGrid1.DataSource.DataSet.FieldByName('LoTWRecDate').AsDateTime;
    EditQSO_Form.Edit8.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('MainPrefix').AsString;
    EditQSO_Form.Edit7.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('DXCCPrefix').AsString;
    EditQSO_Form.Edit6.Text := DBGrid1.DataSource.DataSet.FieldByName('DXCC').AsString;
    EditQSO_Form.Edit15.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('CQZone').AsString;
    EditQSO_Form.Edit16.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('ITUZone').AsString;
    EditQSO_Form.CheckBox3.Checked :=
      DBGrid1.DataSource.DataSet.FieldByName('Marker').AsBoolean;
    EditQSO_Form.DBLookupComboBox3.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;

    EditQSO_Form.ComboBox1.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
    //dmFunc.GetAdifBandFromFreq(DBGrid1.DataSource.DataSet.FieldByName(
    //  'QSOBand').AsString);

    EditQSO_Form.Edit13.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('Continent').AsString;
    EditQSO_Form.Edit20.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('QSLInfo').AsString;
    EditQSO_Form.CheckBox2.Checked :=
      DBGrid1.DataSource.DataSet.FieldByName('ValidDX').AsBoolean;
    EditQSO_Form.Edit19.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('QSLManager').AsString;
    EditQSO_Form.Edit10.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('State1').AsString;
    EditQSO_Form.Edit9.Text := DBGrid1.DataSource.DataSet.FieldByName('State2').AsString;
    EditQSO_Form.Edit11.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('State3').AsString;
    EditQSO_Form.Edit12.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('State4').AsString;
    EditQSO_Form.Memo1.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('QSOAddInfo').AsString;
    EditQSO_Form.CheckBox1.Checked :=
      DBGrid1.DataSource.DataSet.FieldByName('NoCalcDXCC').AsBoolean;
    EditQSO_Form.CheckBox5.Checked :=
      DBGrid1.DataSource.DataSet.FieldByName('QSLReceQSLcc').AsBoolean;
    EditQSO_Form.CheckBox4.Checked :=
      DBGrid1.DataSource.DataSet.FieldByName('QSLRec').AsBoolean;
    EditQSO_Form.CheckBox6.Checked :=
      DBGrid1.DataSource.DataSet.FieldByName('LoTWRec').AsBoolean;

    if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'G' then
      EditQSO_Form.ComboBox6.ItemIndex := 5;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'B' then
      EditQSO_Form.ComboBox6.ItemIndex := 1;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'D' then
      EditQSO_Form.ComboBox6.ItemIndex := 2;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'E' then
      EditQSO_Form.ComboBox6.ItemIndex := 3;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'M' then
      EditQSO_Form.ComboBox6.ItemIndex := 4;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = '' then
      EditQSO_Form.ComboBox6.ItemIndex := 0;

    if DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString = 'G' then
      EditQSO_Form.ComboBox7.ItemIndex := 5;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString = 'B' then
      EditQSO_Form.ComboBox7.ItemIndex := 1;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString = 'D' then
      EditQSO_Form.ComboBox7.ItemIndex := 2;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString = 'E' then
      EditQSO_Form.ComboBox7.ItemIndex := 3;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString = 'M' then
      EditQSO_Form.ComboBox7.ItemIndex := 4;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString = '' then
      EditQSO_Form.ComboBox7.ItemIndex := 0;

    if DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString = 'P' then
      EditQSO_Form.RadioButton2.Checked := True;
    if DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString = 'T' then
      EditQSO_Form.RadioButton1.Checked := True;
    if DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString = 'Q' then
      EditQSO_Form.RadioButton3.Checked := True;
    if DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString = 'F' then
      EditQSO_Form.RadioButton4.Checked := True;
    if DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString = 'N' then
      EditQSO_Form.RadioButton5.Checked := True;

    EditQSO_Form.DBLookupComboBox1.KeyValue :=
      DBGrid1.DataSource.DataSet.FieldByName('PROP_MODE').AsString;

    EditQSO_Form.Show;
  end;
end;

procedure TMainForm.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: integer; Column: TColumn; State: TGridDrawState);
var
  i: integer;
begin
  if LOGBookDS.DataSet.FieldByName('QSLSentAdv').AsString = 'N' then
    with DBGrid1.Canvas do
    begin
      FillRect(Rect);
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end
      else
      begin
        Brush.Color := clRed;
        Font.Color := clBlack;
      end;
      FillRect(Rect);
      DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (LOGBookDS.DataSet.FieldByName('QSL').AsString = '100') or
    (LOGBookDS.DataSet.FieldByName('QSL').AsString = '110') then
    with DBGrid1.Canvas do
    begin
      FillRect(Rect);
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end
      else
      begin
        Brush.Color := clFuchsia;
        Font.Color := clBlack;
      end;
      FillRect(Rect);
      DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (LOGBookDS.DataSet.FieldByName('QSLs').AsString = '10') or
    (LOGBookDS.DataSet.FieldByName('QSLs').AsString = '11') then
    with DBGrid1.Canvas do
    begin
      FillRect(Rect);
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end
      else
      begin
        Brush.Color := clLime;
        Font.Color := clBlack;
      end;
      FillRect(Rect);
      DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (LOGBookDS.DataSet.FieldByName('QSL').AsString = '010') or
    (LOGBookDS.DataSet.FieldByName('QSL').AsString = '110') or
    (LOGBookDS.DataSet.FieldByName('QSL').AsString = '111') then
    if (Column.FieldName = 'CallSign') then
    begin
      with DBGrid1.Canvas do
      begin
        if (gdSelected in State) then
        begin
          Brush.Color := clHighlight;
          Font.Color := clWhite;
        end
        else
        begin
          Brush.Color := clYellow;
          Font.Color := clBlack;
        end;
        FillRect(Rect);
        DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
      end;
    end;

  if (Column.FieldName = 'QSL') then
  begin
    with DBGrid1.Canvas do
    begin
      FillRect(Rect);
      if (LOGBookDS.DataSet.FieldByName('QSL').AsString = '000') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth(''), Rect.Top + 0, '');
      end;

      if (LOGBookDS.DataSet.FieldByName('QSL').AsString = '100') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth('P'), Rect.Top + 0, 'P');
      end;

      if (LOGBookDS.DataSet.FieldByName('QSL').AsString = '110') then
      begin
        TextOut(Rect.Right - 10 - DBGrid1.Canvas.TextWidth('PE'),
          Rect.Top + 0, 'PE');
      end;

      if (LOGBookDS.DataSet.FieldByName('QSL').AsString = '111') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth('PLE'),
          Rect.Top + 0, 'PLE');
      end;

      if (LOGBookDS.DataSet.FieldByName('QSL').AsString = '010') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth('E'), Rect.Top + 0, 'E');
      end;

      if (LOGBookDS.DataSet.FieldByName('QSL').AsString = '001') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth('L'), Rect.Top + 0, 'L');
      end;

      if (LOGBookDS.DataSet.FieldByName('QSL').AsString = '101') then
      begin
        TextOut(Rect.Right - 10 - DBGrid1.Canvas.TextWidth('PL'),
          Rect.Top + 0, 'PL');
      end;

      if (LOGBookDS.DataSet.FieldByName('QSL').AsString = '011') then
      begin
        TextOut(Rect.Right - 10 - DBGrid1.Canvas.TextWidth('LE'),
          Rect.Top + 0, 'PL');
      end;
    end;
  end;

  if (Column.FieldName = 'QSLs') then
  begin
    with DBGrid1.Canvas do
    begin
      FillRect(Rect);
      if (LOGBookDS.DataSet.FieldByName('QSLs').AsString = '00') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth(''), Rect.Top + 0, '');
      end;

      if (LOGBookDS.DataSet.FieldByName('QSLs').AsString = '10') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth('P'), Rect.Top + 0, 'P');
      end;

      if (LOGBookDS.DataSet.FieldByName('QSLs').AsString = '11') then
      begin
        TextOut(Rect.Right - 10 - DBGrid1.Canvas.TextWidth('PL'),
          Rect.Top + 0, 'PE');
      end;

      if (LOGBookDS.DataSet.FieldByName('QSLs').AsString = '01') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth('L'), Rect.Top + 0, 'PLE');
      end;
    end;
  end;
end;

procedure TMainForm.DBGrid1KeyPress(Sender: TObject; var Key: char);
begin
  //if LOGBookDS.DataSet.AfterScroll then

end;

procedure TMainForm.DBGrid1TitleClick(Column: TColumn);
begin
  //ShowMessage('Click');
end;

procedure TMainForm.DBGrid2DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: integer; Column: TColumn; State: TGridDrawState);
begin
  if DataSource2.DataSet.FieldByName('QSLSentAdv').AsString = 'N' then
    with DBGrid2.Canvas do
    begin
      FillRect(Rect);
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end
      else
      begin
        Brush.Color := clRed;
        Font.Color := clBlack;
      end;
      FillRect(Rect);
      DBGrid2.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (DataSource2.DataSet.FieldByName('QSL').AsString = '100') or
    (DataSource2.DataSet.FieldByName('QSL').AsString = '110') then
    with DBGrid2.Canvas do
    begin
      FillRect(Rect);
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end
      else
      begin
        Brush.Color := clFuchsia;
        Font.Color := clBlack;
      end;
      FillRect(Rect);
      DBGrid2.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (DataSource2.DataSet.FieldByName('QSLs').AsString = '10') or
    (DataSource2.DataSet.FieldByName('QSLs').AsString = '11') then
    with DBGrid2.Canvas do
    begin
      FillRect(Rect);
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end
      else
      begin
        Brush.Color := clLime;
        Font.Color := clBlack;
      end;
      FillRect(Rect);
      DBGrid2.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (DataSource2.DataSet.FieldByName('QSL').AsString = '010') or
    (DataSource2.DataSet.FieldByName('QSL').AsString = '110') or
    (DataSource2.DataSet.FieldByName('QSL').AsString = '111') then
    if (Column.FieldName = 'CallSign') then
    begin
      with DBGrid2.Canvas do
      begin
        if (gdSelected in State) then
        begin
          Brush.Color := clHighlight;
          Font.Color := clWhite;
        end
        else
        begin
          Brush.Color := clYellow;
          Font.Color := clBlack;
        end;
        FillRect(Rect);
        DBGrid2.DefaultDrawColumnCell(Rect, DataCol, Column, State);
      end;
    end;

  if (Column.FieldName = 'QSL') then
  begin
    with DBGrid2.Canvas do
    begin
      FillRect(Rect);
      if (DataSource2.DataSet.FieldByName('QSL').AsString = '000') then
      begin
        TextOut(Rect.Right - 6 - DBGrid2.Canvas.TextWidth(''), Rect.Top + 0, '');
      end;

      if (DataSource2.DataSet.FieldByName('QSL').AsString = '100') then
      begin
        TextOut(Rect.Right - 6 - DBGrid2.Canvas.TextWidth('P'), Rect.Top + 0, 'P');
      end;

      if (DataSource2.DataSet.FieldByName('QSL').AsString = '110') then
      begin
        TextOut(Rect.Right - 10 - DBGrid2.Canvas.TextWidth('PE'),
          Rect.Top + 0, 'PE');
      end;

      if (DataSource2.DataSet.FieldByName('QSL').AsString = '111') then
      begin
        TextOut(Rect.Right - 6 - DBGrid2.Canvas.TextWidth('PLE'),
          Rect.Top + 0, 'PLE');
      end;

      if (DataSource2.DataSet.FieldByName('QSL').AsString = '010') then
      begin
        TextOut(Rect.Right - 6 - DBGrid2.Canvas.TextWidth('E'), Rect.Top + 0, 'E');
      end;

      if (DataSource2.DataSet.FieldByName('QSL').AsString = '001') then
      begin
        TextOut(Rect.Right - 6 - DBGrid2.Canvas.TextWidth('L'), Rect.Top + 0, 'L');
      end;

      if (DataSource2.DataSet.FieldByName('QSL').AsString = '101') then
      begin
        TextOut(Rect.Right - 10 - DBGrid2.Canvas.TextWidth('PL'),
          Rect.Top + 0, 'PL');
      end;

      if (DataSource2.DataSet.FieldByName('QSL').AsString = '011') then
      begin
        TextOut(Rect.Right - 10 - DBGrid2.Canvas.TextWidth('LE'),
          Rect.Top + 0, 'PL');
      end;
    end;
  end;

  if (Column.FieldName = 'QSLs') then
  begin
    with DBGrid2.Canvas do
    begin
      FillRect(Rect);
      if (DataSource2.DataSet.FieldByName('QSLs').AsString = '00') then
      begin
        TextOut(Rect.Right - 6 - DBGrid2.Canvas.TextWidth(''), Rect.Top + 0, '');
      end;

      if (DataSource2.DataSet.FieldByName('QSLs').AsString = '10') then
      begin
        TextOut(Rect.Right - 6 - DBGrid2.Canvas.TextWidth('P'), Rect.Top + 0, 'P');
      end;

      if (DataSource2.DataSet.FieldByName('QSLs').AsString = '11') then
      begin
        TextOut(Rect.Right - 10 - DBGrid2.Canvas.TextWidth('PL'),
          Rect.Top + 0, 'PE');
      end;

      if (DataSource2.DataSet.FieldByName('QSLs').AsString = '01') then
      begin
        TextOut(Rect.Right - 6 - DBGrid2.Canvas.TextWidth('L'), Rect.Top + 0, 'PLE');
      end;
    end;
  end;
end;

procedure TMainForm.DBLookupComboBox1Change(Sender: TObject);
begin

end;

procedure TMainForm.DBLookupComboBox1CloseUp(Sender: TObject);
begin
  SelDB(DBLookupComboBox1.KeyValue);
  CallLogBook := DBLookupComboBox1.KeyValue;
end;

procedure TMainForm.Edit12KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  try
    if Key = 13 then
    begin
      cluster.Send(Edit12.Text + #13 + #10);
      Edit12.Clear;
    end;

  except
    Memo1.Append('Нет подключения к кластеру');
    timer2.Enabled := False;
    Edit12.Clear;
  end;
end;

procedure TMainForm.Edit1Change(Sender: TObject);
var
  s: UTF8String;
begin
  s := Edit1.Text;
  if UTF8Length(s) > 0 then
  begin
    Edit1.SelStart := UTF8Length(s);
    Edit1.Text := UTF8UpperCase(UTF8Copy(s, 1, 1)) +
      UTF8LowerCase(UTF8Copy(s, 2, UTF8Length(s)));
  end;

end;

procedure TMainForm.Edit2Change(Sender: TObject);
var
  s: UTF8String;
begin
  s := Edit2.Text;
  if UTF8Length(s) > 0 then
  begin
    Edit2.SelStart := UTF8Length(s);
    //    Edit2.Text := UTF8UpperCase(UTF8Copy(s, 1, 1)) + UTF8LowerCase(UTF8Copy(s, 2, UTF8Length(s)))

    if (UTF8Pos('Г.', s) > 0) or (UTF8Pos('С.', s) > 0) or (UTF8Pos('П.', s) > 0) then
      Edit2.Text := UTF8LowerCase(UTF8Copy(s, 1, 2)) +
        UTF8UpperCase(UTF8Copy(s, 3, 2)) + UTF8LowerCase(UTF8Copy(s, 5, UTF8Length(s)));

    if (UTF8Pos('СТ.', s) > 0) then
      Edit2.Text := UTF8LowerCase(UTF8Copy(s, 1, 3)) +
        UTF8UpperCase(UTF8Copy(s, 4, 2)) + UTF8LowerCase(UTF8Copy(s, 6, UTF8Length(s)));
  end;
end;

procedure TMainForm.EditButton1ButtonClick(Sender: TObject);
begin
  if (CallBookLiteConnection.Connected = True) and (IniF.ReadString('SetLog', 'Sprav', '') = 'False') then
        SearchCallInCallBook(dmFunc.ExtractCallsign(EditButton1.Text));
      if (CallBookLiteConnection.Connected = False) and (IniF.ReadString('SetLog', 'Sprav', '') = 'True') then begin
        InformationForm.QRZRUsprav(EditButton1.Text);
      end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  PathMyDoc: string;
  i, j: integer;
begin
      {$IFDEF UNIX}
    PathMyDoc := GetEnvironmentVariable('HOME') + '/EWLog/';
    {$ELSE}
    PathMyDoc := GetEnvironmentVariable('SystemDrive') +
      GetEnvironmentVariable('HOMEPATH') + '\EWLog\';
    {$ENDIF UNIX}
  Inif := TINIFile.Create(PathMyDoc + 'settings.ini');
  useMAPS := INiF.ReadString('SetLog', 'UseMAPS', '');
  EditFlag := False;
  Application.ProcessMessages;
  StayForm := True;
  AdifFromMobileSyncStart := False;
  ExportAdifSelect := False;
  ImportAdifMobile:=False;
  DateSeparator := '.';
  {$IFDEF UNIX}
 // FDownloader := TMVDESynapse.Create(Self);
  CheckBox3.Visible:=False;
  CheckBox5.Visible:=False;
  {$ELSE}
  CheckBox3.Visible:=True;
  CheckBox5.Visible:=True;
  if useMAPS = 'YES' then begin
  FDownloader := TMVDEWin32.Create(Self);
  MapViewer1.UseThreads := True;
  FDownloader.OnAfterDownload := @DoAfterDownload;
  FDownloader.OnBeforeDownload := @DoBeforeDownload;
  MapViewer1.DownloadEngine := FDownloader;
  MapViewer1.Center;
  end;
  {$ENDIF UNIX}

  try
    InitLog_DB := INiF.ReadString('SetLog', 'LogBookInit', '');
    if InitLog_DB = 'YES' then
    begin
      CallLogBook := INiF.ReadString('SetLog', 'DefaultCallLogBook', '');
      UseCallBook := INiF.ReadString('SetLog', 'UseCallBook', 'No');
      DefaultDB := IniF.ReadString('DataBases', 'DefaultDataBase', '');
      LoginBD := IniF.ReadString('DataBases', 'LoginName', '');
      PasswdDB := IniF.ReadString('DataBases', 'Password', '');
      HostDB := IniF.ReadString('DataBases', 'HostAddr', '');
      PortDB := IniF.ReadString('DataBases', 'Port', '');
      NameDB := IniF.ReadString('DataBases', 'DataBaseName', '');

      PhotoDir := IniF.ReadString('SetLog', 'PhotoDir', '');

      RegisterLog := IniF.ReadString('SetLog', 'Register', '');
      LoginLog := IniF.ReadString('SetLog', 'Login', '');
      PassLog := IniF.ReadString('SetLog', 'Pass', '');

      LoginCallBook := IniF.ReadString('CallBookDB', 'LoginName', '');
      PasswdCallBook := IniF.ReadString('CallBookDB', 'Password', '');
      HostCallBook := IniF.ReadString('CallBookDB', 'HostAddr', '');
      PortCallBook := IniF.ReadString('CallBookDB', 'Port', '');
      NameCallBook := IniF.ReadString('CallBookDB', 'DataBaseName', '');

      SQLiteFILE := IniF.ReadString('DataBases', 'FileSQLite', '');

      LoginCluster := IniF.ReadString('TelnetCluster', 'Login', '');
      PasswordCluster := IniF.ReadString('TelnetCluster', 'Password', '');
      // HostCluster := IniF.ReadString('TelnetCluster', 'Server', '');
      // PortCluster := IniF.ReadString('TelnetCluster', 'Port', '');

      for i := 1 to 9 do
      begin
        TelStr[i] := IniF.ReadString('TelnetCluster', 'Server' +
          IntToStr(i), 'RN6BN -> rn6bn.73.ru:23');
      end;
      TelName := IniF.ReadString('TelnetCluster', 'ServerDef',
        'RN6BN -> rn6bn.73.ru:23');
      ComboBox3.Items.Clear;
      ComboBox3.Items.AddStrings(TelStr);
      ComboBox3.ItemIndex := ComboBox3.Items.IndexOf(TelName);

      ComboBox8.Items.Clear;
      ComboBox8.Items.AddStrings(TelStr);
      ComboBox8.ItemIndex := ComboBox8.Items.IndexOf(TelName);

      i := pos('>', ComboBox3.Text);
      j := pos(':', ComboBox3.Text);
      //Сервер
      HostCluster := copy(ComboBox3.Text, i + 1, j - i - 1);
      Delete(HostCluster, 1, 1);
      //Порт
      PortCluster := copy(ComboBox3.Text, j + 1, Length(ComboBox3.Text) - i);


      fl_path := IniF.ReadString('FLDIGI', 'FldigiPATH', '');
      wsjt_path := IniF.ReadString('WSJT', 'WSJTPATH', '');
      XMLRPC_FL_USE := IniF.ReadString('FLDIGI', 'XMLRPC', '');
      FLDIGI_USE := IniF.ReadString('FLDIGI', 'USEFLDIGI', '');
      WSJT_USE := IniF.ReadString('WSJT', 'USEWSJT', '');

      ShowTRXForm := IniF.ReadBool('SetLog', 'TRXForm', False);

      if FLDIGI_USE = 'YES' then
        MenuItem74.Enabled := True
      else
        MenuItem74.Enabled := False;


      if WSJT_USE = 'YES' then
        MenuItem43.Enabled := True
      else
        MenuItem43.Enabled := False;

      MainForm.Width := IniF.ReadInteger('SetLog', 'Width', 1043);
      MainForm.Height := IniF.ReadInteger('SetLog', 'Height', 671);
      if IniF.ReadString('SetLog', 'FormState', '') = 'Maximized' then
        MainForm.WindowState := wsMaximized;

      DateEdit1.Date := NowUTC;
      DateTimePicker1.Time := NowUTC;
      Label24.Caption := FormatDateTime('hh:mm:ss', Now);
      Label26.Caption := FormatDateTime('hh:mm:ss', NowUTC);

      if DefaultDB = 'MySQL' then
        MenuItem89.Caption := 'Переключить базу на SQLite'
      else
        MenuItem89.Caption := 'Переключить базу на MySQL';
      InitializeDB(DefaultDB);

    end;
    // except
    // end;

  finally
   // DateSeparator := '.';
  end;
  LTCPComponent1.Listen(6666);
  LUDPComponent1.Listen(6667);
  LTCPComponent1.ReuseAddress := True;
  ComboBox1.Text:=IniF.ReadString('SetLog', 'PastBand', '7.000.00');
  freqchange:=True;
  if usewsjt then
    WSJT_Timer.Enabled := True;
  if usefldigi then
    Fl_Timer.Enabled := True;
  if InitLog_DB <> 'YES' then
  begin
    if Application.MessageBox(PChar('База данных ' +
      'не инициализирована, перейти к настройкам?'),
      'Внимание!', MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      SetupForm.Show;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  //IniF.WriteString('SetLog', 'PastBand', ComboBox1.Text);
  if CheckBox3.Checked = True then
    IniF.WriteString('SetLog', 'UseMAPS', 'YES')
  else
    IniF.WriteString('SetLog', 'UseMAPS', 'NO');
  //AdifMobileString.Free;
  //AdifFromMobileString.Free;
  PrefixProvinceList.Free;
  PrefixARRLList.Free;
  FDownloader.Free;
  IniF.Free;
   LTCPComponent1.Free;
  LUDPComponent1.Free;
  TrayIcon1.Free;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (ssAlt in Shift) and (chr(Key)='H') then
  hiddenSettings.Show;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  sgCluster.Columns[3].Width := MainForm.Width - 820;
  Label50.Left := Panel1.Width - 165;
  ComboBox3.Width := MainForm.Width - 655;
  SpeedButton19.Left := Panel9.Width - 27;
  ComboBox8.Width := MainForm.Width - 655;
  SpeedButton25.Left := Panel9.Width - 27;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
 i: integer;
begin
  RegisterLog := IniF.ReadString('SetLog', 'Register', '');
  LoginLog := IniF.ReadString('SetLog', 'Login', '');
  PassLog := IniF.ReadString('SetLog', 'Pass', '');
  sprav:=IniF.ReadString('SetLog', 'Sprav', '');

  if MenuItem86.Checked = True then
    TRXForm.Show;

  UnUsIndex := 0;

  if useMAPS = 'YES' then
    CheckBox3.Checked := True
  else
    CheckBox3.Checked := False;
  CheckBox3.Enabled := True;

  SetGrid;

  if ShowTRXForm = False then
    MenuItem88.Checked := True
  else
    MenuItem86.Checked := True;

  if ShowTRXForm = True then
  begin
    TRXForm.Parent := Panel13;
    TRXForm.BorderStyle := bsNone;
    TRXForm.Align := alClient;
    TRXForm.Show;
  end;

  if IniF.ReadString('SetLog', 'ShowBand', '') = 'True' then
  begin
    ComboBox1.Items.Clear;
    for i:=0 to 12 do
    ComboBox1.Items.Add(constBandName[i]);
  end
  else begin
  ComboBox1.Items.Clear;
    for i:=0 to 12 do
    ComboBox1.Items.Add(constKhzBandName[i]);
  end;

  InformationForm.Timer1.Interval:=3200000;
  InformationForm.Timer1.Enabled:=True;

      {$IFDEF WINDOWS}
  CheckUpdatesTimer.Enabled := True;
    {$ENDIF WINDOWS}

end;

procedure TMainForm.Label50Click(Sender: TObject);
begin
  Update_Form.Show;
end;

procedure TMainForm.LogBookInfoDSDataChange(Sender: TObject; Field: TField);
begin

end;

procedure TMainForm.LTCPComponent1Accept(aSocket: TLSocket);
begin
  StatusBar1.Panels.Items[0].Text :=
    'Клиент подключился:'+aSocket.PeerAddress;
end;

procedure TMainForm.LTCPComponent1CanSend(aSocket: TLSocket);
var
  Sent: integer;
  TempBuffer: string = '';
  lenBuffer: integer;
  Count: integer;
begin
  if (AdifDataSyncAll = True) or (AdifDataSyncDate = True) then
  begin
    Count := 0;
    TempBuffer := BuffToSend;
    lenBuffer := Length(TempBuffer);
    //if
      while TempBuffer <> '' do //then
   // else
    begin
      Sent := LTCPComponent1.SendMessage(TempBuffer, aSocket);
      Delete(BuffToSend, 1, Sent);
      TempBuffer := BuffToSend;
      {$IFDEF LINUX}
      Sleep(100);
      {$ENDIF}
    end;
  end;
end;

procedure TMainForm.LTCPComponent1Error(const msg: string; aSocket: TLSocket);
begin
  MainForm.StatusBar1.Panels.Items[0].Text := asocket.peerAddress + ':' + msg;
end;

function TMainForm.GetNewChunk: string;
var
  res: string;
  i: integer;
begin
  res := '';
  for i := 0 to AdifMobileString.Count - 1 do
  begin
    res := res + AdifMobileString[0];
    AdifMobileString.Delete(0);
  end;
  res := res + 'DataSyncSuccess:' + SetCallName + #13;
  Result := res;
  AdifMobileString.Free;
end;

procedure TMainForm.LTCPComponent1Receive(aSocket: TLSocket);
var
  mess, rec_call, PathMyDoc, s: string;
  AdifFile: TextFile;
begin
    {$IFDEF UNIX}
  PathMyDoc := GetEnvironmentVariable('HOME') + '/EWLog/';
    {$ELSE}
  PathMyDoc := GetEnvironmentVariable('SystemDrive') +
    GetEnvironmentVariable('HOMEPATH') + '\EWLog\';
    {$ENDIF UNIX}

  AdifDataSyncAll := False;
  AdifDataSyncDate := False;

  if aSocket.GetMessage(mess) > 0 then
  begin
    if Pos('DataSyncAll', mess) > 0 then
    begin
      rec_call := dmFunc.par_str(mess, 2);
      if Pos(SetCallName, rec_call) > 0 then
      begin
        AdifMobileString := TStringList.Create;
        exportAdifForm.ExportToMobile('All', '');
        AdifDataSyncAll := True;
        BuffToSend := GetNewChunk;
        LTCPComponent1.OnCanSend(LTCPComponent1.Iterator);
      end;
    end;

    if Pos('DataSyncDate', mess) > 0 then
    begin
      AdifDataDate := dmFunc.par_str(mess, 2);
      rec_call := dmFunc.par_str(mess, 3);
      if Pos(SetCallName, rec_call + #13) > 0 then
      begin
        AdifMobileString := TStringList.Create;
        exportAdifForm.ExportToMobile('Date', AdifDataDate);
        AdifDataSyncDate := True;
        BuffToSend := GetNewChunk;
        LTCPComponent1.OnCanSend(LTCPComponent1.Iterator);
      end;
    end;

    if Pos('DataSyncClientStart', mess) > 0 then
    begin
      rec_call := dmFunc.par_str(mess, 2);
      if Pos(SetCallName, rec_call) > 0 then
      begin
        Stream := TMemoryStream.Create;
        AdifFromMobileSyncStart := True;
      end;
    end;

    if (AdifFromMobileSyncStart = True) then
    begin
      mess := StringReplace(mess, #10, '', [rfReplaceAll]);
      mess := StringReplace(mess, #13, '', [rfReplaceAll]);
      if Length(mess) > 0 then
      begin
        Stream.Write(mess[1], length(mess));
      end;
    end;

    if Pos('DataSyncClientEnd', mess) > 0 then
    begin
      AdifFromMobileSyncStart := False;
      ImportAdifMobile:=True;
      Stream.SaveToFile(PathMyDoc + 'ImportMobile.adi');
      AssignFile(AdifFile, PathMyDoc + 'ImportMobile.adi');
      Reset(AdifFile);
      while not EOF(AdifFile) do
      begin
        Readln(AdifFile, s);
        s := StringReplace(s, '<EOR>', '<EOR>'#10, [rfReplaceAll]);
      end;
      CloseFile(AdifFile);
      Rewrite(AdifFile);
      Writeln(AdifFile, s);
      CloseFile(AdifFile);

      ImportADIFForm.FileNameEdit1.Text := PathMyDoc + 'ImportMobile.adi';
      ImportADIFForm.ADIFImport;
      Stream.Free;
      ImportAdifMobile:=False;
    end;
  end;
end;

procedure TMainForm.LUDPComponent1Receive(aSocket: TLSocket);
var
  mess: string;
begin
  if aSocket.GetMessage(mess) > 0 then
  begin
    if mess = 'GetIP' then
      LUDPComponent1.SendMessage(IdIPWatch1.LocalIP + ':6666');
    if mess = 'Hello' then
      LUDPComponent1.SendMessage('Welcome!');
  end;
end;

procedure TMainForm.MenuItem101Click(Sender: TObject);
begin
  registerform.Show;
end;

procedure TMainForm.MenuItem102Click(Sender: TObject);
begin
  openURL('https://yasobe.ru/na/ewlog');
end;

procedure TMainForm.MenuItem103Click(Sender: TObject);
begin
  filterForm.Show;
end;

procedure TMainForm.MenuItem104Click(Sender: TObject);
begin
      LogBookQuery.Close;
      LogBookQuery.SQL.Clear;

      if DefaultDB = 'MySQL' then
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable +
          ' WHERE `QSLRec` LIKE ' + QuotedStr(IntToStr(1)) +
          ' ORDER BY `UnUsedIndex`' + '');
      end
      else
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable +
          ' WHERE `QSLRec` LIKE ' + QuotedStr(IntToStr(1)) +
          ' ORDER BY `UnUsedIndex`' + '');
      end;
      LogBookQuery.Open;
      LOGBookQuery.Last;
end;

procedure TMainForm.MenuItem105Click(Sender: TObject);
begin
    LogBookQuery.Close;
      LogBookQuery.SQL.Clear;

      if DefaultDB = 'MySQL' then
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable +
          ' WHERE `QSLSent` LIKE ' + QuotedStr(IntToStr(1)) +
          ' ORDER BY `UnUsedIndex`' + '');
      end
      else
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable +
          ' WHERE `QSLSent` LIKE ' + QuotedStr(IntToStr(1)) +
          ' ORDER BY `UnUsedIndex`' + '');
      end;
      LogBookQuery.Open;
      LOGBookQuery.Last;
end;

procedure TMainForm.MenuItem106Click(Sender: TObject);
begin
    LogBookQuery.Close;
      LogBookQuery.SQL.Clear;

      if DefaultDB = 'MySQL' then
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable +
          ' WHERE `QSLSent` LIKE ' + QuotedStr(IntToStr(0)) +
          ' ORDER BY `UnUsedIndex`' + '');
      end
      else
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable +
          ' WHERE `QSLSent` LIKE ' + QuotedStr(IntToStr(0)) +
          ' ORDER BY `UnUsedIndex`' + '');
      end;
      LogBookQuery.Open;
      LOGBookQuery.Last;
end;

procedure TMainForm.MenuItem107Click(Sender: TObject);
begin
 LogBookQuery.Close;
      LogBookQuery.SQL.Clear;

      if DefaultDB = 'MySQL' then
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable +
          ' WHERE `QSLSentAdv` LIKE ' + QuotedStr('P') +
          ' ORDER BY `UnUsedIndex`' + '');
      end
      else
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable +
          ' WHERE `QSLSentAdv` LIKE ' + QuotedStr('P') +
          ' ORDER BY `UnUsedIndex`' + '');
      end;
      LogBookQuery.Open;
      LOGBookQuery.Last;

end;

procedure TMainForm.MenuItem108Click(Sender: TObject);
begin
  LogBookQuery.Close;
      LogBookQuery.SQL.Clear;

      if DefaultDB = 'MySQL' then
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable +
          ' WHERE `QSLSentAdv` LIKE ' + QuotedStr('N') +
          ' ORDER BY `UnUsedIndex`' + '');
      end
      else
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable +
          ' WHERE `QSLSentAdv` LIKE ' + QuotedStr('N') +
          ' ORDER BY `UnUsedIndex`' + '');
      end;
      LogBookQuery.Open;
      LOGBookQuery.Last;
end;

procedure TMainForm.MenuItem109Click(Sender: TObject);
begin
  SelectLogDatabase(LogTable);
end;

//QSL получена и отправлена на печать
procedure TMainForm.MenuItem10Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSLRec`=:QSLRec, `QSLRecDate`=:QSLRecDate, `QSLSentAdv`=:QSLSentAdv WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSLRec').Value := 1;
        Params.ParamByName('QSLRecDate').AsDate := Now;
        Params.ParamByName('QSLSentAdv').AsString := 'Q';
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL получена
procedure TMainForm.MenuItem11Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSLRec`=:QSLRec, `QSLRecDate`=:QSLRecDate WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSLRec').Value := 1;
        Params.ParamByName('QSLRecDate').AsDate := Now;
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//Поставить QSO в очередь на печать
procedure TMainForm.MenuItem12Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSLSentAdv`=:QSLSentAdv WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSLSentAdv').AsString := 'Q';
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL напечатана
procedure TMainForm.MenuItem13Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSLSentAdv`=:QSLSentAdv WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSLSentAdv').AsString := 'P';
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;
end;

//QSL отправлена
procedure TMainForm.MenuItem14Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSLSentAdv`=:QSLSentAdv, `QSLSentDate`=:QSLSentDate, `QSLSent`=:QSLSent WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSLSentAdv').AsString := 'T';
        Params.ParamByName('QSLSentDate').AsDate := Now;
        Params.ParamByName('QSLSent').Value := 1;
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL не отправлена
procedure TMainForm.MenuItem16Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSLSentAdv`=:QSLSentAdv, `QSLSentDate`=:QSLSentDate,`QSLSent`=:QSLSent WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSLSentAdv').AsString := 'F';
        Params.ParamByName('QSLSentDate').IsNull;
        Params.ParamByName('QSLSent').Value := 0;
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL не отправлять
procedure TMainForm.MenuItem17Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSLSentAdv`=:QSLSentAdv WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSLSentAdv').AsString := 'N';
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL получена через B - бюро
procedure TMainForm.MenuItem21Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSL_RCVD_VIA`=:QSL_RCVD_VIA WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSL_RCVD_VIA').AsString := 'B';
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL Получена через D - Direct
procedure TMainForm.MenuItem22Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSL_RCVD_VIA`=:QSL_RCVD_VIA WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSL_RCVD_VIA').AsString := 'D';
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL получена через E - Electronic
procedure TMainForm.MenuItem23Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSL_RCVD_VIA`=:QSL_RCVD_VIA, `QSLReceQSLcc`=:QSLReceQSLcc WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSL_RCVD_VIA').AsString := 'E';
        Params.ParamByName('QSLReceQSLcc').AsBoolean := True;
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL получена через M - менеджера
procedure TMainForm.MenuItem24Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSL_RCVD_VIA`=:QSL_RCVD_VIA WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSL_RCVD_VIA').AsString := 'M';
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL получена через G - GlobalQSL
procedure TMainForm.MenuItem25Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSL_RCVD_VIA`=:QSL_RCVD_VIA WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSL_RCVD_VIA').AsString := 'G';
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL Отправелена через B - Бюро
procedure TMainForm.MenuItem27Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSL_SENT_VIA`=:QSL_SENT_VIA WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSL_SENT_VIA').AsString := 'B';
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL отправлена через D - Direct
procedure TMainForm.MenuItem28Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSL_SENT_VIA`=:QSL_SENT_VIA WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSL_SENT_VIA').AsString := 'D';
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL отправлена через E - Electronic
procedure TMainForm.MenuItem29Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSL_SENT_VIA`=:QSL_SENT_VIA WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSL_SENT_VIA').AsString := 'E';
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL отправлена через M - менеджер
procedure TMainForm.MenuItem30Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSL_SENT_VIA`=:QSL_SENT_VIA WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSL_SENT_VIA').AsString := 'M';
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//QSL отправлена через G - GlobalQSL
procedure TMainForm.MenuItem31Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      with EditQSO_Form.UPDATE_Query do
      begin
        Close;
        SQL.Clear;
        SQL.Add('UPDATE ' + LogTable +
          ' SET `QSL_SENT_VIA`=:QSL_SENT_VIA WHERE `UnUsedIndex`=:UnUsedIndex');
        Params.ParamByName('QSL_SENT_VIA').AsString := 'G';
        Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
        ExecSQL;
      end;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    DBGrid1.DataSource.DataSet.RecNo := UnUsIndex;
  end;

end;

//Выбрать все записи в dbGrid1
procedure TMainForm.MenuItem35Click(Sender: TObject);
var
  i: integer;
begin
  if Self.LogBookQuery.RecordCount > 0 then
  begin
    LogBookQuery.First;
    for i := 0 to Self.LogBookQuery.RecordCount - 1 do
    begin
      Self.DBGrid1.SelectedRows.CurrentRowSelected := True;
      LogBookQuery.Next;
    end;
  end;
end;

procedure TMainForm.MenuItem36Click(Sender: TObject);
var
  i: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      SetLength(ExportAdifArray, DBGrid1.SelectedRows.Count);
      ExportAdifArray[i] := DBGrid1.DataSource.DataSet.FieldByName(
        'UnUsedIndex').AsInteger;
    end;


    // exportSelectADIF:=True;
    //exportAdifForm.ExportToAdif;
    ExportAdifSelect := True;
    exportAdifForm.Button1.Click;
  end;
end;

procedure TMainForm.MenuItem37Click(Sender: TObject);
begin
  if LogBookQuery.RecordCount > 0 then
  begin
    SendHRDThread := TSendHRDThread.Create;
    if Assigned(SendHRDThread.FatalException) then
      raise SendHRDThread.FatalException;
    with SendHRDThread do
    begin
      userid := HRDLogin;
      userpwd := HRDCode;
      call := DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
      startdate := DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsDateTime;
      starttime := DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsDateTime;
      freq := DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
      mode := DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;
      rsts := DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
      rstr := DBGrid1.DataSource.DataSet.FieldByName('QSOReportRecived').AsString;
      locat := DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;
      qslinf := SetQSLInfo;
      information := 1;
      inform := 1;
      //OnEQSLSent := @EQSLSent;
      Resume;
    end;
  end;
end;

procedure TMainForm.MenuItem38Click(Sender: TObject);
begin
  if LogBookQuery.RecordCount > 0 then
  begin
    SendEQSLThread := TSendEQSLThread.Create;
    if Assigned(SendEQSLThread.FatalException) then
      raise SendEQSLThread.FatalException;
    with SendEQSLThread do
    begin
      userid := eQSLccLogin;
      userpwd := eQSLccPassword;
      call := DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
      startdate := DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsDateTime;
      starttime := DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsDateTime;
      freq := DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
      mode := DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;
      rst := DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
      qslinf := SetQSLInfo;
      information := 1;
      //OnEQSLSent := @EQSLSent;
      Resume;
    end;
  end;
end;

procedure TMainForm.MenuItem40Click(Sender: TObject);
begin
  ///Быстрое редактирование
  if LogBookQuery.RecordCount > 0 then
  begin
    EditFlag := True;
    CheckBox1.Checked := False;
    CheckBox2.Checked := True;
    EditButton1.Font.Color := clBlack;
    EditButton1.Color := clRed;
    EditButton1.Text := DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
    Edit1.Text := DBGrid1.DataSource.DataSet.FieldByName('OMName').AsString;
    Edit2.Text := DBGrid1.DataSource.DataSet.FieldByName('OMQTH').AsString;
    Edit3.Text := DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;
    Edit4.Text := DBGrid1.DataSource.DataSet.FieldByName('State').AsString;
    Edit5.Text := DBGrid1.DataSource.DataSet.FieldByName('IOTA').AsString;
    Edit6.Text := DBGrid1.DataSource.DataSet.FieldByName('QSLManager').AsString;
    ComboBox1.Text := DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
    ComboBox2.Items.IndexOf(DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString);
    DateTimePicker1.Time := DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsDateTime;
    DateEdit1.Date := DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsDateTime;
    Edit11.Text := DBGrid1.DataSource.DataSet.FieldByName('QSOAddInfo').AsString;
    Edit10.Text := DBGrid1.DataSource.DataSet.FieldByName('State1').AsString;
    Edit9.Text := DBGrid1.DataSource.DataSet.FieldByName('State2').AsString;
    Edit8.Text := DBGrid1.DataSource.DataSet.FieldByName('State3').AsString;
    Edit7.Text := DBGrid1.DataSource.DataSet.FieldByName('State4').AsString;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'G' then
      ComboBox6.ItemIndex := 5;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'B' then
      ComboBox6.ItemIndex := 1;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'D' then
      ComboBox6.ItemIndex := 2;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'E' then
      ComboBox6.ItemIndex := 3;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'M' then
      ComboBox6.ItemIndex := 4;
    if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = '' then
      ComboBox6.ItemIndex := 0;
    ComboBox4.Text := DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
    ComboBox5.Text := DBGrid1.DataSource.DataSet.FieldByName(
      'QSOReportRecived').AsString;
  end;
end;

procedure TMainForm.MenuItem41Click(Sender: TObject);
begin
  ManagerBasePrefixForm.Show;
end;

procedure TMainForm.MenuItem42Click(Sender: TObject);
begin
  if LogBookQuery.RecordCount > 0 then
  begin
    if DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString <> '' then
    begin
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      EditQSO_Form.Edit1.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
      EditQSO_Form.DateEdit1.Date :=
        DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsDateTime;
      EditQSO_Form.DateTimePicker1.Time :=
        StrToTime(DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsString);
      EditQSO_Form.Edit1.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
      EditQSO_Form.Edit4.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('OMName').AsString;
      EditQSO_Form.Edit5.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('OMQTH').AsString;
      EditQSO_Form.Edit17.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('State').AsString;
      EditQSO_Form.Edit14.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;
      EditQSO_Form.Edit2.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
      EditQSO_Form.Edit3.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('QSOReportRecived').AsString;
      EditQSO_Form.Edit18.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('IOTA').AsString;
      EditQSO_Form.DateEdit3.Date :=
        DBGrid1.DataSource.DataSet.FieldByName('QSLSentDate').AsDateTime;
      EditQSO_Form.DateEdit2.Date :=
        DBGrid1.DataSource.DataSet.FieldByName('QSLRecDate').AsDateTime;
      EditQSO_Form.DateEdit4.Date :=
        DBGrid1.DataSource.DataSet.FieldByName('LoTWRecDate').AsDateTime;
      EditQSO_Form.Edit8.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('MainPrefix').AsString;
      EditQSO_Form.Edit7.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('DXCCPrefix').AsString;
      EditQSO_Form.Edit6.Text := DBGrid1.DataSource.DataSet.FieldByName('DXCC').AsString;
      EditQSO_Form.Edit15.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('CQZone').AsString;
      EditQSO_Form.Edit16.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('ITUZone').AsString;
      EditQSO_Form.CheckBox3.Checked :=
        DBGrid1.DataSource.DataSet.FieldByName('Marker').AsBoolean;
      EditQSO_Form.DBLookupComboBox3.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;

      //EditQSO_Form.DBLookupComboBox4.Text :=
      //  dmFunc.GetAdifBandFromFreq(DBGrid1.DataSource.DataSet.FieldByName(
      //  'QSOBand').AsString);
      EditQSO_Form.ComboBox1.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;

      EditQSO_Form.Edit13.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('Continent').AsString;
      EditQSO_Form.Edit20.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('QSLInfo').AsString;
      EditQSO_Form.CheckBox2.Checked :=
        DBGrid1.DataSource.DataSet.FieldByName('ValidDX').AsBoolean;
      EditQSO_Form.Edit19.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('QSLManager').AsString;
      EditQSO_Form.Edit10.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('State1').AsString;
      EditQSO_Form.Edit9.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('State2').AsString;
      EditQSO_Form.Edit11.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('State3').AsString;
      EditQSO_Form.Edit12.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('State4').AsString;
      EditQSO_Form.Memo1.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('QSOAddInfo').AsString;
      EditQSO_Form.CheckBox1.Checked :=
        DBGrid1.DataSource.DataSet.FieldByName('NoCalcDXCC').AsBoolean;
      EditQSO_Form.CheckBox5.Checked :=
        DBGrid1.DataSource.DataSet.FieldByName('QSLReceQSLcc').AsBoolean;
      EditQSO_Form.CheckBox4.Checked :=
        DBGrid1.DataSource.DataSet.FieldByName('QSLRec').AsBoolean;
      EditQSO_Form.CheckBox6.Checked :=
        DBGrid1.DataSource.DataSet.FieldByName('LoTWRec').AsBoolean;

      if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'G' then
        EditQSO_Form.ComboBox6.ItemIndex := 5;
      if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'B' then
        EditQSO_Form.ComboBox6.ItemIndex := 1;
      if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'D' then
        EditQSO_Form.ComboBox6.ItemIndex := 2;
      if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'E' then
        EditQSO_Form.ComboBox6.ItemIndex := 3;
      if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = 'M' then
        EditQSO_Form.ComboBox6.ItemIndex := 4;
      if DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString = '' then
        EditQSO_Form.ComboBox6.ItemIndex := 0;

      if DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString = 'G' then
        EditQSO_Form.ComboBox7.ItemIndex := 5;
      if DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString = 'B' then
        EditQSO_Form.ComboBox7.ItemIndex := 1;
      if DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString = 'D' then
        EditQSO_Form.ComboBox7.ItemIndex := 2;
      if DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString = 'E' then
        EditQSO_Form.ComboBox7.ItemIndex := 3;
      if DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString = 'M' then
        EditQSO_Form.ComboBox7.ItemIndex := 4;
      if DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString = '' then
        EditQSO_Form.ComboBox7.ItemIndex := 0;

      if DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString = 'P' then
        EditQSO_Form.RadioButton2.Checked := True;
      if DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString = 'T' then
        EditQSO_Form.RadioButton1.Checked := True;
      if DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString = 'Q' then
        EditQSO_Form.RadioButton3.Checked := True;
      if DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString = 'F' then
        EditQSO_Form.RadioButton4.Checked := True;
      if DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString = 'N' then
        EditQSO_Form.RadioButton5.Checked := True;

      EditQSO_Form.DBLookupComboBox1.KeyValue :=
        DBGrid1.DataSource.DataSet.FieldByName('PROP_MODE').AsString;

      EditQSO_Form.Show;
    end;
  end;
end;

procedure TMainForm.MenuItem43Click(Sender: TObject);
var
  p: integer;
  wsjt_args: string;
begin

  //WSJT_UDP_Form.Show;
  //ShowMEssage(BoolToStr( WSJT_UDP_Form.WSJT_IsRunning));
  p := Pos('.EXE', UpperCase(wsjt_path));
  if p > 0 then
  begin
    wsjt_args := wsjt_path;
    wsjt_path := Copy(wsjt_args, 1, p + 3);
    Delete(wsjt_args, 1, p + 4);
  end;
  if (wsjt_path <> '') and FileExists(wsjt_path) and not
    WSJT_UDP_Form.WSJT_IsRunning then
  begin
    txWSJT := not connectedWSJT;
    if dmFunc.RunProgram(wsjt_path, wsjt_args) then
      WSJT_Timer.Interval := 1200;
  end;
end;

procedure TMainForm.MenuItem46Click(Sender: TObject);
begin
  //будет экспорт в Excel
end;

procedure TMainForm.MenuItem48Click(Sender: TObject);
begin
  SynDBDate.Show;
end;

procedure TMainForm.MenuItem49Click(Sender: TObject);
var
  freq, call, cname, mode, rsts, grid: string;
  freq2: double;
begin
  call := DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
  cname := DBGrid1.DataSource.DataSet.FieldByName('OMName').AsString;
  mode := DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;
  rsts := DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
  grid := DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;
  freq := DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
  Delete(freq, length(freq) - 2, 1);
  freq2 := StrToFloat(freq);
  SendSpot(FloatToStr(freq2 * 1000), call, cname, mode, rsts, grid);
end;

procedure TMainForm.MenuItem51Click(Sender: TObject);
begin
  if LogBookQuery.RecordCount > 0 then
  begin
    if Application.MessageBox(PChar('Удалить запись ' +
      DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString + '?!'),
      'Внимание!', MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
    begin
      try
        with DeleteQSOQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add('DELETE FROM ' + LogTable + ' WHERE UnUsedIndex = ' +
            IntToStr(DBGrid1.DataSource.DataSet.FieldByName(
            'UnUsedIndex').AsInteger) + ';');
          ExecSQL;
        end;
      finally
        SQLTransaction1.Commit;
        SelDB(CallLogBook);
      end;
    end;
  end;
end;

procedure TMainForm.MenuItem52Click(Sender: TObject);
begin
  ConfigForm.Show;
end;

procedure TMainForm.MenuItem53Click(Sender: TObject);
begin
  ExportAdifForm.Show();
end;

procedure TMainForm.MenuItem55Click(Sender: TObject);
begin
  DBLookupComboBox1.SetFocus;
  DBLookupComboBox1.DroppedDown := True;
end;

procedure TMainForm.MenuItem56Click(Sender: TObject);
begin
  CreateJournalForm.Show;
end;

procedure TMainForm.MenuItem60Click(Sender: TObject);
begin
  ServiceForm.Show;
end;

procedure TMainForm.MenuItem63Click(Sender: TObject);
begin
  thanks_form.Show;
end;

procedure TMainForm.MenuItem65Click(Sender: TObject);
begin
  SpeedButton9.Click;
end;

procedure TMainForm.MenuItem66Click(Sender: TObject);
begin
  SpeedButton8.Click;
end;

procedure TMainForm.MenuItem69Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainForm.MenuItem70Click(Sender: TObject);
begin
  ImportADIFForm.Show;
end;

procedure TMainForm.MenuItem72Click(Sender: TObject);
begin
  Panel4.Hide;
  Panel5.Hide;
  Panel6.Hide;
  MainForm.Height := 290;
end;

procedure TMainForm.MenuItem73Click(Sender: TObject);
begin
  Panel4.Show;
  Panel5.Show;
  Panel6.Show;
  MainForm.Height := 672;
end;

//Запуск fldigi
procedure TMainForm.MenuItem74Click(Sender: TObject);
var
  p: integer;
  fl_args: string;
begin
  p := Pos('.EXE', UpperCase(fl_path));
  if p > 0 then
  begin
    fl_args := fl_path;
    fl_path := Copy(fl_args, 1, p + 3);
    Delete(fl_args, 1, p + 4);
  end;
  if (fl_path <> '') and FileExists(fl_path) and not Fldigi_IsRunning then
  begin
    tx := not connected;
    if dmFunc.RunProgram(fl_path, fl_args) then
      Fl_Timer.Interval := 1200;
  end;
end;

procedure TMainForm.MenuItem7Click(Sender: TObject);
begin
  LogConfigForm.Show;
end;

//Синхронизация из MySQL в SQLite
procedure TMainForm.MenuItem82Click(Sender: TObject);
var
  LogTableSQLite: string;
  err, ok: integer;
begin
  try
    Application.ProcessMessages;
    err := 0;
    ok := 0;
    with CopySQLQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Text := 'SELECT LogTable FROM LogBookInfo WHERE CallName =' +
        '''' + CallLogBook + '''';
      Open;
      LogTableSQLite := FieldByName('LogTable').AsString;
      Close;
    end;

    DBGrid1.DataSource.DataSet.First;

    while not DBGrid1.DataSource.DataSet.EOF do
    begin
      DUPEQuery.Close;
      DUPEQuery.SQL.Clear;
      DUPEQuery.SQL.Text := 'SELECT COUNT(*) FROM ' + LogTableSQLite +
        ' WHERE strftime(''%d.%m.%Y'',QSODate) = ' + QuotedStr(
        FormatDateTime('dd.mm.yyyy', DBGrid1.DataSource.DataSet.FieldByName(
        'QSODate').AsDateTime)) + ' AND QSOTime = ' +
        QuotedStr(DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsString) +
        ' AND CallSign = ' + QuotedStr(DBGrid1.DataSource.DataSet.FieldByName(
        'CallSign').AsString);
      DUPEQuery.Open;
      if DUPEQuery.Fields.Fields[0].AsInteger > 0 then
      begin
        Application.ProcessMessages;
        SQLiteTr.Rollback;
        Inc(err);
        StatusBar1.Panels.Items[0].Text := 'Дубликаты: ' + IntToStr(err);
      end
      else
      begin
        with CopySQLQuery do
        begin
          Application.ProcessMessages;
          Close;
          SQL.Clear;
          SQL.Add('INSERT INTO ' + LogTableSQLite +
            '(`UnUsedIndex`, `CallSign`, `QSODate`, `QSOTime`, `QSOBand`, `QSOMode`, ' +
            '`QSOReportSent`, `QSOReportRecived`, `OMName`, `OMQTH`, `State`, `Grid`, `IOTA`,'
            + '`QSLManager`, `QSLSent`, `QSLSentAdv`, `QSLSentDate`, `QSLRec`, `QSLRecDate`,'
            + '`MainPrefix`, `DXCCPrefix`, `CQZone`, `ITUZone`, `QSOAddInfo`, `Marker`, `ManualSet`,'
            + '`DigiBand`, `Continent`, `ShortNote`, `QSLReceQSLcc`, `LoTWRec`, `LoTWRecDate`,'
            + '`QSLInfo`, `Call`, `State1`, `State2`, `State3`, `State4`, `WPX`, `AwardsEx`, '
            + '`ValidDX`, `SRX`, `SRX_STRING`, `STX`, `STX_STRING`, `SAT_NAME`, `SAT_MODE`,'
            + '`PROP_MODE`, `LoTWSent`, `QSL_RCVD_VIA`, `QSL_SENT_VIA`, `DXCC`, `USERS`, `NoCalcDXCC`)'
            + 'VALUES (:IUnUsedIndex, :ICallSign, :IQSODate, :IQSOTime, :IQSOBand, :IQSOMode, :IQSOReportSent,'
            + ':IQSOReportRecived, :IOMName, :IOMQTH, :IState, :IGrid, :IIOTA, :IQSLManager, :IQSLSent,'
            + ':IQSLSentAdv, :IQSLSentDate, :IQSLRec, :IQSLRecDate, :IMainPrefix, :IDXCCPrefix, :ICQZone,'
            + ':IITUZone, :IQSOAddInfo, :IMarker, :IManualSet, :IDigiBand, :IContinent, :IShortNote,'
            + ':IQSLReceQSLcc, :ILoTWRec, :ILoTWRecDate, :IQSLInfo, :ICall, :IState1, :IState2, :IState3, :IState4,'
            + ':IWPX, :IAwardsEx, :IValidDX, :ISRX, :ISRX_STRING, :ISTX, :ISTX_STRING, :ISAT_NAME,'
            + ':ISAT_MODE, :IPROP_MODE, :ILoTWSent, :IQSL_RCVD_VIA, :IQSL_SENT_VIA, :IDXCC, :IUSERS, :INoCalcDXCC)');
          Prepare;
          Params.ParamByName('IUnUsedIndex').AsInteger :=
            DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
          Params.ParamByName('ICallSign').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
          Params.ParamByName('IQSODate').AsDateTime :=
            DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsDateTime;
          Params.ParamByName('IQSOTime').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsString;
          Params.ParamByName('IQSOBand').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
          Params.ParamByName('IQSOMode').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;
          Params.ParamByName('IQSOReportSent').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
          Params.ParamByName('IQSOReportRecived').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('QSOReportRecived').AsString;
          Params.ParamByName('IOMName').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('OMName').AsString;
          Params.ParamByName('IOMQTH').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('OMQTH').AsString;
          Params.ParamByName('IState').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('State').AsString;
          Params.ParamByName('IGrid').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;
          Params.ParamByName('IIOTA').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('IOTA').AsString;
          Params.ParamByName('IQSLManager').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('QSLManager').AsString;
          Params.ParamByName('IQSLSent').AsInteger :=
            DBGrid1.DataSource.DataSet.FieldByName('QSLSent').AsInteger;
          Params.ParamByName('IQSLSentAdv').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString;

          if DBGrid1.DataSource.DataSet.FieldByName('QSLSentDate').IsNull = True then
            Params.ParamByName('IQSLSentDate').IsNull
          else
            Params.ParamByName('IQSLSentDate').AsDate :=
              DBGrid1.DataSource.DataSet.FieldByName('QSLSentDate').AsDateTime;

          Params.ParamByName('IQSLRec').AsInteger :=
            DBGrid1.DataSource.DataSet.FieldByName('QSLRec').AsInteger;

          if DBGrid1.DataSource.DataSet.FieldByName('QSLRecDate').IsNull = True then
            Params.ParamByName('IQSLRecDate').IsNull
          else
            Params.ParamByName('IQSLRecDate').AsDate :=
              DBGrid1.DataSource.DataSet.FieldByName('QSLRecDate').AsDateTime;

          Params.ParamByName('IMainPrefix').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('MainPrefix').AsString;
          Params.ParamByName('IDXCCPrefix').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('DXCCPrefix').AsString;
          Params.ParamByName('ICQZone').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('CQZone').AsString;
          Params.ParamByName('IITUZone').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('ITUZone').AsString;
          Params.ParamByName('IQSOAddInfo').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('QSOAddInfo').AsString;
          Params.ParamByName('IMarker').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('Marker').AsString;
          Params.ParamByName('IManualSet').AsInteger :=
            DBGrid1.DataSource.DataSet.FieldByName('ManualSet').AsInteger;
          Params.ParamByName('IDigiBand').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('DigiBand').AsString;
          Params.ParamByName('IContinent').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('Continent').AsString;
          Params.ParamByName('IShortNote').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('ShortNote').AsString;
          Params.ParamByName('IQSLReceQSLcc').AsInteger :=
            DBGrid1.DataSource.DataSet.FieldByName('QSLReceQSLcc').AsInteger;
          Params.ParamByName('ILoTWRec').AsInteger :=
            DBGrid1.DataSource.DataSet.FieldByName('LoTWRec').AsInteger;

          if DBGrid1.DataSource.DataSet.FieldByName('LoTWRecDate').IsNull = True then
            Params.ParamByName('ILoTWRecDate').IsNull
          else
            Params.ParamByName('ILoTWRecDate').AsDate :=
              DBGrid1.DataSource.DataSet.FieldByName('LoTWRecDate').AsDateTime;

          Params.ParamByName('IQSLInfo').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('QSLInfo').AsString;
          Params.ParamByName('ICall').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('Call').AsString;
          Params.ParamByName('IState1').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('State1').AsString;
          Params.ParamByName('IState2').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('State2').AsString;
          Params.ParamByName('IState3').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('State3').AsString;
          Params.ParamByName('IState4').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('State4').AsString;
          Params.ParamByName('IWPX').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('WPX').AsString;
          Params.ParamByName('IAwardsEx').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('AwardsEx').AsString;
          Params.ParamByName('IValidDX').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('ValidDX').AsString;
          Params.ParamByName('ISRX').AsInteger :=
            DBGrid1.DataSource.DataSet.FieldByName('SRX').AsInteger;
          Params.ParamByName('ISRX_STRING').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('SRX_STRING').AsString;
          Params.ParamByName('ISTX').AsInteger :=
            DBGrid1.DataSource.DataSet.FieldByName('STX').AsInteger;
          Params.ParamByName('ISTX_STRING').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('STX_STRING').AsString;
          Params.ParamByName('ISAT_NAME').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('SAT_NAME').AsString;
          Params.ParamByName('ISAT_MODE').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('SAT_MODE').AsString;
          Params.ParamByName('IPROP_MODE').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('PROP_MODE').AsString;
          Params.ParamByName('ILoTWSent').AsInteger :=
            DBGrid1.DataSource.DataSet.FieldByName('LoTWSent').AsInteger;
          Params.ParamByName('IQSL_RCVD_VIA').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString;
          Params.ParamByName('IQSL_SENT_VIA').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString;
          Params.ParamByName('IDXCC').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('DXCC').AsString;
          Params.ParamByName('IUSERS').AsString :=
            DBGrid1.DataSource.DataSet.FieldByName('USERS').AsString;
          Params.ParamByName('INoCalcDXCC').AsInteger :=
            DBGrid1.DataSource.DataSet.FieldByName('NoCalcDXCC').AsInteger;
          ExecSQL;
        end;
        SQLiteTr.Commit;
        Inc(ok);
      end;
      Application.ProcessMessages;
      DBGrid1.DataSource.DataSet.Next;
    end;
    StatusBar1.Panels.Items[0].Text :=
      'Готово! Количество дубликатов ' +
      IntToStr(err) + ', синхронизировано ' +
      IntToStr(ok) + ' связей';
  except
    ShowMessage(
      'Ошибка при работе с БД. Проверьте подключение и настройки');
  end;
end;

//Синхронизация из SQLite в MySQL
procedure TMainForm.MenuItem83Click(Sender: TObject);
var
  LogTableMySQL: string;
  err, ok: integer;
  copyHost, copyUser, copyPass, copyDB, copyPort: string;
begin
  try
    copyUser := IniF.ReadString('DataBases', 'LoginName', '');
    copyPass := IniF.ReadString('DataBases', 'Password', '');
    copyHost := IniF.ReadString('DataBases', 'HostAddr', '');
    copyPort := IniF.ReadString('DataBases', 'Port', '');
    copyDB := IniF.ReadString('DataBases', 'DataBaseName', '');

    if (copyUser = '') or (copyHost = '') or (copyDB = '') then
    begin
      ShowMessage('Не настроены параметры базы данных MySQL');
    end
    else
    begin
      MySQLLOGDBConnection.HostName := copyHost;
      MySQLLOGDBConnection.Port := StrToInt(copyPort);
      MySQLLOGDBConnection.UserName := copyUser;
      MySQLLOGDBConnection.Password := copyPass;
      MySQLLOGDBConnection.DatabaseName := copyDB;
      MySQLLOGDBConnection.Connected := True;
      MySQLLOGDBConnection.Transaction := SQLiteTr;
      SQLiteTr.DataBase := MySQLLOGDBConnection;
      CopySQLQuery2.Transaction := SQLiteTr;
      DUPEQuery2.Transaction := SQLiteTr;
      Application.ProcessMessages;
      err := 0;
      ok := 0;
      with CopySQLQuery2 do
      begin
        Close;
        SQL.Clear;
        SQL.Text := 'SELECT LogTable FROM LogBookInfo WHERE CallName =' +
          '''' + CallLogBook + '''';
        Open;
        LogTableMySQL := FieldByName('LogTable').AsString;
        Close;
      end;

      DBGrid1.DataSource.DataSet.First;

      while not DBGrid1.DataSource.DataSet.EOF do
      begin
        DUPEQuery2.Close;
        DUPEQuery2.SQL.Clear;
        DUPEQuery2.SQL.Text :=
          'SELECT COUNT(*) FROM ' + LogTableMySQL +
          ' WHERE DATE_FORMAT(QSODate, ''%d.%m.%Y'') = ' + QuotedStr(
          FormatDateTime('dd.mm.yyyy', DBGrid1.DataSource.DataSet.FieldByName(
          'QSODate').AsDateTime)) + ' AND QSOTime = ' +
          QuotedStr(DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsString) +
          ' AND CallSign = ' + QuotedStr(DBGrid1.DataSource.DataSet.FieldByName(
          'CallSign').AsString);
        DUPEQuery2.Open;
        if DUPEQuery2.Fields.Fields[0].AsInteger > 0 then
        begin
          Application.ProcessMessages;
          SQLiteTr.Rollback;
          Inc(err);
          StatusBar1.Panels.Items[0].Text := 'Дубликаты: ' + IntToStr(err);
        end
        else
        begin
          with CopySQLQuery2 do
          begin
            Application.ProcessMessages;
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO ' + LogTableMySQL +
              '(`UnUsedIndex`, `CallSign`, `QSODate`, `QSOTime`, `QSOBand`, `QSOMode`, '
              +
              '`QSOReportSent`, `QSOReportRecived`, `OMName`, `OMQTH`, `State`, `Grid`, `IOTA`,'
              + '`QSLManager`, `QSLSent`, `QSLSentAdv`, `QSLSentDate`, `QSLRec`, `QSLRecDate`,'
              + '`MainPrefix`, `DXCCPrefix`, `CQZone`, `ITUZone`, `QSOAddInfo`, `Marker`, `ManualSet`,'
              + '`DigiBand`, `Continent`, `ShortNote`, `QSLReceQSLcc`, `LoTWRec`, `LoTWRecDate`,'
              + '`QSLInfo`, `Call`, `State1`, `State2`, `State3`, `State4`, `WPX`, `AwardsEx`, '
              + '`ValidDX`, `SRX`, `SRX_STRING`, `STX`, `STX_STRING`, `SAT_NAME`, `SAT_MODE`,'
              + '`PROP_MODE`, `LoTWSent`, `QSL_RCVD_VIA`, `QSL_SENT_VIA`, `DXCC`, `USERS`, `NoCalcDXCC`)'
              + 'VALUES (:IUnUsedIndex, :ICallSign, :IQSODate, :IQSOTime, :IQSOBand, :IQSOMode, :IQSOReportSent,'
              + ':IQSOReportRecived, :IOMName, :IOMQTH, :IState, :IGrid, :IIOTA, :IQSLManager, :IQSLSent,'
              + ':IQSLSentAdv, :IQSLSentDate, :IQSLRec, :IQSLRecDate, :IMainPrefix, :IDXCCPrefix, :ICQZone,'
              + ':IITUZone, :IQSOAddInfo, :IMarker, :IManualSet, :IDigiBand, :IContinent, :IShortNote,'
              + ':IQSLReceQSLcc, :ILoTWRec, :ILoTWRecDate, :IQSLInfo, :ICall, :IState1, :IState2, :IState3, :IState4,'
              + ':IWPX, :IAwardsEx, :IValidDX, :ISRX, :ISRX_STRING, :ISTX, :ISTX_STRING, :ISAT_NAME,'
              + ':ISAT_MODE, :IPROP_MODE, :ILoTWSent, :IQSL_RCVD_VIA, :IQSL_SENT_VIA, :IDXCC, :IUSERS, :INoCalcDXCC)');
            Prepare;
            Params.ParamByName('IUnUsedIndex').AsInteger :=
              DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
            Params.ParamByName('ICallSign').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
            Params.ParamByName('IQSODate').AsDateTime :=
              DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsDateTime;
            Params.ParamByName('IQSOTime').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsString;
            Params.ParamByName('IQSOBand').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
            Params.ParamByName('IQSOMode').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;
            Params.ParamByName('IQSOReportSent').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
            Params.ParamByName('IQSOReportRecived').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('QSOReportRecived').AsString;
            Params.ParamByName('IOMName').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('OMName').AsString;
            Params.ParamByName('IOMQTH').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('OMQTH').AsString;
            Params.ParamByName('IState').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('State').AsString;
            Params.ParamByName('IGrid').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;
            Params.ParamByName('IIOTA').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('IOTA').AsString;
            Params.ParamByName('IQSLManager').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('QSLManager').AsString;
            Params.ParamByName('IQSLSent').AsInteger :=
              DBGrid1.DataSource.DataSet.FieldByName('QSLSent').AsInteger;
            Params.ParamByName('IQSLSentAdv').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString;

            if DBGrid1.DataSource.DataSet.FieldByName('QSLSentDate').IsNull = True then
              Params.ParamByName('IQSLSentDate').IsNull
            else
              Params.ParamByName('IQSLSentDate').AsDate :=
                DBGrid1.DataSource.DataSet.FieldByName('QSLSentDate').AsDateTime;

            Params.ParamByName('IQSLRec').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('QSLRec').AsString;

            if DBGrid1.DataSource.DataSet.FieldByName('QSLRecDate').IsNull = True then
              Params.ParamByName('IQSLRecDate').IsNull
            else
              Params.ParamByName('IQSLRecDate').AsDate :=
                DBGrid1.DataSource.DataSet.FieldByName('QSLRecDate').AsDateTime;

            Params.ParamByName('IMainPrefix').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('MainPrefix').AsString;
            Params.ParamByName('IDXCCPrefix').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('DXCCPrefix').AsString;
            Params.ParamByName('ICQZone').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('CQZone').AsString;
            Params.ParamByName('IITUZone').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('ITUZone').AsString;
            Params.ParamByName('IQSOAddInfo').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('QSOAddInfo').AsString;
            Params.ParamByName('IMarker').AsInteger :=
              DBGrid1.DataSource.DataSet.FieldByName('Marker').AsInteger;
            Params.ParamByName('IManualSet').AsInteger :=
              DBGrid1.DataSource.DataSet.FieldByName('ManualSet').AsInteger;
            Params.ParamByName('IDigiBand').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('DigiBand').AsString;
            Params.ParamByName('IContinent').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('Continent').AsString;
            Params.ParamByName('IShortNote').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('ShortNote').AsString;
            Params.ParamByName('IQSLReceQSLcc').AsInteger :=
              DBGrid1.DataSource.DataSet.FieldByName('QSLReceQSLcc').AsInteger;
            Params.ParamByName('ILoTWRec').AsInteger :=
              DBGrid1.DataSource.DataSet.FieldByName('LoTWRec').AsInteger;

            if DBGrid1.DataSource.DataSet.FieldByName('LoTWRecDate').IsNull = True then
              Params.ParamByName('ILoTWRecDate').IsNull
            else
              Params.ParamByName('ILoTWRecDate').AsDate :=
                DBGrid1.DataSource.DataSet.FieldByName('LoTWRecDate').AsDateTime;

            Params.ParamByName('IQSLInfo').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('QSLInfo').AsString;
            Params.ParamByName('ICall').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('Call').AsString;
            Params.ParamByName('IState1').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('State1').AsString;
            Params.ParamByName('IState2').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('State2').AsString;
            Params.ParamByName('IState3').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('State3').AsString;
            Params.ParamByName('IState4').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('State4').AsString;
            Params.ParamByName('IWPX').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('WPX').AsString;
            Params.ParamByName('IAwardsEx').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('AwardsEx').AsString;
            Params.ParamByName('IValidDX').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('ValidDX').AsString;
            Params.ParamByName('ISRX').AsInteger :=
              DBGrid1.DataSource.DataSet.FieldByName('SRX').AsInteger;
            Params.ParamByName('ISRX_STRING').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('SRX_STRING').AsString;
            Params.ParamByName('ISTX').AsInteger :=
              DBGrid1.DataSource.DataSet.FieldByName('STX').AsInteger;
            Params.ParamByName('ISTX_STRING').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('STX_STRING').AsString;
            Params.ParamByName('ISAT_NAME').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('SAT_NAME').AsString;
            Params.ParamByName('ISAT_MODE').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('SAT_MODE').AsString;
            Params.ParamByName('IPROP_MODE').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('PROP_MODE').AsString;
            Params.ParamByName('ILoTWSent').AsInteger :=
              DBGrid1.DataSource.DataSet.FieldByName('LoTWSent').AsInteger;
            Params.ParamByName('IQSL_RCVD_VIA').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString;
            Params.ParamByName('IQSL_SENT_VIA').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString;
            Params.ParamByName('IDXCC').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('DXCC').AsString;
            Params.ParamByName('IUSERS').AsString :=
              DBGrid1.DataSource.DataSet.FieldByName('USERS').AsString;
            Params.ParamByName('INoCalcDXCC').AsInteger :=
              DBGrid1.DataSource.DataSet.FieldByName('NoCalcDXCC').AsInteger;
            ExecSQL;
          end;
          SQLiteTr.Commit;
          Inc(ok);
        end;
        Application.ProcessMessages;
        DBGrid1.DataSource.DataSet.Next;
      end;
      StatusBar1.Panels.Items[0].Text :=
        'Готово! Количество дубликатов ' +
        IntToStr(err) + ', синхронизировано ' +
        IntToStr(ok) + ' связей';
    end;
  except
    ShowMessage(
      'Ошибка при работе с БД. Проверьте подключение и настройки');
  end;
end;

procedure TMainForm.MenuItem84Click(Sender: TObject);
begin
  SettingsCAT.Show;
end;

procedure TMainForm.MenuItem86Click(Sender: TObject);
begin
  MenuItem88.Checked := False;
  if MenuItem86.Checked = True then
  begin
    TRXForm.Parent := Panel13;
    TRXForm.BorderStyle := bsNone;
    TRXForm.Align := alClient;
    TRXForm.Show;
    ShowTRXForm := True;
    //TRXForm.Show;
  end
  else
    TRXForm.Hide;

end;

procedure TMainForm.MenuItem87Click(Sender: TObject);
begin
  SettingsProgramForm.Show;
end;

procedure TMainForm.MenuItem88Click(Sender: TObject);
begin
  MenuItem86.Checked := False;
  MenuItem88.Checked := True;
  ShowTRXForm := False;
  TRXForm.Hide;
end;

procedure TMainForm.MenuItem89Click(Sender: TObject);
begin
  if dbSel = 'SQLite' then
  begin
    InitializeDB('MySQL');
    MenuItem89.Caption := 'Переключить базу на SQLite';
  end
  else
  begin
    InitializeDB('SQLite');
    MenuItem89.Caption := 'Переключить базу на MySQL';
  end;
end;

procedure TMainForm.MenuItem91Click(Sender: TObject);
begin
  SetupForm.Show;
end;

procedure TMainForm.MenuItem92Click(Sender: TObject);
begin
  Update_Form.Show;
end;

procedure TMainForm.MenuItem94Click(Sender: TObject);
begin
  About_Form.Show;
end;

procedure TMainForm.MenuItem95Click(Sender: TObject);
begin
  Hide;
  StayForm := False;
end;

procedure TMainForm.MenuItem96Click(Sender: TObject);
begin
  Show;
  StayForm := True;
end;

procedure TMainForm.MenuItem98Click(Sender: TObject);
begin
  MainForm.Close;
end;

procedure TMainForm.MenuItem99Click(Sender: TObject);
begin
  ConfigGrid_Form.Show;
end;

procedure TMainForm.MySQLLOGDBConnectionAfterConnect(Sender: TObject);
begin
  if MySQLLOGDBConnection.Connected = False then
  begin
    EditButton1.ReadOnly := True;
  end
  else
  begin
    EditButton1.ReadOnly := False;
    DBGrid1.PopupMenu := PopupMenu1;
  end;
end;

procedure TMainForm.Panel10Click(Sender: TObject);
begin

end;

procedure TMainForm.sgClusterDblClick(Sender: TObject);
begin
  EditButton1.Text := sgCluster.Cells[1, sgCluster.Row];
end;

procedure TMainForm.SpeedButton16Click(Sender: TObject);
begin
  CheckForm := 'Main';
  if EditButton1.Text <> '' then
    InformationForm.Show
  else
    ShowMessage('Не введён позывной для просмотра');
end;

procedure TMainForm.SpeedButton17Click(Sender: TObject);
begin
  PopupMenu2.PopUp;
end;

procedure TMainForm.SpeedButton18Click(Sender: TObject);
begin
  Login(HostCluster, PortCluster, LoginCluster, PasswordCluster);
end;

procedure TMainForm.SpeedButton18MouseLeave(Sender: TObject);
begin
  StatusBar1.Panels.Items[0].Text := '';
end;

procedure TMainForm.SpeedButton18MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  StatusBar1.Panels.Items[0].Text :=
    'Соедениться с Telnet кластером';
end;

procedure TMainForm.SpeedButton19Click(Sender: TObject);
begin
  ClusterServer_Form.Show;
end;

procedure TMainForm.SpeedButton1Click(Sender: TObject);
begin
  STATE_Form.Show;
  STATE_Form.Edit1.Text := Edit4.Text;
end;

procedure TMainForm.SpeedButton20Click(Sender: TObject);
begin
  with sgCluster do
  begin
    RowCount := 1;
  end;
end;

procedure TMainForm.SpeedButton20MouseLeave(Sender: TObject);
begin
  StatusBar1.Panels.Items[0].Text := '';
end;

procedure TMainForm.SpeedButton20MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  StatusBar1.Panels.Items[0].Text := 'Очистить окно кластера';
end;

procedure TMainForm.SpeedButton21Click(Sender: TObject);
begin
  cluster.Send('quit' + #13#10);
  Memo1.Append('Вы отключены от DX кластера');
  SpeedButton21.Enabled := False;
  SpeedButton27.Enabled := False;
  SpeedButton18.Enabled := True;
  SpeedButton24.Enabled := True;
  SpeedButton28.Enabled := False;
  SpeedButton22.Enabled := False;
  Timer2.Enabled := False;
end;

procedure TMainForm.SpeedButton21MouseLeave(Sender: TObject);
begin
  StatusBar1.Panels.Items[0].Text := '';
end;

procedure TMainForm.SpeedButton21MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  StatusBar1.Panels.Items[0].Text := 'Отключится от Telnet кластера';
end;

procedure TMainForm.SpeedButton22Click(Sender: TObject);
begin
  SendTelnetSpot.Show;
end;

procedure TMainForm.SpeedButton22MouseLeave(Sender: TObject);
begin
  StatusBar1.Panels.Items[0].Text := '';
end;

procedure TMainForm.SpeedButton22MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  StatusBar1.Panels.Items[0].Text := 'Отправить спот';
end;

procedure TMainForm.SpeedButton23Click(Sender: TObject);
begin
  ClusterFilter.Show;
end;

procedure TMainForm.SpeedButton26Click(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TMainForm.SpeedButton2Click(Sender: TObject);
begin
  IOTA_Form.Edit1.Text := Edit5.Text;
  IOTA_Form.Show;
end;

procedure TMainForm.SpeedButton3Click(Sender: TObject);
begin
  QSLManager_Form.Show;
end;

procedure TMainForm.SpeedButton8Click(Sender: TObject);
var
  QSL_SENT_ADV, dift: string;
  DigiBand: double;
  NameBand: string;
  timeQSO: TTime;
  FmtStngs: TFormatSettings;
  state: string;
begin
  FmtStngs.TimeSeparator := ':';
  FmtStngs.LongTimeFormat := 'hh:nn';
  if EditFlag = False then
  begin
    dift := FormatDateTime('hh', Now - NowUTC);
    if CheckBox2.Checked = True then
    begin
      timeQSO := DateTimePicker1.Time - StrToTime(dift);
    end
    else
      timeQSO := DateTimePicker1.Time;

    if EditButton1.Text = '' then
      ShowMessage('Необходимо ввести позывной')
    else
    begin

      if ComboBox7.ItemIndex = 0 then
        QSL_SENT_ADV := 'T';
      if ComboBox7.ItemIndex = 1 then
        QSL_SENT_ADV := 'P';
      if ComboBox7.ItemIndex = 2 then
        QSL_SENT_ADV := 'Q';
      if ComboBox7.ItemIndex = 3 then
        QSL_SENT_ADV := 'F';
      if ComboBox7.ItemIndex = 4 then
        QSL_SENT_ADV := 'N';

      if IniF.ReadString('SetLog', 'ShowBand', '') = 'True' then
      NameBand:=dmFunc.FreqFromBand(ComboBox1.Text, ComboBox2.Text)
      else
      NameBand:=ComboBox1.Text;

      DigiBand := dmFunc.GetDigiBandFromFreq(NameBand);

      if Edit13.Text <> '' then
        state := Edit4.Text + '-' + Edit13.Text;
      if Edit13.Text = '' then
        state := Edit4.Text;

      SaveQSO(EditButton1.Text, DateEdit1.Date, FormatDateTime('hh:nn', timeQSO),
        NameBand, ComboBox2.Text, ComboBox4.Text,
        ComboBox5.Text,
        Edit1.Text, Edit2.Text,
        state,
        Edit3.Text, Edit5.Text,
        Edit6.Text, IntToStr(0), QSL_SENT_ADV, 'NULL', '0', 'NULL', Label38.Caption,
        Label34.Caption,
        Label45.Caption, Label47.Caption, Edit11.Text, BoolToStr(CheckBox5.Checked), 0,
        FloatToStr(DigiBand),
        Label43.Caption, Edit11.Text, 0, '', 'NULL', SetQSLInfo,
        EditButton1.Text, Edit10.Text, Edit9.Text, Edit8.Text, Edit7.Text,
        Label38.Caption, 'NULL',
        IntToStr(1), 0, '', 0, '', '', '', '', 0, '', ComboBox6.Text,
        IntToStr(DXCCNum), '', 0,
        LogTable);//, IntToStr(lastID + 1));

      if AutoEQSLcc = True then
      begin
        SendEQSLThread := TSendEQSLThread.Create;
        if Assigned(SendEQSLThread.FatalException) then
          raise SendEQSLThread.FatalException;
        with SendEQSLThread do
        begin
          userid := eQSLccLogin;
          userpwd := eQSLccPassword;
          call := EditButton1.Text;
          startdate := DateEdit1.Date;
          starttime := DateTimePicker1.Time;
          freq := NameBand;
          mode := ComboBox2.Text;
          rst := ComboBox4.Text;
          qslinf := SetQSLInfo;
          //OnEQSLSent := @EQSLSent;
          Resume;
        end;
      end;

      if AutoHRDLog = True then
      begin
        SendHRDThread := TSendHRDThread.Create;
        if Assigned(SendHRDThread.FatalException) then
          raise SendHRDThread.FatalException;
        with SendHRDThread do
        begin
          userid := HRDLogin;
          userpwd := HRDCode;
          call := EditButton1.Text;
          startdate := DateEdit1.Date;
          starttime := DateTimePicker1.Time;
          freq := NameBand;
          mode := ComboBox2.Text;
          rsts := ComboBox4.Text;
          rstr := ComboBox5.Text;
          locat := Edit3.Text;
          qslinf := SetQSLInfo;
          //OnEQSLSent := @EQSLSent;
          Resume;
        end;
      end;

      SelDB(CallLogBook);
      Clr();
    end;
  end;

  if EditFlag = True then
  begin

    DigiBand := dmFunc.GetDigiBandFromFreq(NameBand);

    with SaveQSOQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('UPDATE ' + LogTable +
        ' SET `CallSign`=:CallSign, `QSODate`=:QSODate, ' +
        '`QSOTime`=:QSOTime, `QSOBand`=:QSOBand, `QSOMode`=:QSOMode,' +
        '`QSOReportSent`=:QSOReportSent, `QSOReportRecived`=:QSOReportRecived,' +
        '`OMName`=:OMName, `OMQTH`=:OMQTH, `State`=:State, `Grid`=:Grid,' +
        '`IOTA`=:IOTA, `QSLManager`=:QSLManager, `QSOAddInfo`=:QSOAddInfo,' +
        '`DigiBand`=:DigiBand, `ShortNote`=:ShortNote,' +
        '`Call`=:Call, `State1`=:State1, `State2`=:State2,' +
        '`State3`=:State3, `State4`=:State4, `QSL_SENT_VIA`=:QSL_SENT_VIA' +
        ' WHERE `UnUsedIndex`=:UnUsedIndex');
      Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
      Params.ParamByName('CallSign').AsString := EditButton1.Text;
      Params.ParamByName('QSODate').AsDateTime := DateEdit1.Date;
      Params.ParamByName('QSOTime').AsString :=
        TimeToStr(DateTimePicker1.Time, FmtStngs);
      Params.ParamByName('QSOBand').AsString := NameBand;
      Params.ParamByName('QSOMode').AsString := ComboBox2.Text;
      Params.ParamByName('QSOReportSent').AsString := ComboBox4.Text;
      Params.ParamByName('QSOReportRecived').AsString := ComboBox5.Text;
      Params.ParamByName('OMName').AsString := Edit1.Text;
      Params.ParamByName('OMQTH').AsString := Edit2.Text;
      Params.ParamByName('State').AsString := Edit4.Text;
      Params.ParamByName('Grid').AsString := Edit3.Text;
      Params.ParamByName('IOTA').AsString := Edit5.Text;
      Params.ParamByName('QSLManager').AsString := Edit6.Text;
      Params.ParamByName('QSOAddInfo').AsString := Edit11.Text;
      Params.ParamByName('DigiBand').AsString := FloatToStr(DigiBand);
      Params.ParamByName('ShortNote').AsString := Edit11.Text;
      Params.ParamByName('Call').AsString := EditButton1.Text;
      Params.ParamByName('State1').AsString := Edit10.Text;
      Params.ParamByName('State2').AsString := Edit9.Text;
      Params.ParamByName('State3').AsString := Edit8.Text;
      Params.ParamByName('State4').AsString := Edit7.Text;
      if ComboBox6.Text <> '' then
        Params.ParamByName('QSL_SENT_VIA').AsString := ComboBox6.Text
      else
        Params.ParamByName('QSL_SENT_VIA').IsNull;
      ExecSQL;
    end;
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
    Clr();
  end;
end;

procedure TMainForm.SpeedButton8MouseLeave(Sender: TObject);
begin
  StatusBar1.Panels.Items[0].Text := '';
end;

procedure TMainForm.SpeedButton8MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  StatusBar1.Panels.Items[0].Text := 'Сохранить QSO';
end;

procedure TMainForm.SpeedButton9Click(Sender: TObject);
begin
  Clr();
end;

procedure TMainForm.SpeedButton9MouseLeave(Sender: TObject);
begin
  StatusBar1.Panels.Items[0].Text := '';
end;

procedure TMainForm.SpeedButton9MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  StatusBar1.Panels.Items[0].Text := 'Очистить окно ввода QSO';
end;

procedure TMainForm.SQLiteDBConnectionAfterConnect(Sender: TObject);
begin
  if SQLiteDBConnection.Connected = False then
  begin
    EditButton1.ReadOnly := True;
  end
  else
  begin
    EditButton1.ReadOnly := False;
    DBGrid1.PopupMenu := PopupMenu1;
  end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  Label24.Caption := FormatDateTime('hh:mm:ss', Now);
  Label26.Caption := FormatDateTime('hh:mm:ss', NowUTC);
  Label28.Caption := FormatDateTime('hh:mm:ss', NowUTC + timedif / 24);
  if CheckBox1.Checked = True then
  begin
    DateTimePicker1.Time := NowUTC;
    DateEdit1.Date := NowUTC;
  end;
end;

function TMainForm.Login(host, port, userid, passwd: string): boolean;
begin
  Result := False;
  cluster := TTelnetSend.Create;
  try
    cluster.TargetHost := host;
    cluster.TargetPort := port;
    cluster.TermType := 'dumb';
    cluster.Timeout := 5000;
    Application.ProcessMessages;
    if cluster.Login then
    begin
      Application.ProcessMessages;
      memo1.Append(cluster.RecvTerminated(#13));
      cluster.WaitFor(':');
      dmFunc.Delay(50);
      cluster.Send(userid + #13 + #10);
      if Length(passwd) > 0 then
      begin
        Application.ProcessMessages;
        cluster.WaitFor('password:');
        cluster.Send(passwd + #13 + #10);
      end;
      loginmsg := cluster.RecvTerminated('>');
      dmFunc.Delay(50);
      inupdate := False;
      Timer2.Enabled := True;
      Result := True;
      SpeedButton18.Enabled := False;
      SpeedButton24.Enabled := False;
      SpeedButton21.Enabled := True;
      SpeedButton27.Enabled := True;
      SpeedButton28.Enabled := True;
      SpeedButton22.Enabled := True;
    end
    else
    begin
      Memo1.Append('Не могу подключится');
      SpeedButton18.Enabled := True;
      SpeedButton24.Enabled := True;
      SpeedButton21.Enabled := False;
      SpeedButton27.Enabled := False;
      SpeedButton28.Enabled := False;
      SpeedButton22.Enabled := False;
    end;
  except
    Memo1.Append('Не могу подключится');
  end;
end;

procedure TMainForm.Timer2Timer(Sender: TObject);
var
  s, de, dx, freq, comment, time, sband: string;
  p, r, band, mode: integer;
  showspot: boolean;
begin
  if cluster.Sock.LastError <> 0 then
  begin
    //  Close;
    Timer2.Enabled := False;
    Memo1.Append(
      'Не могу подключится. Возможно не введён логин');
    SpeedButton18.Enabled := True;
    SpeedButton24.Enabled := True;
    SpeedButton21.Enabled := False;
    SpeedButton27.Enabled := False;
    SpeedButton28.Enabled := False;
    SpeedButton22.Enabled := False;
    Exit;
  end;
  inupdate := True;
  while cluster.Sock.WaitingData > 0 do
  begin

    s := Trim(cluster.RecvTerminated(#13));
    if Length(s) > 0 then
    begin
      Memo1.Append(s);
      if (Copy(UpperCase(s), 1, 5) = 'DX DE') then
      begin
        // Frequency spot
        if Length(s) >= 75 then
        begin
          de := UpperCase(Trim(Copy(s, 7, 10)));
          p := Pos(':', de);
          if p > 0 then
            Delete(de, p, 1);
          freq := Trim(Copy(s, 17, 8));
          dmFunc.BandMode(freq, band, mode);
          dx := UpperCase(Trim(Copy(s, 27, 12)));
          comment := Trim(Copy(s, 40, 30));
          time := Copy(s, 71, 4);
          insert(':', time, 3);

          if not showspot then
          begin
            case band of
              1:
              begin
                showspot := ClusterFilter.cb160m.Checked;
                sband := '160m';
              end;
              3:
              begin
                showspot := ClusterFilter.cb80m.Checked;
                sband := '80m';
              end;
              5:
              begin
                showspot := ClusterFilter.cb60m.Checked;
                sband := '60m';
              end;
              7:
              begin
                showspot := ClusterFilter.cb40m.Checked;
                sband := '40m';
              end;
              10:
              begin
                showspot := ClusterFilter.cb30m.Checked;
                sband := '30m';
              end;
              14:
              begin
                showspot := ClusterFilter.cb20m.Checked;
                sband := '20m';
              end;
              18:
              begin
                showspot := ClusterFilter.cb17m.Checked;
                sband := '17m';
              end;
              21:
              begin
                showspot := ClusterFilter.cb15m.Checked;
                sband := '15m';
              end;
              24:
              begin
                showspot := ClusterFilter.cb12m.Checked;
                sband := '12m';
              end;
              28:
              begin
                showspot := ClusterFilter.cb10m.Checked;
                sband := '10m';
              end;
              50:
              begin
                showspot := ClusterFilter.cb6m.Checked;
                sband := '6m';
              end;
              70:
              begin
                showspot := ClusterFilter.cb4m.Checked;
                sband := '4m';
              end;
              144:
              begin
                showspot := ClusterFilter.cb2m.Checked;
                sband := '2m';
              end;
              432:
              begin
                showspot := ClusterFilter.cb70cm.Checked;
                sband := '70cm';
              end;
            end;
            if not ClusterFilter.cbAllModes.Checked then
              case mode of
                3, 7: showspot := showspot and ClusterFilter.cbCW.Checked;
                6, 9: showspot := showspot and ClusterFilter.cbData.Checked;
                else
                  showspot := showspot and ClusterFilter.cbSSB.Checked;
              end;
          end;

          if showspot then
          begin
            r := sgCluster.RowCount;
            sgCluster.RowCount := r + 1;
            sgCluster.Cells[0, r] := de;
            sgCluster.Cells[1, r] := dx;
            sgCluster.Cells[2, r] := freq;
            sgCluster.Cells[3, r] := comment;
            sgCluster.Cells[4, r] := time;
            with sgCluster do
              Row := RowCount - 1;
          end;
        end;
      end;
    end;
  end;
  inupdate := False;
end;

procedure TMainForm.Timer3Timer(Sender: TObject);
begin
  Panel10.Refresh;
end;

procedure TMainForm.TrayIcon1DblClick(Sender: TObject);
begin
  if StayForm = True then
    MenuItem95.Click
  else
    MenuItem96.Click;
end;

procedure TMainForm.WSJT_TimerTimer(Sender: TObject);
begin
  if WSJT_UDP_Form.WSJT_IsRunning then
  begin
    if WSJT_Timer.Interval > 1000 then
    begin
      WSJT_Timer.Interval := 1000;
      wsjtactive := usewsjt;
      if wsjtactive then
      begin
        if not connectedWSJT then
        begin
          {$IFDEF WINDOWS}
          TrayIcon1.BalloonHint := 'EWLog подключен к WSJT';
          TrayIcon1.ShowBalloonHint;
          {$ELSE}
          SysUtils.ExecuteProcess('/usr/bin/notify-send',
            ['EWLog', 'подключен к WSJT']);
          {$ENDIF}
          MenuItem74.Enabled := False;
          ComboBox2.Text := 'JT65';
          ComboBox2Change(Sender);
        end;
      end;
    end;
  end
  else if WSJT_Timer.Interval = 1000 then
  begin
    WSJT_Timer.Interval := 10000;
    wsjtactive := False;
    if not connectedWSJT then
    begin
      {$IFDEF WINDOWS}
      TrayIcon1.BalloonHint := 'EWLog не подключен к WSJT';
      TrayIcon1.ShowBalloonHint;
      {$ELSE}
      SysUtils.ExecuteProcess('/usr/bin/notify-send',
        ['EWLog', 'не подключен к WSJT']);
      {$ENDIF}
      MenuItem74.Enabled := True;
      ComboBox2.ItemIndex := 0;
      ComboBox2Change(Sender);
    end;
    Exit;
  end;
end;

procedure TMainForm.SendSpot(freq, call, cname, mode, rsts, grid: string);
var
  comment: string;
begin
  comment := cname + ' ' + mode + ' ' + rsts;
  try
    cluster.Send(Trim(Format('dx %s %s %s', [freq, call, comment])) + #13#10);
  except
    Memo1.Append(
      'Нет подключения к кластеру. Сперва подключитесь, затем отправляйте спот');
  end;
end;


end.
