unit SatEditorForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Buttons, SQLDB, ResourceStr;

type

  { TSATEditorForm }

  TSATEditorForm = class(TForm)
    CBEnable: TCheckBox;
    EditSATname: TEdit;
    EditDescription: TEdit;
    GBOptions: TGroupBox;
    LbSATname: TLabel;
    LbDescription: TLabel;
    LVSatList: TListView;
    SBSatDone: TSpeedButton;
    procedure CBEnableClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LVSatListSelectItem(Sender: TObject; Item: TListItem;
      Selected: boolean);
    procedure SBSatDoneClick(Sender: TObject);
  private
    CBState: boolean;
    procedure LoadList;
    procedure ReloadList(satname, description, enable: string);

  public

  end;

var
  SATEditorForm: TSATEditorForm;

implementation

uses InitDB_dm, satForm_u, MainFuncDM;

{$R *.lfm}

{ TSATEditorForm }

procedure TSATEditorForm.ReloadList(satname, description, enable: string);
var
  Item: TListItem;
begin
  try
    Item := LVSatList.Selected;
    if Item <> nil then
    begin
      Item.Caption := satname;
      Item.SubItems[0] := description;
      Item.SubItems[1] := enable;
    end;
  finally
  end;
end;

procedure TSATEditorForm.CBEnableClick(Sender: TObject);
var
  SelectIndex: integer;
  Query: TSQLQuery;
begin
  if CBEnable.Checked = CBState then
    Exit;

  if Assigned(LVSatList.Selected) then
  begin
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.ServiceDBConnection;
      Query.SQL.Text := ('UPDATE Satellite SET enable = ' +
        BoolToStr(CBEnable.Checked, '1', '0') + ' WHERE name = ' +
        QuotedStr(LVSatList.Selected.Caption));
      SelectIndex := LVSatList.ItemIndex;
      Query.ExecSQL;
      Query.SQLTransaction.Commit;
      ReloadList(EditSATName.Text, EditDescription.Text,
        BoolToStr(CBEnable.Checked, rEnabled, rDisabled));
      LVSatList.ItemIndex := SelectIndex;
      SATForm.CBSat.Items.Clear;
      SATForm.CBSat.Items.AddStrings(MainFunc.LoadSATItems);
      CBState := CBEnable.Checked;
    finally
      FreeAndNil(Query);
    end;
  end;
end;

procedure TSATEditorForm.FormShow(Sender: TObject);
begin
  LoadList;
end;

procedure TSATEditorForm.LVSatListSelectItem(Sender: TObject;
  Item: TListItem; Selected: boolean);
var
  Query: TSQLQuery;
begin
  if Selected then
  begin
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.ServiceDBConnection;
      Query.SQL.Text := ('SELECT * FROM Satellite WHERE Name = ' +
        QuotedStr(LVSatList.Selected.Caption));
      Query.Open;
      EditSATName.Text := Query.FieldByName('Name').AsString;
      EditDescription.Text := Query.FieldByName('Description').AsString;
      CBState := Query.FieldByName('enable').AsBoolean;
      CBEnable.Checked := CBState;
      Query.Close;
    finally
      FreeAndNil(Query);
    end;
  end;
end;

procedure TSATEditorForm.SBSatDoneClick(Sender: TObject);
var
  SelectIndex: integer;
  Query: TSQLQuery;
begin
  if Assigned(LVSatList.Selected) then
  begin
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.ServiceDBConnection;

      Query.SQL.Text := ('UPDATE Satellite SET enable = ' +
        BoolToStr(CBEnable.Checked, '1', '0') +
        ', Name = ' + QuotedStr(EditSATname.Text) +
        ', Description = ' + QuotedStr(EditDescription.Text) +
        ' WHERE name = ' +
        QuotedStr(LVSatList.Selected.Caption));

      SelectIndex := LVSatList.ItemIndex;
      Query.ExecSQL;
      Query.SQLTransaction.Commit;
      ReloadList(EditSATName.Text, EditDescription.Text,
        BoolToStr(CBEnable.Checked, rEnabled, rDisabled));
      LVSatList.ItemIndex := SelectIndex;
      SATForm.CBSat.Items.Clear;
      SATForm.CBSat.Items.AddStrings(MainFunc.LoadSATItems);
      CBState := CBEnable.Checked;
    finally
      FreeAndNil(Query);
    end;
  end;

end;

procedure TSATEditorForm.LoadList;
var
  ListItem: TListItem;
  Query: TSQLQuery;
begin
  try
    Query := TSQLQuery.Create(nil);
    Query.DataBase := InitDB.ServiceDBConnection;
    Query.SQL.Text := ('SELECT * FROM Satellite');
    Query.Open;
    LVSatList.Clear;
    while (not Query.EOF) do
    begin
      ListItem := LVSatList.Items.Add;
      ListItem.Caption := Query.FieldByName('Name').AsString;
      with ListItem.SubItems do
      begin
        Add(Query.FieldByName('Description').AsString);
        Add(BoolToStr(Query.FieldByName('enable').AsBoolean, rEnabled, rDisabled));
      end;
      Query.Next;
    end;
    Query.Close;
  finally
    FreeAndNil(Query);
  end;
end;

end.
