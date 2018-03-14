(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

unit SxUnicode;

interface

uses
  SxTypes, // TCharset
  SxInterfaces;

const
  UNICODEGREEKOFFSET = 848;

  ANSI_CHARSET = 0;
  DEFAULT_CHARSET = 1;
  SYMBOL_CHARSET = 2;
  SHIFTJIS_CHARSET = $80;
  HANGEUL_CHARSET = 129;
  GB2312_CHARSET = 134;
  CHINESEBIG5_CHARSET = 136;
  OEM_CHARSET = 255;
  JOHAB_CHARSET = 130;
  HEBREW_CHARSET = 177;
  ARABIC_CHARSET = 178;
  GREEK_CHARSET = 161;
  TURKISH_CHARSET = 162;
  VIETNAMESE_CHARSET = 163;
  THAI_CHARSET = 222;
  EASTEUROPE_CHARSET = 238;
  RUSSIAN_CHARSET = 204;
  MAC_CHARSET = 77;
  BALTIC_CHARSET = 186;

  // CP = code page values
  // LC = locale values for Linux

  CP_THAI = 874;
  LC_THAI = 'th_TH.TIS-620';

  CP_EASTEUROPE = 1250;
  LC_EASTEUROPE = '?';

  CP_RUSSIAN = 1251;
  LC_RUSSIAN = 'CP1251'; // or ru_RU.CP1251 ?

  CP_ANSI = 1252;
  LC_ANSI = '?'; // ISO-8859-1 ?

  CP_GREEK = 1253;
  LC_GREEK = 'greek'; // or el_GR.ISO-8859-7 ?

  CP_TURKISH = 1254;
  LC_TURKISH = 'turkish'; // ?

  CP_HEBREW = 1255;
  LC_HEBREW = 'CP1255'; // or he_IL.ISO-8859-8 ?

  CP_ARABIC = 1256;
  LC_ARABIC = 'ar_EG.CP1256'; // or 'CP1256' ?

  CP_BALTIC = 1257;
  LC_BALTIC = 'CP1257'; // ?

  CP_VIETNAMESE = 1258;
  LC_VIETNAMESE = 'vi_VN';

type

  (**
   * Unicode converter class.
   *)
  TUnicodeConverter = class(TInterfacedObject, IUnicodeConverter)
{$IFNDEF DOXYGEN_SKIP}
  private
    FCharSet: TCharSet;
    FCodePage: TCodePage;
    FDBCS: Boolean;

    dbcsNibble: shortint;
    dbcsString: AnsiString;

    function GetCharSet: TCharSet;
    procedure SetCharSet(const Value: TCharSet);

    function IsDBCS: Boolean;
    procedure SetDBCS(const Value: Boolean);

    function IntCharToUnicode(const s: AnsiString): WideString;

{$ENDIF}


  public
    constructor Create;

    (**
     * Convert a character to a WideChar character.
     *)
    function CharToUnicode(const C: AnsiChar): WideString;

    (**
     * \property CharSet
     *
     * The Charset property contains the current text node's character set.
     *)
    property CharSet: TCharSet read GetCharSet write SetCharSet;

    (**
     * \property DBCS
     *
     * The DBCS property indicates a double byte character set.
     *)
    property DBCS: Boolean read IsDBCS write SetDBCS;

  end;

function SymbolToUnicode(const A: AnsiString): WideString;

function CharsetToCodepage(const c: TCharset): Integer;

implementation

uses
  SxPlatform,
  SysUtils;

function SymbolToUnicode(const A: AnsiString): WideString;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(A) do
  begin
    if AnsiChar(A[I]) in ['a'..'z', 'A'..'Z'] then
      Result := Result + WideChar(Cardinal(A[i]) + UNICODEGREEKOFFSET)
    else
      Result := Result + WideChar(A[I]);
  end
end;

function CharsetToCodepage;
begin
  case c of
    SYMBOL_CHARSET: result := 0;
    THAI_CHARSET: result := CP_THAI;
    SHIFTJIS_CHARSET: result := 932; // Japanese
    GB2312_CHARSET: result := 936; // Simplified Chinese
    HANGEUL_CHARSET: result := 949; // Korean
    CHINESEBIG5_CHARSET: result := 950; // Traditional Chinese
    EASTEUROPE_CHARSET: result := CP_EASTEUROPE;
    RUSSIAN_CHARSET: result := CP_RUSSIAN;
    ANSI_CHARSET: result := CP_ANSI;
    GREEK_CHARSET: result := CP_GREEK;
    TURKISH_CHARSET: result := CP_TURKISH;
    HEBREW_CHARSET: result := CP_HEBREW;
    ARABIC_CHARSET: result := CP_ARABIC;
    BALTIC_CHARSET: result := CP_BALTIC;
    VIETNAMESE_CHARSET: result := CP_VIETNAMESE;
  else
    {#todo3 use ansicpg }
    result := CP_ANSI
  end;
end;

function TUnicodeConverter.IntCharToUnicode(const S: AnsiString): WideString;
begin
  if FCodePage = 0 then
    // SYMBOL
    Result := WideString(S)
  else
  begin
    Result := StringToWideStringEx(S, FCodePage);
    if Result = '' then
      Result := '?';
  end
end;

{ TUnicodeConverter }

constructor TUnicodeConverter.Create;
begin
  inherited;
  dbcsNibble := 2;
end;

function TUnicodeConverter.GetCharSet: TCharSet;
begin
  result := FCharSet;
end;

function TUnicodeConverter.isDBCS: boolean;
begin
  result := FDBCS;
end;

procedure TUnicodeConverter.SetCharSet(const Value: TCharSet);
begin
  if Value <> CharSet then
  begin
    FCharSet := Value;
    FCodePage := CharsetToCodepage(FCharSet);
    // check if it is a double-byte character set
    FDBCS := FCharSet in [SHIFTJIS_CHARSET, GB2312_CHARSET, HANGEUL_CHARSET,
      CHINESEBIG5_CHARSET];
    if isDBCS then
    begin
      dbcsNibble := 2;
      dbcsString := '';
    end;
  end;
end;

procedure TUnicodeConverter.SetDBCS(const Value: boolean);
begin
  FDBCS := Value;
end;

function TUnicodeConverter.CharToUnicode(const C: AnsiChar): WideString;
begin
  if IsDBCS then
  begin
    if (DbcsNibble = 2) and (C < #$80) then
    begin
      Result := WideChar(C);
    end
    else
    begin
      // S := IntToHex(Integer(C), 2);
      DbcsString := DbcsString + C;
      Dec(DbcsNibble);
      if DbcsNibble = 0 then
      begin
        Result := IntCharToUnicode(DbcsString);
        DbcsNibble := 2;
        DbcsString := '';
      end
      else
        Result := '';
    end
  end
  else
  begin
    if C < #$80 then
      Result := WideChar(C)
    else
      Result := IntCharToUnicode(C);
  end;
end;

end.

