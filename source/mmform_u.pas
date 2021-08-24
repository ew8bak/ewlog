(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit mmform_u;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, Forms, Controls, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, ResourceStr;

type

  { TMM_Form }

  TMM_Form = class(TForm)
    BtClose: TButton;
    BtSaveSubMode: TButton;
    CBEnableMod: TCheckBox;
    GBOptions: TGroupBox;
    LESubMode: TLabeledEdit;
    LVModeList: TListView;
    MMQuery: TSQLQuery;
    procedure BtCloseClick(Sender: TObject);
    procedure BtSaveSubModeClick(Sender: TObject);
    procedure CBEnableModClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LVModeListSelectItem(Sender: TObject; Item: TListItem;
      Selected: boolean);
  private
    CBState: boolean;
    procedure ReloadList(mode, enable: string);
    procedure LoadList;

  public

  end;

var
  MM_Form: TMM_Form;

implementation

{$R *.lfm}
uses miniform_u, InitDB_dm, MainFuncDM;

{ TMM_Form }

procedure TMM_Form.ReloadList(mode, enable: string);
var
  Item: TListItem;
begin
  try
    Item := LVModeList.Selected;
    if Item <> nil then
    begin
      Item.Caption := mode;
      Item.SubItems[0] := enable;
    end;
  finally
  end;
end;

procedure TMM_Form.LoadList;
var
  ListItem: TListItem;
begin
  try
    MMQuery.DataBase := InitDB.ServiceDBConnection;
    MMQuery.SQL.Text := ('SELECT * FROM Modes');
    MMQuery.Open;
    LVModeList.Clear;
    while (not MMQuery.EOF) do
    begin
      ListItem := LVModeList.Items.Add;
      ListItem.Caption := MMQuery.FieldByName('mode').AsString;
      ListItem.SubItems.Add(BoolToStr(MMQuery.FieldByName('enable').AsBoolean,
        rEnabled, rDisabled));
      MMQuery.Next;
    end;
    MMQuery.Close;
  finally
  end;
end;

procedure TMM_Form.FormShow(Sender: TObject);
begin
  if Length(LESubMode.Text) = 0 then
    LESubMode.Text := 'none';
  LoadList;
end;

procedure TMM_Form.CBEnableModClick(Sender: TObject);
var
  SelectIndex: integer;
begin
  if CBEnableMod.Checked = CBState then
    Exit;
  if Assigned(LVModeList.Selected) then
  begin
    MMQuery.SQL.Text := ('UPDATE Modes SET Enable = ' +
      BoolToStr(CBEnableMod.Checked, '1', '0') + ' WHERE mode = ' +
      QuotedStr(LVModeList.Selected.Caption));
    SelectIndex := LVModeList.ItemIndex;
    MMQuery.ExecSQL;
    MMQuery.SQLTransaction.Commit;
    ReloadList(LVModeList.Selected.Caption, BoolToStr(CBEnableMod.Checked,
      rEnabled, rDisabled));
    LVModeList.ItemIndex := SelectIndex;
    MainFunc.LoadBMSL(MiniForm.CBMode, MiniForm.CBSubMode, MiniForm.CBBand);
    CBState := CBEnableMod.Checked;
  end;
end;

procedure TMM_Form.BtCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TMM_Form.BtSaveSubModeClick(Sender: TObject);
var
  SelectIndex: integer;
begin
  if Assigned(LVModeList.Selected) then
  begin
    if LESubMode.Text <> 'none' then
      MMQuery.SQL.Text := ('UPDATE Modes SET submode = ' +
        QuotedStr(LESubMode.Text) + ' WHERE mode = ' +
        QuotedStr(LVModeList.Selected.Caption))
    else
      MMQuery.SQL.Text := ('UPDATE Modes SET submode = ' + QuotedStr('') +
        ' WHERE mode = ' + QuotedStr(LVModeList.Selected.Caption));

    SelectIndex := LVModeList.ItemIndex;
    MMQuery.ExecSQL;
    MMQuery.SQLTransaction.Commit;
    ReloadList(LVModeList.Selected.Caption, BoolToStr(CBEnableMod.Checked,
      rEnabled, rDisabled));
    LVModeList.ItemIndex := SelectIndex;
  end;
end;

procedure TMM_Form.LVModeListSelectItem(Sender: TObject; Item: TListItem;
  Selected: boolean);
begin
  if Selected then
  begin
    MMQuery.SQL.Text := ('SELECT * FROM Modes WHERE mode = ' + QuotedStr(
      LVModeList.Selected.Caption));
    MMQuery.Open;
    if Length(MMQuery['submode']) = 0 then
      LESubMode.Text := 'none'
    else
      LESubMode.Text := MMQuery['submode'];
    CBState := MMQuery['enable'];
    CBEnableMod.Checked := CBState;
    MMQuery.Close;
  end;
end;

end.
