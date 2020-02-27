unit MainForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mysql56conn, sqldb, sqlite3conn, DB, BufDataset, dbf,
  FileUtil, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls, DBGrids,
  ComCtrls, StdCtrls, EditBtn, Buttons, DBCtrls, DateTimePicker, DateUtils,
  IdIPWatch, LazUTF8, VirtualTrees, LCLProc, ActnList, Grids, INIFiles,
  mvMapViewer, LCLType, LazSysUtils, PrintersDlgs, LR_Class, LR_Desgn, LR_DBSet,
  LR_E_TXT, LR_E_CSV, lNetComponents, LCLIntf, lNet, StrUtils, FPReadGif,
  FPReadPNG, RegExpr, mvTypes, gettext, LResources, LCLTranslator, httpsend,
  Printers, DefaultTranslator, zipper, qso_record, ResourceStr, const_u, SetupSQLquery;

type

  { TMainForm }
  TExplodeArray = array of string;

  TMainForm = class(TForm)
    CallBookLiteConnection: TSQLite3Connection;
    CheckBox6: TCheckBox;
    ClearEdit: TAction;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox8: TComboBox;
    ComboBox9: TComboBox;
    Edit12: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    frCSVExport1: TfrCSVExport;
    frDBDataSet1: TfrDBDataSet;
    frReport1: TfrReport;
    frTextExport1: TfrTextExport;
    IdIPWatch1: TIdIPWatch;
    Label49: TLabel;
    Label50: TLabel;
    Label51: TLabel;
    Label52: TLabel;
    LTCPComponent1: TLTCPComponent;
    LTCPSyncDesk: TLTCPComponent;
    dxClient: TLTelnetClientComponent;
    LUDPComponent1: TLUDPComponent;
    LUDPSyncDesk: TLUDPComponent;
    MapView1: TMapView;
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
    MenuItem110: TMenuItem;
    MenuItem111: TMenuItem;
    MenuItem112: TMenuItem;
    MenuItem113: TMenuItem;
    MenuItem114: TMenuItem;
    MenuItem115: TMenuItem;
    MenuItem116: TMenuItem;
    MenuItem117: TMenuItem;
    MenuItem118: TMenuItem;
    MenuItem119: TMenuItem;
    MenuItem120: TMenuItem;
    MenuItem121: TMenuItem;
    MenuItem122: TMenuItem;
    MenuItem123: TMenuItem;
    MenuItem124: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
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
    PopupDxCluster: TPopupMenu;
    CheckTableQuery: TSQLQuery;
    BandsQuery: TSQLQuery;
    subModesQuery: TSQLQuery;
    PrintDialog1: TPrintDialog;
    SpeedButton24: TSpeedButton;
    SpeedButton25: TSpeedButton;
    SpeedButton26: TSpeedButton;
    SpeedButton27: TSpeedButton;
    SpeedButton28: TSpeedButton;
    SpeedButton29: TSpeedButton;
    qBands: TSQLQuery;
    PrintQuery: TSQLQuery;
    UniqueCallsQuery: TSQLQuery;
    TabSheet2: TTabSheet;
    VirtualStringTree1: TVirtualStringTree;
    WSJT_Timer: TTimer;
    TrayPopup: TPopupMenu;
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
    Fl_Timer: TTimer;
    CheckUpdatesTimer: TTimer;
    Timer3: TTimer;
    MenuItem8: TMenuItem;
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
    SQLQuery2: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    CallBookTransaction: TSQLTransaction;
    TabSheet1: TTabSheet;
    Timer1: TTimer;
    TrayIcon1: TTrayIcon;
    procedure CallBookLiteConnectionAfterDisconnect(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox6Change(Sender: TObject);
    //{$IfDef WINDOWS}
    procedure CheckUpdatesTimerStartTimer(Sender: TObject);
    procedure CheckUpdatesTimerTimer(Sender: TObject);
    procedure ComboBox1CloseUp(Sender: TObject);
    procedure ComboBox2CloseUp(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure ComboBox8Change(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1ColumnMoved(Sender: TObject; FromIndex, ToIndex: integer);
    procedure DBGrid1ColumnSized(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure DBGrid2DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure DBLookupComboBox1CloseUp(Sender: TObject);
    procedure dxClientConnect(aSocket: TLSocket);
    procedure dxClientDisconnect(aSocket: TLSocket);
    procedure dxClientReceive(aSocket: TLSocket);
    procedure Edit12KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure EditButton1ButtonClick(Sender: TObject);
    procedure EditButton1Change(Sender: TObject);
    procedure EditButton1KeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure Fl_TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label50Click(Sender: TObject);
    procedure LTCPComponent1Accept(aSocket: TLSocket);
    procedure LTCPComponent1CanSend(aSocket: TLSocket);
    procedure LTCPComponent1Disconnect(aSocket: TLSocket);
    procedure LTCPComponent1Error(const msg: string; aSocket: TLSocket);
    procedure LTCPComponent1Receive(aSocket: TLSocket);
    procedure LTCPSyncDeskAccept(aSocket: TLSocket);
    procedure LTCPSyncDeskError(const msg: string; aSocket: TLSocket);
    procedure LUDPComponent1Receive(aSocket: TLSocket);
    procedure LUDPSyncDeskReceive(aSocket: TLSocket);
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
    procedure MenuItem111Click(Sender: TObject);
    procedure MenuItem112Click(Sender: TObject);
    procedure MenuItem113Click(Sender: TObject);
    procedure MenuItem114Click(Sender: TObject);
    procedure MenuItem115Click(Sender: TObject);
    procedure MenuItem116Click(Sender: TObject);
    procedure MenuItem117Click(Sender: TObject);
    procedure MenuItem118Click(Sender: TObject);
    procedure MenuItem119Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem121Click(Sender: TObject);
    procedure MenuItem122Click(Sender: TObject);
    procedure MenuItem123Click(Sender: TObject);
    procedure MenuItem124Click(Sender: TObject);
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
    procedure MenuItem48Click(Sender: TObject);
    procedure MenuItem49Click(Sender: TObject);
    procedure MenuItem51Click(Sender: TObject);
    procedure MenuItem52Click(Sender: TObject);
    procedure MenuItem53Click(Sender: TObject);
    procedure MenuItem55Click(Sender: TObject);
    procedure MenuItem56Click(Sender: TObject);
    procedure MenuItem58Click(Sender: TObject);
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
    procedure LangItemClick(Sender: TObject);
    procedure MySQLLOGDBConnectionAfterConnect(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure SpeedButton16Click(Sender: TObject);
    procedure SpeedButton17Click(Sender: TObject);
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
    procedure SpeedButton24Click(Sender: TObject);
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
    procedure Timer3Timer(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure VirtualStringTree1Change(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure VirtualStringTree1CompareNodes(Sender: TBaseVirtualTree;
      Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: integer);
    procedure VirtualStringTree1DblClick(Sender: TObject);
    procedure VirtualStringTree1FocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure VirtualStringTree1FreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure VirtualStringTree1GetHint(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex;
      var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: string);
    procedure VirtualStringTree1GetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: boolean; var ImageIndex: integer);
    procedure VirtualStringTree1GetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: integer);
    procedure VirtualStringTree1GetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure VirtualStringTree1HeaderClick(Sender: TVTHeader;
      HitInfo: TVTHeaderHitInfo);
    procedure VirtualStringTree1NodeClick(Sender: TBaseVirtualTree;
      const HitInfo: THitInfo);
    procedure WSJT_TimerTimer(Sender: TObject);

  private
    { private declarations }

  public
    { public declarations }
    PrefixExpProvinceArray: array [0..1000] of record
      reg: TRegExpr;
      id: integer;
    end;
    PrefixExpARRLArray: array [0..1000] of record
      reg: TRegExpr;
      id: integer;
    end;
    UniqueCallsList: TStringList;
    PrefixProvinceList: TStringList;
    PrefixARRLList: TStringList;
    Command: string;
    FlagList: TImageList;
    FlagSList: TStringList;
    Language: string;
    PrintPrev: boolean;

    PhotoQrzString: string;
    PhotoJPEG: TJPEGImage;
    PhotoGIF: TGIFImage;
    PhotoPNG: TPortableNetworkGraphic;
    subModesList: TStringList;
    tIMG: TImage;
    PhotoGroup: TGroupBox;
    ColorTextGrid: integer;
    ColorBackGrid: integer;
    SizeTextGrid: integer;
    columnsGrid: array[0..29] of string;
    columnsWidth: array[0..29] of integer;
    columnsVisible: array[0..29] of boolean;
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
    freqchange: boolean;

    inupdate: boolean;
    procedure SendSpot(freq, call, cname, mode, rsts, grid: string);
    procedure SelectLogDatabase(LogDB: string);//; allrec, ofrec: integer);
    procedure SelDB(calllbook: string);
    procedure SearchCallLog(callNameS: string; ind: integer; ShowCall: boolean);
    procedure Clr();
    procedure SaveQSO(var SQSO: TQSO);
    procedure SearchCallInCallBook(CallName: string);
    function SearchPrefix(CallName: string; gridloc: boolean): boolean;
    procedure InitializeDB(dbS: string);
    procedure SelectQSO;
    procedure SetGrid;
    function GetNewChunk: string;
    function FindNode(const APattern: string; Country: boolean): PVirtualNode;
    function GetModeFromFreq(MHz: string): string;
    function SearchCountry(CallName: string; Province: boolean): string;
    procedure FindCountryFlag(Country: string);
    function FindCountry(ISOCode: string): string;
    procedure FindLanguageFiles(Dir: string; var LangList: TStringList);
    function FindISOCountry(Country: string): string;
    function FindMode(submode: string): string;
    procedure addModes(modeItem: string; subModesFlag: boolean;
      var subModes: TStringList);
    procedure addBands(FreqBand: string; mode: string);
    procedure InitIni;
    procedure FreeObj;
  end;

var
  MainForm: TMainForm;
  QTH_LAT: currency;
  QTH_LON: currency;
  PrefixProvinceCount: integer;
  PrefixARRLCount: integer;
  subModesCount: integer;
  UniqueCallsCount: integer;
  GetingHint: integer;
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
  eQSLccLogin, eQSLccPassword, HRDLogin, HRDCode, HamQTHLogin,
  HamQTHPassword, ClubLogLogin, ClubLogPassword, QRZComLogin, QRZComPassword: string;
  LotWLogin, LotWPassword: string;
  AutoEQSLcc, AutoHRDLog, AutoHamQTH, AutoClubLog, AutoQRZCom: boolean;
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
  fl_path, FLDIGI_USE, wsjt_path, WSJT_USE: string;
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
  seleditnum: integer;
  fAllRecords: integer;
  StateToQSLInfo: Boolean;



implementation

uses
  ConfigForm_U, ManagerBasePrefixForm_U, ExportAdifForm_u, CreateJournalForm_U,
  ImportADIFForm_U, dmFunc_U, eqsl, xmlrpc, fldigi, aziloc,
  QSLManagerForm_U, SettingsCAT_U,
  TRXForm_U, editqso_u, InformationForm_U, LogConfigForm_U, hrdlog,
  hamqth, clublog, qrzcom,
  SettingsProgramForm_U, AboutForm_U, ServiceForm_U, setupForm_U,
  UpdateForm_U, Earth_Form_U,
  IOTA_Form_U, ConfigGridForm_U, SendTelnetSpot_Form_U, ClusterFilter_Form_U,
  ClusterServer_Form_U, STATE_Form_U, WSJT_UDP_Form_U, synDBDate_u,
  ThanksForm_u, register_form_u,
  logtcpform_u, print_sticker_u, hiddentsettings_u, famm_u, mmform_u, flDigiModem;

type
  PTreeData = ^TTreeData;

  TTreeData = record
    DX: string;
    Spots: string;
    Call: string;
    Freq: string;
    Moda: string;
    Comment: string;
    Time: string;
    Country: string;
    Loc: string;
  end;


{$R *.lfm}

{ TMainForm }

procedure TMainForm.addModes(modeItem: string; subModesFlag: boolean;
  var subModes: TStringList);
var
  i: integer;
begin
  subModesQuery.Close;
  subModes.Delimiter := ',';

  if subModesFlag = False then
  begin
    subModesQuery.SQL.Text := 'SELECT * FROM Modes WHERE Enable = 1';
    subModesQuery.Open;
    subModesQuery.First;
    for i := 0 to subModesQuery.RecordCount - 1 do
    begin
      subModes.Add(subModesQuery.FieldByName('mode').AsString);
      subModesQuery.Next;
    end;
  end
  else
  begin
    subModesQuery.Close;
    subModesQuery.SQL.Text := 'SELECT submode FROM Modes WHERE mode = ' +
      QuotedStr(modeItem);
    subModesQuery.Open;
    subModes.DelimitedText := subModesQuery.FieldByName('submode').AsString;
  end;
  subModesQuery.Close;
end;

procedure TMainForm.addBands(FreqBand: string; mode: string);
var
  i: integer;
  lastBand: integer;
  lastBandName: string;
begin
  lastBand := ComboBox1.ItemIndex;
  lastBandName := ComboBox1.Text;
  BandsQuery.Close;
  ComboBox1.Items.Clear;
  BandsQuery.SQL.Text := 'SELECT * FROM Bands WHERE Enable = 1';
  BandsQuery.Open;
  BandsQuery.First;
  DefaultFormatSettings.DecimalSeparator := '.';
  for i := 0 to BandsQuery.RecordCount - 1 do
  begin
    if FreqBand = 'True' then
      ComboBox1.Items.Add(BandsQuery.FieldByName('band').AsString)
    else
    begin
      if mode = 'SSB' then
        ComboBox1.Items.Add(FormatFloat(view_freq,
          BandsQuery.FieldByName('ssb').AsFloat));
      if mode = 'CW' then
        ComboBox1.Items.Add(FormatFloat(view_freq,
          BandsQuery.FieldByName('cw').AsFloat));
      if (mode <> 'CW') and (mode <> 'SSB') then
        ComboBox1.Items.Add(FormatFloat(view_freq,
          BandsQuery.FieldByName('b_begin').AsFloat));
    end;
    BandsQuery.Next;
  end;
  BandsQuery.Close;
  if ComboBox1.Items.IndexOf(lastBandName) >= 0 then
    ComboBox1.ItemIndex := ComboBox1.Items.IndexOf(lastBandName)
  else
    ComboBox1.ItemIndex := lastBand;
end;

function TMainForm.FindMode(submode: string): string;
var
  i, j: integer;
begin
  i := 0;
  for j := 0 to subModesList.Count - 1 do
    if AnsiContainsText(subModesList.Strings[j], submode + ',') or
      AnsiContainsText(subModesList.Strings[j], ', ' + submode) then
    begin
      i := j;
      break;
    end;

  with subModesQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('select * from modes where _id = "' + IntToStr(i + 1) + '"');
    Open;
  end;
  Result := subModesQuery.FieldByName('mode').AsString;
  subModesQuery.Close;
end;

function TMainForm.FindISOCountry(Country: string): string;
var
  ISOList: TStringList;
  LanguageList: TStringList;
  Index: integer;
begin
  Result := '';
  try
    ISOList := TStringList.Create;
    LanguageList := TStringList.Create;
    ISOList.AddStrings(constLanguageISO);
    LanguageList.AddStrings(constLanguage);
    Index := LanguageList.IndexOf(Country);
    if Index <> -1 then
      Result := ISOList.Strings[Index]
    else
      Result := 'None';

  finally
    ISOList.Free;
    LanguageList.Free;
  end;
end;

function TMainForm.FindCountry(ISOCode: string): string;
var
  ISOList: TStringList;
  LanguageList: TStringList;
  Index: integer;
begin
  try
    Result := '';
    ISOList := TStringList.Create;
    LanguageList := TStringList.Create;
    ISOList.AddStrings(constLanguageISO);
    LanguageList.AddStrings(constLanguage);
    Index := ISOList.IndexOf(ISOCode);
    if Index <> -1 then
      Result := LanguageList.Strings[Index]
    else
      Result := 'None';

  finally
    ISOList.Free;
    LanguageList.Free;
  end;
end;

procedure TMainForm.FindLanguageFiles(Dir: string; var LangList: TStringList);
begin
  LangList := FindAllFiles(Dir, 'EWLog.*.po', False, faNormal);
  LangList.Text := StringReplace(LangList.Text, Dir + DirectorySeparator +
    'EWLog.', '', [rfreplaceall]);
  LangList.Text := StringReplace(LangList.Text, '.po', '', [rfreplaceall]);
end;

procedure TMainForm.FindCountryFlag(Country: string);
var
  pImage: TPortableNetworkGraphic;
begin
  try
    pImage := TPortableNetworkGraphic.Create;
    pImage.LoadFromLazarusResource(dmFunc.ReplaceCountry(Country));
    if FlagSList.IndexOf(dmFunc.ReplaceCountry(Country)) = -1 then
    begin
      FlagList.Add(pImage, nil);
      FlagSList.Add(dmFunc.ReplaceCountry(Country));
    end;
  except
    on EResNotFound do
    begin
      pImage.LoadFromLazarusResource('Unknown');
      if FlagSList.IndexOf('Unknown') = -1 then
      begin
        FlagList.Add(pImage, nil);
        FlagSList.Add('Unknown');
      end;
    end;
  end;
  pImage.Free;
end;

function TMainForm.SearchCountry(CallName: string; Province: boolean): string;
var
  i, j: integer;
  BoolPrefix: boolean;
begin
  if CallName.Length < 1 then
  begin
    Result := '';
    exit;
  end;
  BoolPrefix := False;
  Result := '';
  if Province = True then
  begin
    for i := 0 to PrefixProvinceCount do
    begin
      if (PrefixExpProvinceArray[i].reg.Exec(CallName)) and
        (PrefixExpProvinceArray[i].reg.Match[0] = CallName) then
      begin
        BoolPrefix := True;
        with MainForm.PrefixQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add('select * from Province where _id = "' +
            IntToStr(PrefixExpProvinceArray[i].id) + '"');
          Open;
        end;
        Result := MainForm.PrefixQuery.FieldByName('Country').AsString;
        exit;
      end;
    end;
  end;
  if BoolPrefix = False then
  begin
    for j := 0 to PrefixARRLCount do
    begin
      if (PrefixExpARRLArray[j].reg.Exec(CallName)) and
        (PrefixExpARRLArray[j].reg.Match[0] = CallName) then
      begin
        with MainForm.PrefixQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add('select * from CountryDataEx where _id = "' +
            IntToStr(PrefixExpARRLArray[j].id) + '"');
          Open;
          if (FieldByName('Status').AsString = 'Deleted') then
          begin
            PrefixExpARRLArray[j].reg.ExecNext;
            Exit;
          end;
          Result := MainForm.PrefixQuery.FieldByName('Country').AsString;
        end;
        Exit;
      end;
    end;
  end;
end;

function TMainForm.GetModeFromFreq(MHz: string): string;
var
  Band: string;
  tmp: extended;
begin
  Result := '';
  band := dmFunc.GetBandFromFreq(MHz);

  MHz := MHz.replace('.', DefaultFormatSettings.DecimalSeparator);
  MHz := MHz.replace(',', DefaultFormatSettings.DecimalSeparator);

  qBands.Close;
  qBands.SQL.Text := 'SELECT * FROM Bands WHERE band = ' + QuotedStr(band);
  if SQLServiceTransaction.Active then
    SQLServiceTransaction.Rollback;
  SQLServiceTransaction.StartTransaction;
  try
    qBands.Open;
    tmp := StrToFloat(MHz);

    if qBands.RecordCount > 0 then
    begin
      if ((tmp >= qBands.FieldByName('B_BEGIN').AsCurrency) and
        (tmp <= qBands.FieldByName('CW').AsCurrency)) then
        Result := 'CW'
      else
      begin
        if ((tmp > qBands.FieldByName('DIGI').AsCurrency) and
          (tmp <= qBands.FieldByName('SSB').AsCurrency)) then
          Result := 'DIGI'
        else
        begin
          if (tmp > 5) and (tmp < 6) then
            Result := 'USB'
          else
          begin
            if tmp > 10 then
              Result := 'USB'
            else
              Result := 'LSB';
          end;
        end;
      end;
    end
  finally
    qBands.Close;
    SQLServiceTransaction.Rollback
  end;
end;

function TMainForm.FindNode(const APattern: string; Country: boolean): PVirtualNode;
var
  ANode: PVirtualNode;
  DataNode: PTreeData;
begin
  Result := nil;
  ANode := VirtualStringTree1.GetFirst();
  while ANode <> nil do
  begin
    DataNode := VirtualStringTree1.GetNodeData(ANode);
    if Country = False then
    begin
      if DataNode^.DX = APattern then
      begin
        Result := ANode;
        exit;
      end;
    end
    else
    begin
      if DataNode^.Country = APattern then
      begin
        Result := ANode;
        exit;
      end;
    end;
    ANode := VirtualStringTree1.GetNext(ANode);
  end;
end;

procedure TMainForm.SetGrid;
var
  i: integer;
  QBAND: string;
begin
  for i := 0 to 29 do
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

  if IniF.ReadString('SetLog', 'ShowBand', '') = 'True' then
    QBAND := rQSOBand
  else
    QBAND := rQSOBandFreq;

  //Для первого грида
  for i := 0 to 29 do
  begin
    DBGrid1.Columns.Items[i].FieldName := columnsGrid[i];
    DBGrid1.Columns.Items[i].Width := columnsWidth[i];
    case columnsGrid[i] of
      'QSL': DBGrid1.Columns.Items[i].Title.Caption := rQSL;
      'QSLs': DBGrid1.Columns.Items[i].Title.Caption := rQSLs;
      'QSODate': DBGrid1.Columns.Items[i].Title.Caption := rQSODate;
      'QSOTime': DBGrid1.Columns.Items[i].Title.Caption := rQSOTime;
      'QSOBand': DBGrid1.Columns.Items[i].Title.Caption := QBAND;
      'CallSign': DBGrid1.Columns.Items[i].Title.Caption := rCallSign;
      'QSOMode': DBGrid1.Columns.Items[i].Title.Caption := rQSOMode;
      'QSOSubMode': DBGrid1.Columns.Items[i].Title.Caption := rQSOSubMode;
      'OMName': DBGrid1.Columns.Items[i].Title.Caption := rOMName;
      'OMQTH': DBGrid1.Columns.Items[i].Title.Caption := rOMQTH;
      'State': DBGrid1.Columns.Items[i].Title.Caption := rState;
      'Grid': DBGrid1.Columns.Items[i].Title.Caption := rGrid;
      'QSOReportSent': DBGrid1.Columns.Items[i].Title.Caption := rQSOReportSent;
      'QSOReportRecived': DBGrid1.Columns.Items[i].Title.Caption := rQSOReportRecived;
      'IOTA': DBGrid1.Columns.Items[i].Title.Caption := rIOTA;
      'QSLManager': DBGrid1.Columns.Items[i].Title.Caption := rQSLManager;
      'QSLSentDate': DBGrid1.Columns.Items[i].Title.Caption := rQSLSentDate;
      'QSLRecDate': DBGrid1.Columns.Items[i].Title.Caption := rQSLRecDate;
      'LoTWRecDate': DBGrid1.Columns.Items[i].Title.Caption := rLoTWRecDate;
      'MainPrefix': DBGrid1.Columns.Items[i].Title.Caption := rMainPrefix;
      'DXCCPrefix': DBGrid1.Columns.Items[i].Title.Caption := rDXCCPrefix;
      'CQZone': DBGrid1.Columns.Items[i].Title.Caption := rCQZone;
      'ITUZone': DBGrid1.Columns.Items[i].Title.Caption := rITUZone;
      'ManualSet': DBGrid1.Columns.Items[i].Title.Caption := rManualSet;
      'Continent': DBGrid1.Columns.Items[i].Title.Caption := rContinent;
      'ValidDX': DBGrid1.Columns.Items[i].Title.Caption := rValidDX;
      'QSL_RCVD_VIA': DBGrid1.Columns.Items[i].Title.Caption := rQSL_RCVD_VIA;
      'QSL_SENT_VIA': DBGrid1.Columns.Items[i].Title.Caption := rQSL_SENT_VIA;
      'USERS': DBGrid1.Columns.Items[i].Title.Caption := rUSERS;
      'NoCalcDXCC': DBGrid1.Columns.Items[i].Title.Caption := rNoCalcDXCC;
    end;

    case columnsGrid[i] of
      'QSL': DBGrid1.Columns.Items[i].Visible := columnsVisible[0];
      'QSLs': DBGrid1.Columns.Items[i].Visible := columnsVisible[1];
      'QSODate': DBGrid1.Columns.Items[i].Visible := columnsVisible[2];
      'QSOTime': DBGrid1.Columns.Items[i].Visible := columnsVisible[3];
      'QSOBand': DBGrid1.Columns.Items[i].Visible := columnsVisible[4];
      'CallSign': DBGrid1.Columns.Items[i].Visible := columnsVisible[5];
      'QSOMode': DBGrid1.Columns.Items[i].Visible := columnsVisible[6];
      'QSOSubMode': DBGrid1.Columns.Items[i].Visible := columnsVisible[7];
      'OMName': DBGrid1.Columns.Items[i].Visible := columnsVisible[8];
      'OMQTH': DBGrid1.Columns.Items[i].Visible := columnsVisible[9];
      'State': DBGrid1.Columns.Items[i].Visible := columnsVisible[10];
      'Grid': DBGrid1.Columns.Items[i].Visible := columnsVisible[11];
      'QSOReportSent': DBGrid1.Columns.Items[i].Visible := columnsVisible[12];
      'QSOReportRecived': DBGrid1.Columns.Items[i].Visible := columnsVisible[13];
      'IOTA': DBGrid1.Columns.Items[i].Visible := columnsVisible[14];
      'QSLManager': DBGrid1.Columns.Items[i].Visible := columnsVisible[15];
      'QSLSentDate': DBGrid1.Columns.Items[i].Visible := columnsVisible[16];
      'QSLRecDate': DBGrid1.Columns.Items[i].Visible := columnsVisible[17];
      'LoTWRecDate': DBGrid1.Columns.Items[i].Visible := columnsVisible[18];
      'MainPrefix': DBGrid1.Columns.Items[i].Visible := columnsVisible[19];
      'DXCCPrefix': DBGrid1.Columns.Items[i].Visible := columnsVisible[20];
      'CQZone': DBGrid1.Columns.Items[i].Visible := columnsVisible[21];
      'ITUZone': DBGrid1.Columns.Items[i].Visible := columnsVisible[22];
      'ManualSet': DBGrid1.Columns.Items[i].Visible := columnsVisible[23];
      'Continent': DBGrid1.Columns.Items[i].Visible := columnsVisible[24];
      'ValidDX': DBGrid1.Columns.Items[i].Visible := columnsVisible[25];
      'QSL_RCVD_VIA': DBGrid1.Columns.Items[i].Visible := columnsVisible[26];
      'QSL_SENT_VIA': DBGrid1.Columns.Items[i].Visible := columnsVisible[27];
      'USERS': DBGrid1.Columns.Items[i].Visible := columnsVisible[28];
      'NoCalcDXCC': DBGrid1.Columns.Items[i].Visible := columnsVisible[29];
    end;
  end;
  //Для второго грида
  for i := 0 to 29 do
  begin
    DBGrid2.Columns.Items[i].FieldName := columnsGrid[i];
    DBGrid2.Columns.Items[i].Width := columnsWidth[i];
    case columnsGrid[i] of
      'QSL': DBGrid2.Columns.Items[i].Title.Caption := rQSL;
      'QSLs': DBGrid2.Columns.Items[i].Title.Caption := rQSLs;
      'QSODate': DBGrid2.Columns.Items[i].Title.Caption := rQSODate;
      'QSOTime': DBGrid2.Columns.Items[i].Title.Caption := rQSOTime;
      'QSOBand': DBGrid2.Columns.Items[i].Title.Caption := QBAND;
      'CallSign': DBGrid2.Columns.Items[i].Title.Caption := rCallSign;
      'QSOMode': DBGrid2.Columns.Items[i].Title.Caption := rQSOMode;
      'QSOSubMode': DBGrid2.Columns.Items[i].Title.Caption := rQSOSubMode;
      'OMName': DBGrid2.Columns.Items[i].Title.Caption := rOMName;
      'OMQTH': DBGrid2.Columns.Items[i].Title.Caption := rOMQTH;
      'State': DBGrid2.Columns.Items[i].Title.Caption := rState;
      'Grid': DBGrid2.Columns.Items[i].Title.Caption := rGrid;
      'QSOReportSent': DBGrid2.Columns.Items[i].Title.Caption := rQSOReportSent;
      'QSOReportRecived': DBGrid2.Columns.Items[i].Title.Caption := rQSOReportRecived;
      'IOTA': DBGrid2.Columns.Items[i].Title.Caption := rIOTA;
      'QSLManager': DBGrid2.Columns.Items[i].Title.Caption := rQSLManager;
      'QSLSentDate': DBGrid2.Columns.Items[i].Title.Caption := rQSLSentDate;
      'QSLRecDate': DBGrid2.Columns.Items[i].Title.Caption := rQSLRecDate;
      'LoTWRecDate': DBGrid2.Columns.Items[i].Title.Caption := rLoTWRecDate;
      'MainPrefix': DBGrid2.Columns.Items[i].Title.Caption := rMainPrefix;
      'DXCCPrefix': DBGrid2.Columns.Items[i].Title.Caption := rDXCCPrefix;
      'CQZone': DBGrid2.Columns.Items[i].Title.Caption := rCQZone;
      'ITUZone': DBGrid2.Columns.Items[i].Title.Caption := rITUZone;
      'ManualSet': DBGrid2.Columns.Items[i].Title.Caption := rManualSet;
      'Continent': DBGrid2.Columns.Items[i].Title.Caption := rContinent;
      'ValidDX': DBGrid2.Columns.Items[i].Title.Caption := rValidDX;
      'QSL_RCVD_VIA': DBGrid2.Columns.Items[i].Title.Caption := rQSL_RCVD_VIA;
      'QSL_SENT_VIA': DBGrid2.Columns.Items[i].Title.Caption := rQSL_SENT_VIA;
      'USERS': DBGrid2.Columns.Items[i].Title.Caption := rUSERS;
      'NoCalcDXCC': DBGrid2.Columns.Items[i].Title.Caption := rNoCalcDXCC;
    end;

    case columnsGrid[i] of
      'QSL': DBGrid2.Columns.Items[i].Visible := columnsVisible[0];
      'QSLs': DBGrid2.Columns.Items[i].Visible := columnsVisible[1];
      'QSODate': DBGrid2.Columns.Items[i].Visible := columnsVisible[2];
      'QSOTime': DBGrid2.Columns.Items[i].Visible := columnsVisible[3];
      'QSOBand': DBGrid2.Columns.Items[i].Visible := columnsVisible[4];
      'CallSign': DBGrid2.Columns.Items[i].Visible := columnsVisible[5];
      'QSOMode': DBGrid2.Columns.Items[i].Visible := columnsVisible[6];
      'QSOSubMode': DBGrid2.Columns.Items[i].Visible := columnsVisible[7];
      'OMName': DBGrid2.Columns.Items[i].Visible := columnsVisible[8];
      'OMQTH': DBGrid2.Columns.Items[i].Visible := columnsVisible[9];
      'State': DBGrid2.Columns.Items[i].Visible := columnsVisible[10];
      'Grid': DBGrid2.Columns.Items[i].Visible := columnsVisible[11];
      'QSOReportSent': DBGrid2.Columns.Items[i].Visible := columnsVisible[12];
      'QSOReportRecived': DBGrid2.Columns.Items[i].Visible := columnsVisible[13];
      'IOTA': DBGrid2.Columns.Items[i].Visible := columnsVisible[14];
      'QSLManager': DBGrid2.Columns.Items[i].Visible := columnsVisible[15];
      'QSLSentDate': DBGrid2.Columns.Items[i].Visible := columnsVisible[16];
      'QSLRecDate': DBGrid2.Columns.Items[i].Visible := columnsVisible[17];
      'LoTWRecDate': DBGrid2.Columns.Items[i].Visible := columnsVisible[18];
      'MainPrefix': DBGrid2.Columns.Items[i].Visible := columnsVisible[19];
      'DXCCPrefix': DBGrid2.Columns.Items[i].Visible := columnsVisible[20];
      'CQZone': DBGrid2.Columns.Items[i].Visible := columnsVisible[21];
      'ITUZone': DBGrid2.Columns.Items[i].Visible := columnsVisible[22];
      'ManualSet': DBGrid2.Columns.Items[i].Visible := columnsVisible[23];
      'Continent': DBGrid2.Columns.Items[i].Visible := columnsVisible[24];
      'ValidDX': DBGrid2.Columns.Items[i].Visible := columnsVisible[25];
      'QSL_RCVD_VIA': DBGrid2.Columns.Items[i].Visible := columnsVisible[26];
      'QSL_SENT_VIA': DBGrid2.Columns.Items[i].Visible := columnsVisible[27];
      'USERS': DBGrid2.Columns.Items[i].Visible := columnsVisible[28];
      'NoCalcDXCC': DBGrid2.Columns.Items[i].Visible := columnsVisible[29];
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
    SearchCallLog(dmfunc.ExtractCallsign(DBGrid1.DataSource.DataSet.FieldByName(
      'CallSign').AsString), 0, False);
    SearchPrefix(DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString, True);
    Label17.Caption := IntToStr(DBGrid2.DataSource.DataSet.RecordCount);
    Label18.Caption := DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsString;
    Label19.Caption := DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsString;
    Label20.Caption := DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
    Label21.Caption := DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;
    Label22.Caption := DBGrid1.DataSource.DataSet.FieldByName('OMName').AsString;
    UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
    StatusBar1.Panels.Items[1].Text :=
      'QSO № ' + IntToStr(LOGBookQuery.RecNo) + rQSOTotal + IntToStr(fAllRecords);
  except
    on E: ESQLDatabaseError do
    begin
      if Pos('has gone away', E.Message) > 0 then
      begin
        ShowMessage(rMySQLHasGoneAway);
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
  modesString: TStringList;
begin
  subModesList := TStringList.Create;
  PrefixProvinceList := TStringList.Create;
  PrefixARRLList := TStringList.Create;
  UniqueCallsList := TStringList.Create;
  try
     {$IFDEF UNIX}
    sDBPath := GetEnvironmentVariable('HOME') + '/EWLog/';
    {$ELSE}
    sDBPath := GetEnvironmentVariable('SystemDrive') +
      SysToUTF8(GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
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
    ServiceDBConnection.Connected := False;
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
        if PortDB <> '' then
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
        CheckTableQuery.DataBase := MySQLLOGDBConnection;
      {$IFDEF WINDOWS}
        TrayIcon1.BalloonHint := rWelcomeMessageMySQL;
        TrayIcon1.ShowBalloonHint;
      {$ELSE}
        SysUtils.ExecuteProcess('/usr/bin/notify-send',
          ['EWLog', rWelcomeMessageMySQL]);
      {$ENDIF}
      finally
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
        CheckTableQuery.DataBase := SQLiteDBConnection;
      {$IFDEF WINDOWS}
        TrayIcon1.BalloonHint := rWelcomeMessageSQLIte;
        TrayIcon1.ShowBalloonHint;
      {$ELSE}
        SysUtils.ExecuteProcess('/usr/bin/notify-send',
          ['EWLog', rWelcomeMessageSQLIte]);
      {$ENDIF}
      finally
      end;
    end;

    PrefixProvinceQuery.DataBase := ServiceDBConnection;
    PrefixQuery.DataBase := ServiceDBConnection;
    PrefixARRLQuery.DataBase := ServiceDBConnection;
    UniqueCallsQuery.DataBase := ServiceDBConnection;
    qBands.DataBase := ServiceDBConnection;
    subModesQuery.DataBase := ServiceDBConnection;
    BandsQuery.DataBase := ServiceDBConnection;
    try
      modesString := TStringList.Create;
      ComboBox2.Items.Clear;
      AddModes('', False, modesString);
      ComboBox2.Items := modesString;
      modesString.Free;
      subModesQuery.SQL.Text := 'select _id, submode from Modes';
      LogBookInfoQuery.Active := True;
      LogBookFieldQuery.Active := True;
      PrefixProvinceQuery.Active := True;
      PrefixARRLQuery.Active := True;
      UniqueCallsQuery.Active := True;
      subModesQuery.Active := True;

      DBLookupComboBox1.KeyValue := CallLogBook;
      SelDB(CallLogBook);

      PrefixProvinceCount := PrefixProvinceQuery.RecordCount;
      PrefixARRLCount := PrefixARRLQuery.RecordCount;
      UniqueCallsCount := UniqueCallsQuery.RecordCount;
      subModesCount := subModesQuery.RecordCount;

      PrefixProvinceQuery.First;
      PrefixARRLQuery.First;
      UniqueCallsQuery.First;
      subModesQuery.First;
      for i := 0 to PrefixProvinceCount do
      begin
        PrefixProvinceList.Add(PrefixProvinceQuery.FieldByName('PrefixList').AsString);
        PrefixExpProvinceArray[i].reg := TRegExpr.Create;
        PrefixExpProvinceArray[i].reg.Expression := PrefixProvinceList.Strings[i];
        PrefixExpProvinceArray[i].id := PrefixProvinceQuery.FieldByName('_id').AsInteger;
        PrefixProvinceQuery.Next;
      end;
      for i := 0 to PrefixARRLCount do
      begin
        PrefixARRLList.Add(PrefixARRLQuery.FieldByName('PrefixList').AsString);
        PrefixExpARRLArray[i].reg := TRegExpr.Create;
        PrefixExpARRLArray[i].reg.Expression := PrefixARRLList.Strings[i];
        PrefixExpARRLArray[i].id := PrefixARRLQuery.FieldByName('_id').AsInteger;
        PrefixARRLQuery.Next;
      end;
      for i := 0 to UniqueCallsCount do
      begin
        UniqueCallsList.Add(UniqueCallsQuery.FieldByName('Callsign').AsString);
        UniqueCallsQuery.Next;
      end;

      for i := 0 to subModesCount do
      begin
        subModesList.Add(subModesQuery.FieldByName('submode').AsString);
        subModesQuery.Next;
      end;

    finally
    end;

  except
    on E: Exception do
    begin
      ShowMessage(E.ClassName + ':' + E.Message);
      SQLiteDBConnection.Connected := False;
      MySQLLOGDBConnection.Connected := False;
      FreeObj;
    end;
  end;
end;

procedure TMainForm.SearchCallLog(callNameS: string; ind: integer; ShowCall: boolean);
begin
  SQLQuery2.Close;
  SQLQuery2.SQL.Clear;
  if MySQLLOGDBConnection.Connected then
    SQLQuery2.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,' +
      '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
      + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `Call` LIKE ' +
      QuotedStr(callNameS) +
      ' ORDER BY YEAR(QSODate), MONTH(QSODate), DAY(QSODate), QSOTime ASC')
  else
    SQLQuery2.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,' +
      '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) as `QSL`, (`QSLSent`||'
      + '`LoTWSent`) as `QSLs` FROM ' + LogTable + ' WHERE `Call` = ' +
      QuotedStr(callNameS) + ' ORDER BY date(QSODate) ASC, time(QSOTime) ASC');
  SQLQuery2.Open;

  if (SQLQuery2.RecordCount > 0) and (ind = 1) and (EditButton1.Text <> '') then
    EditButton1.Color := clMoneyGreen
  else
    EditButton1.Color := clDefault;

  //Поиск и заполнение из внутриней базы
  if (SQLQuery2.RecordCount > 0) and (EditButton1.Text <> '') and (ShowCall = True) then
  begin
    if UseCallBook <> 'YES' then
    begin
      Edit1.Text := SQLQuery2.FieldByName('OMName').AsString;
      Edit2.Text := SQLQuery2.FieldByName('OMQTH').AsString;
      Edit3.Text := SQLQuery2.FieldByName('Grid').AsString;
      Edit4.Text := SQLQuery2.FieldByName('State').AsString;
      Edit5.Text := SQLQuery2.FieldByName('IOTA').AsString;
      Edit6.Text := SQLQuery2.FieldByName('QSLManager').AsString;
    end
    else
    begin
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


procedure TMainForm.Clr();
var
  Centre: TRealPoint;
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
  MainForm.ComboBox4.ItemIndex := 0;
  MainForm.ComboBox5.ItemIndex := 0;
  EditFlag := False;

  if CheckBox3.Checked then
  begin
    Centre.Lat := 0;
    Centre.Lon := 0;
    MapView1.Center := Centre;
    MapView1.Zoom := 1;
  end;

  ComboBox6.Text := '';
  if MenuItem111.Checked = True then
  begin
    PhotoJPEG.Clear;
    PhotoGIF.Clear;
    PhotoPNG.Clear;
    tIMG.Picture := nil;
  end;
end;

procedure TMainForm.SaveQSO(var SQSO: TQSO);
begin
  with MainForm.SaveQSOQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('INSERT INTO ' + SQSO.NLogDB +
      '(`CallSign`, `QSODate`, `QSOTime`, `QSOBand`, `QSOMode`, `QSOSubMode`, ' +
      '`QSOReportSent`, `QSOReportRecived`, `OMName`, `OMQTH`, `State`, `Grid`, `IOTA`,'
      +
      '`QSLManager`, `QSLSent`, `QSLSentAdv`, `QSLSentDate`, `QSLRec`, `QSLRecDate`,' +
      '`MainPrefix`, `DXCCPrefix`, `CQZone`, `ITUZone`, `QSOAddInfo`, `Marker`, `ManualSet`,'
      + '`DigiBand`, `Continent`, `ShortNote`, `QSLReceQSLcc`, `LoTWRec`, `LoTWRecDate`,'
      + '`QSLInfo`, `Call`, `State1`, `State2`, `State3`, `State4`, `WPX`, `AwardsEx`, '
      + '`ValidDX`, `SRX`, `SRX_STRING`, `STX`, `STX_STRING`, `SAT_NAME`, `SAT_MODE`,'
      + '`PROP_MODE`, `LoTWSent`, `QSL_RCVD_VIA`, `QSL_SENT_VIA`, `DXCC`, `USERS`, `NoCalcDXCC`, `MY_STATE`, `MY_GRIDSQUARE`, `MY_LAT`, `MY_LON`, `SYNC`)' + 'VALUES (:CallSign, :QSODate, :QSOTime, :QSOBand, :QSOMode, :QSOSubMode, :QSOReportSent,' + ':QSOReportRecived, :OMName, :OMQTH, :State, :Grid, :IOTA, :QSLManager, :QSLSent,' + ':QSLSentAdv, :QSLSentDate, :QSLRec, :QSLRecDate, :MainPrefix, :DXCCPrefix, :CQZone,' + ':ITUZone, :QSOAddInfo, :Marker, :ManualSet, :DigiBand, :Continent, :ShortNote,' + ':QSLReceQSLcc, :LoTWRec, :LoTWRecDate, :QSLInfo, :Call, :State1, :State2, :State3, :State4,' + ':WPX, :AwardsEx, :ValidDX, :SRX, :SRX_STRING, :STX, :STX_STRING, :SAT_NAME,' + ':SAT_MODE, :PROP_MODE, :LoTWSent, :QSL_RCVD_VIA, :QSL_SENT_VIA, :DXCC, :USERS, :NoCalcDXCC, :MY_STATE, :MY_GRIDSQUARE, :MY_LAT, :MY_LON, :SYNC)');

    Params.ParamByName('CallSign').AsString := SQSO.CallSing;
    Params.ParamByName('QSODate').AsDateTime := SQSO.QSODate;
    Params.ParamByName('QSOTime').AsString := SQSO.QSOTime;
    Params.ParamByName('QSOBand').AsString := SQSO.QSOBand;
    Params.ParamByName('QSOMode').AsString := SQSO.QSOMode;
    Params.ParamByName('QSOSubMode').AsString := SQSO.QSOSubMode;
    Params.ParamByName('QSOReportSent').AsString := SQSO.QSOReportSent;
    Params.ParamByName('QSOReportRecived').AsString := SQSO.QSOReportRecived;
    Params.ParamByName('OMName').AsString := SQSO.OmName;
    Params.ParamByName('OMQTH').AsString := SQSO.OmQTH;
    Params.ParamByName('State').AsString := SQSO.State0;
    Params.ParamByName('Grid').AsString := SQSO.Grid;
    Params.ParamByName('IOTA').AsString := SQSO.IOTA;
    Params.ParamByName('QSLManager').AsString := SQSO.QSLManager;
    Params.ParamByName('QSLSent').AsString := SQSO.QSLSent;
    Params.ParamByName('QSLSentAdv').AsString := SQSO.QSLSentAdv;

    if SQSO.QSLSentDate = 'NULL' then
      Params.ParamByName('QSLSentDate').IsNull
    else
      Params.ParamByName('QSLSentDate').AsString := SQSO.QSLSentDate;
    Params.ParamByName('QSLRec').AsString := SQSO.QSLRec;
    if SQSO.QSLRecDate = 'NULL' then
      Params.ParamByName('QSLRecDate').IsNull
    else
      Params.ParamByName('QSLRecDate').AsString := SQSO.QSLRecDate;

    Params.ParamByName('MainPrefix').AsString := SQSO.MainPrefix;
    Params.ParamByName('DXCCPrefix').AsString := SQSO.DXCCPrefix;
    Params.ParamByName('CQZone').AsString := SQSO.CQZone;
    Params.ParamByName('ITUZone').AsString := SQSO.ITUZone;
    Params.ParamByName('QSOAddInfo').AsString := SQSO.QSOAddInfo;
    Params.ParamByName('Marker').AsString := SQSO.Marker;
    Params.ParamByName('ManualSet').AsInteger := SQSO.ManualSet;
    Params.ParamByName('DigiBand').AsString := SQSO.DigiBand;
    Params.ParamByName('Continent').AsString := SQSO.Continent;
    Params.ParamByName('ShortNote').AsString := SQSO.ShortNote;
    Params.ParamByName('QSLReceQSLcc').AsInteger := SQSO.QSLReceQSLcc;
    if SQSO.LotWRec = '' then
      Params.ParamByName('LoTWRec').AsInteger := 0
    else
      Params.ParamByName('LoTWRec').AsInteger := 1;
    if SQSO.LotWRecDate = 'NULL' then
      Params.ParamByName('LoTWRecDate').IsNull
    else
      Params.ParamByName('LoTWRecDate').AsString := SQSO.LotWRecDate;
    Params.ParamByName('QSLInfo').AsString := SQSO.QSLInfo;
    Params.ParamByName('Call').AsString := SQSO.Call;
    Params.ParamByName('State1').AsString := SQSO.State1;
    Params.ParamByName('State2').AsString := SQSO.State2;
    Params.ParamByName('State3').AsString := SQSO.State3;
    Params.ParamByName('State4').AsString := SQSO.State4;
    Params.ParamByName('WPX').AsString := SQSO.WPX;
    Params.ParamByName('AwardsEx').AsString := SQSO.AwardsEx;
    Params.ParamByName('ValidDX').AsString := SQSO.ValidDX;
    Params.ParamByName('SRX').AsInteger := SQSO.SRX;
    Params.ParamByName('SRX_STRING').AsString := SQSO.SRX_String;
    Params.ParamByName('STX').AsInteger := SQSO.STX;
    Params.ParamByName('STX_STRING').AsString := SQSO.STX_String;
    Params.ParamByName('SAT_NAME').AsString := SQSO.SAT_NAME;
    Params.ParamByName('SAT_MODE').AsString := SQSO.SAT_MODE;
    Params.ParamByName('PROP_MODE').AsString := SQSO.PROP_MODE;
    Params.ParamByName('LoTWSent').AsInteger := SQSO.LotWSent;
    if SQSO.QSL_RCVD_VIA = '' then
      Params.ParamByName('QSL_RCVD_VIA').IsNull
    else
      Params.ParamByName('QSL_RCVD_VIA').AsString := SQSO.QSL_RCVD_VIA;
    if SQSO.QSL_SENT_VIA = '' then
      Params.ParamByName('QSL_SENT_VIA').IsNull
    else
      Params.ParamByName('QSL_SENT_VIA').AsString := SQSO.QSL_SENT_VIA;
    Params.ParamByName('DXCC').AsString := SQSO.DXCC;
    Params.ParamByName('USERS').AsString := SQSO.USERS;
    Params.ParamByName('NoCalcDXCC').AsInteger := SQSO.NoCalcDXCC;
    Params.ParamByName('MY_STATE').AsString := SQSO.My_State;
    Params.ParamByName('MY_GRIDSQUARE').AsString := SQSO.My_Grid;
    Params.ParamByName('MY_LAT').AsString := SQSO.My_Lat;
    Params.ParamByName('MY_LON').AsString := SQSO.My_Lon;
    Params.ParamByName('SYNC').AsInteger := SQSO.SYNC;
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

  finally
  end;
end;

procedure TMainForm.SelectLogDatabase(LogDB: string);
begin
  LogBookQuery.Close;
  LogBookQuery.SQL.Text := 'SELECT COUNT(*) FROM ' + LogDB;
  LogBookQuery.Open;
  fAllRecords := LogBookQuery.Fields[0].AsInteger;
  LogBookQuery.Close;

  if DefaultDB = 'MySQL' then
  begin
    LogBookQuery.SQL.Text := 'SELECT `UnUsedIndex`, `CallSign`,' +
      ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,' +
      '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
      + '`LoTWSent`) AS QSLs FROM ' + LogDB +
      ' ORDER BY UNIX_TIMESTAMP(STR_TO_DATE(QSODate, ''%Y-%m-%d'')) DESC, QSOTime DESC';
  end
  else
  begin
    LogBookQuery.SQL.Text := 'SELECT `UnUsedIndex`, `CallSign`,' +
      'strftime("%d.%m.%Y",QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,' +
      '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||`LoTWSent`) AS QSLs FROM '
      + LogDB +
      ' INNER JOIN (SELECT UnUsedIndex, QSODate as QSODate2, QSOTime as QSOTime2 from ' +
      LogDB + ' ORDER BY QSODate2 DESC, QSOTime2 DESC) as lim USING(UnUsedIndex)';
  end;

  LogBookQuery.Open;
  lastID := LOGBookQuery.RecNo;
  StatusBar1.Panels.Items[1].Text :=
    'QSO № ' + IntToStr(lastID) + rQSOTotal + IntToStr(fAllRecords);
end;

procedure TMainForm.SelDB(calllbook: string);
var
  ver_table: string;
begin
  ver_table := '';
  CheckTableQuery.Close;

  if calllbook = '' then
    CheckTableQuery.SQL.Text := ('SELECT * FROM LogBookInfo LIMIT 1')
  else
    CheckTableQuery.SQL.Text :=
      ('SELECT * FROM LogBookInfo WHERE CallName = ' + QuotedStr(calllbook));
  CheckTableQuery.Open;

  try
    if CheckTableQuery.FindField('Table_version') = nil then
    begin
      CheckTableQuery.Close;
      CheckTableQuery.SQL.Text :=
        'ALTER TABLE LogBookInfo ADD COLUMN Table_version varchar(10);';
      CheckTableQuery.ExecSQL;
      SQLTransaction1.Commit;
    end;

    if calllbook = '' then
      CheckTableQuery.SQL.Text := ('SELECT * FROM LogBookInfo LIMIT 1')
    else
      CheckTableQuery.SQL.Text :=
        ('SELECT * FROM LogBookInfo WHERE CallName = ' + QuotedStr(calllbook));
    CheckTableQuery.Open;
    ver_table := CheckTableQuery.FieldByName('Table_version').AsString;

    if ver_table <> Table_version then
    begin
      if CheckTableQuery.FindField('ClubLog_User') = nil then
      begin
        CheckTableQuery.Close;
        CheckTableQuery.SQL.Text :=
          'ALTER TABLE LogBookInfo ADD COLUMN ClubLog_User varchar(20);';
        CheckTableQuery.ExecSQL;
        SQLTransaction1.Commit;
      end;

      if CheckTableQuery.FindField('ClubLog_Password') = nil then
      begin
        CheckTableQuery.Close;
        CheckTableQuery.SQL.Text :=
          'ALTER TABLE LogBookInfo ADD COLUMN ClubLog_Password varchar(50);';
        CheckTableQuery.ExecSQL;
        SQLTransaction1.Commit;
      end;

      if CheckTableQuery.FindField('AutoClubLog') = nil then
      begin
        CheckTableQuery.Close;
        CheckTableQuery.SQL.Text :=
          'ALTER TABLE LogBookInfo ADD COLUMN AutoClubLog tinyint(1);';
        CheckTableQuery.ExecSQL;
        SQLTransaction1.Commit;
      end;

      if CheckTableQuery.FindField('QRZCOM_User') = nil then
      begin
        CheckTableQuery.Close;
        CheckTableQuery.SQL.Text :=
          'ALTER TABLE LogBookInfo ADD COLUMN QRZCOM_User varchar(20);';
        CheckTableQuery.ExecSQL;
        SQLTransaction1.Commit;
      end;

      if CheckTableQuery.FindField('QRZCOM_Password') = nil then
      begin
        CheckTableQuery.Close;
        CheckTableQuery.SQL.Text :=
          'ALTER TABLE LogBookInfo ADD COLUMN QRZCOM_Password varchar(50);';
        CheckTableQuery.ExecSQL;
        SQLTransaction1.Commit;
      end;

      if CheckTableQuery.FindField('AutoQRZCom') = nil then
      begin
        CheckTableQuery.Close;
        CheckTableQuery.SQL.Text :=
          'ALTER TABLE LogBookInfo ADD COLUMN AutoQRZCom tinyint(1);';
        CheckTableQuery.ExecSQL;
        SQLTransaction1.Commit;
      end;

      if CheckTableQuery.FindField('LoTW_User') = nil then
      begin
        CheckTableQuery.Close;
        CheckTableQuery.SQL.Text :=
          'ALTER TABLE LogBookInfo ADD COLUMN LoTW_User varchar(20);';
        CheckTableQuery.ExecSQL;
        SQLTransaction1.Commit;
      end;

      if CheckTableQuery.FindField('LoTW_Password') = nil then
      begin
        CheckTableQuery.Close;
        CheckTableQuery.SQL.Text :=
          'ALTER TABLE LogBookInfo ADD COLUMN LoTW_Password varchar(50);';
        CheckTableQuery.ExecSQL;
        SQLTransaction1.Commit;
      end;

      if CheckTableQuery.FindField('HamQTHLogin') = nil then
      begin
        CheckTableQuery.Close;
        CheckTableQuery.SQL.Text :=
          'ALTER TABLE LogBookInfo ADD COLUMN HamQTHLogin varchar(20);';
        CheckTableQuery.ExecSQL;
        SQLTransaction1.Commit;
      end;

      if CheckTableQuery.FindField('HamQTHPassword') = nil then
      begin
        CheckTableQuery.Close;
        CheckTableQuery.SQL.Text :=
          'ALTER TABLE LogBookInfo ADD COLUMN HamQTHPassword varchar(50);';
        CheckTableQuery.ExecSQL;
        SQLTransaction1.Commit;
      end;

      if CheckTableQuery.FindField('AutoHamQTH') = nil then
      begin
        CheckTableQuery.Close;
        CheckTableQuery.SQL.Text :=
          'ALTER TABLE LogBookInfo ADD COLUMN AutoHamQTH tinyint(1);';
        CheckTableQuery.ExecSQL;
        SQLTransaction1.Commit;
      end;
    end;
  except
    on E: ESQLDatabaseError do
  end;

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
    LotWLogin := MainForm.LogBookInfoQuery.FieldByName('LoTW_User').AsString;
    LotWPassword := MainForm.LogBookInfoQuery.FieldByName('LoTW_Password').AsString;
    AutoEQSLcc := MainForm.LogBookInfoQuery.FieldByName('AutoEQSLcc').AsBoolean;
    HRDLogin := MainForm.LogBookInfoQuery.FieldByName('HRDLogLogin').AsString;
    HRDCode := MainForm.LogBookInfoQuery.FieldByName('HRDLogPassword').AsString;
    AutoHRDLog := MainForm.LogBookInfoQuery.FieldByName('AutoHRDLog').AsBoolean;

    HamQTHLogin := MainForm.LogBookInfoQuery.FieldByName('HamQTHLogin').AsString;
    HamQTHPassword := MainForm.LogBookInfoQuery.FieldByName('HamQTHPassword').AsString;
    AutoHamQTH := MainForm.LogBookInfoQuery.FieldByName('AutoHamQTH').AsBoolean;

    ClubLogLogin := MainForm.LogBookInfoQuery.FieldByName('ClubLog_User').AsString;
    ClubLogPassword := MainForm.LogBookInfoQuery.FieldByName(
      'ClubLog_Password').AsString;
    AutoClubLog := MainForm.LogBookInfoQuery.FieldByName('AutoClubLog').AsBoolean;

    QRZComLogin := MainForm.LogBookInfoQuery.FieldByName('QRZCOM_User').AsString;
    QRZComPassword := MainForm.LogBookInfoQuery.FieldByName(
      'QRZCOM_Password').AsString;
    AutoQRZCom := MainForm.LogBookInfoQuery.FieldByName('AutoQRZCom').AsBoolean;

    CheckTableQuery.Close;
    CheckTableQuery.SQL.Text := 'SELECT * FROM ' + LogTable + ' LIMIT 1';
    CheckTableQuery.Open;

    if ver_table <> Table_version then
    begin
      try
        try
          try
            if MainForm.MySQLLOGDBConnection.Connected then
              MainForm.MySQLLOGDBConnection.ExecuteDirect(
                'ALTER TABLE ' + LogTable +
                ' DROP INDEX Dupe_index, ADD UNIQUE Dupe_index (CallSign, QSODate, QSOTime, QSOBand)')
            else
            begin
              MainForm.SQLiteDBConnection.ExecuteDirect(
                'DROP INDEX IF EXISTS Dupe_index');
              MainForm.SQLiteDBConnection.ExecuteDirect(
                'CREATE UNIQUE INDEX Dupe_index ON ' + LogTable +
                '(CallSign, QSODate, QSOTime, QSOBand)');
            end;
          except
            on E: ESQLDatabaseError do
            begin
              if E.ErrorCode = 1091 then
                MainForm.MySQLLOGDBConnection.ExecuteDirect('ALTER TABLE ' +
                  LogTable +
                  ' ADD UNIQUE Dupe_index (CallSign, QSODate, QSOTime, QSOBand)');
            end;
          end;

          if CheckTableQuery.FindField('MY_GRIDSQUARE') = nil then
          begin
            CheckTableQuery.Close;
            CheckTableQuery.SQL.Text :=
              'ALTER TABLE ' + LogTable + ' ADD COLUMN MY_GRIDSQUARE varchar(15);';
            CheckTableQuery.ExecSQL;
            SQLTransaction1.Commit;
          end;

          if CheckTableQuery.FindField('MY_LAT') = nil then
          begin
            CheckTableQuery.Close;
            CheckTableQuery.SQL.Text :=
              'ALTER TABLE ' + LogTable + ' ADD COLUMN MY_LAT varchar(15);';
            CheckTableQuery.ExecSQL;
            SQLTransaction1.Commit;
          end;

          if CheckTableQuery.FindField('MY_LON') = nil then
          begin
            CheckTableQuery.Close;
            CheckTableQuery.SQL.Text :=
              'ALTER TABLE ' + LogTable + ' ADD COLUMN MY_LON varchar(15);';
            CheckTableQuery.ExecSQL;
            SQLTransaction1.Commit;
          end;

          if CheckTableQuery.FindField('SYNC') = nil then
          begin
            CheckTableQuery.Close;
            CheckTableQuery.SQL.Text :=
              'ALTER TABLE ' + LogTable + ' ADD COLUMN SYNC tinyint(1) DEFAULT 0;';
            CheckTableQuery.ExecSQL;
            SQLTransaction1.Commit;
          end;

          if CheckTableQuery.FindField('MY_STATE') = nil then
          begin
            CheckTableQuery.Close;
            CheckTableQuery.SQL.Text :=
              'ALTER TABLE ' + LogTable + ' ADD COLUMN MY_STATE varchar(15);';
            CheckTableQuery.ExecSQL;
            SQLTransaction1.Commit;
          end;

          if CheckTableQuery.FindField('QSOSubMode') = nil then
          begin
            CheckTableQuery.Close;
            CheckTableQuery.SQL.Text :=
              'ALTER TABLE ' + LogTable + ' ADD COLUMN QSOSubMode varchar(15);';
            CheckTableQuery.ExecSQL;
            SQLTransaction1.Commit;
          end;
        except
          on E: ESQLDatabaseError do
        end;
      finally
        CheckTableQuery.Close;
        CheckTableQuery.SQL.Text :=
          'UPDATE LogBookInfo SET Table_version = ' + QuotedStr(Table_version) +
          ' WHERE CallName = "' + calllbook + '"';
        CheckTableQuery.ExecSQL;
        SQLTransaction1.Commit;
      end;
    end;
    MainForm.SelectLogDatabase(LogTable);
  end;
  CheckTableQuery.Close;
  SetGrid();
  LogBookFieldQuery.Open;
  DBLookupComboBox1.KeyValue := calllbook;
end;

function TMainForm.SearchPrefix(CallName: string; gridloc: boolean): boolean;
var
  i, j: integer;
  R: extended;
  la, lo: currency;
  azim, qra, loc: string;
begin
  Result := False;
  loc := '';
  qra := '';
  azim := '';
  la := 0;
  lo := 0;
  if UniqueCallsList.IndexOf(CallName) > -1 then
  begin
    with MainForm.PrefixQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('select * from UniqueCalls where _id = "' +
        IntToStr(UniqueCallsList.IndexOf(CallName)) + '"');
      Open;
      MainForm.Label33.Caption := FieldByName('Country').AsString;
      MainForm.Label34.Caption := FieldByName('ARRLPrefix').AsString;
      MainForm.Label38.Caption := FieldByName('Prefix').AsString;
      MainForm.Label45.Caption := FieldByName('CQZone').AsString;
      MainForm.Label47.Caption := FieldByName('ITUZone').AsString;
      MainForm.Label43.Caption := FieldByName('Continent').AsString;
      MainForm.Label40.Caption := FieldByName('Latitude').AsString;
      MainForm.Label42.Caption := FieldByName('Longitude').AsString;
      CallLAT := FieldByName('Latitude').AsString;
      CallLON := FieldByName('Longitude').AsString;
      DXCCNum := FieldByName('DXCC').AsInteger;
    end;

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
    MainForm.Label32.Caption := azim;
    Result := True;
    exit;
  end;

  for i := 0 to PrefixProvinceCount do
  begin
    if (PrefixExpProvinceArray[i].reg.Exec(CallName)) and
      (PrefixExpProvinceArray[i].reg.Match[0] = CallName) then
    begin
      with MainForm.PrefixQuery do
      begin
        Close;
        SQL.Clear;
        SQL.Add('select * from Province where _id = "' +
          IntToStr(PrefixExpProvinceArray[i].id) + '"');
        Open;
        MainForm.Label33.Caption := FieldByName('Country').AsString;
        MainForm.Label34.Caption := FieldByName('ARRLPrefix').AsString;
        MainForm.Label38.Caption := FieldByName('Prefix').AsString;
        MainForm.Label45.Caption := FieldByName('CQZone').AsString;
        MainForm.Label47.Caption := FieldByName('ITUZone').AsString;
        MainForm.Label43.Caption := FieldByName('Continent').AsString;
        MainForm.Label40.Caption := FieldByName('Latitude').AsString;
        MainForm.Label42.Caption := FieldByName('Longitude').AsString;
        CallLAT := FieldByName('Latitude').AsString;
        CallLON := FieldByName('Longitude').AsString;
        DXCCNum := FieldByName('DXCC').AsInteger;
        timedif := FieldByName('TimeDiff').AsInteger;
      end;

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
      MainForm.Label32.Caption := azim;
      Result := True;
      exit;
    end;
  end;

  for j := 0 to PrefixARRLCount do
  begin
    if (PrefixExpARRLArray[j].reg.Exec(CallName)) and
      (PrefixExpARRLArray[j].reg.Match[0] = CallName) then
    begin
      with MainForm.PrefixQuery do
      begin
        Close;
        SQL.Clear;
        SQL.Add('select * from CountryDataEx where _id = "' +
          IntToStr(PrefixExpARRLArray[j].id) + '"');
        Open;
        if (FieldByName('Status').AsString = 'Deleted') then
        begin
          PrefixExpARRLArray[j].reg.ExecNext;
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

      loc := MainForm.Edit3.Text;
      if gridloc = True then
      begin
        if MainForm.Edit3.Text <> '' then
          loc := MainForm.Edit3.Text;
      end;

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
      MainForm.Label32.Caption := azim;// +'/'+azim2;
      Result := True;
      exit;
    end;
  end;
end;

procedure TMainForm.EditButton1Change(Sender: TObject);
var
  Centre: TRealPoint;
  Lat, Long: real;
  Error: integer;
  engText: string;
  foundPrefix: boolean;
begin
  EditButton1.SelStart := seleditnum;
  engText := dmFunc.RusToEng(EditButton1.Text);
  if (engText <> EditButton1.Text) then
  begin
    EditButton1.Text := engText;
    exit;
  end;

  if not EditFlag then
  begin
    if EditButton1.Text = '' then
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
      exit;
    end;

    if (CallBookLiteConnection.Connected = True) and
      (IniF.ReadString('SetLog', 'Sprav', '') = 'False') then
      SearchCallInCallBook(dmFunc.ExtractCallsign(EditButton1.Text));
    if (CallBookLiteConnection.Connected = False) and
      (IniF.ReadString('SetLog', 'Sprav', '') = 'True') then
      InformationForm.QRZRUsprav(EditButton1.Text, MenuItem111.Checked);

    if CheckBox6.Checked = False then
      SearchCallLog(dmFunc.ExtractCallsign(EditButton1.Text), 1, True);
    foundPrefix := SearchPrefix(EditButton1.Text, False);

    if foundPrefix and CheckBox3.Checked = True then
    begin
      val(lo1, Long, Error);
      if Error = 0 then
      begin
        Centre.Lon := Long;
        val(la1, Lat, Error);
        if Error = 0 then
        begin
          Centre.Lat := Lat;
          MapView1.Zoom := 9;
          MapView1.Center := Centre;
        end;
      end;
    end;

    if CheckBox6.Checked = True then
    begin
      LogBookQuery.Close;
      LogBookQuery.SQL.Clear;

      if MySQLLOGDBConnection.Connected then
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `Call` LIKE ' +
          QuotedStr(EditButton1.Text + '%') + ' ORDER BY `UnUsedIndex`' + '');
      end
      else
      begin
        LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
          ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
          + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `Call` LIKE ' +
          QuotedStr(EditButton1.Text + '%') + ' ORDER BY `UnUsedIndex`' + '');
      end;
      LogBookQuery.Open;
      // LOGBookQuery.Last;
      // lastID := MainForm.DBGrid1.DataSource.DataSet.RecNo;
      //  StatusBar1.Panels.Items[1].Text :=
      //    'QSO № ' + IntToStr(lastID) + rQSOTotal +
      //    IntToStr(MainForm.LOGBookQuery.RecordCount);
    end;
  end;

end;

procedure TMainForm.EditButton1KeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  seleditnum := EditButton1.SelStart + 1;
  if (Key = VK_BACK) then
    seleditnum := EditButton1.SelStart - 1;
  if (Key = VK_DELETE) then
    seleditnum := EditButton1.SelStart;
  if (EditButton1.SelLength <> 0) and (Key = VK_BACK) then
    seleditnum := EditButton1.SelStart;
end;

procedure TMainForm.Fl_TimerTimer(Sender: TObject);
var
  stmp: string;
  currfreq: string;
  currmode: string;
  currsubdigimode: string;
  mode, digimode, subdigimode: string;
  curr_f: extended;
begin
  currmode := '';
  currsubdigimode := '';
  currfreq := '';
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
          dmFlModem.GetModemName(StrToInt(Fldigi_GetModemId), mode, subdigimode);
          ComboBox2.Text := mode;
          ComboBox9.Text := subdigimode;
          ComboBox2CloseUp(Sender);
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
      ComboBox2CloseUp(Sender);
      MenuItem43.Enabled := True;
    end;
    Exit;
  end;
  if fldigiactive then
  begin
    if not connected then
    begin
      stmp := Fldigi_GetFrequencyField;
      dmFlModem.GetModemName(StrToInt(Fldigi_GetModemId), mode, subdigimode);

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

      if (mode <> currmode) or (subdigimode <> currsubdigimode) then
      begin
        dmFlModem.GetModemName(StrToInt(Fldigi_GetModemId), mode, subdigimode);
        if mode <> currmode then
        begin
          currmode := mode;
          subdigimode := currsubdigimode;
          dmFlModem.GetModemName(StrToInt(Fldigi_GetModemId), mode, subdigimode);
          ComboBox9.Text := subdigimode;
          ComboBox2.Text := mode;
        end;
      end;

      if stmp <> currfreq then
      begin
        stmp := Fldigi_GetFrequencyField;
        if stmp <> currfreq then
        begin
          currfreq := stmp;
          curr_f := dmFunc.StrToFreq(stmp);
          stmp := FormatFloat(view_freq, curr_f);
          if ConfigForm.CheckBox2.Checked = True then
            ComboBox1.Text := dmFunc.GetBandFromFreq(stmp)
          else
            ComboBox1.Text := stmp;
        end;
      end;
    end;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i: integer;
  num_start: integer;
begin
  num_start := IniF.ReadInteger('SetLog', 'StartNum', 0);
  num_start := num_start + 1;
  if EditButton1.Text <> '' then
  begin
    if Application.MessageBox(PChar(rQSONotSave), PChar(rWarning),
      MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
    begin
      //Application.Terminate;
      CloseAction := caFree;

    end
    else
      CloseAction := caNone;
  end;

  //Сохранение размещения колонок
  for i := 0 to 29 do
  begin
    IniF.WriteString('GridSettings', 'Columns' + IntToStr(i),
      DBGrid1.Columns.Items[i].FieldName);
  end;

  for i := 0 to 29 do
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
  IniF.WriteBool('SetLog', 'ImgForm', MenuItem111.Checked);
  IniF.WriteInteger('SetLog', 'PastBand', ComboBox1.ItemIndex);
  IniF.WriteString('SetLog', 'PastMode', ComboBox2.Text);
  IniF.WriteString('SetLog', 'PastSubMode', ComboBox9.Text);
  IniF.WriteString('SetLog', 'Language', Language);
  IniF.WriteInteger('SetLog', 'StartNum', num_start);
  if CheckBox3.Checked = True then
    IniF.WriteString('SetLog', 'UseMAPS', 'YES')
  else
    IniF.WriteString('SetLog', 'UseMAPS', 'NO');
  TRXForm.Close;
  IniF.Free;
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
  for i := 0 to 29 do
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
  for i := 0 to 29 do
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

procedure TMainForm.CheckBox2Change(Sender: TObject);
begin
  if CheckBox2.Checked = True then
    Label4.Caption := rQSOTime + ' (Local)'
  else
    Label4.Caption := rQSOTime + ' (UTC)';
end;

procedure TMainForm.CheckBox3Change(Sender: TObject);
begin
  if CheckBox3.Checked = True then
  begin
    MapView1.UseThreads := True;
    MapView1.Center;
    MapView1.Visible := True;
    MapView1.Parent := Panel10;
    Earth.Hide;
  end
  else
  begin
    MapView1.Visible := False;
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

procedure TMainForm.CheckUpdatesTimerStartTimer(Sender: TObject);
begin
  Update_Form.CheckUpdate;
end;

procedure TMainForm.CheckUpdatesTimerTimer(Sender: TObject);
begin
  Update_Form.CheckUpdate;
end;

procedure TMainForm.ComboBox1CloseUp(Sender: TObject);
var
  deldot: string;
begin
  freqchange := True;
  deldot := ComboBox1.Text;
  if Pos('M', deldot) > 0 then
  begin
    deldot := FormatFloat(view_freq, dmFunc.GetFreqFromBand(deldot, ComboBox2.Text));
    Delete(deldot, length(deldot) - 2, 1);
  end
  else
    Delete(deldot, length(deldot) - 2, 1);

  if ComboBox2.Text = 'SSB' then
  begin
    if StrToDouble(deldot) >= 10 then
      ComboBox9.ItemIndex := ComboBox9.Items.IndexOf('USB')
    else
      ComboBox9.ItemIndex := ComboBox9.Items.IndexOf('LSB');
  end;

end;

procedure TMainForm.ComboBox2CloseUp(Sender: TObject);
var
  RSdigi: array[0..4] of string = ('599', '589', '579', '569', '559');
  RSssb: array[0..6] of string = ('59', '58', '57', '56', '55', '54', '53');
  deldot: string;
  modesString: TStringList;
begin
  modesString := TStringList.Create;
  deldot := ComboBox1.Text;
  if Pos('M', deldot) > 0 then
  begin
    deldot := FormatFloat(view_freq, dmFunc.GetFreqFromBand(deldot, ComboBox2.Text));
    Delete(deldot, length(deldot) - 2, 1);
  end
  else
    Delete(deldot, length(deldot) - 2, 1);
  ComboBox9.Items.Clear;
  addModes(ComboBox2.Text, True, modesString);
  ComboBox9.Items := modesString;
  modesString.Free;
  addBands(IniF.ReadString('SetLog', 'ShowBand', ''), ComboBox2.Text);
  if ComboBox2.Text <> 'SSB' then
    ComboBox9.Text := '';

  if deldot <> '' then
  begin
    if StrToDouble(deldot) >= 10 then
      ComboBox9.ItemIndex := ComboBox9.Items.IndexOf('USB')
    else
      ComboBox9.ItemIndex := ComboBox9.Items.IndexOf('LSB');
  end;

  if (ComboBox2.Text <> 'SSB') or (ComboBox2.Text <> 'AM') or
    (ComboBox2.Text <> 'FM') or (ComboBox2.Text <> 'LSB') or
    (ComboBox2.Text <> 'USB') or (ComboBox2.Text <> 'JT44') or
    (ComboBox2.Text <> 'JT65') or (ComboBox2.Text <> 'JT6M') or
    (ComboBox2.Text <> 'JT9') or (ComboBox2.Text <> 'FT8') or
    (ComboBox2.Text <> 'ROS') then
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
  freqchange := True;
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
  EditQSO_Form.ComboBox1.Items := ComboBox1.Items;
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
    EditQSO_Form.ComboBox2.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;
    EditQSO_Form.ComboBox9.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('QSOSubMode').AsString;

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
    EditQSO_Form.CheckBox7.Checked :=
      DBGrid1.DataSource.DataSet.FieldByName('LoTWSent').AsBoolean;

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

    EditQSO_Form.ComboBox3.Text :=
      DBGrid1.DataSource.DataSet.FieldByName('PROP_MODE').AsString;

    EditQSO_Form.Show;
  end;
end;

procedure TMainForm.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: integer; Column: TColumn; State: TGridDrawState);
var
  Field_QSL: string;
  Field_QSLs: string;
  Field_QSLSentAdv: string;
begin
  Field_QSL := LOGBookDS.DataSet.FieldByName('QSL').AsString;
  Field_QSLs := LOGBookDS.DataSet.FieldByName('QSLs').AsString;
  Field_QSLSentAdv := LOGBookDS.DataSet.FieldByName('QSLSentAdv').AsString;

  if Field_QSLSentAdv = 'N' then
    with DBGrid1.Canvas do
    begin
      Brush.Color := clRed;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (Field_QSL = '001') or (Field_QSL = '100') or (Field_QSL = '011') or
    (Field_QSL = '110') or (Field_QSL = '111') or (Field_QSL = '101') then
    with DBGrid1.Canvas do
    begin
      Brush.Color := clFuchsia;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (Field_QSLs = '10') or (Field_QSLs = '11') then
    with DBGrid1.Canvas do
    begin
      Brush.Color := clAqua;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if ((Field_QSLs = '10') or (Field_QSLs = '11')) and
    ((Field_QSL = '001') or (Field_QSL = '011') or (Field_QSL = '111') or
    (Field_QSL = '101') or (Field_QSL = '110')) then
    with DBGrid1.Canvas do
    begin
      Brush.Color := clLime;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (Column.FieldName = 'CallSign') then
    if (Field_QSL = '010') or (Field_QSL = '110') or (Field_QSL = '111') or
      (Field_QSL = '011') then
    begin
      with DBGrid1.Canvas do
      begin
        Brush.Color := clYellow;
        Font.Color := clBlack;
        if (gdSelected in State) then
        begin
          Brush.Color := clHighlight;
          Font.Color := clWhite;
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

      if (Field_QSL = '100') then
        TextOut(Rect.Right - 6 - TextWidth('P'), Rect.Top + 0, 'P');

      if (Field_QSL = '110') then
        TextOut(Rect.Right - 10 - TextWidth('PE'), Rect.Top + 0, 'PE');

      if (Field_QSL = '111') then
        TextOut(Rect.Right - 6 - TextWidth('PLE'), Rect.Top + 0, 'PLE');

      if (Field_QSL = '010') then
        TextOut(Rect.Right - 6 - TextWidth('E'), Rect.Top + 0, 'E');

      if (Field_QSL = '001') then
        TextOut(Rect.Right - 6 - TextWidth('L'), Rect.Top + 0, 'L');

      if (Field_QSL = '101') then
        TextOut(Rect.Right - 10 - TextWidth('PL'), Rect.Top + 0, 'PL');

      if (Field_QSL = '011') then
        TextOut(Rect.Right - 10 - TextWidth('LE'), Rect.Top + 0, 'LE');
    end;
  end;
  if (Column.FieldName = 'QSLs') then
  begin
    with DBGrid1.Canvas do
    begin
      FillRect(Rect);
      if (Field_QSLs = '10') then
        TextOut(Rect.Right - 6 - TextWidth('P'), Rect.Top + 0, 'P');

      if (Field_QSLs = '11') then
        TextOut(Rect.Right - 10 - TextWidth('PL'), Rect.Top + 0, 'PL');

      if (Field_QSLs = '01') then
        TextOut(Rect.Right - 6 - TextWidth('L'), Rect.Top + 0, 'L');
    end;
  end;
  if ConfigForm.CheckBox2.Checked = True then
  begin
    if (Column.FieldName = 'QSOBand') then
    begin
      DBGrid1.Canvas.FillRect(Rect);
      DBGrid1.Canvas.TextOut(Rect.Left + 2, Rect.Top + 0,
        dmFunc.GetBandFromFreq(LOGBookDS.DataSet.FieldByName('QSOBand').AsString));
    end;
  end;
end;

procedure TMainForm.DBGrid2DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: integer; Column: TColumn; State: TGridDrawState);
var
  Field_QSL: string;
  Field_QSLs: string;
  Field_QSLSentAdv: string;
begin
  Field_QSL := DataSource2.DataSet.FieldByName('QSL').AsString;
  Field_QSLs := DataSource2.DataSet.FieldByName('QSLs').AsString;
  Field_QSLSentAdv := DataSource2.DataSet.FieldByName('QSLSentAdv').AsString;

  if Field_QSLSentAdv = 'N' then
    with DBGrid2.Canvas do
    begin
      Brush.Color := clRed;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid2.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (Field_QSL = '001') or (Field_QSL = '100') or (Field_QSL = '011') or
    (Field_QSL = '110') or (Field_QSL = '111') or (Field_QSL = '101') then
    with DBGrid2.Canvas do
    begin
      Brush.Color := clFuchsia;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid2.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (Field_QSLs = '10') or (Field_QSLs = '11') then
    with DBGrid2.Canvas do
    begin
      Brush.Color := clAqua;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid2.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if ((Field_QSLs = '10') or (Field_QSLs = '11')) and
    ((Field_QSL = '001') or (Field_QSL = '011') or (Field_QSL = '111') or
    (Field_QSL = '101') or (Field_QSL = '110')) then
    with DBGrid2.Canvas do
    begin
      Brush.Color := clLime;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid2.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;

  if (Column.FieldName = 'CallSign') then
    if (Field_QSL = '010') or (Field_QSL = '110') or (Field_QSL = '111') or
      (Field_QSL = '011') then
    begin
      with DBGrid2.Canvas do
      begin
        Brush.Color := clYellow;
        Font.Color := clBlack;
        if (gdSelected in State) then
        begin
          Brush.Color := clHighlight;
          Font.Color := clWhite;
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

      if (Field_QSL = '100') then
        TextOut(Rect.Right - 6 - TextWidth('P'), Rect.Top + 0, 'P');

      if (Field_QSL = '110') then
        TextOut(Rect.Right - 10 - TextWidth('PE'), Rect.Top + 0, 'PE');

      if (Field_QSL = '111') then
        TextOut(Rect.Right - 6 - TextWidth('PLE'), Rect.Top + 0, 'PLE');

      if (Field_QSL = '010') then
        TextOut(Rect.Right - 6 - TextWidth('E'), Rect.Top + 0, 'E');

      if (Field_QSL = '001') then
        TextOut(Rect.Right - 6 - TextWidth('L'), Rect.Top + 0, 'L');

      if (Field_QSL = '101') then
        TextOut(Rect.Right - 10 - TextWidth('PL'), Rect.Top + 0, 'PL');

      if (Field_QSL = '011') then
        TextOut(Rect.Right - 10 - TextWidth('LE'), Rect.Top + 0, 'LE');
    end;
  end;
  if (Column.FieldName = 'QSLs') then
  begin
    with DBGrid2.Canvas do
    begin
      FillRect(Rect);
      if (Field_QSLs = '10') then
        TextOut(Rect.Right - 6 - TextWidth('P'), Rect.Top + 0, 'P');

      if (Field_QSLs = '11') then
        TextOut(Rect.Right - 10 - TextWidth('PL'), Rect.Top + 0, 'PL');

      if (Field_QSLs = '01') then
        TextOut(Rect.Right - 6 - TextWidth('L'), Rect.Top + 0, 'L');
    end;
  end;
  if ConfigForm.CheckBox2.Checked = True then
  begin
    if (Column.FieldName = 'QSOBand') then
    begin
      DBGrid2.Canvas.FillRect(Rect);
      DBGrid2.Canvas.TextOut(Rect.Left + 2, Rect.Top + 0,
        dmFunc.GetBandFromFreq(DataSource2.DataSet.FieldByName('QSOBand').AsString));
    end;
  end;
end;

procedure TMainForm.DBLookupComboBox1CloseUp(Sender: TObject);
begin
  Edit14.Clear;
  Edit15.Clear;
  if DBLookupComboBox1.ItemIndex >= 0 then
  begin
    SelDB(DBLookupComboBox1.KeyValue);
    CallLogBook := DBLookupComboBox1.KeyValue;
    if Pos('/', DBLookupComboBox1.Text) > 0 then
    begin
      Label51.Visible := True;
      Edit14.Visible := True;
      Label52.Visible := True;
      Edit15.Visible := True;
    end
    else
    begin
      Label51.Visible := False;
      Edit14.Visible := False;
      Label52.Visible := False;
      Edit15.Visible := False;
    end;
  end;
end;

procedure TMainForm.dxClientConnect(aSocket: TLSocket);
begin
  SpeedButton18.Enabled := False;
  SpeedButton24.Enabled := False;
end;

procedure TMainForm.dxClientDisconnect(aSocket: TLSocket);
begin
  Memo1.Append(rDXClusterDisconnect);

  SpeedButton21.Enabled := False;
  SpeedButton27.Enabled := False;
  SpeedButton18.Enabled := True;
  SpeedButton24.Enabled := True;
  SpeedButton28.Enabled := False;
  SpeedButton22.Enabled := False;
end;

procedure TMainForm.dxClientReceive(aSocket: TLSocket);
var
  DX, Call, Freq, Comment, Time, Loc, Band: string;
  TelnetLine: string;
  Data: PTreeData;
  XNode: PVirtualNode;
  ShowSpot: boolean;
  freqMhz: double;
begin
  freqMhz := 0;
  DX := '';
  Call := '';
  Freq := '';
  Comment := '';
  Time := '';
  Loc := '';
  Band := '';
  showspot := False;
  if dxClient.GetMessage(TelnetLine) > 0 then
  begin
    TelnetLine := Trim(TelnetLine);
    Memo1.Lines.Add(TelnetLine);

    if Length(LoginCluster) > 0 then
    begin
      if Pos('login', TelnetLine) > 0 then
        dxClient.SendMessage(LoginCluster + #13#10, aSocket);
    end;
    if Pos('DX de', TelnetLine) = 1 then
    begin
      TelnetLine := StringReplace(TelnetLine, ':', ' ', [rfReplaceAll]);
      Call := StringReplace(TelnetLine.Substring(6, 8), ' ', '', [rfReplaceAll]);
      Freq := StringReplace(TelnetLine.Substring(15, 10), ' ', '', [rfReplaceAll]);
      DX := StringReplace(TelnetLine.Substring(26, 12), ' ', '', [rfReplaceAll]);
      Comment := Trim(TelnetLine.Substring(39, 30));
      Time := StringReplace(TelnetLine.Substring(70, 2) + ':' +
        TelnetLine.Substring(72, 2), ' ', '', [rfReplaceAll]);
      Loc := StringReplace(TelnetLine.Substring(76, 4), ' ', '', [rfReplaceAll]);
    end;

    if Freq <> '' then
      freqMhz := StrToDouble(Freq) / 1000;

    Band := dmFunc.GetBandFromFreq(FloatToStr(freqMhz));
    if not ShowSpot then
    begin
      case Band of
        '2190M': showspot := True;
        '630M': showspot := True;
        '160M': showspot := ClusterFilter.cb160m.Checked;
        '80M': showspot := ClusterFilter.cb80m.Checked;
        '60M': showspot := ClusterFilter.cb60m.Checked;
        '40M': showspot := ClusterFilter.cb40m.Checked;
        '30M': showspot := ClusterFilter.cb30m.Checked;
        '20M': showspot := ClusterFilter.cb20m.Checked;
        '17M': showspot := ClusterFilter.cb17m.Checked;
        '15M': showspot := ClusterFilter.cb15m.Checked;
        '12M': showspot := ClusterFilter.cb12m.Checked;
        '10M': showspot := ClusterFilter.cb10m.Checked;
        '6M': showspot := ClusterFilter.cb6m.Checked;
        '4M': showspot := ClusterFilter.cb4m.Checked;
        '2M': showspot := ClusterFilter.cb2m.Checked;
        '1.25M': showspot := True;
        '70CM': showspot := ClusterFilter.cb70cm.Checked;
        '33CM': showspot := True;
        '23CM': showspot := True;
        '13CM': showspot := True;
        '9CM': showspot := True;
        '6CM': showspot := True;
        '3CM': showspot := True;
        '1.25CM': showspot := True;
        '6MM': showspot := True;
        '4MM': showspot := True;
      end;
    end;

    if (Length(DX) > 0) and ShowSpot then
    begin
      if FindNode(dmFunc.GetBandFromFreq(FloatToStr(freqMhz)), False) = nil then
      begin
        XNode := VirtualStringTree1.AddChild(nil);
        Data := VirtualStringTree1.GetNodeData(Xnode);
        Data^.DX := dmFunc.GetBandFromFreq(FloatToStr(freqMhz));
        XNode := VirtualStringTree1.AddChild(
          FindNode(dmFunc.GetBandFromFreq(FloatToStr(freqMhz)), False));
        Data := VirtualStringTree1.GetNodeData(Xnode);
        Data^.Spots := DX;
        Data^.Call := Call;
        Data^.Freq := Freq;
        Data^.Moda := GetModeFromFreq(FloatToStr(freqMhz));
        Data^.Comment := Comment;
        Data^.Time := Time;
        Data^.Loc := Loc;
        Data^.Country := SearchCountry(DX, False);
        VirtualStringTree1.Expanded[XNode^.Parent] := True;
        FindCountryFlag(Data^.Country);
      end
      else
      begin
        XNode := VirtualStringTree1.InsertNode(
          FindNode(dmFunc.GetBandFromFreq(FloatToStr(freqMhz)), False), amAddChildFirst);
        Data := VirtualStringTree1.GetNodeData(Xnode);
        Data^.Spots := DX;
        Data^.Call := Call;
        Data^.Freq := Freq;
        Data^.Moda := GetModeFromFreq(FloatToStr(freqMhz));
        Data^.Comment := Comment;
        Data^.Time := Time;
        Data^.Loc := Loc;
        Data^.Country := SearchCountry(DX, False);
        FindCountryFlag(Data^.Country);
      end;
    end;
  end;
end;

procedure TMainForm.Edit12KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = 13 then
  begin
    dxClient.SendMessage(Edit12.Text + #13#10, nil);
    Edit12.Clear;
  end;
end;

procedure TMainForm.EditButton1ButtonClick(Sender: TObject);
begin
  if (CallBookLiteConnection.Connected = True) and
    (IniF.ReadString('SetLog', 'Sprav', '') = 'False') then
    SearchCallInCallBook(dmFunc.ExtractCallsign(EditButton1.Text));
  if (CallBookLiteConnection.Connected = False) and
    (IniF.ReadString('SetLog', 'Sprav', '') = 'True') then
  begin
    InformationForm.QRZRUsprav(EditButton1.Text, MenuItem111.Checked);
  end;
end;

procedure TMainForm.InitIni;
var
  i, j: integer;
begin
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
      StateToQSLInfo := IniF.ReadBool('SetLog', 'StateToQSLInfo', False);

      LoginCallBook := IniF.ReadString('CallBookDB', 'LoginName', '');
      PasswdCallBook := IniF.ReadString('CallBookDB', 'Password', '');
      HostCallBook := IniF.ReadString('CallBookDB', 'HostAddr', '');
      PortCallBook := IniF.ReadString('CallBookDB', 'Port', '');
      NameCallBook := IniF.ReadString('CallBookDB', 'DataBaseName', '');

      SQLiteFILE := IniF.ReadString('DataBases', 'FileSQLite', '');

      if not FileExists(SQLiteFILE) and (SQLiteFILE <> '') then
      begin
        ShowMessage(rNoLogFileFound);
        exit;
      end;

      LoginCluster := IniF.ReadString('TelnetCluster', 'Login', '');
      PasswordCluster := IniF.ReadString('TelnetCluster', 'Password', '');

      for i := 1 to 9 do
      begin
        TelStr[i] := IniF.ReadString('TelnetCluster', 'Server' +
          IntToStr(i), 'FREERC -> dx.feerc.ru:8000');
      end;
      TelName := IniF.ReadString('TelnetCluster', 'ServerDef',
        'FREERC -> dx.freerc.ru:8000');
      ComboBox3.Items.Clear;
      ComboBox3.Items.AddStrings(TelStr);
      if ComboBox3.Items.IndexOf(TelName) > -1 then
        ComboBox3.ItemIndex := ComboBox3.Items.IndexOf(TelName)
      else
        ComboBox3.ItemIndex := 0;

      ComboBox8.Items.Clear;
      ComboBox8.Items.AddStrings(TelStr);
      if ComboBox8.Items.IndexOf(TelName) > -1 then
        ComboBox8.ItemIndex := ComboBox8.Items.IndexOf(TelName)
      else
        ComboBox8.ItemIndex := 0;

      i := pos('>', ComboBox3.Text);
      j := pos(':', ComboBox3.Text);
      //Сервер
      HostCluster := copy(ComboBox3.Text, i + 1, j - i - 1);
      Delete(HostCluster, 1, 1);
      //Порт
      PortCluster := copy(ComboBox3.Text, j + 1, Length(ComboBox3.Text) - i);
      fl_path := IniF.ReadString('FLDIGI', 'FldigiPATH', '');
      wsjt_path := IniF.ReadString('WSJT', 'WSJTPATH', '');
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

      DateEdit1.Date := LazSysUtils.NowUTC;
      DateTimePicker1.Time := NowUTC;
      Label24.Caption := FormatDateTime('hh:mm:ss', Now);
      Label26.Caption := FormatDateTime('hh:mm:ss', NowUTC);

      if DefaultDB = 'MySQL' then
        MenuItem89.Caption := rSwitchDBSQLIte
      else
        MenuItem89.Caption := rSwitchDBMySQL;
      InitializeDB(DefaultDB);
      ComboBox2.ItemIndex := ComboBox2.Items.IndexOf(
        IniF.ReadString('SetLog', 'PastMode', ''));
      ComboBox2CloseUp(Self);
      ComboBox9.ItemIndex := ComboBox9.Items.IndexOf(
        IniF.ReadString('SetLog', 'PastSubMode', ''));
      addBands(IniF.ReadString('SetLog', 'ShowBand', ''), ComboBox2.Text);
      //Автозапуск кластера
      if IniF.ReadBool('TelnetCluster', 'AutoStart', False) = True then
        SpeedButton18.Click;

      if ComboBox1.Items.Count >= IniF.ReadInteger('SetLog', 'PastBand', 0) then
        ComboBox1.ItemIndex := IniF.ReadInteger('SetLog', 'PastBand', 0)
      else
        ComboBox1.ItemIndex := 0;
      freqchange := True;
      if Pos('/', DBLookupComboBox1.Text) > 0 then
      begin
        Label51.Visible := True;
        Edit14.Visible := True;
        Label52.Visible := True;
        Edit15.Visible := True;
      end
      else
      begin
        Label51.Visible := False;
        Edit14.Visible := False;
        Label52.Visible := False;
        Edit15.Visible := False;
      end;
    end;
  finally
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  PathMyDoc: string;
  Lang: string = '';
  FallbackLang: string = '';
begin
  GetLanguageIDs(Lang, FallbackLang);
  GetingHint := 0;

  {$IFDEF UNIX}
  PathMyDoc := GetEnvironmentVariable('HOME') + '/EWLog/';
  {$ELSE}
  PathMyDoc := GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
  {$ENDIF UNIX}
  MapView1.CachePath := PathMyDoc + 'cache' + DirectorySeparator;
  Inif := TINIFile.Create(PathMyDoc + 'settings.ini');
  Language := IniF.ReadString('SetLog', 'Language', '');
  if Language = '' then
    Language := FallbackLang;
  SetDefaultLang(Language, PathMyDoc + DirectorySeparator + 'locale');

  FlagList := TImageList.Create(Self);
  FlagSList := TStringList.Create;
  VirtualStringTree1.Images := FlagList;
  useMAPS := INiF.ReadString('SetLog', 'UseMAPS', '');
  EditFlag := False;
  StayForm := True;
  AdifFromMobileSyncStart := False;
  ExportAdifSelect := False;
  ImportAdifMobile := False;
  CheckBox3.Visible := True;
  CheckBox5.Visible := True;
  if useMAPS = 'YES' then
  begin
    MapView1.UseThreads := True;
    MapView1.Center;
  end;

  InitIni;
  LTCPComponent1.ReuseAddress := True;
  LTCPComponent1.Listen(49154);
  LUDPComponent1.Listen(49153);


  if usewsjt then
    WSJT_Timer.Enabled := True;
  if usefldigi then
    Fl_Timer.Enabled := True;

  RegisterLog := IniF.ReadString('SetLog', 'Register', '');
  LoginLog := IniF.ReadString('SetLog', 'Login', '');
  PassLog := IniF.ReadString('SetLog', 'Pass', '');
  sprav := IniF.ReadString('SetLog', 'Sprav', '');
  PrintPrev := IniF.ReadBool('SetLog', 'PrintPrev', False);

  if MenuItem86.Checked = True then
    TRXForm.Show;

  UnUsIndex := 0;
  SetGrid;

  if ShowTRXForm = False then
    MenuItem88.Checked := True
  else
    MenuItem86.Checked := True;

  if IniF.ReadBool('SetLog', 'ImgForm', False) = True then
    MenuItem111.Click
  else
    MenuItem112.Click;

  VirtualStringTree1.ShowHint := True;
  VirtualStringTree1.HintMode := hmHint;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  if MenuItem111.Checked = True then
  begin
    PhotoJPEG.Free;
    PhotoGIF.Free;
    PhotoPNG.Free;
    tIMG.Free;
    PhotoGroup.Free;
  end;
  FlagList.Free;
  FlagSList.Free;
  FreeObj;
  LTCPComponent1.Free;
  LUDPComponent1.Free;
  TrayIcon1.Free;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (ssAlt in Shift) and (chr(Key) = 'H') then
    hiddenSettings.Show;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  Label50.Left := Panel1.Width - 165;
  ComboBox3.Width := MainForm.Width - 655;
  SpeedButton19.Left := Panel9.Width - 27;
  ComboBox8.Width := MainForm.Width - 655;
  SpeedButton25.Left := Panel9.Width - 27;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if InitLog_DB <> 'YES' then
  begin
    if Application.MessageBox(PChar(rDBNotinit), PChar(rWarning),
      MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      SetupForm.Show;
  end;

  if useMAPS = 'YES' then
    CheckBox3.Checked := True
  else
    CheckBox3.Checked := False;
  CheckBox3.Enabled := True;
  MapView1.Zoom := 1;
  MapView1.DoubleBuffered := True;
  MapView1.Active := True;
  CheckUpdatesTimer.Enabled := True;
end;

procedure TMainForm.Label50Click(Sender: TObject);
begin
  Update_Form.Show;
end;

procedure TMainForm.LTCPComponent1Accept(aSocket: TLSocket);
begin
  StatusBar1.Panels.Items[0].Text :=
    rClientConnected + aSocket.PeerAddress;
end;

procedure TMainForm.LTCPComponent1CanSend(aSocket: TLSocket);
var
  Sent: integer;
  TempBuffer: string = '';
begin
  if (AdifDataSyncAll = True) or (AdifDataSyncDate = True) then
  begin
    TempBuffer := BuffToSend;
    while TempBuffer <> '' do
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

procedure TMainForm.LTCPComponent1Disconnect(aSocket: TLSocket);
begin
  MainForm.StatusBar1.Panels.Items[0].Text := rDone;
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
    SysToUTF8(GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
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
      ImportAdifMobile := True;
      Stream.SaveToFile(PathMyDoc + 'ImportMobile.adi');
      AssignFile(AdifFile, PathMyDoc + 'ImportMobile.adi');
      Reset(AdifFile);
      while not EOF(AdifFile) do
      begin
        Readln(AdifFile, s);
        s := StringReplace(s, '<EOR>', '<EOR>'#10, [rfReplaceAll]);
        s := StringReplace(s, '<EOH>', '<EOH>'#10, [rfReplaceAll]);
      end;
      CloseFile(AdifFile);
      Rewrite(AdifFile);
      Writeln(AdifFile, s);
      CloseFile(AdifFile);

      ImportADIFForm.ADIFImport(PathMyDoc + 'ImportMobile.adi', True);
      Stream.Free;
      ImportAdifMobile := False;
    end;
  end;
end;

procedure TMainForm.LTCPSyncDeskAccept(aSocket: TLSocket);
begin
  StatusBar1.Panels.Items[0].Text :=
    rClientConnected + aSocket.PeerAddress;
end;

procedure TMainForm.LTCPSyncDeskError(const msg: string; aSocket: TLSocket);
begin
  MainForm.StatusBar1.Panels.Items[0].Text := asocket.peerAddress + ':' + msg;
end;

procedure TMainForm.LUDPComponent1Receive(aSocket: TLSocket);
var
  mess: string;
begin
  if aSocket.GetMessage(mess) > 0 then
  begin
    if mess = 'GetIP:' + DBLookupComboBox1.KeyValue then
      LUDPComponent1.SendMessage(IdIPWatch1.LocalIP + ':49154')
    else
      StatusBar1.Panels.Items[0].Text := rSyncErrCall;
    if mess = 'Hello' then
      LUDPComponent1.SendMessage('Welcome!');
  end;
end;

procedure TMainForm.LUDPSyncDeskReceive(aSocket: TLSocket);
var
  mess: string;
begin
  if aSocket.GetMessage(mess) > 0 then
  begin
    if mess = 'GetIP' then
      LUDPComponent1.SendMessage(IdIPWatch1.LocalIP + ':6668');
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
  //filterForm.Show;
end;

procedure TMainForm.MenuItem104Click(Sender: TObject);
begin
  LogBookQuery.Close;
  LogBookQuery.SQL.Clear;

  if DefaultDB = 'MySQL' then
  begin
    LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
      + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
      + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `QSLRec` LIKE ' +
      QuotedStr(IntToStr(1)) + ' ORDER BY `UnUsedIndex`' + '');
  end
  else
  begin
    LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
      + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
      + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `QSLRec` LIKE ' +
      QuotedStr(IntToStr(1)) + ' ORDER BY `UnUsedIndex`' + '');
  end;
  LogBookQuery.Open;
  // LOGBookQuery.Last;
end;

procedure TMainForm.MenuItem105Click(Sender: TObject);
begin
  LogBookQuery.Close;
  LogBookQuery.SQL.Clear;

  if DefaultDB = 'MySQL' then
  begin
    LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
      + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
      + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `QSLSent` LIKE ' +
      QuotedStr(IntToStr(1)) + ' ORDER BY `UnUsedIndex`' + '');
  end
  else
  begin
    LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
      + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
      + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `QSLSent` LIKE ' +
      QuotedStr(IntToStr(1)) + ' ORDER BY `UnUsedIndex`' + '');
  end;
  LogBookQuery.Open;
  // LOGBookQuery.Last;
end;

procedure TMainForm.MenuItem106Click(Sender: TObject);
begin
  LogBookQuery.Close;
  LogBookQuery.SQL.Clear;

  if DefaultDB = 'MySQL' then
  begin
    LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
      + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
      + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `QSLSent` LIKE ' +
      QuotedStr(IntToStr(0)) + ' ORDER BY `UnUsedIndex`' + '');
  end
  else
  begin
    LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
      + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
      + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `QSLSent` LIKE ' +
      QuotedStr(IntToStr(0)) + ' ORDER BY `UnUsedIndex`' + '');
  end;
  LogBookQuery.Open;
  // LOGBookQuery.Last;
end;

procedure TMainForm.MenuItem107Click(Sender: TObject);
begin
  LogBookQuery.Close;
  LogBookQuery.SQL.Clear;

  if DefaultDB = 'MySQL' then
  begin
    LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
      + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
      + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `QSLSentAdv` LIKE ' +
      QuotedStr('P') + ' ORDER BY `UnUsedIndex`' + '');
  end
  else
  begin
    LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
      + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
      + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `QSLSentAdv` LIKE ' +
      QuotedStr('P') + ' ORDER BY `UnUsedIndex`' + '');
  end;
  LogBookQuery.Open;
  //LOGBookQuery.Last;

