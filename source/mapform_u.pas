(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit MapForm_u;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, mvMapViewer, mvTypes;

type

  { TMapForm }

  TMapForm = class(TForm)
    MapView: TMapView;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
    procedure WriteMap(Latitude, Longitude: string; Zoom: integer);
    procedure SavePosition;

  end;

var
  MapForm: TMapForm;

implementation

{$R *.lfm}
uses MainFuncDM, InitDB_dm, miniform_u;

procedure TMapForm.SavePosition;
begin
 MainFunc.SaveWindowPosition(MapForm);
end;

procedure TMapForm.FormCreate(Sender: TObject);
begin
  MapView.CachePath := FilePATH + 'cache' + DirectorySeparator;
  MapView.DoubleBuffered := True;
end;

procedure TMapForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  MiniForm.CheckFormMenu('MapForm', False);
{  if Application.MessageBox(PChar(rShowNextStart), PChar(rWarning),
    MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
    INIFile.WriteBool('SetLog', 'eShow', True)
  else
    INIFile.WriteBool('SetLog', 'eShow', False);

  IniSet.eShow := False;
  CloseAction := caFree; }
end;

procedure TMapForm.FormShow(Sender: TObject);
begin
  MainFunc.LoadWindowPosition(MapForm);
  MapView.Active := True;
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
    //  MapView.ClearBuffer;
    Center.Lat := 0;
    Center.Lon := 0;
    MapView.Center := Center;
    MapView.Zoom := Zoom;
  end;
end;

end.
