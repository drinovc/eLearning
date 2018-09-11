(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

unit SxMain;

interface

uses
  SxBase;

type
  (**
   * Main conversion class.
   *)
  TSxMain = class(TSxBase)
  private
    (** The main conversion function *)
    function DoConvert(RTF: AnsiString): AnsiString;

  public
    (** Convert RTF to HTML / XHTML. *)
    function Convert(const RTF: AnsiString): AnsiString;

    (** Build the tags before the HTML body code *)
    function GetLeadingHTMLTags: AnsiString;

    (** Build the tags after the HTML body code *)
    function GetTrailingHTMLTags: AnsiString;

  end;

implementation

uses
  SxWriter, SxReader, SxTypes, SxPlatform, SxInterfaces, SxOutputWriter,
  Classes, SysUtils;

{------------------------------------------------------------------------------
    Procedure: DoConvert
  Description:
       Author: Michael Justin
 Date created: 2001-06-16
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

function TSxMain.DoConvert(RTF: AnsiString): AnsiString;
var
  OW: TSxOutputWriter;
  ScroogeReader: ISxReader;
  ScroogeWriter: ISxWriter;
begin
  Log(logDebug, 'TCustomScrooge.DoConvert ' + IntToStr(Ord(LogLevel)));

  AbortConversion := False;

  // is it a valid RTF file?
  if Copy(RTF, 1, 5) <> '{\rtf' then
  begin
    result := '';
    Log(logError, 'No RTF header found');
    exit;
  end;

  // create a writer instance
  ScroogeWriter := TSxWriter.Create(Self);
  try
    // set the par open tag
    Translator.SetParOpen(GetParOpen + GetElementClassParam('p'),
      GetElementStyle('p'));

    // set the font size scale
    Translator.SetFontSizeScale(self.FontSizeScale);

    // create a reader instance
    ScroogeReader := TSxReader.Create(Self, ScroogeWriter);
    try
      Log(logDebug, 'Start conversion');

      ScroogeReader.ConvertRTFToHTML(RTF);

      Log(logDebug, 'End of conversion');

      OW := TSxOutputWriter.Create;
      try
        OW.Converter := Self;
        OW.DomDocument := ScroogeWriter.DomDocument;
        OW.ConvertEmpty := ConvertEmptyParagraphs and Translator.IsTransitional;
        OW.EmptyPar := GetEmptyParagraph;
        OW.LineTag := GetLineBreakTag;
        OW.ConvertToPlainText := ConvertToPlainText;
        try
          OW.Write;
        except
          on E: Exception do
            Log(logError, E.Message);
        end;

        {$IFDEF SCROOGE_UTF8}
        Result := UTF8Encode(OW.StringResult);
        {$ELSE}
        Result := OW.StringResult;
        {$ENDIF}


      finally
        OW.Free;
      end;

      if not ConvertToPlainText then
      begin
        (* if (hoHyperlinkFootnotes in HyperlinkOptions) then
          Result := Result + GetHyperlinkFootnotes; *)

        if AddOuterHTML then
        begin
          Log(logInfo, 'Start wrapping');
          Result := GetLeadingHTMLTags + Result + GetTrailingHTMLTags;
          Log(logInfo, 'End of wrapping');
        end;

      end;

    except
      on E: Exception do
        Log(logError, E.Message);
    end;

  except
    on E: Exception do
      Log(logError, E.Message);
  end;

end;

function TSxMain.Convert(const RTF: AnsiString): AnsiString;
begin
  // LinkCollection.Clear;

  if Assigned(OnBeforeConvert) then
    OnBeforeConvert(self);

  Result := DoConvert(RTF);

  if Assigned(OnAfterConvert) then
    OnAfterConvert(self);
end;

function TSxMain.GetLeadingHTMLTags: AnsiString;
var
  SL: TStrings;
  I: Integer;
  LangAttribute: AnsiString;

  procedure Add(const S: AnsiString);
  begin
    SL.Add(Formatter.Add(S));
  end;

  procedure Indent(const S: AnsiString);
  begin
    SL.Add(Formatter.Indent(S));
  end;

  procedure UnIndent(const S: AnsiString);
  begin
    SL.Add(Formatter.UnIndent(S));
  end;

  procedure AddMeta(const metaName, content: AnsiString);
  begin
    if content <> '' then
      Add('<meta name="' + metaName + '" content="' + content
        + '"' + GetCloseEmptyElement);
  end;

  procedure AddMetaHTTP(const httpEquivalent, content: AnsiString);
  begin
    if content <> '' then
      Add('<meta http-equiv="' + httpEquivalent +
        '" content="' + content + '"' + GetCloseEmptyElement);
  end;

  function GetDefaultFontStyleDefinition: AnsiString;
  begin
    result := 'BODY {';
    if DefaultFontName <> '' then
      result := result + 'font-family:' + DefaultFontName + ';';
    if DefaultFontSize > 0 then
      result := result + Translator.GetFontSizeStyle(DefaultFontSize);
    if DefaultFontColor <> '' then
      result := result + 'color:' + DefaultFontColor + ';';
    result := result + ' }';
  end;

begin
  SL := TStringList.Create;

  Formatter.IndentLevel := 0;
  Formatter.NewLine := '';

  try

    if IncludeXMLDeclaration and Translator.IsXml then
      Add(XML_DECLARATION);

    if IncludeDocType or Translator.IsDocTypeRequired then
      Add(Translator.GetDocType);

    Add(Translator.GetRootElement);
    Indent('<head>');
    Indent('<title>');
    Indent(DocumentTitle);
    UnIndent('</title>');

    AddMetaHTTP('content-type', MetaContentType);

    AddMeta('author', MetaAuthor);

    if moMetaDate in MetaOptions then
      AddMeta('date', GetUTCDateTime);

    AddMeta('description', MetaDescription);

    if moMetaGenerator in MetaOptions then
      AddMeta('generator', AnsiString(ClassName + ' ' + Self.Version));

    AddMeta('keywords', MetaKeywords);

    for i := 0 to MetaTags.count - 1 do
      AddMeta(AnsiString(MetaTags.names[i]), AnsiString(MetaTags.Values[MetaTags.names[i]]));

    for i := 0 to HeadTags.count - 1 do
      Add(AnsiString(HeadTags[i]));

    if StyleSheetLink <> '' then
      Add('<link rel="stylesheet" type="text/css" href="' +
        StyleSheetLink + '"' + GetCloseEmptyElement);

    if (StyleSheetInclude.Count > 0) or IncludeDefaultFontStyle then
    begin
      if Translator.SupportsElement('style') then
      begin
        Add('<style type="text/css">');
        Add('<!--');
        Formatter.IndentLevel := Formatter.IndentLevel + 1;
        if IncludeDefaultFontStyle then
          Add(GetDefaultFontStyleDefinition);
        for i := 0 to StyleSheetInclude.Count - 1 do
          Add(AnsiString(StyleSheetInclude[i]));
{$IFDEF SX_DEBUG}
        if isDebugging then
        begin
          Add('tt {font-family : monospace;font-size : 10pt;}');
          Add('tt.black {color : Black;}');
          Add('tt.blue {color : Blue;}');
          Add('tt.red {color : Red;}');
          Add('tt.green {color : Green;}');
          Add('tt.yellow {color : Yellow;}');
          Add('tt.gray {color : Gray;}');
        end;
{$ENDIF}
        Indent('-->');
        Formatter.IndentLevel := Formatter.IndentLevel - 1;
        UnIndent('</style>');
      end;
    end;

    // lang / xml:lang
    if ConvertLanguage then
      if DefaultLanguage <> '' then
        LangAttribute := Translator.BuildLangAttribute(DefaultLanguage);

    UnIndent('</head>');
    Add('<body' + LangAttribute + '>');

    Result := AnsiString(SL.Text);
  finally
    SL.Free;
  end;
end;

function TSxMain.GetTrailingHTMLTags;
begin
  result := '  </body>' + CrLf
    + '</html>'
end;

end.

