unit mxDataRequest;

interface

uses
  SysUtils, Classes, Forms, DB, ADODB, MxADO, DateUtils,
  ActiveX, Windows, Controls, Variants, IdMessage, WideStrings, IdSMTP, IdAttachmentMemory, SuperObject, IdText;

function HandleMultipleRequests(const Params: TWideStrings; InStream: TMemoryStream; var ContentType: WideString): variant;
function HandleAppRequest(method, request, params: WideString; inStream: TMemoryStream): WideString;

function CreateDataModule(DataModuleName: WideString): TDataModule;
function SendEMail(MailMessage: TIdMessage; emailParams : TWideStringList; SMTPIn: TIdSMTP): boolean;
function SendEmailMsg(addr, addrCC, subj, msg : string; emailParams: TWideStringList; SMTPIn: TIdSMTP; attStreams: TWIdeStringList):boolean; overload;
function SendEmailToUser(addr, subj, msg : string; emailParams: TWideStringList): boolean; overload;
function SendEmailToUser(addr, subj, msg : string; emailParams: TWideStringList; SMTPIn: TIdSMTP; attStreams:TList; attNames: TWIdeStringList): boolean; overload;
function getPortalLink(): WideString;

function LogHttp(e: exception; msg: WideString; params: TWideStrings = nil; lineNo: integer = -1): integer; overload;
function LogHttp(msg: WideString; params: TWideStrings = nil; lineNo: integer = -1): integer; overload;
procedure LogHttp2(logFileName: widestring; e: exception; msg: WideString; params: TWideStringList = nil; lineNo: integer = -1);
procedure CloseLogFile();
procedure OpenLogFile();

var
  CritSectLog: TRTLCriticalSection;
  totalRequestCount: integer = 0;

  gSmtpHost: WideString;
  gSmtpPort: integer;
  gSmtpUser: WideString;
  gSmtpPass: WideString;
  gSmtpRecipientAddress: WideString = '';
  gSmtpRecipientName: WideString = '';
  gSmtpSenderAddress: WideString = '';
  gSmtpSenderName : WideString = '';
  gConnStr: WideString;
  gConnDataSource: WideString = '';
  gClientVer: WideString = '';
  gConnCatalog: WideString = '';
  gConnUserID: WideString = '';
  gConnPassword: WideString = '';
  gSettings: TSuperObject;

  gAPIWebServiceURL : WideString = '';

  gLogFile: TextFile;
  gUseLogFile: boolean = false;
  logLineNo: integer = 0;
  gLogLevel: integer = 1;  //  0 - no log, 1 - log exceptions, 2 - log requests, 3 - log requests with params
  gLogFolder: WideString = '';
  gPortalURL: WideString = '';
  gPortalName: WideString = '';
  
  gHttpFolder: WideString = '';
  gLogFileName: WideString = 'MXP_App.log';
  gLogEmailFileName: WideString = 'email.log';
  gEnvironment: WideString = 'D';
  gFileStorage: string = '';

  gMxpFolder: WideString = '';
  gMxpPMSReportsUserId: WideString = '';
  gMxpPMSReportsUsername: WideString = '';
  gMxpPMSReportsPassword: WideString = '';
  gMxpPMSReportsPasswordEnc: WideString = '';
  gMxpPMSCreditCardPaymentUsername: WideString = '';
  gMxpPMSCreditCardPaymentPassword: WideString = '';
  gMxpPMSCreditCardPaymentPasswordEnc: WideString = '';
const
  CRLF = #13#10;
  CR = #13;
  CR2 = #13#13;

implementation

uses WebReq, HTTPApp, mxDateUtils, mxDataADO, mxDataCommon, StackTrace,
  IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase,
  IdMessageClient, IdSMTPBase;

{
	Portal link building function, for now only serves the link from ini setting
}
function getPortalLink(): WideString;
begin
  result := gPortalURL;
end;

