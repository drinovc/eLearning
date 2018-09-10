unit mxDataCommon;

interface

uses
  SysUtils, typInfo, Classes, Forms, DB, ADODB, MxADO, DateUtils,
  ActiveX, Windows, Controls, Variants, IdMessage, SuperObject, WideStrings,
  AppEvnts, HTTPApp, IdMessageCoder, IdMessageCoderMIME, IdMessageParts, IdURI, Graphics, Types, jpeg,
  PngImage, ShellApi, Math, IdHashMessageDigest, idHash;

type
  TExec = function(const Params: TWideStrings; InStream: TMemoryStream; var ContentType: WideString): variant of object;

function prepareGUID(value: string): string;
function trimGUID(value: string): string;
function trimUserGUID(value: string; var userGUID: string): string;

function jsonStringEncode(value: string): string;
function FieldToJSONString(field: TField): string;
function ExecMethod(OnObject: TObject; MethodName: string; const Params: TWideStrings; InStream: TMemoryStream; var ContentType: WideString): variant; overload;
function ObjectHasMethod(OnObject: TObject; MethodName: string): boolean;
function GetAppPath: WideString;
function resultFailed(reason: string): string; overload;
procedure resultFailed(jRes: ISuperObject; reason: string); overload;
procedure resultJson(jRes: ISuperObject; reason: string = ''; success: boolean = false);
function resultSuccess(jData: ISuperObject): string; overload;
function resultSuccess(reason: string = ''): string; overload;
procedure resultSuccess(jRes: ISuperObject; reason: string); overload;
function resultSuccess(jData: ISuperObject; total: integer): string; overload;

procedure ValuesToJSON(sl: TStrings; jData: ISuperObject); overload;
function ValuesToJSON(sl: TStrings): ISuperObject; overload;
function ValuesToJSON(s: string): ISuperObject; overload;
function ValuesToJSONString(sl: TStrings): string;
function FieldTypeToJSONType(fieldType: TFieldType): string;

function VariantToStream(const AVariant : variant; var AStream : TStream) : Int64;
function StreamToVariant(const AStream : TStream) : variant;

function DecodeFormData(Dest: TStream; var DestParams: WideString; const Header: String; ASourceStream: TStream): string;
function DecodeJSONData(ASourceStream: TStream): ISuperObject; overload;
function DecodeJSONData(ASourceStream: TStream; var DestParams: WideString): integer; overload;
function JSONtoParams(AJson: ISuperObject; var DestParams: WideString): integer;

function readRequestContent(request: TWebRequest; sss: TStream): integer;

function replaceNonAlphaNumChars(value: string; replaceChar: Char = '_'): string;

procedure ObjectToParameters(Obj: TObject; query: TADOQuery);
procedure ByteArrayToFile(const ByteArray: TByteDynArray; const FileName: string);
function FileToByteArray(const FileName: string): TByteDynArray;

function EncodeParams(value: WideString): WideString;
function StripHTML(S: string): string;
function CheckImage(var imageStream: TMemoryStream): boolean;
function ResizeImage(var imageStream: TMemoryStream; maxWidth, maxHeight : Integer; Out width: Integer; Out height: Integer): boolean;

function getMaxContentFromParams(aParams: WideString): integer;
function GetImageSubContentType(ext: WideString): WideString;

procedure RunAndWaitShell(Executable, Parameter, Directory: STRING; ShowParameter: INTEGER);
function RunAndWaitShellWithExitCode(Executable, Parameter, Directory: STRING; ShowParameter: INTEGER): DWORD;
function ExecAndWait(const FileName, Params: string; const CmdShow: Integer): DWORD;
function ExecAndReadPipe(const FileName, Params: string; const CmdShow: Integer; var PipeOutput: String): DWORD;
function ExecAndReadOutput(var StdOutOutput: String; CommandLine: String; Work: String = 'C:\MXP'): DWORD;

function isEmpty(const value: WideString; const replaceValue: WideString): WideString; overload;
function isEmpty(const value: WideString; const replaceValue: integer): integer; overload;

function MD5(const value: string): string;

(*function ZCompressString(aText: string; aCompressionLevel: TZCompressionLevel = zcMax): string; overload;
procedure ZCompressString(aText: string; toStream: TStream; aCompressionLevel: TZCompressionLevel = zcMax); overload;
function ZDecompressString(aText: string): string;*)

Type
  tEmailAddressValidity =
      (eOK, eUnknownError, eBlank,
      eNoSeparator, eUserTooLong,
      eDomainTooLong, eInvalidChar, eNoUser,
      eNoDomain, eNoDomainSeparator,
      eTooManyAtSymbols, eUserStartsWithPeriod,
      eUserEndsWithPeriod, eDomainStartsWithPeriod,
      eDomainEndsWithPeriod, eUser2SequentialPeriods,
      eDomain2SequentialPeriods, eSubdomainInvalidStartChar,
      eSubdomainInvalidEndChar, eTooShortGeneralDomain);

Function EmailAddressValidity(const Address: String): tEmailAddressValidity;
Function EmailAddressValidityError2String(ErrorCode: tEmailAddressValidity): String;

const
  PARAM_FILENAME = '_FILE_NAME';
  PARAM_FILESIZE = '_FILE_SIZE';
  PARAM_FILECONTENTS = '_FILE_CONTENTS';
  PARAM_REMOTEIP = '_REMOTE_IP';
  PARAM_SESSIONID = '_SESSION_ID';
  PARAM_URLHOST = '_URLHOST';
  PARAM_BROWSERTIME = 'BROWSER_TIME';

  gMaxContentLength = 50*1024*1024;
  CRLF = #13#10;
  CR = #13;
  CR2 = #13#13;

implementation

uses mxDataADO, mxDataRequest, IdGlobal, IdGlobalProtocols, IdCoderHeader;


{
  creates GUID notation from condensed string representation
}
function prepareGUID(value: string): string;
begin
  // prepare GUID '{xxxxxxxx–xxxx–xxxx–xxxx–xxxxxxxxxxxx}'
  result := value;
  if (value <> '') and (value[1] <> '{') then
    result := '{' + copy(value, 1, 8) + '-' + copy(value, 9, 4) + '-' + copy
      (value, 13, 4) + '-' + copy(value, 17, 4) + '-' + copy(value, 21, 12) + '}';
