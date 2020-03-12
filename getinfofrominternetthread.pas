unit GetInfoFromInternetThread;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes, SysUtils, LazFileUtils, LazUTF8, ssl_openssl;

type
  TGetInfoThread = class(TThread)
  protected
    procedure Execute; override;
    procedure GetInfo(url: string);
  private
    resp: String;
  public
    url: string;
    from: string;
    constructor Create;
    procedure ResultProc;
  end;

var
  GetInfoThread: TGetInfoThread;

implementation

uses Forms, LCLType, HTTPSend, MainForm_U, InformationForm_U, dmFunc_U;

procedure TGetInfoThread.GetInfo(url: string);
begin
  try
   with THTTPSend.Create do
    begin
      if HTTPMethod('GET', url) then
      begin
        SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
      end;
      Free;
    end;

  finally
  Synchronize(@ResultProc);
  end;
end;

constructor TGetInfoThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TGetInfoThread.ResultProc;
begin
  InformationForm.GetInfoFromThread(resp, from);
end;

procedure TGetInfoThread.Execute;
begin
  GetInfo(url);
end;

end.
