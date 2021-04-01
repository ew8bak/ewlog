(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit serverDM_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, lNetComponents, lNet, IdIPWatch, IdTCPServer, ResourceStr,
  const_u, LazUTF8, IdContext, IdUDPClient, IdUDPServer, digi_record,
  flDigiModem, ImportADIThread, MobileSyncThread, IdSocketHandle, IdGlobal,
  DateUtils;

type

  { TServerDM }

  TServerDM = class(TDataModule)
    IdIPWatch1: TIdIPWatch;
    IdFldigiTCP: TIdTCPServer;
    IdWOLServer: TIdUDPServer;
    IdWOLClient: TIdUDPClient;
    LUDPComponent1: TLUDPComponent;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure IdFldigiTCPConnect(AContext: TIdContext);
    procedure IdFldigiTCPDisconnect(AContext: TIdContext);
    procedure IdFldigiTCPException(AContext: TIdContext; AException: Exception);
    procedure IdFldigiTCPExecute(AContext: TIdContext);
    procedure IdWOLServerUDPRead(AThread: TIdUDPListenerThread;
      const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure LUDPComponent1Error(const msg: string; aSocket: TLSocket);
    procedure LUDPComponent1Receive(aSocket: TLSocket);
  private
    PADIImport: TPADIImport;
    lastUDPport: integer;
    DataDigi: TDigiR;
    FldigiMode, FldigiSubMode: string;
    FldigiFreq: double;
    procedure FldigiToForm;
    procedure GetFldigiUDP(Message: string);
    procedure StartImport;
    procedure StartTCPSyncThread;

  public
    procedure DisconnectFldigi;
    procedure SendBroadcastADI(adiLine: string);
    procedure StartWOL;

  end;

var
  ServerDM: TServerDM;
  FldigiConnect: boolean;

implementation

uses InitDB_dm, MainFuncDM, dmFunc_U,
  miniform_u, fldigi, qso_record, prefix_record;

{$R *.lfm}

{ TServerDM }

procedure TServerDM.DisconnectFldigi;
begin
  IdFldigiTCP.Contexts.ClearAndFree;
  IdFldigiTCP.Active := False;
end;

procedure TServerDM.StartTCPSyncThread;
begin
  MobileSynThread := TMobileSynThread.Create;
  if Assigned(MobileSynThread.FatalException) then
    raise MobileSynThread.FatalException;
  MobileSynThread.Start;
end;

procedure TServerDM.LUDPComponent1Receive(aSocket: TLSocket);
var
  mess: string;
begin
  if aSocket.GetMessage(mess) > 0 then
  begin
    if (mess = 'GetIP:' + DBRecord.CurrCall) or (mess = 'GetIP:' +
      DBRecord.CurrCall + #10) then
      LUDPComponent1.SendMessage(IdIPWatch1.LocalIP + ':' +
        IntToStr(MobileSynThread.lastTCPport))
    else
      MiniForm.TextSB(rSyncErrCall, 0);
    if (mess = 'Hello') or (mess = 'Hello' + #10) then
      LUDPComponent1.SendMessage('Welcome!');
  end;
end;

procedure TServerDM.StartWOL;
begin
  try
    IdWOLClient.Active := False;
    IdWOLServer.Active := False;
    IdWOLServer.Bindings.Clear;
    IdWOLClient.BroadcastEnabled := False;
    IdWOLServer.BroadcastEnabled := False;
    if IniSet.WorkOnLAN then
    begin
      IdWOLClient.BroadcastEnabled := True;
      IdWOLClient.Port := IniSet.WOLPort;
      IdWOLClient.Active := True;
      IdWOLServer.Bindings.Add.IP := IniSet.WOLAddress;
      IdWOLServer.Bindings.Add.Port := IniSet.WOLPort;
      IdWOLServer.Active := True;
    end;
  except
    on E: Exception do
      WriteLn(ExceptFile, 'TServerDM.StartWOL:' + E.ClassName + ':' + E.Message);
  end;
end;

procedure TServerDM.DataModuleCreate(Sender: TObject);
var
  i: integer;
begin
  try
    lastUDPport := -1;

    for i := 0 to 5 do
      if LUDPComponent1.Listen(port_udp[i]) then
      begin
        lastUDPport := port_udp[i];
        Break;
      end;

    StartTCPSyncThread;

    FldigiMode := '';
    FldigiSubMode := '';
    FldigiFreq := 0;
    FldigiConnect := False;

    if IniSet.WorkOnLAN then
      StartWOL;

  except
    on E: Exception do
      WriteLn(ExceptFile, 'TServerDM.DataModuleCreate:' + E.ClassName + ':' + E.Message);
  end;
end;

procedure TServerDM.SendBroadcastADI(adiLine: string);
begin
  IndyTextEncoding_UTF8;
  IdWOLClient.Broadcast(adiLine, IniSet.WOLPort);
end;

procedure TServerDM.DataModuleDestroy(Sender: TObject);
begin
  DisconnectFldigi;
  if MobileSynThread <> nil then
    MobileSynThread.Terminate;
end;

procedure TServerDM.IdFldigiTCPConnect(AContext: TIdContext);
begin
  FldigiConnect := True;
  MiniForm.TextSB(rConnectedToFldigi, 0);
end;

procedure TServerDM.IdFldigiTCPDisconnect(AContext: TIdContext);
begin
  FldigiConnect := False;
  MiniForm.TextSB(rDisconnectedFromFldigi, 0);
end;

procedure TServerDM.IdFldigiTCPException(AContext: TIdContext; AException: Exception);
begin
  // WriteLn(ExceptFile, 'IdFldigiTCPException:' + AException.ClassName +
  //   ':' + AException.Message);
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

procedure TServerDM.IdWOLServerUDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  ADILine: string;
  SQSO: TQSO;
  PFXR: TPFXR;
  yyyy, mm, dd: integer;
  QSODate: string;
  DigiBand_String: string;
begin
  try
    IndyTextEncoding_UTF8;
    ADILine := BytesToString(AData);
    if ((dmFunc.getField(ADILine, 'LOG_PGM') = programName) and
      (dmFunc.getField(ADILine, 'LOG_ID') <> IniSet.UniqueID) and
      ((dmFunc.getField(ADILine, 'TO_CALL') = 'ANY') or
      (dmFunc.getField(ADILine, 'TO_CALL') = DBRecord.CurrCall))) then
    begin
      SQSO.CallSing := dmFunc.getField(ADILine, 'CALL');
      SQSO.Call := dmFunc.ExtractCallsign(SQSO.CallSing);
      QSODate := dmFunc.getField(ADILine, 'QSO_DATE');
      SQSO.QSOTime := dmFunc.getField(ADILine, 'TIME_ON');
      SQSO.QSOBand := dmFunc.getField(ADILine, 'FREQ');
      DigiBand_String := SQSO.QSOBand;
      Delete(DigiBand_String, length(DigiBand_String) - 2, 1);
      SQSO.DigiBand := FloatToStr(dmFunc.GetDigiBandFromFreq(DigiBand_String));
      SQSO.QSOMode := dmFunc.getField(ADILine, 'MODE');
      SQSO.QSOSubMode := dmFunc.getField(ADILine, 'SUBMODE');
      SQSO.QSOReportRecived := dmFunc.getField(ADILine, 'RST_RCVD');
      SQSO.QSOReportSent := dmFunc.getField(ADILine, 'RST_SENT');
      SQSO.QSOTime := SQSO.QSOTime[1] + SQSO.QSOTime[2] + ':' +
        SQSO.QSOTime[3] + SQSO.QSOTime[4];
      yyyy := StrToInt(QSODate[1] + QSODate[2] + QSODate[3] + QSODate[4]);
      mm := StrToInt(QSODate[5] + QSODate[6]);
      dd := StrToInt(QSODate[7] + QSODate[8]);
      SQSO.QSODate := EncodeDate(yyyy, mm, dd);
      SQSO.OmQTH := dmFunc.getField(ADILine, 'QTH');
      SQSO.Grid := dmFunc.getField(ADILine, 'GRIDSQUARE');
      SQSO.ShortNote := dmFunc.getField(ADILine, 'COMMENT');
      SQSO.SRX := StrToInt(dmFunc.getField(ADILine, 'SRX'));
      SQSO.STX := StrToInt(dmFunc.getField(ADILine, 'STX'));
      SQSO.SRX_String := dmFunc.getField(ADILine, 'SRX_STRING');
      SQSO.STX_String := dmFunc.getField(ADILine, 'STX_STRING');
      SQSO.State0 := dmFunc.getField(ADILine, 'STATE');
      SQSO.QSLInfo := dmFunc.getField(ADILine, 'QSLMSG');
      SQSO.WPX := dmFunc.ExtractWPXPrefix(SQSO.CallSing);
      PFXR := MainFunc.SearchPrefix(SQSO.CallSing, SQSO.Grid);
      SQSO.MainPrefix := PFXR.Prefix;
      SQSO.DXCCPrefix := PFXR.ARRLPrefix;
      SQSO.CQZone := PFXR.CQZone;
      SQSO.ITUZone := PFXR.ITUZone;
      SQSO.Continent := PFXR.Continent;
      SQSO.DXCC := IntToStr(PFXR.DXCCNum);
      SQSO.NLogDB := LBRecord.LogTable;

      SQSO.IOTA := '';
      SQSO.QSLManager := '';
      SQSO.QSOAddInfo := '';
      SQSO.Marker := '';
      SQSO.State1 := '';
      SQSO.State2 := '';
      SQSO.State3 := '';
      SQSO.State4 := '';
      SQSO.SAT_NAME := '';
      SQSO.SAT_MODE := '';
      SQSO.PROP_MODE := '';
      SQSO.QSLRec := '0';
      SQSO.ManualSet := 0;
      SQSO.QSLReceQSLcc := 0;
      SQSO.LotWRec := '';
      SQSO.QSLSent := '0';
      SQSO.QSLSentAdv := 'F';
      SQSO.ManualSet := 0;
      SQSO.ValidDX := '1';
      SQSO.LotWSent := 0;
      SQSO.QSL_RCVD_VIA := '';
      SQSO.QSL_SENT_VIA := '';
      SQSO.USERS := '';
      SQSO.NoCalcDXCC := 0;
      SQSO.SYNC := 0;
      SQSO.My_State := '';
      SQSO.My_Grid := '';
      SQSO.My_Lat := '';
      SQSO.My_Lon := '';
      SQSO.AwardsEx := '';
      SQSO.My_Grid := '';

      MainFunc.SaveQSO(SQSO);
    end;

  except
    on E: Exception do
      WriteLn(ExceptFile, 'TServerDM.IdWOLServerUDPRead:' + E.ClassName +
        ':' + E.Message);
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
  MiniForm.ShowDataFromDIGI(DataDigi);
  DataDigi.Save := False;
end;

procedure TServerDM.StartImport;
begin
  PADIImport.Path := FilePATH + 'ImportMobile.adi';
  PADIImport.Mobile := True;
  PADIImport.SearchPrefix := True;
  PADIImport.Comment := '';
  PADIImport.TimeOnOff := True;
  ImportADIFThread := TImportADIFThread.Create;
  if Assigned(ImportADIFThread.FatalException) then
    raise ImportADIFThread.FatalException;
  ImportADIFThread.PADIImport := PADIImport;
  ImportADIFThread.Start;
end;

procedure TServerDM.LUDPComponent1Error(const msg: string; aSocket: TLSocket);
begin
  MiniForm.TextSB(aSocket.peerAddress + ':' + SysToUTF8(msg), 0);
end;

end.
