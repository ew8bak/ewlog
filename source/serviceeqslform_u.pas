unit ServiceEqslForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  DBGrids, EditBtn, Buttons, StdCtrls;

type

  { TServiceEqslForm }

  TServiceEqslForm = class(TForm)
    Bevel3: TBevel;
    Bevel4: TBevel;
    BtConnecteQSL: TButton;
    Button1: TButton;
    DBGrid1: TDBGrid;
    DEeQSLcc: TDateEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LBCurrError: TLabel;
    LBCurrStatus: TLabel;
    LBDownload: TLabel;
    LBDownloadSize: TLabel;
    LBErrors: TLabel;
    LBProcessed: TLabel;
    LBStatus: TLabel;
    PageControl1: TPageControl;
    PBDownload: TProgressBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  ServiceEqslForm: TServiceEqslForm;

implementation

{$R *.lfm}

{ TServiceEqslForm }

procedure TServiceEqslForm.Button1Click(Sender: TObject);
begin
 // OpenDialog1.Execute;
 // if OpenDialog1.FileName <> '' then
 //   eQSLImport(OpenDialog1.FileName);
end;

end.

