unit editqso_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DateTimePicker, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ComCtrls, EditBtn, Buttons, ExtCtrls, DBGrids, DBCtrls,
  InformationForm_U, sqldb, DB, RegExpr, Grids;

type

  { TEditQSO_Form }

  TEditQSO_Form = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox6: TComboBox;
    ComboBox7: TComboBox;
    ComboBox9: TComboBox;
    Edit21: TEdit;
    DateEdit1: TDateEdit;
    DateEdit2: TDateEdit;
    DateEdit3: TDateEdit;
    DateEdit4: TDateEdit;
    DateTimePicker1: TDateTimePicker;
    DBGrid1: TDBGrid;
    DBLookupComboBox2: TDBLookupComboBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    Edit2: TEdit;
    Edit20: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
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
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    SpeedButton1: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    SatPropQuery: TSQLQuery;
    TerrQuery: TSQLQuery;
    UPDATE_Query: TSQLQuery;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);
    procedure SpeedButton12Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  EditQSO_Form: TEditQSO_Form;

implementation

uses MainForm_U, DXCCEditForm_U, QSLManagerForm_U, dmFunc_U, IOTA_Form_U, STATE_Form_U;

{$R *.lfm}

{ TEditQSO_Form }

procedure TEditQSO_Form.SpeedButton11Click(Sender: TObject);
begin
  CheckForm := 'Edit';
  InformationForm.Show;
end;

procedure TEditQSO_Form.SpeedButton12Click(Sender: TObject);
begin
  QSLManager_Form.Show;
end;

procedure TEditQSO_Form.SpeedButton1Click(Sender: TObject);
begin
  CountryEditForm.CountryQditQuery.DataBase := MainForm.ServiceDBConnection;
  CountryEditForm.CountryQditQuery.Close;
  CountryEditForm.CountryQditQuery.SQL.Clear;
  CountryEditForm.CountryQditQuery.SQL.Text := 'SELECT * FROM CountryDataEx';
  CountryEditForm.CountryQditQuery.Open;
  MainForm.SQLServiceTransaction.Active := True;
  CountryEditForm.Caption := 'ARRLList';
  CountryEditForm.DBGrid1.DataSource.DataSet.Locate('ARRLPrefix', Edit7.Text, []);
  CountryEditForm.Show;
end;

procedure TEditQSO_Form.SpeedButton2Click(Sender: TObject);
begin
  CountryEditForm.CountryQditQuery.DataBase := MainForm.ServiceDBConnection;

  CountryEditForm.CountryQditQuery.Close;
  CountryEditForm.CountryQditQuery.SQL.Clear;
  CountryEditForm.CountryQditQuery.SQL.Text := 'SELECT * FROM Province';
  CountryEditForm.CountryQditQuery.Open;
  MainForm.SQLServiceTransaction.Active := True;
  CountryEditForm.Caption := 'Province';
  CountryEditForm.DBGrid1.DataSource.DataSet.Locate('Prefix', Edit8.Text, []);
  CountryEditForm.Show;
end;

procedure TEditQSO_Form.SpeedButton9Click(Sender: TObject);
begin
  IOTA_Form.Show;
end;

procedure TEditQSO_Form.Button1Click(Sender: TObject);
begin
  EditQSO_Form.Close;
end;

procedure TEditQSO_Form.Button2Click(Sender: TObject);
begin
  EditQSO_Form.Close;
end;

procedure TEditQSO_Form.Button3Click(Sender: TObject);
var
  FmtStngs: TFormatSettings;
  DigiBand: double;
  ind: integer;
  FREQ_string: string;
