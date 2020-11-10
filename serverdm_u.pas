unit serverDM_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, lNetComponents, lNet, IdIPWatch, IdTCPServer, ResourceStr,
  const_u, LazUTF8, IdContext, digi_record, flDigiModem,
  ImportADIThread, MobileSyncThread;

type

  { TServerDM }

  TServerDM = class(TDataModule)
    IdIPWatch1: TIdIPWatch;
    IdFldigiTCP: TIdTCPServer;
    LUDPComponent1: TLUDPComponent;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure IdFldigiTCPConnect(AContext: TIdContext);
    procedure IdFldigiTCPDisconnect(AContext: TIdContext);
    procedure IdFldigiTCPException(AContext: TIdContext; AException: Exception);
    procedure IdFldigiTCPExecute(AContext: TIdContext);
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

  end;

var
  ServerDM: TServerDM;
  FldigiConnect: boolean;

implementation

uses InitDB_dm, MainFuncDM, dmFunc_U,
  miniform_u, fldigi;

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

  except
    on E: Exception do
      WriteLn(ExceptFile, 'TServerDM.DataModuleCreate:' + E.ClassName + ':' + E.Message);
  end;
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