end;

procedure TMainForm.MenuItem108Click(Sender: TObject);
begin
  LogBookQuery.Close;
  LogBookQuery.SQL.Clear;

  if DefaultDB = 'MySQL' then
  begin
    LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
      + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
      + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `QSLSentAdv` LIKE ' +
      QuotedStr('N') + ' ORDER BY `UnUsedIndex`' + '');
  end
  else
  begin
    LogBookQuery.SQL.Add('SELECT `UnUsedIndex`, `CallSign`,' +
      ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
      + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
      + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
      + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
      + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
      + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
      + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
      + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
      + '`LoTWSent`) AS QSLs FROM ' + LogTable + ' WHERE `QSLSentAdv` LIKE ' +
      QuotedStr('N') + ' ORDER BY `UnUsedIndex`' + '');
  end;
  LogBookQuery.Open;
  // LOGBookQuery.Last;
end;

procedure TMainForm.MenuItem109Click(Sender: TObject);
begin
  SelectLogDatabase(LogTable);//, fAllRecords, offsetRec);
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

procedure TMainForm.MenuItem111Click(Sender: TObject);
begin
  PhotoGroup := TGroupBox.Create(Panel13);
  PhotoGroup.Parent := Panel13;
  PhotoGroup.Align := alClient;
  PhotoGroup.Caption := rPhotoFromQRZru;
  if MenuItem86.Checked = True then
  begin
    ShowTRXForm := False;
    TRXForm.Hide;
    MenuItem88.Checked := True;
    MenuItem86.Checked := False;
  end;

  MenuItem112.Checked := False;
  //отоброжение фото с qrz.ru
  if MenuItem111.Checked = True then
  begin
    PhotoJPEG := TJPEGImage.Create;
    PhotoGIF := TGIFImage.Create;
    PhotoPNG := TPortableNetworkGraphic.Create;
    tIMG := TImage.Create(Self);
    tIMG.Parent := PhotoGroup;
    tIMG.Align := alClient;
    tIMG.Proportional := True;
    tIMG.Stretch := True;
  end
  else
  begin
    PhotoJPEG.Free;
    PhotoGIF.Free;
    PhotoPNG.Free;
    tIMG.Free;
    PhotoGroup.Free;
  end;
