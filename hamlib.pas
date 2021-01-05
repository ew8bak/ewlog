unit hamlib;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process, strutils;

const
  hlReadFreq: String = 'f'   + #10;
  hlTxOn    : String = 'T 1' + #10;
  hlTxOff   : String = 'T 0' + #10;
  hlWait = 400;

type

  TThreadHamlibTxOn = class(TThread)
    protected
      procedure Execute; override;
    public
      Constructor Create;
  end;

  TThreadHamlibTxOff = class(TThread)
    protected
      procedure Execute; override;
    public
      Constructor Create;
  end;

  TThreadHamlibReadQRG = class(TThread)
    protected
      procedure Execute; override;
    public
      Constructor Create;
  end;

  TThreadHamlibSetQRG = class(TThread)
    private
      kHzStr: String;
    protected
      procedure Execute; override;
    public
      Constructor Create(qrgStr: String);
  end;

  TThreadHamlibReconnect = class(TThread)
    protected
      procedure Execute; override;
    public
      Constructor Create;
  end;

var
  //hamlibDir: String;
  //hamlibFileName: String;
  dummyList: TStringList = nil;
  hamlibProcess: TProcess = nil;

  HamlibTxOn:      TThreadHamlibTxOn      = nil;
  HamlibTxOff:     TThreadHamlibTxOff     = nil;
  HamlibReadQRG:   TThreadHamlibReadQRG   = nil;
  HamlibSetQRG:    TThreadHamlibSetQRG    = nil;
  HamlibReconnect: TThreadHamlibReconnect = nil;

  hlBusyFlag:     Boolean = True;
  hlDontReadFlag: Boolean = False;
  hlTx:           Boolean = False;

implementation

uses
  MainForm_U;

Constructor TThreadHamlibTxOn.Create;
begin
  FreeOnTerminate := True;
  inherited Create(False)
end;

Constructor TThreadHamlibTxOff.Create;
begin
  FreeOnTerminate := True;
  inherited Create(False)
end;

Constructor TThreadHamlibReadQRG.Create;
begin
  FreeOnTerminate := True;
  inherited Create(False)
end;

Constructor TThreadHamlibSetQRG.Create(qrgStr: String);
begin
  kHzStr := qrgStr;
  FreeOnTerminate := True;
  inherited Create(False)
end;

Constructor TThreadHamlibReconnect.Create;
begin
  FreeOnTerminate := True;
  inherited Create(False)
end;

procedure TThreadHamlibTxOn.Execute;
var
  i: Integer;
begin
  for i := 1 to 10 do
    if hlBusyFlag then
      Sleep(hlWait)
    else
      break;

  if hamlibProcess.Running then
    begin
      hlBusyFlag := True;
      hamlibProcess.Input.Write(hlTxOn[1], Length(hlTxOn));

      for i := 1 to 3 do
        begin
          Sleep(hlWait);
          if hamlibProcess.Output.NumBytesAvailable = 20 then
            begin
              dummyList.LoadFromStream(hamlibProcess.Output);
              hlBusyFlag := False;
              exit
            end
        end;

      Sleep(hlWait * 2);

      if hamlibProcess.Output.NumBytesAvailable > 8 then
        dummyList.LoadFromStream(hamlibProcess.Output);

      hamlibProcess.Input.Write(hlTxOn[1], Length(hlTxOn));

      for i := 1 to 3 do
        begin
          Sleep(hlWait);
          if hamlibProcess.Output.NumBytesAvailable = 20 then
            begin
              dummyList.LoadFromStream(hamlibProcess.Output);
              break
            end
        end
    end;
  hlBusyFlag := False
end;

procedure TThreadHamlibTxOff.Execute;
var
  i: Integer;
begin
  for i := 1 to 10 do
    if hlBusyFlag then
      Sleep(hlWait)
    else
      break;

  if hamlibProcess.Running then
    begin
      hlBusyFlag := True;

      hamlibProcess.Input.Write(hlTxOff[1], Length(hlTxOff));

      for i := 1 to 3 do
        begin
          Sleep(hlWait);
          if hamlibProcess.Output.NumBytesAvailable = 20 then
            begin
              dummyList.LoadFromStream(hamlibProcess.Output);
              ///// Исправить!
              //Form1.ComboBox3.Enabled := True;
              hlTx := False;
              hlBusyFlag := False;
              exit
            end
        end;

      Sleep(hlWait * 2);

      if hamlibProcess.Output.NumBytesAvailable > 8 then
        dummyList.LoadFromStream(hamlibProcess.Output);

      hamlibProcess.Input.Write(hlTxOff[1], Length(hlTxOff));

      for i := 1 to 3 do
        begin
          Sleep(hlWait);
          if hamlibProcess.Output.NumBytesAvailable = 20 then
            begin
              dummyList.LoadFromStream(hamlibProcess.Output);
              break
            end
        end
    end;
  ////Иправить
  //Form1.ComboBox3.Enabled := True;
  hlTx := False;
  hlBusyFlag := False
