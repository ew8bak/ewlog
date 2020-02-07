unit ServiceForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ComCtrls, LazUTF8, ExtCtrls, StdCtrls, EditBtn, Buttons, LConvEncoding,
  httpsend, LazUtils, LazFileUtils, ssl_openssl, dateutils;

resourcestring
  rNotDataForConnect =
    'The log configuration, do not specify the data to connect to eQSL.cc';
  rStatusConnecteQSL = 'Status: Connceting to eQSL.cc';
  rStatusDownloadeQSL = 'Status: Download eQSL.cc';
  rStatusSaveFile = 'Status: Saving file';
  rStatusNotData = 'Status: Not data';
  rStatusDone = 'Status: Done';
  rProcessedData = 'Processed data:';


type

  { TServiceForm }

  TServiceForm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Button1: TButton;
    Button2: TButton;
    DateEdit1: TDateEdit;
    DateEdit2: TDateEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    OpenDialog1: TOpenDialog;
    SpeedButton1: TSpeedButton;
    UPDATEQuery: TSQLQuery;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }
    procedure eQSLAdifImport(FilePATH: string);
    procedure LotWImport(FilePATH: string);
  public
    { public declarations }
  end;

var
  ServiceForm: TServiceForm;

implementation

{$R *.lfm}
uses dmFunc_U, MainForm_U;

function Q(s: string): string;
var
  i: integer;
  Quote: char;
  char2: char;
begin
  Quote := #39;
  char2 := ',';
  Result := s;
  if Result = 'NULL' then
  begin
    Result := Result + char2;
    exit;
  end;
  for i := Length(Result) downto 1 do
    if Result[i] = Quote then
      Insert(Quote, Result, i);
  Result := Quote + Result + Quote + char2;
end;

procedure TServiceForm.LotWImport(FilePATH: string);

  function getField(str, field: string): string;
  var
    start: integer = 0;
    stop: integer = 0;
  begin
    try
      Result := '';
      start := str.IndexOf('<' + field + ':');
      if (start >= 0) then
      begin
        str := str.Substring(start + field.Length);
        start := str.IndexOf('>');
        stop := str.IndexOf('<');
        if (start < stop) and (start > -1) then
          Result := str.Substring(start + 1, stop - start - 1);
      end;
    except
      Result := '';
    end;

    if (Result = '') and (field <> LowerCase(field)) then
      Result := getField(str, LowerCase(field));
  end;

  function StreamToString(aStream: TStream): string;
  var
    SS: TStringStream;
  begin
    if aStream <> nil then
    begin
      SS := TStringStream.Create('');
      try
        SS.CopyFrom(aStream, 0);
        Result := SS.DataString;
      finally
        SS.Free;
      end;
    end
    else
    begin
      Result := '';
    end;
  end;

var
  i: integer;
  f: TextFile;
  temp_f: TextFile;
  s: string;
  CALL: string;
  BAND: string;
  FREQ: string;
  MODE: string;
  QSO_DATE: string;
  TIME_ON: string;
  QSL_RCVD: string;
  QSLRDATE: string;
  DXCC: string;
  PFX: string;
  GRIDSQUARE: string;
  CQZ: string;
  ITUZ: string;
  Query: string;
  paramQSLRDATE: string;
  DupeCount: integer;
  ErrorCount, RecCount: integer;
  PosEOH: word;
  PosEOR: word;
  yyyy, mm, dd: word;
  Stream: TMemoryStream;
  TempFile: string;
