(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

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
