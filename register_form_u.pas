unit register_form_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  LazUTF8, HTTPSend, jsonparser, fpjson, LCLIntf;

type

  { TRegisterForm }

  TRegisterForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public
    OS: string;
  end;

var
  RegisterForm: TRegisterForm;

function SendHTTP(ham_call, first_name, last_name, email, password,
  os, typ: string): string;

implementation

uses
  MainForm_U;

{$R *.lfm}

{ TRegisterForm }

function SendHTTP(ham_call, first_name, last_name, email, password,
  os, typ: string): string;
var
  HTTP: THTTPSend;
  temp: TStringStream;
  Response: TStringList;
  id, token: string;
begin
  HTTP := THTTPSend.Create;
  temp := TStringStream.Create('');
  Response := TStringList.Create;
  HTTP.MimeType := 'application/x-www-form-urlencoded';

  //Получаем id
  temp.WriteString('username=admin&password=admin');
  HTTP.Document.LoadFromStream(temp);
  if HTTP.HTTPMethod('POST', 'http://register.ewlog.ru/login_token.php') then
  begin
    Response.LoadFromStream(HTTP.Document);
    id := Response.Text;
    id := copy(id, 2, length(id) - 2);
    id := Copy(id, 1, Length(id) - 4);
  end;

  //Получение токена
  temp.Size := 0;
  temp.WriteString('token=' + id);
  HTTP.Document.LoadFromStream(temp);
  if HTTP.HTTPMethod('POST', 'http://register.ewlog.ru/api') then
  begin
    Response.LoadFromStream(HTTP.Document);
    token := Response.Text;
    token := copy(token, 2, length(token) - 2);
    token := Copy(token, 1, Length(token) - 2);
  end;

  if typ = 'Register' then
  begin
    temp.Size := 0;
    temp.WriteString(
      'ham_call=' + ham_call + '&first_name=' + first_name +
      '&last_name=' + last_name + '&email=' + email + '&password=' +
      password + '&os=' + os + '&csrf=' + token);
    HTTP.Document.LoadFromStream(temp);
    if HTTP.HTTPMethod('POST', 'http://register.ewlog.ru/api/register_user') then
    begin
      Response.LoadFromStream(HTTP.Document);
      Result := Response.Text;
    end;
  end;

  if typ = 'Read' then
  begin
    if HTTP.HTTPMethod('GET',
      'http://register.ewlog.ru/api/register_user?filter=ham_call,eq,' +
      ham_call + '&transform=1&csrf=' + token) then
    begin
      Response.LoadFromStream(HTTP.Document);
      Result := Response.Text;
    end;
  end;
  temp.Free;
  HTTP.Free;
  Response.Free;
end;

procedure TRegisterForm.Button1Click(Sender: TObject);
var
  jData: TJSONData;
  passjson: string;
  response: string;
begin

  if (Edit1.Text = '') and (Edit6.Text <> '') then
  begin
    response := SendHTTP(Edit6.Text, '', '', '', '', '', 'Read');
    if Pos(Edit6.Text, response) > 0 then
    begin
      jData := GetJSON(Response);
      passjson := jData.FindPath('register_user[0].password').AsString;
      if passjson = Edit7.Text then
      begin
        Label9.Font.Color := clDefault;
        Label9.Caption := 'Успешный вход';
        Image1.Visible := True;
        Button2.Visible := True;
        IniF.WriteString('SetLog', 'Register', 'YES');
        IniF.WriteString('SetLog', 'Login', Edit6.Text);
        IniF.WriteString('SetLog', 'Pass', Edit7.Text);
        Button1.Enabled := False;
        Edit1.Enabled := False;
        Edit2.Enabled := False;
        Edit3.Enabled := False;
        Edit4.Enabled := False;
        Edit5.Enabled := False;
      end
      else
      begin
        Label9.Font.Color := clRed;
        Label9.Caption := 'Не верный пароль';
      end;
    end
    else
      Label9.Caption := 'Не удалось найти';
  end;

  if (Edit1.Text <> '') and (Edit6.Text = '') then
  begin
    response := SendHTTP(Edit1.Text, Edit2.Text, Edit3.Text, Edit4.Text,
      Edit5.Text, OS, 'Register');

    if Pos('null', response) = 0 then
    begin
      Label9.Font.Color := clDefault;
      Label9.Caption := 'Ваша регистрация под номером ' +
        response;
      Image1.Visible := True;
      IniF.WriteString('SetLog', 'Register', 'YES');
      IniF.WriteString('SetLog', 'Login', Edit1.Text);
      IniF.WriteString('SetLog', 'Pass', Edit5.Text);
      Button1.Enabled := False;
      Button2.Visible := True;
      Edit1.Enabled := False;
      Edit2.Enabled := False;
      Edit3.Enabled := False;
      Edit4.Enabled := False;
      Edit5.Enabled := False;
      Edit6.Text := Edit1.Text;
      Edit7.Text := Edit5.Text;
      Edit1.Clear;
      Edit2.Clear;
      Edit3.Clear;
      Edit4.Clear;
      Edit5.Clear;
    end
    else
    begin
      Label9.Font.Color := clRed;
      Label9.Caption := 'Ваша регистрация не прошла';
    end;
  end;

end;

procedure TRegisterForm.Button2Click(Sender: TObject);
begin
  OpenURL('https://yasobe.ru/na/ewlog');
end;

procedure TRegisterForm.FormShow(Sender: TObject);
begin
  {$IFDEF UNIX}
  OS := 'Linux';
  {$ENDIF UNIX}
  {$IFDEF WIN32}
  OS := 'Windows x86';
  {$ENDIF WIN32}
  {$IFDEF WIN64}
  OS := 'Windows x64';
  {$ENDIF WIN32}

  if MainForm.RegisterLog = 'YES' then
  begin
    Image1.Visible := True;
    Button1.Enabled := False;
    Edit1.Enabled := False;
    Edit2.Enabled := False;
    Edit3.Enabled := False;
    Edit4.Enabled := False;
    Edit5.Enabled := False;
    Label9.Caption := 'Успешно зарегистрировано';
    Edit6.Text := MainForm.LoginLog;
    Edit7.Text := MainForm.PassLog;
    Button2.Visible := True;
  end;
end;

end.
