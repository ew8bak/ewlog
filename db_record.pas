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
    Connected: Boolean;
  end;

implementation

end.