{
	General mail sending method
  requires preset TIdMessage object
  uses general SMTP settings read from ini
  overrides Recepient address and sender address if provided in ini
  returns sending success
}
function SendEMail( MailMessage : TIdMessage; emailParams : TWideStringList; SMTPIn: TIdSMTP): boolean;
var SMTP: TIdSMTP;
begin
  LogHttp2(gLogEmailFileName, nil, 'Sending E-Mail to: ' + MailMessage.Recipients[0].Text
    + CRLF + 'Subject: ' + MailMessage.Subject
    + CRLF + 'Body:' + MailMessage.Body.Text + CRLF);

  if assigned(SMTPIn) then
     SMTP := SMTPIn
  else
    SMTP := TIdSMTP.Create(nil);

  try

    SMTP.Host := isEmpty(emailParams.Values['SmtpHost'], gSmtpHost);
    SMTP.Port := isEmpty(emailParams.Values['SmtpPort'], gSmtpPort);
    SMTP.Username := isEmpty(emailParams.Values['SmtpUser'], gSmtpUser);
    SMTP.Password := isEmpty(emailParams.Values['SmtpPass'], gSmtpPass);

    ////////////
    if (gSmtpRecipientAddress <> '')and(gSmtpRecipientName <> '') then                   // OVERRIDE RECIPIENT
    begin
      MailMessage.Recipients[0].Address := gSmtpRecipientAddress;
      MailMessage.Recipients[0].Name := gSmtpRecipientName;
      MailMessage.Recipients[0].Text := MailMessage.Recipients[0].Name+' <'+MailMessage.Recipients[0].Address+'>';
    end;

    if (MailMessage.From.Address = '') then begin
      if(emailParams.Values['SenderAddress'] <> '') and (emailParams.Values['SenderName'] <> '') then
      begin
        MailMessage.From.Address := emailParams.Values['SenderAddress'];
        MailMessage.From.Name := emailParams.Values['SenderName'];
      end
      else
      begin
        MailMessage.From.Address := gSmtpSenderAddress;
        MailMessage.From.Name := gSmtpSenderName;
      end;
    end;

    try
      try
        if not SMTP.Connected then
        begin
          SMTP.ConnectTimeout := 15000;
          SMTP.ReadTimeout := 15000;
          SMTP.Connect;
        end;
        SMTP.Send(MailMessage);

        result := true;
      except
        on e: exception do
        begin
          result := false;
          LogHttp2(gLogEmailFileName, e, 'Error Sending EMail: ' + StringReplace(e.Message, crlf, ' ', [rfReplaceAll]) + CRLF + '  Trying to send to: ' + MailMessage.Recipients[0].Text + ', from: ' + MailMessage.From.Text);
        end;
      end;
    finally
      try
        if not assigned(SMTPIn) and SMTP.Connected then
          SMTP.Disconnect;
      except
      end;
    end;
  finally
    if not assigned(SMTPIn) then
      SMTP.Free;
  end;
end;

{
  E-Mail sending to specific address with subject and body message
  creates the TIdMessage structure and forwards to SendEMail func
  returns sending success
}

function SendEmailMsg(addr, addrCC, subj, msg : string; emailParams: TWideStringList; SMTPIn: TIdSMTP; attStreams: TWIdeStringList):boolean; overload;
var idmsg : TIdMessage;
    att, i: integer;
    AttachmentStream: TIdAttachmentMemory;
    bodyPart: TIdText;
    stream: TStream;
    attFileName: WideString;
    toList, ccList: TStringList;

    procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
    begin
       ListOfStrings.Clear;
       ListOfStrings.Delimiter     := Delimiter;
       ListOfStrings.DelimitedText := Str;
    end;
begin
  try
    idmsg := TIdMessage.Create(nil);
    try
      idmsg.Subject := subj;
      if(emailParams.Values['ShowHtml'] = '1') then
      begin
        bodyPart := TIdText.Create(idmsg.MessageParts);
        bodyPart.Body.Text := msg;
        bodyPart.ContentType := 'text/html';
      end
      else
        idmsg.Body.Text := msg;
      if(emailParams.Values['ShowHtml'] = '1') then
        idmsg.ContentType := 'multipart/mixed';

      if (attStreams <> nil) then
        for att := 0 to attStreams.Count-1 do
        begin
          stream := TStream(attStreams.Objects[att]);
          attFileName := attStreams[att];
          if(Assigned(stream) and (stream.Size > 0)) then
          begin
            AttachmentStream := TIdAttachmentMemory.Create(idmsg.MessageParts, stream);
            AttachmentStream.FileName := attFileName;
            AttachmentStream.ContentDisposition := 'attachment';
            AttachmentStream.ContentType := 'application/octet-stream';
          end;
        end;

      toList := TStringList.Create;
