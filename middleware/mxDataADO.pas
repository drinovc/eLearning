unit mxDataADO;

interface

uses
  SysUtils, Classes, Forms, DB, ADODB, MxADO, DateUtils,
  ActiveX, Windows, Controls, Variants, IdMessage,
  mxDateUtils, mxDataCommon, SuperObject, WideStrings, StrUtils, WideStrUtils, RC4, AdoInt;

function ParseDocTypeParam(slParams: TWideStrings): boolean;
procedure ProcessParameters(slParams: TWideStrings; query: TADOQuery; inStream: TStream);
function changeConnectionString(constr: WideString): string;
function updateConnectionString(constr, field, value: WideString): string;
function deleteConnStr(AConStr: string; segment: string): string;
function GetConnection(parentCon: TADOConnection; conStr: WideString = ''): TADOConnection;
procedure ReleaseConnection(conn: TADOConnection; forceFree: boolean = false);
function handleADOMethod(lineNo: integer; method: WideString; slParams: TWideStringList; queryMX: TADOQueryMX; InStream: TMemoryStream; var ContentType: WideString; location: WideString): variant;
function BuildFieldMetaData(query: TADOQuery): ISuperObject;
function DataSetToJSON(query: TADOQuery; onlyFirstRow: boolean; var nbrows: integer): ISuperObject;
function DataSetToArray(query: TADOQuery; onlyFirstRow: boolean; var nbrows: integer): ISuperObject;
function EncryptString(aText: String; pass: AnsiString): AnsiString;
function SaveToBlob(const Stream: TStream; const AField: TField): boolean;
function LoadFromBlob(const AField: TField; const Stream: TStream): boolean;


var
  lConnections: TList;
  CritSectConnections: TRTLCriticalSection;
  gEncPass: AnsiString = 'mx4ecomm!';

implementation

uses mxDataRequest;

// Beispiel: StrToHexString('Daten') => '446174656E'
function StrToHexString(const s : AnsiString):AnsiString;
begin
  if s = '' then
    Result := ''
  else
  begin
    SetLength(Result, Length(s)*2);
    BinToHex(PAnsiChar(s), PAnsiChar(Result), Length(s));
  end;
end;

// Beispiel: HexStringToStr('446174656E') => 'Daten'
function HexStringToStr(s : AnsiString):AnsiString;
begin
  if s = '' then
    Result := ''
  else
  begin
    if Odd(length(s)) then
      s := '0'+s;
    SetLength(Result, Length(s) div 2);
    HexToBin(PAnsiChar(s), PAnsiChar(Result), Length(Result));
  end;
end;

function DecryptString(aText: string; pass: AnsiString): AnsiString;
var Data: TRC4Data;
    sText: AnsiString;
begin
  sText := AnsiString(aText);
  sText := HexStringToStr(sText);
  result := sText;
  RC4Init(Data, PAnsiChar(pass), length(pass));
  RC4Crypt(Data, PAnsiChar(sText), PAnsiChar(result), length(sText));
  RC4Burn(Data);
end;

function EncryptString(aText: string; pass: AnsiString): AnsiString;
var Data: TRC4Data;
    sText: AnsiString;
begin
  sText := AnsiString(aText);
  result := sText;
  RC4Init(Data, PAnsiChar(pass), length(pass));
  RC4Crypt(Data, PAnsiChar(sText), PAnsiChar(result), length(sText));
  RC4Burn(Data);
  result := StrToHexString(result);
end;

{
  Frees all created connections within the connections pool
  used on application termination
}
procedure FreeConnections;
var
  i: integer;
begin
  EnterCriticalSection(CritSectConnections);
  try
    for i := 0 to lConnections.Count - 1 do
    begin
      try
        TADOConnection(lConnections[i]).Free;
      except on e: exception do
        WriteLn(gLogFile, 'FreeConnections Error: ' + e.message);
      end;
    end;
    lConnections.Clear;
  finally
    LeaveCriticalSection(CritSectConnections);
  end;
end;

