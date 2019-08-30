{
  Multi thread Queue,witch can be used without multi-thread (c) 2014 ti_dic

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
unit mvJobQueue;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,syncobjs,contnrs,forms;

const
  ALL_TASK_COMPLETED = -1;
  NO_MORE_TASK = 0;

type
    TJobQueue = class;

    { TJob }

    TJob = Class
      private
        FLauncher: TObject;
        FCancelled: Boolean;
        FName: String;

      protected
        Queue: TJobQueue;
        procedure DoCancel; virtual;
        Procedure WaitForResultOf(aJob: TJob);
        Procedure EnterCriticalSection;
        procedure LeaveCriticalSection;

        //should be called inside critical section
        function pGetTask: integer; virtual;
        procedure pTaskStarted(aTask: integer); virtual; abstract;
        procedure pTaskEnded(aTask: integer; aExcept: Exception); virtual; abstract;
        property Launcher: TObject read FLauncher;

      public
        procedure ExecuteTask(aTask: integer; FromWaiting: boolean); virtual; abstract;
        function Running: boolean; virtual; abstract;
        procedure Cancel;
        property Cancelled: boolean read FCancelled;
        property Name: String read FName write FName;
     end;

    TJobArray = Array of TJob;

    { TJobQueue }

    TJobQueue = class
      private
        FMainThreadId: TThreadID;
        FOnIdle: TNotifyEvent;
        waitings: TStringList;
        FNbThread: integer;
        TerminatedThread: integer;
        FSect: TCriticalSection;
        FEvent, TerminateEvent: TEvent;
        FUseThreads: boolean;
        Threads: TList;
        Jobs: TObjectList;
        procedure pJobCompleted(var aJob: TJob);
        procedure SetUseThreads(AValue: boolean);
        procedure ClearWaitings;
      protected
        Procedure InitThreads;
        Procedure FreeThreads;
        Procedure EnterCriticalSection;
        procedure LeaveCriticalSection;
        Procedure DoWaiting(E: Exception; TaskId: integer);

        //Should be called inside critical section
        procedure pAddWaiting(aJob: TJob; aTask: integer; JobId: String);
        procedure pTaskStarted(aJob: TJob; aTask: integer);
        procedure pTaskEnded(var aJob: TJob; aTask: integer; aExcept: Exception);
        function pGetJob(out TaskId: integer; out Restart: boolean) : TJob;
        function pFindJobByName(const aName: string; ByLauncher: TObject) : TJobArray;
        procedure pNotifyWaitings(aJob: TJob);
        Function IsMainThread: boolean;
      public
        constructor Create(NbThread: integer = 5);
        destructor Destroy; override;
        procedure QueueAsyncCall(const AMethod: TDataEvent; Data: PtrInt);
        procedure QueueSyncCall(const AMethod: TDataEvent; Data: PtrInt);
        Procedure AddJob(aJob: TJob; Launcher: TObject);
        function AddUniqueJob(aJob: TJob; Launcher: TObject) : boolean;
        function CancelAllJob(ByLauncher: TObject): TJobArray;
        function CancelJobByName(aJobName: String; ByLauncher: TObject): boolean;
        Procedure WaitForTerminate(const lstJob: TJobArray);
        Procedure WaitAllJobTerminated(ByLauncher: TObject);
        property UseThreads: boolean read FUseThreads write SetUseThreads;
        property OnIdle: TNotifyEvent read FOnIdle write FOnIdle;
    end;


implementation

const
  WAIT_TIME = 3000;
  TERMINATE_TIMEOUT = 1000;

type

  { EWaiting }

  EWaiting = class(Exception)
  private
    FLauncher: TJob;
    FNewJob: TJob;
  public
    constructor Create(ALauncher: TJob; ANewJob: TJob);
  end;

  { TRestartTask }

  TRestartTask = class(TJob)
  private
    FStarted: Boolean;
    FJob: TJob;
    FTask: integer;
  protected
    procedure DoCancel; override;
    procedure pTaskStarted(aTask: integer); override;
    procedure pTaskEnded(aTask: integer; aExcept: Exception); override;
    function pGetTask: integer; override;
  public
    constructor Create(aJob: TJob; aTask: integer);
    procedure ExecuteTask(aTask: integer; FromWaiting: boolean); override;
    function Running: boolean; override;
  end;

  { TQueueThread }

  TQueueThread = class(TThread)
  private
    MyQueue: TJobQueue;
    function ProcessJob: boolean;
  public
    constructor Create(aQueue: TJobQueue);
    procedure Execute; override;
  end;

  { TSyncCallData }

  TSyncCallData = Class
  private
    FMethod: TDataEvent;
    FData: PtrInt;
  public
    constructor Create(AMethod: TDataEvent; AData: PtrInt);
    procedure SyncCall;
  end;


{ TSyncCallData }

constructor TSyncCallData.Create(AMethod: TDataEvent; AData: PtrInt);
begin
  FMethod := AMethod;
  FData := AData;
end;

procedure TSyncCallData.SyncCall;
begin
  FMethod(FData);
end;


{ TRestartTask }

procedure TRestartTask.DoCancel;
begin
  FJob.Cancel;
end;

procedure TRestartTask.pTaskStarted(aTask: integer);
begin
  FStarted := true;
end;

procedure TRestartTask.pTaskEnded(aTask: integer; aExcept: Exception);
begin
  Queue.pTaskEnded(FJob, FTask, aExcept);
end;

function TRestartTask.pGetTask: integer;
begin
  if FStarted then
    Result := inherited pGetTask
  else
    Result := 1;
end;

constructor TRestartTask.Create(aJob: TJob; aTask: integer);
begin
  FJob := aJob;
  FTask := aTask;
end;

procedure TRestartTask.ExecuteTask(aTask: integer; FromWaiting: boolean);
begin
  FJob.ExecuteTask(FTask, true);
end;

function TRestartTask.Running: boolean;
begin
  Result := FStarted;
end;


{ EWaiting }

constructor EWaiting.Create(ALauncher: TJob; ANewJob: TJob);
begin
  FLauncher := ALauncher;
  FNewJob := ANewJob;
end;


{ TQueueThread }

constructor TQueueThread.Create(aQueue: TJobQueue);
begin
  MyQueue := aQueue;
  inherited Create(False);
end;

procedure TQueueThread.Execute;
var
  wRes: TWaitResult;
begin
  while not Terminated do
  begin
    wRes := MyQueue.FEvent.WaitFor(WAIT_TIME);
    if not Terminated then
    begin
      if not ProcessJob then
        if wRes = wrTimeout then
           if Assigned(MyQueue.OnIdle) then
             MyQueue.OnIdle(self);
    end;
  end;
  MyQueue.EnterCriticalSection;
  try
     inc(MyQueue.TerminatedThread);
     if Assigned(MyQueue.TerminateEvent) then
        if MyQueue.TerminatedThread=MyQueue.Threads.count then
          MyQueue.TerminateEvent.SetEvent;
  finally
    MyQueue.LeaveCriticalSection;
  end;
end;

function TQueueThread.ProcessJob: boolean;
var
  aJob: TJob;
  TaskId: Integer;

  procedure SetRes(e: Exception);
  begin
    MyQueue.EnterCriticalSection;
    try
      MyQueue.pTaskEnded(aJob,TaskId,nil);
    finally
      MyQueue.LeaveCriticalSection;
    end;
  end;

var
  RestartTask: boolean;
  SomeJob: Boolean;
begin
  Result := false;
  Repeat
    SomeJob := false;
    MyQueue.EnterCriticalSection;
    try
      Result := Result or (MyQueue.Jobs.Count > 0);
      aJob := MyQueue.pGetJob(TaskId, RestartTask);
      if Assigned(aJob) then
      begin
        if TaskId = ALL_TASK_COMPLETED then
        begin
          MyQueue.pJobCompleted(aJob);
          SomeJob := true;
        end
        else
        begin
          MyQueue.FEvent.ResetEvent;
          if not(RestartTask) then
            MyQueue.pTaskStarted(aJob, TaskId);
        end;
      end;
    finally
      MyQueue.LeaveCriticalSection;
    end;
    if Assigned(aJob) then
    begin
      SomeJob := true;
      try
        aJob.ExecuteTask(TaskId, RestartTask);
        SetRes(nil);
      except
        on e: Exception do
          if e.InheritsFrom(EWaiting) then
            MyQueue.DoWaiting(e, TaskId)
          else
            SetRes(e);
      end;
    end;
  until not SomeJob;
end;


{ TJobQueue }

constructor TJobQueue.Create(NbThread: integer);
begin
  waitings := TStringList.Create;
  FNbThread := NbThread;
  FMainThreadId := GetCurrentThreadId;
end;

destructor TJobQueue.Destroy;
begin
  FreeThreads;
  ClearWaitings;
  FreeAndNil(Waitings);
  inherited;
end;

procedure TJobQueue.SetUseThreads(AValue: boolean);
begin
  if FUseThreads = AValue then
     Exit;
  FUseThreads := AValue;
  if FUsethreads then
    InitThreads
  else
    FreeThreads;
end;

procedure TJobQueue.ClearWaitings;
var
  i: integer;
begin
  for i := 0 to pred(Waitings.count) do
    Waitings.Objects[i].Free;
  Waitings.Clear;
end;

procedure TJobQueue.InitThreads;
var
  i: integer;
begin
  Jobs := TObjectList.Create(true);
  Threads := TObjectList.Create(true);
  FEvent := TEvent.Create(nil,true,false,'');
  FSect := TCriticalSection.Create;
  TerminatedThread := 0;
  for i:=1 to FNbThread do
    Threads.Add(TQueueThread.Create(self));
end;

procedure TJobQueue.FreeThreads;
var
  i: integer;
begin
  if Assigned(Threads) then
  begin
    TerminateEvent := TEvent.Create(nil, false, false, '');
    try
      FEvent.SetEvent;
      TerminatedThread := 0;
      for i:=0 to pred(Threads.Count) do
        TQueueThread(Threads[i]).Terminate;
      TerminateEvent.WaitFor(TERMINATE_TIMEOUT);
      FreeAndNil(FSect);
      FreeAndNil(FEvent);
      FreeAndNil(Threads);
    finally
      FreeAndNil(TerminateEvent);
    end;
    FreeAndNil(Jobs);
  end;
end;

procedure TJobQueue.EnterCriticalSection;
begin
  if Assigned(FSect) and UseThreads then
    FSect.Enter;
end;

procedure TJobQueue.LeaveCriticalSection;
begin
  if Assigned(FSect) and UseThreads then
    FSect.Leave;
end;

procedure TJobQueue.DoWaiting(E: Exception; TaskId: integer);
var
  we: EWaiting;
begin
  EnterCriticalSection;
  try
    we := EWaiting(e);
    pAddWaiting(we.FLauncher, TaskId, we.FNewJob.Name);
    AddUniqueJob(we.FNewJob, we.FLauncher.FLauncher);
  finally
    LeaveCriticalSection;
  end;
end;

procedure TJobQueue.pAddWaiting(aJob: TJob; aTask: integer; JobId: String);
begin
  Waitings.AddObject(JobId, TRestartTask.Create(aJob, aTask));
end;

procedure TJobQueue.pTaskStarted(aJob: TJob; aTask: integer);
begin
  aJob.pTaskStarted(aTask);
end;

procedure TJobQueue.pJobCompleted(var aJob: TJob);
Begin
  pNotifyWaitings(aJob);
  if FuseThreads then
  begin
    Jobs.Remove(aJob);
    aJob := nil;
  end
  else
    FreeAndNil(aJob);
end;

procedure TJobQueue.pTaskEnded(var aJob: TJob; aTask: integer; aExcept: Exception);
begin
  aJob.pTaskEnded(aTask, aExcept);
  if (aJob.pGetTask = ALL_TASK_COMPLETED) then
    pJobcompleted(aJob);
end;

function TJobQueue.pGetJob(out TaskId: integer; out Restart: boolean): TJob;
var
  iJob: integer;
  aJob: TJob;
begin
  Restart := false;
  Result := nil;
  for iJob := 0 to pred(Jobs.Count) do
  begin
    aJob := TJob(Jobs[iJob]);
    if aJob.InheritsFrom(TRestartTask) then
    begin
      Result := TRestartTask(aJob).FJob;
      TaskId := TRestartTask(aJob).FTask;
      Restart := true;
      Jobs.Delete(iJob);
      exit;
    end;
    TaskId := aJob.pGetTask;
    if (TaskId>NO_MORE_TASK) or (TaskId=ALL_TASK_COMPLETED) then
    begin
      Result := aJob;
      Exit;
    end;
  end;
  if not Assigned(Result) then
    TaskId := NO_MORE_TASK;
end;

function TJobQueue.pFindJobByName(const aName: string;
  ByLauncher: TObject): TJobArray;
var
  iRes, i: integer;
begin
  SetLength(Result, Jobs.Count);
  iRes := 0;
  for i := 0 to pred(Jobs.Count) do
  begin
    if TJob(Jobs[i]).Name = aName then
    begin
      if (ByLauncher = nil) or (TJob(Jobs[i]).FLauncher = ByLauncher) then
      begin
        Result[iRes] := TJob(Jobs[i]);
        inc(iRes);
      end;
    end;
  end;
  SetLength(Result, iRes);
end;

procedure TJobQueue.pNotifyWaitings(aJob: TJob);
var
  JobId: String;
  ObjRestart: TRestartTask;
  idx: integer;
begin
  JobId := aJob.Name;
  repeat
    idx := waitings.IndexOf(JobId);
    if idx <> -1 then
    begin
      ObjRestart := TRestartTask(waitings.Objects[idx]);
      waitings.Delete(idx);
      Jobs.Add(ObjRestart);
    end;
  until idx = -1;
end;

function TJobQueue.IsMainThread: boolean;
begin
  Result := (GetCurrentThreadId = FMainThreadID);
end;

procedure TJobQueue.QueueAsyncCall(const AMethod: TDataEvent; Data: PtrInt);
begin
  if UseThreads then
    Application.QueueAsyncCall(aMethod,Data)
  else
    AMethod(Data);
end;

procedure TJobQueue.QueueSyncCall(const AMethod: TDataEvent; Data: PtrInt);
var
  tmp: TSyncCallData;
begin
  tmp := TSyncCallData.Create(AMethod,Data);
  try
    TThread.Synchronize(nil, @tmp.SyncCall);
  finally
    tmp.Free;
  end;
end;

procedure TJobQueue.AddJob(aJob: TJob; Launcher: TObject);
var
  TaskId: Integer;
  restart: boolean;
begin
  aJob.FLauncher := Launcher;
  aJob.Queue := self;
  if Usethreads then
  begin
    EnterCriticalSection;
    try
      Jobs.Add(aJob);
    finally
      LeaveCriticalSection;
    end;
    FEvent.SetEvent;
  end
  else
  begin
    try
      repeat
        TaskId := aJob.pGetTask;
        restart := false;
        if TaskId > NO_MORE_TASK then
        begin
          pTaskStarted(aJob, TaskId);
          try
            aJob.ExecuteTask(TaskId, restart);
            pTaskEnded(aJob,TaskId, nil);
          except
            on e: Exception do
            begin
              if not e.InheritsFrom(EWaiting) then
                pTaskEnded(aJob, TaskId, e)
              else
                DoWaiting(e, TaskId);
            end;
          end;
        end;
        if not Assigned(aJob) then
           TaskId := ALL_TASK_COMPLETED;
      until TaskId = ALL_TASK_COMPLETED;
    finally
      aJob.Free;
    end;
  end;
end;

function TJobQueue.AddUniqueJob(aJob: TJob; Launcher: TObject): boolean;
var
  lst: TJobArray;
begin
  Result := true;
  if FUseThreads then
  begin
    aJob.Queue := self;
    aJob.FLauncher := Launcher;
    EnterCriticalSection;
    try
      lst := pFindJobByName(aJob.Name, Launcher);
      if Length(lst) = 0 then
        Jobs.Add(aJob)
      else
        Result := false;
    finally
      LeaveCriticalSection;
    end;
    FEvent.SetEvent;;
  end
  else
    AddJob(aJob,Launcher);
end;

function TJobQueue.CancelAllJob(ByLauncher: TObject): TJobArray;
var
  i, iJob: integer;
begin
  SetLength(Result, 0);
  if FUseThreads then
  begin
    EnterCriticalSection;
    try
      SetLEngth(Result, Jobs.Count);
      iJob := 0;
      for i := pred(Jobs.Count) downto 0 do
      begin
        if (ByLauncher = nil) or (TJob(Jobs[i]).FLauncher = ByLauncher) then
        begin
          TJob(Jobs[i]).Cancel;
          Result[iJob] := TJob(Jobs[i]);
          iJob += 1;
        end;
      end;
      SetLength(Result, iJob);
    finally
      LeaveCriticalSection;
    end;
  end;
end;

function TJobQueue.CancelJobByName(aJobName: String; ByLauncher: TObject): boolean;
var
  lst: TJobArray;
  i: integer;
begin
  Result := false;
  if FUseThreads then
  begin
    EnterCriticalSection;
    try
      lst := pFindJobByName(aJobName, ByLauncher);
      for i := Low(lst) to High(lst) do
      begin
        Result := true;
        lst[i].Cancel;
      end;
    finally
      LeaveCriticalSection;
    end;
  end;
end;

procedure TJobQueue.WaitForTerminate(const lstJob: TJobArray);
var
  OneFound: Boolean;
  i: integer;
  mThread: Boolean;
  TimeOut: integer;
begin
  TimeOut := 0;
  mThread := IsMainThread;
  if FUseThreads then
  begin
    repeat
      OneFound := False;
      EnterCriticalSection;
      try
        for i := Low(lstJob) to High(lstJob) do
        begin
          if Jobs.IndexOf(lstJob[i]) <> -1 then
          begin
            OneFound := True;
            break;
          end;
        end;
      finally
        LeaveCriticalSection;
      end;
      if OneFound and (TimeOut > 200) then
        raise Exception.Create('TimeOut');
      if mThread then
        Application.ProcessMessages;
      if OneFound then
        Sleep(100);
      Inc(TimeOut);
    until not OneFound;
  end;
end;

procedure TJobQueue.WaitAllJobTerminated(ByLauncher: TObject);
var
  OneFound: boolean;
  i: integer;
  TimeOut: integer;
  mThread: Boolean;

  procedure CheckTimeOut;
  begin
    if TimeOut > 200 then
      raise Exception.Create('TimeOut');
    if mThread then
      Application.ProcessMessages;
    Sleep(100);
    inc(TimeOut);
  end;

begin
  TimeOut := 0;
  if FUseThreads then
  begin
    mThread := IsMainThread;
    if ByLauncher = nil then
    begin
      while Jobs.Count > 0 do
        CheckTimeOut;
    end
    else
    begin
      repeat
        OneFound := False;
        EnterCriticalSection;
        try
          for i := 0 to pred(Jobs.Count) do
          begin
            if TJob(Jobs[i]).FLauncher = ByLauncher then
            begin
              OneFound := True;
              break;
            end;
          end;
        finally
          LeaveCriticalSection;
        end;
        if OneFound then
          CheckTimeOut;
      until not OneFound;
    end;
  end;
end;

{ TJobQueue }

procedure TJob.Cancel;
var
  lst: Array of TRestartTask;
  i, idx: integer;
begin
  Queue.EnterCriticalSection;
  try
    FCancelled := true;
    if (Name <> '') and (Queue.waitings.Count > 0) then
    begin
      SetLength(lst, 0);
      repeat
        idx := Queue.waitings.IndexOf(Name);
        if idx <> -1 then
        begin
          SetLength(lst, Length(lst)+1);
          lst[High(lst)] := TRestartTask(Queue.waitings.Objects[idx]);
          Queue.waitings.Delete(idx);
        end;
      until idx = -1;
      for i := Low(lst) to High(lst) do
      begin
        lst[i].Cancel;
        lst[i].pTaskEnded(1, nil);
        lst[i].Free;
      end;
    end;
    DoCancel;
  finally
    Queue.LeaveCriticalSection;
  end;
end;

procedure TJob.DoCancel;
begin
  //
end;

function TJob.pGetTask: integer;
begin
  result := ALL_TASK_COMPLETED;
end;

procedure TJob.WaitForResultOf(aJob: TJob);
begin
  raise EWaiting.Create(self,aJob);
end;

procedure TJob.EnterCriticalSection;
begin
  Queue.EnterCriticalSection;
end;

procedure TJob.LeaveCriticalSection;
begin
  Queue.LeaveCriticalSection;
end;

end.

