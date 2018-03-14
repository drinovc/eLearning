(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

unit SxPlatform;

interface

uses
  SysUtils {$IFDEF LINUX}, DateUtils {$ELSE}, Windows {$ENDIF};

function StringToWideStringEx(const S: AnsiString; const CodePage: Word):
  WideString;

function GetUTCDateTime: AnsiString;

implementation

function TwoDigits(const S: Word): AnsiString;
begin
  Result := AnsiString(Format('%2.2d', [S]));
end;

function StringToWideStringEx(const S: AnsiString; const CodePage: Word):
  WideString;
var
  InputLength,
    OutputLength: Integer;
begin
  {$IFDEF LINUX}
  mbtowc();
  {$ELSE}
  InputLength := Length(S);
  OutputLength := MultiByteToWideChar(CodePage, 0, PAnsiChar(S), InputLength, nil,
    0);
  SetLength(Result, OutputLength);
  MultiByteToWideChar(CodePage, 0, PAnsiChar(S), InputLength, PWideChar(Result),
    OutputLength);
  {$ENDIF}
end;

// see http://community.borland.com/article/0,1410,16157,00.html
// "Getting the time and date in Universal Time"

function GetUTCDateTime: AnsiString;
var
  ST: TSYSTEMTIME;
begin
  {$IFDEF LINUX}
  Result := DateTimeToStr(0);
  {$ELSE}
  GetSystemTime(ST);
  result := AnsiString(IntToStr(ST.wYear)) + '-' +
    TwoDigits(ST.wmonth) + '-' +
    TwoDigits(ST.wDay) + '-' + 'T' +
    TwoDigits(ST.wHour) + ':' +
    TwoDigits(ST.wMinute) + ':' +
    TwoDigits(ST.wSecond) + '+00:00'
  {$ENDIF}
end;

end.

