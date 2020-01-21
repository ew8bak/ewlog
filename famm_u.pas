unit famm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Variants;

type

  { TFM_Form }

  TFM_Form = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    FMQuery: TSQLQuery;
    GroupBox1: TGroupBox;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    LabeledEdit4: TLabeledEdit;
    LabeledEdit5: TLabeledEdit;
    LabeledEdit6: TLabeledEdit;
    ListView1: TListView;
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
  private
    procedure ReloadList;

  public

  end;

var
  FM_Form: TFM_Form;

implementation

{$R *.lfm}
uses dmFunc_U, MainForm_U;

{ TFM_Form }

procedure TFM_Form.ReloadList;
var
  ListItem: TListItem;
begin
  try
    FMQuery.DataBase := MainForm.ServiceDBConnection;

    ListView1.Clear;
    FMQuery.SQL.Text := ('SELECT * FROM Bands');
    FMQuery.Open;
    while (not FMQuery.EOF) do
    begin
      ListItem := ListView1.Items.Add;
      ListItem.Caption := VarToStr(FMQuery['band']);
      with ListItem.SubItems do
      begin
        Add(VarToStr(FMQuery['b_begin']));
        Add(VarToStr(FMQuery['b_end']));
        Add(VarToStr(FMQuery['enable']));
      end;
      FMQuery.Next;
    end;
    FMQuery.Close;
  finally
  end;
end;

procedure TFM_Form.FormShow(Sender: TObject);
begin
  ReloadList;
end;

procedure TFM_Form.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TFM_Form.CheckBox1Click(Sender: TObject);
var
  SelectIndex: integer;
begin
  if Assigned(ListView1.Selected) then
  begin
    FMQuery.SQL.Text := ('UPDATE Bands SET Enable = ' +
      BoolToStr(CheckBox1.Checked, '1', '0') + ' WHERE band = ' +
      QuotedStr(ListView1.Selected.Caption));
    SelectIndex := ListView1.ItemIndex;
    FMQuery.ExecSQL;
    FMQuery.SQLTransaction.Commit;
    ReloadList;
    ListView1.ItemIndex := SelectIndex;
  end;
end;

procedure TFM_Form.ListView1Click(Sender: TObject);
begin
  if ListView1.Selected.Selected then
  begin
    FMQuery.SQL.Text := ('SELECT * FROM Bands WHERE band = ' + QuotedStr(
      ListView1.Selected.Caption));
    FMQuery.Open;
    LabeledEdit1.Text := FMQuery['band'];
    LabeledEdit2.Text := FMQuery['b_begin'];
    LabeledEdit3.Text := FMQuery['b_end'];
    LabeledEdit4.Text := FMQuery['cw'];
    LabeledEdit5.Text := FMQuery['digi'];
    LabeledEdit6.Text := FMQuery['ssb'];
    CheckBox1.Checked := FMQuery['enable'];
    FMQuery.Close;
  end;
end;

end.
