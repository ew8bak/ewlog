unit MainForm_U;

{$mode objfpc}{$H+}

interface

uses
  Forms, ExtCtrls, Classes, Controls;

type
  { TMainForm }

  TMainForm = class(TForm)
    LeftPanel: TPanel;
    AllClientPanel: TPanel;
    GridsPanel: TPanel;
    ClusterPanel: TPanel;
    EarthPanel: TPanel;
    MiniPanel: TPanel;
    OtherPanel: TPanel;
  private
    { private declarations }

  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

end.
