unit serverDM_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, lNetComponents, lNet, IdIPWatch, IdTCPServer, ResourceStr,
  const_u, LazUTF8, IdCustomTCPServer, IdContext, digi_record, flDigiModem;

type

  { TServerDM }

  TServerDM = class(TDataModule)
    IdIPWatch1: TIdIPWatch;
    IdFldigiTCP: TIdTCPServer;
    LTCPComponent1: TLTCPComponent;
    LUDPComponent1: TLUDPComponent;
    procedure DataModuleCreate(Sender: TObject);
    procedure IdFldigiTCPConnect(AContext: TIdContext);
    procedure IdFldigiTCPDisconnect(AContext: TIdContext);
    procedure IdFldigiTCPException(AContext: TIdContext; AException: Exception);
    procedure IdFldigiTCPExecute(AContext: TIdContext);
    procedure LTCPComponent1Accept(aSocket: TLSocket);
    procedure LTCPComponent1CanSend(aSocket: TLSocket);
    procedure LTCPComponent1Disconnect(aSocket: TLSocket);
    procedure LTCPComponent1Error(const msg: string; aSocket: TLSocket);
    procedure LTCPComponent1Receive(aSocket: TLSocket);
    procedure LUDPComponent1Error(const msg: string; aSocket: TLSocket);
    procedure LUDPComponent1Receive(aSocket: TLSocket);
  private
    lastTCPport: integer;
    lastUDPport: integer;
    AdifDataSyncAll: boolean;
    AdifDataSyncDate: boolean;
    AdifDataDate: string;
    BuffToSend: string;
    ImportAdifMobile: boolean;
    Stream: TMemoryStream;
    AdifFromMobileSyncStart: boolean;
    DataDigi: TDigiR;
    FldigiMode, FldigiSubMode: string;
    FldigiFreq: double;
    procedure FldigiToForm;
    function GetNewChunk: string;
    procedure GetFldigiUDP(Message: string);

  public
    AdifFromMobileString: TStringList;
    AdifMobileString: TStringList;

  end;

var
  ServerDM: TServerDM;
  MessageToForm: string;

implementation

uses InitDB_dm, MainFuncDM, dmFunc_U, ExportAdifForm_u,
  ImportADIFForm_U, miniform_u, fldigi;

{$R *.lfm}

{ TServerDM }

procedure TServerDM.LUDPComponent1Receive(aSocket: TLSocket);
var
  mess: string;
