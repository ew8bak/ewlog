unit MapForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, mvMapViewer, mvTypes,
  LCLType, ResourceStr;

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
uses MainFuncDM, InitDB_dm;

procedure TMapForm.SavePosition;
begin
  if IniSet.MainForm = 'MULTI' then
    if MapForm.WindowState <> wsMaximized then
    begin
      INIFile.WriteInteger('SetLog', 'eLeft', MapForm.Left);
      INIFile.WriteInteger('SetLog', 'eTop', MapForm.Top);
      INIFile.WriteInteger('SetLog', 'eWidth', MapForm.Width);
      INIFile.WriteInteger('SetLog', 'eHeight', MapForm.Height);
    end;
end;

procedure TMapForm.FormCreate(Sender: TObject);
begin
  MapView.CachePath := FilePATH + 'cache' + DirectorySeparator;
  MapView.DoubleBuffered := True;
end;

procedure TMapForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
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
  if (IniSet.MainForm = 'MULTI') and IniSet.eShow then
    if (IniSet._l_e <> 0) and (IniSet._t_e <> 0) and (IniSet._w_e <> 0) and
      (IniSet._h_e <> 0) then
      MapForm.SetBounds(IniSet._l_e, IniSet._t_e, IniSet._w_e, IniSet._h_e);
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
