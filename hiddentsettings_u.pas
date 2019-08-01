unit hiddentsettings_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, httpsend, ssl_openssl, fpjson;

type

  { ThiddenSettings }

  ThiddenSettings = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    CatTimer: TTimer;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CatTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  hiddenSettings: ThiddenSettings;
  address_serv, API_key: String;
  apicat,apisend: Boolean;
  function SendHTTP(freq, mode, dt, key, radio, address: string): string;

implementation
uses
  MainForm_U;

{$R *.lfm}

function SendHTTP(freq, mode, dt, key, radio, address: string): string;
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
   temp.WriteString('{"key":"'+key+'", "radio":"'+radio+'","frequency":'+freq+',"mode":"'+mode+'","timestamp":"'+dt+'"}');
   HTTP.Document.LoadFromStream(temp);
    if HTTP.HTTPMethod('POST', 'https://logbook.ew8bak.ru/index.php/api/radio/') then
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
  address_serv:=IniF.ReadString('Hidden', 'address', '');
  API_key:=IniF.ReadString('Hidden','apikey', '');
  apicat:=IniF.ReadBool('Hidden','apicat',False);
  apisend:=IniF.ReadBool('Hidden','apisend',False);
  if apicat = True then CatTimer.Enabled:=True else CatTimer.Enabled:=False;
end;

procedure ThiddenSettings.FormShow(Sender: TObject);
begin
  address_serv:=IniF.ReadString('Hidden', 'address', '');
  API_key:=IniF.ReadString('Hidden','apikey', '');
  apicat:=IniF.ReadBool('Hidden','apicat',False);
  apisend:=IniF.ReadBool('Hidden','apisend',False);
  LabeledEdit1.Text:=address_serv;
  LabeledEdit2.Text:=API_key;
  CheckBox1.Checked:=apicat;
  CheckBox2.Checked:=apisend;
  if apicat = True then CatTimer.Enabled:=True else CatTimer.Enabled:=False;
end;

procedure ThiddenSettings.Button1Click(Sender: TObject);
begin
  IniF.WriteString('Hidden','address',LabeledEdit1.Text);
  IniF.WriteString('Hidden','apikey',LabeledEdit2.Text);
  IniF.WriteBool('Hidden','apicat',CheckBox1.Checked);
  IniF.WriteBool('Hidden','apisend',CheckBox2.Checked);
  hiddenSettings.Close;
end;

procedure ThiddenSettings.Button2Click(Sender: TObject);
begin
  Memo1.Lines.Add(SendHTTP('14045','SSB','2019/12/12 15:55','cl5d397f96ae561','EWLog',address_serv));
end;

procedure ThiddenSettings.CatTimerTimer(Sender: TObject);
var
  old,new : string;
begin
 // old:=MainForm.ComboBox1.Text;
  //if old <> new then

 // new:=old;
end;

end.