{
  Returns first free connection from connection pool or creates a new connection object
  uses the connection string provided from the parentCon parameter
    which is updated with data source read from ini settings
}
function changeConnectionString(constr: WideString): string;
var n, ne: integer;
begin
  if conStr <> '' then
  begin
    // remove the original data source if exists
    n := Pos(WideString('Data Source='), conStr);
    if n > 0 then
    begin
      ne := PosEx(';', conStr, n+1);
      if ne > 0 then
        delete(conStr, n, ne-n)
      else
        delete(conStr, n, MaxInt);
    end;

    if (conStr <> '')and(conStr[length(conStr)]<>';') then
      conStr := conStr + ';';
    // add the data source, should be provided in the ini file, read on startup into global var
    conStr := conStr + 'Data Source=' + gConnDataSource;

    if gConnPassword <> '' then
    begin
      conStr := deleteConnStr(conStr, 'Password=');
      conStr := deleteConnStr(conStr, 'User ID=');
      // add the data source, should be provided in the ini file, read on startup into global var
      if (conStr <> '')and(conStr[length(conStr)]<>';') then
        conStr := conStr + ';';
      conStr := conStr + 'Password=' + String(DecryptString(gConnPassword, gEncPass)) + ';';
      conStr := conStr + 'User ID=' + gConnUserID + ';';
    end;

    if gConnCatalog <> '' then
    begin
      conStr := deleteConnStr(conStr, 'Initial Catalog=');
      // add the data source, should be provided in the ini file, read on startup into global var
      if (conStr <> '')and(conStr[length(conStr)]<>';') then
        conStr := conStr + ';';
      conStr := conStr + 'Initial Catalog=' + gConnCatalog + ';';
    end;

  end;
  result := conStr;
end;

function updateConnectionString(constr, field, value: WideString): string;
var n, ne: integer;
begin
  if conStr <> '' then
  begin
    // remove the original data source if exists
    n := Pos(WideString(field + '='), conStr);
    if n > 0 then
    begin
      ne := PosEx(';', conStr, n+1);
      if ne > 0 then
        delete(conStr, n, ne-n+1)
      else
        delete(conStr, n, MaxInt);
    end;
  end;
  if value <> '' then
  begin
    if (conStr <> '')and(conStr[length(conStr)]<>';') then
      conStr := conStr + ';';
    // add the data source, should be provided in the ini file, read on startup into global var
    conStr := conStr + field+'=' + value;
  end;
  result := conStr;
end;

function deleteConnStr(AConStr: string; segment: string): string;
var n, ne: integer;
begin
  // remove the original data source if exists
  n := Pos(lowercase(segment), lowercase(AConStr));
  if n > 0 then
  begin
    ne := PosEx(';', AConStr, n+1);
    if ne > 0 then
      delete(AConStr, n, ne-n+1)
    else
      delete(AConStr, n, MaxInt);
  end;

  if (AConStr <> '')and(AConStr[length(AConStr)]<>';') then
    AConStr := AConStr + ';';

  result := AConStr;
end;

function GetConnection(parentCon: TADOConnection; conStr: WideString = ''): TADOConnection;
var
  i: integer;
  conn: TADOConnection;
begin
  result := nil;
  try
    EnterCriticalSection(CritSectConnections);
    try
      for i := 0 to lConnections.Count - 1 do
      begin
        conn := TADOConnection(lConnections[i]);
        if conn.Tag = 0 then
        begin
          conn.Tag := 1;
          result := conn;
          Break;
        end;
      end;

      if not Assigned(result) then
      begin
        result := TADOConnection.Create(nil);
        result.LoginPrompt := false;
        result.Tag := 1;
//LogHttp(nil, '-- GetConnection: ' + inttostr(lConnections.Count+1));

        // get the connection string from the "parent" ado connection component
        if (conStr = '')and(Assigned(parentCon)) then
          conStr := parentCon.ConnectionString;

        if (conStr <> '') then
        begin
          conStr := deleteConnStr(conStr, 'Data Source=');

          // add the data source, should be provided in the ini file, read on startup into global var
          conStr := conStr + 'Data Source=' + gConnDataSource + ';';

          if gConnPassword <> '' then
          begin
            conStr := deleteConnStr(conStr, 'Password=');
            conStr := deleteConnStr(conStr, 'User ID=');
            // add the data source, should be provided in the ini file, read on startup into global var
            conStr := conStr + 'Password=' + String(DecryptString(gConnPassword, gEncPass)) + ';';
            conStr := conStr + 'User ID=' + gConnUserID + ';';
          end;

          if gConnCatalog <> '' then
          begin
            conStr := deleteConnStr(conStr, 'Initial Catalog=');
            // add the data source, should be provided in the ini file, read on startup into global var
            conStr := conStr + 'Initial Catalog=' + gConnCatalog + ';';
          end;

          result.ConnectionString := conStr;
        end
        else
          LogHttp(nil, 'GetConnection: No connection string');

        //Result.ConnectionTimeout := 5;
        //Result.CommandTimeout := 10;
        lConnections.Add(result);
      end;
    finally
      LeaveCriticalSection(CritSectConnections);
    end;
  except
    on e: exception do
      LogHttp(e, 'ERROR GetConnection: ' + e.message);
  end;
end;

{
  Release a connection from connection pool
  A connection is only released if there are more than 50 concurrent connections
    of if there was an error within the connection and it needs to be forcefully dropped
}
procedure ReleaseConnection(conn: TADOConnection; forceFree: boolean = false);
begin
  try
    EnterCriticalSection(CritSectConnections);
    try
      conn.Tag := 0;
      if (lConnections.Count > 50) or (forceFree) then
      begin
        try
          lConnections.Remove(conn);

          try
            conn.Close;
          except
          end;
