unit ClusterFilter_Form_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TClusterFilter }

  TClusterFilter = class(TForm)
    cb160m: TCheckBox;
    cb80m: TCheckBox;
    cb6m: TCheckBox;
    cb4m: TCheckBox;
    cb2m: TCheckBox;
    cb70cm: TCheckBox;
    cb60m: TCheckBox;
    cb40m: TCheckBox;
    cb30m: TCheckBox;
    cb20m: TCheckBox;
    cb17m: TCheckBox;
    cb15m: TCheckBox;
    cb12m: TCheckBox;
    cb10m: TCheckBox;
    cbSSB: TCheckBox;
    cbCW: TCheckBox;
    cbData: TCheckBox;
    cbAllModes: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  ClusterFilter: TClusterFilter;

implementation

{$R *.lfm}

end.

