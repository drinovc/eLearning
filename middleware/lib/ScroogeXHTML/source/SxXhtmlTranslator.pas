(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

unit SxXhtmlTranslator;

interface

uses
  SxCustomTranslator, SxTypes;

const
  DOCTYPE_XHTML_10_TRANSITIONAL =
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
  DOCTYPE_XHTML_10_STRICT =
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">';
  DOCTYPE_XHTML_BASIC_10 =
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">';
  DOCTYPE_XHTML_MP_10 =
    '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.0//EN" "http://www.wapforum.org/DTD/xhtml-mobile10.dtd">';
  DOCTYPE_XHTML_11 =
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">';
  DOCTYPE_XHTML_50 = '<!DOCTYPE html>';

  XHTML_OPEN = '<html xmlns="http://www.w3.org/1999/xhtml">';

type
  (**
   * Generic XHTML Translator
   *)
  TXHTMLTranslator = class(TCustomTranslator)
    (** Returns the document root element. *)
    function GetRootElement: AnsiString; override;

    (** Returns " />" *)
    function GetCloseEmptyElement: AnsiString; override;

    (** Returns text with formatting CSS/XHTML tags *)
    function FormatElement(const Text: SxText; const CP: TCharacterProperties): SxText;
      override;

    (**
     * Returns True because all subclasses are XML based.
     *)
    function IsXml: Boolean; override;
    
  end;

  (**
   * XHTML 1.0 Strict Translator
   *)
  TXHTML10StrictTranslator = class(TXHTMLTranslator)
    function GetDocType: AnsiString; override;
    class function GetDocTypeName: AnsiString; override;
    function GetParagraphStyle(const pp: TParagraphProperties): AnsiString;
      override;
    function SupportsElement(const elementName: AnsiString): boolean; override;
    function SupportsParameter(const elementName: AnsiString; const paramName:
      AnsiString): boolean; override;
    function IsTransitional: boolean; override;
  end;

  (**
   * XHTML 1.0 Transitional Translator
   *)
  TXHTML10TransitionalTranslator = class(TXHTMLTranslator)
    function GetDocType: AnsiString; override;
    class function GetDocTypeName: AnsiString; override;
    (** Returns the HTML for a P element (paragraph).
     * \note
     *  XHTML 1.0 Transitional supports the 'classic' HTML parameter
     * align="..." for left or right aligned and centered paragraphs for
     * the P element (see: xhtml1-transitional.dtd).
     * To be backward compatible with older HTML browsers, this parameter will
     * be used where possible.
     * For justified paragraphs, a CSS style parameter will be used.
     *)
    function GetParagraphStyle(const PP: TParagraphProperties): AnsiString;
      override;
    function IsTransitional: Boolean; override;
  end;

  (**
   * XHTML Basic 1.0 Translator
   *)
  TXHTMLBasic10Translator = class(TXHTMLTranslator)
    function FormatElement(const Text: SxText; const CP: TCharacterProperties): SxText;
      override;
    function GetDocType: AnsiString; override;
    class function GetDocTypeName: AnsiString; override;
    function GetParagraphStyle(const PP: TParagraphProperties): AnsiString;
      override;
    function IsTransitional: Boolean; override;
    function SupportsElement(const ElementName: AnsiString): Boolean; override;
    function SupportsParameter(const ElementName, ParamName: AnsiString): boolean;
      override;
  end;

  (**
   * XHTML Mobile Profile 1.0 Translator
   *)
  TXHTMLMobileProfile10Translator = class(TXHTMLBasic10Translator)
    function GetDocType: AnsiString; override;
    class function GetDocTypeName: AnsiString; override;
    function IsTransitional: Boolean; override;
    function SupportsElement(const ElementName: AnsiString): Boolean; override;
  end;

  (**
   * XHTML 1.1 Translator
   *)
  TXHTML11Translator = class(TXHTML10StrictTranslator)
    function GetDocType: AnsiString; override;
    class function GetDocTypeName: AnsiString; override;
    function GetParagraphStyle(const PP: TParagraphProperties): AnsiString;
      override;
    function SupportsElement(const ElementName: AnsiString): Boolean; override;
    function SupportsParameter(const ElementName: AnsiString; const ParamName:
      AnsiString): Boolean; override;
    function IsTransitional: Boolean; override;
    function IsDocTypeRequired: Boolean; override;
  end;


  (**
   * XHTML 5 Translator
   *)
  TXHTML50Translator = class(TXHTML11Translator)
    function GetDocType: AnsiString; override;
    class function GetDocTypeName: AnsiString; override;
    function GetParagraphStyle(const PP: TParagraphProperties): AnsiString;
      override;
    function SupportsElement(const ElementName: AnsiString): Boolean; override;
    function SupportsParameter(const ElementName: AnsiString; const ParamName:
      AnsiString): Boolean; override;
    function IsTransitional: Boolean; override;
    (** Returns the document root element. *)
    function GetRootElement: AnsiString; override;
  end;

implementation

uses
  SysUtils;

{ TXHTMLTranslator }

function TXHTMLTranslator.GetCloseEmptyElement: AnsiString;
begin
  Result := ' />';
end;

function TXHTMLTranslator.GetRootElement: AnsiString;
begin
  Result := XHTML_OPEN;
end;

function TXHTMLTranslator.FormatElement(const Text: SxText;
  const CP: TCharacterProperties): SxText;
begin
  Result := GetCharacterStyles(Text, CP);
end;

function TXHTMLTranslator.IsXml: Boolean;
begin
  Result := True;
end;

{ TXHTML10TransitionalTranslator }

function TXHTML10TransitionalTranslator.GetDocType: AnsiString;
begin
  Result := DOCTYPE_XHTML_10_TRANSITIONAL;
end;

class function TXHTML10TransitionalTranslator.GetDocTypeName: AnsiString;
begin
  Result := 'XHTML 1.0 Transitional';
end;

function TXHTML10TransitionalTranslator.GetParagraphStyle(
  const PP: TParagraphProperties): AnsiString;
var
  indentAndDirection: AnsiString;
begin
  indentAndDirection := GetIndentAndDirectionStyle(pp);
  case pp.Alignment of
    paRightJustify: Result := getParagraph(indentAndDirection,
        ' align="right"');
    paCenter: Result := getParagraph(indentAndDirection, ' align="center"');
    paJustify: Result := getParagraph('text-align:justify;' +
        indentAndDirection);
  else
    Result := getParagraph(indentAndDirection);
  end
end;

function TXHTML10TransitionalTranslator.IsTransitional: Boolean;
begin
  Result := True;
end;

{ TXHTML10StrictTranslator }

function TXHTML10StrictTranslator.GetParagraphStyle(const PP:
  TParagraphProperties):
  AnsiString;
var
  indent: AnsiString;
begin
  indent := GetIndentAndDirectionStyle(pp);
  case pp.Alignment of
    paRightJustify: Result := getParagraph('text-align:right;' + indent);
    paCenter: Result := getParagraph('text-align:center;' + indent);
    paJustify: Result := getParagraph('text-align:justify;' + indent);
  else
    Result := getParagraph(indent);
  end
end;

function TXHTML10StrictTranslator.GetDocType: AnsiString;
begin
  Result := DOCTYPE_XHTML_10_STRICT;
end;

function TXHTML10StrictTranslator.SupportsElement(const
  elementName: AnsiString): boolean;
begin
  Result := elementName <> 'br';
end;

class function TXHTML10StrictTranslator.GetDocTypeName: AnsiString;
begin
  Result := 'XHTML 1.0 Strict';
end;

function TXHTML10StrictTranslator.SupportsParameter(
  const ElementName: AnsiString; const ParamName: AnsiString): Boolean;
begin
  if (ElementName = 'a') and (ParamName = 'target') then
    Result := False
  else
    Result := True;
end;

function TXHTML10StrictTranslator.IsTransitional: boolean;
begin
  Result := False;
end;

{ TXHTML10BasicTranslator }

function TXHTMLBasic10Translator.FormatElement(const Text: SxText;
  const CP: TCharacterProperties): SxText;
begin
  Result := Text;
  with CP do
  begin
    if IsBold then
      Result := '<strong>' + Result + '</strong>';
    if IsItalic then
      Result := '<em>' + Result + '</em>';
  end;
end;

function TXHTMLBasic10Translator.GetDocType: AnsiString;
begin
  Result := DOCTYPE_XHTML_BASIC_10;
end;

class function TXHTMLBasic10Translator.GetDocTypeName: AnsiString;
begin
  Result := 'XHTML Basic 1.0';
end;

function TXHTMLBasic10Translator.GetParagraphStyle(
  const PP: TParagraphProperties): AnsiString;
begin
  Result := GetParagraph('');
end;

function TXHTMLBasic10Translator.IsTransitional: Boolean;
begin
  Result := False;
end;

function TXHTMLBasic10Translator.SupportsElement(const
  ElementName: AnsiString): Boolean;
begin
  Result := elementName <> 'style';
end;

function TXHTMLBasic10Translator.SupportsParameter(const ElementName,
  ParamName: AnsiString): Boolean;
begin
  if (elementName = 'a') and (paramName = 'target') then
    Result := False
  else
    Result := True;
end;

{ TXHTMLMobileProfile10Translator }

function TXHTMLMobileProfile10Translator.GetDocType: AnsiString;
begin
  Result := DOCTYPE_XHTML_MP_10;
end;

class function TXHTMLMobileProfile10Translator.GetDocTypeName: AnsiString;
begin
  Result := 'XHTML Mobile 1.0';
end;

function TXHTMLMobileProfile10Translator.IsTransitional: Boolean;
begin
  Result := False;
end;

function TXHTMLMobileProfile10Translator.SupportsElement(const
  ElementName: AnsiString): Boolean;
begin
  Result := True;
end;

{ TXHTML11StrictTranslator }

function TXHTML11Translator.GetDocType: AnsiString;
begin
  Result := DOCTYPE_XHTML_11;
end;

class function TXHTML11Translator.GetDocTypeName: AnsiString;
begin
  Result := 'XHTML 1.1';
end;

function TXHTML11Translator.GetParagraphStyle(
  const PP: TParagraphProperties): AnsiString;
begin
  Result := inherited GetParagraphStyle(PP);
end;

function TXHTML11Translator.IsDocTypeRequired: Boolean;
begin
  Result := True;
end;

function TXHTML11Translator.IsTransitional: Boolean;
begin
  Result := False;
end;

function TXHTML11Translator.SupportsElement(
  const ElementName: AnsiString): Boolean;
begin
  Result := inherited SupportsElement(ElementName);
end;

function TXHTML11Translator.SupportsParameter(const ElementName,
  ParamName: AnsiString): Boolean;
begin
  Result := (ParamName<>'lang') and
    inherited SupportsParameter(ElementName, ParamName);
end;

{ TXHTML20Translator }

function TXHTML50Translator.GetDocType: AnsiString;
begin
  Result := DOCTYPE_XHTML_50;
end;

class function TXHTML50Translator.GetDocTypeName: AnsiString;
begin
  Result := 'XHTML 5';
end;

function TXHTML50Translator.GetParagraphStyle(
  const PP: TParagraphProperties): AnsiString;
begin
  Result := inherited GetParagraphStyle(PP);
end;

function TXHTML50Translator.GetRootElement: AnsiString;
begin
  Result := XHTML_OPEN;
end;

function TXHTML50Translator.IsTransitional: Boolean;
begin
  Result := False;
end;

function TXHTML50Translator.SupportsElement(
  const ElementName: AnsiString): Boolean;
begin
  Result := inherited SupportsElement(ElementName);
end;

function TXHTML50Translator.SupportsParameter(const ElementName,
  ParamName: AnsiString): Boolean;
begin
  Result := inherited SupportsParameter(ElementName, ParamName);
end;

end.