//      toList.Duplicates:= dupIgnore;
//      toList.Sorted := true;
      Split(',', addr, toList);
      for i := 0 to toList.count - 1 do
      begin
        with idmsg.Recipients.Add do
          Address := toList[i];
      end;

      ccList := TStringList.Create;
//      ccList.Duplicates:= dupIgnore;
//      ccList.Sorted := true;
      Split(',', addrCC, ccList);
      for i := 0 to ccList.count - 1 do
      begin
        with idmsg.CCList.Add do
          Address := ccList[i];
      end;

      result := SendEMail(idmsg, emailParams, SMTPIn);
    finally
      idmsg.Free;
      toList.Free;
      ccList.Free;
    end;
  except
    on e: Exception do
    begin
      result := false;
      LogHttp2(gLogEmailFileName, e, 'Error Preparing EMail: ' + StringReplace(e.Message, crlf, ' ', [rfReplaceAll]));
    end;
  end;
end;

{
  E-Mail sending to specific address with subject and body message
  creates the TIdMessage structure and forwards to SendEMail func
  returns sending success
}
function SendEmailToUser(addr, subj, msg : string; emailParams: TWideStringList; SMTPIn: TIdSMTP; attStreams:TList; attNames: TWIdeStringList):boolean; overload;
var idmsg : TIdMessage;
att: integer;
AttachmentStream: TIdAttachmentMemory;
stream: TMemoryStream;
attFileName: WideString;
begin
  idmsg := TIdMessage.Create(nil);
  try
    idmsg.Subject := subj;
    idmsg.Body.Text := msg;

    if (attStreams <> nil) and (attNames <> nil) then
    begin
      while (attStreams.Count > 0) and (attNames.Count > 0) do
      begin
           stream := attStreams[0];
           attFileName := attNames[0];
           if(Assigned(stream) and (stream.Size > 0)) then
           begin
              AttachmentStream := TIdAttachmentMemory.Create(idmsg.MessageParts, stream);
              AttachmentStream.FileName := attFileName;
           end;
           attStreams.Remove(stream);
           attNames.Delete(0);
      end;
    end;

    with idmsg.Recipients.Add do begin
      Address := addr;
    end;
    result := SendEMail(idmsg, emailParams, SMTPIn)
  finally
    idmsg.Free;
  end;
end;

function SendEmailToUser(addr, subj, msg : string; emailParams: TWideStringList):boolean; overload;
begin
  result := SendEmailToUser(addr, subj, msg, emailParams, nil, nil, nil);
end;

{
  Logs the http actions to log file
  uses gLogLevel to set log level details
  returns logLineNo for on-screen presentations (if required)
}
function LogHttp(msg: WideString; params: TWideStrings = nil; lineNo: integer = -1): integer;
begin
  result := LogHttp(nil, msg, params, lineNo);
end;

function LogHttp(e: exception; msg: WideString; params: TWideStrings = nil; lineNo: integer = -1): integer;
begin
  result := -1;

  if (gUseLogFile)and(((gLogLevel > 0)and(e <> nil))or(gLogLevel > 1)) then
  begin
    EnterCriticalSection(CritSectLog);
    try
      try
        inc(logLineNo);
        result := logLineNo;

        if lineNo = -1 then
          lineNo := result;

        WriteLn(gLogFile, '[' + inttostr(lineNo) + '] ' + DateTimeToStr(now) + ' # ' + msg);
        try
          if (e <> nil) then
            WriteLn(gLogFile, e.Message + CRLF + GetStackTrace);
          if (params <> nil) then
            WriteLn(gLogFile, params.Text);
        except
          on ex: exception do
            WriteLn(gLogFile, 'StackTrace Error: ' + ex.message);
        end;

        Flush(gLogFile);
      except
      end;
    finally
      LeaveCriticalSection(CritSectLog);
    end;
  end;
end;

