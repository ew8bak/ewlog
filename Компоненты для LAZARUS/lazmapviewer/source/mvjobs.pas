{
  basics jobs for multi-threading(c) 2014 ti_dic

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
unit mvJobs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mvJobQueue;


type

  { TSimpleJob: job with only one task }

  TSimpleJob = class(TJob)
  private
    FRunning, FEnded: boolean;
  protected
    function pGetTask: integer; override;
    procedure pTaskStarted(aTask: integer); override;
    procedure pTaskEnded(aTask: integer; {%H-}aExcept: Exception); override;
  public
    function Running: boolean; override;
  end;

  TJobProc = procedure (Data: TObject; Job: TJob) of object;

  { TEventJob: job with only one task (callback an event) }

  TEventJob = class(TSimpleJob)
  private
    FData: TObject;
    FTask: TJobProc;
    FOwnData: Boolean;
  public
    constructor Create(aEvent: TJobProc; Data: TObject; OwnData: Boolean;
      JobName: String = ''); virtual;
    destructor Destroy; override;
    procedure ExecuteTask(aTask: integer; {%H-}FromWaiting: boolean); override;
  end;


implementation

{ TEventJob }

constructor TEventJob.Create(aEvent: TJobProc; Data: TObject;
  OwnData: Boolean; JobName: String = '');
begin
  Name := JobName;
  FTask := aEvent;
  if Assigned(Data) or OwnData then
  begin
    FData := Data;
    FOwnData := OwnData;
  end
  else
  begin
    FOwnData := false;
    FData := self;
  end;
end;

destructor TEventJob.Destroy;
begin
  if FOwnData then
    if FData <> self then
      FData.Free;
  inherited Destroy;
end;

procedure TEventJob.ExecuteTask(aTask: integer; FromWaiting: boolean);
begin
  if Assigned(FTask) then
    FTask(FData, self);
end;


{ TSimpleJob }

function TSimpleJob.pGetTask: integer;
begin
  if FRunning or Cancelled then
  begin
    if not FRunning then
      Result := ALL_TASK_COMPLETED
    else
      Result := NO_MORE_TASK
  end
  else
  begin
    if FEnded then
      Result := ALL_TASK_COMPLETED
    else
      Result := 1;
  end;
end;

procedure TSimpleJob.pTaskStarted(aTask: integer);
begin
  FEnded := false;
  FRunning := True;
end;

procedure TSimpleJob.pTaskEnded(aTask: integer; aExcept: Exception);
begin
  FEnded := True;
  FRunning := False;
end;

function TSimpleJob.Running: boolean;
begin
  Result := FRunning;
end;


end.

