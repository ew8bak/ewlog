{*********************************************************************************
***                               AlarmeJT                                    ***
***    AlarmeJT is designed to work with exellent WSJT -X Joe Taylor, K1JT    ***
***    running on JT65A, JT9 and FT8 modes.                                   ***
***    -------------------------------------------------------------------    ***
***    version : 0.8 UDP beta 64 bits                                         ***
***    -------------------------------------------------------------------    ***
***    Copyright 2017 Alain Thébault (F5JMH)                                  ***
***                                                                           ***
***    This file is part of AlarmeJT.                                         ***
***                                                                           ***
***    AlarmeJT is free software: you can redistribute it and/or modify       ***
***    it under the terms of the GNU General Public License as published by   ***
***    the Free Software Foundation, either version 2.0 of the License, or    ***
***    any later version.                                                     ***
***                                                                           ***
***    AlarmeJT is distributed in the hope that it will be useful,            ***
***    but WITHOUT ANY WARRANTY; without even the implied warranty of         ***
***    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          ***
***    GNU General Public License for more details.                           ***
***                                                                           ***
***    You should have received a copy of the GNU General Public License      ***
***    along with AlarmeJT.  If not, see <http://www.gnu.org/licenses/>.      ***
***                                                                           ***
***    -------------------------------------------------------------------    ***
*********************************************************************************}

unit WSJT_UDP_Form_U;

{$mode objfpc}{$H+}

interface

uses

{$DEFINE UseCThreads}
{$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
{$ENDIF}{$ENDIF}
  Classes, SysUtils, IdUDPServer, FileUtil, Forms, Controls, Graphics,
  StdCtrls, IdComponent, IdSocketHandle, IdGlobal, dateutils, WsjtUtils, digi_record,
  QSODataDecoder;

const
  SJT65: string = '#';
  SJT9: string = '@';
  SFT8: string = '~';


type
  { TWSJT_UDP_Form }

  TWSJT_UDP_Form = class(TForm)
    IdWsjtUDP: TIdUDPServer;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure IdWsjtUDPStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure IdWsjtUDPUDPException(AThread: TIdUDPListenerThread;
      ABinding: TIdSocketHandle; const AMessage: string;
      const AExceptionClass: TClass);
    procedure IdWsjtUDPUDPRead(AThread: TIdUDPListenerThread;
      AData: TIdBytes; ABinding: TIdSocketHandle);
  private
    DataDigi: TDigiR;
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

uses miniform_u, MainFuncDM;

{$R *.lfm}

{ TWSJT_UDP_Form }

function TWSJT_UDP_Form.WSJT_IsRunning: boolean;
begin
  Result := WSJT_Run;
end;

procedure TWSJT_UDP_Form.IdWsjtUDPStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin
  Memo1.Lines.Add('Статус UDP сервера: ' + AStatusText);
end;

procedure TWSJT_UDP_Form.FormCreate(Sender: TObject);
begin
  IdWsjtUDP.Active := IniSet.WSJT_USE;
end;

procedure TWSJT_UDP_Form.FormDestroy(Sender: TObject);
begin
  FreeAndNil(IdWsjtUDP);
end;

procedure TWSJT_UDP_Form.IdWsjtUDPUDPException(AThread: TIdUDPListenerThread;
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

function QDateTimeToTDateTime(const AQDateTime: TQDateTime): TDateTime;
const
  DELPHI_EPOCH_JD = 2415018.5;
begin
  Result := AQDateTime.JulianDay - DELPHI_EPOCH_JD;
  Result := Result + (AQDateTime.MsecsSinceMidnight / MSecsPerDay);
end;

procedure TWSJT_UDP_Form.IdWsjtUDPUDPRead(AThread: TIdUDPListenerThread;
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
  Decoder: TQSODataDecoder;
  QSO: TQSOLogged;
begin
  peerPort := ABinding.PeerPort;

  while index < Length(AData) do
  begin
    Unpack(AData, index, magic);

    if (magic = longint($ADBCCBDA)) and (index < Length(AData)) then
    begin
      Unpack(AData, index, schema);
      if (schema = 2) and (index < Length(AData)) then
      begin
        Unpack(AData, index, messageType);
        Unpack(AData, index, id);
        DataDigi.Save := False;
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
            Unpack(AData, index, DataDigi.DXCall);
            Unpack(AData, index, DataDigi.RSTs);
            Unpack(AData, index, TXMode);
            Unpack(AData, index, TXEnabled);
            Unpack(AData, index, transmitting);
            Unpack(AData, index, Decoding);
            Unpack(AData, index, RXDF);
            Unpack(AData, index, TXDF);
            Unpack(AData, index, DECall);
            Unpack(AData, index, DEGrid);
            Unpack(AData, index, DataDigi.DXGrid);

            DataDigi.Freq := frequency;

            if mode <> 'FT4' then
            begin
              DataDigi.Mode := mode;
              DataDigi.SubMode := '';
            end
            else
            begin
              DataDigi.Mode := 'MFSK';
              DataDigi.SubMode := 'FT4';
            end;
            MiniForm.ShowDataFromDIGI(DataDigi);
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
            Decoder := TQSODataDecoder.Create;
            QSO := Decoder.DecodeMessage(AData);

            Unpack(AData, index, date);
            Unpack(AData, index, DataDigi.DXCall);
            Unpack(AData, index, DataDigi.DXGrid);
            Unpack(AData, index, frequency);
            Unpack(AData, index, mode);
            Unpack(AData, index, DataDigi.RSTs);
            Unpack(AData, index, DataDigi.RSTr);
            Unpack(AData, index, TXPower);
            Unpack(AData, index, comments);
            Unpack(AData, index, DXName);
            date := QDateTimeToTDateTime(QSO.DateTimeOn);

            Memo1.Lines.Add('QSO сохранено: Дата:' +
              FormatDateTime('dd.mm.yyyy hh:mm:ss', date) +
              ' DX Call:' + DataDigi.DXCall + ' DX Grid:' + DataDigi.DXGrid +
              ' Частота:' + IntToStr(frequency) + ' Мода:' +
              mode + ' RST отправлено: ' + DataDigi.RSTs +
              ' RST получено:' + DataDigi.RSTr + ' TX мощность:' +
              TXPower + ' Комментарий:' + comments + ' Имя:' + DXName);

              DataDigi.Freq := frequency;

            if mode <> 'FT4' then
            begin
              DataDigi.Mode := mode;
              DataDigi.SubMode := '';
            end
            else
            begin
              DataDigi.Mode := 'MFSK';
              DataDigi.SubMode := 'FT4';
            end;

            //if (DXName <> '') and (DXCall <> '') then
            //  DataDigi.OmName := DXName;
            DataDigi.Comment := comments;
            DataDigi.Save := True;
            MiniForm.ShowDataFromDIGI(DataDigi);
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
