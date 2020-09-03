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

