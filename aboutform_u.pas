(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit AboutForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TAbout_Form }

  TAbout_Form = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public

    { public declarations }
  end;

var
  About_Form: TAbout_Form;

implementation
uses
  dmFunc_U;

{$R *.lfm}

{ TAbout_Form }

procedure TAbout_Form.FormShow(Sender: TObject);
begin
  Label5.Caption := dmFunc.GetMyVersion;
end;

end.
