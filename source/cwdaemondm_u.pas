unit CWDaemonDM_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdUDPClient;

type

  { TCWDaemonDM }

  TCWDaemonDM = class(TDataModule)
    IdCWDaemonClient: TIdUDPClient;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    procedure StartCWDaemon;
    procedure SendCWDaemonWPM(wpm: integer);
    procedure SendTextCWDaemon(Text: string);
    procedure TuneStart;
    procedure TuneStop;
    procedure StopSending;

  end;

var
  CWDaemonDM: TCWDaemonDM;

implementation

uses InitDB_dm, MainFuncDM;

{$R *.lfm}

procedure TCWDaemonDM.DataModuleCreate(Sender: TObject);
begin
  if IniSet.CWDaemonEnable then
    StartCWDaemon;
end;

procedure TCWDaemonDM.StartCWDaemon;
begin
  {$IFDEF LINUX}
  try
    IdCWDaemonClient.Active := False;
    if IniSet.CWDaemonEnable then
    begin
      IdCWDaemonClient.Host := IniSet.CWDaemonAddr;
      IdCWDaemonClient.Port := IniSet.CWDaemonPort;
      IdCWDaemonClient.Active := True;
      SendCWDaemonWPM(IniSet.CWDaemonWPM);
    end;
  except
    on E: Exception do
      WriteLn(ExceptFile, 'TCWDaemonDM.StartCWDaemon:' + E.ClassName + ':' + E.Message);
  end;
  {$ENDIF LINUX}
end;

procedure TCWDaemonDM.SendCWDaemonWPM(wpm: integer);
begin
  IniSet.CWDaemonWPM := wpm;
  IdCWDaemonClient.Send(Chr(27) + '2' + IntToStr(wpm));
end;

procedure TCWDaemonDM.TuneStart;
begin
  IdCWDaemonClient.Send(Chr(27) + 'c10');
end;

procedure TCWDaemonDM.TuneStop;
begin
  IdCWDaemonClient.Send(Chr(27) + 'c0');
end;

procedure TCWDaemonDM.StopSending;
begin
  IdCWDaemonClient.Send(Chr(27) + '4');
end;

procedure TCWDaemonDM.SendTextCWDaemon(Text: string);
const
  MinCWWPM = 4;
  MaxCWWPM = 60;
var
  i: integer;
  wpm: word;
  old_wpm: word = 0;
begin
  Text := UpperCase(Trim(Text));
  if Text = '' then
    exit;
  wpm := IniSet.CWDaemonWPM;
  old_wpm := wpm;
  if (Pos('+', Text) > 0) or (Pos('-', Text) > 0) then
  begin
    for i := 1 to Length(Text) do
    begin
      if Text[i] = '+' then
      begin
        wpm := wpm + 5;
        if wpm > MaxCWWPM then
          wpm := MaxCWWPM;
        IdCWDaemonClient.Send(Chr(27) + '2' + IntToStr(wpm));
      end
      else
      begin
        if Text[i] = '-' then
        begin
          wpm := wpm - 5;
          if wpm < MinCWWPM then
            wpm := MinCWWPM;
          IdCWDaemonClient.Send(Chr(27) + '2' + IntToStr(wpm));
        end
        else
          IdCWDaemonClient.Send(Text[i]);
      end;
    end;
    IdCWDaemonClient.Send(Chr(27) + '2' + IntToStr(old_wpm));
  end
  else
    IdCWDaemonClient.Send(Text);
end;

end.
