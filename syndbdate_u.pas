unit synDBDate_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Calendar,
  StdCtrls, resourcestr;

type

  { TSynDBDate }

  TSynDBDate = class(TForm)
    Button1: TButton;
    Calendar1: TCalendar;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  SynDBDate: TSynDBDate;

implementation

uses MainForm_U, InitDB_dm;

{$R *.lfm}

{ TSynDBDate }

procedure TSynDBDate.Button1Click(Sender: TObject);
var
  LogTableMySQL: string;
  err, ok: integer;
  LogTableSQLite: string;
  copyHost, copyUser, copyPass, copyDB, copyPort: string;
begin
{
  //Синхронизация из MySQL в SQLite
  if dbSel = 'MySQL' then
  begin
    try
      Application.ProcessMessages;
      err := 0;
      ok := 0;
      with MainForm.CopySQLQuery do
      begin
        Close;
        SQL.Clear;
        SQL.Text := 'SELECT LogTable FROM LogBookInfo WHERE CallName =' +
          '''' + CallLogBook + '''';
        Open;
        LogTableSQLite := FieldByName('LogTable').AsString;
        Close;
      end;

      with MainForm.DBGrid1.DataSource.DataSet do
      begin
        Filtered := False;
        Filter := 'QSODate = ' + QuotedStr(Calendar1.Date);
        Filtered := True;
        First;
      end;


      while not MainForm.DBGrid1.DataSource.DataSet.EOF do
      begin
        MainForm.DUPEQuery.Close;
        MainForm.DUPEQuery.SQL.Clear;
        MainForm.DUPEQuery.SQL.Text :=
          'SELECT COUNT(*) FROM ' + LogTableSQLite +
          ' WHERE strftime(''%d.%m.%Y'',QSODate) = ' + QuotedStr(
          FormatDateTime('dd.mm.yyyy', MainForm.DBGrid1.DataSource.DataSet.FieldByName(
          'QSODate').AsDateTime)) + ' AND QSOTime = ' +
          QuotedStr(MainForm.DBGrid1.DataSource.DataSet.FieldByName(
          'QSOTime').AsString) +
          ' AND CallSign = ' + QuotedStr(MainForm.DBGrid1.DataSource.DataSet.FieldByName(
          'CallSign').AsString);
        MainForm.DUPEQuery.Open;
        if MainForm.DUPEQuery.Fields.Fields[0].AsInteger > 0 then
        begin
          Application.ProcessMessages;
          MainForm.SQLiteTr.Rollback;
          Inc(err);
          MainForm.StatusBar1.Panels.Items[0].Text := rDuplicates + IntToStr(err);
        end
        else
        begin
          with MainForm.CopySQLQuery do
          begin
            Application.ProcessMessages;
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO ' + LogTableSQLite +
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
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
            Params.ParamByName('ICallSign').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
            Params.ParamByName('IQSODate').AsDateTime :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsDateTime;
            Params.ParamByName('IQSOTime').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsString;
            Params.ParamByName('IQSOBand').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
            Params.ParamByName('IQSOMode').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;
            Params.ParamByName('IQSOReportSent').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSOReportSent').AsString;
            Params.ParamByName('IQSOReportRecived').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName(
              'QSOReportRecived').AsString;
            Params.ParamByName('IOMName').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('OMName').AsString;
            Params.ParamByName('IOMQTH').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('OMQTH').AsString;
            Params.ParamByName('IState').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('State').AsString;
            Params.ParamByName('IGrid').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;
            Params.ParamByName('IIOTA').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('IOTA').AsString;
            Params.ParamByName('IQSLManager').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSLManager').AsString;
            Params.ParamByName('IQSLSent').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSLSent').AsString;
            Params.ParamByName('IQSLSentAdv').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString;

            if MainForm.DBGrid1.DataSource.DataSet.FieldByName(
              'QSLSentDate').IsNull = True then
              Params.ParamByName('IQSLSentDate').IsNull
            else
              Params.ParamByName('IQSLSentDate').AsDate :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName(
                'QSLSentDate').AsDateTime;

            Params.ParamByName('IQSLRec').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSLRec').AsString;

            if MainForm.DBGrid1.DataSource.DataSet.FieldByName(
              'QSLRecDate').IsNull = True then
              Params.ParamByName('IQSLRecDate').IsNull
            else
              Params.ParamByName('IQSLRecDate').AsDate :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSLRecDate').AsDateTime;

            Params.ParamByName('IMainPrefix').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('MainPrefix').AsString;
            Params.ParamByName('IDXCCPrefix').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('DXCCPrefix').AsString;
            Params.ParamByName('ICQZone').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('CQZone').AsString;
            Params.ParamByName('IITUZone').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('ITUZone').AsString;
            Params.ParamByName('IQSOAddInfo').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSOAddInfo').AsString;
            Params.ParamByName('IMarker').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('Marker').AsString;
            Params.ParamByName('IManualSet').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('ManualSet').AsString;
            Params.ParamByName('IDigiBand').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('DigiBand').AsString;
            Params.ParamByName('IContinent').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('Continent').AsString;
            Params.ParamByName('IShortNote').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('ShortNote').AsString;
            Params.ParamByName('IQSLReceQSLcc').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSLReceQSLcc').AsString;
            Params.ParamByName('ILoTWRec').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('LoTWRec').AsString;

            if MainForm.DBGrid1.DataSource.DataSet.FieldByName(
              'LoTWRecDate').IsNull = True then
              Params.ParamByName('ILoTWRecDate').IsNull
            else
              Params.ParamByName('ILoTWRecDate').AsDate :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName(
                'LoTWRecDate').AsDateTime;

            Params.ParamByName('IQSLInfo').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSLInfo').AsString;
            Params.ParamByName('ICall').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('Call').AsString;
            Params.ParamByName('IState1').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('State1').AsString;
            Params.ParamByName('IState2').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('State2').AsString;
            Params.ParamByName('IState3').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('State3').AsString;
            Params.ParamByName('IState4').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('State4').AsString;
            Params.ParamByName('IWPX').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('WPX').AsString;
            Params.ParamByName('IAwardsEx').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('AwardsEx').AsString;
            Params.ParamByName('IValidDX').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('ValidDX').AsString;
            Params.ParamByName('ISRX').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('SRX').AsString;
            Params.ParamByName('ISRX_STRING').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('SRX_STRING').AsString;
            Params.ParamByName('ISTX').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('STX').AsString;
            Params.ParamByName('ISTX_STRING').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('STX_STRING').AsString;
            Params.ParamByName('ISAT_NAME').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('SAT_NAME').AsString;
            Params.ParamByName('ISAT_MODE').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('SAT_MODE').AsString;
            Params.ParamByName('IPROP_MODE').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('PROP_MODE').AsString;
            Params.ParamByName('ILoTWSent').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('LoTWSent').AsString;
            Params.ParamByName('IQSL_RCVD_VIA').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString;
            Params.ParamByName('IQSL_SENT_VIA').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString;
            Params.ParamByName('IDXCC').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('DXCC').AsString;
            Params.ParamByName('IUSERS').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('USERS').AsString;
            Params.ParamByName('INoCalcDXCC').AsString :=
              MainForm.DBGrid1.DataSource.DataSet.FieldByName('NoCalcDXCC').AsString;
            ExecSQL;
          end;
          MainForm.SQLiteTr.Commit;
          Inc(ok);
        end;
        Application.ProcessMessages;
        MainForm.DBGrid1.DataSource.DataSet.Next;
      end;
      MainForm.StatusBar1.Panels.Items[0].Text :=
        'Готово! Количество дубликатов ' + IntToStr(err) + ', синхронизировано ' +
        IntToStr(ok) + ' связей';
    except
      ShowMessage('Ошибка при работе с БД. Проверьте подключение и настройки');
    end;
    MainForm.DBGrid1.DataSource.DataSet.Filtered := False;
    MainForm.DBGrid1.DataSource.DataSet.Last;
  end;

  if dbSel = 'SQLite' then
  begin
    try
      copyUser := INIFile.ReadString('DataBases', 'LoginName', '');
      copyPass := INIFile.ReadString('DataBases', 'Password', '');
      copyHost := INIFile.ReadString('DataBases', 'HostAddr', '');
      copyPort := INIFile.ReadString('DataBases', 'Port', '');
      copyDB := INIFile.ReadString('DataBases', 'DataBaseName', '');

      if (copyUser = '') or (copyHost = '') or (copyDB = '') then
      begin
        ShowMessage('Не настроены параметры базы данных MySQL');
      end
      else
      begin
        MainForm.MySQLLOGDBConnection.HostName := copyHost;
        MainForm.MySQLLOGDBConnection.Port := StrToInt(copyPort);
        MainForm.MySQLLOGDBConnection.UserName := copyUser;
        MainForm.MySQLLOGDBConnection.Password := copyPass;
        MainForm.MySQLLOGDBConnection.DatabaseName := copyDB;
        MainForm.MySQLLOGDBConnection.Connected := True;
        MainForm.MySQLLOGDBConnection.Transaction := MainForm.SQLiteTr;
        MainForm.SQLiteTr.DataBase := MainForm.MySQLLOGDBConnection;
        MainForm.CopySQLQuery2.Transaction := MainForm.SQLiteTr;
        MainForm.DUPEQuery2.Transaction := MainForm.SQLiteTr;
        Application.ProcessMessages;
        err := 0;
        ok := 0;
        with MainForm.CopySQLQuery2 do
        begin
          Close;
          SQL.Clear;
          SQL.Text := 'SELECT LogTable FROM LogBookInfo WHERE CallName =' +
            '''' + CallLogBook + '''';
          Open;
          LogTableMySQL := FieldByName('LogTable').AsString;
          Close;
        end;

        with MainForm.DBGrid1.DataSource.DataSet do
        begin
          Filtered := False;
          Filter := 'QSODate = ' + QuotedStr(Calendar1.Date);
          Filtered := True;
          First;
        end;

        while not MainForm.DBGrid1.DataSource.DataSet.EOF do
        begin
          MainForm.DUPEQuery2.Close;
          MainForm.DUPEQuery2.SQL.Clear;
          MainForm.DUPEQuery2.SQL.Text :=
            'SELECT COUNT(*) FROM ' + LogTableMySQL +
            ' WHERE DATE_FORMAT(QSODate, ''%d.%m.%Y'') = ' + QuotedStr(
            FormatDateTime('dd.mm.yyyy', MainForm.DBGrid1.DataSource.DataSet.FieldByName(
            'QSODate').AsDateTime)) + ' AND QSOTime = ' +
            QuotedStr(MainForm.DBGrid1.DataSource.DataSet.FieldByName(
            'QSOTime').AsString) + ' AND CallSign = ' +
            QuotedStr(MainForm.DBGrid1.DataSource.DataSet.FieldByName(
            'CallSign').AsString);
          MainForm.DUPEQuery2.Open;
          if MainForm.DUPEQuery2.Fields.Fields[0].AsInteger > 0 then
          begin
            Application.ProcessMessages;
            MainForm.SQLiteTr.Rollback;
            Inc(err);
            MainForm.StatusBar1.Panels.Items[0].Text := rDuplicates + IntToStr(err);
          end
          else
          begin
            with MainForm.CopySQLQuery2 do
            begin
              Application.ProcessMessages;
              Close;
              SQL.Clear;
              SQL.Add('INSERT INTO ' + LogTableMySQL +
                '(`UnUsedIndex`, `CallSign`, `QSODate`, `QSOTime`, `QSOBand`, `QSOMode`, '
                +
                '`QSOReportSent`, `QSOReportRecived`, `OMName`, `OMQTH`, `State`, `Grid`, `IOTA`,'
                +
                '`QSLManager`, `QSLSent`, `QSLSentAdv`, `QSLSentDate`, `QSLRec`, `QSLRecDate`,'
                +
                '`MainPrefix`, `DXCCPrefix`, `CQZone`, `ITUZone`, `QSOAddInfo`, `Marker`, `ManualSet`,'
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
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
              Params.ParamByName('ICallSign').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('CallSign').AsString;
              Params.ParamByName('IQSODate').AsDateTime :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSODate').AsDateTime;
              Params.ParamByName('IQSOTime').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSOTime').AsString;
              Params.ParamByName('IQSOBand').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSOBand').AsString;
              Params.ParamByName('IQSOMode').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSOMode').AsString;
              Params.ParamByName('IQSOReportSent').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName(
                'QSOReportSent').AsString;
              Params.ParamByName('IQSOReportRecived').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName(
                'QSOReportRecived').AsString;
              Params.ParamByName('IOMName').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('OMName').AsString;
              Params.ParamByName('IOMQTH').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('OMQTH').AsString;
              Params.ParamByName('IState').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('State').AsString;
              Params.ParamByName('IGrid').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('Grid').AsString;
              Params.ParamByName('IIOTA').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('IOTA').AsString;
              Params.ParamByName('IQSLManager').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSLManager').AsString;
              Params.ParamByName('IQSLSent').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSLSent').AsString;
              Params.ParamByName('IQSLSentAdv').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSLSentAdv').AsString;

              if MainForm.DBGrid1.DataSource.DataSet.FieldByName(
                'QSLSentDate').IsNull = True then
                Params.ParamByName('IQSLSentDate').IsNull
              else
                Params.ParamByName('IQSLSentDate').AsDate :=
                  MainForm.DBGrid1.DataSource.DataSet.FieldByName(
                  'QSLSentDate').AsDateTime;

              Params.ParamByName('IQSLRec').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSLRec').AsString;

              if MainForm.DBGrid1.DataSource.DataSet.FieldByName(
                'QSLRecDate').IsNull = True then
                Params.ParamByName('IQSLRecDate').IsNull
              else
                Params.ParamByName('IQSLRecDate').AsDate :=
                  MainForm.DBGrid1.DataSource.DataSet.FieldByName(
                  'QSLRecDate').AsDateTime;

              Params.ParamByName('IMainPrefix').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('MainPrefix').AsString;
              Params.ParamByName('IDXCCPrefix').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('DXCCPrefix').AsString;
              Params.ParamByName('ICQZone').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('CQZone').AsString;
              Params.ParamByName('IITUZone').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('ITUZone').AsString;
              Params.ParamByName('IQSOAddInfo').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSOAddInfo').AsString;
              Params.ParamByName('IMarker').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('Marker').AsString;
              Params.ParamByName('IManualSet').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('ManualSet').AsString;
              Params.ParamByName('IDigiBand').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('DigiBand').AsString;
              Params.ParamByName('IContinent').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('Continent').AsString;
              Params.ParamByName('IShortNote').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('ShortNote').AsString;
              Params.ParamByName('IQSLReceQSLcc').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSLReceQSLcc').AsString;
              Params.ParamByName('ILoTWRec').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('LoTWRec').AsString;

              if MainForm.DBGrid1.DataSource.DataSet.FieldByName(
                'LoTWRecDate').IsNull = True then
                Params.ParamByName('ILoTWRecDate').IsNull
              else
                Params.ParamByName('ILoTWRecDate').AsDate :=
                  MainForm.DBGrid1.DataSource.DataSet.FieldByName(
                  'LoTWRecDate').AsDateTime;

              Params.ParamByName('IQSLInfo').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSLInfo').AsString;
              Params.ParamByName('ICall').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('Call').AsString;
              Params.ParamByName('IState1').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('State1').AsString;
              Params.ParamByName('IState2').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('State2').AsString;
              Params.ParamByName('IState3').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('State3').AsString;
              Params.ParamByName('IState4').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('State4').AsString;
              Params.ParamByName('IWPX').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('WPX').AsString;
              Params.ParamByName('IAwardsEx').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('AwardsEx').AsString;
              Params.ParamByName('IValidDX').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('ValidDX').AsString;
              Params.ParamByName('ISRX').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('SRX').AsString;
              Params.ParamByName('ISRX_STRING').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('SRX_STRING').AsString;
              Params.ParamByName('ISTX').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('STX').AsString;
              Params.ParamByName('ISTX_STRING').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('STX_STRING').AsString;
              Params.ParamByName('ISAT_NAME').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('SAT_NAME').AsString;
              Params.ParamByName('ISAT_MODE').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('SAT_MODE').AsString;
              Params.ParamByName('IPROP_MODE').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('PROP_MODE').AsString;
              Params.ParamByName('ILoTWSent').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('LoTWSent').AsString;
              Params.ParamByName('IQSL_RCVD_VIA').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSL_RCVD_VIA').AsString;
              Params.ParamByName('IQSL_SENT_VIA').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('QSL_SENT_VIA').AsString;
              Params.ParamByName('IDXCC').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('DXCC').AsString;
              Params.ParamByName('IUSERS').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('USERS').AsString;
              Params.ParamByName('INoCalcDXCC').AsString :=
                MainForm.DBGrid1.DataSource.DataSet.FieldByName('NoCalcDXCC').AsString;
              ExecSQL;
            end;
            MainForm.SQLiteTr.Commit;
            Inc(ok);
          end;
          Application.ProcessMessages;
          MainForm.DBGrid1.DataSource.DataSet.Next;
        end;
        MainForm.StatusBar1.Panels.Items[0].Text :=
          'Готово! Количество дубликатов ' + IntToStr(err) +
          ', синхронизировано ' + IntToStr(ok) + ' связей';
      end;
    except
      ShowMessage('Ошибка при работе с БД. Проверьте подключение и настройки');
    end;
    MainForm.DBGrid1.DataSource.DataSet.Filtered := False;
    MainForm.DBGrid1.DataSource.DataSet.Last;
  end;  }
end;

procedure TSynDBDate.FormShow(Sender: TObject);
begin
  Calendar1.DateTime:=Now;
end;

end.
