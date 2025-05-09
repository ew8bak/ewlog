unit qsosu;

{$mode ObjFPC}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils, qso_record, fphttpclient;

resourcestring
  rAnswerServer = 'Server response:';
  rErrorSendingSata = 'Error sending data';
  rRecordAddedSuccessfully = 'Record added successfully';
  rNoEntryAdded = 'No entry added! Perhaps a duplicate!';
  rUnknownUser = 'Unknown user! See settings';

const
  BaseURL = 'https://api.qso.su/method/v1';

type
  TQSOsuSentEvent = procedure of object;

  TSendQSOsuLogThread = class(TThread)
  protected
    procedure Execute; override;
    procedure ShowResult;
    function SendQSOsu(SendQSOr: TQSO): boolean;
    function getCallsingID(myCallSign: string): boolean;
  private
    result_mes: string;
    getDoc: boolean;
    Done: boolean;
  public
    SendQSO: TQSO;
    token: string;
    callsign: string;
    callsignID: integer;
    operatorID: integer;
    OnQSOsuSent: TQSOsuSentEvent;
    constructor Create;
  end;

function StripStr(t, s: string): string;

var
  SendQSOsuThread: TSendQSOsuLogThread;

implementation

uses Forms, LCLType, dmFunc_U, MainFuncDM, fpjson, jsonparser;

function StripStr(t, s: string): string;
begin
  Result := StringReplace(s, t, '', [rfReplaceAll]);
end;

function TSendQSOsuLogThread.SendQSOsu(SendQSOr: TQSO): boolean;
var
  HTTP: TFPHttpClient;
  QSOData: TJSONObject;
begin
  if callsignID = 0 then getCallsingID(callsign);
  QSOData := TJSONObject.Create;
  QSOData.Add('id_station_callsign', callsignID);
  QSOData.Add('id_operator', operatorID);
  QSOData.Add('call', SendQSOr.CallSing);
  QSOData.Add('band', dmFunc.GetBandFromFreq(SendQSOr.QSOBand));
  QSOData.Add('mode', SendQSOr.QSOMode);
  QSOData.Add('submode', SendQSOr.QSOSubMode);
  QSOData.Add('freq', StringReplace(SendQSOr.QSOBand, '.', '', [rfReplaceAll]) + '0');

  HTTP := TFPHttpClient.Create(nil);
  HTTP.AllowRedirect := True;
  HTTP.AddHeader('Authorization', 'Bearer ' + token);
  //ToDo JSON
  Result := true;
end;

function TSendQSOsuLogThread.getCallsingID(myCallSign: string): Boolean;
var
  HTTP: TFPHttpClient;
  Response: string;
  JsonData: TJSONData;
  ResponseObj: TJSONObject;
  StationCallsigns, Operators: TJSONArray;
  I: Integer;
  FoundCallSign: Boolean;
begin
  Result := False;
  callsignID := 0;
  operatorID := 0;

  HTTP := TFPHttpClient.Create(nil);
  try
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('Authorization', 'Bearer ' + token);
    try
      Response := HTTP.Get(BaseURL + '/getCallsign');

      if HTTP.ResponseStatusCode = 200 then
      begin
        JsonData := GetJSON(Response);
        try
          if JsonData.JSONType = jtObject then
          begin
            ResponseObj := TJSONObject(JsonData).Objects['response'];

            // Получаем ID оператора (первый элемент из массива operator)
            Operators := ResponseObj.Arrays['operator'];
            if Operators.Count > 0 then
              operatorID := TJSONObject(Operators[0]).Get('id', 0);

            // Ищем позывной в station_callsign
            StationCallsigns := ResponseObj.Arrays['station_callsign'];
            FoundCallSign := False;

            for I := 0 to StationCallsigns.Count - 1 do
            begin
              if TJSONObject(StationCallsigns[I]).Get('name', '') = myCallSign then
              begin
                callsignID := TJSONObject(StationCallsigns[I]).Get('id', 0);
                FoundCallSign := True;
                Break;
              end;
            end;

            // Если не нашли в station_callsign, проверяем operator (если нужно)
            if not FoundCallSign then
            begin
              for I := 0 to Operators.Count - 1 do
              begin
                if TJSONObject(Operators[I]).Get('name', '') = myCallSign then
                begin
                  callsignID := TJSONObject(Operators[I]).Get('id', 0);
                  Break;
                end;
              end;
            end;

            Result := (callsignID <> 0) and (operatorID <> 0);
          end;
        finally
          JsonData.Free;
        end;
      end;
    except
      on E: Exception do
        result_mes := E.Message;
    end;
  finally
    HTTP.Free;
  end;
end;
constructor TSendQSOsuLogThread.Create;
begin
  FreeOnTerminate := True;
  OnQSOsuSent := nil;
  inherited Create(True);
end;

procedure TSendQSOsuLogThread.Execute;
begin
  if SendQSOsu(SendQSO) then
    if Assigned(OnQSOsuSent) then
      Synchronize(OnQSOsuSent);
  Synchronize(@ShowResult);
end;

procedure TSendQSOsuLogThread.ShowResult;
begin
  if Done then
    MainFunc.UpdateQSL('QSOSU_QSO_UPLOAD_STATUS', '1', SendQSO);
  if Length(result_mes) > 0 then
    Application.MessageBox(PChar(rAnswerServer + result_mes),
      PChar('QSOsu -> '+ SendQSO.CallSing), MB_ICONEXCLAMATION);
end;

end.

