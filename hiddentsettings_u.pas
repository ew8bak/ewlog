unit hiddentsettings_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  httpsend, ssl_openssl, const_u;

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
    address_serv, API_key: string;
    apicat, apisend: boolean;

  end;

var
  hiddenSettings: ThiddenSettings;


function SendRadio(freq, mode, dt, key, radio, address: string): string;

implementation

uses
  MainForm_U, dmFunc_U, InitDB_dm;

{$R *.lfm}

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
  address_serv := INIFile.ReadString('Hidden', 'address', '');
  API_key := INIFile.ReadString('Hidden', 'apikey', '');
  apicat := INIFile.ReadBool('Hidden', 'apicat', False);
  apisend := INIFile.ReadBool('Hidden', 'apisend', False);
  if apicat = True then
    CatTimer.Enabled := True
  else
    CatTimer.Enabled := False;
end;

procedure ThiddenSettings.FormShow(Sender: TObject);
begin
  address_serv := INIFile.ReadString('Hidden', 'address', '');
  API_key := INIFile.ReadString('Hidden', 'apikey', '');
  apicat := INIFile.ReadBool('Hidden', 'apicat', False);
  apisend := INIFile.ReadBool('Hidden', 'apisend', False);
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
  INIFile.WriteString('Hidden', 'address', LabeledEdit1.Text);
  INIFile.WriteString('Hidden', 'apikey', LabeledEdit2.Text);
  INIFile.WriteBool('Hidden', 'apicat', CheckBox1.Checked);
  INIFile.WriteBool('Hidden', 'apisend', CheckBox2.Checked);
  hiddenSettings.Close;
end;

procedure ThiddenSettings.CatTimerTimer(Sender: TObject);
var
  tempfreq: string;
begin
  if MainForm.freqchange = True then
  begin

    if Pos('M', MainForm.ComboBox1.Text) > 0 then
      tempfreq := FormatFloat(view_freq, dmFunc.GetFreqFromBand(
        MainForm.ComboBox1.Text, MainForm.ComboBox2.Text))
    else
    begin
      tempfreq := MainForm.ComboBox1.Text;
      Delete(tempfreq, length(tempfreq) - 2, 1);
    end;
      Memo1.Lines.Add(SendRadio(StringReplace(tempfreq,
        '.', '', [rfReplaceAll]) + '0', MainForm.ComboBox2.Text,
        DateTimeToStr(Now), API_key, 'EWLog', address_serv + '/index.php/api/radio/'));
  end;
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
