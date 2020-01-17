unit famm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Variants;

type

  { TFaMM_Form }

  TFaMM_Form = class(TForm)
    FMQuery: TSQLQuery;
    ListView1: TListView;
    ListView2: TListView;
    procedure FormShow(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
  private

  public

  end;

var
  FaMM_Form: TFaMM_Form;

implementation

{$R *.lfm}
uses dmFunc_U, MainForm_U;

{ TFaMM_Form }

procedure TFaMM_Form.FormShow(Sender: TObject);
var
  I: integer;
  ListItem: TListItem;
begin
  try
    FMQuery.DataBase := MainForm.ServiceDBConnection;

    ListView2.Clear;
    FMQuery.SQL.Text := ('SELECT * FROM Modes');
    FMQuery.Open;
    while (not FMQuery.EOF) do
    begin
      ListItem := ListView2.Items.Add;
      ListItem.Caption := VarToStr(FMQuery['mode']);
      with ListItem.SubItems do
      begin
        Add(VarToStr(FMQuery['enable']));
      end;
      FMQuery.Next;
    end;
    FMQuery.Close;

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

procedure TFaMM_Form.ListView1Click(Sender: TObject);
begin
  if ListView1.Selected.Selected then
  begin
    FMQuery.SQL.Text := ('SELECT * FROM Bands WHERE band = ' + QuotedStr(
      ListView1.Selected.Caption));
    FMQuery.Open;
    ShowMessage(FMQuery['b_begin']);
    FMQuery.Close;
  end;
end;

end.
