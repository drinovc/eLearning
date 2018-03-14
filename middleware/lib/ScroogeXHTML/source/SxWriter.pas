(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

(** unit for the TSxWriter class *)
unit SxWriter;

interface

uses
  SxInterfaces,
  SxTypes,
  SxSimpleDomInterfaces,
  Classes; // TStrings

type
  (**
   * Class which writes text and properties to a TSimpleDomDocument instance.
   *)
  TSxWriter = class(TInterfacedObject, ISxWriter)
  private
{$IFNDEF DOXYGEN_SKIP}
    WriterOptions: ISxWriterOptions; //
    CharProps: TCharacterProperties;
    ParProps: TParagraphProperties;
    FDefaultFontName: AnsiString;
    UnicodeConverter: IUnicodeConverter;
    FDocCharset: TCharset;
    FDomDocument: ISimpleDomDocument;
    FIsNumbered: Boolean;
    FHidden: Boolean;
{$ENDIF}

    procedure SetDirection(const Value: TDirection);
    procedure SetParDirection(const Value: TDirection);

    (** font name which will be used if no font is specified *)
    procedure SetDefaultFontName(const Value: AnsiString); virtual;
    // character properties
    (** set the font name property *)
    procedure SetFontName(const Value: AnsiString);
    (** set the font character set property *)
    procedure SetFontCharSet(const Value: TCharSet);
    (** set the font color property *)
    procedure SetFontColor(const Value: AnsiString);
    (** set the font background color property *)
    procedure SetFontBGColor(const Value: AnsiString);
    (** set the font highlight color property *)
    procedure SetFontHLColor(const Value: AnsiString);
    (** set the font style property *)
    procedure SetFontStyle(const Value: TFontstyles);
    (** get the font style property *)
    function GetFontStyle: TFontstyles;
    (** set the font size property *)
    procedure SetFontSize(const Value: Integer);
    (** get the hidden text property *)
    function GetHidden: Boolean;
    (** set the hidden text property *)
    procedure SetHidden(const Value: Boolean);
    (** set the font superscript property *)
    procedure SetSuperscript(const Value: boolean);
    (** get the font superscript property *)
    function GetSubscript: boolean;
    (** set the font subcript property *)
    procedure SetSubscript(const Value: boolean);
    (** get the font subcript property *)
    function GetSuperscript: boolean;
    // paragraph properties
    (** set the paragraph alignment property *)
    procedure SetAlignment(const Value: TParagraphAlignment);
    (** set the paragraph numbering level property *)
    procedure SetNumberingLevel(const Value: TNumberingLevel);
    (** set the paragraph numbering style property *)
    procedure SetNumberingStyle(const Value: Boolean);
    (** get the paragraph numbering style property *)
    function GetNumberingStyle: Boolean;
    (** set the languange property *)
    procedure SetLanguage(const Value: AnsiString);
    (** get the left indent property *)
    procedure SetLeftIndent(const Value: Integer);
    (** set the right indent property *)
    procedure SetRightIndent(const Value: Integer);
    (** get the first indent property *)
    procedure SetFirstIndent(const Value: Integer);
    procedure SetDocCharset(const Value: TCharset);
    function GetDocCharset: TCharset;
    procedure SetDomDocument(const Value: ISimpleDomDocument);
    function GetDomDocument: ISimpleDomDocument;
    procedure SetIsNumbered(const Value: Boolean);
    function GetIsNumbered: Boolean;
    function GetDefaultFontName: AnsiString;
    function GetNumberingLevel: TNumberingLevel;

    (** global (!) flag for numbered list *)
    property IsNumbered: Boolean read GetIsNumbered write SetIsNumbered;

  public
    (** get a new ScroogeXHTMLWriter instance *)
    constructor Create(const Owner: ISxWriterOptions);
    (** destroy the ScroogeXHTMLWriter instance *)
    destructor Destroy; override;

    (** Add an Element to the last paragraph *)
    // procedure AddElement(const ElementName: AnsiString; const TextContent: WideString);

    (** add a character to the output document *)
    procedure AddChar(const ch: AnsiChar);

{$IFDEF SX_DEBUG}
    (** add a debug AnsiString to the output document *)
    procedure Debug(const s: AnsiString); overload;
    (** add a colored debug AnsiString to the output document *)
    procedure Debug(const color, s: AnsiString); overload;
{$ENDIF}

    (** save all current text properties in the current ScroogeXHTMLDocText object *)
    procedure StoreTextProperties;
    (** save all current paragraph properties in the current ScroogeXHTMLDocParagraph object *)
    procedure StoreParagraphProperties;
    (** set all character attributes to default values *)
    procedure ResetCharacterAttributes;
    (** set all character properties *)
    procedure SetCharacterProperties(const Value: TCharacterProperties);
    (** set all paragraph properties to default values *)
    procedure ResetParagraphAttributes;
    (** get a clone of all paragraph properties *)
    function CloneCharacterProperties: TCharacterProperties;
    (** Get a clone of all paragraph properties *)
    function CloneParagraphProperties: TParagraphProperties;
    (** set all paragraph properties *)
    procedure SetParagraphProperties(const Value: TParagraphProperties);

    // General properties
    (** default font name property *)
    property DefaultFontName: AnsiString read GetDefaultFontName write
      SetDefaultFontName;
    // character properties
    property Direction: TDirection write SetDirection;
    (** font background color property *)
    property FontBGColor: AnsiString write SetFontBGColor;
    (** font highlight color property *)
    property FontHLColor: AnsiString write SetFontHLColor;
    (** font color property *)
    property FontColor: AnsiString write SetFontColor;
    (** font name property *)
    property FontName: AnsiString write SetFontName;
    (** font character set property *)
    property FontCharSet: TCharset write SetFontCharSet;
    (** font style property *)
    property FontStyle: TFontstyles read GetFontStyle write SetFontStyle;
    (** font size property *)
    property FontSize: Integer write SetFontSize;
    (** font hidden property *)
    property IsHidden: Boolean read GetHidden write SetHidden;
    (** subscript property *)
    property Subscript: boolean read GetSubscript write SetSubscript;
    (** superscript property *)
    property Superscript: boolean read GetSuperscript write SetSuperscript;

    // paragraph properties
    (** Paragraph numbering level property *)
    property NumberingLevel: TNumberingLevel read GetNumberingLevel write SetNumberingLevel;
    (** Paragraph numbering style property *)
    property NumberingStyle: Boolean read GetNumberingStyle write
      SetNumberingStyle;
    (** Paragraph alignment property *)
    property Alignment: TParagraphAlignment write SetAlignment;
    (** Paragraph text direction property *)
    property ParDirection: TDirection write SetParDirection;
    (** Langauge property *)
    property Language: AnsiString write SetLanguage;
    (** left indent property *)
    property LeftIndent: Integer write SetLeftIndent;
    (** right indent property *)
    property RightIndent: Integer write SetRightIndent;
    (** first indent property *)
    property FirstIndent: Integer write SetFirstIndent;
    (** the character set used in the document *)
    property DocCharset: TCharset read GetDocCharset write SetDocCharset;
    (** the output document structure *)
    property DomDocument: ISimpleDomDocument read GetDomDocument write
      SetDomDocument;
  end;

implementation

uses
  SxDocumentParagraph,
  SxDocument,
  SxDocumentText,
  SxUnicode,
  Sysutils; // IntToStr

{------------------------------------------------------------------------------
    Procedure: TSxWriter.Create
  Description:
       Author: Michael Justin
 Date created: 2001-06-14
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

constructor TSxWriter.Create(const Owner: ISxWriterOptions);
begin
  inherited Create;
  WriterOptions := Owner;
  DomDocument := TSimpleDomDocument.Create(nil);
  DocCharset := SxUnicode.ANSI_CHARSET;
  CharProps := TCharacterProperties.Create;
  ParProps := TParagraphProperties.Create;
  IsNumbered := False;
  UnicodeConverter := TUnicodeConverter.Create;
  UnicodeConverter.CharSet := DocCharset;
  // Owner.Log(logDebug, 'ScroogeXHTMLWriter created');
end;

{------------------------------------------------------------------------------
    Procedure: TSxWriter.Destroy
  Description:
       Author: Michael Justin
 Date created: 2001-06-14
Date modified: 2002-12-09
      Purpose: free all objects
 Known Issues:
 ------------------------------------------------------------------------------}

destructor TSxWriter.Destroy;
begin
  ParProps.Free;
  CharProps.Free;
  inherited;
end;

{------------------------------------------------------------------------------
    Procedure: TSxWriter.ResetParagraphAttributes
  Description: actions of the \pard token
       Author: Michael Justin
 Date created: 2001-06-14
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxWriter.ResetParagraphAttributes;
begin
  Alignment := paLeftJustify;
  NumberingStyle := False;
  NumberingLevel := NL_NONE;
  LeftIndent := 0;
  RightIndent := 0;
  FirstIndent := 0;
  IsNumbered := False;
end;

{------------------------------------------------------------------------------
    Procedure: TSxWriter.Debug
  Description:
       Author: Michael Justin
 Date created: 2001-06-14
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

{$IFDEF SX_DEBUG}
procedure TSxWriter.Debug(const S: AnsiString);
begin
  Debug(dcBlack, S);
end;

procedure TSxWriter.Debug(const Color, S: AnsiString);
begin
  if color = 'blue' then
    DomDocument.AddEncoded('<tt class="blue">' + s + '</tt>')
  else if color = 'gray' then
    DomDocument.AddEncoded('<tt class="gray">' + s + '</tt>')
  else if color = 'silver' then
    DomDocument.AddEncoded('<tt class="silver">' + s + '</tt>')
  else if color = 'red' then
    DomDocument.AddEncoded('<tt class="red">' + s + '</tt>')
  else if color = 'green' then
    DomDocument.AddEncoded('<tt class="green">' + s + '</tt>')
  else if color = 'yellow' then
    DomDocument.AddEncoded('<tt class="yellow">' + s + '</tt>')
  else
    DomDocument.AddEncoded('<tt class="black">' + s + '</tt>')
end;
{$ENDIF}

{------------------------------------------------------------------------------
    Procedure: TSxWriter.AddChar
  Description:
       Author: Michael Justin
 Date created: 2001-06-14
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxWriter.AddChar(const Ch: AnsiChar);
begin
  if IsHidden then
    Exit;
    
  case ch of
    #10:
      begin
        DomDocument.AddPar;
        { the current paragraph inherits all paragraph properties
        defined in the previous paragraph }
        StoreParagraphProperties;
        StoreTextProperties;
      end;
    #9:
      begin
        StoreTextProperties;
        TCharacterProperties(TTextNode(TParagraphNode(DomDocument.LastChild).LastChild).Data).FontName := '';
        DomDocument.AddEncoded(string(WriterOptions.TabString));
        StoreTextProperties;
      end;
    #$0C: ; // 'form feed' character is illegal in XHTML
    #0: ;
  else
    DomDocument.Add(UnicodeConverter.CharToUnicode(ch));
  end // case ch of
end;


{------------------------------------------------------------------------------
    Procedure: TSxWriter.Plain
  Description: reset character attributes
       Author: Michael Justin
 Date created: 2001-06-14
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxWriter.ResetCharacterAttributes;
begin
  FontBGColor := '';
  FontHLColor := '';
  FontCharset := DocCharset;
  FontColor := WriterOptions.OptionsOptimize.DefaultFontColor;
  FontName := WriterOptions.OptionsOptimize.DefaultFontName;
  FontSize := WriterOptions.OptionsOptimize.DefaultFontSize;
  FontStyle := [];
  Subscript := False;
  Superscript := False;
  IsHidden := False;
end;

{------------------------------------------------------------------------------
    Procedure: TSxWriter.SetCharacterProperties
  Description:
       Author: Michael Justin
 Date created: 2001-06-14
Date modified: 2001-07-02
      Purpose: added Sub/Superscript
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetCharacterProperties(const Value:
  TCharacterProperties);
begin
  Self.Direction := Value.Direction;
  Self.FontBGColor := Value.FontBGColor;
  Self.FontHLColor := Value.FontHLColor;
  Self.FontColor := Value.FontColor;
  Self.FontSize := Value.FontSize;
  Self.FontStyle := Value.FontStyle;
  Self.FontName := Value.FontName;
  Self.FontCharSet := Value.FontCharSet;
  Self.Language := Value.Language;

  case Value.VerticalAlignment of
    vaSub: Self.Subscript := true;
    vaSuper: Self.Superscript := true;
  else
    begin
      Self.Subscript := False;
      Self.Superscript := False;
    end;
  end;

end;

function TSxWriter.CloneCharacterProperties: TCharacterProperties;
begin
  Result := CharProps.Clone;
end;

function TSxWriter.CloneParagraphProperties;
begin
  Result := ParProps.Clone;
end;

{------------------------------------------------------------------------------
    Procedure: SetParagraphProperties
  Description: called in TSxReader.popRTFState
       Author: Michael Justin
 Date created: 2001-07-15
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetParagraphProperties(const Value:
  TParagraphProperties);
begin
  // ParProps.CopyFrom(Value);
  ParProps.Alignment := Value.Alignment;
  ParProps.Direction := Value.Direction;
  ParProps.Numbered := Value.Numbered;
  {#todo1 analyze }
  // ParProps.NumberingLevel := Value.NumberingLevel; // !!!
  ParProps.LeftIndent := Value.LeftIndent;
  ParProps.RightIndent := Value.RightIndent;
  ParProps.FirstIndent := Value.FirstIndent;
end;

procedure TSxWriter.StoreTextProperties;
begin
  TParagraphNode(DomDocument.LastChild).AddText;
  TTextNode(TParagraphNode(DomDocument.LastChild).LastChild).SetTextProperties(CharProps);
end;

procedure TSxWriter.StoreParagraphProperties;
begin
  TParagraphNode(DomDocument.LastChild).SetParProperties(ParProps);
end;

procedure TSxWriter.SetDefaultFontName(const Value: AnsiString);
begin
  FDefaultFontName := Value;
end;

{------------------------------------------------------------------------------
     Property: Direction
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetDirection(const Value: TDirection);
begin
  if (Value <> CharProps.Direction) then
  begin
    CharProps.Direction := Value;
    StoreTextProperties;
  end;
end;

{------------------------------------------------------------------------------
     Property: FontSize
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetFontSize(const Value: Integer);
begin
  if (opFontSize in WriterOptions.FontConversionOptions)
    and (Value <> CharProps.FontSize) then
  begin
    CharProps.FontSize := Value;
    StoreTextProperties;
  end;
end;

{------------------------------------------------------------------------------
     Property: FontName
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetFontName(const Value: AnsiString);
begin
  if (opFontName in WriterOptions.FontConversionOptions)
    and (Value <> CharProps.FontName) then
  begin
    CharProps.FontName := Value;
    StoreTextProperties;
{$IFDEF SX_DEBUG}
    if WriterOptions.IsDebugging then
      Debug('grey', Value);
{$ENDIF}
  end;
end;

{------------------------------------------------------------------------------
     Property: FontCharSet
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetFontCharSet(const Value: TCharSet);
begin
  if Value <> CharProps.FontCharSet then
  begin
    CharProps.FontCharSet := Value;
    UnicodeConverter.CharSet := Value;
{$IFDEF SX_DEBUG}
    if WriterOptions.IsDebugging then
      Debug('grey', IntToStr(Value));
{$ENDIF}
  end;
end;

{------------------------------------------------------------------------------
     Property: FontColor
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetFontColor(const Value: AnsiString);
begin
  if (opFontColor in WriterOptions.FontConversionOptions)
    and (Value <> CharProps.FontColor) then
  begin
    CharProps.FontColor := Value;
    StoreTextProperties;
  end
end;

{------------------------------------------------------------------------------
     Property: FontBGColor
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetFontBGColor(const Value: AnsiString);
begin
  if (opFontBGColor in WriterOptions.FontConversionOptions)
    and (Value <> CharProps.FontBGColor) then
  begin
    CharProps.FontBGColor := Value;
    StoreTextProperties;
  end
end;

{------------------------------------------------------------------------------
     Property: FontHLColor
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetFontHLColor(const Value: AnsiString);
begin
  if (opFontHLColor in WriterOptions.FontConversionOptions)
    and (Value <> CharProps.FontHLColor) then
  begin
    CharProps.FontHLColor := Value;
    StoreTextProperties;
  end
end;

{------------------------------------------------------------------------------
     Property: FontStyle
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetFontStyle;
begin
  if (opFontStyle in WriterOptions.FontConversionOptions) and
    (Value <> CharProps.FontStyle) then
  begin
    CharProps.FontStyle := Value;
    StoreTextProperties;
  end;
end;

function TSxWriter.GetFontStyle;
begin
  Result := CharProps.FontStyle;
end;

{------------------------------------------------------------------------------
     Property: Subscript
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetSubscript(const Value: boolean);
begin
  if Value <> Subscript then
  begin
    if Value then
      CharProps.VerticalAlignment := vaSub
    else
      CharProps.VerticalAlignment := vaBaseline;
    StoreTextProperties;
  end
end;

function TSxWriter.GetSubscript;
begin
  Result := CharProps.VerticalAlignment = vaSub;
end;

{------------------------------------------------------------------------------
     Property: Superscript
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetSuperscript(const Value: boolean);
begin
  if Value <> Superscript then
  begin
    if Value then
      CharProps.VerticalAlignment := vaSuper
    else
      CharProps.VerticalAlignment := vaBaseline;
    StoreTextProperties;
  end
end;

function TSxWriter.GetSuperscript;
begin
  Result := CharProps.VerticalAlignment = vaSuper;
end;

{------------------------------------------------------------------------------
     Property: Alignment
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetAlignment;
begin
  with ParProps do
  begin
    if Value <> Alignment then
    begin
      Alignment := Value;
      StoreParagraphProperties;
    end;
  end
end;

{------------------------------------------------------------------------------
     Property: ParDirection
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetParDirection(const Value: TDirection);
begin
  if ParProps.Direction <> Value then
  begin
    ParProps.Direction := Value;
    StoreParagraphProperties;
  end;
end;

{------------------------------------------------------------------------------
     Property: NumberingLevel
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetNumberingLevel;
begin
  if ParProps.NumberingLevel <> Value then
  begin
    ParProps.NumberingLevel := Value;
    StoreParagraphProperties;
  end;
end;

{------------------------------------------------------------------------------
     Property: NumberingStyle
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetNumberingStyle;
begin
  with ParProps do
  begin
    if Numbered <> Value then
    begin
      Numbered := Value;
      StoreParagraphProperties;
    end;
  end;
end;

{------------------------------------------------------------------------------
     Property: LeftIndent
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetLeftIndent;
begin
  with ParProps do
  begin
    if LeftIndent <> Value then
    begin
      LeftIndent := Value;
      StoreParagraphProperties;
    end;
  end;
end;

{------------------------------------------------------------------------------
     Property: RightIndent
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetRightIndent;
begin
  with ParProps do
  begin
    if RightIndent <> Value then
    begin
      RightIndent := Value;
      StoreParagraphProperties;
    end;
  end;
end;

{------------------------------------------------------------------------------
     Property: FirstIndent
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetFirstIndent;
begin
  with ParProps do
  begin
    if FirstIndent <> Value then
    begin
      FirstIndent := Value;
      StoreParagraphProperties;
    end;
  end;
end;

{------------------------------------------------------------------------------
     Property: DocCharset
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetDocCharset(const Value: TCharset);
begin
  FDocCharset := Value;
end;

function TSxWriter.GetDocCharset: TCharset;
begin
  Result := FDocCharset;
end;

{------------------------------------------------------------------------------
     Property: DomDocument
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetDomDocument(const Value: ISimpleDomDocument);
begin
  FDomDocument := Value;
end;

function TSxWriter.GetDomDocument: ISimpleDomDocument;
begin
  Result := FDomDocument;
end;

{------------------------------------------------------------------------------
     Property: IsNumbered (GLOBAL)
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetIsNumbered(const Value: Boolean);
begin
  FIsNumbered := Value;
end;

function TSxWriter.GetIsNumbered: Boolean;
begin
  Result := FIsNumbered;
end;

{------------------------------------------------------------------------------
     Property: DefaultFontName
 ------------------------------------------------------------------------------}

function TSxWriter.GetDefaultFontName: AnsiString;
begin
  Result := FDefaultFontName;
end;

{------------------------------------------------------------------------------
     Property: Language
 ------------------------------------------------------------------------------}

procedure TSxWriter.SetLanguage(const Value: AnsiString);
begin
  if WriterOptions.ConvertLanguage and (Value <> CharProps.Language) then
  begin
    if Value = WriterOptions.DefaultLanguage then
      CharProps.Language := ''
    else
      CharProps.Language := Value;
    StoreTextProperties;
  end;
end;

function TSxWriter.GetNumberingStyle: Boolean;
begin
  Result := ParProps.Numbered;
end;

function TSxWriter.GetNumberingLevel: TNumberingLevel;
begin
  Result := ParProps.NumberingLevel;
end;

(*
procedure TSxWriter.AddElement(const ElementName: AnsiString;
  const TextContent: WideString);
var
  Element: TSimpleDomNode;
begin
  Element := TSimpleDomNode.Create(DomDocument.LastChild, etElement);
  Element.ElementName := ElementName;
  Element.TextContent := TextContent;
  DomDocument.LastChild.Append(Element);
  TParagraphNode(DomDocument.LastChild).AddText;
end;
*)
function TSxWriter.GetHidden: Boolean;
begin
  Result := FHidden
end;

procedure TSxWriter.SetHidden(const Value: Boolean);
begin
  FHidden := Value; 
end;

end.

