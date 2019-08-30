{ Map Viewer Download Engine Free Pascal HTTP Client

  Copyright (C) 2011 Maciej Kaczkowski / keit.co

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

  Taken from:
  https://forum.lazarus.freepascal.org/index.php/topic,12674.msg160255.html#msg160255

}

unit mvDLEFpc;

{$mode objfpc}{$H+}

{.$DEFINE LOG_URL}

interface

uses
  SysUtils, Classes,
  mvDownloadEngine;

type

  { TMVDEFPC }

  TMVDEFPC = class(TMvCustomDownloadEngine)
  {$IF FPC_FullVersion >= 30101}
  private
    FUseProxy: Boolean;
    FProxyHost: string;
    FProxyPort: Word;
    FProxyUserName: String;
    FProxyPassWord: String;
  {$IFEND}
  public
    procedure DownloadFile(const Url: string; AStream: TStream); override;
  {$IF FPC_FullVersion >= 30101}
  published
    property UseProxy: Boolean read FUseProxy write FUseProxy default false;
    property ProxyHost: String read FProxyHost write FProxyHost;
    property ProxyPort: Word read FProxyPort write FProxyPort;
    property ProxyUsername: String read FProxyUserName write FProxyUserName;
    property ProxyPassword: String read FProxyPassword write FProxyPassword;
  {$IFEND}
  end;


implementation

uses
  {$IFDEF LOG_URL}
  lazlogger,
  {$ENDIF}
  fphttpclient, openssl;

{ TMVDEFPC }

procedure TMVDEFPC.DownloadFile(const Url: string; AStream: TStream);
var
  http: TFpHttpClient;
begin
  {$IFDEF LOG_URL}
  DebugLn(Url);
  {$ENDIF}
  InitSSLInterface;
  http := TFpHttpClient.Create(nil);
  try
   {$IF FPC_FullVersion >= 30000}
    http.AllowRedirect := true;
   {$IFEND}
    http.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
   {$IF FPC_FullVersion >= 30101}
    if UseProxy then begin
      http.Proxy.Host := FProxyHost;
      http.Proxy.Port := FProxyPort;
      http.Proxy.UserName := FProxyUserName;
      http.Proxy.Password := FProxyPassword;
    end;
   {$ENDIF}
    try
      http.Get(Url, AStream);
    except
    end;
    AStream.Position := 0;
  finally
    http.Free;
  end;
end;

end.
