(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit Changelog_Form_U;

{$mode objfpc}{$H+}

interface

uses
  Forms, Controls, ExtCtrls,
  StdCtrls;

type

  { TChangeLog_Form }

  TChangeLog_Form = class(TForm)
    BtOK: TButton;
    MChangeLog: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure BtOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  ChangeLog_Form: TChangeLog_Form;

implementation

{$R *.lfm}

{ TChangeLog_Form }

procedure TChangeLog_Form.BtOKClick(Sender: TObject);
begin
  MChangeLog.Lines.Clear;
  ChangeLog_Form.Close;
end;

procedure TChangeLog_Form.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  MChangeLog.Lines.Clear;
end;

end.