begin
  FmtStngs.TimeSeparator := ':';
  FmtStngs.LongTimeFormat := 'hh:nn';
  FREQ_string := ComboBox1.Text;
  Delete(FREQ_string, length(FREQ_string) - 2, 1);
  DigiBand := dmFunc.GetDigiBandFromFreq(FREQ_string);

  ind := MainForm.DBGrid1.DataSource.DataSet.RecNo;
  with UPDATE_Query do
  begin
    Close;
    SQL.Clear;
    SQL.Add('UPDATE ' + LogTable +
      ' SET `CallSign`=:CallSign, `QSODate`=:QSODate, `QSOTime`=:QSOTime, `QSOBand`=:QSOBand, `QSOMode`=:QSOMode,`QSOSubMode`=:QSOSubMode, `QSOReportSent`=:QSOReportSent, `QSOReportRecived`=:QSOReportRecived, `OMName`=:OMName, `OMQTH`=:OMQTH, `State`=:State, `Grid`=:Grid, `IOTA`=:IOTA, `QSLManager`=:QSLManager, `QSLSent`=:QSLSent, `QSLSentAdv`=:QSLSentAdv, `QSLSentDate`=:QSLSentDate, `QSLRec`=:QSLRec, `QSLRecDate`=:QSLRecDate, `MainPrefix`=:MainPrefix, `DXCCPrefix`=:DXCCPrefix, `CQZone`=:CQZone, `ITUZone`=:ITUZone, `QSOAddInfo`=:QSOAddInfo, `Marker`=:Marker, `ManualSet`=:ManualSet, `DigiBand`=:DigiBand, `Continent`=:Continent, `ShortNote`=:ShortNote, `QSLReceQSLcc`=:QSLReceQSLcc, `LoTWRec`=:LoTWRec, `LoTWRecDate`=:LoTWRecDate, `QSLInfo`=:QSLInfo, `Call`=:Call, `State1`=:State1, `State2`=:State2, `State3`=:State3, `State4`=:State4, `WPX`=:WPX, `ValidDX`=:ValidDX, `SRX`=:SRX, `SRX_STRING`=:SRX_STRING, `STX`=:STX, `STX_STRING`=:STX_STRING, `SAT_NAME`=:SAT_NAME, `SAT_MODE`=:SAT_MODE, `PROP_MODE`=:PROP_MODE, `LoTWSent`=:LoTWSent, `QSL_RCVD_VIA`=:QSL_RCVD_VIA, `QSL_SENT_VIA`=:QSL_SENT_VIA, `DXCC`=:DXCC, `NoCalcDXCC`=:NoCalcDXCC WHERE `UnUsedIndex`=:UnUsedIndex');
    Params.ParamByName('UnUsedIndex').AsInteger := UnUsIndex;
    Params.ParamByName('CallSign').AsString := Edit1.Text;
    Params.ParamByName('QSODate').AsDateTime := DateEdit1.Date;
    Params.ParamByName('QSOTime').AsString := TimeToStr(DateTimePicker1.Time, FmtStngs);
    Params.ParamByName('QSOBand').AsString := ComboBox1.Text;
    Params.ParamByName('QSOMode').AsString := ComboBox2.Text;
    Params.ParamByName('QSOSubMode').AsString := ComboBox9.Text;
    Params.ParamByName('QSOReportSent').AsString := Edit2.Text;
    Params.ParamByName('QSOReportRecived').AsString := Edit3.Text;
    Params.ParamByName('OMName').AsString := Edit4.Text;
    Params.ParamByName('OMQTH').AsString := Edit5.Text;
    Params.ParamByName('State').AsString := Edit17.Text;
    Params.ParamByName('Grid').AsString := Edit14.Text;
    Params.ParamByName('IOTA').AsString := Edit18.Text;
    Params.ParamByName('QSLManager').AsString := Edit19.Text;
    Params.ParamByName('QSLSent').AsBoolean := RadioButton1.Checked;

    if RadioButton1.Checked = True then
      Params.ParamByName('QSLSentAdv').AsString := 'T';
    if RadioButton2.Checked = True then
      Params.ParamByName('QSLSentAdv').AsString := 'P';
    if RadioButton3.Checked = True then
      Params.ParamByName('QSLSentAdv').AsString := 'Q';
    if RadioButton4.Checked = True then
      Params.ParamByName('QSLSentAdv').AsString := 'F';
    if RadioButton5.Checked = True then
      Params.ParamByName('QSLSentAdv').AsString := 'N';

    if DateEdit3.Text <> '' then
      Params.ParamByName('QSLSentDate').AsDate := DateEdit3.Date
    else
      Params.ParamByName('QSLSentDate').IsNull;

    Params.ParamByName('QSLRec').AsBoolean := CheckBox4.Checked;

    if DateEdit2.Text <> '' then
      Params.ParamByName('QSLRecDate').AsDate := DateEdit2.Date
    else
      Params.ParamByName('QSLRecDate').IsNull;

    Params.ParamByName('DXCC').AsString := Edit6.Text;
    Params.ParamByName('DXCCPrefix').AsString := Edit7.Text;
    Params.ParamByName('CQZone').AsString := Edit15.Text;
    Params.ParamByName('ITUZone').AsString := Edit16.Text;
    Params.ParamByName('QSOAddInfo').AsString := Memo1.Text;
    Params.ParamByName('Marker').AsBoolean := CheckBox3.Checked;
    Params.ParamByName('ManualSet').AsBoolean := False;

    Params.ParamByName('DigiBand').AsString := FloatToStr(DigiBand);

    Params.ParamByName('Continent').AsString := Edit13.Text;
    Params.ParamByName('ShortNote').AsString := Memo1.Text;
    Params.ParamByName('QSLReceQSLcc').AsBoolean := CheckBox5.Checked;
    Params.ParamByName('LoTWRec').AsBoolean := CheckBox6.Checked;

    if DateEdit4.Text <> '' then
      Params.ParamByName('LoTWRecDate').AsDate := DateEdit4.Date
    else
      Params.ParamByName('LoTWRecDate').IsNull;

    Params.ParamByName('QSLInfo').AsString := Edit20.Text;
    Params.ParamByName('Call').AsString := Edit1.Text;
    Params.ParamByName('State1').AsString := Edit10.Text;
    Params.ParamByName('State2').AsString := Edit9.Text;
    Params.ParamByName('State3').AsString := Edit11.Text;
    Params.ParamByName('State4').AsString := Edit12.Text;
    Params.ParamByName('WPX').AsString := Edit8.Text;
    Params.ParamByName('ValidDX').AsBoolean := CheckBox2.Checked;
    Params.ParamByName('SRX').IsNull;
    Params.ParamByName('SRX_STRING').AsString := '';
    Params.ParamByName('STX').IsNull;
    Params.ParamByName('STX_STRING').AsString := '';
    Params.ParamByName('SAT_NAME').AsString := DBLookupComboBox2.Text;
    Params.ParamByName('SAT_MODE').AsString := ComboBox4.Text;
    Params.ParamByName('PROP_MODE').AsString := ComboBox3.Text;

    //Пока нету лотв ставлю 0
    Params.ParamByName('LoTWSent').AsString := '0';

    if ComboBox6.Text <> '' then
      Params.ParamByName('QSL_RCVD_VIA').AsString := ComboBox6.Text
    else
      Params.ParamByName('QSL_RCVD_VIA').IsNull;
    if ComboBox7.Text <> '' then
      Params.ParamByName('QSL_SENT_VIA').AsString := ComboBox7.Text
    else
      Params.ParamByName('QSL_SENT_VIA').IsNull;
    Params.ParamByName('NoCalcDXCC').AsBoolean := CheckBox1.Checked;
    Params.ParamByName('MainPrefix').AsString := Edit8.Text;
    ExecSQL;
  end;
  MainForm.SQLTransaction1.Commit;
  MainForm.SelDB(CallLogBook);
  MainForm.DBGrid1.DataSource.DataSet.RecNo := ind;

