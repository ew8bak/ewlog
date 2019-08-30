{
  (c) 2014 ti_dic
  Parts of this component are based on :
    Map Viewer Copyright (C) 2011 Maciej Kaczkowski / keit.co

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

unit mvTypes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  TILE_SIZE = 256;
  PALETTE_PAGE = 'Misc';

Type
    { TArea }
  TArea = record
    top, left, bottom, right: Int64;
  end;

  { TRealPoint }
  TRealPoint = Record
    Lon : Double;
    Lat : Double;
  end;

  { TRealArea }
  TRealArea = Record
    TopLeft : TRealPoint;
    BottomRight : TRealPoint;
  end;

implementation

end.

