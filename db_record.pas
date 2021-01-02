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
    DefaultDB: string[7];
    CurrentDB: string[7];
    MySQLHost: string;
    MySQLPort: integer;
    MySQLUser: string;
    MySQLPass: string;
    MySQLDBName: string;
    SQLitePATH: string;
    InitDB: string[3];
    DefCall: string;
    CurrCall: string;
    Connected: Boolean;
  end;

implementation

end.