end;

procedure TMainForm.MenuItem112Click(Sender: TObject);
begin
  if MenuItem111.Checked = True then
  begin
    PhotoJPEG.Free;
    PhotoGIF.Free;
    PhotoPNG.Free;
    tIMG.Free;
    PhotoGroup.Free;
  end;
  MenuItem111.Checked := False;
  MenuItem112.Checked := True;
end;

procedure TMainForm.MenuItem113Click(Sender: TObject);
var
  XNode: PVirtualNode;
  Data: PTreeData;
begin
  XNode := VirtualStringTree1.FocusedNode;
  Data := VirtualStringTree1.GetNodeData(XNode);
  if Length(Data^.Spots) > 1 then
    EditButton1.Text := Data^.Spots;
end;

procedure TMainForm.MenuItem114Click(Sender: TObject);
begin
  VirtualStringTree1.DeleteSelectedNodes;
end;

procedure TMainForm.MenuItem115Click(Sender: TObject);
begin
  if not VirtualStringTree1.IsEmpty then
  begin
    VirtualStringTree1.BeginUpdate;
    VirtualStringTree1.Clear;
    VirtualStringTree1.EndUpdate;
  end;
end;

procedure TMainForm.LangItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  PathMyDoc: string;
begin
   {$IFDEF UNIX}
  PathMyDoc := GetEnvironmentVariable('HOME') + '/EWLog/';
    {$ELSE}
  PathMyDoc := GetEnvironmentVariable('SystemDrive') +
    GetEnvironmentVariable('HOMEPATH') + '\EWLog\';
    {$ENDIF UNIX}
  MenuItem := (Sender as TMenuItem);
  SetDefaultLang(FindISOCountry(MenuItem.Caption), PathMyDoc + 'locale');
  ComboBox7.ItemIndex := 3;
  Language := FindISOCountry(MenuItem.Caption);
  SelDB(DBLookupComboBox1.KeyValue);
  CallLogBook := DBLookupComboBox1.KeyValue;
