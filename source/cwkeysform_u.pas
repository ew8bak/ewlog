unit CWKeysForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TCWKeysForm }

  TCWKeysForm = class(TForm)
    BtF1: TButton;
    BtF10: TButton;
    BtF2: TButton;
    BtF3: TButton;
    BtF4: TButton;
    BtF5: TButton;
    BtF6: TButton;
    BtF7: TButton;
    BtF8: TButton;
    BtF9: TButton;
    procedure BtF1Click(Sender: TObject);
  private

  public

  end;

var
  CWKeysForm: TCWKeysForm;

implementation
uses CWDaemonDM_u;

{$R *.lfm}

{ TCWKeysForm }

procedure TCWKeysForm.BtF1Click(Sender: TObject);
begin
  CWDaemonDM.SendTextCWDaemon('CQ CQ CQ DE EW8BAK');
end;

end.

