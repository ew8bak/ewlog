unit InformationForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, ExtCtrls, httpsend, LCLIntf, IntfGraphics;
resourcestring
  rErrorXMLAPI = 'Error XML API:';
  rNotConfigQRZRU = 'Specify the Login and Password for accessing the XML API QRZ.ru in the settings';
  rInformationFromQRZRU = 'Information from QRZ.ru';
  rInformationFromQRZCOM = 'Information from QRZ.com';
  rInformationFromHamQTH = 'Information from HAMQTH';

type

  { TInformationForm }

  TInformationForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    DirectoryEdit1: TDirectoryEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
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
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function QRZRU(CallS: string): string;
    procedure QRZRUsprav(CallS: string; imgShow:Boolean);
    function HAMQTH(CallS: string): string;
    function QRZCOM(CallS: string): string;
    procedure Timer1StartTimer(Sender: TObject);
  private
    calsign: string;
    ErrorCall: string;
    loginQRZru: string;
    passQRZru: string;
    sessionNumQRZRU: string;
    { private declarations }
  public
    { public declarations }
  end;

var
  InformationForm: TInformationForm;

implementation

uses MainForm_U, editqso_u, dmFunc_U;

{$R *.lfm}

{ TInformationForm }

procedure TInformationForm.Timer1StartTimer(Sender: TObject);
var
  resp, errorCode, error: string;
  beginSTR, endSTR: integer;
begin
  try
  loginQRZru := IniF.ReadString('SetLog', 'QRZ_Login', '');
  passQRZru := IniF.ReadString('SetLog', 'QRZ_Pass', '');
  errorCode := '';
  error := '';
  if (loginQRZru <> '') and (passQRZru <> '') then
  begin
    with THTTPSend.Create do
    begin
      if HTTPMethod('GET', 'http://api.qrz.ru/login?u=' + loginQRZru +
        '&p=' + passQRZru + '') then
      begin
        SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
      end;
      Free;
    end;

    beginSTR := resp.IndexOf('<session_id>');
    endSTR := resp.IndexOf('</session_id>');
    if (beginSTR <> endSTR) then
      sessionNumQRZRU := resp.Substring(beginSTR + 12, endSTR - beginSTR - 12);
    beginSTR := resp.IndexOf('<errorcode>');
    endSTR := resp.IndexOf('</errorcode>');
    if (beginSTR <> endSTR) then
      errorCode := resp.Substring(beginSTR + 11, endSTR - beginSTR - 11);
    if errorCode <> '' then
      MainForm.StatusBar1.Panels.Items[0].Text := rErrorXMLAPI + errorCode;

   beginSTR := resp.IndexOf('<error>');
    endSTR := resp.IndexOf('</error>');
    if (beginSTR <> endSTR) then
      error := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);
    if error <> '' then begin
      MainForm.StatusBar1.Panels.Items[0].Text := 'XML:' + error;
      Timer1.OnTimer(Self);
    end;

  end;
  finally
  end;
end;

function TInformationForm.QRZRU(CallS: string): string;
var
  resp: string;
  beginSTR, endSTR: integer;
  PhotoString: string;
  Photo: TJPEGImage;
  Flags: TReplaceFlags;