end;

procedure TEditQSO_Form.Button4Click(Sender: TObject);
var
  i, j: integer;
  BoolPrefix: boolean;
begin
  BoolPrefix := False;

  with TerrQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('select * from ' + LogTable + ' where CallSign = "' + Edit1.Text + '"');
    Open;
  end;

  for i := 0 to PrefixProvinceCount do
  begin
    if (PrefixExpProvinceArray[i].reg.Exec(Edit1.Text)) and
      (PrefixExpProvinceArray[i].reg.Match[0] = Edit1.Text) then
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
      GroupBox1.Caption := MainForm.PrefixQuery.FieldByName('Country').AsString;
      Edit7.Text := MainForm.PrefixQuery.FieldByName('ARRLPrefix').AsString;
      Edit8.Text := MainForm.PrefixQuery.FieldByName('Prefix').AsString;
      Edit15.Text := MainForm.PrefixQuery.FieldByName('CQZone').AsString;
      Edit16.Text := MainForm.PrefixQuery.FieldByName('ITUZone').AsString;
      Edit13.Text := MainForm.PrefixQuery.FieldByName('Continent').AsString;
      Edit6.Text := MainForm.PrefixQuery.FieldByName('DXCC').AsString;
    end;
  end;
  if BoolPrefix = False then
  begin
    for j := 0 to PrefixARRLCount do
    begin
      if (PrefixExpARRLArray[j].reg.Exec(Edit1.Text)) and
        (PrefixExpARRLArray[j].reg.Match[0] = Edit1.Text) then
      begin
        with MainForm.PrefixQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add('select * from CountryDataEx where _id = "' +
            IntToStr(PrefixExpARRLArray[j].id) + '"');
          Open;
          if FieldByName('Status').AsString = 'Deleted' then
          begin
            PrefixExpARRLArray[j].reg.ExecNext;
            Exit;
          end;

        end;
        GroupBox1.Caption := MainForm.PrefixQuery.FieldByName('Country').AsString;
        Edit7.Text := MainForm.PrefixQuery.FieldByName('ARRLPrefix').AsString;
        Edit8.Text := MainForm.PrefixQuery.FieldByName('ARRLPrefix').AsString;
        Edit15.Text := MainForm.PrefixQuery.FieldByName('CQZone').AsString;
        Edit16.Text := MainForm.PrefixQuery.FieldByName('ITUZone').AsString;
        Edit13.Text := MainForm.PrefixQuery.FieldByName('Continent').AsString;
        Edit6.Text := MainForm.PrefixQuery.FieldByName('DXCC').AsString;
      end;
    end;
  end;
