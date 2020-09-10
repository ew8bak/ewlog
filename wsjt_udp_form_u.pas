unit WSJT_UDP_Form_U;

{$mode objfpc}{$H+}

interface

uses

{$DEFINE UseCThreads}
{$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
{$ENDIF}{$ENDIF}
  Classes, SysUtils, IdUDPServer, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, IdComponent, IdSocketHandle, IdGlobal, dateutils, WsjtUtils, qso_record;

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

uses dmFunc_U, miniform_u, InitDB_dm, MainFuncDM;

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
  IdUDPServer1.Active := True;
end;

procedure TWSJT_UDP_Form.FormDestroy(Sender: TObject);
begin
  FreeAndNil(IdUDPServer1);
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
  //tm: cardinal;
  ztime: TDateTime;
  DT: double;
  DF: cardinal;
  date: TDateTime;
  z: TStringList;
  Memomessage, locator: string;
  rst, RXDF, TXDF: integer;
begin
  peerPort := ABinding.PeerPort;

 // Memo1.Lines.Add('Datagram received - length: ' + IntToStr(Length(AData)));
  while index < Length(AData) do
  begin
    Unpack(AData, index, magic);
  //   Memo1.Lines.Add('index:' + IntToStr(index) + ' magic:$' + IntToHex(magic,8));
    if (magic = longint($ADBCCBDA)) and (index < Length(AData)) then
    begin
      Unpack(AData, index, schema);
      if (schema = 2) and (index < Length(AData)) then
      begin
        Unpack(AData, index, messageType);
        Unpack(AData, index, id);
        Memo1.Lines.Add('Message type:' + IntToStr(messageType) + ' from:[' + id + ']');
        case messageType of
          0:
          begin
            Memo1.Lines.Add('ЖИВУ!');
            WSJT_Run := True;
          end;
          1:
          begin
            Unpack(AData, index, frequency);
            Unpack(AData, index, mode);
            Unpack(AData, index, DXCall);
            Unpack(AData, index, report);
            Unpack(AData, index, TXMode);
            Unpack(AData, index, TXEnabled);
            Unpack(AData, index, transmitting);
            Unpack(AData, index, Decoding);
            Unpack(AData, index, RXDF);
            Unpack(AData, index, TXDF);
            Unpack(AData, index, DECall);
            Unpack(AData, index, DEGrid);
            Unpack(AData, index, DXGrid);

            MiniForm.EditCallsign.Text := DXCall;
            MiniForm.EditGrid.Text := DXGrid;

            if IniSet.showBand and
              (dmFunc.GetBandFromFreq(FormatFloat('0.000"."00', frequency / 1000000)) <> '') then
              MiniForm.CBBand.Text := dmFunc.GetBandFromFreq(
                FormatFloat('0.000"."00', frequency / 1000000))
            else
              MiniForm.CBBand.Text := FormatFloat('0.000"."00', frequency / 1000000);

            if mode <> 'FT4' then begin
            MiniForm.CBMode.Text := mode;
            MiniForm.CBSubMode.Text := '';
            end
            else begin
            MiniForm.CBMode.Text := 'MFSK';
            MiniForm.CBSubMode.Text := 'FT4';
            end;
            MiniForm.CBRSTr.Text := report;
          end;

          2:
          begin
            Unpack(AData, index, isNew);
            Unpack(AData, index, tm);
            ztime := IncMilliSecond(0, tm);
            Unpack(AData, index, SNR);
            Unpack(AData, index, DT);
            Unpack(AData, index, DF);
            Unpack(AData, index, mode);
            Unpack(AData, index, message);

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
            Unpack(AData, index, date);
            Unpack(AData, index, DXCall);
            Unpack(AData, index, DXGrid);
            Unpack(AData, index, frequency);
            Unpack(AData, index, mode);
            Unpack(AData, index, report);
            Unpack(AData, index, reportReceived);
            Unpack(AData, index, TXPower);
            Unpack(AData, index, comments);
            Unpack(AData, index, DXName);

            Memo1.Lines.Add('QSO сохранено: Дата:' +
              FormatDateTime('dd.mm.yyyy hh:mm:ss', date) +
              ' DX Call:' + DXCall + ' DX Grid:' + DXGrid +
              ' Частота:' + IntToStr(frequency) + ' Мода:' +
              mode + ' RST отправлено: ' + report +
              ' RST получено:' + reportReceived + ' TX мощность:' +
              TXPower + ' Комментарий:' + comments + ' Имя:' + DXName);

            MiniForm.CBRealTime.Checked := False;
            MiniForm.DateEdit1.Date := date;
            MiniForm.DateTimePicker1.Time := date;
            MiniForm.EditCallsign.Text := DXCall;

             if IniSet.showBand and
              (dmFunc.GetBandFromFreq(FormatFloat('0.000"."00', frequency / 1000000)) <> '') then
              MiniForm.CBBand.Text := dmFunc.GetBandFromFreq(
                FormatFloat('0.000"."00', frequency / 1000000))
            else
              MiniForm.CBBand.Text := FormatFloat('0.000"."00', frequency / 1000000);

            MiniForm.EditGrid.Text := DXGrid;
            MiniForm.CBMode.Text := mode;
            MiniForm.CBRSTs.Text := report;
            MiniForm.CBRSTr.Text := reportReceived;
            if DXName <> '' then
            MiniForm.EditName.Text := DXName;
            MiniForm.EditComment.Text := comments;
            MiniForm.SBSave.Click;
            MiniForm.CBRealTime.Checked := True;
          end;

          12:
          begin
           // Unpack(AData, index, id);
            Unpack(AData, index, adif_text);
            //writeln('Index:' + id + ', ADIF:' + adif_text);
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