begin
  try
    Photo := TJPEGImage.Create;
    PhotoString := '';
    Photo.Clear;

    with THTTPSend.Create do
    begin
      if HTTPMethod('GET', 'http://api.qrz.ru/callsign?id=' +
        sessionNumQRZRU + '&callsign=' + CallS) then
      begin
        SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
      end;
      Free;
    end;

    //Обработка ошибки
    beginSTR := resp.IndexOf('<error>');
    endSTR := resp.IndexOf('</error>');
    if (beginSTR <> endSTR) then
    ErrorCall := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //Позывной
    beginSTR := resp.IndexOf('<call>');
    endSTR := resp.IndexOf('</call>');
    if (beginSTR <> endSTR) then begin
      Label14.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);
      Result:=resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);
      GroupBox1.Caption:=resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);;
    end;

    //Имя
    beginSTR := resp.IndexOf('<name>');
    endSTR := resp.IndexOf('</name>');
    if (beginSTR <> endSTR) then
      Label16.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);

     //Фамилия
    beginSTR := resp.IndexOf('<surname>');
    endSTR := resp.IndexOf('</surname>');
    if (beginSTR <> endSTR) then
      Label16.Caption := Label16.Caption + ' ' + resp.Substring(beginSTR + 9, endSTR - beginSTR - 9);

    //Город
    beginSTR := resp.IndexOf('<city>');
    endSTR := resp.IndexOf('</city>');
    if (beginSTR <> endSTR) then
      Label17.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);

    //Локатор
    beginSTR := resp.IndexOf('<qthloc>');
    endSTR := resp.IndexOf('</qthloc>');
    if (beginSTR <> endSTR) then
      Label19.Caption := resp.Substring(beginSTR + 8, endSTR - beginSTR - 8);

    //State
    beginSTR := resp.IndexOf('<state>');
    endSTR := resp.IndexOf('</state>');
    if (beginSTR <> endSTR) then
      Label21.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //Страна
    beginSTR := resp.IndexOf('<country>');
    endSTR := resp.IndexOf('</country>');
    if (beginSTR <> endSTR) then
      Label15.Caption := resp.Substring(beginSTR + 9, endSTR - beginSTR - 9);

    //Дом страница
    beginSTR := resp.IndexOf('<url>');
    endSTR := resp.IndexOf('</url>');
    if (beginSTR <> endSTR) then
      Label20.Caption := resp.Substring(beginSTR + 5, endSTR - beginSTR - 5);


    //Телефон
    beginSTR := resp.IndexOf('<telephone>');
    endSTR := resp.IndexOf('</telephone>');
    if (beginSTR <> endSTR) then
      Label22.Caption := resp.Substring(beginSTR + 11, endSTR - beginSTR - 11);

    //email
    beginSTR := resp.IndexOf('<email>');
    endSTR := resp.IndexOf('</email>');
    if (beginSTR <> endSTR) then
      Label23.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //улица
    beginSTR := resp.IndexOf('<street>');
    endSTR := resp.IndexOf('</street>');
    if (beginSTR <> endSTR) then
      Label18.Caption := resp.Substring(beginSTR + 8, endSTR - beginSTR - 8);

    //icq
    beginSTR := resp.IndexOf('<icq>');
    endSTR := resp.IndexOf('</icq>');
    if (beginSTR <> endSTR) then
      Label24.Caption := resp.Substring(beginSTR + 5, endSTR - beginSTR - 5);

    //QSL VIA
    beginSTR := resp.IndexOf('<qslvia>');
    endSTR := resp.IndexOf('</qslvia>');
    if (beginSTR <> endSTR) then
      Label26.Caption := resp.Substring(beginSTR + 8, endSTR - beginSTR - 8);

    //Photo
    beginSTR := resp.IndexOf('<file>');
    endSTR := resp.IndexOf('</file>');
    if (beginSTR <> endSTR) then
      PhotoString := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);

    if PhotoString <> '' then
    begin
      InformationForm.Height := 658;
      with THTTPSend.Create do
      begin
        if HTTPMethod('GET', StringReplace(PhotoString, 'https', 'http', Flags)) then
        begin
          Photo.LoadFromStream(Document);
          if DirectoryEdit1.Text <> '' then
  {$IFDEF UNIX}
            Photo.SaveToFile(DirectoryEdit1.Text + '/' + CallS + '.jpg');
  {$ENDIF UNIX}
  {$IFDEF WINDOWS}
          Photo.SaveToFile(DirectoryEdit1.Text + '\' + CallS + '.jpg');
  {$ENDIF WINDOWS}
        end;
        Free;
      end;
      Image1.Picture.Assign(Photo);
    end
    else
      InformationForm.Height := 364;
  finally
    Photo.Free;
  end;
end;

procedure TInformationForm.QRZRUsprav(CallS: string; imgShow:Boolean);
var
  resp, comment: string;
  beginSTR, endSTR: integer;
  PhotoString: string;
  Flags: TReplaceFlags;
begin
  try
  MainForm.Edit11.Text := '';
  MainForm.Edit1.Text := '';
  MainForm.Edit2.Text := '';
  MainForm.Edit3.Text := '';
  MainForm.Edit4.Text := '';
  comment := '';
  PhotoString := '';

  if Length(CallS) >= 3 then
  begin

    with THTTPSend.Create do
    begin
      if HTTPMethod('GET', 'http://api.qrz.ru/callsign?id=' +
        sessionNumQRZRU + '&callsign=' + CallS) then
      begin
        SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
      end;
      Free;
    end;

    //Имя
    beginSTR := resp.IndexOf('<name>');
    endSTR := resp.IndexOf('</name>');
    if (beginSTR <> endSTR) then
      MainForm.Edit1.Text := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);

    //QTH
    beginSTR := resp.IndexOf('<city>');
    endSTR := resp.IndexOf('</city>');
    if (beginSTR <> endSTR) then
      MainForm.Edit2.Text := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);

    //Grid
    beginSTR := resp.IndexOf('<qthloc>');
    endSTR := resp.IndexOf('</qthloc>');
    if (beginSTR <> endSTR) then
      MainForm.Edit3.Text := resp.Substring(beginSTR + 8, endSTR - beginSTR - 8);

    //State
    beginSTR := resp.IndexOf('<state>');
    endSTR := resp.IndexOf('</state>');
    if (beginSTR <> endSTR) then
      MainForm.Edit4.Text := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //Comment
    beginSTR := resp.IndexOf('<birthday>');
    endSTR := resp.IndexOf('</birthday>');
    if (beginSTR <> endSTR) then
    begin
      comment := comment + resp.Substring(beginSTR + 10, endSTR - beginSTR - 10);
      if comment <> '' then
        comment := comment + ', ';
    end;
    //Comment
    beginSTR := resp.IndexOf('<email>');
    endSTR := resp.IndexOf('</email>');
    if (beginSTR <> endSTR) then
    begin
      comment := comment + resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);
      if comment <> '' then
        comment := comment + ', ';
    end;
    //Comment
    beginSTR := resp.IndexOf('<street>');
    endSTR := resp.IndexOf('</street>');
    if (beginSTR <> endSTR) then
      comment := comment + resp.Substring(beginSTR + 8, endSTR - beginSTR - 8);
    MainForm.Edit11.Text := comment;

    //Photo
    beginSTR := resp.IndexOf('<file>');
    endSTR := resp.IndexOf('</file>');
    if (beginSTR <> endSTR) then
    PhotoString := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);

    if (PhotoString <> '') and (imgShow = True) then
    begin
      with THTTPSend.Create do
      begin
        if HTTPMethod('GET', StringReplace(PhotoString, 'https', 'http', Flags)) then
        begin
       //   ShowMessage(dmFunc.Extention(PhotoString));
        if dmFunc.Extention(PhotoString) = '.gif' then MainForm.PhotoGIF.LoadFromStream(Document);
        if dmFunc.Extention(PhotoString) = '.jpg' then MainForm.PhotoJPEG.LoadFromStream(Document);
        if dmFunc.Extention(PhotoString) = '.png' then MainForm.PhotoPNG.LoadFromStream(Document);
        end;
        Free;
      end;
     if dmFunc.Extention(PhotoString) = '.gif' then MainForm.tIMG.Picture.Assign(MainForm.PhotoGIF);
     if dmFunc.Extention(PhotoString) = '.jpg' then MainForm.tIMG.Picture.Assign(MainForm.PhotoJPEG);
     if dmFunc.Extention(PhotoString) = '.png' then MainForm.tIMG.Picture.Assign(MainForm.PhotoPNG);
      MainForm.tIMG.Show;
    end else
    if imgShow = True then
    MainForm.tIMG.Picture:=nil;
  end;
  finally
  end;