//LogHttp(nil, '-- CloseConnection: ' + inttostr(lConnections.Count));

          FreeAndNil(conn);
        except on e: exception do
          LogHttp(e, 'ERROR ReleaseConnection1: ' + e.message);
        end;
      end;
//LogHttp(nil, '-- ReleaseConnection: ' + inttostr(lConnections.Count));
    finally
      LeaveCriticalSection(CritSectConnections);
    end;
  except
    on e: exception do
    begin
      LogHttp(e, 'ERROR ReleaseConnection2: ' + e.message);
      try
        if (not forceFree)and(conn <> nil) then
          ReleaseConnection(conn, true);
      except
      end;
    end;
  end;
end;

{
  Loads a blob field value into stream
  returns load success
}
function LoadFromBlob(const AField: TField; const Stream: TStream): boolean;
var
  blobStream: TStream;
begin
  Result := false;
  if (Assigned(AField)) and (Assigned(Stream)) then begin
    try
      blobStream := AField.DataSet.CreateBlobStream(AField, bmRead);
      Stream.CopyFrom(blobStream, 0);
      blobStream.Free;

      Stream.Seek(0,0);
      Result := true;
    except
    end;
  end;
end;

{
  Stores a stream contents into database blob field
}
function SaveToBlob(const Stream: TStream; const AField: TField): boolean;
var
  FieldStr: string;
  PFieldStr: PChar;
begin
  Result := false;
  if (Assigned(AField)) and (Assigned(Stream)) then begin
    try
      Stream.Seek(0,0);
      SetLength(FieldStr, Stream.Size);
      PFieldStr := PChar(FieldStr);
      Stream.Read(PFieldStr^, Stream.Size);
      AField.Value := FieldStr;
      Result := true;
    except
    end;
  end;
end;

// has a param like "/?66BA5DD1FEF1461FBA1765C317EC50DA" or "/GUID={...}
function ParseDocTypeParam(slParams: TWideStrings): boolean;
var n: integer;
    s, g, userGUID: string;
begin
  userGUID := '';
  for n := 0 to slParams.Count - 1 do
  begin
    if (slParams.Names[n] = '') then
    begin
      s := slParams[n];
      if s <> '' then
      begin
        s := trimUserGUID(s, userGUID);
        s := trimGUID(trim(s));
        slParams[n] := 'docID=' + s;
        slParams.Add('docGUID=' + prepareGUID(s));
        if userGUID <> '' then
          slParams.Add('userGUID=' + userGUID);
        result := true;
        Exit;
      end;
    end;
    if (slParams.Names[n] = 'GUID') then
    begin
      s := slParams.ValueFromIndex[n];
      s := trimUserGUID(s, userGUID);
      slParams.Add('docID=' + trimGUID(trim(s)));
      slParams.Add('docGUID=' + s);
      if userGUID <> '' then
        slParams.Add('userGUID=' + userGUID);
      result := true;
      Exit;
    end;
  end;
end;

{
  Sets the parameters for provided ADOQuery object from
    required key=value parameter string list
  also re-parses "data" value if it is provided within parameters
}
procedure ProcessParameters(slParams: TWideStrings; query: TADOQuery; inStream: TStream);
var
  n: integer;
  content, value, paramName: WideString;
  dbParam: TParameter;
  jData: ISuperObject;
  ite: TSuperObjectIter;
  fs: TFormatSettings;
