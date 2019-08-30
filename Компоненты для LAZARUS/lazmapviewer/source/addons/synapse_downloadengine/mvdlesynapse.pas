{ Map Viewer Download Engine Synapse

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
  Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.
}
unit mvDLESynapse;

{$mode objfpc}{$H+}

interface

uses
  mvDownloadEngine, SysUtils, Classes, ssl_openssl, httpsend;

type

  { TMvDESynapse }

  TMvDESynapse = class(TMvCustomDownloadEngine)
  private
    FProxyHost: string;
    FProxyPassword: string;
    FProxyPort: Integer;
    FProxyUsername: string;
    FUseProxy: Boolean;
  public
    procedure DownloadFile(const Url: string; str: TStream); override;

  published
    property UseProxy: Boolean read FUseProxy write FUseProxy default false;
    property ProxyHost: string read FProxyHost write FProxyHost;
    property ProxyPort: Integer read FProxyPort write FProxyPort default 0;
    property ProxyUsername: string read FProxyUsername write FProxyUsername;
    property ProxyPassword: string read FProxyPassword write FProxyPassword;
  end;

procedure Register;

implementation

uses
  mvTypes;

procedure Register;
begin
  RegisterComponents(PALETTE_PAGE, [TMvDESynapse]);
end;


{ TMvDESynapse }

procedure TMvDESynapse.DownloadFile(const Url: string; str: TStream);
var
  FHttp: THTTPSend;
  realURL: String;
  i: Integer;
begin
  FHttp := THTTPSend.Create;
  try
    if FUseProxy then
    begin
      FHTTP.ProxyHost := FProxyHost;
      FHTTP.ProxyPort := IntToStr(FProxyPort);
      FHTTP.ProxyUser := FProxyUsername;
      FHTTP.ProxyPass := FProxyPassword;
    end;

    if FHTTP.HTTPMethod('GET', Url) then
    begin
      // If its a 301 or 302 we need to do more processing
      if (FHTTP.ResultCode = 301) or (FHTTP.ResultCode = 302) then
      begin
        // Check the headers for the Location header
        for i := 0 to FHTTP.Headers.Count -1 do
        begin
          // Extract the URL
          if Copy(FHTTP.Headers[i], 1, 8) = 'Location' then
            realURL := copy(FHTTP.Headers[i], 11, Length(FHTTP.Headers[i]) - 10); //11);
        end;
        // If we have a URL, run it through the same function
        if Length(realURL) > 1 then
          DownloadFile(realURL, str);
      end
      else
      begin
        str.Seek(0, soFromBeginning);
        str.CopyFrom(FHTTP.Document, 0);
        str.Position := 0;
      end;
    end;
  finally
    FHttp.Free;
  end;
end;

end.
