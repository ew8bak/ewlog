(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit selectQSO_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TSelQSOR = record
    QSODate: string;
    QSOTime: string;
    QSOBand: string;
    QSOMode: string;
    OMName: string;
    NumSelectQSO: integer;
  end;

implementation

end.