begin
  GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, fs);
  fs.DecimalSeparator := '.';
  fs.ThousandSeparator := ',';

  if query.Parameters.Count = 0 then
    Exit;

  content := slParams.Values['data'];
  if (content <> '') then
  begin
    if content[1] = '[' then // remove the array "[...]" brackets from the ext request
      content := copy(content, 2, length(content) - 3);

    //content := '{"data":' + content + '}';
    jData := SO(content);

    if ObjectFindFirst(jData, ite) then
    repeat
      slParams.Add(ite.key + '=' + ite.val.AsString);
    until not ObjectFindNext(ite);
    ObjectFindClose(ite);
  end;

  // check for some kind of blob field which would take the stream contents
  if (Assigned(inStream) and (inStream.Size > 0)) then
  begin
    dbParam := query.Parameters.FindParam(PARAM_FILECONTENTS);
    if Assigned(dbParam) then
    begin
      dbParam.LoadFromStream(inStream, dbParam.DataType);
      //dbParam.Value := TBytes(TMemoryStream(inStream).Memory); // http://qc.embarcadero.com/wc/qcmain.aspx?d=54686
      //dbParam.Size
    end;
  end;

  for n := 0 to slParams.Count - 1 do
  begin
    dbParam := query.Parameters.FindParam(slParams.Names[n]);
    // pair value is an object
    if Assigned(dbParam) then
    begin
      value := trim(slParams.ValueFromIndex[n]);

      if (value = '')or(value = '&nbsp;')or(value = 'null') then
      begin
        if (not(paNullable in dbParam.Attributes)) and (dbParam.DataType = ftString) then
          dbParam.value := ''      // if it cannot be null then write an empty string into it
        else
          dbParam.value := Null;   // otherwise just set it to null
      end
      else
      begin
        case dbParam.DataType of
          ftString:
          begin
            //value := UTF8Decode( WideStringReplace(value, '%0A', #13#10, [rfReplaceAll]));     // change the URL encoded line feed into crlf
            value := WideStringReplace(value, '%0A', #13#10, [rfReplaceAll]);     // change the URL encoded line feed into crlf

            if (dbParam.Size < length(value)) then
              dbParam.value := copy(value, 1, dbParam.Size)
            else
              dbParam.value := value;
          end;
          ftGuid:
            dbParam.value := prepareGUID(value);
          // GUIDToString(StringToGUID(value));

          ftSmallint, ftInteger, ftWord:
            dbParam.value := strtoint(value);

          ftBCD, ftFloat, ftCurrency :
            dbParam.value := strtofloat(value, fs);

          ftTimeStamp,
            ftDate,
            ftTime,
            ftDateTime:
            begin
              if (pos('T', value) = 11) then                //1979-04-21T00:00:00
                dbParam.value := DateTimeStrEval('yyyy-mm-ddThh:nn:ss', value)
              else
              if (length(value) = 23) and (pos('-', value) = 5) and (pos(' ', value) = 11) then   //1979-04-21 00:00:000
                dbParam.value := DateTimeStrEval('yyyy-mm-dd hh:nn:sss', value)
              else
              if (length(value) = 10) and (pos('-', value) = 5) and (PosEx('-', value, 6) = 8) then   //1979-04-21 00:00:000
                dbParam.value := DateTimeStrEval('yyyy-mm-dd', value)
              else
                dbParam.value := value;
            end;
          ftBoolean: dbParam.value := StrToBoolDef(value, false);

          (* ftUnknown: ;
            ftBytes: ;
            ftVarBytes: ;
            ftAutoInc: ;
            ftBlob: ;
            ftMemo: ;
            ftGraphic: ;
            ftFmtMemo: ;
            ftParadoxOle: ;
            ftDBaseOle: ;
            ftTypedBinary: ;
            ftCursor: ;
            ftFixedChar: ;
            ftWideString: ;
            ftLargeint: ;
            ftADT: ;
            ftArray: ;
            ftReference: ;
            ftDataSet: ;
            ftOraBlob: ;
            ftOraClob: ;
            ftVariant: ;
            ftInterface: ;
            ftIDispatch: ;
            ftFMTBcd: ;
            ftFixedWideChar: ;
            ftWideMemo: ;
            ftOraTimeStamp: ;
            ftOraInterval: ;
            ftConnection: ;
            ftParams: ;
            ftStream: ;
            ftTimeStampOffset: ;
            ftObject: ; *)
        else
          dbParam.value := value;
        end;
      end;
    end;
  end;
end;

{
    builds ExtJS store meta data from which the store creates fields and columns
    requires a query with active result set
    returns JSON as superObject
}
function BuildFieldMetaData(query: TADOQuery): ISuperObject;
var
  i: integer;
  field: TField;
  sFieldName: string;
  metaData, metaFields, metaCols, metaField, metaCol: ISuperObject;
begin
  (* result example:
    metaData: {
    "idProperty": "id",
    "root": "rows",
    "totalProperty": "results"
    "successProperty": "success",
    // used by store to set its sortInfo
    "sortInfo":{"field": "name", "direction": "ASC" },
    // paging data (if applicable)
    "start": 0,
    "limit": 2,
    // custom property
    "foo": "bar" },*)

  metaData := TSuperObject.Create;
  metaData.S['root'] := 'data';
  metaData.S['totalProperty'] := 'total';
  metaData.S['successProperty'] := 'success';

  metaFields := TSuperObject.Create(stArray);
  metaCols := TSuperObject.Create(stArray);
  (* "fields": [{"type": "int", "hidden": "true","width": "50","readOnly": "true","header": "###","name": "user_id","mapping": "user_id"},{... *)
  (* "colModel":[{"dataIndex":"k","header":"Strikes","width":50},{... *)
  for i := 0 to query.Fields.Count - 1 do
  begin
    field := query.Fields[i];

    sFieldName := replaceNonAlphaNumChars(field.FieldName, '_');

    if i = 0 then
      metaData.S['idProperty'] := sFieldName;

    metaField := TSuperObject.Create;
    metaField.S['type'] := FieldTypeToJSONType(field.DataType);
    // field type to json type
    metaField.B['readonly'] := field.ReadOnly;
    metaField.S['name'] := sFieldName;
    metaField.S['mapping'] := sFieldName;
    metaFields.O[''] := metaField;

    metaCol := TSuperObject.Create;
    metaCol.S['dataIndex'] := sFieldName;
    metaCol.S['id'] := sFieldName;
    metaCol.B['hidden'] := not field.Visible;
    metaCol.I['width'] := field.DisplayWidth * 3;
    metaCol.S['header'] := field.DisplayLabel;

    if field.Alignment = taRightJustify then
      metaCol.S['align'] := 'right'
    else if field.Alignment = taCenter then
      metaCol.S['align'] := 'center';

    metaCols.O[''] := metaCol;
  end;

  metaData.O['fields'] := metaFields;
  metaData.O['colModel'] := metaCols; // custom for column model delivery

  result := metaData;
end;

{
  Creates a result JSON object from active ADOQuery result set
  can return only first row or all rows within json array
  also returns number of rows
  string field values are encoded
}

function DataSetToJSON(query: TADOQuery; onlyFirstRow: boolean; var nbrows: integer): ISuperObject;
var jRecord, jRecords: ISuperObject;
    i: integer;
    sFieldName: string;
    acceptRec: boolean;
    fs: TFormatSettings;
begin
  GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, fs);
  fs.DateSeparator := '/';

  if not onlyFirstRow then
  begin
    jRecords := TSuperObject.Create(stArray);
    while not query.Recordset.EOF do
    begin
      acceptRec := true;

      if (not query.Filtered)and(Assigned(query.OnFilterRecord)) then    // custom filtering
        query.OnFilterRecord(query, acceptRec);

      if acceptRec then
      begin
        inc(nbrows);
        jRecord := TSuperObject.Create;
        for i := 0 to query.FieldCount - 1 do
        begin
          sFieldName := replaceNonAlphaNumChars(query.Recordset.Fields[i].Name, '_');

          if TVarData(query.Recordset.Fields[i].Value).VType = varNull then
            jRecord.O[sFieldName] := nil
          else
          if query.Recordset.Fields[i].Type_ = adBoolean then
            jRecord.B[sFieldName] := query.Recordset.Fields[i].Value
          else
          if query.Recordset.Fields[i].Type_ in [adInteger, adSmallint] then
            jRecord.I[sFieldName] := query.Recordset.Fields[i].Value
          else
          if query.Recordset.Fields[i].Type_ in [adBigInt] then
            jRecord.S[sFieldName] := VarToStr(query.Recordset.Fields[i].Value)
          else
          if (query.Recordset.Fields[i].Type_ in [adSingle, adDouble, adCurrency, adDecimal, adNumeric]) then
            jRecord.D[sFieldName] := query.Recordset.Fields[i].Value
          else
          if query.Recordset.Fields[i].Type_ in [adDate, adDBDate, adDBTime, adDBTimeStamp] then
          begin
            if SameDateTime(EncodeDate(1899, 12, 30), query.Recordset.Fields[i].Value) then
              jRecord.S[sFieldName] := ''
            else
              jRecord.S[sFieldName] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', query.Recordset.Fields[i].Value);   // 2010-02-22T00:00:00.000
          end
          else
            jRecord.S[sFieldName] := query.Recordset.Fields[i].Value;
        end;

        jRecords.O[''] := jRecord;
      end;
      query.Recordset.MoveNext;
    end;
    result := jRecords;
  end
  else
  begin
    jRecord := TSuperObject.Create;
    if not query.EOF then          // return nil or empty json? for now, empty json
    begin
      inc(nbrows);
      for i := 0 to query.FieldCount - 1 do
      begin
        sFieldName := replaceNonAlphaNumChars(query.Fields[i].FieldName, '_');

        if query.Fields[i].IsNull then
          jRecord.O[sFieldName] := nil
        else
        if query.Fields[i].DataType = ftBoolean then
          jRecord.B[sFieldName] := query.Fields[i].Value
        else
        if query.Fields[i].DataType = ftInteger then
          jRecord.I[sFieldName] := query.Fields[i].Value
        (*else
        if (query.Fields[i].DataType = ftFloat)or(query.Fields[i].DataType = ftBCD) then
          jRecord.D[sFieldName] := query.Fields[i].Value*)
        else
          jRecord.S[sFieldName] := jsonStringEncode(FieldToJSONString(query.Fields[i]));
      end;
    end;
    result := jRecord;
  end;
end;

(*
function DataSetToJSON(query: TADOQuery; onlyFirstRow: boolean; var nbrows: integer): ISuperObject;
var jRecord, jRecords: ISuperObject;
    i: integer;
    sFieldName: string;
    acceptRec: boolean;
    totalParam: TParameter;
begin
  if not onlyFirstRow then
  begin
    jRecords := TSuperObject.Create(stArray);
    while not query.EOF do
    begin
      acceptRec := true;

      if (not query.Filtered)and(Assigned(query.OnFilterRecord)) then    // custom filtering
        query.OnFilterRecord(query, acceptRec);

      if acceptRec then
      begin
        inc(nbrows);
        jRecord := TSuperObject.Create;
        for i := 0 to query.FieldCount - 1 do
        begin
          sFieldName := replaceNonAlphaNumChars(query.Fields[i].FieldName, '_');

          if query.Fields[i].IsNull then
            jRecord.O[sFieldName] := nil
          else
          if query.Fields[i].DataType = ftBoolean then
            jRecord.B[sFieldName] := query.Fields[i].Value
          else
          if query.Fields[i].DataType in [ftInteger, ftSmallint, ftWord, ftLargeint, ftAutoInc] then
            jRecord.I[sFieldName] := query.Fields[i].Value
          else
          if (query.Fields[i].DataType = ftFloat) or (query.Fields[i].DataType = ftFMTBcd) or (query.Fields[i].DataType = ftBcd) then
            jRecord.D[sFieldName] := query.Fields[i].AsFloat
          else
            jRecord.S[sFieldName] := jsonStringEncode(FieldToJSONString(query.Fields[i]));
        end;

        jRecords.O[''] := jRecord;
      end;
      query.Next;
    end;
    result := jRecords;
  end
  else
  begin
    jRecord := TSuperObject.Create;
    if not query.EOF then          // return nil or empty json? for now, empty json
    begin
      inc(nbrows);
      for i := 0 to query.FieldCount - 1 do
      begin
        sFieldName := replaceNonAlphaNumChars(query.Fields[i].FieldName, '_');

        if query.Fields[i].IsNull then
          jRecord.O[sFieldName] := nil
        else
        if query.Fields[i].DataType = ftBoolean then
          jRecord.B[sFieldName] := query.Fields[i].Value
        else
        if query.Fields[i].DataType = ftInteger then
          jRecord.I[sFieldName] := query.Fields[i].Value
        else
          jRecord.S[sFieldName] := jsonStringEncode(FieldToJSONString(query.Fields[i]));
      end;
    end;
    result := jRecord;
  end;

  totalParam := query.Parameters.FindParam('total');
  if (totalParam <> nil)and(totalParam.Value <> null) then
    nbrows := totalParam.Value;
end;
*)

{
  Creates a result json ARRAY object from active ADOQuery result set
  can return only first row or all rows within json array
  also returns number of rows
  string field values are encoded
}
function DataSetToArray(query: TADOQuery; onlyFirstRow: boolean; var nbrows: integer): ISuperObject;
var jRecord, jRecords: ISuperObject;
    i: integer;
begin
  if not onlyFirstRow then
  begin
    jRecords := TSuperObject.Create(stArray);
    while not query.EOF do
    begin
      inc(nbrows);
      jRecord := TSuperObject.Create(stArray);
      for i := 0 to query.FieldCount - 1 do
        if query.Fields[i].DataType = ftBoolean then
        begin
          if query.Fields[i].IsNull then
            jRecord.B[''] := false
          else
            jRecord.B[''] := query.Fields[i].Value;
        end
        else
          jRecord.S[''] := jsonStringEncode(FieldToJSONString(query.Fields[i]));
      jRecords.O[''] := jRecord;
      query.Next;
    end;
    result := jRecords;
  end
  else
  begin
    jRecord := TSuperObject.Create;
    if not query.EOF then          // return nil or empty json? for now, empty json
    begin
      inc(nbrows);
      for i := 0 to query.FieldCount - 1 do
        if query.Fields[i].DataType = ftBoolean then
        begin
          if query.Fields[i].IsNull then
            jRecord.B[''] := false
          else
            jRecord.B[''] := query.Fields[i].Value;
        end
        else
          jRecord.S[''] := jsonStringEncode(FieldToJSONString(query.Fields[i]));
    end;
    result := jRecord;
  end;
end;

function DataSetToSArray(query: TADOQuery; onlyFirstRow: boolean; var nbrows: integer): WideString;
var sRecord, sRecords: WideString;
    i: integer;
begin
  if not onlyFirstRow then
  begin
    sRecords := '';
    while not query.EOF do
    begin
      inc(nbrows);

      //[ [1, 'Bill', 'Gardener'], [2, 'Ben', 'Horticulturalist'] ]

      sRecord := '';
      for i := 0 to query.FieldCount - 1 do
      begin
        if i > 0 then
          sRecord := sRecord + ',';

        if query.Fields[i].DataType = ftBoolean then
        begin
          if query.Fields[i].IsNull then
            sRecord := sRecord + 'false'
          else
            sRecord := sRecord + BoolToStr(query.Fields[i].Value, true);
        end
        else
          sRecord := sRecord + '''' + jsonStringEncode(FieldToJSONString(query.Fields[i])) + '''';
      end;

      if (sRecords = '') then
        sRecords := '[' + sRecord + ']'
      else
        sRecords := sRecords + ',[' + sRecord + ']';

      query.Next;
    end;
    result := sRecords + ']';
  end
  else
  begin
    sRecord := '';
    if not query.EOF then          // return nil or empty json? for now, empty json
    begin
      inc(nbrows);
      for i := 0 to query.FieldCount - 1 do
      begin
        if i > 0 then
          sRecord := sRecord + ',';

        if query.Fields[i].DataType = ftBoolean then
        begin
          if query.Fields[i].IsNull then
            sRecord := sRecord + 'false'
          else
            sRecord := sRecord + BoolToStr(query.Fields[i].Value, true);
        end
        else
          sRecord := sRecord + '''' + jsonStringEncode(FieldToJSONString(query.Fields[i])) + '''';
      end;
    end;
    result := '['+sRecord+']';
  end;
end;

function handleADOMethod(lineNo: integer; method: WideString; slParams: TWideStringList; queryMX: TADOQueryMX; InStream: TMemoryStream; var ContentType: WideString; location: WideString): variant;
var nbrows: integer;
  rqFirstRow, rqMetaData: boolean;
  connection: TADOConnection;
  forceReleaseConnection: boolean;
  jRes: ISuperObject;
begin
  nbrows := 0;
  forceReleaseConnection := false;
  connection := nil;
  // create resulting JSON obj aka super object
  jRes := TSuperObject.Create;
  try
    rqFirstRow := false;
    rqMetaData := false;
    try
      rqFirstRow := SameText(slParams.Values['firstrow'], 'true'); // check if client demands only one row in json object not an array of objects
      rqMetaData := SameText(slParams.Values['metaData'], 'true'); // requesting grid metadata as part of JSON response
    except
      on e: exception do
        LogHttp(e, 'ERROR ProcessRequest ('+location+'): ' + e.message, slParams, lineNo);
    end;

    try
      // get a new connection, either one from connection pool or create a new one (it uses the connection string from provided connection component)
      connection := GetConnection(queryMX.Connection);
      // assign the connection to ado query component (it's automatic for subcomponents)
      queryMx.Connection := connection;
    except
      on e: exception do
      begin
        LogHttp(e, 'ERROR GetConnection ('+location+'): ' + e.message, slParams, lineNo);
        resultFailed(jRes, 'Get connection failed.');
        Exit;
      end;
    end;

    // execute the ADO sql query based on the method (select - GET, update - PUT, insert - POST, delete - DELETE, get as stream - DOWNLOAD)
    // usually the result is JSON object as wide string into resulting variant type
    if method = 'GET' then // Select
    begin
      try
        // copy the http parameter values into database query Parameters
        ProcessParameters(slParams, queryMx, inStream);
      except
        on e: exception do
          LogHttp(e, 'ERROR ProcessParameters ('+location+'): ' + e.message, slParams, lineNo);
      end;

      try
        queryMx.Open;
      except
        on e: exception do
        begin
          forceReleaseConnection := true;
          resultFailed(jRes, 'Error while opening database query: ' + e.message);
          LogHttp(e, 'ERROR SelectQuery ('+location+'): ' + e.message, slParams, lineNo);
          Exit;
        end;
      end;

      try
        if rqMetaData then
          jRes.O['metaData'] := BuildFieldMetaData(queryMx);
      except
        on e: exception do
          LogHttp(e, 'ERROR BuildMetaData ('+location+'): ' + e.message, slParams, lineNo);
      end;

      try
        if slParams.Values['resultType'] = 'array' then
          jRes.O['data'] := DataSetToArray(queryMX, rqFirstRow, nbrows)
        else
          jRes.O['data'] := DataSetToJSON(queryMX, rqFirstRow, nbrows);
      except
        on e: exception do
          LogHttp(e, 'ERROR ComposeRecordResponse ('+location+'): ' + e.message, slParams, lineNo);
      end;

      try
        queryMx.Close;
      except
        on e: exception do
        begin
          forceReleaseConnection := true;
          LogHttp(e, 'ERROR CloseComponent ('+location+'): ' + e.message, slParams, lineNo);
        end;
      end;

      jRes.I['total'] := nbrows;
      jRes.B['success'] := true;
    end
    else if method = 'PUT' then // Update
    begin
      try
        // copy the http parameter values into database query Parameters
        ProcessParameters(slParams, queryMx.UpdateQuery, inStream);
      except
        on e: exception do
          LogHttp(e, 'ERROR ProcessParameters PUT ('+location+'): ' + e.message, slParams, lineNo);
      end;

      try
        if queryMx.UpdateQuery.Tag <> 1 then
        begin
          if queryMx.UpdateQuery.ExecSQL > 0 then
          begin
            if Assigned(queryMx.UpdateQuery.AfterOpen) then
              queryMx.UpdateQuery.AfterOpen(queryMx.UpdateQuery); // call afteropen so we can do LogAction there

            jRes.B['success'] := true;
          end
          else
            resultFailed(jRes, 'No records affected.');
        end
        else
        begin
          queryMx.UpdateQuery.Open;

          if not queryMx.UpdateQuery.Eof then
          begin
            jRes.O['data'] := DataSetToJSON(queryMX.UpdateQuery, rqFirstRow, nbrows);
            jRes.B['success'] := true;
          end
          else
            resultFailed(jRes, 'No records affected.');
        end;

        (*if queryMx.UpdateQuery.ExecSQL > 0 then
        begin
          if Assigned(queryMx.UpdateQuery.AfterOpen) then
            queryMx.UpdateQuery.AfterOpen(queryMx.UpdateQuery); // call afteropen so we can do LogAction there
          jRes.B['success'] := true;
        end
        else
          resultFailed(jRes, 'No records affected.');*)

      except
        on e: exception do
        begin
          resultFailed(jRes, 'Updating the database failed: ' + e.message);
          LogHttp(e, 'ERROR UpdateComponent: ' + e.message, slParams, lineNo);
        end;
      end;
    end
    else if method = 'POST' then    // Insert
    begin
      try
      ProcessParameters(slParams, queryMx.InsertQuery, inStream);

      queryMx.InsertQuery.Open;
      except
        on e: exception do
        begin
          forceReleaseConnection := true;
          resultFailed(jRes, 'Error while inserting into database: ' + e.message);
          LogHttp(e, 'ERROR InsertQuery ('+location+'): ' + e.message, slParams, lineNo);
          Exit;
        end;
      end;

      try
        if not queryMx.InsertQuery.EOF then
          jRes.O['data'] := DataSetToJSON(queryMX.InsertQuery, rqFirstRow, nbrows)
        else
          jRes.O['data'] := TSuperObject.Create(stArray);
      except
        on e: exception do
          LogHttp(e, 'ERROR ComposeRecordResponse ('+location+'): ' + e.message, slParams, lineNo);
      end;

      jRes.B['success'] := true;
    end
    else if method = 'DELETE' then  // Delete
    begin
      // copy the http parameter values into database query Parameters
      ProcessParameters(slParams, queryMx.DeleteQuery, inStream);
      if queryMx.DeleteQuery.Tag <> 1 then
      begin
        if (queryMx.DeleteQuery.ExecSQL > 0) then
          jRes.B['success'] := true
        else
          jRes.B['success'] := false;
      end
      else
      begin
        queryMx.DeleteQuery.Open;
        if not queryMx.DeleteQuery.Eof then
        begin
          jRes.O['data'] := DataSetToJSON(queryMX.DeleteQuery, rqFirstRow, nbrows);
          jRes.B['success'] := true
        end
        else
          jRes.B['success'] := false;
      end;
    end
    else if method = 'DOWNLOAD' then  // Download
    begin
      // copy the http parameter values into database query Parameters
      ProcessParameters(slParams, queryMx, inStream);

      try
        queryMx.Open;
      except
        on e: exception do
        begin
          forceReleaseConnection := true;
          resultFailed(jRes, 'Error while opening database query: ' + e.message);
          LogHttp(e, 'ERROR SelectQuery ('+location+'): ' + e.message, slParams, lineNo);
          Exit;
        end;
      end;

      inStream.Clear;
      LoadFromBlob(queryMx.Fields[0], inStream);
      jRes.B['success'] := true;
    end
    else
      resultFailed(jRes, 'Could not find the method.');

    try
      queryMx.Connection := nil;
    except
      on e: exception do
        LogHttp(e, 'ERROR CleanConnection ('+location+'): ' + e.message, slParams, lineNo);
    end;

  finally
    if (connection <> nil) then
      ReleaseConnection(connection, forceReleaseConnection);

    jRes.S['ver'] := gClientVer;

    result := jRes.AsJSon;
    //FreeAndNil(jRes);
  end;
end;

initialization
  InitializeCriticalSection(CritSectConnections);
  lConnections := TList.Create;

finalization
  try
    FreeConnections;
    FreeAndNil(lConnections);
  except
  end;

  try
    DeleteCriticalSection(CritSectConnections);
  except
  end;

end.