end;

procedure TEditQSO_Form.ComboBox2Change(Sender: TObject);
var
  modesString: TStringList;
begin
  modesString := TStringList.Create;
  MainForm.addModes(ComboBox2.Text, True, modesString);
  ComboBox9.Items := modesString;
  modesString.Free;
end;

procedure TEditQSO_Form.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: integer; Column: TColumn; State: TGridDrawState);
var
  i: integer;
begin
  if MainForm.LOGBookDS.DataSet.FieldByName('QSLSentAdv').AsString = 'N' then
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

  if (MainForm.LOGBookDS.DataSet.FieldByName('QSL').AsString = '100') or
    (MainForm.LOGBookDS.DataSet.FieldByName('QSL').AsString = '110') then
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

  if (MainForm.LOGBookDS.DataSet.FieldByName('QSLs').AsString = '10') or
    (MainForm.LOGBookDS.DataSet.FieldByName('QSLs').AsString = '11') then
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

  if (MainForm.LOGBookDS.DataSet.FieldByName('QSL').AsString = '010') or
    (MainForm.LOGBookDS.DataSet.FieldByName('QSL').AsString = '110') or
    (MainForm.LOGBookDS.DataSet.FieldByName('QSL').AsString = '111') then
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
      if (MainForm.LOGBookDS.DataSet.FieldByName('QSL').AsString = '000') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth(''), Rect.Top + 0, '');
      end;

      if (MainForm.LOGBookDS.DataSet.FieldByName('QSL').AsString = '100') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth('P'), Rect.Top + 0, 'P');
      end;

      if (MainForm.LOGBookDS.DataSet.FieldByName('QSL').AsString = '110') then
      begin
        TextOut(Rect.Right - 10 - DBGrid1.Canvas.TextWidth('PE'),
          Rect.Top + 0, 'PE');
      end;

      if (MainForm.LOGBookDS.DataSet.FieldByName('QSL').AsString = '111') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth('PLE'),
          Rect.Top + 0, 'PLE');
      end;

      if (MainForm.LOGBookDS.DataSet.FieldByName('QSL').AsString = '010') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth('E'), Rect.Top + 0, 'E');
      end;

      if (MainForm.LOGBookDS.DataSet.FieldByName('QSL').AsString = '001') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth('L'), Rect.Top + 0, 'L');
      end;

      if (MainForm.LOGBookDS.DataSet.FieldByName('QSL').AsString = '101') then
      begin
        TextOut(Rect.Right - 10 - DBGrid1.Canvas.TextWidth('PL'),
          Rect.Top + 0, 'PL');
      end;

      if (MainForm.LOGBookDS.DataSet.FieldByName('QSL').AsString = '011') then
      begin
        TextOut(Rect.Right - 10 - DBGrid1.Canvas.TextWidth('LE'),
          Rect.Top + 0, 'LE');
      end;
    end;
  end;

  if (Column.FieldName = 'QSLs') then
  begin
    with DBGrid1.Canvas do
    begin
      FillRect(Rect);
      if (MainForm.LOGBookDS.DataSet.FieldByName('QSLs').AsString = '00') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth(''), Rect.Top + 0, '');
      end;

      if (MainForm.LOGBookDS.DataSet.FieldByName('QSLs').AsString = '10') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth('P'), Rect.Top + 0, 'P');
      end;

      if (MainForm.LOGBookDS.DataSet.FieldByName('QSLs').AsString = '11') then
      begin
        TextOut(Rect.Right - 10 - DBGrid1.Canvas.TextWidth('PL'),
          Rect.Top + 0, 'PE');
      end;

      if (MainForm.LOGBookDS.DataSet.FieldByName('QSLs').AsString = '01') then
      begin
        TextOut(Rect.Right - 6 - DBGrid1.Canvas.TextWidth('L'), Rect.Top + 0, 'PLE');
      end;
    end;
  end;

  if IniF.ReadString('SetLog', 'ShowBand', '') = 'True' then
  begin
    if (Column.FieldName = 'QSOBand') then
    begin
      DBGrid1.Canvas.FillRect(Rect);
      DBGrid1.Canvas.TextOut(Rect.Left + 2, Rect.Top + 0,
        dmFunc.GetBandFromFreq(MainForm.LOGBookDS.DataSet.FieldByName(
        'QSOBand').AsString));
    end;
  end;

