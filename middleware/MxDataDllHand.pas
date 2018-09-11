unit MxDataDllHand;

interface

uses Windows, SysUtils, ExtCtrls, Classes, WideStrUtils, WideStrings, HTTPApp, DateUtils;

type
  THandleRequest = function(Method, Request, Params: PWideChar; var Content: Pointer; var ContentLenght: integer): PWideChar; stdcall;
  TFreeString = procedure(p: PWideChar); stdcall;
  TFreeStream = procedure(p: Pointer); stdcall;

function GetAppPath: WideString;

function LoadMxDataDll: THandle;
procedure UnloadMxDatadll;
function CheckForDllUpdate: boolean;
function UpdateDll: boolean;
function IncreaseRequestCount: boolean;
procedure DecreaseRequestCount;

function decodeHTTPRequestParams(unparsedParams: string): WideString;

function LogHttp(ex: Exception; msg: string): integer;

procedure CheckForUpdates();


var
  CritSectUpdate: TRTLCriticalSection;
  DllHandleRequest : THandleRequest = nil;
  DllFreeString: TFreeString = nil;
  DllFreeStream: TFreeStream = nil;
  dllHandle: THandle = 0;
  dllIsUpdating: boolean = false; // important flag which keeps back the http requests
  dllLastUpdateCheck: TDateTime = 0;
  requestCount: integer = 0;

var
  isRunningAsService: boolean = false;

  MX_DLL_NAME: string = 'mxDataDll.dll';
  MX_DLL_UPDATE: string = 'mxDataDll.dll.upd';
  MX_DLL_BACKUP: string = 'mxDataDll.dll.bck.';
  gHttpFolder: string = '';
  gSrvName: string = '';
  gPort: string = '';
  gDEVICE_DEFAULTS: TStringList = nil;
  gDEVICE_DEFAULTS_MD5: string = '';
  gDatabase: string = '';
  gAppPath: WideString = '';
  gLogFolder: WideString = '';

  gLogFileName: WideString = 'MXP_App.log';
  gIniFileName: WideString = 'MXP_App.ini';

  gLogFile: TextFile;
  gLogFileOpened: boolean = false;
  CritSectLogDll: TRTLCriticalSection;
  logLineNo: cardinal = 0;

implementation

{
  Logs an exception to a log file
}
function LogHttp(ex: Exception; msg: string): integer;
var logFile: TextFile;
begin
  EnterCriticalSection(CritSectLogDll);
  try
    try
      AssignFile(logFile, gAppPath + gLogFolder + gLogFileName);
      if not FileExists(gAppPath + gLogFolder + gLogFileName) then
        Rewrite(logFile)
      else
        Append(logFile);

      inc(logLineNo);

      WriteLn(logFile,  '[' + inttostr(logLineNo) + '] ' + DateTimeToStr(now) + ' # ' + msg);
        if (ex <> nil) then
        WriteLn(logFile, ex.Message);

      Flush(logFile);
    except
    end;
    try
      CloseFile(logFile);
      except
      end;
    finally
      LeaveCriticalSection(CritSectLogDll);
    end;

  result := logLineNo;
end;

{
  Get the file system path where this middleware is running
}
function GetAppPath: WideString;
Var
  Test : WideString;
  Res  : Longint;
  CurSize : Longint;
