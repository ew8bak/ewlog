(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit inform_record;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics;

type
  TInformRecord = record
    System: string;
    user: string;
    password: string;
    sessionid: string;
    Callsign: string;
    Country: string;
    Name: string;
    SurName: string;
    Address: string;
    City: string;
    Grid: string;
    HomePage: string;
    State: string;
    Telephone: string;
    eMail: string;
    icq: string;
    qslVia: string;
    PhotoURL: string;
    Error: string;
    ErrorCode: string;
    Sender: string;
    PhotoJPEG: TJPEGImage;
    PhotoGIF: TGIFImage;
    PhotoPNG: TPortableNetworkGraphic;
  end;

implementation

end.
