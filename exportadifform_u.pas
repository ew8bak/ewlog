unit ExportAdifForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLType, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, EditBtn, ExtCtrls, sqldb, LazUTF8, LConvEncoding;

resourcestring
  rDone = 'Done';
  rWarning = 'Warning!';
  rExport = 'Export';
  rError = 'Error';
  rExportCompl = 'Export completed';
  pPleaseFile = 'Please specify a file for export!';
  rNoMethodExport = 'No export method selected!';
  rNumberOfQSO0 = 'Number of QSO: 0';
  rNumberOfQSO = 'Number of QSO';
  rErrorOpenFile = 'Error opening file';
  rSentRecord = 'Sent Record';

type

  { TexportAdifForm }

  TexportAdifForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    DateEdit1: TDateEdit;
    DateEdit2: TDateEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Q1: TSQLQuery;
    RadioButton1: TRadioButton;
    rbFileExportAll: TRadioButton;
    SaveDialog1: TSaveDialog;
    Q2: TSQLQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure rbFileExportAllClick(Sender: TObject);
    procedure SaveDialog1Close(Sender: TObject);
  private
    FileName: string;
    ExportAll: boolean;
    { private declarations }
  public
    function ExportToAdif: word;
    function ExportToMobile(range: string; date: string): word;
    { public declarations }
  end;

var
  exportAdifForm: TexportAdifForm;

implementation

uses dmFunc_U, MainForm_U, InitDB_dm;

{$R *.lfm}

procedure TexportAdifForm.Button1Click(Sender: TObject);
begin
  if Button1.Caption = rDone then
    exportAdifForm.Close
  else
  begin
    SaveDialog1.FileName := MainForm.ComboBox10.Text + '_' +
      FormatDateTime('yyyy-mm-dd', now);
    SaveDialog1.InitialDir := INIFile.ReadString('SetLog', 'ExportPath', '');
    if SaveDialog1.Execute then
    begin
      if SaveDialog1.FileName = '' then
      begin
        Application.MessageBox(
          PChar(pPleaseFile), PChar(rWarning),
          mb_ok + mb_IconWarning);
        exit;
      end;
      ExportAll := rbFileExportAll.Checked;
      FileName := SysToUTF8(SaveDialog1.FileName);
      if CheckBox1.Checked = True then
        ExportToAdif
      else
        Application.MessageBox(PChar(rNoMethodExport),
          PChar(rWarning),
          mb_ok + mb_IconWarning);
    end;
  end;
end;

procedure TexportAdifForm.Button2Click(Sender: TObject);
begin
  exportAdifForm.Close;
end;

procedure TexportAdifForm.FormCreate(Sender: TObject);
begin

end;

procedure TexportAdifForm.FormShow(Sender: TObject);
begin
  if DBRecord.CurrentDB = 'MySQL' then
  begin
    Q1.DataBase := InitDB.MySQLConnection;
    Q2.DataBase := InitDB.MySQLConnection;
  end
  else
  begin
    Q1.DataBase := InitDB.SQLiteConnection;
    Q2.DataBase := InitDB.SQLiteConnection;
  end;
  if rbFileExportAll.Checked = True then
  begin
    DateEdit1.Enabled := False;
    DateEdit2.Enabled := False;
  end;
  Button1.Caption := rExport;
  Label2.Caption := '';
  Label1.Caption := rNumberOfQSO0;
end;

procedure TexportAdifForm.RadioButton1Click(Sender: TObject);
begin
  if RadioButton1.Checked = True then
  begin
    DateEdit1.Enabled := True;
    DateEdit2.Enabled := True;
  end;
end;

procedure TexportAdifForm.rbFileExportAllClick(Sender: TObject);
begin
  if rbFileExportAll.Checked = True then
  begin
    DateEdit1.Enabled := False;
    DateEdit2.Enabled := False;
  end;
end;

procedure TexportAdifForm.SaveDialog1Close(Sender: TObject);
begin
  INIFile.WriteString('SetLog', 'ExportPath', ExtractFilePath(SaveDialog1.FileName));
