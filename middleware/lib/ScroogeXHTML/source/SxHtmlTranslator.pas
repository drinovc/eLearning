(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

unit SxHtmlTranslator;

interface

uses
  SxCustomTranslator, SxTypes;

const
  DOCTYPE_HTML_401_TRANSITIONAL =
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">';
  DOCTYPE_HTML_401_STRICT =
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">';
  DOCTYPE_HTML_50 = '<!DOCTYPE html>';

  HTML_OPEN = '<html>';

type

  (**
   * Generic HTML translator.
   *)
  THTMLTranslator = class(TCustomTranslator)
    (** Returns the document root element. *)
    function GetRootElement: AnsiString; override;

    (** Returns ">" *)
    function GetCloseEmptyElement: AnsiString; override;

    (** Returns text with formatting CSS/HTML tags *)
    function FormatElement(const Text: SxText; const CP: TCharacterProperties): SxText; override;

    (**
     * Returns False because no subclasses are XML based.
     *)
    function IsXml: Boolean; override;

  end;

  (**
   * Translator for HTML 4.01 Transitional
   *
   *
   *)
  THTML401TransitionalTranslator = class(THTMLTranslator)
    function GetDocType: AnsiString; override;
    class function GetDocTypeName: AnsiString; override;
    function GetParagraphStyle(const pp: TParagraphProperties): AnsiString; override;
    function IsTransitional: boolean; override;
  end;

  (**
   * Translator for HTML 4.01 Strict
   *
   *
   *
   *)
  THTML401StrictTranslator = class(THTMLTranslator)
    function GetDocType: AnsiString; override;
    class function GetDocTypeName: AnsiString; override;
    function GetParagraphStyle(const pp: TParagraphProperties): AnsiString; override;
    function IsTransitional: boolean; override;
    function SupportsElement(const elementName: AnsiString): boolean; override;
    function SupportsParameter(const elementName, paramName: AnsiString): boolean;
      override;
  end;

  (**
   * Translator for HTML5
   *
   *
   *)
  THTML50Translator = class(THTMLTranslator)
    function GetDocType: AnsiString; override;
    class function GetDocTypeName: AnsiString; override;
    function GetParagraphStyle(const pp: TParagraphProperties): AnsiString; override;
    function IsTransitional: boolean; override;
    function SupportsElement(const elementName: AnsiString): boolean; override;
  end;

implementation

uses
  SysUtils;

{ THTMLTranslator }

function THTMLTranslator.GetCloseEmptyElement: AnsiString;
begin
  result := '>';
end;

function THTMLTranslator.GetRootElement: AnsiString;
begin
  result := HTML_OPEN;
end;

function THTMLTranslator.FormatElement(const Text: SxText;
  const CP: TCharacterProperties): SxText;
begin
  Result := GetCharacterStyles(Text, CP);
end;

function THTMLTranslator.IsXml: Boolean;
begin
  Result := False;
end;

{ THTML401TransitionalTranslator }

function THTML401TransitionalTranslator.GetDocType: AnsiString;
begin
  Result := DOCTYPE_HTML_401_TRANSITIONAL;
end;

class function THTML401TransitionalTranslator.GetDocTypeName: AnsiString;
begin
  Result := 'HTML 4.01 Transitional';
end;

function THTML401TransitionalTranslator.GetParagraphStyle(
  const pp: TParagraphProperties): AnsiString;
var
  indent: AnsiString;
begin
  indent := GetIndentAndDirectionStyle(pp);
  case pp.Alignment of
    paRightJustify: result := getParagraph(indent, ' align="right"');
    paCenter: result := getParagraph(indent, ' align="center"');
    paJustify: result := getParagraph(indent, ' align="justify"');
  else
    result := getParagraph(indent);
  end
end;

function THTML401TransitionalTranslator.IsTransitional: boolean;
begin
  Result := True;
end;

{ THTML401StrictTranslator }

function THTML401StrictTranslator.GetDocType: AnsiString;
begin
  Result := DOCTYPE_HTML_401_STRICT;
end;

class function THTML401StrictTranslator.GetDocTypeName: AnsiString;
begin
  Result := 'HTML 4.01 Strict';
end;

function THTML401StrictTranslator.GetParagraphStyle(
  const pp: TParagraphProperties): AnsiString;
var
  indentAndDirection: AnsiString;
begin
  indentAndDirection := GetIndentAndDirectionStyle(pp);
  case pp.Alignment of
    paRightJustify: result := getParagraph('text-align:right;' +
        indentAndDirection);
    paCenter: result := getParagraph('text-align:center;' + indentAndDirection);
    paJustify: result := getParagraph('text-align:justify;' +
        indentAndDirection);
  else
    result := getParagraph(indentAndDirection);
  end
end;

function THTML401StrictTranslator.IsTransitional: boolean;
begin
  Result := False;
end;

function THTML401StrictTranslator.SupportsElement(const
  elementName: AnsiString): boolean;
begin
  result := elementName <> 'br';
end;

function THTML401StrictTranslator.SupportsParameter(
  const elementName: AnsiString; const paramName: AnsiString): boolean;
begin
  if (elementName = 'a') and (paramName = 'target') then
    result := false
  else
    result := true;
end;

{ THTML50TransitionalTranslator }

function THTML50Translator.GetDocType: AnsiString;
begin
  Result := DOCTYPE_HTML_50;
end;

class function THTML50Translator.GetDocTypeName: AnsiString;
begin
  Result := 'HTML5';
end;

function THTML50Translator.GetParagraphStyle(
  const pp: TParagraphProperties): AnsiString;
var
  indentAndDirection: AnsiString;
begin
  indentAndDirection := GetIndentAndDirectionStyle(pp);
  case pp.Alignment of
    paRightJustify: result := getParagraph('text-align:right;' +
        indentAndDirection);
    paCenter: result := getParagraph('text-align:center;' + indentAndDirection);
    paJustify: result := getParagraph('text-align:justify;' +
        indentAndDirection);
  else
    result := getParagraph(indentAndDirection);
  end
end;

function THTML50Translator.IsTransitional: boolean;
begin
  Result := False;
end;

function THTML50Translator.SupportsElement(
  const elementName: AnsiString): boolean;
begin
  Result := True;
end;

end.

