library MXP_App_ISAPI;

uses
  ActiveX,
  ComObj,
  WebBroker,
  ISAPIApp,
  ISAPIThreadPool,
  mxDataIsapi in 'mxDataIsapi.pas' {WebModule1: TWebModule},
  MxDataDllHand in 'MxDataDllHand.pas',
  mxDataCommon in 'mxDataCommon.pas';

{$R *.res}
{$R aVersionInfo.res}

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  CoInitFlags := COINIT_MULTITHREADED;
  Application.Initialize;
  Application.CreateForm(TWebModule1, WebModule1);
  Application.Run;
end.