end;

procedure TEditQSO_Form.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Edit1.Text := '';
end;

procedure TEditQSO_Form.FormCreate(Sender: TObject);
var
  i: integer;
begin
  if InitLog_DB = 'YES' then
  begin
    if DefaultDB = 'MySQL' then
    begin
      TerrQuery.DataBase := MainForm.MySQLLOGDBConnection;
      UPDATE_Query.DataBase := MainForm.MySQLLOGDBConnection;
    end
    else
    begin
      TerrQuery.DataBase := MainForm.SQLiteDBConnection;
      UPDATE_Query.DataBase := MainForm.SQLiteDBConnection;
    end;

    //  ModesQuery.DataBase := MainForm.ServiceDBConnection;
    //  BandsQuery.DataBase := MainForm.ServiceDBConnection;
    SatPropQuery.DataBase := MainForm.ServiceDBConnection;
    //SATQuery.DataBase := MainForm.ServiceDBConnection;

    //  ModesQuery.Active := True;
    //  BandsQuery.Active := True;
    // SATQuery.Active := True;
    //  MainForm.VHFTypeQuery.Active := True;

    for i := 0 to 29 do
    begin
      DBGrid1.Columns.Items[i].FieldName := Mainform.columnsGrid[i];
      DBGrid1.Columns.Items[i].Width := Mainform.columnsWidth[i];
      case Mainform.columnsGrid[i] of
        'QSL': DBGrid1.Columns.Items[i].Title.Caption := rQSL;
        'QSLs': DBGrid1.Columns.Items[i].Title.Caption := rQSLs;
        'QSODate': DBGrid1.Columns.Items[i].Title.Caption := rQSODate;
        'QSOTime': DBGrid1.Columns.Items[i].Title.Caption := rQSOTime;
        'QSOBand': DBGrid1.Columns.Items[i].Title.Caption := rQSOBand;
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
    end;
    ComboBox2.Items := MainForm.ComboBox2.Items;
  end;

end;

procedure TEditQSO_Form.FormShow(Sender: TObject);
var
  i: integer;
begin
  try
    if InitLog_DB = 'YES' then
    begin

      if DefaultDB = 'MySQL' then
      begin
        TerrQuery.DataBase := MainForm.MySQLLOGDBConnection;
        UPDATE_Query.DataBase := MainForm.MySQLLOGDBConnection;
      end
      else
      begin
        TerrQuery.DataBase := MainForm.SQLiteDBConnection;
        UPDATE_Query.DataBase := MainForm.SQLiteDBConnection;
      end;
    end;

    if ComboBox2.Text <> '' then
      ComboBox2Change(Self);

    SatPropQuery.SQL.Text := 'SELECT * FROM PropMode';
    SatPropQuery.Open;
    SatPropQuery.First;
    for i := 0 to SatPropQuery.RecordCount - 1 do
    begin
      ComboBox3.Items.Add(SatPropQuery.FieldByName('Type').AsString);
      SatPropQuery.Next;
    end;
    SatPropQuery.Close;

    Button4.Click;
    Edit1.SetFocus;
  except
    on E: ESQLDatabaseError do
    begin
      if Pos('has gone away', E.Message) > 0 then
      begin
        ShowMessage(rMySQLHasGoneAway);
        UseCallBook := 'NO';
        DefaultDB := 'SQLite';
        dbSel := 'SQLite';
        MainForm.InitializeDB('SQLite');
      end;
    end;
  end;

end;

procedure TEditQSO_Form.SpeedButton10Click(Sender: TObject);
begin
  STATE_Form.Show;
end;

end.
