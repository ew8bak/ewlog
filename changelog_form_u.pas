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
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TChangeLog_Form }

  TChangeLog_Form = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure Button1Click(Sender: TObject);
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

procedure TChangeLog_Form.Button1Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
  ChangeLog_Form.Close;
end;

procedure TChangeLog_Form.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  Memo1.Lines.Clear;
end;

end.

