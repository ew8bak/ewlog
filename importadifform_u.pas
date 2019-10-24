unit ImportADIFForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, EditBtn, LCLType, LConvEncoding, LazUTF8, LCLIntf;

resourcestring
  rDone = 'Done';
  rImport = 'Import';
  rImportRecord = 'Imported Records';
  rFileError = 'Error file:';
  rImportErrors = 'Import Errors';
  rNumberDup = 'Number of duplicates';
  rNothingImport = 'Nothing to import';
  rProcessing = 'Processing';

const
  ERR_FILE = 'errors.adi';
  MyWhiteSpace = [#0..#31];

type

  { TImportADIFForm }

  TImportADIFForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    FileNameEdit1: TFileNameEdit;
    GroupBox1: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblErrorLog: TLabel;
    lblErrors: TLabel;
    lblCount: TLabel;
    lblComplete: TLabel;
    Memo1: TMemo;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    ImportQuery: TSQLQuery;
    DUPEQuery: TSQLQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FileNameEdit1ButtonClick(Sender: TObject);
    procedure FileNameEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblErrorLogClick(Sender: TObject);
  private
    procedure WriteWrongADIF(Lines: array of string);
    { private declarations }
  public
    procedure ADIFImport;
    { public declarations }
  end;

var
  ImportADIFForm: TImportADIFForm;

implementation

uses dmFunc_U, MainForm_U;

{$R *.lfm}

{ TImportADIFForm }

procedure TImportADIFForm.WriteWrongADIF(Lines: array of string);
var
  f: TextFile;
  i: integer;
  PathMyDoc: string;
begin
   {$IFDEF UNIX}
  PathMyDoc := GetEnvironmentVariable('HOME') + '/EWLog/';
    {$ELSE}
  PathMyDoc := GetEnvironmentVariable('SystemDrive') +
    GetEnvironmentVariable('HOMEPATH') + '\EWLog\';
    {$ENDIF UNIX}


  if FileExists(PathMyDoc + ERR_FILE) then
  begin
    AssignFile(f, PathMyDoc + ERR_FILE);
    Append(f);
    for i := 0 to Length(Lines) - 1 do
      WriteLn(f, Lines[i]);
    writeln(f);
    CloseFile(f);
  end
  else
  begin
    AssignFile(f, PathMyDoc + ERR_FILE);
    Rewrite(f);
    for i := 0 to Length(Lines) - 1 do
      WriteLn(f, Lines[i]);
    writeln(f);
    CloseFile(f);
  end;
  lblErrorLog.Caption := rFileError + ERR_FILE;
  lblErrorLog.Font.Color := clBlue;
  lblErrorLog.Cursor := crHandPoint;
end;

procedure TImportADIFForm.ADIFImport;
var
  PathMyDoc: string;
  f: TextFile;
  PosEOH: word;
  PosEOR: word;
  PosCall: word;
  PosName: word;
  PosRSTS: word;
  PosQTH: word;
  PosRSTR: word;
  PosTon: word;
  PosToff: word;
  PosQSLR: word;
  PosQSLS: word;
  PosMode: word;
  PosFreq: word;
  PosPWR: word;
  PosCom: word;
  PosNot: word;
  PosDate: word;
  PosDat1: word;
  PosQSLV: word;
  PosLoc: word;
  PosMLoc: word;
  PosSRX: word;
  PosSTX: word;
  PosBand: word;
  PosIOTA: word;
  PosWAZ: word;
  PosITUZ: word;
  PosDXCC: word;
  PosAward: word;
  PosCounty: word;
  PosState: word;
  PosLQslS: word;
  PosLQslR: word;
  PosLQslSDate: word;
  PosLQslRDate: word;
  PosPFX: word;
  PosCONT: word;
  PosQSLMSG: word;
  PosDXCC2: word;

  PosQSLRDATE: word;
  PosQSLSDATE: word;
  PosQSL_RCVD_VIA: word;
  PosEQSL_QSLRDATE: word;
  PosEQSL_QSLSDATE: word;
  PosEQSL_QSL_RCVD: word;
  PosEQSL_QSL_SENT: word;

  Call: string;
  sName: string;
  RSTS: string;
  QTH: string;
  RSTR: string;
  Ton: string;
  Toff: string;
  QSLR: string;
  QSLS: string;
  Mode: string;
  Freq: string;
  PWR: string;
  Com: string;
  Note: string;
  Date: string;
  QSLV: string;
  Loc: string;
  MLoc: string;
  SRX: string;
  STX: string;
  Band: string;
  IOTA: string;
  ITUZ: string;
  WAZ: string;
  DXCC: string;
  Award: string;
  County: string;
  State: string;
  LQslS: string;
  LQslR: string;
  LQslSDate: string;
  LQslRDate: string;
  PFX: string;
  CONT: string;
  QSLMSG: string;
  DXCC2: string;
  QSLRDATE: string;
  QSLSDATE: string;
  QSL_RCVD_VIA: string;
  EQSL_QSL_RCVD: string;
  EQSL_QSL_SENT: string;

  a: string;
  Data: string;
  i: integer;
  sCount: string;
  Count: integer;
  QSODate: string;
  RecCount: longint = 0;
  Lines: array of string;
  Len: integer;
  id_waz, id_itu: string;
  err, errr: integer;

  MyPower: string = '';
  MyLoc: string;
  yyyy, mm, dd, yyyy2, mm2, dd2, yyyy3, mm3, dd3: word;
begin
     {$IFDEF UNIX}
  PathMyDoc := GetEnvironmentVariable('HOME') + '/EWLog/';
    {$ELSE}
  PathMyDoc := GetEnvironmentVariable('SystemDrive') +
    GetEnvironmentVariable('HOMEPATH') + '\EWLog\';
    {$ENDIF UNIX}
  errr := 0;
  lblComplete.Visible := False;
  RecCount := 0;
  err := 0;
  lblCount.Caption := rImportRecord;
  PosEOH := 0;
  PosEOR := 0;
  MyPower := '5 W';
  MyLoc := '';

  try
    try
      AssignFile(f, SysToUTF8(FileNameEdit1.Text));
      Reset(f);
      Button1.Enabled := False;
      Len := 0;
      if MainForm.ImportAdifMobile = False then
      begin
        while not (PosEOH > 0) do //Skip header
        begin
          Readln(f, a);
          a := UpperCase(a);
          PosEOH := Pos('<EOH>', a);
        end;
      end;
      while not EOF(f) do
      begin
        Call := '';
        sName := '';
        RSTS := '';
        QTH := '';
        RSTR := '';
        Ton := '';
        Toff := '';
        QSLR := '';
        QSLS := '';
        Mode := '';
        Freq := '';
        PWR := '';
        Com := '';
        Note := '';
        Date := '';
        QSLV := '';
        Loc := '';
        MLoc := '';
        SRX := '';
        STX := '';
        Band := '';
        IOTA := '';
        WAZ := '';
        ITUZ := '';
        DXCC := '';
        PosEOR := 0;
        Award := '';
        County := '';
        State := '';
        LQslS := '';
        LQslR := '';
        LQslSDate := '';
        LQslRDate := '';
        PFX := '';
        CONT := '';
        QSLMSG := '';
        DXCC2 := '';
        QSLRDATE := '';
        QSLSDATE := '';
        QSL_RCVD_VIA := '';
        EQSL_QSL_RCVD := '';
        EQSL_QSL_SENT := '';

        Count := 0;
        Len := 0;
        while not ((PosEOR > 0) or EOF(f)) do
        begin
          Inc(len);

          SetLength(Lines, Len);
          Readln(f, a);
          a := Trim(a);
          Lines[Len - 1] := a;
          Data := a;
          a := UpperCase(a);
          //inc(RecCount);
          PosDat1 := 0;
          PosEOR := Pos('<EOR>', a);
          PosCALL := Pos('<CALL:', a);
          PosName := Pos('<NAME:', a);
          PosRSTs := Pos('<RST_SENT:', a);
          PosQTH := Pos('<QTH:', a);
          PosRSTR := Pos('<RST_RCVD:', a);
          PosTON := Pos('<TIME_ON:', a);
          PosTOFF := Pos('<TIME_OFF:', a);
          PosQSLR := Pos('<QSL_RCVD:', a);
          PosQSLS := Pos('<QSL_SENT:', a);
          PosMode := Pos('<MODE:', a);
          PosFREQ := Pos('<FREQ:', a);
          PosPWR := Pos('<TX_PWR:', a);
          PosCom := Pos('<COMMENT:', a);
          PosNot := Pos('<NOTES:', a);
          PosDate := Pos('<QSO_DATE:8:D>', a);
          if PosDate < 1 then
            PosDat1 := Pos('<QSO_DATE:', a);
          PosQSLV := Pos('<QSL_VIA:', a);
          PosMLoc := Pos('<MY_GRIDSQUARE:', a);
          PosLoc := Pos('<GRIDSQUARE:', a);
          PosSRX := Pos('<SRX:', a);
          PosSTX := Pos('<STX:', a);
          PosBand := Pos('<BAND:', a);
          PosIOTA := Pos('<IOTA:', a);
          PosWAZ := Pos('<CQZ:', a);
          PosITUZ := Pos('<ITUZ:', a);
          PosAward := Pos('<AWARD:', a);
          PosDXCC := Pos('<DXCC_PREF:', a);
          PosDXCC2 := Pos('<DXCC:', a);
          PosPFX := Pos('<PFX:', a);
          PosCONT := Pos('<CONT:', a);
          PosQSLMSG := Pos('<QSLMSG:', a);
          PosCounty := Pos('<CNTY:', a);
          PosState := Pos('<STATE:', a);
          PosLQslS := Pos('<LOTW_QSL_SENT', a);
          PosLQslR := Pos('<LOTW_QSL_RCVD', a);
          PosLQslSDate := Pos('<LOTW_QSLSDATE', a);
          PosLQslRDate := Pos('<LOTW_QSLRDATE', a);
          PosQSLRDATE := Pos('<QSLRDATE:', a);
          PosQSLSDATE := Pos('<QSLSDATE:', a);
          PosQSL_RCVD_VIA := Pos('<QSL_RCVD_VIA', a);
          PosEQSL_QSLRDATE := Pos('<EQSL_QSLRDATE', a);
          PosEQSL_QSLSDATE := Pos('<EQSL_QSLSDATE', a);
          PosEQSL_QSL_RCVD := Pos('<EQSL_QSL_RCVD', a);
          PosEQSL_QSL_SENT := Pos('<EQSL_QSL_SENT', a);

          if PosCall > 0 then
          begin
            Call := '';
            sCount := '';
            PosCall := PosCall + 6; //Move cursor to first letter of callsign
            while not (a[PosCall] = '>') do
            begin
              sCount := sCount + a[PosCall];
              Inc(PosCall);
            end;
            Count := StrToInt(sCount);
            for i := PosCall + 1 to Count + PosCall do
              Call := call + Data[i];
          end;

          if PosName > 0 then
          begin
            sName := '';
            PosName := PosName + 6; //Move cursor to first letter of name
            SCount := '';
            while not (a[PosName] = '>') do
            begin
              sCount := sCount + a[PosName];
              Inc(PosName);
            end;
            Count := StrToInt(sCount);
            for i := PosName + 1 to Count + PosName do
              sName := sName + Data[i];
          end;

          if PosRSTS > 0 then
          begin
            RSTS := '';
            PosRSTS := PosRSTS + 10; //Move cursor to first letter of report
            sCount := '';
            while not (a[PosRSTS] = '>') do
            begin
              sCount := sCount + a[PosRSTS];
              Inc(PosRSTS);
            end;
            Count := StrToInt(sCount);
            for i := PosRSTS + 1 to Count + PosRSTS do
              RSTS := RSTS + Data[i];
          end;

          if PosRSTR > 0 then
          begin
            RSTR := '';
            PosRSTR := PosRSTR + 10; //Move cursor to first letter of report
            sCount := '';
            while not (a[PosRSTR] = '>') do
            begin
              sCount := sCount + a[PosRSTR];
              Inc(PosRSTR);
            end;
            Count := StrToInt(sCount);
            for i := PosRSTR + 1 to PosRSTR + Count do
              RSTR := RSTR + Data[i];
          end;

          if PosQTH > 0 then
          begin
            QTH := '';
            PosQTH := PosQTH + 5;
            sCount := '';
            while not (a[PosQTH] = '>') do
            begin
              sCount := sCount + a[PosQTH];
              Inc(PosQTH);
            end;
            Count := StrToInt(sCount);
            for i := PosQTH + 1 to Count + PosQTH do
              QTH := QTH + Data[i];
          end;

          if PosTon > 0 then
          begin
            Ton := '';
            PosTon := PosTon + 9;
            sCount := '';
            while not (a[PosTon] = '>') do
            begin
              sCount := sCount + a[PosTon];
              Inc(PosTon);
            end;
            Count := StrToInt(sCount);
            for i := PosTon + 1 to Count + PosTon do
              Ton := Ton + Data[i];
            if (Ton <> '') then
              Ton := Ton[1] + Ton[2] + ':' + Ton[3] + Ton[4];
          end;

          if PosToff > 0 then
          begin
            Toff := '';
            PosToff := PosToff + 10;
            sCount := '';
            while not (a[PosToff] = '>') do
            begin
              sCount := sCount + a[PosToff];
              Inc(PosToff);
            end;
            Count := StrToInt(sCount);
            for i := PosToff + 1 to Count + PosToff do
              Toff := Toff + Data[i];
            if (Toff <> '') then
              Toff := Toff[1] + Toff[2] + ':' + Toff[3] + Toff[4];
          end;

          if PosQSLR > 0 then
          begin
            QSLR := '';
            PosQSLR := PosQSLR + 10;
            sCount := '';
            while not (a[PosQSLR] = '>') do
            begin
              sCount := sCount + a[PosQSLR];
              Inc(PosQSLR);
            end;
            Count := StrToInt(sCount);
            for i := PosQSLR + 1 to Count + PosQSLR do
              QSLR := QSLR + Data[i];
          end;


          if PosQSLS > 0 then
          begin
            QSLS := '';
            PosQSLS := PosQSLS + 10;
            sCount := '';
            while not (a[PosQSLS] = '>') do
            begin
              sCount := sCount + a[PosQSLS];
              Inc(PosQSLS);
            end;
            Count := StrToInt(sCount);
            for i := PosQSLS + 1 to Count + PosQSLS do
              QSLS := QSLS + Data[i];
          end;

          if PosMode > 0 then
          begin
            Mode := '';
            PosMode := PosMode + 6;
            sCount := '';
            while not (a[PosMode] = '>') do
            begin
              sCount := sCount + a[PosMode];
              Inc(PosMode);
            end;
            Count := StrToInt(sCount);
            for i := PosMode + 1 to Count + PosMode do
              Mode := Mode + Data[i];
            if Mode = 'BPSK31' then
              Mode := 'PSK31';
            if Mode = 'SST' then
              Mode := 'SSTV';
            if Mode = 'TTY' then
              Mode := 'RTTY';
            if Mode = 'WSTJ' then
              Mode := 'FSK441';
            if Mode = 'BPSK' then
              Mode := 'PSK';
          end;

          if PosFreq > 0 then
          begin
            Freq := '';
            PosFreq := PosFreq + 6;
            sCount := '';
            while not (a[PosFreq] = '>') do
            begin
              sCount := sCount + a[PosFreq];
              Inc(PosFreq);
            end;
            Count := StrToInt(sCount);
            for i := PosFreq + 1 to Count + PosFreq do
              Freq := Freq + Data[i];
          end;

          if PosPwr > 0 then
          begin
            Pwr := '';
            PosPwr := PosPwr + 8;
            sCount := '';
            while not (a[PosPwr] = '>') do
            begin
              sCount := sCount + a[PosPwr];
              Inc(PosPwr);
            end;
            Count := StrToInt(sCount);
            for i := PosPwr + 1 to Count + PosPwr do
              Pwr := Pwr + Data[i];
          end;

          if PosCom > 0 then
          begin
            Com := '';
            PosCom := PosCom + 9;
            sCount := '';
            while not (a[PosCom] = '>') do
            begin
              sCount := sCount + a[PosCom];
              Inc(PosCom);
            end;
            Count := StrToInt(sCount);
            for i := PosCom + 1 to Count + PosCom do
              Com := Com + Data[i];
          end;

          if PosNot > 0 then
          begin
            Note := '';
            PosNot := PosNot + 7;
            sCount := '';
            while not (a[PosNot] = '>') do
            begin
              sCount := sCount + a[PosNot];
              Inc(PosNot);
            end;
            Count := StrToInt(sCount);
            for i := PosNot + 1 to Count + PosNot do
              Note := Note + Data[i];
          end;

          if PosDate > 0 then
          begin
            Date := '';
            PosDate := PosDate + 12;
            sCount := '';
          {while not ((a[PosDate] = '>') or (a[PosDate] = ':')) do
          begin
            sCount := sCount + a[PosDate];
            inc(PosDate)
          end;
          Count := StrToInt(sCount);}
            for i := PosDate + 2 to PosDate + 9 do
              Date := Date + Data[i];
          end;

          if PosDat1 > 0 then
          begin
            Date := '';
            PosDat1 := PosDat1 + 10;
            sCount := '';
            while not (a[PosDat1] = '>') do
            begin
              sCount := sCount + a[PosDat1];
              Inc(PosDat1);
            end;
            Count := StrToInt(sCount);
            for i := PosDat1 + 1 to Count + PosDat1 do
              Date := Date + Data[i];
          end;

          if PosQSLV > 0 then
          begin
            QSLV := '';
            PosQSLV := PosQSLV + 9;//10
            sCount := '';
            while not (a[PosQSLV] = '>') do
            begin
              sCount := sCount + a[PosQSLV];
              Inc(PosQSLV);
            end;
            if sCount = '' then
            begin
              ShowMessage(a);
              exit;
            end;
            Count := StrToInt(sCount);
            for i := PosQSLV + 1 to Count + PosQSLV do
              QSLV := QSLV + Data[i];
          end;

          if PosMLoc > 0 then
          begin
            MLoc := '';
            PosMLoc := PosMLoc + 15;
            sCount := '';
            while not (a[PosMLoc] = '>') do
            begin
              sCount := sCount + a[PosMLoc];
              Inc(PosMLoc);
            end;
            Count := StrToInt(sCount);
            for i := PosMLoc + 1 to Count + PosMLoc do
              MLoc := MLoc + Data[i];
          end;

          if PosLoc > 0 then
          begin
            Loc := '';
            PosLoc := PosLoc + 12;
            sCount := '';
            while not (a[PosLoc] = '>') do
            begin
              sCount := sCount + a[PosLoc];
              Inc(PosLoc);
            end;
            Count := StrToInt(sCount);
            for i := PosLoc + 1 to Count + PosLoc do
              Loc := Loc + Data[i];
          end;

          if PosSRX > 0 then
          begin
            SRX := '';
            PosSRX := PosSRX + 5;
            sCount := '';
            while not (a[PosSRX] = '>') do
            begin
              sCount := sCount + a[PosSRX];
              Inc(PosSRX);
            end;
            Count := StrToInt(sCount);
            for i := PosSRX + 1 to Count + PosSRX do
              SRX := SRX + Data[i];
          end;

          if PosSTX > 0 then
          begin
            STX := '';
            PosSTX := PosSTX + 5;
            sCount := '';
            while not (a[PosSTX] = '>') do
            begin
              sCount := sCount + a[PosSTX];
              Inc(PosSTX);
            end;
            Count := StrToInt(sCount);
            for i := PosSTX + 1 to Count + PosSTX do
              STX := STX + Data[i];
          end;

          if PosBand > 0 then
          begin
            Band := '';
            PosBand := PosBand + 6;
            sCount := '';
            while not (a[PosBand] = '>') do
            begin
              sCount := sCount + a[PosBand];
              Inc(PosBand);
            end;
            Count := StrToInt(sCount);
            for i := PosBand + 1 to Count + PosBand do
              Band := Band + Data[i];
          end;

          if PosIOTA > 0 then
          begin
            IOTA := '';
            PosIOTA := PosIOTA + 6;
            sCount := '';
            while not (a[PosIOTA] = '>') do
            begin
              sCount := sCount + a[PosIOTA];
              Inc(PosIOTA);
            end;
            Count := StrToInt(sCount);
            for i := PosIOTA + 1 to Count + PosIOTA do
              IOTA := IOTA + Data[i];
          end;

          if PosITUZ > 0 then
          begin
            ITUZ := '';
            PosITUZ := PosITUZ + 6;
            sCount := '';
            while not (a[PosITUZ] = '>') do
            begin
              sCount := sCount + a[PosITUZ];
              Inc(PosITUZ);
            end;
            Count := StrToInt(sCount);
            for i := PosITUZ + 1 to Count + PosITUZ do
              ITUZ := ITUZ + Data[i];
          end;

          if PosWAZ > 0 then
          begin
            WAZ := '';
            PosWAZ := PosWAZ + 5;
            sCount := '';
            while not (a[PosWAZ] = '>') do
            begin
              sCount := sCount + a[PosWAZ];
              Inc(PosWAZ);
            end;
            Count := StrToInt(sCount);
            for i := PosWAZ + 1 to Count + PosWAZ do
              WAZ := WAZ + Data[i];
          end;

          if PosDXCC > 0 then
          begin
            DXCC := '';
            PosDXCC := PosDXCC + 11;
            sCount := '';
            while not (a[PosDXCC] = '>') do
            begin
              sCount := sCount + a[PosDXCC];
              Inc(PosDXCC);
            end;
            Count := StrToInt(sCount);
            for i := PosDXCC + 1 to Count + PosDXCC do
              DXCC := DXCC + Data[i];
          end;

          if PosDXCC2 > 0 then
          begin
            DXCC2 := '';
            PosDXCC2 := PosDXCC2 + 6;
            sCount := '';
            while not (a[PosDXCC2] = '>') do
            begin
              sCount := sCount + a[PosDXCC2];
              Inc(PosDXCC2);
            end;
            Count := StrToInt(sCount);
            for i := PosDXCC2 + 1 to Count + PosDXCC2 do
              DXCC2 := DXCC2 + Data[i];
          end;

          if PosPFX > 0 then
          begin
            PFX := '';
            PosPFX := PosPFX + 5;
            sCount := '';
            while not (a[PosPFX] = '>') do
            begin
              sCount := sCount + a[PosPFX];
              Inc(PosPFX);
            end;
            Count := StrToInt(sCount);
            for i := PosPFX + 1 to Count + PosPFX do
              PFX := PFX + Data[i];
          end;

          if PosCONT > 0 then
          begin
            CONT := '';
            PosCONT := PosCONT + 6;
            sCount := '';
            while not (a[PosCONT] = '>') do
            begin
              sCount := sCount + a[PosCONT];
              Inc(PosCONT);
            end;
            Count := StrToInt(sCount);
            for i := PosCONT + 1 to Count + PosCONT do
              CONT := CONT + Data[i];
          end;

          if PosQSLMSG > 0 then
          begin
            QSLMSG := '';
            PosQSLMSG := PosQSLMSG + 8;
            sCount := '';
            while not (a[PosQSLMSG] = '>') do
            begin
              sCount := sCount + a[PosQSLMSG];
              Inc(PosQSLMSG);
            end;
            Count := StrToInt(sCount);
            for i := PosQSLMSG + 1 to Count + PosQSLMSG do
              QSLMSG := QSLMSG + Data[i];
          end;

          if PosAward > 0 then
          begin
            Award := '';
            PosAward := PosAward + 7;
            sCount := '';
            while not (a[PosAward] = '>') do
            begin
              sCount := sCount + a[PosAward];
              Inc(PosAward);
            end;
            Count := StrToInt(sCount);
            for i := PosAward + 1 to Count + PosAward do
              Award := Award + Data[i];
          end;

          if PosCounty > 0 then
          begin
            County := '';
            PosCounty := PosCounty + 6;
            sCount := '';
            while not (a[PosCounty] = '>') do
            begin
              sCount := sCount + a[PosCounty];
              Inc(PosCounty);
            end;
            Count := StrToInt(sCount);
            for i := PosCounty + 1 to Count + PosCounty do
              County := County + Data[i];
          end;

          if PosState > 0 then
          begin
            State := '';
            PosState := PosState + 7;
            sCount := '';
            while not (a[PosState] = '>') do
            begin
              sCount := sCount + a[PosState];
              Inc(PosState);
            end;
            Count := StrToInt(sCount);
            for i := PosState + 1 to Count + PosState do
              State := State + Data[i];
          end;

          if PosLQslSDate > 0 then
          begin
            LQslSDate := '';
            PosLQSLSDate := PosLQslSDate + 15;
            sCount := '';
            while not (a[PosLQslSDate] = '>') do
            begin
              sCount := sCount + a[PosLQslSDate];
              Inc(PosLQslSDate);
            end;
            Count := StrToInt(sCount);
            LQslSDate := copy(Data, PosLQslSDate + 1, Count);
          end;

          if PosLQslRDate > 0 then
          begin
            LQslRDate := '';
            PosLQSLRDate := PosLQslRDate + 15;
            sCount := '';
            while not (a[PosLQslRDate] = '>') do
            begin
              sCount := sCount + a[PosLQslRDate];
              Inc(PosLQslRDate);
            end;
            Count := StrToInt(sCount);
            LQslRDate := copy(Data, PosLQslRDate + 1, Count);
          end;

          if PosLQslS > 0 then
          begin
            LQslS := '';
            PosLQslS := PosLQslS + 15;
            sCount := '';
            while not (a[PosLQSLS] = '>') do
            begin
              sCount := sCount + a[PosLQSLS];
              Inc(PosLQSLS);
            end;
            Count := StrToInt(sCount);
            LQslS := copy(Data, PosLQSLS + 1, Count);
          end;

          if PosLQslR > 0 then
          begin
            LQslR := '';
            PosLQslR := PosLQslR + 15;
            sCount := '';
            while not (a[PosLQSLR] = '>') do
            begin
              sCount := sCount + a[PosLQSLR];
              Inc(PosLQSLR);
            end;
            Count := StrToInt(sCount);
            LQslR := copy(Data, PosLQSLR + 1, Count);
          end;

          if PosQSLRDATE > 0 then
          begin
            QSLRDATE := '';
            PosQSLRDATE := PosQSLRDATE + 10;
            sCount := '';
            while not (a[PosQSLRDATE] = '>') do
            begin
              sCount := sCount + a[PosQSLRDATE];
              Inc(PosQSLRDATE);
            end;
            Count := StrToInt(sCount);
            QSLRDATE := copy(Data, PosQSLRDATE + 1, Count);
          end;

          if PosQSLSDATE > 0 then
          begin
            QSLSDATE := '';
            PosQSLSDATE := PosQSLSDATE + 10;
            sCount := '';
            while not (a[PosQSLSDATE] = '>') do
            begin
              sCount := sCount + a[PosQSLSDATE];
              Inc(PosQSLSDATE);
            end;
            Count := StrToInt(sCount);
            QSLSDATE := copy(Data, PosQSLSDATE + 1, Count);
          end;

          if PosQSL_RCVD_VIA > 0 then
          begin
            QSL_RCVD_VIA := '';
            PosQSL_RCVD_VIA := PosQSL_RCVD_VIA + 14;
            sCount := '';
            while not (a[PosQSL_RCVD_VIA] = '>') do
            begin
              sCount := sCount + a[PosQSL_RCVD_VIA];
              Inc(PosQSL_RCVD_VIA);
            end;
            Count := StrToInt(sCount);
            QSL_RCVD_VIA := copy(Data, PosQSL_RCVD_VIA + 1, Count);
          end;

          if PosEQSL_QSL_RCVD > 0 then
          begin
            EQSL_QSL_RCVD := '';
            PosEQSL_QSL_RCVD := PosEQSL_QSL_RCVD + 15;
            sCount := '';
            while not (a[PosEQSL_QSL_RCVD] = '>') do
            begin
              sCount := sCount + a[PosEQSL_QSL_RCVD];
              Inc(PosEQSL_QSL_RCVD);
            end;
            Count := StrToInt(sCount);
            EQSL_QSL_RCVD := copy(Data, PosEQSL_QSL_RCVD + 1, Count);
          end;

          if PosEQSL_QSL_SENT > 0 then
          begin
            EQSL_QSL_SENT := '';
            PosEQSL_QSL_SENT := PosEQSL_QSL_SENT + 15;
            sCount := '';
            while not (a[PosEQSL_QSL_SENT] = '>') do
            begin
              sCount := sCount + a[PosEQSL_QSL_SENT];
              Inc(PosEQSL_QSL_SENT);
            end;
            Count := StrToInt(sCount);
            EQSL_QSL_SENT := copy(Data, PosEQSL_QSL_SENT + 1, Count);
          end;

          if PosEOR > 0 then
          begin
            ///????????????????????????????????????????
            QSODate := dmFunc.ADIFDateToDate(date);

            if LQslSDate <> '' then
              LQslSDate := dmFunc.ADIFDateToDate(LQslSDate);
            if LQslRDate <> '' then
              LQslRDate := dmFunc.ADIFDateToDate(LQslRDate);

            if ((LQslSDate <> '') and (LQslS <> '')) then
              LQslS := 'Y'
            else
              LQslS := '';
            if ((LQslRDate <> '') and (LQslR <> '')) then
              LQslR := 'L'
            else
              LQslR := '';

            if Length(Toff) = 0 then
              Toff := Ton;

            if (DXCC <> '') then
              // begin
              //  if (dxcc <> '!') and (dxcc <> '#') and (dxcc <> '?') and (Pos('/',mode)=0) then
              //    dmDXCC.id_country(call,StrToDateFormat(qsodate),DXCC,tmp,tmp,id_waz,tmp,id_itu,tmp,tmp)

              // end
              // else
              //   dmDXCC.id_country(call,StrToDateFormat(qsodate),DXCC,tmp,tmp,id_waz,tmp,id_itu,tmp,tmp);
              DXCC := DXCC;

            if ((WAZ = '') or (ITUZ = '')) then
              dmFunc.ModifyWAZITU(id_waz, id_itu);
            if (waz = '') then
              waz := id_waz;
            if (ITUZ = '') then
              ituz := id_itu;

            if ituz = '' then
              ituz := '0';
            if waz = '' then
              WAZ := '0';

            if ((mode = 'CW') and (RSTS = '')) then
              RSTS := '599';
            if ((mode = 'CW') and (RSTR = '')) then
              RSTR := '599';

            iota := dmFunc.MyTrim(dmFunc.RemoveSpaces(iota));
            iota := UpperCase(iota);

            QSLV := UpperCase(QSLV);
            if Pos('QSL VIA', QSLV) > 0 then
              QSLV := copy(QSLV, 9, Length(QSLV) - 1);
            QSLV := trim(QSLV);
            if Memo1.Text <> '' then
              com := Memo1.Text + ' ' + com;

            if (Length(QTH) > 60) then
              qth := copy(qth, 1, 60);
            if (Length(QSLV) > 30) then
              QSLV := copy(QSLV, 1, 30);
            if (Length(com) > 200) then
              com := copy(com, 1, 200);


            qth := dmFunc.MyTrim(qth);
            qth := copy(qth, 1, 60);
            sName := dmFunc.MyTrim(sName);
            sName := copy(sName, 1, 40);
            Com := dmFunc.MyTrim(Com);
            Com := copy(com, 1, 200);
            Toff := copy(Toff, 1, 5);
            Ton := copy(Ton, 1, 5); //only hh:mm format supported
            RSTR := dmFunc.MyTrim(RSTR);
            RSTS := dmFunc.MyTrim(RSTS);
            SRX := dmFunc.MyTrim(SRX);
            STX := dmFunc.MyTrim(STX);
            state := copy(state, 1, 4);

            //if SRX <> '' then
            //  Com := STX + '/' + SRX + ' ' + Com;

            MLoc := UpperCase(Trim(MLoc));

            if PWR = '' then
              pwr := MyPower;

            if not dmFunc.IsLocOK(MLoc) then
              Mloc := MyLoc;

            if (Mode = 'USB') or (mode = 'LSB') then
              Mode := 'SSB';

            if freq = '' then
              freq := dmFunc.FreqFromBand(Band, Mode);
            if not dmFunc.IsAdifOK(QSODate, Ton, Toff, Call, Freq,
              Mode, RSTS, RSTR, IOTA, ITUZ, WAZ, Loc, MLoc, Band) then
            begin
              Inc(err);
              lblErrors.Caption :=
                rImportErrors + ' ' + IntToStr(err);
              lblErrorLog.Caption :=
                rFileError + PathMyDoc + ERR_FILE;
              Repaint;
              Application.ProcessMessages;
              WriteWrongADIF(Lines);
              Len := 0;
              SetLength(Lines, 0);
              Continue;
            end;

            freq := FormatFloat('0.000"."00', StrToFloat(freq));
            band := FloatToStr(dmFunc.GetDigiBandFromFreq(freq));

            //    if CheckBox2.Checked = True then
            //   begin //Нужна проверка ну дубли?
            DUPEQuery.Close;         //Проверка на дубликаты
            DUPEQuery.SQL.Clear;
            if DefaultDB = 'MySQL' then
            begin
              DUPEQuery.SQL.Text :=
                'SELECT COUNT(*) FROM ' + LogTable + ' WHERE QSODate = ' +
                QuotedStr(qsodate) + ' AND QSOTime = ' + QuotedStr(ton) +
                ' AND CallSign = ' + QuotedStr(call);

            end
            else
            begin
              DUPEQuery.SQL.Text :=
                'SELECT COUNT(*) FROM ' + LogTable +
                ' WHERE strftime(''%Y-%m-%d'',QSODate) = ' +
                QuotedStr(qsodate) + ' AND QSOTime = ' + QuotedStr(ton) +
                ' AND CallSign = ' + QuotedStr(call);
            end;

            DUPEQuery.Open;
            if DUPEQuery.Fields.Fields[0].AsInteger > 0 then
            begin
              Application.ProcessMessages;
              MainForm.SQLTransaction1.Rollback;
              Inc(errr);
              Label2.Caption :=
                rNumberDup + ' ' + IntToStr(errr);
            end
            //  end
            else                   //Если всё норм -> поехали добавлять)
            begin

              if GuessEncoding(sName) <> 'utf8' then
                sName := CP1251ToUTF8(sName);
              if GuessEncoding(qth) <> 'utf8' then
                qth := CP1251ToUTF8(qth);
              if GuessEncoding(Com) <> 'utf8' then
                Com := CP1251ToUTF8(Com);

              ImportQuery.SQL.Clear;
              ImportQuery.SQL.Text :=
                'INSERT INTO ' + LogTable +
                ' (QSODate,QSOTime,CallSign,QSOBand,QSOMode,' +
                'QSOReportSent,QSOReportRecived,OMName,OMQTH,QSL_SENT_VIA,IOTA,ITUZone,Grid,'
                + 'QSOAddInfo,DXCCPrefix,AwardsEx,DigiBand,State, CQZone, MainPrefix, Continent,'
                + 'QSLInfo, DXCC, QSLSentDate, QSLSent, QSLRecDate, QSLRec, NoCalcDXCC, QSLSentAdv, QSLReceQSLcc, QSL_RCVD_VIA) VALUES (:QSODate,'
                + ':QSOTime, :CallSign, :QSOBand, :QSOMode, :QSOReportSent, :QSOReportRecived,'
                + ':OMName, :OMQTH, :QSL_SENT_VIA, :IOTA, :ITUZone, :Grid, :QSOAddInfo,'
                + ':DXCCPrefix, :AwardsEx, :DigiBand, :State, :CQZone, :MainPrefix, :Continent,'
                + ':QSLInfo, :DXCC, :QSLSentDate, :QSLSent, :QSLRecDate, :QSLRec, :NoCalcDXCC, :QSLSentAdv, :QSLReceQSLcc, :QSL_RCVD_VIA)';
              ImportQuery.Prepare;

              yyyy := StrToInt(QSODate[1] + QSODate[2] + QSODate[3] + QSODate[4]);
              mm := StrToInt(QSODate[6] + QSODate[7]);
              dd := StrToInt(QSODate[9] + QSODate[10]);

              if DefaultDB = 'MySQL' then
                ImportQuery.Params.ParamByName('QSODate').AsString := QSODate
              else
                ImportQuery.Params.ParamByName('QSODate').AsDate :=
                  EncodeDate(yyyy, mm, dd);
              if RadioButton1.Checked = True then
                ImportQuery.Params.ParamByName('QSOTime').AsString := Toff;
              if RadioButton2.Checked = True then
                ImportQuery.Params.ParamByName('QSOTime').AsString := Ton;

              ImportQuery.Params.ParamByName('CallSign').AsString := Call;
              ImportQuery.Params.ParamByName('QSOBand').AsString := Freq;
              ImportQuery.Params.ParamByName('QSOMode').AsString := Mode;
              ImportQuery.Params.ParamByName('QSOReportSent').AsString := RSTS;
              ImportQuery.Params.ParamByName('QSOReportRecived').AsString := RSTR;
              ImportQuery.Params.ParamByName('OMName').AsString := sName;
              ImportQuery.Params.ParamByName('OMQTH').AsString := QTH;
              ImportQuery.Params.ParamByName('QSL_SENT_VIA').AsString := QSLV;
              ImportQuery.Params.ParamByName('IOTA').AsString := IOTA;
              ImportQuery.Params.ParamByName('ITUZone').AsString := ITUZ;
              ImportQuery.Params.ParamByName('Grid').AsString := Loc;
              ImportQuery.Params.ParamByName('QSOAddInfo').AsString := Com;
              ImportQuery.Params.ParamByName('DXCCPrefix').AsString := DXCC;
              ImportQuery.Params.ParamByName('AwardsEx').AsString := Award;
              ImportQuery.Params.ParamByName('DigiBand').AsString := Band;
              ImportQuery.Params.ParamByName('State').AsString := State;
              ImportQuery.Params.ParamByName('CQZone').AsString := WAZ;
              ImportQuery.Params.ParamByName('MainPrefix').AsString := PFX;
              ImportQuery.Params.ParamByName('Continent').AsString := CONT;
              ImportQuery.Params.ParamByName('QSLInfo').AsString := QSLMSG;
              ImportQuery.Params.ParamByName('DXCC').AsString := DXCC2;
              ImportQuery.Params.ParamByName('NoCalcDXCC').AsInteger := 0;
              ImportQuery.Params.ParamByName('QSLSentAdv').AsString := 'Q';

              if QSLSDATE <> '' then
              begin
                yyyy2 := StrToInt(QSLSDATE[1] + QSLSDATE[2] + QSLSDATE[3] + QSLSDATE[4]);
                mm2 := StrToInt(QSLSDATE[5] + QSLSDATE[6]);
                dd2 := StrToInt(QSLSDATE[7] + QSLSDATE[8]);

                if DefaultDB = 'MySQL' then
                  ImportQuery.Params.ParamByName('QSLSentDate').AsString := QSLSDATE
                else
                  ImportQuery.Params.ParamByName('QSLSentDate').AsDate :=
                    EncodeDate(yyyy2, mm2, dd2);
                ImportQuery.Params.ParamByName('QSLSent').AsInteger := 1;

              end
              else
              begin
                ImportQuery.Params.ParamByName('QSLSentDate').IsNull;
                ImportQuery.Params.ParamByName('QSLSent').IsNull;
              end;

              if QSLRDATE <> '' then
              begin
                yyyy3 := StrToInt(QSLRDATE[1] + QSLRDATE[2] + QSLRDATE[3] + QSLRDATE[4]);
                mm3 := StrToInt(QSLRDATE[5] + QSLRDATE[6]);
                dd3 := StrToInt(QSLRDATE[7] + QSLRDATE[8]);

                if DefaultDB = 'MySQL' then
                  ImportQuery.Params.ParamByName('QSLRecDate').AsString := QSLRDATE
                else
                  ImportQuery.Params.ParamByName('QSLRecDate').AsDate :=
                    EncodeDate(yyyy3, mm3, dd3);
                ImportQuery.Params.ParamByName('QSLRec').AsInteger := 1;
              end
              else
              begin
                ImportQuery.Params.ParamByName('QSLRecDate').IsNull;
                ImportQuery.Params.ParamByName('QSLRec').AsInteger := 0;
              end;

              ImportQuery.Params.ParamByName('QSLReceQSLcc').AsString := EQSL_QSL_RCVD;
              ImportQuery.Params.ParamByName('QSL_RCVD_VIA').AsString := QSL_RCVD_VIA;

              ImportQuery.ExecSQL;

              note := dmFunc.MyTrim(note);

              Inc(RecCount);
              lblCount.Caption :=
                rImportRecord + ' ' + IntToStr(RecCount);
              if MainForm.ImportAdifMobile = True then
                MainForm.StatusBar1.Panels.Items[0].Text :=
                  rImportRecord + ' ' + IntToStr(RecCount);

            end;   //Пока не завершится файл
          end;
        end;
      end;
    except
      MainForm.SQLTransaction1.Rollback;
    end;
  finally
    MainForm.SQLTransaction1.Commit;
    lblComplete.Caption := rDone;
    Button1.Enabled := True;
    CloseFile(f);
    MainForm.SelDB(CallLogBook);
  end;
end;

procedure TImportADIFForm.Button2Click(Sender: TObject);
begin
  ImportADIFForm.Close;
end;

procedure TImportADIFForm.FileNameEdit1ButtonClick(Sender: TObject);
begin
  FileNameEdit1.InitialDir := Inif.ReadString('SetLog', 'ImportPath', '');
end;

procedure TImportADIFForm.FileNameEdit1Change(Sender: TObject);
begin
  IniF.WriteString('SetLog', 'ImportPath', ExtractFilePath(FileNameEdit1.FileName));
end;

procedure TImportADIFForm.FormCreate(Sender: TObject);
begin
  if DefaultDB = 'MySQL' then
  begin
    DUPEQuery.DataBase := MainForm.MySQLLOGDBConnection;
    ImportQuery.DataBase := MainForm.MySQLLOGDBConnection;
    MainForm.SQLTransaction1.DataBase := MainForm.MySQLLOGDBConnection;
  end
  else
  begin
    DUPEQuery.DataBase := MainForm.SQLiteDBConnection;
    ImportQuery.DataBase := MainForm.SQLiteDBConnection;
    MainForm.SQLTransaction1.DataBase := MainForm.SQLiteDBConnection;
  end;
  Button1.Caption := rImport;
end;

procedure TImportADIFForm.FormShow(Sender: TObject);
begin
  if DefaultDB = 'MySQL' then
  begin
    DUPEQuery.DataBase := MainForm.MySQLLOGDBConnection;
    ImportQuery.DataBase := MainForm.MySQLLOGDBConnection;
    MainForm.SQLTransaction1.DataBase := MainForm.MySQLLOGDBConnection;
  end
  else
  begin
    DUPEQuery.DataBase := MainForm.SQLiteDBConnection;
    ImportQuery.DataBase := MainForm.SQLiteDBConnection;
    MainForm.SQLTransaction1.DataBase := MainForm.SQLiteDBConnection;
  end;
  Button1.Enabled := True;
  Button1.Caption := rImport;
  FileNameEdit1.Text := '';
  Memo1.Clear;
  Label2.Caption := rNumberDup + ' ';
  lblCount.Caption := rImportRecord + ' ';
  lblErrors.Caption := rImportErrors + ' ';
  lblErrorLog.Caption := rFileError;

end;

procedure TImportADIFForm.lblErrorLogClick(Sender: TObject);
var
  PathMyDoc: string;
begin
 {$IFDEF UNIX}
  PathMyDoc := GetEnvironmentVariable('HOME') + '/EWLog/';
  {$ELSE}
  PathMyDoc := GetEnvironmentVariable('SystemDrive') +
    GetEnvironmentVariable('HOMEPATH') + '\EWLog\';
  {$ENDIF UNIX}
  OpenDocument(PathMyDoc + ERR_FILE);

end;

procedure TImportADIFForm.Button1Click(Sender: TObject);
begin
  if FileNameEdit1.Text = '' then
  begin
    ShowMessage(rNothingImport);
  end
  else
  begin
    if Button1.Caption <> rDone then
    begin
      DeleteFile(dmFunc.DataDir + ERR_FILE);
      lblComplete.Caption := rProcessing;
      ADIFImport;
    end
    else
      ImportADIFForm.Close;
  end;
end;



end.
