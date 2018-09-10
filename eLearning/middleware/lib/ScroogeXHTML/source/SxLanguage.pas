(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

unit SxLanguage;

(**
 * A unit which converts a Windows LCID language code to the
 * corresponding ISO 639-1 two letter code.
 *
 * The complete ISO 639 code list contains 136 languages, not all
 * languages are included in this class.
 *
 * Important: language codes may change in the future.
 *
 * References:
 *
 * - List of Locale ID (LCID) Values as Assigned by Microsoft
 *   http://www.microsoft.com/globaldev/reference/lcid-all.mspx
 *
 * - Language Codes:  ISO 639, Microsoft and Macintosh
 *   a draft list of language code correspondences between ISO codes,
 *   Microsoft codes, and Macintosh codes
 *   http://www.unicode.org/onlinedat/languages.html
 *
 * - Code for the Representation of the Names of Languages. From ISO 639,
 *   revised 1989.
 *   http://www.oasis-open.org/cover/iso639a.html
 *
 * - ISO 639
 *   http://www.rtt.org/ISO/TC37/SC2/WG1/639

   NOLANGUAGE = 0x0400;
   LG_ALBANIAN = 0x041c; // sq
   LG_ARABIC = 0x0401; // ar
   LG_BAHASA = 0x0421; // id (Indonesia)
   LG_BELGIANDUTCH = 0x0813; // nl
   LG_BELGIANFRENCH = 0x080c; // fr
   LG_BRAZILIANPORTUGUESE = 0x0416;
   LG_BULGARIAN = 0x0402; // bg
   LG_BURMESE = 0x0455; // my
   LG_CAMBODIAN = 0x0453; // km
   LG_CATALAN = 0x0403; // ca
   LG_CROATOSERBIANLATIN = 0x041a; // SH
   LG_CZECH = 0x0405; // cs
   LG_DANISH = 0x0406; // da
   LG_DUTCH = 0x0413; // nl
   LG_ENGLISHAUSTRALIAN = 0x0c09; // en
   LG_ENGLISHUK = 0x0809; // en
   LG_ENGLISHUS = 0x0409; // en
   LG_FINNISH = 0x040b; // fi
   LG_FRENCH = 0x040c; // fr
   LG_FRENCHCANADIAN = 0x0c0c; // ka
   LG_GERMAN = 0x0407; // de
   LG_GREEK = 0x0408; // el
   LG_HEBREW = 0x040d; // he
   LG_HUNGARIAN = 0x040e; // hu
   LG_ICELANDIC = 0x040f; // is
   LG_INUKTITUT = 0x045d; // iu
   LG_ITALIAN = 0x0410; // it
   LG_JAPANESE = 0x0411; // ja
   LG_KOREAN = 0x0412; // ko
   LG_LAOTIC = 0x0454; // lo
   LG_NORWEGIANBOKMAL = 0x0414; // no
   LG_NORWEGIANNYNORSK = 0x0814; // no
   LG_POLISH = 0x0415; // pl
   LG_PORTUGUESE = 0x0816; // pt
   LG_RHAETOROMANIC = 0x0417; // rm
   LG_ROMANIAN = 0x0418; // ro
   LG_RUSSIAN = 0x0419; // ru
   LG_SERBOCROATIANCYRILLIC = 0x081a; // sh
   LG_SIMPLIFIEDCHINESE = 0x0804; // zh
   LG_SLOVAK = 0x041b; // sk
   LG_SPANISHCASTILIAN = 0x040a; // es
   LG_SPANISHMEXICAN = 0x080a; // es
   LG_SWEDISH = 0x041d; // se
   LG_SWISSFRENCH = 0x100c; // fr
   LG_SWISSGERMAN = 0x0807; // de
   LG_SWISSITALIAN = 0x0810; // it
   LG_THAI = 0x041e; // th
   LG_TRADITIONALCHINESE = 0x0404; // zh
   LG_TURKISH = 0x041f; // tr
   LG_URDU = 0x0420; // ur
   LG_SESOTHOSOTHO = 0x0430; // st
   LG_AFRIKAANS = 0x0436; // af
   LG_ZULU = 0x0435; // zu
   LG_XHOSA = 0x0434; // xh
   LG_VENDA = 0x0433; // ve
   LG_TSWANA = 0x0432; // ??
   LG_TSONGA = 0x0431; // ??
   LG_FARSIPERSIAN = 0x0429; // fa

 *)
interface

(**
 * Convert a LCID to the two-letter language code.
 *)
function GetLanguageCode(const langId: Integer): AnsiString;

implementation

function GetLanguageCode(const langId: Integer): AnsiString;
begin
  case langId of
    $0401: Result := 'ar';
    $0407: Result := 'de';
    $0809: Result := 'en';
    $0409: Result := 'en';
    $040a: Result := 'es';
    $040C: Result := 'fr';
    $0410: Result := 'it';
    $0411: Result := 'ja';
    $0419: Result := 'ru';
    $041d: Result := 'se';
    $041e: Result := 'th';
    $0404: Result := 'zh';
    $0804: Result := 'zh';
  else
    Result := '';
  end;
end;

end.

