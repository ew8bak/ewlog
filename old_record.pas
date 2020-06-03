unit old_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TOldQSOR = record
    Num: string;
    Date: string[12];
    Time: string[5];
    Frequency : string[15];
    Mode: string[5];
    Name: string[30];
  end;

implementation

end.