end;

procedure TMainForm.MenuItem116Click(Sender: TObject);
var
  LangItem: TMenuItem;
  LangList: TStringList;
  i: integer;
  PathMyDoc: string;
begin
     {$IFDEF UNIX}
  PathMyDoc := GetEnvironmentVariable('HOME') + '/EWLog/';
    {$ELSE}
  PathMyDoc := GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
    {$ENDIF UNIX}
  for i := MainForm.ComponentCount - 1 downto 0 do
    if (MainForm.Components[i] is TMenuItem) then
      if (MainForm.Components[i] as TMenuItem).Tag = 99 then
        (MainForm.Components[i] as TMenuItem).Free;

  LangList := TStringList.Create;
  FindLanguageFiles(PathMyDoc + 'locale', LangList);
  for i := 0 to LangList.Count - 1 do
  begin
    LangItem := TMenuItem.Create(Self);
    LangItem.Name := 'LangItem' + IntToStr(i);
    LangItem.Caption := FindCountry(LangList.Strings[i]);
    LangItem.OnClick := @LangItemClick;
    LangItem.Tag := 99;
    MenuItem116.Insert(i, LangItem);
  end;
  LangList.Free;
end;

procedure TMainForm.MenuItem117Click(Sender: TObject);
begin
  PrintSticker_Form.Show;
