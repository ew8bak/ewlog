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
    PhotoJPEG: TJPEGImage;
    PhotoGIF: TGIFImage;
    PhotoPNG: TPortableNetworkGraphic;
  end;

implementation

end.
