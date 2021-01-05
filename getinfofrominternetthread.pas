(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit GetInfoFromInternetThread;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes, SysUtils, LazFileUtils, LazUTF8, ssl_openssl, httpsend;

type
  TGetInfoThread = class(TThread)
  protected
    procedure Execute; override;
    function GetInfo(url: string): Boolean;
  private
    resp: String;
  public
    url: string;
    constructor Create;
    procedure ResultProc;
  end;

var
  GetInfoThread: TGetInfoThread;

implementation
uses
infoDM_U;

function TGetInfoThread.GetInfo(url: string): Boolean;
begin
  Result:=False;
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
   Result:=True;
  end;
end;

constructor TGetInfoThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TGetInfoThread.ResultProc;
begin
  InfoDM.GetResponseFromThread(resp);
end;

procedure TGetInfoThread.Execute;
begin
  if GetInfo(url) then Synchronize(@ResultProc);
end;

end.