procedure LogHttp2(logFileName: widestring; e: exception; msg: WideString; params: TWideStringList = nil; lineNo: integer = -1);
var logFile: TextFile;
begin
  if ((gLogLevel > 0)and(e <> nil))or(gLogLevel > 1) then
  begin
    EnterCriticalSection(CritSectLog);
    try
      AssignFile(logFile, GetAppPath + logFileName);
      if not FileExists(GetAppPath + logFileName) then
        Rewrite(logFile)
      else
        Append(logFile);

      try
        WriteLn(logFile, DateTimeToStr(now) + ': ' + msg);
        Flush(logFile);
      except
      end;

      CloseFile(logFile);
    finally
      LeaveCriticalSection(CritSectLog);
    end;
  end;
end;

procedure CloseLogFile();
begin
  if gUseLogFile then
  begin
    gUseLogFile := false;
    EnterCriticalSection(CritSectLog);
    try
      try
        CloseFile(gLogFile);
      except
      end;
    finally
      LeaveCriticalSection(CritSectLog);
    end;
  end;
end;

procedure OpenLogFile();
var logFileBase: string;
  function assignLogFile(num: integer): boolean;
  begin
    if num > 20 then
      result := false
    else
    begin
      try
        AssignFile(gLogFile, logFileBase + '_' + inttostr(num) + ExtractFileExt(gLogFileName));
        if not FileExists(logFileBase + '_' + inttostr(num) + ExtractFileExt(gLogFileName)) then
          Rewrite(gLogFile)
        else
          Append(gLogFile);
        result := true;
      except
        result := assignLogFile(num+1);
      end;
    end;
  end;
begin
  EnterCriticalSection(CritSectLog);
  try
    try
      logFileBase := GetAppPath + gLogFolder + ChangeFileExt(gLogFileName, '') + '_' + FormatDateTime('yyyymmdd', now);

      AssignFile(gLogFile, logFileBase + ExtractFileExt(gLogFileName));
      if not FileExists(logFileBase + ExtractFileExt(gLogFileName)) then
        Rewrite(gLogFile)
      else
        Append(gLogFile);
      gUseLogFile := true;
    except
      gUseLogFile := assignLogFile(1);
    end;
  finally
    LeaveCriticalSection(CritSectLog);
  end;
end;
{
  Creates a TDataModule object based on provided module name, if it is registered within application
  used within most requests for execution of contained sql objects
}
function CreateDataModule(DataModuleName: WideString): TDataModule;
var
  cref: TPersistentClass;
begin
  result := nil;
  cref := GetClass('T' + DataModuleName);
  if Assigned(cref) then
    result := TDataModule(TControlClass(cref).Create(nil));
end;

{
  MAIN REQUEST HANLER ENTRY POINT
  requires pre-parsed http parameters and/or input stream (file upload)
  returns JSON result or filled in input stream (file download from DB)
  function behaves the same no matter the call origin (ISAPI, Indy server, WebDebug, ..)
  it extractes the DataModule name and SQL object or module method from the request, creates it and starts sql object execution or module method
}
function HandleAppRequest(method, request, params: WideString; inStream: TMemoryStream): WideString;
var
  dataModuleName, objectName, paramRowId: WideString;
  npos, lineNo: integer;
  dm: TDataModule;
  obj: TComponent;
  slParams: TWideStringList;
  res: WideString;
  resContentType: WideString;
  resVar: variant;
