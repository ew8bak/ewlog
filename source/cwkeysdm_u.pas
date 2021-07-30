unit CWKeysDM_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, Variants, Dialogs;

type
  TMacros = record
    Button: string[2];
    Name: string[20];
    Macro: string[255];
  end;

type

  { TCWKeysDM }

  TCWKeysDM = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    function ReplaceMacro(str: string): string;

  end;

var
  CWKeysDM: TCWKeysDM;

implementation

uses
  InitDB_dm, miniform_u, MainFuncDM, SetupSQLquery, ResourceStr;

{$R *.lfm}

function TCWKeysDM.ReplaceMacro(str: string): string;
var
  MyFREQ: string = '';
  MyCall: string = '';
  MyLoc: string = '';
  MyName: string = '';
  MyQTH: string = '';
  MyRST: string = '';
begin
  MyCall := LBRecord.CallSign;
  MyLoc := LBRecord.OpLoc;
  MyName := LBRecord.OpName;
  MyQTH := LBRecord.OpQTH;
  MyRST := MiniForm.CBRSTs.Text;
  MyFREQ := FloatToStr(FMS.Freq);
  Result := str;
  Result := StringReplace(Result, '<MYFREQ>', MyFREQ, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<MYCALL>', MyCall, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<MYLOC>', MyLoc, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<MYNAME>', MyName, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<MYQTH>', MyQTH, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<MYRST>', MyRST, [rfReplaceAll, rfIgnoreCase]);
end;

procedure TCWKeysDM.DataModuleCreate(Sender: TObject);
begin

end;

end.