begin
  if aSocket.GetMessage(mess) > 0 then
  begin
    if (mess = 'GetIP:' + DBRecord.CurrCall) or (mess = 'GetIP:' +
      DBRecord.CurrCall + #10) then
      LUDPComponent1.SendMessage(IdIPWatch1.LocalIP + ':' + IntToStr(lastTCPport))
    else
      MessageToForm := rSyncErrCall;
    if (mess = 'Hello') or (mess = 'Hello' + #10) then
      LUDPComponent1.SendMessage('Welcome!');
  end;
end;

procedure TServerDM.DataModuleCreate(Sender: TObject);
var
  i: integer;
begin
  try
    lastUDPport := -1;
    AdifFromMobileSyncStart := False;
    ImportAdifMobile := False;
    for i := 0 to 5 do
      if LUDPComponent1.Listen(port_udp[i]) then
      begin
        lastUDPport := port_udp[i];
        Break;
      end;
    if lastUDPport = -1 then
      MessageToForm := 'Can not create socket';
    lastTCPport := -1;
    LTCPComponent1.ReuseAddress := True;
    for i := 0 to 5 do
      if LTCPComponent1.Listen(port_tcp[i]) then
      begin
        lastTCPport := port_tcp[i];
        MessageToForm :=
          'Sync port UDP:' + IntToStr(lastUDPport) + ' TCP:' + IntToStr(lastTCPport);
        Break;
      end;
    if lastTCPport = -1 then
      MessageToForm := 'Can not create socket';

    if IniSet.FLDIGI_USE then
      IdFldigiTCP.Active := True;

    FldigiMode := '';
    FldigiSubMode := '';
    FldigiFreq := 0;

  except
    on E: Exception do
      WriteLn(ExceptFile, 'TServerDM.DataModuleCreate:' + E.ClassName + ':' + E.Message);
  end;
end;

procedure TServerDM.IdFldigiTCPConnect(AContext: TIdContext);
begin
  MiniForm.TextSB(rConnectedToFldigi, 0);
end;

procedure TServerDM.IdFldigiTCPDisconnect(AContext: TIdContext);
begin
  MiniForm.TextSB(rDisconnectedFromFldigi, 0);
end;

procedure TServerDM.IdFldigiTCPException(AContext: TIdContext; AException: Exception);
begin
  WriteLn(ExceptFile, 'IdFldigiTCPException:' + AException.ClassName +
    ':' + AException.Message);
end;

procedure TServerDM.IdFldigiTCPExecute(AContext: TIdContext);
const
  ProgramStr: string = '<CMD><PROGRAM></CMD>';
var
  MessageFromUDP: string;
begin
  MessageFromUDP := AContext.Connection.Socket.ReadLn;
  if Length(MessageFromUDP) > 0 then
  begin
    if Pos(ProgramStr, MessageFromUDP) > 0 then
    begin
      AContext.Connection.Socket.Writeln('<CMD><PROGRAMRESPONSE><PGM>N3FJP''s ' +
        'Amateur Contact Log</PGM><VER>5.5</VER><APIVER>0.6.2</APIVER></CMD>');
    end;
    GetFldigiUDP(MessageFromUDP);
  end;
end;

procedure TServerDM.GetFldigiUDP(Message: string);
const
  ProgramStr: string = '<CMD><PROGRAM></CMD>';
var
  currFreq: double;
  currMode: string = '';
  currSubMode: string = '';
  currCall: string;
  currName: string;
  currQTH: string;
  currGrid: string;
  currRSTr: string;
  currRSTs: string;
  currState: string;
begin
  try
    if Pos(ProgramStr, Message) = 0 then
    begin
      if Pos('ACTION', Message) > 0 then
        if dmFunc.getFieldFromFldigi(Message, 'VALUE') = 'ENTER' then
          DataDigi.Save := True;
      if Pos('ACTION', Message) > 0 then
        if dmFunc.getFieldFromFldigi(Message, 'VALUE') = 'CLEAR' then
        begin
          DataDigi.DXCall := '';
          DataDigi.OmName := '';
          DataDigi.QTH := '';
          DataDigi.DXGrid := '';
          DataDigi.RSTr := '';
          DataDigi.RSTs := '';
          DataDigi.State := '';
          Exit;
        end;
    end;

    currFreq := Fldigi_GetQSOFrequency / 1000;
    currCall := Fldigi_GetCall;
    currName := Fldigi_GetName;
    currQTH := Fldigi_GetQTH;
    currGrid := Fldigi_GetLocator;
    currRSTr := Fldigi_GetRSTr;
    currRSTs := Fldigi_GetRSTs;
    currState := fldigi_getState;
    dmFlModem.GetModemName(Fldigi_GetModemId, currMode, currSubMode);

    DataDigi.DXCall := currCall;
    if Length(currName) > 0 then
      DataDigi.OmName := currName;
    if Length(currQTH) > 0 then
      DataDigi.QTH := currQTH;
    if Length(currGrid) > 0 then
      DataDigi.DXGrid := currGrid;
    if Length(currRSTr) > 0 then
      DataDigi.RSTr := currRSTr;
    if Length(currRSTs) > 0 then
      DataDigi.RSTs := currRSTs;
    if Length(currState) > 0 then
      DataDigi.State := currState;

    if (FldigiMode <> currMode) or (FldigiSubMode <> currSubMode) then
    begin
      FldigiMode := currMode;
      FldigiSubMode := currSubMode;
      DataDigi.SubMode := FldigiSubMode;
      DataDigi.Mode := FldigiMode;
    end;

    if FldigiFreq <> currFreq then
    begin
      FldigiFreq := currFreq;
      if IniSet.showBand then
        DataDigi.Freq := dmFunc.GetBandFromFreq(FormatFloat(view_freq, FldigiFreq))
      else
        DataDigi.Freq := FormatFloat(view_freq, FldigiFreq);
    end;

  finally
    TThread.Synchronize(nil, @FldigiToForm);
  end;
end;

procedure TServerDM.FldigiToForm;
begin
  MiniForm.ShowDataFromFldigi(DataDigi);
  DataDigi.Save := False;
end;

procedure TServerDM.LTCPComponent1Accept(aSocket: TLSocket);
begin
  MessageToForm :=
    rClientConnected + aSocket.PeerAddress;
end;

procedure TServerDM.LTCPComponent1CanSend(aSocket: TLSocket);
var
  Sent: integer;
  TempBuffer: string = '';
begin
  if (AdifDataSyncAll = True) or (AdifDataSyncDate = True) then
  begin
    TempBuffer := BuffToSend;
    while TempBuffer <> '' do
    begin
      Sent := LTCPComponent1.SendMessage(TempBuffer, aSocket);
      Delete(BuffToSend, 1, Sent);
      TempBuffer := BuffToSend;
      {$IFDEF LINUX}
      Sleep(100);
      {$ENDIF}
    end;
  end;
end;

function TServerDM.GetNewChunk: string;
var
  res: string;
  i: integer;
begin
  res := '';
  for i := 0 to AdifMobileString.Count - 1 do
  begin
    res := res + AdifMobileString[0];
    AdifMobileString.Delete(0);
  end;
  res := res + 'DataSyncSuccess:' + LBRecord.CallSign + #13;
  Result := res;
  AdifMobileString.Free;
end;

procedure TServerDM.LTCPComponent1Disconnect(aSocket: TLSocket);
begin
  //MainForm.StatusBar1.Panels.Items[0].Text := rDone;
  MessageToForm := aSocket.PeerAddress + ':' + rDone;
end;

procedure TServerDM.LTCPComponent1Error(const msg: string; aSocket: TLSocket);
begin
  MessageToForm := asocket.peerAddress + ':' + SysToUTF8(msg);
end;

procedure TServerDM.LTCPComponent1Receive(aSocket: TLSocket);
var
  mess, rec_call, s: string;
  AdifFile: TextFile;
begin
  AdifDataSyncAll := False;
  AdifDataSyncDate := False;

  if aSocket.GetMessage(mess) > 0 then
  begin
    if Pos('DataSyncAll', mess) > 0 then
    begin
      rec_call := dmFunc.par_str(mess, 2);
      if Pos(LBRecord.CallSign, rec_call) > 0 then
      begin
        AdifMobileString := TStringList.Create;
        exportAdifForm.ExportToMobile('All', '');
        AdifDataSyncAll := True;
        BuffToSend := GetNewChunk;
        LTCPComponent1.OnCanSend(LTCPComponent1.Iterator);
      end;
    end;

    if Pos('DataSyncDate', mess) > 0 then
    begin
      AdifDataDate := dmFunc.par_str(mess, 2);
      rec_call := dmFunc.par_str(mess, 3);
      if Pos(LBRecord.CallSign, rec_call + #13) > 0 then
      begin
        AdifMobileString := TStringList.Create;
        exportAdifForm.ExportToMobile('Date', AdifDataDate);
        AdifDataSyncDate := True;
        BuffToSend := GetNewChunk;
        LTCPComponent1.OnCanSend(LTCPComponent1.Iterator);
      end;
    end;

    if Pos('DataSyncClientStart', mess) > 0 then
    begin
      rec_call := dmFunc.par_str(mess, 2);
      if Pos(LBRecord.CallSign, rec_call) > 0 then
      begin
        Stream := TMemoryStream.Create;
        AdifFromMobileSyncStart := True;
      end;
    end;

    if (AdifFromMobileSyncStart = True) then
    begin
      mess := StringReplace(mess, #10, '', [rfReplaceAll]);
      mess := StringReplace(mess, #13, '', [rfReplaceAll]);
      if Length(mess) > 0 then
      begin
        Stream.Write(mess[1], length(mess));
      end;
    end;

    if Pos('DataSyncClientEnd', mess) > 0 then
    begin
      AdifFromMobileSyncStart := False;
      ImportAdifMobile := True;
      Stream.SaveToFile(FilePATH + 'ImportMobile.adi');
      AssignFile(AdifFile, FilePATH + 'ImportMobile.adi');
      Reset(AdifFile);
      while not EOF(AdifFile) do
      begin
        Readln(AdifFile, s);
        s := StringReplace(s, '<EOR>', '<EOR>'#10, [rfReplaceAll]);
        s := StringReplace(s, '<EOH>', '<EOH>'#10, [rfReplaceAll]);
      end;
      CloseFile(AdifFile);
      Rewrite(AdifFile);
      Writeln(AdifFile, s);
      CloseFile(AdifFile);

      ImportADIFForm.ADIFImport(FilePATH + 'ImportMobile.adi', True);
      Stream.Free;
      ImportAdifMobile := False;
    end;
  end;
end;

procedure TServerDM.LUDPComponent1Error(const msg: string; aSocket: TLSocket);
begin
  MessageToForm := asocket.peerAddress + ':' + SysToUTF8(msg);
end;

end.
