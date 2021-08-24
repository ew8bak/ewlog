unit StreamAdapter_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TOnProgress = procedure(Sender: TObject; Percent: integer) of object;
  { TStreamAdapter }

  TStreamAdapter = class(TStream)
  strict private
    fOnProgress: TOnProgress;
    fPercent: integer;
    fStream: TStream;
  public
    constructor Create(AStream: TStream; ASize: int64);
    destructor Destroy; override;
    function Read(var Buffer; Count: longint): longint; override;
    function Write(const Buffer; Count: longint): longint; override;
    function Seek(Offset: longint; Origin: word): longint; override;
    procedure DoProgress(Writing: boolean); virtual;
  published
    property OnProgress: TOnProgress read FOnProgress write FOnProgress;
  end;

implementation

{ TStreamAdapter }

constructor TStreamAdapter.Create(AStream: TStream; ASize: int64);
begin
  inherited Create;
  FStream := AStream;
  fStream.Size := ASize;
  fStream.Position := 0;
end;

destructor TStreamAdapter.Destroy;
begin
  FStream.Free;
  inherited Destroy;
end;

function TStreamAdapter.Read(var Buffer; Count: longint): longint;
begin
  Result := FStream.Read(Buffer, Count);
  DoProgress(False);
end;

function TStreamAdapter.Write(const Buffer; Count: longint): longint;
begin
  Result := FStream.Write(Buffer, Count);
  DoProgress(False);
end;

function TStreamAdapter.Seek(Offset: longint; Origin: word): longint;
begin
  Result := FStream.Seek(Offset, Origin);
end;

procedure TStreamAdapter.DoProgress(Writing: boolean);
begin
  fPercent := Trunc((FStream.Position) / (FStream.Size) * 100);
  //WriteLn(FStream.Size);
  if Assigned(OnProgress) then
  begin
    OnProgress(self, FPercent);
  end;
end;



end.
