unit infoDM_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, openssl, httpsend, Graphics, inform_record;

type
  TInfoDM = class(TDataModule)
  private
    procedure GetSession;

  public
    InfoR:TInformRecord;

  end;

var
  InfoDM: TInfoDM;

implementation

uses
  getSessionID, GetPhotoFromInternet, GetInfoFromInternetThread, MainFuncDM;

{$R *.lfm}

procedure TInfoDM.GetSession;
begin
  GetSessionThread := TGetSessionThread.Create;
  if Assigned(GetSessionThread.FatalException) then
    raise GetSessionThread.FatalException;
  with GetSessionThread do
  begin
    qrzcom_login := IniSet.QRZCOM_Login;
    qrzcom_pass := IniSet.QRZCOM_Pass;
    qrzru_login := IniSet.QRZRU_Login;
    qrzru_pass := IniSet.QRZRU_Pass;
    Start;
  end;
end;

end.