end;

function trimGUID(value: string): string;
begin
  result := value;
  result := StringReplace(result, '{', '', [rfReplaceAll]);
  result := StringReplace(result, '}', '', [rfReplaceAll]);
  result := StringReplace(result, '-', '', [rfReplaceAll]);
end;

{ two part guid, first log_in_code, second user GUID
  GUID=F2F23538BABE48F08257B41856220BCBC3-D3F69794-0B6A-4613-94C7-A11EF2B1C70F
}
function trimUserGUID(value: string; var userGUID: string): string;
var ind: integer;
begin
  userGUID := '';
  ind := pos('-', value);
  if (ind > 32)and(length(value) > 68) then
  begin
    result := copy(value, 1, ind-1);
    userGUID := copy(value, ind+1, MaxInt);
    userGUID := prepareGUID(trimGUID(userGUID));
  end
  else
    result := value;
end;

{
  special string routines for database value to JSON processing
}
function jsonStringEncode(value: string): string;
begin
  result := trim(value);
  // this is now done in the json superobject
  // in the quotes response
  // result := StringReplace(result, #$D#$A, '<br />', [rfReplaceAll]);
  (*result := StringReplace(result, '\', '\\', [rfReplaceAll]);
  result := StringReplace(result, #$D#$A, '\n', [rfReplaceAll]);
  result := StringReplace(result, #$A, '\n', [rfReplaceAll]);
  result := StringReplace(result, '"', '\"', [rfReplaceAll]);*)
end;

{
  Creates a JSON for failed requests
  requires a reason for failure
}
function resultFailed(reason: string): string;
var res: ISuperObject;
begin
  res := TSuperObject.Create();
  resultFailed(res, reason);
  result := res.AsJSon;
end;

procedure resultFailed(jRes: ISuperObject; reason: string);
begin
  jRes.B['success'] := false;
  jRes.S['reason'] := StringReplace(trim(reason), CRLF, '</br>', [rfReplaceAll]);
  jRes.S['ver'] := gClientVer;
end;

function resultSuccess(reason: string = ''): string;
var res: ISuperObject;
begin
  res := TSuperObject.Create();
  resultSuccess(res, reason);
  result := res.AsJSon;
end;

procedure resultJson(jRes: ISuperObject; reason: string = ''; success: boolean = false);
begin
  jRes.B['success'] := success;
  if (reason <> '') then
    jRes.S['reason'] := reason;
end;

procedure resultSuccess(jRes: ISuperObject; reason: string);
begin
  jRes.B['success'] := true;
  if reason <> '' then
    jRes.S['reason'] := StringReplace(trim(reason), CRLF, '</br>', [rfReplaceAll]);
end;

function resultSuccess(jData: ISuperObject; total: integer): string;
var jRes: ISuperObject;
begin
  jRes := TSuperObject.Create;
  jRes.O['data'] := jData;
  jRes.I['total'] := total;
  jRes.B['success'] := true;
  jRes.S['ver'] := gClientVer;
  result := jRes.AsJSon;
end;

function resultSuccess(jData: ISuperObject): string;
var jRes: ISuperObject;
begin
  jRes := TSuperObject.Create;
  jRes.O['data'] := jData;
  jRes.B['success'] := true;
  jRes.S['ver'] := gClientVer;
  result := jRes.AsJSon;
end;

procedure ValuesToJSON(sl: TStrings; jData: ISuperObject);
var i: integer;
begin
  for i:=0 to sl.Count-1 do
    jData.S[sl.Names[i]] := sl.ValueFromIndex[i];
end;

function ValuesToJSON(sl: TStrings): ISuperObject;
begin
  result := TSuperObject.Create;
  ValuesToJSON(sl, result);
end;

function ValuesToJSON(s: String): ISuperObject;
var sl: TStringList;
begin
  sl := TStringList.Create;
  sl.Text := s;
  result := ValuesToJSON(sl);
  sl.Free;
end;

function ValuesToJSONString(sl: TStrings): string;
var jRes: ISuperObject;
begin
  jRes := ValuesToJSON(sl);
  result := jRes.AsJSon();
end;
{
  Returns a JSON string representation of a field contents
  usefull for standard date encoding
}
function FieldToJSONString(field: TField): string;
var fs: TFormatSettings;
begin
  GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, fs);
  fs.DateSeparator := '/';

   case field.DataType of
    //ftGuid:
    //ftDateTime: result := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', field.AsDateTime)   // 2010-02-22 00:00:00.000
      ftDateTime:
      begin
        if SameDateTime(EncodeDate(1899, 12, 30), field.AsDateTime) then
          result := ''
        else
          result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', field.AsDateTime);   // 2010-02-22T00:00:00.000
      end;
    else
      result := field.AsString;
  end;
end;

{
  Executes a specified method (function) on provided object, which should generally be TDataModule
    requires standard parameters for http request execution
}
function ExecMethod(OnObject: TObject; MethodName: string; const Params: TWideStrings; InStream: TMemoryStream; var ContentType: WideString): variant;
var
  Routine: TMethod;
  Exec: TExec;
begin
  Routine.Data := Pointer(OnObject);
  Routine.Code := OnObject.MethodAddress(MethodName);
  if not Assigned(Routine.Code) then
    Exit;
  Exec := TExec(Routine);
  result := Exec(Params, InStream, ContentType);
end;

{
  Check if a provided object contains an addressable method by its name
}
function ObjectHasMethod(OnObject: TObject; MethodName: string): boolean;
begin
  result := Assigned(OnObject.MethodAddress(MethodName));
end;

{
  Returns a file system path where this middleware is running
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
    //Res := GetModuleFilenameW(GetModuleHandle(nil), PWideChar(test), CurSize);
    Res := GetModuleFilenameW(HInstance, PWideChar(test), CurSize);
  end;
  Setlength(Test, Res);
  test := ExtractFileDir(Test);
  if (test[Length(test)] = '\') or (test[Length(test)]='/') then
      SetLength(Test, Length(test) - 1);
  Result := test + '\';

  if Result[3]='?' then  // like "\\?\C:...."
    Delete(result, 1, 4);
end;

{
  Convert ADO field type name to ExtJS json store type name
}
function FieldTypeToJSONType(fieldType: TFieldType): string;
begin
  case fieldType of
    ftString, ftFmtMemo, ftMemo, ftFixedChar, ftWideString, ftFixedWideChar, ftWideMemo:
      result := 'string';
    ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint:
      result := 'int';
    ftBCD, ftFloat, ftCurrency, ftFMTBcd:
      result := 'float';
    ftTimeStamp, ftDate, ftTime, ftDateTime:
      result := 'date';
    ftBoolean:
      result := 'boolean';
    (* ftUnknown: ;
      ftBytes: ;
      ftVarBytes: ;
      ftBlob: ;
      ftGraphic: ;
      ftParadoxOle: ;
      ftDBaseOle: ;
      ftTypedBinary: ;
      ftCursor: ;
      ftADT: ;
      ftArray: ;
      ftReference: ;
      ftDataSet: ;
      ftOraBlob: ;
      ftOraClob: ;
      ftVariant: ;
      ftInterface: ;
      ftIDispatch: ;
      ftOraTimeStamp: ;
      ftOraInterval: ;
      ftConnection: ;
      ftParams: ;
      ftStream: ;
      ftTimeStampOffset: ;
      ftObject: ; *)
    else
      result := 'auto';         // (Default, implies no conversion)
  end;
end;

{
  Convert a variant array to stream
}
function VariantToStream(const AVariant : variant; var AStream : TStream) : Int64;
var
  p: Pointer;
begin
  AStream.Position := 0;
  p := VarArrayLock(AVariant);
  AStream.Write(p ^, VarArrayHighBound(AVariant, 1)+1);
  VarArrayUnlock(AVariant);
  AStream.Position := 0;
  Result := AStream.Size;
end;

{
  Convert a stream to variant array
}
function StreamToVariant(const AStream : TStream) : variant;
var
  MyBuffer: Pointer;
begin
  if Assigned(AStream) then
  begin
    Result   := VarArrayCreate([0, AStream.Size - 1], VarByte);
    MyBuffer := VarArrayLock(Result);
    AStream.ReadBuffer(MyBuffer^, AStream.Size);
    VarArrayUnlock(Result);
  end
  else
    result := Null;
end;

{
  Decode a HTML form data
    parses the Body of the HTTP request to extract the form field values
    also extractes file contents if they are included in the post
}

function DecodeFormData(Dest: TStream; var DestParams: WideString; const Header: String; ASourceStream: TStream): string;
var
 MsgEnd: Boolean;
 Decoder: TIdMessageDecoder;
 ln, prevLn, paramName: String;
 boudaryStartLen: integer;
 attachmentStart, attachmentEnd: integer;
 decodeCount: integer;
 parseCount: integer;

   // from IdMessageCoderMIME, IdGlobalProtocls, IdGlobal, IdMessageCoder
    const
      token_specials = '()<>@,;:\"/[]?='; {do not localize}
    procedure SplitHeaderSubItemsMX(AHeaderLine: String; AItems: TStrings);
    var
      LName, LValue: String;
      I: Integer;

      function FetchQuotedString(var VHeaderLine: string): string;
      begin
        Result := '';
        Delete(VHeaderLine, 1, 1);
        I := 1;
        while I <= Length(VHeaderLine) do
        begin
          (*if VHeaderLine[I] = '\' then begin     // MK: IE full path fix
            if I < Length(VHeaderLine) then begin
              Delete(VHeaderLine, I, 1);
            end;
          end
          else *)if VHeaderLine[I] = '"' then begin
            Result := Copy(VHeaderLine, 1, I-1);
            VHeaderLine := Copy(VHeaderLine, I+1, MaxInt);
            Break;
          end;
          Inc(I);
        end;
        Fetch(VHeaderLine, ';');
      end;

    begin
      Fetch(AHeaderLine, ';'); { do not localize}
      while AHeaderLine <> '' do
      begin
        AHeaderLine := TrimLeft(AHeaderLine);
        if AHeaderLine = '' then begin
          Exit;
        end;
        LName := Trim(Fetch(AHeaderLine, '=')); {do not localize}
        AHeaderLine := TrimLeft(AHeaderLine);
        if TextStartsWith(AHeaderLine, '"') then {do not localize}
        begin
          LValue := FetchQuotedString(AHeaderLine);
        end else
        begin
          I := FindFirstOf(' ' + token_specials, AHeaderLine);
          if I <> 0 then
          begin
            LValue := Copy(AHeaderLine, 1, I-1);
            if AHeaderLine[I] = ';' then begin {do not localize}
              Inc(I);
            end;
            Delete(AHeaderLine, 1, I-1);
          end else
          begin
            LValue := AHeaderLine;
            AHeaderLine := '';
          end;
        end;
        if (LName <> '') and (LValue <> '') then begin
          AItems.Add(LName + '=' + LValue);
        end;
      end;
    end;

    function ExtractHeaderSubItemMX(const AHeaderLine, ASubItem: String): String;
    var
      LItems: TStringList;
      {$IFNDEF VCL6ORABOVE}
      I: Integer;
      LTmp: string;
      {$ENDIF}
    begin
      Result := '';
      LItems := TStringList.Create;
      try
        SplitHeaderSubItemsMX(AHeaderLine, LItems);  // MK
        {$IFDEF VCL6ORABOVE}
        LItems.CaseSensitive := False;
        Result := LItems.Values[ASubItem];
        {$ELSE}
        for I := 0 to LItems.Count-1 do
        begin
          if TextIsSame(LItems.Names[I], ASubItem) then
          begin
            LTmp := LItems.Strings[I];
            Result := Copy(LTmp, Pos('=', LTmp)+1, MaxInt); {do not localize}
            Break;
          end;
        end;
        {$ENDIF}
      finally
        LItems.Free;
      end;
    end;
    function RemoveInvalidCharsFromFilenameMX(const AFilename: string): string;
    var
      LN: integer;
    begin
      Result := AFilename;
      //First, strip any Windows or Unix path...
      for LN := Length(Result) downto 1 do begin
        if ((Result[LN] = '/') or (Result[LN] = '\')) then begin  {do not localize}
          Result := Copy(Result, LN+1, MaxInt);
          Break;
        end;
      end;
      //Now remove any invalid filename chars.
      //Hmm - this code will be less buggy if I just replace them with _
      for LN := 1 to Length(Result) do begin
        // MtW: WAS: if Pos(Result[LN], ValidWindowsFilenameChars) = 0 then begin
        if Pos(Result[LN], InvalidWindowsFilenameChars) > 0 then begin
          Result[LN] := '_';    {do not localize}
        end;
      end;
    end;
    function GetAttachmentFilenameMX(const AContentType, AContentDisposition: string): string;
    var
      LValue: string;
    begin
      LValue := ExtractHeaderSubItemMX(AContentDisposition, 'filename'); {do not localize}  // MK
      if LValue = '' then begin
        // Get filename from Content-Type
        LValue := ExtractHeaderSubItemMX(AContentType, 'name'); {do not localize}
      end;
      if Length(LValue) > 0 then begin
        Result :=RemoveInvalidCharsFromFilenameMX(DecodeHeader(LValue));
      end else begin
        Result := '';
      end;
    end;


begin
  MsgEnd := False;
  Decoder := TIdMessageDecoderMIME.Create(nil);
  try
    Decoder.SourceStream := ASourceStream;
    Decoder.FreeSourceStream := False;
    TIdMessageDecoderMIME(Decoder).MIMEBoundary := Decoder.ReadLn;  // the first line is the boundary

    boudaryStartLen := length(TIdMessageDecoderMIME(Decoder).MIMEBoundary);

    decodeCount := 0;
    repeat
      inc(decodeCount);

      if (decodeCount > (ASourceStream.Size / 10)) then
        raise Exception.Create('Decode count exceeded');

      Decoder.ReadHeader;
      if Decoder.Headers.Text <> '' then
      begin
        try
          parseCount := 0;
          attachmentStart := ASourceStream.Position;
          repeat
            inc(parseCount);
            if (parseCount > ASourceStream.Size) then
              raise Exception.Create('Parse count exceeded');

            prevLn := ln;
            ln := Decoder.ReadLn;
            if (Decoder.SourceStream.Position >= Decoder.SourceStream.Size-1) then
              MsgEnd := true;
          until (MsgEnd)or(CompareText(Copy(ln, 1, boudaryStartLen), TIdMessageDecoderMIME(Decoder).MIMEBoundary) = 0);

          if (Decoder.FileName <> '') then
          begin
            //result := ExtractFileName(Decoder.FileName);
            result := ExtractFileName(GetAttachmentFilenameMX(Decoder.Headers.Values['Content-Type'], Decoder.Headers.Values['Content-Disposition']));

            attachmentEnd := ASourceStream.Position - (length(ln) + 4);
            ASourceStream.Position := attachmentStart;
            Dest.CopyFrom(ASourceStream, attachmentEnd - attachmentStart);
            ASourceStream.Position := attachmentEnd;
            Decoder.ReadLn;
            Decoder.ReadLn;
            MsgEnd := false;
          end
          else
          begin
            paramName := copy(Decoder.Headers.Text, pos('name="', Decoder.Headers.Text)+6, MaxInt);
            paramName := copy(paramName, 1, pos('"', paramName)-1);

            if DestParams = '' then
              DestParams := paramName + '=' + prevLn
            else
              DestParams := DestParams + #13#10 + paramName + '=' + prevLn;
          end;

          Decoder.Headers.Clear;
          //Decoder := Decoder.ReadBody(Dest, MsgEnd);      // the readbody does not work, it appears to be for text only
        finally
        end;
      end;
    until (Decoder = nil) or MsgEnd;
  finally
    FreeAndNil(Decoder);
  end;
end;

function DecodeJSONData(ASourceStream: TStream; var DestParams: WideString): integer;
var sstream: TStringStream;
    json: ISuperObject;
    item: TSuperAvlEntry;
    val: WideString;
begin
  result := 0;
  sstream := TStringStream.Create();
  try
    sstream.CopyFrom(ASourceStream, 0);
    json := SO(sstream.DataString);

    for item in json.AsObject do
    begin
      val := item.Value.AsString;

      val := StringReplace(val, #13#10, '%0A', [rfReplaceAll]);        // change line feeds back to URL encoding, so we retain the complete line in the params
      val := StringReplace(val, #10, '%0A', [rfReplaceAll]);        // change line feeds back to URL encoding, so we retain the complete line in the params

      if DestParams = '' then
        DestParams := item.Name + '=' + val
      else
        DestParams := DestParams + #13#10 + item.Name + '=' + val;

      inc(result);
    end;
  finally
    sstream.Free;
  end;
end;

function DecodeJSONData(ASourceStream: TStream): ISuperObject;
var sstream: TStringStream;
    json: ISuperObject;
begin
  sstream := TStringStream.Create();
  try
    sstream.CopyFrom(ASourceStream, 0);
    result := SO(sstream.DataString);
  finally
    sstream.Free;
  end;
end;

function JSONtoParams(AJson: ISuperObject; var DestParams: WideString): integer;
var item: TSuperAvlEntry;
    val: WideString;
begin
  result := 0;
  for item in AJson.AsObject do
  begin
    val := item.Value.AsString;

    val := StringReplace(val, #13#10, '%0A', [rfReplaceAll]);        // change line feeds back to URL encoding, so we retain the complete line in the params
    val := StringReplace(val, #10, '%0A', [rfReplaceAll]);        // change line feeds back to URL encoding, so we retain the complete line in the params

    if DestParams = '' then
      DestParams := item.Name + '=' + val
    else
      DestParams := DestParams + #13#10 + item.Name + '=' + val;

    inc(result);
  end;
end;

// read contents contents into stream
function readRequestContent(request: TWebRequest; sss: TStream): integer;
var Buffer: array of Byte;
    BytesRead, TotalBytes, RemainingBytes, BufferSize, emtpyCount: integer;
begin
  emtpyCount := 0;
  BytesRead := 0;
  emtpyCount := 0;
  TotalBytes := Request.ContentLength;
  RemainingBytes := TotalBytes - Length(Request.RawContent);

  BufferSize := 32 * 1024;

  // read the request into file stream
  sss.WriteBuffer(BytesOf(Request.RawContent)[0], length(Request.RawContent));
  // must read the rest of the contents by hand
  if (RemainingBytes > 0) then
  begin
    SetLength(Buffer, BufferSize);

    try
      BytesRead := Request.ReadClient(Buffer[0], Min(RemainingBytes, BufferSize));
      while (RemainingBytes > 0)  do
      begin
        if (BytesRead > 0) then
        begin
          sss.Write(Buffer[0], BytesRead);

          Dec(RemainingBytes, BytesRead);

          emtpyCount := 0;
        end
        else
        begin
          inc(emtpyCount);  // if we read nothing we wait for up to 10 seconds for upload to continue
          sleep(100);
        end;

        if (RemainingBytes > 0)and(emtpyCount < 50) then
          BytesRead := Request.ReadClient(Buffer[0], Min(RemainingBytes, BufferSize));
      end;
    finally
      SetLength(Buffer, 0);
    end;
  end;

  result := sss.Size;

  if emtpyCount >= 50 then
    raise Exception.Create('Request upload 5 sec timeout exceeded!');
end;


{
  removes all non-alphanumerical characters from string
}
function replaceNonAlphaNumChars(value: string; replaceChar: Char = '_'): string;
var i: integer;
begin
  result := value;
  for i:=1 to length(value) do
    case value[i] of
      'A'..'Z', 'a'..'z', '0'..'9' :
      begin
      end // No action
      else
        result[i] := replaceChar;
    end;
end;

{
  validate email address
}

Const
  cMaxDomainPortion=256;
  cMaxUserNamePortion=64;

Function EmailAddressValidity (const Address: String)
  : tEmailAddressValidity;

  Var
    AllowedChars: set of Char;
    DataLen: Integer;
    SepPos, LastSep, SepCount, PrevSep: Integer;
    fI: Integer;
    DomainStrLen, UserStrLen: Integer;
    UserStr, DomainStr, SubDomain: String;

Begin
  Try
    { 1. Check: Blank, No @, or invalid characters }

    { Is it blank? }
    DataLen:= Length(Address);
    If DataLen=0 then begin
      Result:= eBlank;
      Exit;
    end;

    { Has @? }
    SepPos:= Pos ('@', Address);
    If SepPos=0 then begin
      Result:= eNoSeparator;
      Exit;
    end;

    { Invalid characters? }
    AllowedChars:=
      ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
      'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
      '0', '1', '2', '3', '4', '5', '6', '7','8', '9', '@', '-', '.',
      '_', '''', '+', '$', '/', '%'];

    For fI:= 1 to DataLen do begin
      If NOT (Address[fI] in AllowedChars) then begin
        Result:= eInvalidChar;
        Exit;
      end;
    end;

    { 2. Split the string in 2: User and Domain }

    UserStr:= Copy(Address, 1, SepPos -1);
    DomainStr:= Copy(Address, SepPos + 1, DataLen);

    { 3. Check if either User or Domain is missing }

    If (UserStr = '') then begin
      Result:= eNoUser;
      Exit;
    end;

    If (DomainStr = '') then begin
      Result:= eNoDomain;
      Exit;
    end;

    { 4. Check if either User or Domain are > standard }

    DomainStrLen:= Length(DomainStr);
    UserStrLen:= Length(UserStr);

    If DomainStrLen > cMaxDomainPortion then begin
      Result:= eDomainTooLong;
      Exit;
    end;

    If UserStrLen > cMaxUserNamePortion then  begin
      Result:= eUserTooLong;
      Exit;
    end;

    { 5. Verify User }

    { first/last character  is . ? -implicitly checks if User='.'}
    If (UserStr[1] = '.') then begin
      Result:= eUserStartsWithPeriod;
      Exit;
    end;

    If (UserStr[UserStrLen] = '.') then begin
      Result:= eUserEndsWithPeriod;
      Exit;
    end;

    { 2 periods, .. , in a row? }
    For fI:= 1 to UserStrLen do begin
      If UserStr[fI] = '.' then begin
        If UserStr[fI + 1] = '.' then begin
          Result:= eUser2SequentialPeriods;
          Exit;
        end;
      end;
    end;

    { 6. Verify Domain }

    { first/last character  is . ? -implicitly checks if Domain='.' }
    If (DomainStr[1] = '.') then begin
      Result:= eDomainStartsWithPeriod;
      Exit;
    end;

    If (DomainStr[DomainStrLen] = '.') then begin
      Result:= eDomainEndsWithPeriod;
      Exit;
    end;

    { 2 periods, .. , in a row? }

    // and, while in the loop, count the periods, and
    // record the last one,
    // and while checking items, verify that domain and subdomains
    // don't start or end with a -

    SepCount := 0;
    LastSep := 0;
    PrevSep := 1; // Start of string

    For fI:= 1 to DomainStrLen do begin
      If DomainStr[fI] = '.' then
        begin
          If DomainStr[fI + 1] = '.' then begin
            Result:= eDomain2SequentialPeriods;
            Exit;
          end;

          { starts/ends with '-'?}
          Inc(SepCount);
          LastSep:= fI;

          SubDomain:= Copy(DomainStr, PrevSep, (LastSep) - PrevSep);
          If SubDomain[1] = '-' then begin
            Result:= eSubdomainInvalidStartChar;
            Exit;
          end;

          If SubDomain[Length(SubDomain)] = '-' then begin
            Result:= eSubdomainInvalidEndChar;
            Exit;
          end;

          PrevSep:= LastSep + 1;
        end // If DomainStr[fI] = '.'
      else
        begin
          If DomainStr[fI] = '@' then begin
            Result:= eTooManyAtSymbols;
            Exit;
          end;
        end; // else
    end; // for

    { At least one . ? }
    If SepCount < 1 then begin
      Result:= eNoDomainSeparator;
      Exit;
    end;

    { Lowest level (for instance '.com'), is at least 2 chars? }
    SubDomain:= Copy(DomainStr, LastSep, DomainStrLen);
    If Length(SubDomain) < 2 then begin
      Result:= eTooShortGeneralDomain;
      Exit;
    end;

    { Passed all tests }
    Result:= eOK;

  Except
    Result:= eUnknownError;
  end; // try/except
End; // Function EmailAddressValidity

Function EmailAddressValidityError2String(ErrorCode: tEmailAddressValidity): String;
Begin
  Case ErrorCode of
    eUnknownError: Result:= 'Unknown error';
    eBlank: Result:= 'Blank email address';
    eNoSeparator: Result:= 'No @ separator'; // ***
    eUserTooLong: Result:= 'User part longer than ' + IntToStr(cMaxUsernamePortion) + ' characters';
    eDomainTooLong: Result:= 'Domain part longer than ' + IntToStr(cMaxDomainPortion) + ' characters';
    eInvalidChar: Result:= 'Invalid character';
    eNoUser: Result:= 'No user part';
    eNoDomain: Result:= 'No domain part';
    eNoDomainSeparator: Result:= 'Domain part requires period (.) separator';
    eTooManyAtSymbols: Result:= 'Too many @ separators';
    eUserStartsWithPeriod: Result:= 'User part starts with a period';
    eUserEndsWithPeriod: Result:= 'User part ends with a period';
    eDomainStartsWithPeriod: Result:= 'Domain part starts with a period';
    eDomainEndsWithPeriod: Result:= 'Domain part ends with a period';
    eUser2SequentialPeriods: Result:= '2 sequential periods in user part';
    eDomain2SequentialPeriods: Result:= '2 sequential periods in domain part';
    eSubdomainInvalidStartChar: Result:= '- not allowed as subdomain start character';
    eSubdomainInvalidEndChar: Result:= '- not allowed as subdomain end character';
    eTooShortGeneralDomain: Result:= 'General domain needs be at least 2 characters long';
    else Result:= '';
  end;
End; // EmailAddressValidityError2String

procedure ObjectToParameters(Obj: TObject; query: TADOQuery);
var i: integer;
    paramName, paramType: string;
    PropInfo: PPropInfo;
    vari, vari2: Variant;
begin
  for i := 0 to query.Parameters.Count-1 do
  begin
    paramName := query.Parameters.Items[i].Name;

    PropInfo := GetPropInfo(Obj, paramName);
    //if such property exists
    if Assigned(PropInfo) then
    begin
      vari := GetPropValue(Obj, PropInfo, false);

      (*query.Parameters.Items[i].Value := vari;
      if (query.Parameters.Items[i].DataType = ftString) then
        if (query.Parameters.Items[i].Value = '') then
          query.Parameters.Items[i].Value := Null;*)

      if (query.Parameters.Items[i].DataType = ftString) then
      begin
        query.Parameters.Items[i].Value := vari;
        if (query.Parameters.Items[i].Value = '') then
          query.Parameters.Items[i].Value := Null;
      end
      else
      if (PropInfo^.PropType^^.Kind in [tkString, tkLString, tkUString, tkWString])and(vari = '') then
          query.Parameters.Items[i].Value := Null
      else
      if (PropInfo^.PropType^^.Kind = tkInteger) then
          query.Parameters.Items[i].Value := vari
      else
      if (query.Parameters.Items[i].DataType in [ftInteger, ftLargeint]) then
          query.Parameters.Items[i].Value := strtoint(vari)
      else
      if (query.Parameters.Items[i].DataType in [ftFloat, ftExtended]) then
          query.Parameters.Items[i].Value := strtofloat(vari)
      else
      if (query.Parameters.Items[i].DataType in [ftDateTime, ftDate, ftTime]) then
          query.Parameters.Items[i].Value := strtofloat(vari)
      else
      if (query.Parameters.Items[i].DataType = ftBoolean) then
          query.Parameters.Items[i].Value := StrToBool(vari);
    end;
  end;
end;

procedure ByteArrayToFile(const ByteArray: TByteDynArray; const FileName: string);
var
  Count: integer;
  f: FIle of Byte;
  pTemp: Pointer;
begin
  AssignFile(f, FileName);
  Rewrite(f);
  try
    Count := Length(ByteArray);
    pTemp := @ByteArray[0];
    BlockWrite(f, pTemp^, Count);
  finally
    CloseFile(f);
  end;
end;

function FileToByteArray(const FileName: string): TByteDynArray;
const
  BLOCK_SIZE = 1024;
var
  BytesRead, BytesToWrite, Count: integer;
  f: FIle of Byte;
  pTemp: Pointer;
begin
  AssignFile(f, FileName);
  Reset(f);
  try
    Count := FileSize(f);
    SetLength(Result, Count);
    pTemp := @Result[0];
    BytesRead := BLOCK_SIZE;
    while (BytesRead = BLOCK_SIZE) do
    begin
      BytesToWrite := Min(Count, BLOCK_SIZE);
      BlockRead(f, pTemp^, BytesToWrite, BytesRead);
      pTemp := Pointer(Longint(pTemp) + BLOCK_SIZE);
      Count := Count - BytesRead;
    end;
  finally
    CloseFile(f);
  end;
end;



function EncodeParams(value: WideString): WideString;
begin
  result := TIdURI.ParamsEncode(value);
end;

function StripHTML(S: string): string;
var
  TagBegin, TagEnd, TagLength: integer;
begin
  TagBegin := Pos( '<', S);      // search position of first <

  while (TagBegin > 0) do begin  // while there is a < in S
    TagEnd := Pos('>', S);              // find the matching >
    if (TagEnd = 0) then
      Break;
    TagLength := TagEnd - TagBegin + 1;
    Delete(S, TagBegin, TagLength);     // delete the tag
    TagBegin:= Pos( '<', S);            // search for next <
  end;

  Result := S;                   // give the result
end;

function CheckImage(var imageStream: TMemoryStream): boolean;
var image: TWICImage;
begin
    image:= TWICImage.Create;
    try
    try
      image.LoadFromStream(imageStream);
      result := true;
    except
      on e : Exception do begin
        result := false;
        LogHttp(e, 'CheckImage - NOT IMAGE FILE ERROR');
      end;
    end;
  finally
    image.Free;
  end;
end;

function ResizeImage(var imageStream: TMemoryStream; maxWidth, maxHeight : Integer; Out width: Integer; Out height: Integer): boolean;
var image: TWICImage;
    bmp, bmp2: TBitmap;
    StretchMode: Integer;
    scale, scaleX, scaleY: Double;
    Png: TPngImage;
begin
    image:= TWICImage.Create;
    bmp := TBitmap.Create;
    bmp2 := TBitmap.Create;
  try
    try
      image.LoadFromStream(imageStream);

      if (image.Height > maxHeight) or (image.Width > maxWidth) then
      begin
        scaleX := maxWidth / image.Width;
        scaleY := maxHeight / image.Height;

        if scaleX < scaleY then
          scale := scaleX
        else
          scale := scaleY;

        bmp.SetSize(image.Width, image.Height);
        bmp2.SetSize(Round(image.Width * scale), Round(image.Height * scale));

        bmp.Canvas.StretchDraw(bmp.Canvas.ClipRect, image);
        StretchMode := SetStretchBltMode(bmp2.Canvas.Handle, HALFTONE);
        StretchBlt(bmp2.Canvas.Handle, 0, 0, bmp2.Width, bmp2.Height, bmp.Canvas.Handle, 0, 0, image.Width, image.Height, SRCCOPY);
        SetStretchBltMode(bmp2.Canvas.Handle, StretchMode);

        imageStream.Free;
        imageStream := TMemoryStream.Create;

        png := TPngImage.Create;
        png.Assign(bmp2);
        png.SaveToStream(imageStream);
        //bmp2.SaveToStream(imageStream);

        width := bmp2.Width;
        height := bmp2.Height;

        result := true;
      end
      else
      begin
        width := image.Width;
        height := image.Height;
        result := true;
        //resultStream := imageStream.LoadFromStream(imageStream);
        //result := imageStream;
      end;
    except
      on e : Exception do begin
        result := false;
        LogHttp(e, 'UploadLogo - NOT IMAGE FILE ERROR');
      end;
    end;
  finally
      image.Free;
      bmp.Free;
      bmp2.Free;
  end;
end;

(*
// zlib

function ZCompressString(aText: string; aCompressionLevel: TZCompressionLevel = zcMax): string;
var
  strInput,
  strOutput: TStringStream;
  Zipper: TZCompressionStream;
begin
  Result:= '';
  strInput:= TStringStream.Create(aText);
  strOutput:= TStringStream.Create;
  try
    Zipper:= TZCompressionStream.Create(strOutput, aCompressionLevel);
    try
      Zipper.CopyFrom(strInput, strInput.Size);
    finally
      Zipper.Free;
    end;
    Result:= strOutput.DataString;
  finally
    strInput.Free;
    strOutput.Free;
  end;
end;

procedure ZCompressString(aText: string; toStream: TStream; aCompressionLevel: TZCompressionLevel = zcMax);
var
  strInput: TStringStream;
  Zipper: TZCompressionStream;
begin
  strInput:= TStringStream.Create(aText);
  try
    Zipper:= TZCompressionStream.Create(toStream, aCompressionLevel);
    try
      Zipper.CopyFrom(strInput, strInput.Size);
    finally
      Zipper.Free;
    end;
  finally
    strInput.Free;
  end;
end;

function ZDecompressString(aText: string): string;
var
  strInput,
  strOutput: TStringStream;
  Unzipper: TZDecompressionStream;
begin
  Result:= '';
  strInput:= TStringStream.Create(aText);
  strOutput:= TStringStream.Create;
  try
    Unzipper:= TZDecompressionStream.Create(strInput);
    try
      strOutput.CopyFrom(Unzipper, Unzipper.Size);
    finally
      Unzipper.Free;
    end;
    Result:= strOutput.DataString;
  finally
    strInput.Free;
    strOutput.Free;
  end;
end;*)

function getMaxContentFromParams(aParams: WideString): integer;
var n: integer;
begin
  result := MaxInt;
  n := pos(WideString('maxSize='), aParams);
  if n > 0 then
  begin
    aParams := copy(aParams, n + 8, MaxInt);
    n := pos(#$D, aParams);
    if n > 0 then
      aParams := copy(aParams, 1, n-1);

    if aParams <> '' then
      result := StrToIntDef(aParams, MaxInt);
    if result <> MaxInt then
      result := result * 1024;
  end;
end;

function GetImageSubContentType(ext: WideString): WideString;
begin
  if (ext = 'jpg') or (ext = 'jpeg') then
  begin
      result := '/jpeg';
  end
  else if (ext = 'tiff') or (ext = 'tif') then
  begin
      result := '/tiff';
  end
  else if (ext = 'gif')then
  begin
      result := '/gif';
  end
  else if (ext = 'png') then
  begin
      result := '/png';
  end
  else result := '';
end;

procedure RunAndWaitShell(Executable, Parameter, Directory: STRING; ShowParameter: INTEGER);
var
  Info: TShellExecuteInfo;
  pInfo: PShellExecuteInfo;
  exitCode: DWord;
begin
  {Pointer to Info}
  pInfo := @Info;
  {Fill info}
  with Info do
  begin
    cbSize := SizeOf(Info);
    fMask := SEE_MASK_NOCLOSEPROCESS;
    wnd   := application.Handle;
    lpVerb := NIL;
    lpFile := PChar(Executable);
    {Executable parameters}
    lpParameters := PChar(Parameter + #0);
    lpDirectory := PChar(Directory);
    nShow       := ShowParameter;
    hInstApp    := 0;
  end;
  {Execute}
  ShellExecuteEx(pInfo);

  {Wait to finish}
  repeat
    exitCode := WaitForSingleObject(Info.hProcess, 500);
    Application.ProcessMessages;
  until (exitCode <> WAIT_TIMEOUT);
end;

function RunAndWaitShellWithExitCode(Executable, Parameter, Directory: STRING; ShowParameter: INTEGER): DWORD;
var
  Info: TShellExecuteInfo;
  pInfo: PShellExecuteInfo;
  exitCode: DWord;
begin
  {Pointer to Info}
  pInfo := @Info;
  {Fill info}
  with Info do
  begin
    cbSize := SizeOf(Info);
    fMask := SEE_MASK_NOCLOSEPROCESS;
    wnd   := application.Handle;
    lpVerb := NIL;
    lpFile := PChar(Executable);
    {Executable parameters}
    lpParameters := PChar(Parameter + #0);
    lpDirectory := PChar(Directory);
    nShow       := ShowParameter;
    hInstApp    := 0;
  end;
  {Execute}
  ShellExecuteEx(pInfo);

  {Wait to finish}
  repeat
    exitCode := WaitForSingleObject(Info.hProcess, 500);
    Application.ProcessMessages;
  until (exitCode <> WAIT_TIMEOUT);

  {Get exit code}
  GetExitCodeProcess(Info.hProcess, exitCode);
  result := exitCode;
end;

function ExecAndWait(const FileName, Params: string; const CmdShow: Integer): DWORD;
var
  exInfo: TShellExecuteInfo;
  Ph: DWORD;
  ErrorCode: DWORD;
begin
  FillChar(exInfo, SizeOf(exInfo), 0);
  with exInfo do
  begin
    cbSize := SizeOf(exInfo);
    fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_DDEWAIT;
    //Wnd := GetActiveWindow();
    Wnd := Application.Handle;
    ExInfo.lpVerb := 'open';
    ExInfo.lpParameters := PChar(Params);
    lpFile := PChar(FileName);
    nShow := CmdShow;
  end;
  if ShellExecuteEx(@exInfo) then
    Ph := exInfo.HProcess
  else
  begin
    //ShowMessage(SysErrorMessage(GetLastError));
    Exit;
  end;
  while WaitForSingleObject(ExInfo.hProcess, 50) <> WAIT_OBJECT_0 do
    Application.ProcessMessages;
  GetExitCodeProcess(ExInfo.hProcess, ErrorCode);
  CloseHandle(Ph);
  result := ErrorCode;
end;

function ExecAndReadPipe(const FileName, Params: string; const CmdShow: Integer; var PipeOutput: String): DWORD;
const
  BufSize = 512;
  PipeTimeout = 30000;
var
  exInfo: TShellExecuteInfo;
  Ph: DWORD;
  ErrorCode: DWORD;
  buf: array [0 .. BufSize-1] of char;
  read: cardinal;
  hPipe: THandle;
  pipeName, msg: string;
  dtStart: TDateTime;
begin
  pipeName := '\\.\pipe\myNamedPipe';  
  hPipe := CreateNamedPipe(
    PChar(pipeName),
    PIPE_ACCESS_DUPLEX or FILE_FLAG_OVERLAPPED,
    PIPE_TYPE_MESSAGE or PIPE_READMODE_MESSAGE or PIPE_NOWAIT,
    PIPE_UNLIMITED_INSTANCES,
    BufSize,
    BufSize,
    0,
    nil
  );

  FillChar(exInfo, SizeOf(exInfo), 0);
  with exInfo do
  begin
    cbSize := SizeOf(exInfo);
    fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_DDEWAIT;
    Wnd := Application.Handle;
    ExInfo.lpVerb := 'open';
    ExInfo.lpParameters := PChar(StringReplace(Params, '{pipeName}', pipeName, [rfReplaceAll, rfIgnoreCase]));
    lpFile := PChar(FileName);
    nShow := CmdShow;
  end;
  if ShellExecuteEx(@exInfo) then
    Ph := exInfo.HProcess
  else
  begin
    Exit;
  end;

  dtStart := Now;
  ConnectNamedPipe(hPipe, nil);

  while (msg = '') do
  begin
    Sleep(50);
    if (MilliSecondsBetween(dtStart, Now) > PipeTimeout) then
    begin
      result := 42001; // RD: Named pipe timeout
      Exit;
    end
    else
    begin
      repeat
        FillChar(buf, BufSize, #0);
        ReadFile(hPipe, buf[0], BufSize, read, nil);
        msg := msg + Copy(buf, 0, read);
      until GetLastError <> ERROR_MORE_DATA;    
    end;
  end;

  DisconnectNamedPipe(hPipe);
  CloseHandle(hPipe);
  PipeOutput := msg;

  while WaitForSingleObject(ExInfo.hProcess, 50) <> WAIT_OBJECT_0 do
    Application.ProcessMessages;
  GetExitCodeProcess(ExInfo.hProcess, ErrorCode);
  CloseHandle(Ph);
  result := ErrorCode;
end;

function ExecAndReadOutput(var StdOutOutput: String; CommandLine: String; Work: String = 'C:\MXP'): DWORD;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: string;
  Handle: Boolean;
  ErrorCode: DWORD;
begin
  StdOutOutput := '';

  with SA do begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
  try
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;
    WorkDir := Work;
    CommandLine := 'Project1.exe';
    Handle := CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine),
                            nil, nil, True, 0, nil,
                            PChar(WorkDir), SI, PI);
    CloseHandle(StdOutPipeWrite);
    if Handle then
      try
        repeat
          WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
          if BytesRead > 0 then
          begin
            Buffer[BytesRead] := #0;
            StdOutOutput := StdOutOutput + Buffer;
          end;
        until not WasOK or (BytesRead = 0);
        WaitForSingleObject(PI.hProcess, INFINITE);
      finally
        GetExitCodeProcess(PI.hProcess, ErrorCode);
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
      end;
  finally
    CloseHandle(StdOutPipeRead);
  end;
  result := ErrorCode;
end;

function isEmpty(const value: WideString; const replaceValue: WideString): WideString;
begin
  if value = '' then
    result := replaceValue
  else
    result := value;
end;

function isEmpty(const value: WideString; const replaceValue: integer): integer; overload;
begin
  if value = '' then
    result := replaceValue
  else
    result := StrToIntDef(value, replaceValue);
end;

function MD5(const value: string): string;
var
  IdMD5: TIdHashMessageDigest5;
begin
 IdMD5 := TIdHashMessageDigest5.Create;
 try
   Result := IdMD5.HashStringAsHex(value);
 finally
   IdMD5.Free;
 end;
end;

end.
