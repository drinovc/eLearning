program MXP_App_DataServer;



uses
  SvcMgr,
  Windows,
  SysUtils,
  Forms,
  mxDataSrvMain in 'mxDataSrvMain.pas' {MXDataServ: TService},
  MxDataDllHand in 'MxDataDllHand.pas',
  MxDataWebForm in 'MxDataWebForm.pas' {FHttpRest},
  StackTrace in 'StackTrace.pas',
  mxDataCommon in 'mxDataCommon.pas';

{$R *.RES}

function GetLoginName: string;
var
  buffer: array[0..255] of char;
  size: dword;
begin
  size := 256;
  if GetUserName(buffer, size) then
    Result := buffer
  else
    Result := ''
end;

function NeedToRunAsService: boolean;
var cmd: string;
begin // this could be implemented in several ways, eg. check for a parameter with ParamStr().
  result := (uppercase(GetLoginName) = 'SYSTEM');

  cmd := uppercase(CmdLine);
  if (ansipos('INSTALL', cmd) <> 0) or
     (ansipos('UNINSTALL', cmd) <> 0) or
     (ansipos('SERVICE', cmd) <> 0) then
    result := true; // we are installing or uninstalling the service
end;

begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  //
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  //
  // Application.DelayInitialize := True;
  //
  try
    if NeedToRunAsService then
    begin // we need the service
      isRunningAsService := true;
      if not SvcMgr.Application.DelayInitialize or SvcMgr.Application.Installing then
        SvcMgr.Application.Initialize;
      SvcMgr.Application.Title := 'mxData';
      SvcMgr.Application.CreateForm(TFHttpRest, FHttpRest);
  SvcMgr.Application.CreateForm(TMXDataServ, MXDataServ);
      SvcMgr.Application.Run;
    end
    else
    begin // the form needs to be created
      //ReportMemoryLeaksOnShutdown := true;
      Forms.Application.Initialize;
      Forms.Application.CreateForm(TFHttpRest, FHttpRest);
      Forms.Application.Run;
    end;
  except
    on e: exception do
    begin
      LogHttp(e, 'MAIN SERVICE ERROR ' + e.message);
    end;
  end;

  (*if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TService4, Service4);
  Application.Run;*)
end.