begin
  {$IFDEF UNIX}
  TempFile := GetEnvironmentVariable('HOME') + DirectorySeparator +'EWLog'+DirectorySeparator+'temp.adi';
  {$ELSE}
  TempFile := GetEnvironmentVariable('SystemDrive')+GetEnvironmentVariable('HOMEPATH') + DirectorySeparator +'EWLog'+DirectorySeparator+'temp.adi';
  {$ENDIF UNIX}
  RecCount := 0;
  DupeCount := 0;
  ErrorCount := 0;
  PosEOH := 0;
  PosEOR := 0;
  try
    Stream := TMemoryStream.Create;
    AssignFile(f, FilePATH);
    Reset(f);

    while not (PosEOH > 0) do
    begin
      Readln(f, s);
      PosEOH := Pos('<EOH>', UpperCase(s));
    end;

    while not EOF(f) do
    begin
      Readln(f, s);
      s := StringReplace(s, #10, '', [rfReplaceAll]);
      s := StringReplace(s, #13, '', [rfReplaceAll]);
      s := StringReplace(UpperCase(s), '<EOR>', '<EOR>'#10, [rfReplaceAll]);
      if Length(s) > 0 then
      begin
        Stream.Write(s[1], length(s));
      end;
    end;
    Stream.SaveToFile(TempFile);

    AssignFile(temp_f, TempFile);
    Reset(temp_f);

    while not (EOF(temp_f)) do
    begin
      try
        CALL := '';
        BAND := '';
        FREQ := '';
        MODE := '';
        QSO_DATE := '';
        TIME_ON := '';
        QSL_RCVD := '';
        QSLRDATE := '';
        DXCC := '';
        PFX := '';
        GRIDSQUARE := '';
        CQZ := '';
        ITUZ := '';
        paramQSLRDATE := '';

        Readln(temp_f, s);
        s := Trim(s);

        PosEOR := Pos('<EOR>', UpperCase(s));
        if not (PosEOR > 0) then
          Continue;

        CALL := getField(s, 'CALL');
        BAND := getField(s, 'BAND');
        FREQ := getField(s, 'FREQ');
        MODE := getField(s, 'MODE');
        QSO_DATE := getField(s, 'QSO_DATE');
        TIME_ON := getField(s, 'TIME_ON');
        QSL_RCVD := getField(s, 'QSL_RCVD');
        QSLRDATE := getField(s, 'QSLRDATE');
        DXCC := getField(s, 'DXCC');
        PFX := getField(s, 'PFX');
        GRIDSQUARE := getField(s, 'GRIDSQUARE');
        CQZ := getField(s, 'CQZ');
        ITUZ := getField(s, 'ITUZ');
        if PosEOR > 0 then
        begin
          if QSLRDATE <> '' then
          begin
            yyyy := StrToInt(QSLRDATE[1] + QSLRDATE[2] + QSLRDATE[3] +
              QSLRDATE[4]);
            mm := StrToInt(QSLRDATE[5] + QSLRDATE[6]);
            dd := StrToInt(QSLRDATE[7] + QSLRDATE[8]);
            if MainForm.MySQLLOGDBConnection.Connected then
              paramQSLRDATE := dmFunc.ADIFDateToDate(QSLRDATE)
            else
              paramQSLRDATE :=
                FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd)));
          end;
          Query := 'UPDATE ' + LogTable + ' SET GRID = ' + Q(GRIDSQUARE) +
            'CQZone = ' + Q(CQZ) + 'ITUZone = ' + Q(ITUZ) +
            'WPX = ' + Q(PFX) + 'DXCC = ' + Q(DXCC) +
            'LoTWRec = ''1'', LoTWRecDate = ' + QuotedStr(paramQSLRDATE) +
            ' WHERE CallSign = ' + QuotedStr(CALL) + ' AND strftime(''%Y%m%d'',QSODate) = ' +
            QuotedStr(QSO_DATE) + ';';
          UPDATEQuery.SQL.Text := Query;
          UPDATEQuery.ExecSQL;
          MainForm.SQLTransaction1.Commit;
        end;
      except
        MainForm.SQLTransaction1.Rollback;
      end;
    end;
  finally
    CloseFile(f);
    CloseFile(temp_f);
    Stream.Free;
    MainForm.SelDB(CallLogBook);
  end;
end;

procedure TServiceForm.FormCreate(Sender: TObject);
begin
  if DefaultDB = 'MySQL' then
  begin
    UPDATEQuery.DataBase := MainForm.MySQLLOGDBConnection;
    MainForm.SQLTransaction1.DataBase := MainForm.MySQLLOGDBConnection;
  end
  else
  begin
    UPDATEQuery.DataBase := MainForm.SQLiteDBConnection;
    MainForm.SQLTransaction1.DataBase := MainForm.SQLiteDBConnection;
  end;
end;

procedure TServiceForm.Button2Click(Sender: TObject);
const
  CDWNLD = '.adi">';
var
  FULLUrl, LoadFilePATH: string;
  LoadFile: TFileStream;
  i: integer;
  eQSLPage: TStringList;
  tmp: string;
  getHttp: THTTPSend;
