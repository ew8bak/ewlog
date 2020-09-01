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

  end;

var
  InfoDM: TInfoDM;

implementation

{$R *.lfm}

end.