end;

function TexportAdifForm.ExportToAdif: word;
var
  f: TextFile;
  tmp: string = '';
  nr: integer = 1;
  i: integer;
  date, freq2, numberToExp, EQSL_QSL_RCVD, QSL_RCVD, QSL_SENT, MY_LAT, MY_LON: string;

begin

  if FileExists(FileName) then
    DeleteFile(FileName);

  AssignFile(f, FileName);
  {$i-}
  Rewrite(f);
  {$i+}
  Result := IOResult;
  if IOresult <> 0 then
  begin
    Application.MessageBox(PChar(rErrorOpenFile + ' ' + IntToStr(IOResult)),
      PChar(rError), mb_ok + mb_IconError);
    exit;
  end;

  date := FormatDateTime('yyyy-mm-dd', now);
  Writeln(f, '<ADIF_VER:5>3.0.2');
  Writeln(f, 'ADIF export from EWLog');
  Writeln(f, 'Copyleft 2015-2020 by EW8BAK');
  Writeln(f);
  Writeln(f, 'Internet: https://www.ew8bak.ru');
  Writeln(f, 'Generated date ' + date);
  Writeln(f);
  Writeln(f, '<EOH>');
  Q1.Close;
  Q2.Close;

  if rbFileExportAll.Checked = True then
  begin
    Q1.SQL.Text := 'select * from ' + LBRecord.LogTable + ' ORDER BY UnUsedIndex ASC';
  end;

  Q2.SQL.Text := 'select * from LogBookInfo WHERE LogTable = ' + QuotedStr(LBRecord.LogTable);

  if RadioButton1.Checked = True then
  begin
    if DBRecord.DefaultDB = 'MySQL' then
      Q1.SQL.Text := 'SELECT * FROM ' + LBRecord.LogTable + ' WHERE QSODate BETWEEN ' +
        '''' + FormatDateTime('yyyy-mm-dd', DateEdit1.Date) + '''' +
        ' and ' + '''' + FormatDateTime('yyyy-mm-dd', DateEdit2.Date) +
        '''' + ' ORDER BY UnUsedIndex ASC'
    else
      Q1.SQL.Text :=
        'SELECT * FROM ' + LBRecord.LogTable + ' WHERE ' + 'strftime(' +
        QuotedStr('%Y-%m-%d') + ',QSODate) BETWEEN ' +
        QuotedStr(FormatDateTime('yyyy-mm-dd', DateEdit1.Date)) +
        ' and ' + QuotedStr(FormatDateTime('yyyy-mm-dd', DateEdit2.Date)) +
        ' ORDER BY UnUsedIndex ASC';
  end;

  if MainForm.ExportAdifSelect = True then
  begin

    for i := 0 to High(MainForm.ExportAdifArray) do
    begin
      if i > 0 then
        numberToExp := numberToExp + ', ';
      numberToExp := numberToExp + IntToStr(MainForm.ExportAdifArray[i]);
    end;
    for i := 0 to Length(MainForm.ExportAdifArray) - 1 do
    begin
      Q1.SQL.Text := 'SELECT * FROM ' + LBRecord.LogTable + ' WHERE `UnUsedIndex` in (' +
        numberToExp + ')' + ' ORDER BY UnUsedIndex ASC';
    end;
  end;

  MainForm.ExportAdifSelect := False;
  Q1.Open();
  Q2.Open();
  try
    Q1.First;
    while not Q1.EOF do
    begin
      Label1.Caption := rNumberOfQSO + ' ' + IntToStr(Nr);

      tmp := '<OPERATOR' + dmFunc.StringToADIF(
        dmFunc.RemoveSpaces(MainForm.ComboBox10.Text), CheckBox2.Checked);
      Write(f, tmp);

      tmp := '<CALL' + dmFunc.StringToADIF(
        dmFunc.RemoveSpaces(Q1.Fields.FieldByName('CallSign').AsString),
        CheckBox2.Checked);
      Write(f, tmp);

      tmp := FormatDateTime('yyyymmdd', Q1.Fields.FieldByName('QSODate').AsDateTime);
      tmp := '<QSO_DATE' + dmFunc.StringToADIF(tmp, CheckBox2.Checked);
      Write(f, tmp);

      tmp := Q1.Fields.FieldByName('QSOTime').AsString;
      tmp := copy(tmp, 1, 2) + copy(tmp, 4, 2);
      tmp := '<TIME_ON' + dmFunc.StringToADIF(tmp, CheckBox2.Checked);
      Write(f, tmp);

      if Q1.Fields.FieldByName('QSOMode').AsString <> '' then
      begin
        tmp := '<MODE' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSOMode').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('QSOBand').AsString <> '' then
      begin
        freq2 := Q1.Fields.FieldByName('QSOBand').AsString;
        Delete(freq2, Length(freq2) - 2, 1);
        //Удаляю последнюю точку
        tmp := '<FREQ' + dmFunc.StringToADIF(FormatFloat('0.#####', StrToFloat(freq2)),
          CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('QSOReportSent').AsString <> '' then
      begin
        tmp := '<RST_SENT' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSOReportSent').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('QSOReportRecived').AsString <> '' then
      begin
        tmp := '<RST_RCVD' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSOReportRecived').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if (Q1.Fields.FieldByName('SRX').AsInteger <> 0) or
        (not Q1.Fields.FieldByName('SRX').IsNull) then
      begin
        tmp := '<SRX' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'SRX').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if (Q1.Fields.FieldByName('STX').AsInteger <> 0) or
        (not Q1.Fields.FieldByName('STX').IsNull) then
      begin
        tmp := '<STX' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'STX').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if (Q1.Fields.FieldByName('SRX_STRING').AsString <> '') then
      begin
        tmp := '<SRX_STRING' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'SRX_STRING').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if (Q1.Fields.FieldByName('STX_STRING').AsString <> '') then
      begin
        tmp := '<STX_STRING' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'STX_STRING').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('OMName').AsString <> '' then
      begin
        tmp := '<NAME' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'OMName').AsString, CheckBox2.Checked);
        if CheckBox2.Checked = True then
          Write(f, UTF8ToCP1251(tmp))
        else
          Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('OMQTH').AsString <> '' then
      begin
        tmp := '<QTH' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'OMQTH').AsString, CheckBox2.Checked);
        if CheckBox2.Checked = True then
          Write(f, UTF8ToCP1251(tmp))
        else
          Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('State').AsString <> '' then
      begin
        tmp := '<STATE' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'State').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('Grid').AsString <> '' then
      begin
        tmp := '<GRIDSQUARE' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'Grid').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('WPX').AsString <> '' then
      begin
        tmp := '<PFX' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'WPX').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('DXCCPrefix').AsString <> '' then
      begin
        tmp := '<DXCC_PREF' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'DXCCPrefix').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('QSOBand').AsString <> '' then
      begin
        tmp := '<BAND' + dmFunc.StringToADIF(dmFunc.GetBandFromFreq(
          Q1.Fields.FieldByName('QSOBand').AsString), CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('CQZone').AsString <> '' then
      begin
        tmp := '<CQZ' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'CQZone').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('ITUZone').AsString <> '' then
      begin
        tmp := '<ITUZ' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'ITUZone').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('Continent').AsString <> '' then
      begin
        tmp := '<CONT' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'Continent').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('QSLInfo').AsString <> '' then
      begin
        tmp := '<QSLMSG' + dmFunc.StringToADIF(
          dmFunc.MyTrim(Q1.Fields.FieldByName('QSLInfo').AsString), CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('QSLReceQSLcc').AsString = '1' then
      begin
        EQSL_QSL_RCVD := Q1.Fields.FieldByName('QSLReceQSLcc').AsString;
        if EQSL_QSL_RCVD = '0' then
          tmp := '<EQSL_QSL_RCVD' + dmFunc.StringToADIF('N', CheckBox2.Checked)
        else
          tmp := '<EQSL_QSL_RCVD' + dmFunc.StringToADIF('Y', CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('QSLSentDate').AsString <> '' then
      begin
        tmp := FormatDateTime('yyyymmdd', Q1.Fields.FieldByName(
          'QSLSentDate').AsDateTime);
        tmp := '<QSLSDATE' + dmFunc.StringToADIF(tmp, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('QSLRecDate').AsString <> '' then
      begin
        tmp := FormatDateTime('yyyymmdd', Q1.Fields.FieldByName(
          'QSLRecDate').AsDateTime);
        tmp := '<QSLRDATE' + dmFunc.StringToADIF(tmp, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('QSLRec').AsString = '1' then
      begin
        QSL_RCVD := Q1.Fields.FieldByName('QSLRec').AsString;
        if QSL_RCVD = '0' then
          tmp := '<QSL_RCVD' + dmFunc.StringToADIF('N', CheckBox2.Checked)
        else
          tmp := '<QSL_RCVD' + dmFunc.StringToADIF('Y', CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('QSL_RCVD_VIA').AsString <> '' then
      begin
        tmp := '<QSL_RCVD_VIA' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSL_RCVD_VIA').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('QSL_SENT_VIA').AsString <> '' then
      begin
        tmp := '<QSL_SENT_VIA' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSL_SENT_VIA').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('QSLSent').AsString = '1' then
      begin
        QSL_SENT := Q1.Fields.FieldByName('QSLSent').AsString;
        if QSL_SENT = '0' then
          tmp := '<QSL_SENT' + dmFunc.StringToADIF('N', CheckBox2.Checked)
        else
          tmp := '<QSL_SENT' + dmFunc.StringToADIF('Y', CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('DXCC').AsString <> '' then
      begin
        tmp := '<DXCC' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'DXCC').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('QSOAddInfo').AsString <> '' then
      begin
        tmp := '<COMMENT' + dmFunc.StringToADIF(
          dmFunc.MyTrim(Q1.Fields.FieldByName('QSOAddInfo').AsString),
          CheckBox2.Checked);
        if CheckBox2.Checked = True then
          Write(f, UTF8ToCP1251(tmp))
        else
          Write(f, tmp);
      end;

      if Q1.Fields.FieldByName('MY_STATE').AsString <> '' then
      begin
        tmp := '<MY_STATE' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'MY_STATE').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      if Q2.Fields.FieldByName('Loc').AsString <> '' then
      begin
        tmp := '<MY_GRIDSQUARE' + dmFunc.StringToADIF(Q2.Fields.FieldByName(
          'Loc').AsString, CheckBox2.Checked);
        Write(f, tmp);
      end;

      MY_LAT := Q2.Fields.FieldByName('Lat').AsString;
      while Length(MY_LAT) > 6 do
        Delete(MY_LAT, Length(MY_LAT), 1);
      if Q2.Fields.FieldByName('Lat').AsString <> '' then
      begin
        tmp := '<MY_LAT' + dmFunc.StringToADIF(MY_LAT, CheckBox2.Checked);
        Write(f, tmp);
      end;

      MY_LON := Q2.Fields.FieldByName('Lon').AsString;
      while Length(MY_LON) > 6 do
        Delete(MY_LON, Length(MY_LON), 1);
      if Q2.Fields.FieldByName('Lon').AsString <> '' then
      begin
        tmp := '<MY_LON' + dmFunc.StringToADIF(MY_LON, CheckBox2.Checked);
      end;

      if CheckBox2.Checked = True then
        Write(f, UTF8ToCP1251(tmp))
      else
        Write(f, tmp);

      Write(f, '<EOR>'#13#10);

      if (nr mod 100 = 0) then
      begin
        Label1.Repaint;
        Application.ProcessMessages;
      end;
      Inc(nr);
      Q1.Next;
    end
  finally
    CloseFile(f);
    Label2.Caption := rDone;
    Q1.Close;
    Q2.Close;
    ShowMessage(rExportCompl)
  end;
end;

function TexportAdifForm.ExportToMobile(range: string; date: string): word;
var
  tmp: string = '';
  tmp2: string = '';
  nr: integer = 1;
  freq2: string;
begin

  if DBRecord.CurrentDB = 'MySQL' then
  begin
    Q1.DataBase := InitDB.MySQLConnection;
    Q2.DataBase := InitDB.MySQLConnection;
  end
  else
  begin
    Q1.DataBase := InitDB.SQLiteConnection;
    Q2.DataBase := InitDB.SQLiteConnection;
  end;

  Q1.Close;
  if (range = 'All') then
    Q1.SQL.Text := 'select * from ' + LBRecord.LogTable + ' ORDER BY UnUsedIndex ASC';
  if (range = 'Date') then
  begin
    if DBRecord.CurrentDB = 'MySQL' then
      Q1.SQL.Text := 'SELECT * FROM ' + LBRecord.LogTable + ' WHERE QSODate >= ' +
        '''' + FormatDateTime('yyyy-mm-dd', StrToDate(date)) +
        '''' + ' OR SYNC = 0 ORDER BY UnUsedIndex ASC'
    else
      Q1.SQL.Text :=
        'SELECT * FROM ' + LBRecord.LogTable + ' WHERE ' + 'strftime(' +
        QuotedStr('%Y-%m-%d') + ',QSODate) >= ' +
        QuotedStr(FormatDateTime('yyyy-mm-dd', StrToDate(date))) +
        ' OR SYNC = 0 ORDER BY UnUsedIndex ASC';
  end;
  Q1.Open();
  try
    Q1.First;
    while not Q1.EOF do
    begin
      tmp2 := '';
      MainForm.StatusBar1.Panels.Items[0].Text :=
        rSentRecord + ' ' + IntToStr(nr);

      tmp := '<OPERATOR' + dmFunc.StringToADIF(
        dmFunc.RemoveSpaces(MainForm.ComboBox10.Text), CheckBox2.Checked);
      tmp2 := tmp2 + tmp;

      tmp := '<CALL' + dmFunc.StringToADIF(
        dmFunc.RemoveSpaces(Q1.Fields.FieldByName('CallSign').AsString),
        CheckBox2.Checked);
      tmp2 := tmp2 + tmp;

      tmp := FormatDateTime('yyyymmdd', Q1.Fields.FieldByName('QSODate').AsDateTime);
      tmp := '<QSO_DATE' + dmFunc.StringToADIF(tmp, CheckBox2.Checked);
      tmp2 := tmp2 + tmp;

      tmp := Q1.Fields.FieldByName('QSOTime').AsString;
      tmp := copy(tmp, 1, 2) + copy(tmp, 4, 2);
      tmp := '<TIME_ON' + dmFunc.StringToADIF(tmp, CheckBox2.Checked);
      tmp2 := tmp2 + tmp;

      tmp := Q1.Fields.FieldByName('QSOTime').AsString;
      tmp := copy(tmp, 1, 2) + copy(tmp, 4, 2);
      tmp := '<TIME_OFF' + dmFunc.StringToADIF(tmp, CheckBox2.Checked);
      tmp2 := tmp2 + tmp;

      if Q1.Fields.FieldByName('QSOMode').AsString <> '' then
      begin
        tmp := '<MODE' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSOMode').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
        freq2 := Q1.Fields.FieldByName('QSOBand').AsString;
        Delete(freq2, Length(freq2) - 2, 1);
        //Удаляю последнюю точку
        tmp := '<FREQ' + dmFunc.StringToADIF(freq2, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('QSOReportSent').AsString <> '' then
      begin
        tmp := '<RST_SENT' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSOReportSent').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('QSOReportRecived').AsString <> '' then
      begin
        tmp := '<RST_RCVD' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSOReportRecived').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if (Q1.Fields.FieldByName('SRX').AsInteger <> 0) or
        (not Q1.Fields.FieldByName('SRX').IsNull) then
      begin
        tmp := '<SRX' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'SRX').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if (Q1.Fields.FieldByName('STX').AsInteger <> 0) or
        (not Q1.Fields.FieldByName('STX').IsNull) then
      begin
        tmp := '<STX' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'STX').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if (Q1.Fields.FieldByName('SRX_STRING').AsString <> '') then
      begin
        tmp := '<SRX_STRING' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'SRX_STRING').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if (Q1.Fields.FieldByName('STX_STRING').AsString <> '') then
      begin
        tmp := '<STX_STRING' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'STX_STRING').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('OMName').AsString <> '' then
      begin
        tmp := '<NAME' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'OMName').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('OMQTH').AsString <> '' then
      begin
        tmp := '<QTH' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'OMQTH').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('State').AsString <> '' then
      begin
        tmp := '<STATE' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'State').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('Grid').AsString <> '' then
      begin
        tmp := '<GRIDSQUARE' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'Grid').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('WPX').AsString <> '' then
      begin
        tmp := '<PFX' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'WPX').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('DXCCPrefix').AsString <> '' then
      begin
        tmp := '<DXCC_PREF' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'DXCCPrefix').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('QSOBand').AsString <> '' then
      begin
        tmp := '<BAND' + dmFunc.StringToADIF(dmFunc.GetBandFromFreq(
          Q1.Fields.FieldByName('QSOBand').AsString), CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('CQZone').AsString <> '' then
      begin
        tmp := '<CQZ' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'CQZone').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('ITUZone').AsString <> '' then
      begin
        tmp := '<ITUZ' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'ITUZone').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('Continent').AsString <> '' then
      begin
        tmp := '<CONT' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'Continent').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('QSLInfo').AsString <> '' then
      begin
        tmp := '<QSLMSG' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSLInfo').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('QSLReceQSLcc').AsString <> '' then
      begin
        tmp := '<EQSL_QSL_RCVD' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSLReceQSLcc').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('QSLSentDate').AsString <> '' then
      begin
        tmp := FormatDateTime('yyyymmdd', Q1.Fields.FieldByName(
          'QSLSentDate').AsDateTime);
        tmp := '<QSLSDATE' + dmFunc.StringToADIF(tmp, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('QSLRecDate').AsString <> '' then
      begin
        tmp := FormatDateTime('yyyymmdd', Q1.Fields.FieldByName(
          'QSLRecDate').AsDateTime);
        tmp := '<QSLRDATE' + dmFunc.StringToADIF(tmp, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('QSLRec').AsString <> '' then
      begin
        tmp := '<QSL_RCVD' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSLRec').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('QSL_RCVD_VIA').AsString <> '' then
      begin
        tmp := '<QSL_RCVD_VIA' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSL_RCVD_VIA').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('QSL_SENT_VIA').AsString <> '' then
      begin
        tmp := '<QSL_SENT_VIA' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSL_SENT_VIA').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('QSLSent').AsString <> '' then
      begin
        tmp := '<QSL_SENT' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSLSent').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('DXCC').AsString <> '' then
      begin
        tmp := '<DXCC' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'DXCC').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('QSOAddInfo').AsString <> '' then
      begin
        tmp := '<COMMENT' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'QSOAddInfo').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('MY_STATE').AsString <> '' then
      begin
        tmp := '<MY_STATE' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'MY_STATE').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('MY_GRIDSQUARE').AsString <> '' then
      begin
        tmp := '<MY_GRIDSQUARE' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'MY_GRIDSQUARE').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('MY_LAT').AsString <> '' then
      begin
        tmp := '<MY_LAT' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'MY_LAT').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      if Q1.Fields.FieldByName('MY_LON').AsString <> '' then
      begin
        tmp := '<MY_LON' + dmFunc.StringToADIF(Q1.Fields.FieldByName(
          'MY_LON').AsString, CheckBox2.Checked);
        tmp2 := tmp2 + tmp;
      end;

      tmp := '<EOR>';
      tmp2 := tmp2 + tmp;
      tmp := #13;
      tmp2 := tmp2 + tmp;
      MainForm.AdifMobileString.Add(tmp2);
      if (nr mod 100 = 0) then
      begin
        MainForm.StatusBar1.Repaint;
        Application.ProcessMessages;
      end;
      Inc(nr);
      Q1.Next;
    end;
  finally
    Result := nr;
    Q1.Close;
  end;

end;

end.
