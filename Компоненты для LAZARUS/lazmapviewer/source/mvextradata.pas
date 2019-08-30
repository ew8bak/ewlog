unit mvExtraData;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics;

type

  { TDrawingExtraData }

  TDrawingExtraData = class
  private
    FColor: TColor;
    FId: integer;
    procedure SetColor(AValue: TColor);
  public
    constructor Create(aId: integer); virtual;
    property Color: TColor read FColor write SetColor;
    property Id: integer read FId;
  end;

  TTrackExtraData = class(TDrawingExtraData)
  private
    FWidth: Double;
    procedure SetWidth(AValue: Double);
  public
    property Width: Double read FWidth write SetWidth;   // Line width in mm
  end;


implementation

{ TDrawingExtraData }

constructor TDrawingExtraData.Create(aId: integer);
begin
  FId := aId;
  FColor := clRed;
end;

procedure TDrawingExtraData.SetColor(AValue: TColor);
begin
  if FColor = AValue then Exit;
  FColor := AValue;
end;


{ TTrackExtraData }

procedure TTrackExtraData.SetWidth(AValue: Double);
begin
  if AValue = FWidth then Exit;
  FWidth := abs(AValue);
end;

end.