end;

procedure TMainForm.MenuItem118Click(Sender: TObject);
begin
  try
    if Application.MessageBox(PChar(rCleanUpJournal), PChar(rWarning),
      MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
    begin
      with DeleteQSOQuery do
      begin
        SQL.Clear;
        SQL.Text := 'DELETE FROM ' + LogTable;
        Prepare;
        ExecSQL;
      end;
    end;
  finally
    SQLTransaction1.Commit;
    SelDB(CallLogBook);
  end;
end;

procedure TMainForm.MenuItem119Click(Sender: TObject);
var
  HTTP: THTTPSend;
  updatePATH: string;
  UnZipper: TUnZipper;
begin
   {$IFDEF UNIX}
  updatePATH := GetEnvironmentVariable('HOME') + '/EWLog/';
   {$ELSE}
  updatePATH := SysUtils.GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
   {$ENDIF UNIX}
  ForceDirectories(updatePATH + 'locale');
  HTTP := THTTPSend.Create;
  UnZipper := TUnZipper.Create;
  try
    if HTTP.HTTPMethod('GET', 'http://update.ew8bak.ru/locale.zip') then
      HTTP.Document.SaveToFile(updatePATH + 'updates' + DirectorySeparator +
        'locale.zip');
  finally
    HTTP.Free;
    try
      UnZipper.FileName := updatePATH + 'updates' + DirectorySeparator + 'locale.zip';
      UnZipper.OutputPath := updatePATH + 'locale' + DirectorySeparator;
      UnZipper.Examine;
      UnZipper.UnZipAllFiles;
    finally
      UnZipper.Free;
      ShowMessage(rLanguageComplite);
    end;
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

procedure TMainForm.MenuItem121Click(Sender: TObject);
var
  i: integer;
  PrintArray: array of integer;
  PrintOK: boolean;
  numberToPrint: string;
  NumberCopies: integer;
  ind: integer;
  resStream: TLazarusResourceStream;
  reportPATH: string;
begin
     {$IFDEF UNIX}
  reportPATH := GetEnvironmentVariable('HOME') + '/EWLog/';
   {$ELSE}
  reportPATH := SysUtils.GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
   {$ENDIF UNIX}
  PrintOK := False;
  PrintQuery.Close;
  numberToPrint := '';
  resStream := TLazarusResourceStream.Create('report', nil);
  try
    if DefaultDB = 'MySQL' then
      PrintQuery.DataBase := MainForm.MySQLLOGDBConnection
    else
      PrintQuery.DataBase := MainForm.SQLiteDBConnection;

    if (UnUsIndex <> 0) then
    begin
      for i := 0 to DBGrid1.SelectedRows.Count - 1 do
      begin
        DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
        SetLength(PrintArray, DBGrid1.SelectedRows.Count);
        PrintArray[i] := DBGrid1.DataSource.DataSet.FieldByName(
          'UnUsedIndex').AsInteger;
      end;
      PrintOK := True;
    end;

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

    if PrintOK then
    begin
      for i := 0 to High(PrintArray) do
      begin
        if i > 0 then
          numberToPrint := numberToPrint + ', ';
        numberToPrint := numberToPrint + IntToStr(PrintArray[i]);
      end;
      for i := 0 to Length(PrintArray) - 1 do
      begin
        PrintQuery.SQL.Text :=
          'SELECT * FROM ' + LogTable + ' WHERE `UnUsedIndex` in (' +
          numberToPrint + ')' + ' ORDER BY UnUsedIndex ASC';
      end;
    end;
    PrintOK := False;
    PrintQuery.Open;
    resStream.SaveToFile(reportPATH + 'rep.lrf');
    frReport1.LoadFromFile(reportPATH + 'rep.lrf');
    if PrintPrev = True then
      frReport1.ShowReport
    else
    begin
      ind := Printer.PrinterIndex;
      if not frReport1.PrepareReport then
        Exit;

      with PrintDialog1 do
      begin
        Options := [poPageNums];
        Copies := 1;
        Collate := True;
        FromPage := 1;
        ToPage := frReport1.EMFPages.Count;
        MaxPage := frReport1.EMFPages.Count;
        if Execute then
        begin
          if (Printer.PrinterIndex <> ind) or frReport1.CanRebuild or
            frReport1.ChangePrinter(ind, Printer.PrinterIndex) then
            frReport1.PrepareReport
          else
            exit;
          if PrintDialog1.PrintRange = prPageNums then
          begin
            FromPage := PrintDialog1.FromPage;
            ToPage := PrintDialog1.ToPage;
          end;
          NumberCopies := PrintDialog1.Copies;
          frReport1.PrintPreparedReport(IntToStr(FromPage) + '-' + IntToStr(ToPage),
            NumberCopies);
        end;
      end;
    end;
  finally
    resStream.Free;
  end;
end;

procedure TMainForm.MenuItem122Click(Sender: TObject);
var
  i: integer;
  PrintArray: array of integer;
  PrintOK: boolean;
  numberToPrint: string;
  NumberCopies: integer;
  ind: integer;
  resStream: TLazarusResourceStream;
  reportPATH: string;
begin
   {$IFDEF UNIX}
  reportPATH := GetEnvironmentVariable('HOME') + '/EWLog/';
   {$ELSE}
  reportPATH := SysUtils.GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
   {$ENDIF UNIX}
  PrintOK := False;
  PrintQuery.Close;
  numberToPrint := '';
  resStream := TLazarusResourceStream.Create('report', nil);
  try
    if DefaultDB = 'MySQL' then
      PrintQuery.DataBase := MainForm.MySQLLOGDBConnection
    else
      PrintQuery.DataBase := MainForm.SQLiteDBConnection;

    if (UnUsIndex <> 0) then
    begin
      for i := 0 to DBGrid1.SelectedRows.Count - 1 do
      begin
        DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
        SetLength(PrintArray, DBGrid1.SelectedRows.Count);
        PrintArray[i] := DBGrid1.DataSource.DataSet.FieldByName(
          'UnUsedIndex').AsInteger;
      end;
      PrintOK := True;
    end;

    if PrintOK then
    begin
      for i := 0 to High(PrintArray) do
      begin
        if i > 0 then
          numberToPrint := numberToPrint + ', ';
        numberToPrint := numberToPrint + IntToStr(PrintArray[i]);
      end;
      for i := 0 to Length(PrintArray) - 1 do
      begin
        PrintQuery.SQL.Text :=
          'SELECT * FROM ' + LogTable + ' WHERE `UnUsedIndex` in (' +
          numberToPrint + ')' + ' ORDER BY UnUsedIndex ASC';
      end;
    end;
    PrintOK := False;
    PrintQuery.Open;
    resStream.SaveToFile(reportPATH + 'rep.lrf');
    frReport1.LoadFromFile(reportPATH + 'rep.lrf');


    if PrintPrev = True then
      frReport1.ShowReport
    else
    begin
      ind := Printer.PrinterIndex;
      if not frReport1.PrepareReport then
        Exit;

      with PrintDialog1 do
      begin
        Options := [poPageNums];
        Copies := 1;
        Collate := True;
        FromPage := 1;
        ToPage := frReport1.EMFPages.Count;
        MaxPage := frReport1.EMFPages.Count;
        if Execute then
        begin
          if (Printer.PrinterIndex <> ind) or frReport1.CanRebuild or
            frReport1.ChangePrinter(ind, Printer.PrinterIndex) then
            frReport1.PrepareReport
          else
            exit;
          if PrintDialog1.PrintRange = prPageNums then
          begin
            FromPage := PrintDialog1.FromPage;
            ToPage := PrintDialog1.ToPage;
          end;
          NumberCopies := PrintDialog1.Copies;
          frReport1.PrintPreparedReport(IntToStr(FromPage) + '-' + IntToStr(ToPage),
            NumberCopies);
        end;
      end;
    end;
  finally
    resStream.Free;
  end;
end;

procedure TMainForm.MenuItem123Click(Sender: TObject);
begin
  FM_Form.Show;
end;

procedure TMainForm.MenuItem124Click(Sender: TObject);
begin
  MM_Form.Show;
end;

//Поставить QSO в очередь на печать
procedure TMainForm.MenuItem12Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;

end;

//QSL напечатана
procedure TMainForm.MenuItem13Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;
end;

//QSL отправлена
procedure TMainForm.MenuItem14Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;

end;

//QSL не отправлена
procedure TMainForm.MenuItem16Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;

end;

//QSL не отправлять
procedure TMainForm.MenuItem17Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;

end;

//QSL получена через B - бюро
procedure TMainForm.MenuItem21Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;

end;

//QSL Получена через D - Direct
procedure TMainForm.MenuItem22Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;

end;

//QSL получена через E - Electronic
procedure TMainForm.MenuItem23Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;

end;

//QSL получена через M - менеджера
procedure TMainForm.MenuItem24Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;

end;

//QSL получена через G - GlobalQSL
procedure TMainForm.MenuItem25Click(Sender: TObject);
var
  i, recnom: integer;
begin
  if (UnUsIndex <> 0) then
  begin
    recnom := 0;
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;

end;

//QSL Отправелена через B - Бюро
procedure TMainForm.MenuItem27Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;

end;

//QSL отправлена через D - Direct
procedure TMainForm.MenuItem28Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;

end;

//QSL отправлена через E - Electronic
procedure TMainForm.MenuItem29Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;

end;

//QSL отправлена через M - менеджер
procedure TMainForm.MenuItem30Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
  end;

end;

//QSL отправлена через G - GlobalQSL
procedure TMainForm.MenuItem31Click(Sender: TObject);
var
  i, recnom: integer;
begin
  recnom := 0;
  if (UnUsIndex <> 0) then
  begin
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      UnUsIndex := DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
      recnom := LOGBookQuery.RecNo;
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
    DBGrid1.DataSource.DataSet.RecNo := recnom;
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
    exportAdifForm.Show;
    for i := 0 to DBGrid1.SelectedRows.Count - 1 do
    begin
      DBGrid1.DataSource.DataSet.GotoBookmark(Pointer(DBGrid1.SelectedRows.Items[i]));
      SetLength(ExportAdifArray, DBGrid1.SelectedRows.Count);
      ExportAdifArray[i] := DBGrid1.DataSource.DataSet.FieldByName(
        'UnUsedIndex').AsInteger;
    end;
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
      submode := DBGrid1.DataSource.DataSet.FieldByName('QSOSubMode').AsString;
      rsts := DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
      rstr := DBGrid1.DataSource.DataSet.FieldByName('QSOReportRecived').AsString;
      locat := DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;
      qslinf := SetQSLInfo;
      information := 1;
      inform := 1;
      Start;
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
      submode := DBGrid1.DataSource.DataSet.FieldByName('QSOSubMode').AsString;
      rst := DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
      qslinf := SetQSLInfo;
      information := 1;
      Start;
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
  EditQSO_Form.ComboBox1.Items := ComboBox1.Items;
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
      EditQSO_Form.ComboBox2.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;
      EditQSO_Form.ComboBox9.Text :=
        DBGrid1.DataSource.DataSet.FieldByName('QSOSubMode').AsString;

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
      EditQSO_Form.CheckBox7.Checked :=
        DBGrid1.DataSource.DataSet.FieldByName('LoTWSent').AsBoolean;

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

      EditQSO_Form.ComboBox3.Text :=
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
  wsjt_args := '';
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

procedure TMainForm.MenuItem48Click(Sender: TObject);
begin
  SynDBDate.Show;
end;

procedure TMainForm.MenuItem49Click(Sender: TObject);
var
  freq: string;
  freq2: double;
begin
  SendTelnetSpot.Show;
  SendTelnetSpot.Edit1.Text :=
    DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
  freq := DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
  Delete(freq, length(freq) - 2, 1);
  freq2 := StrToFloat(freq);
  SendTelnetSpot.ComboBox1.Text := FloatToStr(freq2);
end;

procedure TMainForm.MenuItem51Click(Sender: TObject);
begin
  if LogBookQuery.RecordCount > 0 then
  begin
    if Application.MessageBox(PChar(rDeleteRecord +
      DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString + '?!'),
      PChar(rWarning), MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
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

procedure TMainForm.MenuItem58Click(Sender: TObject);
begin
 { if MySQLLOGDBConnection.Connected then
  MySQLLOGDBConnection.ExecuteDirect('')
  else begin
  SQLiteDBConnection.ExecuteDirect('END; VACUUM; REINDEX; BEGIN; COMMIT;');
  end;     }
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
  Close;
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
  fl_args := '';
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
        StatusBar1.Panels.Items[0].Text := rDuplicates + IntToStr(err);
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
      rSyncOK + IntToStr(err) + rSync + IntToStr(ok) + rQSOsync;
  except
    ShowMessage(rDBError);
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
      ShowMessage(rMySQLNotSet);
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
          StatusBar1.Panels.Items[0].Text := rDuplicates + IntToStr(err);
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
        rSyncOK + IntToStr(err) + rSync + IntToStr(ok) + rQSOsync;
    end;
  except
    ShowMessage(rDBError);
  end;
end;

procedure TMainForm.MenuItem84Click(Sender: TObject);
begin
  SettingsCAT.Show;
end;

procedure TMainForm.MenuItem86Click(Sender: TObject);
begin
  if MenuItem111.Checked = True then
  begin
    PhotoJPEG.Free;
    PhotoGIF.Free;
    PhotoPNG.Free;
    tIMG.Free;
    PhotoGroup.Free;
  end;

  MenuItem88.Checked := False;
  MenuItem111.Checked := False;
  MenuItem112.Checked := True;
  if MenuItem86.Checked = True then
  begin
    TRXForm.Parent := Panel13;
    TRXForm.BorderStyle := bsNone;
    TRXForm.Align := alClient;
    TRXForm.Show;
    ShowTRXForm := True;
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
  //очищаем обьекты
  FreeObj;
  if dbSel = 'SQLite' then
  begin
    InitializeDB('MySQL');
    MenuItem89.Caption := rSwitchDBSQLIte;
  end
  else
  begin
    InitializeDB('SQLite');
    MenuItem89.Caption := rSwitchDBMySQL;
  end;
end;

procedure TMainForm.FreeObj;
var
  i: integer;
begin
  FreeAndNil(PrefixProvinceList);
  FreeAndNil(PrefixARRLList);
  FreeAndNil(UniqueCallsList);
  FreeAndNil(subModesList);
  for i := 0 to 1000 do
  begin
    FreeAndNil(PrefixExpARRLArray[i].reg);
    FreeAndNil(PrefixExpProvinceArray[i].reg);
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

procedure TMainForm.ScrollBar1Change(Sender: TObject);
begin
  SelectLogDatabase(LogTable);
end;

procedure TMainForm.SpeedButton16Click(Sender: TObject);
begin
  CheckForm := 'Main';
  if EditButton1.Text <> '' then
    InformationForm.Show
  else
    ShowMessage(rNotCallsign);
end;

procedure TMainForm.SpeedButton17Click(Sender: TObject);
begin
  PopupMenu2.PopUp;
end;

procedure TMainForm.SpeedButton18MouseLeave(Sender: TObject);
begin
  StatusBar1.Panels.Items[0].Text := '';
end;

procedure TMainForm.SpeedButton18MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  StatusBar1.Panels.Items[0].Text := rDXClusterConnecting;
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
  if not VirtualStringTree1.IsEmpty then
  begin
    VirtualStringTree1.BeginUpdate;
    VirtualStringTree1.Clear;
    VirtualStringTree1.EndUpdate;
  end;
end;

procedure TMainForm.SpeedButton20MouseLeave(Sender: TObject);
begin
  StatusBar1.Panels.Items[0].Text := '';
end;

procedure TMainForm.SpeedButton20MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  StatusBar1.Panels.Items[0].Text := rDXClusterWindowClear;
end;

procedure TMainForm.SpeedButton21Click(Sender: TObject);
begin
  dxClient.SendMessage('bye' + #13#10);
  SpeedButton21.Enabled := False;
  SpeedButton27.Enabled := False;
  SpeedButton18.Enabled := True;
  SpeedButton24.Enabled := True;
  SpeedButton28.Enabled := False;
  SpeedButton22.Enabled := False;
end;

procedure TMainForm.SpeedButton21MouseLeave(Sender: TObject);
begin
  StatusBar1.Panels.Items[0].Text := '';
end;

procedure TMainForm.SpeedButton21MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  StatusBar1.Panels.Items[0].Text := rDXClusterDisconnecting;
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
  StatusBar1.Panels.Items[0].Text := rSendSpot;
end;

procedure TMainForm.SpeedButton23Click(Sender: TObject);
begin
  ClusterFilter.Show;
end;

procedure TMainForm.SpeedButton24Click(Sender: TObject);
begin
  dxClient.Host := HostCluster;
  dxClient.Port := StrToInt(PortCluster);
  if dxClient.Connect = True then
  begin
    SpeedButton27.Enabled := True;
    SpeedButton28.Enabled := True;
    SpeedButton22.Enabled := True;
    SpeedButton21.Enabled := True;
  end;
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
  QSL_SENT_ADV, QSL_SENT, dift: string;
  DigiBand: double;
  NameBand: string;
  DigiBand_String: string;
  timeQSO: TTime;
  FmtStngs: TFormatSettings;
  state: string;
  lat, lon: currency;
  SQSO: TQSO;
begin
  state := '';
  QSL_SENT := '';
  QSL_SENT_ADV := '';
  NameBand := '';
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
      ShowMessage(rEnCall)
    else
    begin

      if ComboBox7.ItemIndex = 0 then
      begin
        QSL_SENT_ADV := 'T';
        QSL_SENT := '1';
      end;
      if ComboBox7.ItemIndex = 1 then
      begin
        QSL_SENT_ADV := 'P';
        QSL_SENT := '0';
      end;
      if ComboBox7.ItemIndex = 2 then
      begin
        QSL_SENT_ADV := 'Q';
        QSL_SENT := '0';
      end;
      if ComboBox7.ItemIndex = 3 then
      begin
        QSL_SENT_ADV := 'F';
        QSL_SENT := '0';
      end;
      if ComboBox7.ItemIndex = 4 then
      begin
        QSL_SENT_ADV := 'N';
        QSL_SENT := '0';
      end;

      if IniF.ReadString('SetLog', 'ShowBand', '') = 'True' then
        NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(
          ComboBox1.Text, ComboBox2.Text))
      else
        NameBand := ComboBox1.Text;

      DigiBand_String := NameBand;
      Delete(DigiBand_String, length(DigiBand_String) - 2, 1);
      DigiBand := dmFunc.GetDigiBandFromFreq(DigiBand_String);

      SQSO.CallSing := EditButton1.Text;
      SQSO.QSODate := DateEdit1.Date;
      SQSO.QSOTime := FormatDateTime('hh:nn', timeQSO);
      SQSO.QSOBand := NameBand;
      SQSO.QSOMode := ComboBox2.Text;
      SQSO.QSOSubMode := ComboBox9.Text;
      SQSO.QSOReportSent := ComboBox4.Text;
      SQSO.QSOReportRecived := ComboBox5.Text;
      SQSO.OmName := Edit1.Text;
      SQSO.OmQTH := Edit2.Text;
      SQSO.State0 := Edit4.Text;
      SQSO.Grid := Edit3.Text;
      SQSO.IOTA := Edit5.Text;
      SQSO.QSLManager := Edit6.Text;
      SQSO.QSLSent := QSL_SENT;
      SQSO.QSLSentAdv := QSL_SENT_ADV;
      SQSO.QSLSentDate := 'NULL';
      SQSO.QSLRec := '0';
      SQSO.QSLRecDate := 'NULL';
      SQSO.MainPrefix := Label38.Caption;
      SQSO.DXCCPrefix := Label34.Caption;
      SQSO.CQZone := Label45.Caption;
      SQSO.ITUZone := Label47.Caption;
      SQSO.QSOAddInfo := Edit11.Text;
      SQSO.Marker := BoolToStr(CheckBox5.Checked);
      SQSO.ManualSet := 0;
      SQSO.DigiBand := FloatToStr(DigiBand);
      SQSO.Continent := Label43.Caption;
      SQSO.ShortNote := Edit11.Text;
      SQSO.QSLReceQSLcc := 0;
      SQSO.LotWRec := '';
      SQSO.LotWRecDate := 'NULL';

      if not StateToQSLInfo then
      SQSO.QSLInfo := SetQSLInfo
      else begin
      if (Edit14.Text <> '') or (Edit15.Text <> '') then
      SQSO.QSLInfo:= Edit15.Text + ' ' + Edit14.Text else
      SQSO.QSLInfo:=SetQSLInfo;
      end;

      SQSO.Call := dmFunc.ExtractCallsign(EditButton1.Text);
      SQSO.State1 := Edit10.Text;
      SQSO.State2 := Edit9.Text;
      SQSO.State3 := Edit8.Text;
      SQSO.State4 := Edit7.Text;
      SQSO.WPX := dmFunc.ExtractWPXPrefix(EditButton1.Text);
      SQSO.AwardsEx := 'NULL';
      SQSO.ValidDX := IntToStr(1);
      SQSO.SRX := 0;
      SQSO.SRX_String := '';
      SQSO.STX := 0;
      SQSO.STX_String := '';
      SQSO.SAT_NAME := '';
      SQSO.SAT_MODE := '';
      SQSO.PROP_MODE := '';
      SQSO.LotWSent := 0;
      SQSO.QSL_RCVD_VIA := '';
      SQSO.QSL_SENT_VIA := ComboBox6.Text;
      SQSO.DXCC := IntToStr(DXCCNum);
      SQSO.USERS := '';
      SQSO.NoCalcDXCC := 0;
      SQSO.SYNC := 0;

      if SetLoc <> '' then
        SQSO.My_Grid := SetLoc;

      if Edit14.Text <> '' then
        SQSO.My_Grid := Edit14.Text;

      SQSO.My_State := Edit15.Text;

      if (SQSO.My_Grid <> '') and (dmFunc.IsLocOK(SQSO.My_Grid)) then
      begin
        dmFunc.CoordinateFromLocator(SQSO.My_Grid, lat, lon);
        SQSO.My_Lat := CurrToStr(lat);
        SQSO.My_Lon := CurrToStr(lon);
      end
      else
      begin
        SQSO.My_Lat := '';
        SQSO.My_Lon := '';
      end;
      SQSO.NLogDB := LogTable;
      SaveQSO(SQSO);

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
          submode := ComboBox9.Text;
          rst := ComboBox4.Text;
          qslinf := SetQSLInfo;
          Start;
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
          submode := ComboBox9.Text;
          rsts := ComboBox4.Text;
          rstr := ComboBox5.Text;
          locat := Edit3.Text;
          qslinf := SetQSLInfo;
          Start;
        end;
      end;

      if AutoHamQTH = True then
      begin
        SendHamQTHThread := TSendHamQTHThread.Create;
        if Assigned(SendHamQTHThread.FatalException) then
          raise SendHamQTHThread.FatalException;
        with SendHamQTHThread do
        begin
          userid := HamQTHLogin;
          userpwd := HamQTHPassword;
          call := EditButton1.Text;
          startdate := DateEdit1.Date;
          starttime := DateTimePicker1.Time;
          freq := NameBand;
          mode := ComboBox2.Text;
          submode := ComboBox9.Text;
          rsts := ComboBox4.Text;
          rstr := ComboBox5.Text;
          opname := Edit1.Text;
          opqth := Edit2.Text;
          opcont := Label43.Caption;
          mygrid := '';
          locat := Edit3.Text;
          qslinf := SetQSLInfo;
          Start;
        end;
      end;

      //Отправка в QRZ.COM
      if AutoQRZCom = True then
      begin
        SendQRZComThread := TSendQRZComThread.Create;
        if Assigned(SendQRZComThread.FatalException) then
          raise SendQRZComThread.FatalException;
        with SendQRZComThread do
        begin
          userid := QRZComLogin;
          userpwd := QRZComPassword;
          call := EditButton1.Text;
          startdate := DateEdit1.Date;
          starttime := DateTimePicker1.Time;
          freq := NameBand;
          mode := ComboBox2.Text;
          submode := ComboBox9.Text;
          rsts := ComboBox4.Text;
          rstr := ComboBox5.Text;
          opname := Edit1.Text;
          opqth := Edit2.Text;
          opcont := Label43.Caption;
          mygrid := '';
          locat := Edit3.Text;
          qslinf := SetQSLInfo;
          Start;
        end;
      end;

      //Отправка в ClubLog
      if AutoClubLog = True then
      begin
        SendClubLogThread := TSendClubLogThread.Create;
        if Assigned(SendClubLogThread.FatalException) then
          raise SendClubLogThread.FatalException;
        with SendClubLogThread do
        begin
          userid := ClubLogLogin;
          userpwd := ClubLogPassword;
          usercall := CallLogBook;
          call := EditButton1.Text;
          startdate := DateEdit1.Date;
          starttime := DateTimePicker1.Time;
          freq := NameBand;
          mode := ComboBox2.Text;
          submode := ComboBox9.Text;
          rsts := ComboBox4.Text;
          rstr := ComboBox5.Text;
          locat := Edit3.Text;
          qslinf := SetQSLInfo;
          Start;
        end;
      end;

      //Скрытые настройки, отправка в CloudLog
      if hiddenSettings.apisend then
        hiddenSettings.SendQSO(hiddenSettings.API_key, hiddenSettings.address_serv +
          '/index.php/api/qso/', EditButton1.Text,
          FormatDateTime('yyyymmdd', DateEdit1.Date), FormatDateTime(
          'hhnnss', DateTimePicker1.Time), NameBand, ComboBox2.Text, ComboBox9.Text,
          ComboBox4.Text, ComboBox5.Text, Edit1.Text, Edit2.Text, Edit4.Text,
          Edit3.Text, Edit11.Text);

      SelDB(CallLogBook);
      Clr();
    end;
  end;

  if EditFlag = True then
  begin
    if Pos('M', ComboBox1.Text) > 0 then
      NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(
        ComboBox1.Text, ComboBox2.Text))
    else
      NameBand := ComboBox1.Text;

    DigiBand_String := NameBand;
    Delete(DigiBand_String, length(DigiBand_String) - 2, 1);
    DigiBand := dmFunc.GetDigiBandFromFreq(DigiBand_String);

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
      Params.ParamByName('Call').AsString := dmFunc.ExtractCallsign(EditButton1.Text);
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
    EditFlag := False;
    CheckBox1.Checked := True;
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
  StatusBar1.Panels.Items[0].Text := rSaveQSO;
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
  StatusBar1.Panels.Items[0].Text := rClearQSO;
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

procedure TMainForm.VirtualStringTree1Change(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  VirtualStringTree1.Refresh;
end;

procedure TMainForm.VirtualStringTree1CompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: integer);
begin
  with TVirtualStringTree(Sender) do
    Result := AnsiCompareText(Text[Node1, Column], Text[Node2, Column]);
end;

procedure TMainForm.VirtualStringTree1DblClick(Sender: TObject);
var
  XNode: PVirtualNode;
  Data: PTreeData;
begin
  XNode := VirtualStringTree1.FocusedNode;
  Data := VirtualStringTree1.GetNodeData(XNode);
  if Length(Data^.Spots) > 1 then
    EditButton1.Text := Data^.Spots;

end;

procedure TMainForm.VirtualStringTree1FocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  VirtualStringTree1.Refresh;
end;

procedure TMainForm.VirtualStringTree1FreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PTreeData;
begin
  Data := VirtualStringTree1.GetNodeData(Node);
  if Assigned(Data) then
  begin
    Data^.DX := '';
    Data^.Spots := '';
    Data^.Call := '';
    Data^.Freq := '';
    Data^.Moda := '';
    Data^.Comment := '';
    Data^.Time := '';
    Data^.Loc := '';
    Data^.Country := '';
  end;
end;

procedure TMainForm.VirtualStringTree1GetHint(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex;
  var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: string);
var
  Data: PTreeData;
begin
  Data := Sender.GetNodeData(Node);
  HintText := SearchCountry(Data^.Spots, True);
end;

procedure TMainForm.VirtualStringTree1GetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: boolean; var ImageIndex: integer);
var
  Data: PTreeData;
