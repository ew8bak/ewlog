unit print_sticker_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin;

type

  { TPrintSticker_Form }

  TPrintSticker_Form = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    SpinEdit1: TSpinEdit;
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  PrintSticker_Form: TPrintSticker_Form;

implementation

{$R *.lfm}

{ TPrintSticker_Form }

procedure TPrintSticker_Form.FormShow(Sender: TObject);
begin
  ComboBox1.Clear;
  ComboBox1.Style := csDropDown;
  ComboBox1.Items.Assign(Screen.Fonts);

end;

end.

