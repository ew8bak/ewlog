unit dmTHT_u;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TTHTRecord = record
    VFO: string;
    MODULATION: string;
    STATUS: boolean;
  end;

type
  TTHTSettings = record
    Name: string;
    Address: string;
    Port: integer;
    Enable: boolean;
  end;

type
  TdmTHT = class(TDataModule)
  private

  public
    procedure SaveTHTini(nTRX: integer);
    procedure LoadTHTini(nTRX: integer);

  end;

var
  dmTHT: TdmTHT;
  THTSettings: TTHTSettings;

implementation

uses MainFuncDM, InitDB_dm, dmFunc_U, miniform_u, TRXForm_U;

{$R *.lfm}

procedure TdmTHT.SaveTHTini(nTRX: integer);
begin
  INIFile.WriteString('THT' + IntToStr(nTRX), 'Name', THTSettings.Name);
  INIFile.WriteString('THT' + IntToStr(nTRX), 'Address', THTSettings.Address);
  INIFile.WriteInteger('THT' + IntToStr(nTRX), 'Port', THTSettings.Port);
  INIFile.WriteBool('THT' + IntToStr(nTRX), 'Enable', THTSettings.Enable);
end;

procedure TdmTHT.LoadTHTini(nTRX: integer);
begin
  THTSettings.Name := INIFile.ReadString('THT' + IntToStr(nTRX), 'Name', '');
  THTSettings.Address := INIFile.ReadString('THT' + IntToStr(nTRX),
    'Address', '127.0.0.1');
  THTSettings.Port := INIFile.ReadInteger('THT' + IntToStr(nTRX), 'Port', 8081);
  THTSettings.Enable := INIFile.ReadBool('THT' + IntToStr(nTRX), 'Enable', False);
end;

end.