begin
  if (eQSLccLogin = '') or (eQSLccPassword = '') then
    ShowMessage(rNotDataForConnect)
  else
  begin
    eQSLPage := TStringList.Create;
    getHttp := THTTPSend.Create;
    try
      with getHttp do
      begin
        Application.ProcessMessages;
        Label6.Caption := rStatusConnecteQSL;
        if HTTPMethod('GET', 'http://www.eqsl.cc/qslcard/DownloadInBox.cfm?UserName=' +
          eQSLccLogin + '&Password=' + eQSLccPassword + '&RcvdSince=' +
          FormatDateTime('yyyymmdd', DateEdit2.Date)) then
        begin
          Document.Seek(0, soBeginning);
          eQSLPage.LoadFromStream(Document);
          if Pos(CDWNLD, eQSLPage.Text) > 0 then
          begin
            for i := 0 to Pred(eQSLPage.Count) do
            begin
              if Pos(CDWNLD, eQSLPage[i]) > 0 then
              begin
                tmp := copy(eQSLPage[i], pos('HREF="', eQSLPage[i]) +
                  6, length(eQSLPage[i]));
                tmp := copy(eQSLPage[i], 1, pos('.adi"', eQSLPage[i]) + 3);
                tmp := ExtractFileNameOnly(tmp) + ExtractFileExt(tmp);
              end;
            end;
          end;
        end;
      end;

      FULLUrl := 'http://www.eqsl.cc/downloadedfiles/' + tmp;

       {$IFDEF UNIX}
      LoadFile := TFileStream.Create(GetEnvironmentVariable('HOME') +
        '/EWLog/eQSLcc_' + FormatDateTime('yyyymmdd', DateEdit2.Date) +
        '.adi', fmCreate);
      LoadFilePATH := GetEnvironmentVariable('HOME') + '/EWLog/eQSLcc_' +
        FormatDateTime('yyyymmdd', DateEdit2.Date) + '.adi';
      {$ELSE}
      Label6.Caption := rStatusSaveFile;
      LoadFilePATH := GetEnvironmentVariable('SystemDrive') +
        GetEnvironmentVariable('HOMEPATH') + '\EWLog\eQSLcc_' +
        FormatDateTime('yyyymmdd', DateEdit2.Date) + '.adi';
      LoadFile := TFileStream.Create(GetEnvironmentVariable('SystemDrive') +
        GetEnvironmentVariable('HOMEPATH') + '\EWLog\eQSLcc_' +
        FormatDateTime('yyyymmdd', DateEdit2.Date) + '.adi', fmCreate);
      {$ENDIF UNIX}
      Application.ProcessMessages;
      Label6.Caption := rStatusDownloadeQSL;
      HttpGetBinary(FULLUrl, LoadFile);

    finally
      getHttp.Free;
      eQSLPage.Free;
      LoadFile.Free;
      eQSLAdifImport(LoadFilePATH);
    end;

  end;
end;

procedure TServiceForm.Button1Click(Sender: TObject);
const
  LotW_URL = 'https://lotw.arrl.org/lotwuser/lotwreport.adi?';
var
  fullURL, LoadFilePATH: string;
  LoadFile: TFileStream;
begin
  if (LotWLogin = '') or (LotWPassword = '') then
    ShowMessage(rNotDataForConnect)
  else
  begin
    try
       {$IFDEF UNIX}
      LoadFile := TFileStream.Create(GetEnvironmentVariable('HOME') +
        '/EWLog/LotW_' + FormatDateTime('yyyymmdd', DateEdit1.Date) + '.adi', fmCreate);
      LoadFilePATH := GetEnvironmentVariable('HOME') + '/EWLog/LotW_' +
        FormatDateTime('yyyymmdd', DateEdit1.Date) + '.adi';
      {$ELSE}
      Label6.Caption := rStatusSaveFile;
      LoadFilePATH := GetEnvironmentVariable('SystemDrive') +
        GetEnvironmentVariable('HOMEPATH') + '\EWLog\LotW_' +
        FormatDateTime('yyyymmdd', DateEdit1.Date) + '.adi';
      LoadFile := TFileStream.Create(GetEnvironmentVariable('SystemDrive') +
        GetEnvironmentVariable('HOMEPATH') + '\EWLog\LotW_' +
        FormatDateTime('yyyymmdd', DateEdit1.Date) + '.adi', fmCreate);
      {$ENDIF UNIX}
      fullURL := LotW_URL + 'login=' + LotWLogin + '&password=' +
        LotWPassword + '&qso_query=1&qso_qsldetail="yes"' + '&qso_qslsince=' +
        FormatDateTime('yyyy-mm-dd', DateEdit1.Date);
      Application.ProcessMessages;
      HttpGetBinary(fullURL, LoadFile);
    finally
      LoadFile.Free;
    end;
    LotWImport(LoadFilePATH);
  end;