end;

procedure TThreadHamlibReadQRG.Execute;
var
  qrgHzStr, Hz, kHz, bandStr: String;
  LqrgHz, i, hertz: Integer;
  okFlag: Boolean;
begin
  if hamlibProcess.Running then
    begin
      hlBusyFlag := True;
      if not ((hamlibProcess.Output.NumBytesAvailable = 35) or (hamlibProcess.Output.NumBytesAvailable = 36)) then
        begin
          if hamlibProcess.Output.NumBytesAvailable > 0 then
            begin
              dummyList.LoadFromStream(hamlibProcess.Output);
              hlBusyFlag := False;
              exit
            end;
          hamlibProcess.Input.Write(hlReadFreq[1], Length(hlReadFreq));
        end;
      okFlag := False;

      for i := 1 to 3 do
        begin
          Sleep(hlWait * i);
          if (hamlibProcess.Output.NumBytesAvailable = 35) or (hamlibProcess.Output.NumBytesAvailable = 36) then
            begin
              okFlag := True;
              break
            end
        end;

      if okFlag then
        begin
          dummyList.LoadFromStream(hamlibProcess.Output);

          qrgHzStr := dummyList[0];

          if qrgHzStr[12] = 'r' then
            begin
              ///Исправить
              ///Form1.LabelRigInfo1.Caption:= 'HamLib Disabled';
              hlBusyFlag := False;
              exit
            end;

          qrgHzStr := qrgHzStr[12..Length(qrgHzStr)];

          if TryStrToInt(qrgHzStr, hertz) then
            begin
              LqrgHz := Length(qrgHzStr);

              kHz := qrgHzStr[1..LqrgHz - 3];
              Hz  := qrgHzStr[LqrgHz - 2..LqrgHz];

              if Hz = '000' then
                //Испарвить
                MainForm.ComboBox3.Text:= kHz
              else
                MainForm.ComboBox3.Text:= kHz + '.' + Hz;

              //qrgHz := hertz;
             // bandStr := BandFromIntQRG(hertz);
              if bandStr <> '' then
                begin
                 // Form17.BandChanged(bandStr);
                 // Form1.EditBand.Text:= bandStr;
                end
            end
        end
    end;
  hlBusyFlag := False
end;

procedure TThreadHamlibSetQRG.Execute;
var
  hz, kHz, qrg: String;
  i: Integer;
begin
  for i := 1 to 5 do
    if hlBusyFlag then
      Sleep(hlWait)
    else
      break;

  if hamlibProcess.Running then
    begin
      hlBusyFlag := True;

      Hz := '';
      if AnsiContainsStr(kHzStr, '.') then
        begin
          khz := ExtractWord(1, kHzStr, ['.']);
          if WordCount(kHzStr, ['.']) = 2 then
            Hz := ExtractWord(2, kHzStr, ['.'])
        end
      else
        begin
          khz := kHzStr
        end;
      Hz := Hz + '000';
      qrg := 'F ' + khz + Hz[1..3] + #10;

      hamlibProcess.Input.Write(qrg[1], Length(qrg));

      for i := 1 to 4 do
        begin
          Sleep(hlWait);
          if hamlibProcess.Output.NumBytesAvailable = 26 then
            begin
              dummyList.LoadFromStream(hamlibProcess.Output);
              break
            end
        end
    end;
  hlBusyFlag := False
end;

procedure TThreadHamlibReconnect.Execute;
var
  i: Integer;
begin
  for i := 1 to 5 do
    if hlBusyFlag then
      Sleep(hlWait)
    else
      break;

    hlBusyFlag := True;
    if hamlibProcess.Running then
      begin
        hamlibProcess.Terminate(0);
        Sleep(500)
      end;

    hamlibProcess.Execute;
    Sleep(5000);

    if hamlibProcess.Output.NumBytesAvailable = 15 then
      begin
        dummyList.LoadFromStream(hamlibProcess.Output);
        //Form1.LabelRigInfo1.Caption:= 'HamLib ' + Form6.cbCATPort.Text
      end
    else
      begin
        if hamlibProcess.Output.NumBytesAvailable > 10 then;
          dummyList.LoadFromStream(hamlibProcess.Output);
        //Form1.LabelRigInfo1.Caption:= 'HamLib Disabled';
        hamlibProcess.Terminate(0)
      end;
  hlBusyFlag := False
end;

end.

