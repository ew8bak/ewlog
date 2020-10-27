unit ExportADIThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TInfo = record
    AllRec: integer;
    RecCount: integer;
    DupeCount: integer;
    ErrorCount: integer;
    Result: boolean;
  end;

type
  TPADIImport = record
    Path: string;
    Comment: string;
    Mobile: boolean;
    TimeOnOff: boolean;
    AllRec: integer;
    SearchPrefix: boolean;
    RemoveDup: boolean;
  end;

type
  TExportADIFThread = class(TThread)
  protected
    procedure Execute; override;
  private

  public
    PADIImport: TPADIImport;
    Info: TInfo;
    constructor Create;
    procedure ToForm;
  end;

var
  ExportADIFThread: TExportADIFThread;

implementation

uses MainFuncDM, miniform_u, InitDB_dm, dmFunc_U, ExportAdifForm_u;

constructor TExportADIFThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TExportADIFThread.ToForm;
begin

end;

procedure TExportADIFThread.Execute;
begin

end;

end.
