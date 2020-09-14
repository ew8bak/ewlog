unit MapForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, mvMapViewer, mvTypes;

type

  { TMapForm }

  TMapForm = class(TForm)
    MapView: TMapView;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
    procedure WriteMap(Latitude, Longitude: string; Zoom: integer);

  end;

var
  MapForm: TMapForm;

implementation

{$R *.lfm}
uses MainFuncDM, InitDB_dm;

procedure TMapForm.FormCreate(Sender: TObject);
begin
  MapView.CachePath := FilePATH + 'cache' + DirectorySeparator;
  MapView.DoubleBuffered := True;
end;

procedure TMapForm.FormShow(Sender: TObject);
begin
  MapView.Active:=True;
  WriteMap('0', '0', 1);
end;

procedure TMapForm.WriteMap(Latitude, Longitude: string; Zoom: integer);
var
  Center: TRealPoint;
begin
  if Zoom > 1 then
    MainFunc.LoadMaps(Latitude, Longitude, MapView)
  else
  begin
    MapView.ClearBuffer;
    Center.Lat := 0;
    Center.Lon := 0;
    MapView.Center := Center;
    MapView.Zoom := Zoom;
  end;
end;

end.