begin
  lineNo := -1;
  dm := nil;
  resContentType := '';
  res := '';
  try
    try
      // assign the html params to the WideStringList lines so we can use NAME=VALUE
      slParams := TWideStringList.Create;

      slParams.Text := params;

      if gLogLevel = 2 then //  0 - no log, 1 - log exceptions, 2 - log requests, 3 - log requests with params, 4 - also log results
        lineNo := LogHttp(nil, '[' + slParams.Values[PARAM_REMOTEIP] + '] ' + method + ' ' + request)
      else
      if gLogLevel > 2 then
        lineNo := LogHttp(nil, '[' + slParams.Values[PARAM_REMOTEIP] + '] ' + method + ' ' + request + ' ' + crlf + params);

      // the complete url is "http://host:port/Method/Module/Object/RowID"  (".../GET/QuoteDetail/Quotes")
      // the method is already parsed in the "method" variable
      // the "request" variable so contains "Module/Object/RowID", RowID is optional

      // parse the url to get the data module and object names and maybe an aditional record id from
      try
        request := StringReplace(request, 'MW/', '', []);

        paramRowId := '';
        npos := pos('/', request);
        // extract data module name from the URL string "Module/Object/RowID"
        dataModuleName := copy(request, 1, npos - 1);
        // extract the object name from the URL string "Module/Object/RowID"
        objectName := copy(request, npos + 1, MaxInt);
        // extract/split aditional parameter as row identifier, if it exists
        npos := pos('/', objectName);
        if npos > 0 then
        begin
          paramRowId := copy(objectName, npos + 1, MaxInt);
          objectName := copy(objectName, 1, npos - 1);
        end;

        if (dataModuleName = 'GET')or(dataModuleName = 'PUT')or(dataModuleName = 'POST')or(dataModuleName = 'DELETE')or(dataModuleName = 'EXEC')or(dataModuleName = 'UPLOAD')or(dataModuleName = 'DOWNLOAD') then
        begin
          method := dataModuleName;
          dataModuleName := objectName;
          objectName := paramRowId;
          paramRowId := '';
          npos := pos('/', objectName);
          if npos > 0 then
          begin
            paramRowId := copy(objectName, npos + 1, MaxInt);
            objectName := copy(objectName, 1, npos - 1);
          end;
        end;

      except
        on e: exception do
        begin
          LogHttp(e, 'ERROR ParseRequest: ' + e.message, slParams, lineNo);
          res := resultFailed('Parse request failed.');
          Exit;
        end;
      end;

      try
        if (res = '') and (objectName <> '') and (objectName[1] <> '_') then
        begin
          if (objectName = 'multi') then
            res := HandleMultipleRequests(slParams, inStream, resContentType)
          else
          begin
            // try to create the DataModule
            dm := CreateDataModule(dataModuleName);
            if Assigned(dm) then
            begin
              slParams.Add('_rowid='+paramRowId);
              slParams.Add('_environment='+gEnvironment);
              slParams.Add('_method='+Method);

              // call the setParams method of the DataModule - if it exists
              // usually for custom params processing by the DataModule, such as storing the _remoteIP etc..
              ExecMethod(dm, 'setParams', slParams, inStream, resContentType);

              // try to find the component in the DataModule
              obj := dm.FindComponent(objectName);
              if Assigned(obj) and (obj is TADOQueryMX) then
              begin  // execute the ADO sql query based on the method (select - GET, update - PUT, insert - POST, delete - DELETE, get as stream - DOWNLOAD)
                resVar := handleADOMethod(lineNo, method, slParams, TADOQueryMX(obj), inStream, resContentType, request);
              end
              else  // try to find the method in the DataModule
              if ObjectHasMethod(dm, objectName) then
              begin  // execute an object method declared in the DataModule
                resVar := ExecMethod(dm, objectName, slParams, inStream, resContentType);
              end
              else
                resVar := resultFailed('Could not find the object or method.');

              // convert resulting variant to string if required, usually JSON notation (could also be memory stream)
              case TVarData(resVar).VType of
                varString : res := resVar;
                varOleStr : res := resVar;
                {$IFDEF VER210} varUString: res := resVar; {$ENDIF}  // delphi 2010
                {$IFDEF VER220} varUString: res := resVar; {$ENDIF}  // delphi XE
              else
                res := resultFailed('Invalid result type.');
            end;

              try
                if gLogLevel = 4 then
                  lineNo := LogHttp('[' + slParams.Values[PARAM_REMOTEIP] + '] ' + method + ' ' + request + ' -> ' + res, nil, lineNo);
              except
              end;
            end
            else
              res := resultFailed('Could not find the module.');
          end;
        end;
      finally
        try
          if Assigned(dm) then
            FreeAndNil(dm);
        except
          on e: exception do
            LogHttp(e, 'ERROR FreeModule: ' + e.message, slParams, lineNo);
        end;
      end;
      FreeAndNil(slParams);
    except
      on e: exception do
      begin
        LogHttp(e, 'ERROR: ' + e.message, nil, lineNo);
        res := resultFailed(e.Message);
      end;
    end;
  finally
    if res = '' then
      result := resultFailed('Middleware created no response.')
    else
    result := res;
  end;
