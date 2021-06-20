unit DownloadADIThread;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, Dialogs, LazUTF8, ssl_openssl, httpsend;

type
  TDownADIThread = class(TThread)
  private
    fStatusText: string;
    procedure ShowStatus;
  protected
    procedure Execute; override;
    procedure DownFile(URL: string; FilePath:TStream);
  public
    DownURL: string;
    LoadFile: TStream;
    constructor Create;
  end;
  var
  DownADIThread: TDownADIThread;

implementation

constructor TDownADIThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TDownADIThread.DownFile(URL: string; FilePath:TStream);
var
  LoadFilea: TFileStream;
begin
    LoadFilea := TFileStream.Create(GetEnvironmentVariable('HOME') +
        '/EWLog/LotW_' + '.adi', fmCreate);
 HttpGetBinary(URL,LoadFilea);
end;

procedure TDownADIThread.ShowStatus;
begin
  // Form1.Caption := fStatusText;
end;

procedure TDownADIThread.Execute;
var
  newStatus: string;
begin
 DownFile(DownURL, LoadFile);
 // fStatusText := 'TMyThread Starting...';
 // Synchronize(@Showstatus);
 // fStatusText := 'TMyThread Running...';
end;

end.