end;

procedure TServiceForm.FormShow(Sender: TObject);
begin
  if DefaultDB = 'MySQL' then
  begin
    UPDATEQuery.DataBase := MainForm.MySQLLOGDBConnection;
    MainForm.SQLTransaction1.DataBase := MainForm.MySQLLOGDBConnection;
  end
  else
  begin
    UPDATEQuery.DataBase := MainForm.SQLiteDBConnection;
    MainForm.SQLTransaction1.DataBase := MainForm.SQLiteDBConnection;
  end;
  DateEdit1.Date := Now;
  DateEdit2.Date := Now;
end;

procedure TServiceForm.SpeedButton1Click(Sender: TObject);
begin
  OpenDialog1.Execute;
  eQSLAdifImport(OpenDialog1.FileName);
end;

procedure TServiceForm.eQSLAdifImport(FilePATH: string);
var
  adiFile: TextFile;
  PosEOH: word;
  PosEOR: word;
  PosCall: word;
  PosQSODate: word;
  PosTimeOn: word;
  PosBand: word;
  PosMode: word;
  PosRSTS: word;
  PosQSLS: word;
  PosQSLSV: word;
  PosQSLMSG: word;
  Call: string;
  QSODate: string;
  QSODateADIF: string;
  TimeOn: string;
  Band: string;
  Mode: string;
  RSTS: string;
  QSLS: string;
  QSLSV: string;
  QSLMSG: string;
  a: string;
  Lines: array of string;
  Len: integer;
  Count: integer;
  sCount: string;
  i: integer;
  Data: string;
  RecCount: longint = 0;
  ErrCount: longint = 0;
