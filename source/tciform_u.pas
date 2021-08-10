unit TCIForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  syWebSocketServer, syconnectedclient, sywebsocketframe, sywebsocketclient,
  lclintf, StdCtrls, sywebsocketcommon;

type

  { TTCIForm }

  TTCIForm = class(TForm)
    btnClientStart: TButton;
    btnClientStop: TButton;
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Memo1: TMemo;
    procedure btnClientStartClick(Sender: TObject);
    procedure btnClientStopClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FWebSocket: TsyWebSocketServer;
    FwsClient: TsyWebsocketClient;
    procedure OnClientMessage(Sender: TObject);
    procedure OnClientTerminate(Sender: TObject);

  public

  end;

var
  TCIForm: TTCIForm;

implementation

{$R *.lfm}

{ TTCIForm }

procedure TTCIForm.btnClientStartClick(Sender: TObject);
begin
 FwsClient := TsyWebsocketClient.Create(edit1.Text, StrToInt64Def(Edit2.Text, 8080));
  FwsClient.OnMessage := @OnClientMessage;
  FwsClient.OnTerminate := @OnClientTerminate;
  FwsClient.Start;
  btnClientStart.Enabled := False;
  btnClientStop.Enabled := True;
end;

procedure TTCIForm.btnClientStopClick(Sender: TObject);
begin
   if assigned(FwsClient) then
    FwsClient.TerminateThread;
  FwsClient := nil;
  btnClientStop.Enabled := False;
  btnClientStart.Enabled := True;
end;

procedure TTCIForm.Button1Click(Sender: TObject);
begin
    FwsClient.SendMessage(Edit3.Text);
end;

procedure TTCIForm.OnClientMessage(Sender: TObject);
var
  val: TMessageRecord;
begin
  if not Assigned(FwsClient) then
    exit;
  while FwsClient.MessageQueue.TotalItemsPushed <> FwsClient.MessageQueue.TotalItemsPopped do
  begin
    FwsClient.MessageQueue.PopItem(val);
    Memo1.Lines.Add(val.Message);
  end;
end;

procedure TTCIForm.OnClientTerminate(Sender: TObject);
begin
  Memo1.Lines.Add('Terminated');
 btnClientStopClick(self);
end;


end.
