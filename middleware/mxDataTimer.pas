unit mxDataTimer;

interface

uses Classes, SysUtils, SyncObjs;

type
  TTimerThread = class(TThread)
  strict private
    FFinishEvent: TSimpleEvent;
  protected
    procedure Execute; override;
  public
    procedure SetFinishedFlag;
    constructor Create;
    destructor Destroy; override;
  end;
  // call these functions somewhere from the outside (not the
  // intialization section e.g. on the first
  // request. Also call Finish from a designated function and
  // not from the finalization section
  // intialization is called from DLLMain and this is not very safe.
  procedure InitTimerThread;
  procedure FinishTimerTread;

implementation

const cTimerInterval = 1800000; // half an hour
      cWakeupInterval = 30000;  // 30 seconds

var TimerThread: TTimerThread;

{
  Creates the timer thread if it does not already exists
}
procedure InitTimerThread;
begin
  if not assigned(TimerThread) then
    TimerThread := TTimerThread.Create;
end;

{
  Terminates and destroys the timer thread
}
procedure FinishTimerTread;
begin
  if Assigned(TimerThread) then
  begin
    TimerThread.Terminate;
    TimerThread.SetFinishedFlag;
    TimerThread.WaitFor;
    FreeAndNil(TimerThread);
  end;
end;

constructor TTimerThread.Create;
begin
  fFinishEvent := TSimpleEvent.Create;

  inherited Create(False);
end;

destructor TTimerThread.Destroy;
begin
  FreeAndNil(fFinishEvent);

  inherited;
end;

{
  Timer thread execution loop
  Wakes up every wakeup seconds and executes provided code every interval seconds
  Currently is used to process expired insurances every 30 minutes
}
procedure TTimerThread.Execute;
var elapsedTime : integer;
begin
  elapsedTime := 0;

  while not Terminated do
  begin
    if fFinishEvent.WaitFor(cWakeupInterval) = wrTimeout then
    begin
      inc(elapsedTime, cWakeupInterval);

      if elapsedTime > cTimerInterval then
      begin
        try
        except
        on e: exception do
        end;

        elapsedTime := 0;
      end;
    end
    else
      break;
  end;
end;

{
  Trigger the finish event so the thread terminates
}
procedure TTimerThread.SetFinishedFlag;
begin
  fFinishEvent.SetEvent;
end;

end.
