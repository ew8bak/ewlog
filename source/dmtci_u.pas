unit dmTCI_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  sywebsocketclient,
  lclintf, StdCtrls, sywebsocketcommon;

type
  TTCIRecord = record
    VFO: string;
    MODULATION: string;
    DEVICE: string;
    PROTOCOL: string;
    STATUS: boolean;
  end;

type
  TTCISettings = record
    Name: string;
    Address: string;
    Port: integer;
    Enable: boolean;
  end;

type

  { TdmTCI }

  TdmTCI = class(TDataModule)
  private
    old_reciever: string;
    TCIClient: TsyWebsocketClient;
    procedure OnMessage(Sender: TObject);
    procedure OnTerminate(Sender: TObject);
    procedure OnConnected(Sender: TObject);
    function ParseValue(reciever, Command: string): string;

  public
    procedure SendValue(Command, Value: string);
    procedure SaveTCIini(nTRX: integer);
    procedure LoadTCIini(nTRX: integer);
    function InicializeTCI(nTRX: integer): boolean;
    procedure StopTCI;

  end;

var
  dmTCI: TdmTCI;
  TCIRec: TTCIRecord;
  TCISettings: TTCISettings;

implementation

uses MainFuncDM, InitDB_dm, dmFunc_U, miniform_u, TRXForm_U;

{$R *.lfm}

{ TdmTCI }

function TdmTCI.InicializeTCI(nTRX: integer): boolean;
begin
  Result := False;
  old_reciever := '';
  StopTCI;
  LoadTCIini(nTRX);
  if TCISettings.Enable then
  begin
    TCIClient := TsyWebsocketClient.Create(TCISettings.Address, TCISettings.Port);
    TCIClient.OnMessage := @OnMessage;
    TCIClient.OnTerminate := @OnTerminate;
    TCIClient.OnConnected := @OnConnected;
    TCIClient.Start;
    Result := True;
  end;
end;

procedure TdmTCI.LoadTCIini(nTRX: integer);
begin
  TCISettings.Name := INIFile.ReadString('TCI' + IntToStr(nTRX), 'Name', '');
  TCISettings.Address := INIFile.ReadString('TCI' + IntToStr(nTRX),
    'Address', '127.0.0.1');
  TCISettings.Port := INIFile.ReadInteger('TCI' + IntToStr(nTRX), 'Port', 40001);
  TCISettings.Enable := INIFile.ReadBool('TCI' + IntToStr(nTRX), 'Enable', False);
end;

procedure TdmTCI.SaveTCIini(nTRX: integer);
begin
  INIFile.WriteString('TCI' + IntToStr(nTRX), 'Name', TCISettings.Name);
  INIFile.WriteString('TCI' + IntToStr(nTRX), 'Address', TCISettings.Address);
  INIFile.WriteInteger('TCI' + IntToStr(nTRX), 'Port', TCISettings.Port);
  INIFile.WriteBool('TCI' + IntToStr(nTRX), 'Enable', TCISettings.Enable);
end;

procedure TdmTCI.SendValue(Command, Value: string);
begin
  if TCIRec.STATUS then
  begin
    if Command = 'VFO' then
    begin
      TCIClient.SendMessage('VFO:0,0,' + Value + ';');
    end;
    if Command = 'MODULATION' then
    begin
      TCIClient.SendMessage('MODULATION:0,' + Value + ';');
    end;
  end;
end;

function TdmTCI.ParseValue(reciever, Command: string): string;
var
  tci_string: StringArray;
  values: StringArray;
begin
  if reciever <> old_reciever then
  begin
    SetLength(tci_string, 4);
    SetLength(values, 3);
    tci_string := reciever.Split(':');
    if (tci_string[0] = Command) then
    begin
      values := tci_string[1].split(',');
      if (tci_string[0] = 'VFO') then
      begin
        if (values[1] = '0') and (values[0] = '0') then
          Result := StringReplace(values[2], ';', '', [rfReplaceAll]);
        Exit;
      end;
      if (tci_string[0] = 'MODULATION') then
      begin
        if values[0] = '0' then
          Result := StringReplace(values[1], ';', '', [rfReplaceAll]);
        Exit;
      end;
      if (tci_string[0] = 'PROTOCOL') then
      begin
        Result := StringReplace(values[1], ';', '', [rfReplaceAll]);
        Exit;
      end;
      if (tci_string[0] = 'DEVICE') then
      begin
        Result := StringReplace(values[0], ';', '', [rfReplaceAll]);
        Exit;
      end;
    end
    else
      Result := '';
  end;
end;

procedure TdmTCI.OnMessage(Sender: TObject);
var
  val: TMessageRecord;
  //hz_freq: longint;
begin
  if not Assigned(TCIClient) then
    exit;
  while TCIClient.MessageQueue.TotalItemsPushed <>
    TCIClient.MessageQueue.TotalItemsPopped do
  begin
    TCIClient.MessageQueue.PopItem(val);
    writeln(val.Message);
    TCIRec.PROTOCOL := ParseValue(UpperCase(val.Message), 'PROTOCOL');
    TCIRec.DEVICE := ParseValue(UpperCase(val.Message), 'DEVICE');
    TCIRec.VFO := ParseValue(UpperCase(val.Message), 'VFO');
    TCIRec.MODULATION := ParseValue(UpperCase(val.Message), 'MODULATION');
  end;

  if (TCIRec.VFO <> '') or (TCIRec.MODULATION <> '') then
  begin
    dmFunc.GetRIGMode(TCIRec.MODULATION, FMS.Mode, FMS.SubMode);
    if TCIRec.VFO <> '' then
    begin
      TryStrToFloatSafe(TCIRec.VFO, FMS.Freq);

      //FMS.Freq := FMS.Freq / 1000000;
    end;
    TThread.Synchronize(nil, @MiniForm.ShowInfoFromRIG);
    TThread.Synchronize(nil, @TRXForm.ShowInfoFromRIG);
    //TRXForm.ShowInfoFromRIG(hz_freq);
  end;
end;

procedure TdmTCI.OnTerminate(Sender: TObject);
begin
  TCIRec.STATUS := False;
  IniSet.RIGConnected := TCIRec.STATUS;
  FMS.Freq := 0;
  TThread.Synchronize(nil, @TRXForm.ShowInfoFromRIG);
  StopTCI;
end;

procedure TdmTCI.OnConnected(Sender: TObject);
begin
  TCIRec.STATUS := True;
  IniSet.RIGConnected := TCIRec.STATUS;
  TCIClient.SendMessage('VFO:0,0;');
  TCIClient.SendMessage('MODULATION:0;');
end;

procedure TdmTCI.StopTCI;
begin
  if Assigned(TCIClient) then
    TCIClient.TerminateThread;
  TCIClient := nil;
end;

end.
