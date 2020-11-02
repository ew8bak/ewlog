unit hiddentsettings_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  httpsend, ssl_openssl, const_u;

type

  { ThiddenSettings }

  ThiddenSettings = class(TForm)
  private

  public

  end;

var
  hiddenSettings: ThiddenSettings;


implementation

uses
  miniform_u, dmFunc_U, InitDB_dm;

{$R *.lfm}


{ ThiddenSettings }

end.
