unit mxDataIsapi;

interface

uses
  SysUtils, Classes, HTTPApp, Forms, IniFiles, ActiveX, Dialogs, ExtCtrls, SuperObject;

type
  TWebModule1 = class(TWebModule)
    procedure WebModule1WebActionItem1Action(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1WebActionItem2Action(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WebModule1: TWebModule1;

implementation

uses WebReq,  // WebDebug
     MxDataDllHand, mxDataCommon;

{$R *.dfm}

{
  Extracts the content string from WebRequest object
}
function ExtractContentFieldsMX(webRequest: TWebRequest): string;
var
  ContentStr: string;
  //Strings: TStringList;
begin
  if webRequest.ContentLength > 0 then
  begin
    ContentStr := webRequest.Content;
    if Length(ContentStr) < webRequest.ContentLength then
      ContentStr := ContentStr + webRequest.ReadUnicodeString(webRequest.ContentLength - Length(ContentStr));

    result := ContentStr;
    (*Strings := TStringList.Create;
    try
      // change the %0A with dummy for a while so it doesen't break the stringlist
      ContentStr := StringReplace(ContentStr, '%0A', '%1F', [rfReplaceAll]);
      webRequest.ExtractFields(['&'], [], PChar(ContentStr), Strings);
      ContentStr := StringReplace(ContentStr, #$1F, '%0A', [rfReplaceAll]);

      result := Strings.Text;
    finally
      Strings.Free;
    end;*)
  end;
end;

function EncodingGetBytesCount(const AContentType: AnsiString; const AValue: string): integer;
var
  Encoding: TEncoding;
begin
  Encoding := EncodingFromContentType(AContentType);
  Result := Encoding.GetByteCount(AValue);
end;

{
  MAIN ISAPI ENTRY POINT
  Default action for ISAPI execution
  parses and prepares the parameters and forwardes them to worker dll
}
procedure TWebModule1.WebModule1WebActionItem1Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  req, callback, sParams, content, method, remoteIP, mFileName, sp: WideString;
  npos: integer;
  dllRes: PWideChar;
  contentStream, responseStream: TMemoryStream;
  dllContentStream: Pointer;
  dllStreamSize: integer;
  fs: TFileStream;
  ss: TMemoryStream;
  sss: TStringStream;
  jParams: ISuperObject;
  contentType: String;
begin
  dllRes := nil;
  dllContentStream := nil;
  dllStreamSize := 0;
  contentStream := nil;
  content := '';

  if IncreaseRequestCount then  // wait until the update finishes and inc request count so the update waits until idle state
  try
    CoInitialize(nil);

    try
      remoteIP := Request.RemoteAddr;
      //lineNo := LogHttp(nil, ' ['+remoteIP+'] ' + ARequestInfo.Document);

      req := String(Request.InternalPathInfo); // "/GET/QuoteDetail/Quotes?start=0&limit=500&_dc=1263469395716&callback=stcCallback1014"
      if (req <> '') and (req[1] = '/') then
        Delete(req, 1, 1);

      req := StringReplace(req, 'MXP_App_ISAPI.dll/', '', [rfReplaceAll, rfIgnoreCase]);

      // method := ARequestInfo.Command;  // method is always GET since the ScriptTagProxy routes all requests through <script> tags
      (*npos := pos('/', req);
      method := copy(req, 1, npos - 1); // so we need to extract method from the url, which the Ext developer should provide
      req := copy(req, npos + 1, MaxInt);

      if (method = 'MW') then //or(not((method = 'GET')or(method = 'PUT')or(method = 'POST')or(method = 'DELETE')or(method = 'EXEC')or(method = 'UPLOAD')or(method = 'DOWNLOAD'))) then
        *)
        method := Request.Method;    // if the method is not explicitly set in the URL, we use the browser http command method

      if (gDEVICE_DEFAULTS <> nil)and((req = 'GET/DefaultSettings')or(req = 'DefaultSettings')) then
      begin
        content := resultSuccess(ValuesToJSON(gDEVICE_DEFAULTS));
      end
      else
      if ((req = 'POST/UploadStoresData')or(req = 'UploadStoresData')) then
      begin
        LogHttp(nil, 'UploadStoresData Request');

        try
          fs := TFileStream.Create(GetAppPath + 'dump\' + FormatDateTime('yymmdd-hhnnsszzz', now) + '_' + StringReplace(remoteIP, ':', '-', [rfReplaceAll]) + '.dmp', fmCreate);

          readRequestContent(request, fs);

          content := resultSuccess();
        except
          on e: exception do
            begin
            LogHttp(e, 'ERROR: UploadStoresData Request ' + e.Message);
            content := resultFailed(e.Message);
          end;
        end;
        FreeAndNil(fs);
      end
      else
      // decode an attachment if there is a FILE UPLOAD
      if (pos(WideString('multipart/form-data'), Request.ContentType) > 0) then
      begin
        //LogHttp(nil, 'multipart request');
        contentStream := TMemoryStream.Create;
        ss := TMemoryStream.Create;
        try
          readRequestContent(request, ss);

        ss.Position := 0;

        // decode the uploaded file into stream (is a part of the form data MIME)
        mFileName := DecodeFormData(contentStream, sParams, '', ss);
        sParams := sParams + #13#10 + PARAM_FILENAME + '=' + mFileName;  // internal parameter for uploaded file name
        sParams := sParams + #13#10 + PARAM_FILESIZE + '=' + inttostr(contentStream.Size);  // internal parameter for uploaded file size


        dllContentStream := contentStream.Memory;
        dllStreamSize := contentStream.Size;
        finally
          FreeAndNil(ss);
        end;
      end
      else
      // large forms
      if (pos(WideString('application/x-www-form-urlencoded'), Request.ContentType) > 0) then
      begin
        //LogHttp(nil, 'application request: ' + Request.ContentType);
        sss := TStringStream.Create;
        try
          readRequestContent(request, sss);

          sParams := decodeHTTPRequestParams(sss.DataString);
        finally
          sss.Free;
        end;
      end
      else
      if pos(WideString('application/json'), Request.ContentType) > 0 then
      begin
        ss := TMemoryStream.Create;
        try
          // read contents into memory stream
          readRequestContent(request, ss);

          ss.Position := 0;
          jParams := DecodeJSONData(ss);
          if jParams.IsType(TSuperType.stObject) then
          begin
            JSONtoParams(jParams, sParams);
            jParams := nil;
          end;

        finally
          ss.Free;
        end;
      end
      else
      begin
        sParams := ExtractContentFieldsMX(Request);
        sParams := decodeHTTPRequestParams(sParams);

        if (Request.QueryFields.Text <> '') then
        begin
          sp := UTF8Decode(Request.QueryFields.Text);

          if (sParams <> '') then
            sParams := sParams + #13#10 + sp
          else
            sParams := sp;
        end;
      end;

      sParams := sParams + #13#10 + PARAM_REMOTEIP + '=' + remoteIP;  // internal parameter for remote requestor IP

      // MAIN REQUEST HANDLER   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      if content = '' then
      if (assigned(DllHandleRequest)) then
        dllRes := DllHandleRequest(PWideChar(method), PWideChar(req), PWideChar(sParams), dllContentStream, dllStreamSize)
      else
        Response.Content := 'Could not load the dll at: ' + GetAppPath;

      if (dllRes <> nil) and (Pos('#MIME:', dllRes) = 1) then
        contentType := Copy(dllRes, 7, Length(dllRes) - 6);

    except
      on e: exception do
      begin
        LogHttp(e, ' (ERROR: '+ e.Message + ')');
        Response.Content := '{"success":false,"error":"DLL handle request error: ' + e.message + '"}';
        Response.ContentLength := length(UTF8Encode(Response.Content));  // count the length of the UTF8 string
      end;
    end;

    try
      // result is a STREAM, copy it, assign it as a result and tell the dll to free it (also check if it's not the same stream we sent into)
      if (dllContentStream <> nil)and(dllStreamSize > 0)and((contentStream = nil)or(dllContentStream <> contentStream.Memory))then
      begin
        responseStream := TMemoryStream.Create;
        responseStream.Write(dllContentStream^, dllStreamSize);     // copy the memory from dll to our stream

        responseStream.Position := 0;
        Response.Content := '';

        //Response.ContentType := aMIMEMap.GetFileMIMEType(req); // RD
        if contentType <> '' then
          Response.ContentType := contentType
        else
          Response.ContentType := 'application/octet-stream';

        //Response.ContentType := 'application/octet-stream';     //'application/x-download'
        //Response.SetCustomHeader('Content-disposition', 'attachment;');  //'Content-disposition: attachment; filename=movie.mpg'
        Response.ContentStream := responseStream; // the ResponseInfo will also free the stream
        Response.SendResponse;

        DllFreeStream(dllContentStream);  // tell the dll to free the memory from the outgoing stream

        if Assigned(dllRes) then
          DllFreeString(dllRes);   // tell the dll to free the memory from the resulting string
      end
      else
      begin
        Response.ContentType := 'text/html; charset=UTF-8;';  //'text/x-json; charset=UTF-8;' image uploading result expected text/html...

        // copy the RESULT string JSON and tell the dll to free it
        if Assigned(dllRes) then
        begin
          content := dllRes;
          DllFreeString(dllRes);   // tell the dll to free the memory from the resulting string
        end;

        // string response, probably as JSON
        Response.ContentType := 'text/html; charset=UTF-8;';  //'text/x-json; charset=UTF-8;' image uploading result expected text/html...
        Response.Content := content;

        if Response.Content = '' then
          Response.Content := '{"success":false,"error":"No response"}';

        // if a CALLBACK is defined, then prepand it to the resulting JSON
        if callback <> '' then
        begin  // fix the response to support the ScriptTagProxy in ExtJS for cross domain requests using the <script>
          Response.ContentType := 'text/javascript; charset=UTF-8;';
          Response.Content := callback + '(' + Response.Content + ');';
        end;

        Response.ContentLength := EncodingGetBytesCount(Response.ContentType, Response.Content);  // count the length of the UTF8 string
      end;
    except
      on e: exception do
      begin
        LogHttp(e, ' (ERROR: '+ e.Message + ')');
        Response.Content := '{"success":false,"error": "'+e.Message+'"}';
        Response.ContentLength := EncodingGetBytesCount(Response.ContentType, Response.Content);   // count the length of the UTF8 string
      end;
    end;
    CoUnInitialize;
  finally
    DecreaseRequestCount;   // explicitly defined in finally since it's important
    CheckForUpdates();
  end;
end;

{
  File download function
  used only for web debugger, IIS serves normal web file requests
}
procedure TWebModule1.WebModule1WebActionItem2Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var LFile: TFileStream;
    fileName: string;
begin
  try  // ONLY FOR WEB DEBUGGER, iis should handle file serving
    fileName := Request.InternalPathInfo;
    fileName := GetAppPath + gHttpFolder+ fileName;

    if fileExists(fileName) then
    begin
      LFile := TFileStream.Create(fileName, fmOpenRead);
      Response.SetCustomHeader('Content-Disposition', 'filename=' + ExtractFileName(fileName));
      Response.ContentStream := LFile;
    end;
  except
    Response.Content := 'Error while serving the requested file';
  end;
end;

{
  Load settings from ini file
}
procedure LoadSettings();
var ini: TIniFile;
begin
  gAppPath := GetAppPath;

  try
    ini := TIniFile.Create(GetAppPath + gIniFileName);
    try
      gSrvName := ini.ReadString('SERVICE', 'SrvName', 'MXDataServ');
      MX_DLL_NAME := ini.ReadString('SERVICE', 'DllFileName', MX_DLL_NAME);
      MX_DLL_UPDATE := MX_DLL_NAME + '.upd';
      MX_DLL_BACKUP := MX_DLL_NAME + '.bck.';

      if gDEVICE_DEFAULTS = nil then
        gDEVICE_DEFAULTS := TStringList.Create;
      ini.ReadSectionValues('DEVICE_DEFAULTS', gDEVICE_DEFAULTS);

      gHttpFolder := ini.ReadString('WEB', 'WebRoot', 'httpdocs');

      gLogFileName := ini.ReadString('WEB', 'LogFileName', gLogFileName);
      gLogFolder := ini.ReadString('WEB', 'LogFolder', '');

      gLogFileName := ChangeFileExt(gLogFileName, '') + '_ISAPI' + ExtractFileExt(gLogFileName);
      if (gLogFolder <> '')and(gLogFolder[length(gLogFolder)] <> '\') then
        gLogFolder := gLogFolder + '\';
    finally
      ini.Free;
    end;
  except
  end;
end;

initialization
  if WebRequestHandler <> nil then    // WebDebug
    WebRequestHandler.WebModuleClass := TWebModule1;

  LoadSettings;
  LoadMxDataDll;

finalization
  UnloadMxDatadll;

end.

