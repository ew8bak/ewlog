unit mmform_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, DB, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, DBCtrls, variants;

type

  { TMM_Form }

  TMM_Form = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    GroupBox1: TGroupBox;
    LabeledEdit1: TLabeledEdit;
    ListView1: TListView;
    MMQuery: TSQLQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
  private
    procedure ReloadList;

  public

  end;

var
  MM_Form: TMM_Form;

implementation

{$R *.lfm}
uses dmFunc_U, MainForm_U;

{ TMM_Form }

procedure TMM_Form.ReloadList;
var
  ListItem: TListItem;
begin
  try
    MMQuery.DataBase := MainForm.ServiceDBConnection;

    ListView1.Clear;
    MMQuery.SQL.Text := ('SELECT * FROM Modes');
    MMQuery.Open;
    while (not MMQuery.EOF) do
    begin
      ListItem := ListView1.Items.Add;
      ListItem.Caption := VarToStr(MMQuery['mode']);
      with ListItem.SubItems do
      begin
        Add(VarToStr(MMQuery['enable']));
      end;
      MMQuery.Next;
    end;
    MMQuery.Close;
  finally
  end;
end;

procedure TMM_Form.FormShow(Sender: TObject);
begin
  if Length(LabeledEdit1.Text) = 0 then
    LabeledEdit1.Text := 'none';
  ReloadList;
end;

procedure TMM_Form.CheckBox1Click(Sender: TObject);
var
  SelectIndex: integer;
begin
  if Assigned(ListView1.Selected) then
  begin
    MMQuery.SQL.Text := ('UPDATE Modes SET Enable = ' +
      BoolToStr(CheckBox1.Checked, '1', '0') + ' WHERE mode = ' +
      QuotedStr(ListView1.Selected.Caption));
    SelectIndex := ListView1.ItemIndex;
    MMQuery.ExecSQL;
    MMQuery.SQLTransaction.Commit;
    ReloadList;
    ListView1.ItemIndex := SelectIndex;
    MainForm.AddModes('', False);
  end;
end;

procedure TMM_Form.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TMM_Form.Button2Click(Sender: TObject);
var
  SelectIndex: integer;
begin
  if Assigned(ListView1.Selected) then
  begin
    if LabeledEdit1.Text <> 'none' then
      MMQuery.SQL.Text := ('UPDATE Modes SET submode = ' +
        QuotedStr(LabeledEdit1.Text) + ' WHERE mode = ' +
        QuotedStr(ListView1.Selected.Caption))
    else
      MMQuery.SQL.Text := ('UPDATE Modes SET submode = ' + QuotedStr('') +
        ' WHERE mode = ' + QuotedStr(ListView1.Selected.Caption));

    SelectIndex := ListView1.ItemIndex;
    MMQuery.ExecSQL;
    MMQuery.SQLTransaction.Commit;
    ReloadList;
    ListView1.ItemIndex := SelectIndex;
  end;
end;

procedure TMM_Form.ListView1Click(Sender: TObject);
begin
  if ListView1.Selected.Selected then
  begin
    MMQuery.SQL.Text := ('SELECT * FROM Modes WHERE mode = ' + QuotedStr(
      ListView1.Selected.Caption));
    MMQuery.Open;
    if Length(MMQuery['submode']) = 0 then
      LabeledEdit1.Text := 'none'
    else
      LabeledEdit1.Text := MMQuery['submode'];
    CheckBox1.Checked := MMQuery['enable'];
    MMQuery.Close;
  end;
end;

end.
