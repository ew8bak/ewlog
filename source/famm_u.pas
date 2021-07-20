(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit famm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Variants;

type

  { TFM_Form }

  TFM_Form = class(TForm)
    BtClose: TButton;
    BtSaveBand: TButton;
    CBEnableBand: TCheckBox;
    FMQuery: TSQLQuery;
    GBOptions: TGroupBox;
    LEBand: TLabeledEdit;
    LEBegin: TLabeledEdit;
    LEEnd: TLabeledEdit;
    LECW: TLabeledEdit;
    LEDigi: TLabeledEdit;
    LESSB: TLabeledEdit;
    LVBandList: TListView;
    procedure BtCloseClick(Sender: TObject);
    procedure BtSaveBandClick(Sender: TObject);
    procedure CBEnableBandClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LVBandListSelectItem(Sender: TObject; Item: TListItem;
      Selected: boolean);
  private
    CBState: boolean;
    procedure ReloadList(band, b_begin, b_end, enable: string);
    procedure LoadList;

  public

  end;

var
  FM_Form: TFM_Form;

implementation

{$R *.lfm}
uses dmFunc_U, miniform_u, InitDB_dm, MainFuncDM;

{ TFM_Form }

procedure TFM_Form.ReloadList(band, b_begin, b_end, enable: string);
var
  Item: TListItem;
begin
  try
    Item := LVBandList.Selected;
    if Item <> nil then
    begin
      Item.Caption := band;
      Item.SubItems[0] := b_begin;
      Item.SubItems[1] := b_end;
      Item.SubItems[2] := enable;
    end;
  finally
  end;
end;

procedure TFM_Form.LoadList;
var
  ListItem: TListItem;
begin
  try
    FMQuery.DataBase := InitDB.ServiceDBConnection;
    FMQuery.SQL.Text := ('SELECT * FROM Bands');
    FMQuery.Open;
    LVBandList.Clear;
    while (not FMQuery.EOF) do
    begin
      ListItem := LVBandList.Items.Add;
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
  LoadList;
end;

procedure TFM_Form.BtCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFM_Form.BtSaveBandClick(Sender: TObject);
var
  SelectIndex: integer;
begin
  if Assigned(LVBandList.Selected) then
  begin
    FMQuery.SQL.Text := ('UPDATE Bands SET band = ' +
      QuotedStr(LEBand.Text) + ', b_begin = ' + QuotedStr(LEBegin.Text) +
      ', b_end = ' + QuotedStr(LEEnd.Text) + ', cw = ' +
      QuotedStr(LECW.Text) + ', digi = ' + QuotedStr(LEDigi.Text) +
      ', ssb = ' + QuotedStr(LESSB.Text) + ' WHERE band = ' +
      QuotedStr(LVBandList.Selected.Caption));
    SelectIndex := LVBandList.ItemIndex;
    FMQuery.ExecSQL;
    FMQuery.SQLTransaction.Commit;
    ReloadList(LEBand.Text, LEBegin.Text, LEEnd.Text,
      BoolToStr(CBEnableBand.Checked, 'True', 'False'));
    LVBandList.ItemIndex := SelectIndex;
  end;
end;

procedure TFM_Form.CBEnableBandClick(Sender: TObject);
var
  SelectIndex: integer;
begin
  if CBEnableBand.Checked = CBState then
    Exit;
  if Assigned(LVBandList.Selected) then
  begin
    FMQuery.SQL.Text := ('UPDATE Bands SET Enable = ' +
      BoolToStr(CBEnableBand.Checked, '1', '0') + ' WHERE band = ' +
      QuotedStr(LVBandList.Selected.Caption));
    SelectIndex := LVBandList.ItemIndex;
    FMQuery.ExecSQL;
    FMQuery.SQLTransaction.Commit;
    ReloadList(LEBand.Text, LEBegin.Text, LEEnd.Text,
      BoolToStr(CBEnableBand.Checked, 'True', 'False'));
    LVBandList.ItemIndex := SelectIndex;
    MainFunc.LoadBMSL(MiniForm.CBMode, MiniForm.CBSubMode, MiniForm.CBBand);
    CBState := CBEnableBand.Checked;
  end;
end;

procedure TFM_Form.LVBandListSelectItem(Sender: TObject; Item: TListItem;
  Selected: boolean);
begin
  if Selected then
  begin
    FMQuery.SQL.Text := ('SELECT * FROM Bands WHERE band = ' + QuotedStr(
      LVBandList.Selected.Caption));
    FMQuery.Open;
    LEBand.Text := FMQuery['band'];
    LEBegin.Text := FMQuery['b_begin'];
    LEEnd.Text := FMQuery['b_end'];
    LECW.Text := FMQuery['cw'];
    LEDigi.Text := FMQuery['digi'];
    LESSB.Text := FMQuery['ssb'];
    CBState := FMQuery['enable'];
    CBEnableBand.Checked := CBState;
    FMQuery.Close;
  end;
end;

end.
