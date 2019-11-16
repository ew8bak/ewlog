unit AboutForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, resource, versiontypes, versionresource;

type

  { TAbout_Form }

  TAbout_Form = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public

    { public declarations }
  end;

var
  About_Form: TAbout_Form;

implementation

{$R *.lfm}

{ TAbout_Form }
function ResourceVersionInfo: string;
var
  Stream: TResourceStream;
  vr: TVersionResource;
  fi: TVersionFixedInfo;
begin
  Result := '';
  Stream := TResourceStream.CreateFromID(HINSTANCE, 1, PChar(RT_VERSION));
  try
    vr := TVersionResource.Create;
    try
      vr.SetCustomRawDataStream(Stream);
      fi := vr.FixedInfo;
      Result := Format('v%d.%d.%d-Build %d', [fi.FileVersion[0],
        fi.FileVersion[1], fi.FileVersion[2], fi.FileVersion[3]]);
    finally
      vr.Free
    end;
  finally
    Stream.Free
  end;
end;

procedure TAbout_Form.FormShow(Sender: TObject);
begin
  Label5.Caption := ResourceVersionInfo;
end;

end.
