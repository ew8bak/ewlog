(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit DB_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TDBRecord = record
    SQLitePATH: string;
    InitDB: string[3];
    CurrentLogTable: string;
    DefaultLogTable: string;
    CurrentCall: string;

  end;

implementation

end.
