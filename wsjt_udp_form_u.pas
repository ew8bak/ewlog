unit WSJT_UDP_Form_U;

{$mode objfpc}{$H+}

interface

uses

{$DEFINE UseCThreads}
{$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
{$ENDIF}{$ENDIF}
  Classes, SysUtils, IdUDPServer, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, IdComponent, IdSocketHandle, IdGlobal, dateutils;

const
  SJT65: string = '#';
  SJT9: string = '@';
  SFT8: string = '~';


type
  { TWSJT_UDP_Form }

  TWSJT_UDP_Form = class(TForm)
    IdUDPServer1: TIdUDPServer;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure IdUDPServer1Status(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure IdUDPServer1UDPException(AThread: TIdUDPListenerThread;
      ABinding: TIdSocketHandle; const AMessage: string;
      const AExceptionClass: TClass);
    procedure IdUDPServer1UDPRead(AThread: TIdUDPListenerThread;
      AData: TIdBytes; ABinding: TIdSocketHandle);
  private
    { private declarations }
  public
    function decodeMode(mode: string): string;
    function WSJT_IsRunning: boolean;
    { public declarations }
  end;

var
  WSJT_UDP_Form: TWSJT_UDP_Form;
  UFreq, UModeRX, UModeTX, UDXCall, URSTs, UHeureDeb: string;
  UCall, ULoc: string;
  UIndex: integer;
  peerPort: qword;
  SNR: longint;
  WSJT_Run: boolean = False;

implementation

uses dmFunc_U, MainForm_U;

{$R *.lfm}

{ TWSJT_UDP_Form }

function TWSJT_UDP_Form.WSJT_IsRunning: boolean;
begin
  Result := WSJT_Run;
end;

procedure TWSJT_UDP_Form.IdUDPServer1Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin
  Memo1.Lines.Add('Статус UDP сервера: ' + AStatusText);
end;

procedure TWSJT_UDP_Form.FormCreate(Sender: TObject);
begin
  //IdUDPServer1.Active:=True;
  //IdUDPServer1.Active := False;
  //IdUDPServer1.Bindings.Add.IPVersion := Id_IPv4;
  IdUDPServer1.Active := True;

end;

procedure TWSJT_UDP_Form.FormDestroy(Sender: TObject);
begin
  FreeAndNil(IdUDPServer1);
  //IdUDPServer1.Destroy;
end;

procedure TWSJT_UDP_Form.IdUDPServer1UDPException(AThread: TIdUDPListenerThread;
  ABinding: TIdSocketHandle; const AMessage: string; const AExceptionClass: TClass);
begin
  Memo1.Lines.Add('Ошибка UDP сервера: ' + AMessage);
end;

function TWSJT_UDP_Form.decodeMode(mode: string): string;
begin
  if mode = SJT65 then
    Result := 'JT65';
  if mode = SJT9 then
    Result := 'JT9';
  if mode = SFT8 then
    Result := 'FT8';
end;

procedure TWSJT_UDP_Form.IdUDPServer1UDPRead(AThread: TIdUDPListenerThread;
  AData: TIdBytes; ABinding: TIdSocketHandle);
var
  index: integer = 0;
  magic, schema, messageType: longint;
  id, mode, DXCall, report, TXMode, message, DXGrid, DEGrid, DECall,
  reportReceived: string;
  TXPower, comments, DXName, adif_text: string;
  frequency: QWord;
  isNew, TXEnabled, transmitting, Decoding: boolean;
  tm: longword;
  ztime: TDateTime;
  DT: double;
  DF: cardinal;
  date: TDateTime;
  z: TStringList;
  Memomessage, locator: string;
  rst, RXDF, TXDF: integer;
begin
  peerPort := ABinding.PeerPort;

  Memo1.Lines.Add('Datagram received - length: ' + IntToStr(Length(AData)));
  while index < Length(AData) do
  begin
    dmFunc.Unpack(AData, index, magic);
     Memo1.Lines.Add('index:' + IntToStr(index) + ' magic:$' + IntToHex(magic,8));
    if (magic = longint($ADBCCBDA)) and (index < Length(AData)) then
    begin
      dmFunc.Unpack(AData, index, schema);
      if (schema = 2) and (index < Length(AData)) then
      begin
        dmFunc.Unpack(AData, index, messageType);
        dmFunc.Unpack(AData, index, id);
        Memo1.Lines.Add('Message type:' + IntToStr(messageType) + ' from:[' + id + ']');
        case messageType of
          0:
          begin
            Memo1.Lines.Add('ЖИВУ!');
            WSJT_Run := True;
          end;
          1:
          begin
            dmFunc.Unpack(AData, index, frequency);
            dmFunc.Unpack(AData, index, mode);
            dmFunc.Unpack(AData, index, DXCall);
            dmFunc.Unpack(AData, index, report);
            dmFunc.Unpack(AData, index, TXMode);
            dmFunc.Unpack(AData, index, TXEnabled);
            dmFunc.Unpack(AData, index, transmitting);
            dmFunc.Unpack(AData, index, Decoding);
            dmFunc.Unpack(AData, index, RXDF);
            dmFunc.Unpack(AData, index, TXDF);
            dmFunc.Unpack(AData, index, DECall);
            dmFunc.Unpack(AData, index, DEGrid);
            dmFunc.Unpack(AData, index, DXGrid);

            MainForm.EditButton1.Text := DXCall;
            MainForm.Edit3.Text := DXGrid;

            if (IniF.ReadString('SetLog', 'ShowBand', '') = 'True') and
              (dmFunc.GetBandFromFreq(FormatFloat('0.000"."00', frequency / 1000000)) <> '') then
              MainForm.ComboBox1.Text := dmFunc.GetBandFromFreq(
                FormatFloat('0.000"."00', frequency / 1000000))
            else
              MainForm.ComboBox1.Text := FormatFloat('0.000"."00', frequency / 1000000);

            if mode <> 'FT4' then begin
            MainForm.ComboBox2.Text := mode;
            MainForm.ComboBox9.Text := '';
            end
            else begin
            MainForm.ComboBox2.Text := 'MFSK';
            MainForm.ComboBox9.Text := 'FT4';
            end;
            MainForm.ComboBox4.Text := report;
          end;

          2:
          begin
            dmFunc.Unpack(AData, index, isNew);
            dmFunc.Unpack(AData, index, tm);
            ztime := IncMilliSecond(0, tm);
            dmFunc.Unpack(AData, index, SNR);
            dmFunc.Unpack(AData, index, DT);
            dmFunc.Unpack(AData, index, DF);
            dmFunc.Unpack(AData, index, mode);
            dmFunc.Unpack(AData, index, message);

            Memomessage := 'Декодировано:' + ' ' +
              BoolToStr(isNew) + ' ' + FormatDateTime('hhmm', ztime) +
              ' ' + IntToStr(SNR) + ' ' + FloatToStrF(DT, ffGeneral, 4, 1) +
              ' ' + IntToStr(DF) + ' ' + mode + ' ' + message + ' ' +
              timeToStr(ztime) + ' ' + FloatToStr(DT) + ' ' + IntToStr(tm);
            Memo1.Lines.Add(Memomessage);

            rst := SNR;
            mode := decodeMode(mode);
            try
              z := TStringList.Create;
              z.Delimiter := ' ';
              z.DelimitedText := message;
              if z.Count > 1 then
              begin
                z.Add(message);
                if z[1] = 'DX' then
                begin
                  DXCall := z[2];
                  locator := z[3];
                end
                else
                begin
                  DXCall := z[1];
                  locator := z[2];
                end;

                UCall := z[0];
              end;
            except
              on E: Exception do
                WriteLn(Format('Ошибка : %s', [e.Message]));
            end;
            z.Free;
          end;

          3:
          begin
            Memo1.Lines.Add('Очистил');
          end;

          5:
          begin
            dmFunc.Unpack(AData, index, date);
            dmFunc.Unpack(AData, index, DXCall);
            dmFunc.Unpack(AData, index, DXGrid);
            dmFunc.Unpack(AData, index, frequency);
            dmFunc.Unpack(AData, index, mode);
            dmFunc.Unpack(AData, index, report);
            dmFunc.Unpack(AData, index, reportReceived);
            dmFunc.Unpack(AData, index, TXPower);
            dmFunc.Unpack(AData, index, comments);
            dmFunc.Unpack(AData, index, DXName);

            Memo1.Lines.Add('QSO сохранено: Дата:' +
              FormatDateTime('dd.mm.yyyy hh:mm:ss', date) +
              ' DX Call:' + DXCall + ' DX Grid:' + DXGrid +
              ' Частота:' + IntToStr(frequency) + ' Мода:' +
              mode + ' RST отправлено: ' + report +
              ' RST получено:' + reportReceived + ' TX мощность:' +
              TXPower + ' Комментарий:' + comments + ' Имя:' + DXName);

            MainForm.CheckBox1.Checked := False;
            MainForm.DateEdit1.Date := date;
            MainForm.DateTimePicker1.Time := date;
            MainForm.EditButton1.Text := DXCall;

             if (IniF.ReadString('SetLog', 'ShowBand', '') = 'True') and
              (dmFunc.GetBandFromFreq(FormatFloat('0.000"."00', frequency / 1000000)) <> '') then
              MainForm.ComboBox1.Text := dmFunc.GetBandFromFreq(
                FormatFloat('0.000"."00', frequency / 1000000))
            else
              MainForm.ComboBox1.Text := FormatFloat('0.000"."00', frequency / 1000000);

            MainForm.Edit3.Text := DXGrid;
            MainForm.ComboBox2.Text := mode;
            MainForm.ComboBox4.Text := report;
            MainForm.ComboBox5.Text := reportReceived;
            if DXName <> '' then
            MainForm.Edit1.Text := DXName;
            MainForm.Edit11.Text := comments;
            MainForm.SpeedButton8.Click;
            MainForm.CheckBox1.Checked := True;
          end;

          12:
          begin
            dmFunc.Unpack(AData, index, id);
            dmFunc.Unpack(AData, index, adif_text);
            memo1.Lines.Add('Index:' + id + ', ADIF:' + adif_text);
          end

          else
          begin
            Memo1.Lines.Add('Непонятный тип сообщения:' +
              IntToStr(messageType));

          end;
            WSJT_Run := False;
        end;
      end;
    end;
  end;
end;

end.
