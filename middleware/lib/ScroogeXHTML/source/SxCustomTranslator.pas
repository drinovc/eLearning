(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

unit SxCustomTranslator;

interface

uses
  SxInterfaces,
  SxTypes;

const
  HTML_SPECIAL_ENTITTY_QUOT = '&quot;';
  HTML_SPECIAL_ENTITTY_AMP = '&amp;';
  HTML_SPECIAL_ENTITTY_LT = '&lt;';
  HTML_SPECIAL_ENTITTY_GT = '&gt;';

  {** left margin }
  LEFT_MARGIN = '      ';

  (** scales the left indent of a paragraph *)
  INDENT_RATIO = 15;

  (** scales the font size conversion from point to 'em' *)
  EM_FACTOR = 12;

  (** number of significant places for 'em' font size *)
  EM_SIGNIFICANT = 2;

  (** scales the font size conversion from point to 'ex' *)
  EX_FACTOR = 14;

  (** number of significant places for 'ex' font size *)
  EX_SIGNIFICANT = 2;

  (** scales the font size conversion from point to '%' *)
  PERCENT_FACTOR = 0.12;

  (** number of significant places for '%' font size *)
  PERCENT_SIGNIFICANT = 3;

type
  (**
   * Abstract translator class.
   *)
  TCustomTranslator = class(TInterfacedObject, ISxTranslator)
  private
    ParOpen: AnsiString;
    ParStyle: AnsiString;
    FFontSizeScale: TFontSizeScale;

    function GetMarginStyle(const Twips: Integer): AnsiString;

  public
    (** Returns lang attribute *)
    function BuildLangAttribute(const Language: AnsiString): AnsiString;

    (** Returns carriage return / line feed and margin *)
    function IndentCrLf: AnsiString;

    (** Returns a CSS style for the given font size. *)
    function GetFontSizeStyle(const Pt: Integer): AnsiString;

    (** Returns a sequence of spaces (the left margin). *)
    function GetMargin: AnsiString;

    (** Encode Unicode string using UTF-8 *)
    function Encode(const S: WideString): WideString; virtual;

    (**
     * Returns the HTML / XHTML document root element.
     * \par
     * \li for HTML, this is \verbatim <html> \endverbatim
     * \li for XHTML, this is \verbatim <html xmlns="http://www.w3.org/1999/xhtml"> \endverbatim
     *)
    function GetRootElement: AnsiString; virtual; abstract;

    (** Returns the correct closing bracket for an empty element.
     * \par
     * Example:
     * \li in HTML, the linebreak element is \verbatim <br> \endverbatim
     * \li in XHTML, the linebreak element is \verbatim <br /> \endverbatim
     * \note
     * \li For HTML, the function returns \verbatim ">" \endverbatim
     * \li For XHTML, the function returns \verbatim " />" \endverbatim
     *)
    function GetCloseEmptyElement: AnsiString; virtual; abstract;

    (** Returns text with formatting CSS/HTML/XHTML tags *)
    function FormatElement(const Text: SxText; const CP: TCharacterProperties):
      SxText; virtual; abstract;

    (**
     * Get the DOCTYPE definition.
     *)
    function GetDocType: AnsiString; virtual; abstract;

    (**
     * Get the name of the doctype.
     *)
    class function GetDocTypeName: AnsiString; virtual; abstract;

    (** returns the start tag for a paragraph element *)
    function GetParagraph(const AdditionalStyle: AnsiString; const
      AdditionalParams:
      AnsiString = ''): AnsiString;

    (**
     * Converts the paragraph properties to a style definition.
     *)
    function GetParagraphStyle(const PP: TParagraphProperties): AnsiString;
      virtual;
      abstract;

    (**
     * Setter for the 'paragraph open' tag.
     *)
    procedure SetParOpen(const TagAndClass: AnsiString; const DefaultStyle:
      AnsiString);

    (**
     * Get style parameter. Add the given style.
     *)
    function GetStyleParam(const AdditionalStyle: AnsiString): AnsiString;

    (**
     * Returns True if the element is supported by the current doctype.
     *)
    function SupportsElement(const ElementName: AnsiString): Boolean; virtual;

    (**
     * Returns True if the element supports the given parameter.
     *)
    function SupportsParameter(const ElementName, ParamName: AnsiString):
      Boolean;
      virtual;

    (**
     * Returns a indent and direction style for the paragraph.
     *)
    function GetIndentAndDirectionStyle(const PP: TParagraphProperties):
      AnsiString;

    (**
     * Returns text with styles applied for the given character properties.
     *)
    function GetCharacterStyles(const Text: SxText; const CP:
      TCharacterProperties): SxText;

    (**
     * Returns True if the document type is a transitional version.
     *)
    function IsTransitional: boolean; virtual; abstract;

    (**
     * Returns True if a DOCTYPE declaration is required (see XHTML 1.1).
     *)
    function IsDocTypeRequired: Boolean; dynamic;

    (**
     * Returns True if it is an XML based Translator.
     *)
    function IsXml: Boolean; virtual; abstract;

    (**
     * Setter for the font size scale.
     *)
    procedure SetFontSizeScale(const FSS: TFontSizeScale);

  end;

implementation

uses
  SysUtils, Math;

{ TCustomTranslator }

function TCustomTranslator.Encode(const S: WideString): WideString;
var
  I: Integer;
  C: WideChar;
begin
  Result := '';
  for I := 1 to Length(S) do
  begin
    C := S[I];
    case C of
      '>': Result := Result + HTML_SPECIAL_ENTITTY_GT;
      '<': Result := Result + HTML_SPECIAL_ENTITTY_LT;
      '&': Result := Result + HTML_SPECIAL_ENTITTY_AMP;
      '"': Result := Result + HTML_SPECIAL_ENTITTY_QUOT;
    else
      begin
{$IFDEF SCROOGE_UTF8}
        Result := Result + C;
{$ELSE}
        if Cardinal(C) < 128 then
          Result := Result + C
        else
          Result := Result + '&#' + IntToStr(Cardinal(C)) + ';';
{$ENDIF}
      end;
    end;
  end;
end;

function TCustomTranslator.IndentCrLf: AnsiString;
begin
  Result := CrLf + getMargin;
end;

function TCustomTranslator.GetMargin: AnsiString;
begin
  Result := LEFT_MARGIN;
end;

function TCustomTranslator.GetParagraph(const AdditionalStyle: AnsiString;
  const AdditionalParams: AnsiString = ''): AnsiString;
begin
  Result := '    ' + parOpen + additionalParams + getStyleParam(additionalStyle)
    + '>' + CrLf + getMargin();
end;

procedure TCustomTranslator.SetParOpen(const TagAndClass, DefaultStyle:
  AnsiString);
begin
  parOpen := tagAndClass;
  parStyle := defaultStyle;
end;

function TCustomTranslator.SupportsElement(const ElementName: AnsiString):
  Boolean;
begin
  Result := True;
end;

function TCustomTranslator.GetStyleParam(const AdditionalStyle: AnsiString):
  AnsiString;
begin
  Result := parStyle;
  if AdditionalStyle <> '' then
  begin
    if Result <> '' then
      Result := Result + ';';
    Result := Result + AdditionalStyle;
  end;
  if Result <> '' then
    Result := ' style="' + Result + '"';
end;

function TCustomTranslator.GetFontSizeStyle(const Pt: Integer): AnsiString;
begin
  case FFontSizeScale of
    // use absolute size in "point" (pt)
    fsPoint: Result := AnsiString('font-size:' + IntToStr(pt) + 'pt;');
    // use relative size in "em"
    fsEM: Result := AnsiString('font-size:' +
        StringReplace(Format('%.' + IntToStr(EM_SIGNIFICANT) + 'g',
        [Ceil(EM_FACTOR * pt / EM_FACTOR) / EM_FACTOR]),
        DecimalSeparator, '.', []) + 'em;');
    // use relative size in "ex"
    fsEX: Result := AnsiString('font-size:' +
        StringReplace(Format('%.' + IntToStr(EX_SIGNIFICANT) + 'g',
        [Ceil(EX_FACTOR * pt / EX_FACTOR) / EM_FACTOR]),
        DecimalSeparator, '.', []) + 'ex;');
    // use relative size in "percent" (%)
    fsPercent: Result := AnsiString('font-size:' +
        StringReplace(Format('%.' + IntToStr(PERCENT_SIGNIFICANT) + 'g',
        [Ceil(PERCENT_FACTOR * pt / PERCENT_FACTOR) / PERCENT_FACTOR]),
        DecimalSeparator, '.', []) + '%;');
  end;
end;

function TwipsToPix(const Twips: Integer): Integer;
begin
  if twips < 0 then
    Result := Floor(twips / INDENT_RATIO)
  else
    Result := Ceil(twips / INDENT_RATIO);
end;

function TCustomTranslator.GetMarginStyle(const Twips: Integer): AnsiString;
begin
  Result := AnsiString(IntToStr(TwipsToPix(twips)) + 'px;');
end;

function TCustomTranslator.GetIndentAndDirectionStyle(const
  PP: TParagraphProperties): AnsiString;
begin
  Result := '';
  if pp.leftindent <> 0 then
    Result := Result + 'margin-left:' + GetMarginStyle(pp.leftindent);
  if pp.rightindent <> 0 then
    Result := Result + 'margin-right:' + GetMarginStyle(pp.rightindent);
  if pp.firstindent <> 0 then
    Result := Result + 'text-indent:' + GetMarginStyle(pp.firstindent);
  // add text direction
  if pp.Direction = diRTL then
    Result := Result + 'direction:rtl;'
end;

function TCustomTranslator.GetCharacterStyles(const Text: SxText; const CP:
  TCharacterProperties): SxText;
var
  FontStyleCSS, CSS: AnsiString;
  Lang: AnsiString;
begin
  Result := Text;
  if IsTransitional then
    with CP do
    begin
      // supported in Transitional doctypes
      if IsBold then
        Result := '<b>' + Result + '</b>';
      if IsItalic then
        Result := '<i>' + Result + '</i>';
      if IsUnderline then
        Result := '<u>' + Result + '</u>';
      if IsStrike then
        Result := '<strike>' + Result + '</strike>';
      if (VerticalAlignment = vaSub) then
        Result := '<sub>' + Result + '</sub>';
      if (VerticalAlignment = vaSuper) then
        Result := '<sup>' + Result + '</sup>';
    end
  else
  begin
    // not supported in Transitional doctypes
    with CP do
    begin
      FontStyleCSS := '';
      if IsBold then
        FontStyleCSS := FontStyleCSS + 'font-weight:bold;';
      if IsItalic then
        FontStyleCSS := FontStyleCSS + 'font-style:italic;';
      if IsUnderline then
        FontStyleCSS := FontStyleCSS + 'text-decoration:underline;';
      if IsStrike then
        FontStyleCSS := FontStyleCSS + 'text-decoration:line-through;';
      if (VerticalAlignment = vaSub) then
        FontStyleCSS := FontStyleCSS + 'vertical-align:sub;';
      if (VerticalAlignment = vaSuper) then
        FontStyleCSS := FontStyleCSS + 'vertical-align:super;';
    end // with
  end;

  // supported in Strict and Transitional
  with CP do
  begin
    // only include the font name is not the default font
    if (FontName <> '') then
      FontStyleCSS := FontStyleCSS + 'font-family:' + fontName + ';';
    // only include the color if it is not the default color
    if (FontColor <> '') then
      FontStyleCSS := FontStyleCSS + 'color:' + Fontcolor + ';';
    // only include the background color if it is not empty
    if (Fontbgcolor <> '') then
      FontStyleCSS := FontStyleCSS + 'background-color:' + Fontbgcolor + ';';
    // only include the highlight color if it is not empty
    if (Fonthlcolor <> '') then
      FontStyleCSS := FontStyleCSS + 'background-color:' + Fonthlcolor + ';';
    // only include the size if it is not the default size
    if (FontSize <> 0) then
      FontStyleCSS := FontStyleCSS + GetFontSizeStyle(Fontsize);
    // left-to-right text
    if (Direction = diRTL) then
      FontStyleCSS := FontStyleCSS + 'direction:rtl;';
  end;

  if (FontStyleCSS <> '') then
    CSS := ' style=' + IndentCrLf + '"' + FontStyleCSS + '"';

  if CP.Language <> '' then
    Lang := BuildLangAttribute(CP.Language);

  if (CSS <> '') or (Lang <> '') then
    Result := '<span' + CSS + Lang + '>' + Result + '</span>';

end;

function TCustomTranslator.SupportsParameter(const ElementName: AnsiString;
  const ParamName: AnsiString): Boolean;
begin
  Result := True;
end;

procedure TCustomTranslator.SetFontSizeScale(const FSS: TFontSizeScale);
begin
  FFontSizeScale := FSS;
end;

function TCustomTranslator.BuildLangAttribute(const Language: AnsiString):
  AnsiString;
begin
  Result := '';
  if (Language <> '') then
  begin
    if SupportsParameter('', 'lang') then
      Result := ' lang="' + Language + '"';
    if IsXml then
      Result := ' xml:lang="' + Language + '"' + Result;
  end;
end;

function TCustomTranslator.IsDocTypeRequired: Boolean;
begin
  Result := False;
end;

end.