begin
  if FilePATH <> '' then
  begin
    try
      try
        AssignFile(adiFile, SysToUTF8(FilePATH));
        Reset(adiFile);
        while not (PosEOH > 0) do
        begin
          Readln(adiFile, a);
          a := UpperCase(a);
          PosEOH := Pos('<EOH>', a);
        end;
        while not EOF(adiFile) do
        begin
          Call := '';
          QSODate := '';
          QSODateADIF := '';
          TimeOn := '';
          Band := '';
          Mode := '';
          RSTS := '';
          QSLS := '';
          QSLSV := '';
          QSLMSG := '';
          PosEOR := 0;
          Count := 0;
          Len := 0;
          while not ((PosEOR > 0) or EOF(adiFile)) do
          begin
            Inc(Len);
            SetLength(Lines, Len);
            Readln(adiFile, a);
            a := Trim(a);
            Lines[Len - 1] := a;
            Data := a;
            a := UpperCase(a);

            PosEOR := Pos('<EOR>', a);
            PosCALL := Pos('<CALL:', a);
            PosQSODate := Pos('<QSO_DATE:8:D>', a);
            PosTimeOn := Pos('<TIME_ON:', a);
            PosBand := Pos('<BAND:', a);
            PosMode := Pos('<MODE:', a);
            PosRSTS := Pos('<RST_SENT:', a);
            PosQSLS := Pos('<QSL_SENT:', a);
            PosQSLSV := Pos('<QSL_SENT_VIA:', a);
            PosQSLMSG := Pos('<QSLMSG:', a);

            //Записываем позывной
            if PosCall > 0 then
            begin
              Call := '';
              sCount := '';
              PosCall := PosCall + 6;
              while not (a[PosCall] = '>') do
              begin
                sCount := sCount + a[PosCall];
                Inc(PosCall);
              end;
              Count := StrToInt(sCount);
              for i := PosCall + 1 to Count + PosCall do
                Call := call + Data[i];
            end;

            //Записываем дату связи
            if PosQSODate > 0 then
            begin
              QSODateADIF := '';
              PosQSODate := PosQSODate + 12;
              sCount := '';
              for i := PosQSODate + 2 to PosQSODate + 9 do
                QSODateADIF := QSODateADIF + Data[i];
            end;

            //Записываем время связи
            if PosTimeOn > 0 then
            begin
              TimeOn := '';
              PosTimeOn := PosTimeOn + 9;
              sCount := '';
              while not (a[PosTimeOn] = '>') do
              begin
                sCount := sCount + a[PosTimeOn];
                Inc(PosTimeOn);
              end;
              Count := StrToInt(sCount);
              for i := PosTimeOn + 1 to Count + PosTimeOn do
                TimeOn := TimeOn + Data[i];
              if (TimeOn <> '') then
                TimeOn := TimeOn[1] + TimeOn[2] + ':' + TimeOn[3] + TimeOn[4];
            end;

            //Записываем диапазон
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

            //Записываем моду
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

            // Записываем принятый рапорт
            if PosRSTS > 0 then
            begin
              RSTS := '';
              PosRSTS := PosRSTS + 10;
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

            //Записываем отправленая QSL
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

            //Записываем чем отправлена QSL
            if PosQSLSV > 0 then
            begin
              QSLSV := '';
              PosQSLSV := PosQSLSV + 14;
              sCount := '';
              while not (a[PosQSLSV] = '>') do
              begin
                sCount := sCount + a[PosQSLSV];
                Inc(PosQSLSV);
              end;
              Count := StrToInt(sCount);
              QSLSV := copy(Data, PosQSLSV + 1, Count);
            end;

            //Записываем сообщение
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

            if PosEOR > 0 then
            begin
              QSODate := dmFunc.ADIFDateToDate(QSODateADIF);
              QSLSV := UpperCase(QSLSV);
              QSLMSG := dmFunc.MyTrim(QSLMSG);
              QSLMSG := copy(QSLMSG, 1, 200);
              TimeOn := copy(TimeOn, 1, 5);
              RSTS := dmFunc.MyTrim(RSTS);
              if (Mode = 'USB') or (Mode = 'Mode') then
                Mode := 'SSB';
              Application.ProcessMessages;
              if GuessEncoding(QSLMSG) <> 'utf8' then
                QSLMSG := SysToUTF8(QSLMSG);

              UPDATEQuery.Close;
              UPDATEQuery.SQL.Clear;
              if DefaultDB = 'MySQL' then
                UPDATEQuery.SQL.Add('UPDATE ' + LogTable +
                  ' SET QSL_RCVD_VIA =:QSL_RCVD_VIA, QSLReceQSLcc =:QSLReceQSLcc, '
                  +
                  'QSLInfo =:QSLInfo WHERE CallSign =:CallSign AND QSODate =:QSODate')
              else
                UPDATEQuery.SQL.Add('UPDATE ' + LogTable +
                  ' SET QSL_RCVD_VIA =:QSL_RCVD_VIA, QSLReceQSLcc =:QSLReceQSLcc, '
                  +
                  'QSLInfo =:QSLInfo WHERE CallSign =:CallSign AND strftime(''%Y-%m-%d'',QSODate) =:QSODate');

              UPDATEQuery.Prepare;
              if QSLS = 'Y' then
              begin
                UPDATEQuery.Params.ParamByName('QSLReceQSLcc').AsInteger := 1;
              end
              else
              begin
                UPDATEQuery.Params.ParamByName('QSLReceQSLcc').IsNull;
              end;
              UPDATEQuery.Params.ParamByName('QSL_RCVD_VIA').AsString := QSLSV;
              UPDATEQuery.Params.ParamByName('QSLInfo').AsString := QSLMSG;
              UPDATEQuery.Params.ParamByName('CallSign').AsString := Call;
              UPDATEQuery.Params.ParamByName('QSODate').AsString := QSODate;

              UPDATEQuery.ExecSQL;
              MainForm.SQLTransaction1.Commit;
              Application.ProcessMessages;
              Inc(RecCount);
              Label4.Caption := rProcessedData + IntToStr(RecCount);
            end;
          end;
        end;

      except
        MainForm.SQLTransaction1.Rollback;
      end;

    finally
      MainForm.SQLTransaction1.Commit;
      CloseFile(adiFile);
      MainForm.SelDB(CallLogBook);
      Label6.Caption := rStatusDone;
    end;
  end;
end;

end.
