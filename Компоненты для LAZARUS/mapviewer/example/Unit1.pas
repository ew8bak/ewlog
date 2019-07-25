unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, kcMapViewer, kcMapViewerGLGeoNames
  {$IFDEF WIN32}, kcMapViewerDEWin32{$ELSE}, kcMapViewerDESynapse{$ENDIF WIN32};

type

  { TForm1 }

  TForm1 = class(TForm)
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    mv: TMapViewer;
    MVGLGeoNames1: TMVGLGeoNames;
    Panel1: TPanel;
    TrackBar1: TTrackBar;
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormDblClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private
    FDownloader: TCustomDownloadEngine;
    procedure DoBeforeDownload(Url: string; str: TStream; var CanHandle: Boolean);
    procedure DoAfterDownload(Url: string; str: TStream);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  md5;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  p: TIntPoint;
  r: TRealPoint;
begin
  p := mv.GetMouseMapPixel(X, Y);
  Label2.Caption := Format('Pixel: %d:%d', [p.X, p.Y]);
  p := mv.GetMouseMapTile(X, Y);
  Label3.Caption := Format('Tile: %d:%d', [p.X, p.Y]);
  r := mv.GetMouseMapLongLat(X, Y);
  Label4.Caption := Format('Long: %g', [r.X]);
  Label5.Caption := Format('Lat: %g', [r.Y]);

  r := mv.CenterLongLat;
  Label6.Caption := Format('Long: %g', [r.X]);
  Label7.Caption := Format('Lat: %g', [r.Y]);
end;

procedure TForm1.FormDblClick(Sender: TObject);
begin
  TrackBar1.Position := mv.Zoom;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  if Sender = TrackBar1 then
    mv.Zoom := TrackBar1.Position;
end;

procedure TForm1.DoBeforeDownload(Url: string; str: TStream;
  var CanHandle: Boolean);
var
  x: string;
  f: TFileStream;
begin
  x := 'cache\'+MDPrint(MD5String(Url));
  if FileExists(x) then
  begin
    f := TFileStream.Create(x, fmOpenRead);
    try
      str.Position := 0;
      str.CopyFrom(f, f.Size);
      str.Position := 0;
      CanHandle := True;
    finally
      f.Free;
    end;
  end
  else
    CanHandle := False;
end;

procedure TForm1.DoAfterDownload(Url: string; str: TStream);
var
  x: string;
  f: TFileStream;
begin
  if not DirectoryExists('cache') then
    ForceDirectories('cache');
  x := 'cache\'+MDPrint(MD5String(Url));
  if (not FileExists(x)) and (not (str.Size = 0)) then
  begin
    f := TFileStream.Create(x, fmCreate);
    try
      str.Position := 0;
      f.CopyFrom(str, str.Size);
    finally
      f.Free;
    end;
  end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  mv.Source := TMapSource(ComboBox1.ItemIndex);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  {$IFDEF WIN32}
  FDownloader := TMVDEWin32.Create(Self);
  {$ELSE}
  FDownloader := TMVDESynapse.Create(Self);
  {$ENDIF WIN32}

  FDownloader.OnAfterDownload := @DoAfterDownload;
  FDownloader.OnBeforeDownload := @DoBeforeDownload;
  mv.DownloadEngine := FDownloader;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FDownloader.Free
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  mv.Debug := CheckBox1.Checked;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  mv.BeginUpdate;
  MVGLGeoNames1.LocationName := Edit1.Text;
  mv.Zoom := 12;
  TrackBar1.Position := mv.Zoom;
  mv.Geolocate;
  mv.EndUpdate;
end;

procedure TForm1.CheckBox2Change(Sender: TObject);
begin
  mv.UseThreads := CheckBox2.Checked;
end;

procedure TForm1.CheckBox3Change(Sender: TObject);
begin
  mv.DoubleBuffering:=CheckBox3.Checked;
end;

end.
