unit GetPhotoFromInternet;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes, SysUtils, LazFileUtils, LazUTF8, ssl_openssl;

type
  TGetPhotoThread = class(TThread)
  protected
    procedure Execute; override;
    procedure GetPhoto(url: string);
  private
     PhotoStream: TMemoryStream;
  public
    url: string;
    Call: string;
    Main: Boolean;
    constructor Create;
    procedure ResultProc;
  end;

var
  GetPhotoThread: TGetPhotoThread;

implementation

uses Forms, LCLType, HTTPSend, MainForm_U, InformationForm_U, dmFunc_U;

procedure TGetPhotoThread.GetPhoto(url: string);
begin
  try
     PhotoStream:=TMemoryStream.Create;
     with THTTPSend.Create do
    begin
      if HTTPMethod('GET', url) then
      begin
        PhotoStream.LoadFromStream(Document);
      end;
      Free;
    end;

  finally
  Synchronize(@ResultProc);
  end;
end;

constructor TGetPhotoThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TGetPhotoThread.ResultProc;
begin
  InformationForm.ViewPhoto(PhotoStream,url,call, Main);
  PhotoStream.Free;
end;

procedure TGetPhotoThread.Execute;
begin
  GetPhoto(url);
end;

end.