begin
  if Column <> 8 then
    Exit;

  ImageIndex := -1;
  Data := VirtualStringTree1.GetNodeData(Node);
  if Assigned(Data) then
  begin
    ImageIndex := FlagSList.IndexOf(dmFunc.ReplaceCountry(Data^.Country));
  end;
end;

procedure TMainForm.VirtualStringTree1GetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: integer);
begin
  NodeDataSize := SizeOf(TTreeData);
end;

procedure TMainForm.VirtualStringTree1GetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PTreeData;
begin
  Data := VirtualStringTree1.GetNodeData(Node);
  case Column of
    0: CellText := Data^.DX;
    1: CellText := Data^.Spots;
    2: CellText := Data^.Call;
    3: CellText := Data^.Freq;
    4: CellText := Data^.Moda;
    5: CellText := Data^.Comment;
    6: CellText := Data^.Time;
    7: CellText := Data^.Loc;
    8: CellText := Data^.Country;
  end;
end;

procedure TMainForm.VirtualStringTree1HeaderClick(Sender: TVTHeader;
  HitInfo: TVTHeaderHitInfo);
begin
  if HitInfo.Button = mbLeft then
  begin
    VirtualStringTree1.Header.SortColumn := HitInfo.Column;
    if VirtualStringTree1.Header.SortDirection = sdAscending then
      VirtualStringTree1.Header.SortDirection := sdDescending
    else
      VirtualStringTree1.Header.SortDirection := sdAscending;
    VirtualStringTree1.SortTree(HitInfo.Column, VirtualStringTree1.Header.SortDirection);
  end;
