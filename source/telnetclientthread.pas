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
  Classes, SysUtils, ssl_openssl, lNetComponents, lNet;

type
  TTelnetThread = class(TThread)
  protected
    procedure Execute; override;
  private
    procedure OnReceiveDX(aSocket: TLSocket);
    procedure OnErrorDX(const msg: string; aSocket: TLSocket);
    procedure OnConnectDX(aSocket: TLSocket);
    procedure OnDisconnectDX(aSocket: TLSocket);
    function ConnectToCluster: boolean;

  public
    constructor Create;
    destructor Destroy; override;
    procedure ToForm;
  end;

var
  TelnetThread: TTelnetThread;
  DXTelnetClient: TLTelnetClientComponent;
  TelnetLine: string;
  ConnectCluster: boolean;

implementation

uses MainFuncDM, dxclusterform_u;

procedure TTelnetThread.OnConnectDX(aSocket: TLSocket);
begin
  ConnectCluster := True;
  Synchronize(@ToForm);
end;

procedure TTelnetThread.OnDisconnectDX(aSocket: TLSocket);
begin
  ConnectCluster := False;
  TelnetLine := 'DX Cluster disconnected';
  Synchronize(@ToForm);
  TelnetThread.Destroy;
end;

procedure TTelnetThread.OnReceiveDX(aSocket: TLSocket);
begin
  if DXTelnetClient.GetMessage(TelnetLine) = 0 then
    exit;
  Synchronize(@ToForm);
end;

procedure TTelnetThread.OnErrorDX(const msg: string; aSocket: TLSocket);
begin
  TelnetLine := msg;
  ConnectCluster := False;
  Synchronize(@ToForm);
  TelnetLine := 'DX Cluster disconnected';
  Synchronize(@ToForm);
  TelnetThread.Destroy;
end;

constructor TTelnetThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
  DXTelnetClient := nil;
  DXTelnetClient := TLTelnetClientComponent.Create(nil);
end;

destructor TTelnetThread.Destroy;
begin
  FreeAndNil(DXTelnetClient);
  inherited Destroy;
  TelnetThread := nil;
end;

procedure TTelnetThread.ToForm;
begin
  dxClusterForm.FromClusterThread(TelnetLine);
end;

function TTelnetThread.ConnectToCluster: boolean;
begin
  Result := True;
  ConnectCluster := False;
  try
    DXTelnetClient.OnReceive := @OnReceiveDX;
    DXTelnetClient.OnError := @OnErrorDX;
    DXTelnetClient.OnConnect := @OnConnectDX;
    DXTelnetClient.OnDisconnect := @OnDisconnectDX;
    DXTelnetClient.Host := IniSet.Cluster_Host;
    DXTelnetClient.Port := StrToInt(IniSet.Cluster_Port);
    DXTelnetClient.Connect;
    DXTelnetClient.CallAction;
  except
    on E: Exception do
    begin
      ConnectCluster := False;
      Result := False;
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
    sleep(100);
  end;
end;

end.
