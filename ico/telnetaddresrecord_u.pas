unit telnetaddresrecord_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TTelnetAddressRecord = record
    Name: string;
    Address: string;
    Port: integer;
  end;

implementation

end.

