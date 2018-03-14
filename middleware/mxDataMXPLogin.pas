unit mxDataMXPLogin;

interface

uses
  Windows, SysUtils, Classes, DB, ADODB, Types, StrUtils;

function changeConnectionDataSource(constr: string; dataSource: string): string;
function updateConnectionString(constr, field, value: string): string;

function changeConnectionMXPUser(user_guid: string; pin_code: string; var con_string, errmsg: ansistring): boolean; overload;
function changeConnectionMXPUser(ado_connection: TADOConnection; user_guid: string; pin_code: string): boolean; overload;

function getMXPLoginInfo(const con_string: string; const user_guid: string; const pin_code: string; var userid: integer; var username, password, errmsg: ansistring): boolean; overload;
function getMXPLoginInfo(con_string: string; user_guid: string; pin_code: string; var userid: integer; var username, password: ansistring): boolean; overload;

function EncryptionWithPassword(Str, Pwd: AnsiString; Encode: Boolean; PassDigit :Integer): AnsiString;

implementation

function updateConnectionString(constr, field, value: string): string;
var n, ne: integer;
begin
  if conStr <> '' then
  begin
    // remove the original data source if exists
    n := Pos(field + '=', conStr);
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

function changeConnectionDataSource(constr: string; dataSource: string): string;
begin
  result := updateConnectionString(constr, 'Data Source', dataSource);
end;

function RotateBits(C: AnsiChar; Bits: Integer): AnsiChar;
var  SI : Word;
begin
 try
  Bits := Bits mod 8;
  if Bits < 0 then begin
   SI := MakeWord(Byte(C),0);
   SI := SI shl Abs(Bits);
  end
  else
  begin
   SI := MakeWord(0,Byte(C));
   SI := SI shr Abs(Bits);
  end;
  SI := Swap(SI);
  SI := Lo(SI) or Hi(SI);
  Result := AnsiChar(Chr(SI));
 except
  //on e:exception do MessageDlg('Unable to rotate encryption bits! Reason: '+e.message,mtError,[mbOK],0);
 end;
end;

function EncryptionWithPassword(Str,Pwd: AnsiString; Encode: Boolean;PassDigit :Integer): AnsiString;
var  a,PwdChk,Direction,ShiftVal,PasswordDigit : Integer;
begin
 try
  PasswordDigit := PassDigit;
  PwdChk := 0;
  for a := 1 to Length(Pwd) do Inc(PwdChk,Ord(Pwd[a]));
  Result := Str;
  if Encode then Direction := -1 else Direction := 1;
  for a := 1 to Length(Result) do begin
   if Length(Pwd)=0 then ShiftVal := a else
   ShiftVal := Ord(Pwd[PasswordDigit]);

   if Odd(A) then Result[A] := RotateBits(Result[A],-Direction*(ShiftVal+PwdChk)) else
   Result[A] := RotateBits(Result[A],Direction*(ShiftVal+PwdChk));
   inc(PasswordDigit);
   if PasswordDigit > Length(Pwd) then PasswordDigit := 1;
  end;
 except
  //on e:exception do MessageDlg('Unable to encrypt password! Reason: '+e.message,mtError,[mbOK],0);
 end;
end;

function getMXPLoginInfo(const con_string: string; const user_guid: string; const pin_code: string; var userid: integer; var username, password, errmsg: ansistring): boolean;
var pwd: AnsiString;
    MXPUsers: TADOQuery;
begin
  result := False;
  username := '';
  password := '';
  errmsg := '';

  MXPUsers := TADOQuery.Create(nil);
  MXPUsers.ConnectionString := con_string;
  try
    with MXPUsers do
    begin
      SQL.Text := 'SELECT USER_PIN_CODE, USER_ID, USERNAME, PASSWORD, PASSWORD_ENCRYPTED FROM Users WHERE GUID = :user_guid';
      Parameters[0].Value := user_guid;
      Open;
      if not eof then
      begin
        if (pin_code = '') or (fieldByName('user_pin_code').AsString = pin_code) then
        begin
          userid := fieldByName('USER_ID').AsInteger;
          username := fieldByName('USERNAME').AsString;
          pwd := fieldByName('PASSWORD').value;
//          pwd := '';
          if (fieldByName('PASSWORD_ENCRYPTED').AsBoolean) then
            password := EncryptionWithPassword(pwd,username,False,1)
          else
            password := pwd;
          password := password; // + '@qyE23QX3434';

          result := True;
        end
        else
          Raise Exception.Create('Wrong pin code');
      end
      else
        Raise Exception.Create('User ID not found');
    end;
  except
    on e : Exception do begin
      errmsg := e.message;
    end;
  end;
  MXPUsers.Free;
end;

function getMXPLoginInfo(con_string: string; user_guid: string; pin_code: string; var userid: integer; var username, password: ansistring): boolean;
var errmsg: ansistring;
begin
  result := getMXPLoginInfo(con_string, user_guid, pin_code, userid, username, password);
  if not result then
    raise Exception.Create(errmsg);
end;

function changeConnectionMXPUser(user_guid, pin_code: string; var con_string, errmsg: ansistring): boolean;
var
  userid: integer;
  username, password: ansistring;
begin
  result := getMXPLoginInfo(con_string, user_guid, pin_code, userid, username, password, errmsg);
  if result then
  begin
    con_string := updateConnectionString(con_string, 'Password', password);
    con_string := updateConnectionString(con_string, 'User ID', username);
  end;
end;

function changeConnectionMXPUser(ado_connection: TADOConnection; user_guid: string; pin_code: string): boolean;
var con_string, errmsg: ansistring;
begin
  con_string := ado_connection.ConnectionString;
  result := changeConnectionMXPUser(user_guid, pin_code, con_string, errmsg);
  if result then
    ado_connection.ConnectionString := con_string
  else
    Raise Exception.Create(errmsg);
end;

end.
