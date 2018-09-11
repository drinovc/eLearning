library MXP_App_Worker;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes,
  IniFiles,
  Forms,
  Windows,
  MxADO,
  StrUtils,
  WideStrings,
  WideStrUtils,
  mxDataRequest in 'mxDataRequest.pas',
  StackTrace in 'StackTrace.pas',
  mxDataADO in 'mxDataADO.pas',
  mxDataCommon in 'mxDataCommon.pas',
  mxDataTimer in 'mxDataTimer.pas',
  mxDM_App_Pub in 'mxDM_App_Pub.pas' {Pub: TDataModule},
  mxDataMXPLogin in 'mxDataMXPLogin.pas',
  XLSRow5 in 'XLSRow5.pas',
  MXP_App_Lookups in 'MXP_App_Lookups.pas' {Lookups: TDataModule};

//,mxAllExports in 'mxAllExports.pas';

{$R *.res}
{$R aVersionInfo.res}

var
  gLogFileName: WideString = 'MXP_App.log';
  gIniFileName: WideString = 'MXP_App.ini';

procedure LoadSettings();
var ini: TIniFile;
    sl: TStringList;
    i,k, n, n2: integer;
begin
  try
    ini := TIniFile.Create(GetAppPath + gIniFileName);
    try
      gSmtpHost := ini.ReadString('SMTP', 'Host', '');
      gSmtpPort := ini.ReadInteger('SMTP', 'Port', 25);
      gSmtpUser := ini.ReadString('SMTP', 'User', '');
      gSmtpPass := ini.ReadString('SMTP', 'Password', '');
      gSmtpRecipientAddress := ini.ReadString('SMTP', 'RecipientAddress', '');
      gSmtpRecipientName := ini.ReadString('SMTP', 'RecipientName', '');
      gSmtpSenderAddress := ini.ReadString('SMTP', 'SenderAddress', '');
      gSmtpSenderName := ini.ReadString('SMTP', 'SenderName', '');

      gConnDataSource := ini.ReadString('WEB', 'DataSource', '');
      gConnCatalog := ini.ReadString('WEB', 'Catalog', '');
      gLogLevel := ini.ReadInteger('WEB', 'LogLevel', 1);
      gLogFolder := ini.ReadString('WEB', 'LogFolder', '');
      gPortalURL := ini.ReadString('WEB', 'ApplicationURL', 'http://');
      gPortalName := ini.ReadString('WEB', 'ApplicationName', '');

      gMxpFolder := ini.ReadString('MXP', 'MxpFolder', '');
      gMxpPMSReportsUserId := ini.ReadString('MXP', 'PMSReportsUserId', '');
      gMxpPMSReportsUsername := ini.ReadString('MXP', 'PMSReportsUsername', '');
      gMxpPMSReportsPassword := ini.ReadString('MXP', 'PMSReportsPassword', '');
      gMxpPMSReportsPasswordEnc := ini.ReadString('MXP', 'PMSReportsPasswordEnc', '');
      gMxpPMSCreditCardPaymentUsername := ini.ReadString('MXP', 'PMSCreditCardPaymentUsername', '');
      gMxpPMSCreditCardPaymentPassword := ini.ReadString('MXP', 'PMSCreditCardPaymentPassword', '');
      gMxpPMSCreditCardPaymentPasswordEnc := ini.ReadString('MXP', 'PMSCreditCardPaymentPasswordEnc', '');

      if gMxpFolder <> '' then
        gMxpFolder := IncludeTrailingBackslash(gMxpFolder);

      if (gMxpPMSReportsUsername <> '') and (gMxpPMSReportsPasswordEnc <> '') then
        gMxpPMSReportsPassword := EncryptionWithPassword(gMxpPMSReportsPasswordEnc, gMxpPMSReportsUsername, False, 1);
      if (gMxpPMSCreditCardPaymentUsername <> '') and (gMxpPMSCreditCardPaymentPasswordEnc <> '') then
        gMxpPMSCreditCardPaymentPassword := EncryptionWithPassword(gMxpPMSCreditCardPaymentPasswordEnc, gMxpPMSCreditCardPaymentUsername, False, 1);

      gAPIWebServiceURL := ini.ReadString('API webservice', 'URL', '');

      if (gLogFolder <> '')and(gLogFolder[length(gLogFolder)] <> '\') then
        gLogFolder := gLogFolder + '\';

    finally
      ini.Free;
    end;

    OpenLogFile;


    try
      sl := TStringList.Create;
      if FileExists(GetAppPath + 'pkg-mx-it.js') then
        sl.LoadFromFile(GetAppPath + 'pkg-mx-it.js')
      else if FileExists(GetAppPath + 'pkg-mx-spa.js') then
        sl.LoadFromFile(GetAppPath + 'pkg-mx-spa.js')
      else
      begin
        LogHttp(nil, '------ Client version file not found in ' + GetAppPath + 'pkg-mx-it.js');
        if FileExists(GetAppPath + '..\websource\compile\deploy\pkg-mx-it.js') then
          sl.LoadFromFile(GetAppPath + '..\websource\compile\deploy\pkg-mx-it.js')
        else
          LogHttp(nil, '------ Client version file not found in ' + GetAppPath + '..\websource\compile\deploy\pkg-mx-it.js');
      end;

      for i:=0 to sl.Count-1 do
      begin
        k := pos('svn_rev', sl[i]);
        if k > 0 then
        begin
          n := Pos('"', sl[i]);
          n2 := PosEx('"', sl[i], n+1);
          gClientVer := copy(sl[i], n+1, n2-n-1);
          break;
        end;
      end;
      sl.Free;
    except
      on e: exception do
        LogHttp(e, '------ Client version ERROR ' + e.Message);
    end;
    LogHttp(nil, '------ Client version ' + gClientVer + ' from ' + GetAppPath + 'pkg-mx-it.js');
  except
  end;
end;

function HandleRequest(Method, Request, Params: PWideChar; var Content: Pointer; var ContentLenght: integer): PWideChar; export; stdcall;
var res: WideString;
    inStream: TMemoryStream;
begin
  //InitTimerThread;

  result := nil;
  try
    //DecimalSeparator := '.';      // TEST
    //ThousandSeparator := ',';

    inStream := TMemoryStream.Create;
    if (Content <> nil)and(ContentLenght > 0) then
      inStream.Write(Content^, ContentLenght);

    res := HandleAppRequest(Method, Request, Params, inStream);
    if (length(res) > 0) then
    begin
      result := WStrAlloc( length(res) + 1 );
      WStrCopy( result, PWideChar(res) );
    end;

    if (ContentLenght = 0)and(Assigned(inStream))and(inStream.Size > 0) then
    begin   // return the stream
      Content := AllocMem(inStream.Size);
      inStream.Position := 0;
      inStream.Read(Content^, inStream.Size);
      ContentLenght := inStream.Size;
    end
    else
    begin
      ContentLenght := 0;
      Content := nil;
    end;

    if Assigned(inStream) then
      FreeAndNil(inStream);
  except
    on e: exception do
    begin
      LogHttp(e, 'HandleRequestMain ERROR: ' + e.Message);
      res := '{"success":false,"reason":"'+e.Message+'"}';
      result := WStrAlloc( length(res) + 1 );
      WStrCopy( result, PWideChar(res) );
    end;
  end;
end;

procedure FreeString(p: PWideChar); export; stdcall;
begin
  try
    if Assigned(p) then
      WStrDispose(p);
  except
    on e: exception do
      LogHttp(e, 'ERROR FreeString: ' + e.Message);
  end;
end;

procedure FreeStream(p: Pointer); export; stdcall;
begin
  try
    if Assigned(p) then
      FreeMem(p);
  except
    on e: exception do
      LogHttp(e, 'ERROR FreeStream: ' + e.Message);
  end;
end;

procedure Shutdown(); export; stdcall;
begin
  //FinishTimerTread;
end;

exports HandleRequest;
exports FreeString;
exports FreeStream;
exports Shutdown;

begin
  IsMultiThread := true;
  LoadSettings();
  //ReportMemoryLeaksOnShutdown := true;
end.
