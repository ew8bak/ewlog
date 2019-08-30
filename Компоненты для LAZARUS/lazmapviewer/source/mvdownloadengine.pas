{ Map Viewer Download Engine

  Copyright (C) 2011 Maciej Kaczkowski / keit.co

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
unit mvDownloadEngine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TMvCustomDownloadEngine }

  TMvCustomDownloadEngine = class(TComponent)
  public
    procedure DownloadFile(const {%H-}Url: string; {%H-}AStream: TStream); virtual;
  end;


implementation

{ TMvCustomDownloadEngine }

procedure TMvCustomDownloadEngine.DownloadFile(const Url: string; AStream: TStream);
begin
  // to be overridden...
end;

end.

