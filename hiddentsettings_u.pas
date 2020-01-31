unit hiddentsettings_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  httpsend;

type

  { ThiddenSettings }

  ThiddenSettings = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    CatTimer: TTimer;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure CatTimerTimer(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
    procedure SendQSO(key, address, call, date, time, freq, mode,
      submode, rsts, rstr, omname, qth, state, grid, comment: string);
  public
    address_serv, API_key: string;
    apicat, apisend: boolean;

  end;

var
  hiddenSettings: ThiddenSettings;


function SendRadio(freq, mode, dt, key, radio, address: string): string;

implementation

uses
  MainForm_U, dmFunc_U;

{$R *.lfm}

procedure ThiddenSettings.SendQSO(key, address, call, date, time,
  freq, mode, submode, rsts, rstr, omname, qth, state, grid, comment: string);
var
  HTTP: THTTPSend;
  temp: TStringStream;
  Response: TStringList;
  logdata, json: string;

  procedure AddData(const datatype, Data: string);
  begin
    if Data <> '' then
      logdata := logdata + Format('<%s:%d>%s', [datatype, Length(Data), Data]);
  end;

begin
  try
    HTTP := THTTPSend.Create;
    HTTP.MimeType := 'application/json';
    temp := TStringStream.Create('');
    Response := TStringList.Create;
    logdata := '';
    AddData('CALL', call);
    AddData('QSO_DATE', date);
    AddData('TIME_ON', time);
    AddData('BAND', dmFunc.GetBandFromFreq(freq));
    AddData('MODE', mode);
    AddData('SUBMODE', submode);
    AddData('RST_SENT', rsts);
    AddData('RST_RCVD', rstr);
    AddData('COMMENT', comment);
    AddData('QTH', qth);
    AddData('NAME', omname);
    AddData('STATE', state);
    AddData('GRIDSQUARE', grid);
    Delete(freq, length(freq) - 2, 1); //Удаляем последнюю точку
    AddData('FREQ', freq);
    logdata := logdata + '<EOR>';
    json := '{"key":"' + key + '", "type":"adif", "string":"' + logdata + '"}';
    temp.Size := 0;
    temp.WriteString(json);
    HTTP.Document.LoadFromStream(temp);
    if HTTP.HTTPMethod('POST', address) then
    begin
      Response.LoadFromStream(HTTP.Document);
      Memo1.Lines.Add(Response.Text);
    end;
  finally
    temp.Free;
    HTTP.Free;
    Response.Free;
  end;
end;

function SendRadio(freq, mode, dt, key, radio, address: string): string;
var
  HTTP: THTTPSend;
  temp: TStringStream;
  Response: TStringList;
begin
  try
    Result := '';
    HTTP := THTTPSend.Create;
    temp := TStringStream.Create('');
    Response := TStringList.Create;
    HTTP.MimeType := 'application/json';
    temp.Size := 0;
    temp.WriteString('{"key":"' + key + '", "radio":"' + radio +
      '","frequency":' + freq + ',"mode":"' + mode + '","timestamp":"' + dt + '"}');
    HTTP.Document.LoadFromStream(temp);
    if HTTP.HTTPMethod('POST', address) then
    begin
      Response.LoadFromStream(HTTP.Document);
      Result := Response.Text;
    end;
  finally
    temp.Free;
    HTTP.Free;
    Response.Free;
  end;
end;

{ ThiddenSettings }

procedure ThiddenSettings.FormCreate(Sender: TObject);
begin
  address_serv := IniF.ReadString('Hidden', 'address', '');
  API_key := IniF.ReadString('Hidden', 'apikey', '');
  apicat := IniF.ReadBool('Hidden', 'apicat', False);
  apisend := IniF.ReadBool('Hidden', 'apisend', False);
  if apicat = True then
    CatTimer.Enabled := True
  else
    CatTimer.Enabled := False;
end;

procedure ThiddenSettings.FormShow(Sender: TObject);
begin
  address_serv := IniF.ReadString('Hidden', 'address', '');
  API_key := IniF.ReadString('Hidden', 'apikey', '');
  apicat := IniF.ReadBool('Hidden', 'apicat', False);
  apisend := IniF.ReadBool('Hidden', 'apisend', False);
  LabeledEdit1.Text := address_serv;
  LabeledEdit2.Text := API_key;
  CheckBox1.Checked := apicat;
  CheckBox2.Checked := apisend;
  if apicat = True then
    CatTimer.Enabled := True
  else
    CatTimer.Enabled := False;
end;

procedure ThiddenSettings.Button1Click(Sender: TObject);
begin
  IniF.WriteString('Hidden', 'address', LabeledEdit1.Text);
  IniF.WriteString('Hidden', 'apikey', LabeledEdit2.Text);
  IniF.WriteBool('Hidden', 'apicat', CheckBox1.Checked);
  IniF.WriteBool('Hidden', 'apisend', CheckBox2.Checked);
  hiddenSettings.Close;
end;

procedure ThiddenSettings.CatTimerTimer(Sender: TObject);
begin
  if MainForm.freqchange = True then
    Memo1.Lines.Add(SendRadio(StringReplace(MainForm.ComboBox1.Text,
      '.', '', [rfReplaceAll]) + '0', MainForm.ComboBox2.Text,
      DateTimeToStr(Now), API_key, 'EWLog', address_serv + '/index.php/api/radio/'));
  MainForm.freqchange := False;
end;

procedure ThiddenSettings.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked = True then
  begin
    apicat := True;
    CatTimer.Enabled := True;
  end
  else
  begin
    apicat := False;
    CatTimer.Enabled := False;
  end;
end;

procedure ThiddenSettings.CheckBox2Change(Sender: TObject);
begin
  if CheckBox2.Checked = True then
    apisend := True
  else
    apisend := False;
end;

end.
