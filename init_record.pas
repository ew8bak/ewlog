unit init_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TInitRecord = record
    ServiceDBInit: boolean;
    InitDBINI: boolean;
    LogbookDBInit: boolean;
    InitPrefix: boolean;
    GetLogBookTable: boolean;
    SelectLogbookTable: boolean;
    LoadINIsettings: boolean;
  end;

implementation

end.
