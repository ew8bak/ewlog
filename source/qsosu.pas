unit qsosu;

{$mode ObjFPC}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils, qso_record, fphttpclient, DateUtils;

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
    procedure SyncShowResult;
    function SendQSOsu(SendQSOr: TQSO): boolean;
    function getCallsingID(myCallSign: string): boolean;
  private
    result_mes: string;
    getDoc: boolean;
    Done: boolean;
    FSuccess: boolean;
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
function DateToISO8601(const DateTime: TDateTime): String;

var
  SendQSOsuThread: TSendQSOsuLogThread;

implementation

uses Forms, LCLType, dmFunc_U, MainFuncDM, fpjson, jsonparser;

function StripStr(t, s: string): string;
begin
  Result := StringReplace(s, t, '', [rfReplaceAll]);
end;

function DateToISO8601(const DateTime: TDateTime): String;
var
  Year, Month, Day: Word;
  Hour, Min, Sec, MSec: Word;
begin
  DecodeDate(DateTime, Year, Month, Day);
  DecodeTime(DateTime, Hour, Min, Sec, MSec);
  Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d', [Year, Month, Day, Hour, Min, Sec]);
end;

function TSendQSOsuLogThread.SendQSOsu(SendQSOr: TQSO): boolean;
var
  HTTP: TFPHttpClient;
  RequestBody: TStringStream;
  Response: string;
  JsonData: TJSONData;
  ResponseObj: TJSONObject;
  QSOData: TJSONObject;
  hash: string;
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
  QSOData.Add('datetime', DateToISO8601(SendQSOr.QSODateTime));
  QSOData.Add('name', SendQSOr.OmName);
  QSOData.Add('rsts', SendQSOr.QSOReportSent);
  QSOData.Add('rstr', SendQSOr.QSOReportRecived);
  QSOData.Add('qth', SendQSOr.OmQTH);
  QSOData.Add('state', SendQSOr.OmQTH);
  QSOData.Add('cnty', SendQSOr.State0);
  QSOData.Add('gridsquare', SendQSOr.Grid);
  QSOData.Add('my_cnty', SendQSOr.My_State);
  QSOData.Add('my_gridsquare', SendQSOr.My_Grid);
  QSOData.Add('cqz', SendQSOr.CQZone);
  QSOData.Add('ituz', SendQSOr.ITUZone);

  hash :=  QSOData.AsJSON;
  Result := False;
  HTTP := TFPHttpClient.Create(nil);
  RequestBody := TStringStream.Create(QSOData.AsJSON, TEncoding.UTF8);
  try
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('Authorization', 'Bearer ' + token);
    HTTP.AddHeader('Content-Type', 'application/json');
    HTTP.RequestBody := RequestBody;

    try
      Response := HTTP.Post(BaseURL + '/sendLog');

      if HTTP.ResponseStatusCode = 201 then
      begin
        JsonData := GetJSON(Response);
        try
          if JsonData.JSONType = jtObject then
          begin
            ResponseObj := TJSONObject(JsonData).Objects['response'];
            hash := ResponseObj.Get('hash', '');
            if hash = '' then
            begin
              result_mes := TJSONObject(JsonData).Get('message', 'Unknown error');
            end
            else
            begin
               MainFunc.UpdateQSL('QSOSU_HASH', hash, SendQSO);
            end;
          end;
        finally
          JsonData.Free;
        end;
      end
      else
      begin
        result_mes := 'HTTP Error: ' + IntToStr(HTTP.ResponseStatusCode);
      end;
    except
      on E: Exception do
        result_mes := E.Message;
    end;
  finally
    RequestBody.Free;
    HTTP.Free;
  end;


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

procedure TSendQSOsuLogThread.SyncShowResult;
begin
  if FSuccess and Assigned(OnQSOsuSent) then
    OnQSOsuSent;
  ShowResult;
end;

procedure TSendQSOsuLogThread.Execute;
begin
  FSuccess := SendQSOsu(SendQSO);
  Synchronize(@SyncShowResult);
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

