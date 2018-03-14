unit mxDataSrvMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs;

type
  TMXDataServ = class(TService)
    procedure ServiceExecute(Sender: TService);
    procedure ServiceBeforeInstall(Sender: TService);
    procedure ServiceCreate(Sender: TObject);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  MXDataServ: TMXDataServ;

implementation

{$R *.DFM}

uses MxDataWebForm, mxDataDllHand;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  MXDataServ.Controller(CtrlCode);
end;

function TMXDataServ.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TMXDataServ.ServiceBeforeInstall(Sender: TService);
var user, pass: String;
  pc: integer;
begin
  pc := System.ParamCount;
  if pc > 2 then
  begin
    user := ParamStr(2);
    pass := ParamStr(3);

    Sender.ServiceStartName := user;
    Sender.Password := pass;
  end;
end;

procedure TMXDataServ.ServiceCreate(Sender: TObject);
begin
  Name := gSrvName;
end;

procedure TMXDataServ.ServiceExecute(Sender: TService);
begin
  while not Terminated do
  begin
    try
      ServiceThread.ProcessRequests(false);
      Sleep(500);
    except
      on e: exception do
        LogHttp(e, 'MAIN EXECUTE ERROR ' + e.message);
    end;
  end;
end;

end.
