program Project1;

uses
  Forms,
  Interfaces,
  sysutils,
  Unit1 in 'Unit1.pas' {Form1},
  kcMapViewer in 'kcMapViewer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
