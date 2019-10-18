unit hiddentsettings_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  httpsend, fpjson, laz_synapse;

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
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  hiddenSettings: ThiddenSettings;
  address_serv, API_key: string;
  apicat, apisend: boolean;

function SendRadio(freq, mode, dt, key, radio, address: string): string;
function SendQSO(key, adi, address: string): string;

implementation

uses
  MainForm_U;

{$R *.lfm}

function SendQSO(key, adi, address: string): string;
var
  HTTP: THTTPSend;
  temp: TStringStream;
  Response: TStringList;
begin
  HTTP := THTTPSend.Create;
  temp := TStringStream.Create('');
  Response := TStringList.Create;
  HTTP.MimeType := 'application/json';
  temp.Size := 0;
  temp.WriteString('{"key":"' + key + '", "type":"adif", "string":"'+adi+'"}');
  HTTP.Document.LoadFromStream(temp);
  if HTTP.HTTPMethod('POST', address) then
  begin
    Response.LoadFromStream(HTTP.Document);
    Result := Response.Text;
  end;
  temp.Free;
  HTTP.Free;
  Response.Free;
end;

function SendRadio(freq, mode, dt, key, radio, address: string): string;
var
  HTTP: THTTPSend;
  temp: TStringStream;
  Response: TStringList;
begin
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
  temp.Free;
  HTTP.Free;
  Response.Free;
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
    Memo1.Lines.Add(SendRadio(StringReplace(MainForm.ComboBox1.Text, '.', '', [rfReplaceAll]) +
      '0', MainForm.ComboBox2.Text, DateTimeToStr(Now), API_key, 'EWLog', address_serv));
  MainForm.freqchange := False;
end;

end.
