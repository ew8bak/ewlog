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
    procedure ToForm;
  end;

var
  TelnetThread: TTelnetThread;
  DXTelnetClient: TLTelnetClientComponent;
  TelnetLine: string;
  ConnectCluster: boolean;

implementation

uses MainFuncDM, MainForm_U, dxclusterform_u;

procedure TTelnetThread.OnConnectDX(aSocket: TLSocket);
begin
  ConnectCluster := True;
  Synchronize(@ToForm);
end;

procedure TTelnetThread.OnDisconnectDX(aSocket: TLSocket);
begin
  ConnectCluster := False;
  Synchronize(@ToForm);
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
  Synchronize(@ToForm);
end;

constructor TTelnetThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TTelnetThread.ToForm;
begin
  dxClusterForm.FromClusterThread(TelnetLine);
  if ConnectCluster then
    dxClusterForm.SpeedButton1.Enabled := False;
end;

function TTelnetThread.ConnectToCluster: boolean;
begin
  Result := True;
  ConnectCluster := False;
  try
    DXTelnetClient := nil;
    DXTelnetClient := TLTelnetClientComponent.Create(nil);
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
end;

end.