(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit ImbedCallBookCheckRec;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TImbedCallBookCheckRec = record
    ReleaseDate: string;
    Version: string;
    NumberOfRec: Integer;
    Found: boolean;
  end;

implementation

end.

