{
  (c) 2014 ti_dic

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}
unit mvDragObj;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

Type
  TDragObj = Class;

  TDragEvent = Procedure (Sender : TDragObj) of Object;

  { TDragObj }

  TDragObj = class
  private
    FMouseDown : boolean;
    FLnkObj: TObject;
    FDragsrc,FStartSrc : TObject;
    FOfsX: integer;
    FOfsY: integer;
    InDrag : Boolean;
    FStartX,FStartY : integer;
    FMouseX,FMouseY : integer;
    FEndX,FEndY : integer;
    FOnDrag: TDragEvent;
    FOnEndDrag: TDragEvent;

    procedure SetDest(X,Y : Integer);
    procedure SetLnkObj(AValue: TObject);
    procedure SetOnDrag(AValue: TDragEvent);
    procedure SetOnEndDrag(AValue: TDragEvent);

    Procedure DostartDrag(X,Y: Integer);
    Procedure DoDrag(X,Y: integer);
    Procedure DoEndDrag(X,Y: integer);
    Function HasMoved(X,Y: integer) : Boolean;
    Procedure AbortDrag;

    public
      Procedure MouseDown(aDragSrc: TObject; X,Y: integer);
      Procedure MouseUp(X,Y: integer);
      Procedure MouseMove(X,Y: integer);

      property OnDrag: TDragEvent read FOnDrag write SetOnDrag;
      property OnEndDrag: TDragEvent read FOnEndDrag write SetOnEndDrag;

      property OfsX: integer read FOfsX;
      property OfsY: integer read FOfsY;
      property StartX: integer read FStartX;
      property StartY: integer read FStartY;
      property MouseX: Integer read FMouseX;
      property MouseY: integer read FMouseY;
      property EndX: integer read FEndX;
      property EndY: integer read FEndY;
      Property LnkObj: TObject Read FLnkObj write SetLnkObj;
      property DragSrc: TObject Read FStartSrc;
  end;


implementation

{ TDragObj }

procedure TDragObj.SetDest(X, Y: Integer);
begin
  FEndX := X;
  FEndY := Y;
  FOfsX := FEndX-FstartX;
  FOfsY := FEndY-FstartY;
end;

procedure TDragObj.SetLnkObj(AValue: TObject);
begin
  if FLnkObj=AValue then Exit;
  FreeAndNil(FLnkObj);
  FLnkObj := AValue;
end;

procedure TDragObj.SetOnDrag(AValue: TDragEvent);
begin
  if FOnDrag=AValue then Exit;
  FOnDrag := AValue;
end;

procedure TDragObj.SetOnEndDrag(AValue: TDragEvent);
begin
  if FOnEndDrag=AValue then Exit;
  FOnEndDrag := AValue;
end;

procedure TDragObj.DostartDrag(X, Y: Integer);
begin
  InDrag := True;
  FStartSrc := FDragSrc;
  DoDrag(X,Y);
end;

procedure TDragObj.DoDrag(X, Y: integer);
begin
  if (X<>FEndX) or (Y<>FEndY) then
  begin
    SetDest(X,Y);
    if Assigned(FOnDrag) then
      FOnDrag(Self);
  end;
end;

procedure TDragObj.DoEndDrag(X, Y: integer);
begin
  DoDrag(X,Y);
  if Assigned(FOnEndDrag) then
    FOnEndDrag(self);
  FreeAndNil(FLnkObj);
  FStartSrc := nil;
  InDrag := False;
end;

function TDragObj.HasMoved(X, Y: integer): Boolean;
begin
  Result := (X <> FStartX) or (Y <> FStartY);
end;

procedure TDragObj.AbortDrag;
begin
  if InDrag then
  Begin
    DoDrag(FstartX,FStartY);
    InDrag := False;
    FMouseDown := False;
    FDragSrc :=nil;
    FStartSrc := nil;
    FreeAndNil(FLnkObj);
  end;
end;

procedure TDragObj.MouseDown(aDragSrc : TObject;X, Y: integer);
begin
  if not(FMouseDown) then
  begin
    FDragSrc := aDragSrc;
    FMouseDown := True;
    FStartX := X;
    FStartY := Y;
    FEndX := X;
    FEndY := Y;
  end
  else
    AbortDrag;
end;


procedure TDragObj.MouseMove(X, Y: integer);
begin
  FMouseX := X;
  FMouseY := Y;
  if FMouseDown then
  begin
    if InDrag then
      DoDrag(X,Y)
    else
    begin
      if HasMoved(X,Y) then
        DoStartDrag(X,Y);
    end;
  end;
end;


procedure TDragObj.MouseUp(X, Y: integer);
begin
  if FMouseDown then
  begin
    FMouseDown := False;
    if InDrag then
      DoEndDrag(X,Y);
    FDragSrc := nil;
  end;
end;

end.