end;

function TInformationForm.HAMQTH(CallS: string): string;
var
  resp, errorCode, sessionNum, PhotoString: string;
  beginSTR, endSTR: integer;
  Flags: TReplaceFlags;
  Photo: TJPEGImage;
begin
  try
    Photo := TJPEGImage.Create;
    PhotoString := '';
    Photo.Clear;

    with THTTPSend.Create do
    begin
      if HTTPMethod('GET', 'http://www.hamqth.com/xml.php?u=ew8bak&p=Ml197895551ml') then
      begin
        SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
      end;
      Free;
    end;

    beginSTR := resp.IndexOf('<session_id>');
    endSTR := resp.IndexOf('</session_id>');
    if (beginSTR <> endSTR) then
      sessionNum := resp.Substring(beginSTR + 12, endSTR - beginSTR - 12);
    beginSTR := resp.IndexOf('<errorcode>');
    endSTR := resp.IndexOf('</errorcode>');
    if (beginSTR <> endSTR) then
      errorCode := resp.Substring(beginSTR + 11, endSTR - beginSTR - 11);

     with THTTPSend.Create do
    begin
      if HTTPMethod('GET', 'http://www.hamqth.com/xml.php?id=' +
        SessionNum + '&callsign=' + CallS + '&prg=EWLog') then
      begin
        SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
      end;
      Free;
    end;

       //Обработка ошибки
    beginSTR := resp.IndexOf('<error>');
    endSTR := resp.IndexOf('</error>');
    if (beginSTR <> endSTR) then
    ErrorCall := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //Позывной
    beginSTR := resp.IndexOf('<callsign>');
    endSTR := resp.IndexOf('</callsign>');
    if (beginSTR <> endSTR) then begin
      Label14.Caption := resp.Substring(beginSTR + 10, endSTR - beginSTR - 10);
      Result:=resp.Substring(beginSTR + 10, endSTR - beginSTR - 10);
      GroupBox1.Caption:=resp.Substring(beginSTR + 10, endSTR - beginSTR - 10);;
    end;

    //Имя
    beginSTR := resp.IndexOf('<nick>');
    endSTR := resp.IndexOf('</nick>');
    if (beginSTR <> endSTR) then
      Label16.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);

    //Город
    beginSTR := resp.IndexOf('<street>');
    endSTR := resp.IndexOf('</street>');
    if (beginSTR <> endSTR) then
      Label17.Caption := resp.Substring(beginSTR + 8, endSTR - beginSTR - 8);

    //Локатор
    beginSTR := resp.IndexOf('<grid>');
    endSTR := resp.IndexOf('</grid>');
    if (beginSTR <> endSTR) then
      Label19.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);

    //State
    beginSTR := resp.IndexOf('<state>');
    endSTR := resp.IndexOf('</state>');
    if (beginSTR <> endSTR) then
      Label21.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //Страна
    beginSTR := resp.IndexOf('<country>');
    endSTR := resp.IndexOf('</country>');
    if (beginSTR <> endSTR) then
      Label15.Caption := resp.Substring(beginSTR + 9, endSTR - beginSTR - 9);

    //Дом страница
    beginSTR := resp.IndexOf('<web>');
    endSTR := resp.IndexOf('</web>');
    if (beginSTR <> endSTR) then
      Label20.Caption := resp.Substring(beginSTR + 5, endSTR - beginSTR - 5);


    //Телефон
    beginSTR := resp.IndexOf('<telephone>');
    endSTR := resp.IndexOf('</telephone>');
    if (beginSTR <> endSTR) then
      Label22.Caption := resp.Substring(beginSTR + 11, endSTR - beginSTR - 11);

    //email
    beginSTR := resp.IndexOf('<email>');
    endSTR := resp.IndexOf('</email>');
    if (beginSTR <> endSTR) then
      Label23.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //улица
    beginSTR := resp.IndexOf('<adr_city>');
    endSTR := resp.IndexOf('</adr_city>');
    if (beginSTR <> endSTR) then
      Label18.Caption := resp.Substring(beginSTR + 10, endSTR - beginSTR - 10);

    //icq
    beginSTR := resp.IndexOf('<icq>');
    endSTR := resp.IndexOf('</icq>');
    if (beginSTR <> endSTR) then
      Label24.Caption := resp.Substring(beginSTR + 5, endSTR - beginSTR - 5);

    //Photo
    beginSTR := resp.IndexOf('<picture>');
    endSTR := resp.IndexOf('</picture>');
    if (beginSTR <> endSTR) then
      PhotoString := resp.Substring(beginSTR + 9, endSTR - beginSTR - 9);

    if PhotoString <> '' then
    begin
      InformationForm.Height := 658;
      with THTTPSend.Create do
      begin
        if HTTPMethod('GET', StringReplace(PhotoString, 'https', 'http', Flags)) then
        begin
          Photo.LoadFromStream(Document);
          if DirectoryEdit1.Text <> '' then
  {$IFDEF UNIX}
            Photo.SaveToFile(DirectoryEdit1.Text + '/' + CallS + '.jpg');
  {$ENDIF UNIX}
  {$IFDEF WINDOWS}
          Photo.SaveToFile(DirectoryEdit1.Text + '\' + CallS + '.jpg');
  {$ENDIF WINDOWS}
        end;
        Free;
      end;
      Image1.Picture.Assign(Photo);
    end
    else
      InformationForm.Height := 364;
   finally
     Photo.Free;
  end;
end;

function TInformationForm.QRZCOM(CallS: string): string;
var
  resp, errorCode, sessionNum, PhotoString: string;
  beginSTR, endSTR: integer;
  Flags: TReplaceFlags;
  Photo: TJPEGImage;
begin
  try
      Photo := TJPEGImage.Create;
      PhotoString := '';
      Photo.Clear;

      with THTTPSend.Create do
      begin
        if HTTPMethod('GET', 'http://xmldata.qrz.com/xml/?username=ew8bak;password=Ml197895551ml;agent=EWLog') then
        begin
          SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
        end;
        Free;
      end;

      beginSTR := resp.IndexOf('<Key>');
      endSTR := resp.IndexOf('</Key>');
      if (beginSTR <> endSTR) then
        sessionNum := resp.Substring(beginSTR + 5, endSTR - beginSTR - 5);
      beginSTR := resp.IndexOf('<errorcode>');
      endSTR := resp.IndexOf('</errorcode>');
      if (beginSTR <> endSTR) then
        errorCode := resp.Substring(beginSTR + 11, endSTR - beginSTR - 11);

       with THTTPSend.Create do
      begin
        if HTTPMethod('GET', 'http://xmldata.qrz.com/xml/current/?s=' +
        SessionNum + ';callsign=' + CallS) then
        begin
          SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
        end;
        Free;
      end;

         //Обработка ошибки
      beginSTR := resp.IndexOf('<Error>');
      endSTR := resp.IndexOf('</Error>');
      if (beginSTR <> endSTR) then
      ErrorCall := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

      //Позывной
      beginSTR := resp.IndexOf('<call>');
      endSTR := resp.IndexOf('</call>');
      if (beginSTR <> endSTR) then begin
        Label14.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);
        Result:=resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);
        GroupBox1.Caption:=resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);
      end;

      //Имя
      beginSTR := resp.IndexOf('<fname>');
      endSTR := resp.IndexOf('</fname>');
      if (beginSTR <> endSTR) then
        Label16.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

      //Город
      beginSTR := resp.IndexOf('<addr1>');
      endSTR := resp.IndexOf('</addr1>');
      if (beginSTR <> endSTR) then
        Label17.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

      //Локатор
      beginSTR := resp.IndexOf('<grid>');
      endSTR := resp.IndexOf('</grid>');
      if (beginSTR <> endSTR) then
        Label19.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);

      //State
      beginSTR := resp.IndexOf('<state>');
      endSTR := resp.IndexOf('</state>');
      if (beginSTR <> endSTR) then
        Label21.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

      //Страна
      beginSTR := resp.IndexOf('<country>');
      endSTR := resp.IndexOf('</country>');
      if (beginSTR <> endSTR) then
        Label15.Caption := resp.Substring(beginSTR + 9, endSTR - beginSTR - 9);

      //Дом страница
      beginSTR := resp.IndexOf('<url>');
      endSTR := resp.IndexOf('</url>');
      if (beginSTR <> endSTR) then
        Label20.Caption := resp.Substring(beginSTR + 5, endSTR - beginSTR - 5);


      //Телефон
      beginSTR := resp.IndexOf('<telephone>');
      endSTR := resp.IndexOf('</telephone>');
      if (beginSTR <> endSTR) then
        Label22.Caption := resp.Substring(beginSTR + 11, endSTR - beginSTR - 11);

      //email
      beginSTR := resp.IndexOf('<email>');
      endSTR := resp.IndexOf('</email>');
      if (beginSTR <> endSTR) then
        Label23.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

      //улица
      beginSTR := resp.IndexOf('<addr2>');
      endSTR := resp.IndexOf('</addr2>');
      if (beginSTR <> endSTR) then
        Label18.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

      //icq
      beginSTR := resp.IndexOf('<icq>');
      endSTR := resp.IndexOf('</icq>');
      if (beginSTR <> endSTR) then
        Label24.Caption := resp.Substring(beginSTR + 5, endSTR - beginSTR - 5);

       //QSL VIA
    beginSTR := resp.IndexOf('<qslvia>');
    endSTR := resp.IndexOf('</qslvia>');
    if (beginSTR <> endSTR) then
      Label26.Caption := resp.Substring(beginSTR + 8, endSTR - beginSTR - 8);

      //Photo
      beginSTR := resp.IndexOf('<image>');
      endSTR := resp.IndexOf('</image>');
      if (beginSTR <> endSTR) then
        PhotoString := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

      if PhotoString <> '' then
      begin
        InformationForm.Height := 658;
        with THTTPSend.Create do
        begin
          if HTTPMethod('GET', StringReplace(PhotoString, 'https', 'http', Flags)) then
          begin
            Photo.LoadFromStream(Document);
            if DirectoryEdit1.Text <> '' then
    {$IFDEF UNIX}
              Photo.SaveToFile(DirectoryEdit1.Text + '/' + CallS + '.jpg');
    {$ENDIF UNIX}
    {$IFDEF WINDOWS}
            Photo.SaveToFile(DirectoryEdit1.Text + '\' + CallS + '.jpg');
    {$ENDIF WINDOWS}
          end;
          Free;
        end;
        Image1.Picture.Assign(Photo);
      end
      else
        InformationForm.Height := 364;
     finally
       Photo.Free;
    end;
end;

procedure TInformationForm.FormShow(Sender: TObject);
begin
  Label14.Caption := '';
  Label15.Caption := '';
  Label16.Caption := '';
  Label17.Caption := '';
  Label18.Caption := '';
  Label19.Caption := '';
  Label20.Caption := '';
  Label21.Caption := '';
  Label22.Caption := '';
  Label23.Caption := '';
  Label23.Caption := '';
  Label24.Caption := '';
  Label25.Caption := '';
  Label26.Caption := '';
  GroupBox1.Caption := rCallSign;
  ErrorCall := '';
  loginQRZru := IniF.ReadString('SetLog', 'QRZ_Login', '');
  passQRZru := IniF.ReadString('SetLog', 'QRZ_Pass', '');
  DirectoryEdit1.Text := MainForm.PhotoDir;

  if (loginQRZru = '') or (passQRZru = '') then
      ShowMessage(rNotConfigQRZRU);

  if (MainForm.EditButton1.Text <> '') and (EditQSO_Form.Edit1.Text ='') then
  calsign:=MainForm.EditButton1.Text
  else
    calsign:=EditQSO_Form.Edit1.Text;

  InformationForm.Caption := rInformationFromQRZRU;
  QRZRU(calsign);

  if ErrorCall <> '' then
  begin
    ErrorCall := '';
    QRZCOM(calsign);
    InformationForm.Caption := rInformationFromQRZCOM;
  end;
   if ErrorCall <> '' then
  begin
     HAMQTH(calsign);
    InformationForm.Caption := rInformationFromHamQTH;
  end;
end;

procedure TInformationForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IniF.WriteString('SetLog', 'PhotoDir', DirectoryEdit1.Text);
  MainForm.PhotoDir := DirectoryEdit1.Text;
  Label14.Caption := '';
  Label15.Caption := '';
  Label16.Caption := '';
  Label17.Caption := '';
  Label18.Caption := '';
  Label19.Caption := '';
  Label20.Caption := '';
  Label21.Caption := '';
  Label22.Caption := '';
  Label23.Caption := '';
  Label23.Caption := '';
  Label24.Caption := '';
  Label25.Caption := '';
  Label26.Caption := '';
  GroupBox1.Caption := rCallSign;

end;

procedure TInformationForm.FormCreate(Sender: TObject);
begin
    InformationForm.Timer1.Interval:=3200000;
    InformationForm.Timer1.Enabled:=True;
end;

procedure TInformationForm.Button1Click(Sender: TObject);
begin
  if CheckForm = 'Main' then
  begin
    MainForm.EditButton1.Text := Label14.Caption;
    MainForm.Edit1.Text := Label16.Caption;
    MainForm.Edit2.Text := Label18.Caption;
    MainForm.Edit3.Text := Label19.Caption;
    MainForm.Edit4.Text := Label21.Caption;
  end;
  if CheckForm = 'Edit' then
  begin
    EditQSO_Form.Edit4.Text := Label16.Caption;
    EditQSO_Form.Edit5.Text := Label18.Caption;
    if Label19.Caption <> '' then
      EditQSO_Form.Edit14.Text := Label19.Caption;
    if Label21.Caption <> '' then
      EditQSO_Form.Edit17.Text := Label21.Caption;
  end;
end;

procedure TInformationForm.Button2Click(Sender: TObject);
begin
  OpenURL('http://qrzcq.com/call/' + calsign);
end;

procedure TInformationForm.Button3Click(Sender: TObject);
begin
  OpenURL('https://www.qrz.ru/db/' + calsign);
end;

procedure TInformationForm.Button5Click(Sender: TObject);
begin
  OpenURL('https://www.pskreporter.info/pskmap.html?callsign=' +
    calsign + '&search=Find');
end;

procedure TInformationForm.Button6Click(Sender: TObject);
begin
  OpenURL('https://secure.clublog.org/logsearch/' + calsign);
end;

end.