end;

procedure TMainForm.VirtualStringTree1NodeClick(Sender: TBaseVirtualTree;
  const HitInfo: THitInfo);
var
  XNode: PVirtualNode;
begin
  XNode := VirtualStringTree1.FocusedNode;
  VirtualStringTree1.Selected[XNode] := True;
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
          TrayIcon1.BalloonHint := rLogConWSJT;
          TrayIcon1.ShowBalloonHint;
          {$ELSE}
          SysUtils.ExecuteProcess('/usr/bin/notify-send',
            ['EWLog', rLogConWSJT]);
          {$ENDIF}
          if IniF.ReadString('FLDIGI', 'USEFLDIGI', '') = 'YES' then
            MenuItem74.Enabled := False;
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
      TrayIcon1.BalloonHint := rLogNConWSJT;
      TrayIcon1.ShowBalloonHint;
      {$ELSE}
      SysUtils.ExecuteProcess('/usr/bin/notify-send',
        ['EWLog', rLogNConWSJT]);
      {$ENDIF}
      if IniF.ReadString('FLDIGI', 'USEFLDIGI', '') = 'YES' then
        MenuItem74.Enabled := True;
      //    ComboBox2.ItemIndex := lastBand;
      //ComboBox2Change(Sender);
      //    ComboBox2CloseUp(Sender);
      Clr();
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
    dxClient.SendMessage(Trim(Format('dx %s %s %s', [freq, call, comment])) + #13#10);
  except
    on E: Exception do
      Memo1.Append(E.Message);
  end;
end;


end.
