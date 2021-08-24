(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit hiddentsettings_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  const_u;

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
