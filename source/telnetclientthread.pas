(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit telnetClientThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ssl_openssl, IdGlobal, IdTelnet, IdComponent;

type
  TdxClientRecord = record
    Message: string;
    Connected: boolean;
  end;

type
  TTelnetThread = class(TThread)
  protected
    procedure Execute; override;
  private
    DXTelnetClient: TIdTelnet;
    dxClientRecord: TdxClientRecord;
    procedure OnDataAvailable(Sender: TIdTelnet; const Buffer: TIdBytes);
    procedure OnStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    function ConnectToCluster: boolean;
    procedure SendMessage(Message: string);
    procedure ClearSendMessage;

  public
    constructor Create;
    destructor Destroy; override;
    procedure ToForm;
  end;

var
  TelnetThread: TTelnetThread;

implementation

uses MainFuncDM, dxclusterform_u, InitDB_dm;

procedure TTelnetThread.SendMessage(Message: string);
begin
  if Length(Message) > 0 then
  begin
    DXTelnetClient.SendString(Message);
    Synchronize(@ClearSendMessage);
  end;
end;

procedure TTelnetThread.OnDataAvailable(Sender: TIdTelnet; const Buffer: TIdBytes);
begin
  dxClientRecord.Message := BytesToString(Buffer, IndyTextEncoding_UTF8);
  if Length(dxClientRecord.Message) > 0 then
    Synchronize(@ToForm);
end;

procedure TTelnetThread.OnStatus(ASender: TObject; const AStatus: TIdStatus;
  const AStatusText: string);
begin
  if AStatus = hsConnected then
  begin
    dxClientRecord.Connected := True;
    Synchronize(@ToForm);
    exit;
  end;
  if AStatus = hsDisconnected then
  begin
    dxClientRecord.Connected := False;
    Synchronize(@ToForm);
    exit;
  end;
end;

constructor TTelnetThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
  DXTelnetClient := nil;
  DXTelnetClient := TIdTelnet.Create;
  dxClientRecord.Connected := False;
  dxClientRecord.Message := '';
end;

destructor TTelnetThread.Destroy;
begin
  FreeAndNil(DXTelnetClient);
  inherited Destroy;
  TelnetThread := nil;
end;

procedure TTelnetThread.ToForm;
begin
  dxClusterForm.FromClusterThread(dxClientRecord);
  dxClientRecord.Message := '';
end;

procedure TTelnetThread.ClearSendMessage;
begin
  dxClusterForm.SendMessageString := '';
end;

function TTelnetThread.ConnectToCluster: boolean;
begin
  try
    Result := True;
    DXTelnetClient.OnDataAvailable := @OnDataAvailable;
    DXTelnetClient.OnStatus := @OnStatus;
    DXTelnetClient.Host := IniSet.Cluster_Host;
    DXTelnetClient.Port := StrToInt(IniSet.Cluster_Port);
    DXTelnetClient.Connect;
  except
    on E: Exception do
    begin
      Result := False;
      WriteLn(ExceptFile, 'TTelnetThread.ConnectToCluster:' + E.ClassName +
        ':' + E.Message);
    end;
  end;
end;

procedure TTelnetThread.Execute;
begin
  if not ConnectToCluster then
  begin
    FreeAndNil(DXTelnetClient);
    Exit;
  end;
  while not Terminated do
  begin
    SendMessage(dxClusterForm.SendMessageString);
    sleep(100);
  end;
end;

end.