end;

function HandleMultipleRequests(const Params: TWideStrings; InStream: TMemoryStream; var ContentType: WideString): variant;
var paramsAll, selParamName, selParamValue, module, request, query : WideString;
    newParams: TWideStringList;
    jRes, jRes2, jsonValue, jInput: ISuperObject;
    itemSO: TSuperAvlEntry;
    component: TComponent;
    dm: TDataModule;
    i, j, nbrows, totalRequests, execTime: integer;
begin
  result := '{"success": false}';
  totalRequests := 0;
  try
    try
      jRes := TSuperObject.Create();
      //itrerate through all input parameters
      for i := 0 to Params.Count - 1 do
      begin
        module := '';
        query := '';
        nbrows := 0;
        dm := nil;

        //check if parameter starts with '_'
        if(Params.Names[i] <> '') and (Params.Names[i][1] = '_') then
          Continue;

        request:= Params.Names[i];  //get request name
        paramsAll := Params.Values[Params.Names[i]];  //get request parameters

        newParams := TWideStringList.Create();
        jInput := TSuperObject.ParseString(PWideChar(paramsAll), true);   //parse JSON parameters
        //iterate through request JSON parameters
        if jInput <> nil then
        begin
          for itemSO in jInput.AsObject do
          begin
            selParamName:= itemSO.Name;         //get parameter name
            jsonValue:= itemSO.Value;
            selParamValue:= jsonValue.AsString; //get parameter value

            if(selParamName = 'Module') then  //check if parameter contains module information
               module:= selParamValue
            else
            if(selParamName = 'Query') then  //check if parameter contains query information
               query:= selParamValue
            else
              newParams.Add(selParamName+'='+selParamValue);
          end;
          totalRequests := totalRequests + 1;

          // try to create the DataModule
          dm := CreateDataModule(module);
          if Assigned(dm) then
          begin
            // try to find the component in the DataModule
            component := dm.FindComponent(query);
            if Assigned(component) and (component is TADOQueryMX) then
            begin
              for j := 1 to Params.Count - 1 do  //add parameters which starts with '_' (_USER_MXP_ID, _CONTACT_MXP_ID)
                if(Params.Names[j] <> '') and (Params.Names[j][1] = '_') then
                  newParams.Add(Params.Names[j]+'='+Params.Values[Params.Names[j]]);

              execTime := DateUtils.MilliSecondsBetween(Now, 0);

              //create connection and open execute query
              TADOQueryMX(component).Connection := GetConnection(TADOQueryMX(component).Connection);
              ProcessParameters(newParams, TADOQueryMX(component), nil);
              TADOQueryMX(component).Open;

              execTime := DateUtils.MilliSecondsBetween(Now, 0) - execTime;

              //create JSON data
              jRes2 := TSuperObject.Create;
              jRes2.N['data'] := DataSetToJSON(TADOQueryMX(component), false, nbrows);
              jRes2.I['total'] := nbrows;
              jRes2.B['success'] := true;
              jRes2.I['execTime'] := execTime;
              jRes.N[request] := jRes2;
              ReleaseConnection(TADOQueryMX(component).Connection);
            end
            else
              jRes.S[request] := resultFailed('Could not find the object or method.');

            try
              if Assigned(dm) then
                FreeAndNil(dm);
            except
            end;
          end
          else
            jRes.S[request] := resultFailed('Could not find the module.');
        end;

        FreeAndNil(newParams);
      end;
    finally
      jRes.I['total'] := totalRequests;
      jRes.B['success'] := true;
      result := jRes.AsJSon;
    end;
  except
  on e: exception do
    begin
      LogHttp(e, 'ERROR: ' + e.message);
      result := resultFailed(e.Message);
    end;
  end;
end;


initialization
  InitializeCriticalSection(CritSectLog);

finalization
  try
    closeLogFile();
  except
  end;

  try
    DeleteCriticalSection(CritSectLog);
  except
  end;

end.