begin
  CurSize := 1024;
  SetLength(Test, CurSize);
  //Res := GetModuleFileNameW(GetModuleHandle(nil), PWideChar(test), CurSize);
  Res := GetModuleFileNameW(HInstance, PWideChar(test), CurSize);
  If (res > curSize) then
  begin
    CurSize := res + 10;
    SetLength(Test, CurSize);
    //Res := GetModuleFileNameW(GetModuleHandle(nil), PWideChar(test), CurSize);
    Res := GetModuleFileNameW(HInstance, PWideChar(test), CurSize);
  end;
  Setlength(Test, Res);
  test := ExtractFileDir(Test);
  if (test[Length(test)] = '\') or (test[Length(test)]='/') then
      SetLength(Test, Length(test) - 1);
  Result := test + '\';

  if Result[3]='?' then  // like "\\?\C:...."
    Delete(result, 1, 4);
end;

// stupid INDY 10 does not parse the utf-8 chars in url right...
// http://stackoverflow.com/questions/2381017/delphi-indy10-http-server-and-extjs-form-submit
function decodeHTTPRequestParams(unparsedParams: string): WideString;
var sParams: WideString;
begin
  try
  {$IFDEF VER210}
    unparsedParams := StringReplace(unparsedParams, '&', '%1F', [rfReplaceAll]);  // change "&" to "unit separator" character, so we can have "&" in the text after decoding
    sParams := UTF8ToWideString(HTTPDecode(UTF8ToString(unparsedParams)));
    sParams := StringReplace(sParams, #13#10, '%0A', [rfReplaceAll]);        // change line feeds back to URL encoding, so we retain the complete line in the params
    sParams := StringReplace(sParams, #10, '%0A', [rfReplaceAll]);        // change line feeds back to URL encoding, so we retain the complete line in the params
    sParams := StringReplace(sParams, #$1F, #13#10, [rfReplaceAll]);        // change the delimiters ("&"->unit separator) into crlf so we can use stringlist as params NAME=VALUE storage
  {$ELSE}
    unparsedParams := StringReplace(unparsedParams, '&', '%1F', [rfReplaceAll]);  // change "&" to "unit separator" character, so we can have "&" in the text after decoding
    sParams := HTTPDecode(unparsedParams);
    sParams := StringReplace(sParams, #13#10, '%0A', [rfReplaceAll]);        // change line feeds back to URL encoding, so we retain the complete line in the params
    sParams := StringReplace(sParams, #10, '%0A', [rfReplaceAll]);        // change line feeds back to URL encoding, so we retain the complete line in the params
    sParams := StringReplace(sParams, #$1F, #13#10, [rfReplaceAll]);        // change the delimiters ("&"->unit separator) into crlf so we can use stringlist as params NAME=VALUE storage
    sParams := UTF8Decode(sParams);
  {$ENDIF}
  except
  end;
  result := sParams;
end;

{
  Load the worker dll
}
function LoadMxDataDll: THandle;
begin
  try
    LogHttp(nil, 'LOADING dll: ' + GetAppPath + MX_DLL_NAME);
    result := LoadLibraryW(PWideChar(GetAppPath + MX_DLL_NAME));

    if result <> 0 then
    begin
      @DllHandleRequest := GetProcAddress(result, 'HandleRequest');
      @DllFreeString := GetProcAddress(result, 'FreeString');
      @DllFreeStream := GetProcAddress(result, 'FreeStream');
    end;
  except
    on e: Exception do
    begin
      LogHttp(e, 'LOADING dll failed ' + e.Message);
      result := 0;
    end;
  end;
  dllHandle := result;
end;

{
  Unload the worker dll
}
procedure UnloadMxDatadll;
begin
  try
    if dllHandle <> 0 then
    begin
      FreeLibrary(dllHandle);
      dllHandle := 0;
    end;
  except
  end;
end;

{
  Checks if an update file exists
}
function CheckForDllUpdate: boolean;
begin
  result := FileExists(GetAppPath + MX_DLL_UPDATE);
  // check file version? or alow the restoration of old versions..
end;

{
  Backup of the worker dll with an incrementable extension
}
function BackupDll: string;
var i: integer;
begin
  i := 1;
  while FileExists(GetAppPath + MX_DLL_BACKUP + inttostr(i)) do
    inc(i);
  result := GetAppPath + MX_DLL_BACKUP + inttostr(i);

  if not CopyFileW(PWideChar(GetAppPath + MX_DLL_NAME), PWideChar(result), true) then
    result := '';
end;

{
  Update worker dll with fallback should anything go wrong
}
function UpdateDll: boolean;      // TODO: CLEANUP AND CHECK !!!
var backupDllName: string;
    retCnt: integer;
begin
  result := false;
  try
    if CheckForDllUpdate then
    begin
      LogHttp(nil, 'UPDATE dll found');

      try
        // create a backup of the current dll
        LogHttp(nil, 'UPDATE backup dll');
        backupDllName := BackupDll;
        if backupDllName = '' then
        begin
          LogHttp(nil, 'UPDATE FAILED could not backup dll: ' + backupDllName);
          Exit;
        end
        else
          LogHttp(nil, 'UPDATE backup dll: ' + backupDllName);
      except
        on e: exception do
        begin
          LogHttp(e, 'UPDATE backup error: ' + e.Message);
          Exit;
        end;
      end;

      try
        // unload the dll
        LogHttp(nil, 'UPDATE unload dll');
        FreeLibrary(dllHandle);
      except
        on e: exception do
          LogHttp(e, 'UPDATE unload dll error: ' + e.message);
        // ignore if there is an error message, for now
      end;

      //Sleep(3000);           // for tests

      LogHttp(nil, 'UPDATE delete dll');
      retCnt := 0;
      while (not DeleteFile(GetAppPath + MX_DLL_NAME))and(retCnt < 30) do
      begin
        inc(retCnt);
        Sleep(100);
      end;

      if (retCnt >= 30) then
      begin                                    // could not delete the original file so reload it back and try again later
        LogHttp(nil, 'UPDATE FAILED could not delete dll');
        LoadMxDataDll;
        Exit;
      end;

      // rename the updating dll and try to load the dll
      LogHttp(nil, 'UPDATE rename update');
      if (not RenameFile(GetAppPath + MX_DLL_UPDATE, GetAppPath + MX_DLL_NAME)) or (LoadMxDataDll = 0) then
      begin
        LogHttp(nil, 'UPDATE rename FAILED reverting');
        // if fails then rename the updating dll back
        RenameFile(GetAppPath + MX_DLL_NAME, GetAppPath + MX_DLL_UPDATE + '.failed');
        // restore the backuped dll
        RenameFile(backupDllName, GetAppPath + MX_DLL_NAME);
        // re-load the previous version
        LogHttp(nil, 'UPDATE reloading old');
        LoadMxDataDll;
      end
      else
        result := true;
    end;
  except
    on e: exception do
      LogHttp(e, 'UPDATE UpdateDll error: ' + e.message);
  end;
end;

{
  Increases the current request count
  it is required so we proceed with updates only when request count is 0
}
function IncreaseRequestCount: boolean;
begin
  result := false;

  while not result do
  begin
    EnterCriticalSection(CritSectUpdate);
    try
      if not dllIsUpdating then
      begin
        inc(requestCount);        // this is how we know we have requests open at the moment
        result := true;
      end
      else
        Sleep(100);               // if we are updating then wait until we finish, check each xx milisecs
    finally
      LeaveCriticalSection(CritSectUpdate);
    end;
  end;
end;

{
  Decreases the request count
}
procedure DecreaseRequestCount;
begin
  EnterCriticalSection(CritSectUpdate);
  try
    dec(requestCount);          // the request has finished so decrease the request count
  finally
    LeaveCriticalSection(CritSectUpdate);
  end;
end;

{
  Checks for updates at every request but only if certain time has elapsed
}
procedure CheckForUpdates();
begin
  EnterCriticalSection(CritSectUpdate);
  try
    if (dllLastUpdateCheck = 0)or(SecondsBetween(Now, dllLastUpdateCheck) > 10) then
    begin
      //LogHttp(nil, 'Checking for update');
      dllLastUpdateCheck := now;
      if CheckForDllUpdate then
      begin
        // check if we can update (only when the dll is idle - no requests at the moment)
        if requestCount = 0 then
        begin
          dllIsUpdating := true;
          try
            UpdateDll;
          finally
            dllIsUpdating := false;
          end;
        end
        else
        begin
          LogHttp(nil, 'UPDATE found BUT requestCount: ' + inttostr(requestCount));
          dllLastUpdateCheck := 0;
        end;
      end;
    end;
  finally
    LeaveCriticalSection(CritSectUpdate);
  end;
end;

initialization
  InitializeCriticalSection(CritSectUpdate);
  InitializeCriticalSection(CritSectLogDll);

finalization
  LogHttp(nil, 'Finalization');
  if dllHandle <> 0 then
    FreeLibrary(dllHandle);
  DeleteCriticalSection(CritSectUpdate);
  DeleteCriticalSection(CritSectLogDll);


end.
