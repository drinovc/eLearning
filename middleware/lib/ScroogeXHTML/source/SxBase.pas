(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

unit SxBase;

interface

uses
  SxSimpleDomInterfaces,
  SxInterfaces,
  SxTypes,
  SxOptions,
  Sysutils, // IntToStr / StringReplace / Format
  Classes; // TComponent

const
  (** the component version *)
  VersionString = '5.1';

type
  {** event called for a detected hyperlink }
  THyperlinkEvent = procedure(Sender: TObject;
    var linkText: WideString) of object;

  {** event called before and after Unicode encoding *}
  TEncodingEvent = procedure(Sender: TObject; const
    TextElement: ISimpleDomTextNode) of object;

  {** event called to log internal informations }
  TLogEvent = procedure(Sender: TObject;
    const logLevel: TLogLevel;
    const logText: AnsiString) of object;

  {** event called to visualize conversion progress }
  TProgressEvent = procedure(Sender: TObject;
    const Position: Integer;
    var allowContinue: boolean) of object;

  (** event called to substitute font names *)
  TReplaceFontEvent = procedure(Sender: TObject;
    var FontName: AnsiString) of object;

  (**
   * The base class for ScroogeXHTML.
   *
   * \ingroup Core Components
   *)
  TSxBase = class(TComponent, ISxWriterOptions)
  private
    FAbortConversion: Boolean;
    FConvertEmptyParagraphs: Boolean;
    FConvertHyperlinks: Boolean;
    FConvertIndent: Boolean;
    FConvertLanguage: Boolean;
    FConvertPictures: Boolean;
    FConvertSpaces: Boolean;
    FConvertToPlainText: Boolean;
    FDebugMode: Boolean;
    FDefaultLanguage: AnsiString;
    FDocumentType: TDocumentType;
    FFontConversionOptions: TFontConversionOptions;
    FFormatter: ISxFormatter;
    FHyperlinkList: TStrings;
    FHyperlinkOptions: THyperlinkOptions;
    FIncludeDocType: Boolean;
    FIncludeXMLDeclaration: Boolean;
    FLogLevel: TLogLevel;
    FOnAfterConvert: TNotifyEvent;
    FOnAfterEncode: TEncodingEvent;
    FOnBeforeConvert: TNotifyEvent;
    FOnBeforeEncode: TEncodingEvent;
    FOnHyperlink: THyperlinkEvent;
    FOnLog: TLogEvent;
    FOnProgress: TProgressEvent;
    FOnReplaceFont: TReplaceFontEvent;
    FPictureAdapter: ISxPictureAdapter;
    FTranslator: ISxTranslator;
    FTabString: AnsiString;
    FElementClasses: TStrings;
    FElementStyles: TStrings;
    FFontSizeScale: TFontSizeScale;
    FOptionsHead: TSxOptionsHead;
    FOptionsOptimize: TSxOptionsOptimize;
    FReplaceFonts: TStrings;
    FRtfEnd: Boolean;
    FConvertUsingPrettyIndents: Boolean;

    function GetVersion: AnsiString;
    procedure SetVersion(const Value: AnsiString);
    procedure SetDocumentType(const Value: TDocumentType);
    procedure SetAbortConversion(const Value: Boolean);
    procedure SetHeadTags(Value: TStrings);
    procedure SetHyperlinkList(Value: TStrings);
    procedure SetMetaTags(Value: TStrings);
    procedure SetReplaceFonts(Value: TStrings);
    procedure SetStyleSheetInclude(Value: TStrings);
    procedure SetOptionsHead(const Value: TSxOptionsHead);
    procedure SetOptionsOptimize(const Value: TSxOptionsOptimize);
    function GetDefaultFontColor: AnsiString;
    procedure SetDefaultFontColor(const Value: AnsiString);
    function GetDefaultFontName: AnsiString;
    function GetDefaultFontSize: Integer;
    procedure SetDefaultFontName(const Value: AnsiString);
    procedure SetDefaultFontSize(const Value: Integer);
    function GetIncludeDefaultFontStyle: Boolean;
    procedure SetIncludeDefaultFontStyle(const Value: Boolean);
    function GetAddOuterHTML: Boolean;
    procedure SetAddOuterHTML(const Value: Boolean);
    function GetMetaTags: TStrings;
    function GetDocumentTitle: AnsiString;
    procedure SetDocumentTitle(const Value: AnsiString);
    function GetHeadTags: TStrings;
    function GetStyleSheetInclude: TStrings;
    function GetStyleSheetLink: AnsiString;
    procedure SetStyleSheetLink(const Value: AnsiString);
    function GetMetaAuthor: AnsiString;
    procedure SetMetaAuthor(const Value: AnsiString);
    function GetMetaContentType: AnsiString;
    procedure SetMetaContentType(const Value: AnsiString);
    function GetMetaDescription: AnsiString;
    procedure SetMetaDescription(const Value: AnsiString);
    function GetMetaKeywords: AnsiString;
    procedure SetMetaKeywords(const Value: AnsiString);
    function GetMetaOptions: TMetaOptions;
    procedure SetMetaOptions(const Value: TMetaOptions);
    function GetTabString: AnsiString;
    function GetOptionsOptimize: TSxOptionsOptimize;
    function GetFontConversionOptions: TFontConversionOptions;
    function GetConvertLanguage: Boolean;
    function GetDefaultLanguage: AnsiString;
    procedure SetDebugMode(const Value: Boolean);
    function GetPictureAdapter: ISxPictureAdapter;
    procedure SetConvertUsingPrettyIndents(const Value: Boolean);

  public
    (** create a new TSxBase instance *)
    constructor Create(AOwner: TComponent); override;

   (**
    * Destroy TSxBase instance.
    *)
    destructor Destroy; override;

    (**
     * Checks properties for invalid settings.
     * Will throw an Exception to indicate bad values.
     *)
    procedure VerifySettings;

    (** check if we are in debug mode *)
{$IFDEF SX_DEBUG}
    function IsDebugging: Boolean;
{$ENDIF}

    (** returns ' /&gt;' or '&gt;' depending on DOCTYPE  *)
    function GetCloseEmptyElement: AnsiString;

    (** returns an empty paragraph *)
    function GetEmptyParagraph: AnsiString;

    (** returns the opening tag for a paragraph without "&gt;" *)
    function GetParOpen: AnsiString;

    (** get the opening tag for an ordered list *)
    function GetOrderedListTag: AnsiString;

    (** get the opening tag for an unordered list *)
    function GetUnorderedListTag: AnsiString;

    (** get the opening tag for a list item *)
    function GetListItemTag: AnsiString;

    (** returns the class parameter for the given element *)
    function GetElementClassParam(const ElementName: AnsiString): AnsiString;

    (** returns the style="..." parameter for the given element *)
    function GetElementStyleParam(const ElementName: AnsiString): AnsiString;

    (** returns the CSS style for the given element *)
    function GetElementStyle(const ElementName: AnsiString): AnsiString;

    (** returns the line break element *)
    function GetLineBreakTag: AnsiString;

    (** call the log event handler and pass the log level and message *)
    procedure Log(const alogLevel: TLogLevel; const logText: WideString);

    (** replace a font name *)
    procedure ReplaceFont(var FontName: AnsiString);

    (** replace a hyperlink *)
    procedure ReplaceHyperlink(const TextElement: ISimpleDomTextNode);

    (** convert a text element to HTML / XHTML.
     * This function receives a block of text and its attributes, packaged in
     * a ISimpleDomTextNode object. It will then
     * \li call #OnBeforeEncode (with the text block as parameter)
     * \li if IncludeDefaultFontStyle: clear the default font properties
     * \li do special processing for the 'Symbol' font
     * \li use the TCustomTranslator#encode method to convert the text to UTF-8
     * \li if #ConvertHyperlinks: search and process a hyperlink
     * \li if #ConvertSpaces: replace '  ' with \&nbsp;
     * \li call #OnAfterEncode
     * \li call TCustomTranslator#formatElement
     *)
    function TextElementToXHTML(const TextElement: ISimpleDomTextNode):
      SxText;

    (**
     * \name TSxBase public properties
     * These properties are not visible in the Object Inspector, except OptionsHead and OptionsOptimize.
     *)
    //@{
        (** set this property to True to abort the conversion *)
    property AbortConversion: Boolean read FAbortConversion write
      SetAbortConversion default false;

    (**
     * Set this property to True to include the surrounding tags for the HTML
     * header and the body in the output document.
     *
     * Deprecated. Use TSxBase.OptionsHead.
     *)
     property AddOuterHTML: Boolean read GetAddOuterHTML write SetAddOuterHTML;

    (**
     * The document title which will be displayed in the window title of the browser.
     *
     * Deprecated. Use TSxBase.OptionsHead.
     *)
    property DocumentTitle: AnsiString read GetDocumentTitle write
      SetDocumentTitle;

    (**
     * List of additional tags for the head section.
     *
     * Deprecated. Use TSxBase.OptionsHead.
     *)
    property HeadTags: TStrings read GetHeadTags write SetHeadTags;

    (**
     * This property may be used to specify the document author.
     * It will add a META-element to the HEAD section.
     *
     * Deprecated. Use TSxBase.OptionsHead.
     *)
    property MetaAuthor: AnsiString read GetMetaAuthor write SetMetaAuthor;

    (**
     * This property may be used to specify a character encoding for the
     * document.
     * It will add a META-element to the HEAD section.
     * Default: "text/html;charset=UTF-8"
     *
     * Deprecated. Use TSxBase.OptionsHead.
     *)
    property MetaContentType: AnsiString read GetMetaContentType write
      SetMetaContentType;

    (**
     * This property may be used to specify a document description.
     * It will add a META-element to the HEAD section.
     *
     * Deprecated. Use TSxBase.OptionsHead.
     *)
    property MetaDescription: AnsiString read GetMetaDescription write
      SetMetaDescription;

     (**
     * This property may be used to specify keywords for the document.
     * It will add a META-element to the HEAD section.
     *
     * Deprecated. Use TSxBase.OptionsHead.
     *)
    property MetaKeywords: AnsiString read GetMetaKeywords write
      SetMetaKeywords;

    (**
     * A set of options which enable or disable additional meta tags.
     * \li moMetaDate include tag with UTC date and time.
     * \li moMetaGenerator include tag with generator name.
     *
     * Deprecated. Use TSxBase.OptionsHead.
     *)
    property MetaOptions: TMetaOptions read GetMetaOptions write SetMetaOptions;

    (**
     * List of additional meta tags which can be used for a document description.
     *
     * Deprecated. Use TSxBase.OptionsHead.
     *)
    property MetaTags: TStrings read GetMetaTags write SetMetaTags;

    (**
     * Style sheet definitions which will be added in the HEAD
     * section HTML document.
     * Default: empty.
     *
     * Deprecated. Use TSxBase.OptionsHead.
     *)
    property StyleSheetInclude: TStrings read GetStyleSheetInclude write
      SetStyleSheetInclude;

    (**
     * URL of a file which contains external CSS style sheet definitions.
     * Default: empty.
     * \n
     * Example:
     * If this property has the value "scrooge.css", the following line will be inserted in the HTML header section:
     * \code <link href="scrooge.css" rel="stylesheet" type="text/css"> \endcode
     *
     * Deprecated. Use TSxBase.OptionsHead.
     *)
    property StyleSheetLink: AnsiString read GetStyleSheetLink write
      SetStyleSheetLink;

    (**
     * Use this property to optimize the HTML code generation.
     * Deprecated. Use TSxBase.OptionsOptimize.
     *)
    property DefaultFontColor: AnsiString read GetDefaultFontColor write
      SetDefaultFontColor;

    (**
     * Use this property to optimize the HTML code generation.
     *
     * Deprecated. Use TSxBase.OptionsOptimize.
     *)
    property DefaultFontName: AnsiString read GetDefaultFontName write
      SetDefaultFontName;

    (**
     * Use this property to optimize the HTML code generation.
     *
     * Deprecated. Use TSxBase.OptionsOptimize.
     *)
    property DefaultFontSize: Integer read GetDefaultFontSize write
      SetDefaultFontSize;

    (**
     * Use this property to optimize the HTML code generation.
     *
     * Deprecated. Use TSxBase.OptionsOptimize.
     *)
     property IncludeDefaultFontStyle: Boolean read GetIncludeDefaultFontStyle
       write SetIncludeDefaultFontStyle;

    (*
     * \property Formatter
     * The formatter
     *)
    property Formatter: ISxFormatter read FFormatter;

{$IFDEF VER130}
    (**
     * Properties which control HEAD area.
     * \since 4.0
     *)
    property OptionsHead: TSxOptionsHead read FOptionsHead write SetOptionsHead;

    (**
     * Properties which control optimization.
     * \since 4.0
     *)
    property OptionsOptimize: TSxOptionsOptimize read GetOptionsOptimize write
      SetOptionsOptimize;

{$ENDIF}
    (**
     * The picture adapter.
     *)
    property PictureAdapter: ISxPictureAdapter read GetPictureAdapter write
      FPictureAdapter;

    (**
     * True -> end of document or conversion aborted
     *)
    property RtfEnd: Boolean read FRtfEnd write FRtfEnd;

    (**
     * The HTML / XHTML Translator.
     *
     * \note To change the Translator, please use the #DocumentType property. *)
    property Translator: ISxTranslator read FTranslator;
    //@)

  published
    (** \name TSxBase published properties
     * These properties are visible in the Object Inspector.
     *)
    //@{
    (**
     * Set this property to True to replace empty paragraphs
     * (where the opening &lt;p&gt; tag is followed by the closing &lt;/p&gt; tag)
     * by a line break tag (&lt;br /&gt;).
     * Default: <em>false</em>
     *)
    property ConvertEmptyParagraphs: Boolean read FConvertEmptyParagraphs write
      FConvertEmptyParagraphs;

    (**
     * Set this property to True to activate hyperlink support.
     * Default: <em>false</em>
     *
     * \note
     * Hyperlinks are detected only if they use formatted blue and underlined in the source document
     * \n
     * If the OnHyperlink event handler is assigned,
     * only the event handler will be executed,
     * and all options defined in the property HyperlinkOptions have no effect.
     *
     *)
    property ConvertHyperlinks: Boolean read FConvertHyperlinks write
      FConvertHyperlinks;

    (**
     * Set this property to True if You want to activate support for left and
     * right paragraph indent. Default: <em>false</em>
     * \note
     * the right indent in the output document is relative to the browser window,
     * if you change the browser window size, the text area will adjust its size
     *)
    property ConvertIndent: Boolean read FConvertIndent write FConvertIndent;

    (**
     * Activates support for language conversion.
     *)
    property ConvertLanguage: Boolean read GetConvertLanguage write
      FConvertLanguage;

    (**
     * Activates support for picture conversion.
     *)
    property ConvertPictures: Boolean read FConvertPictures write
      FConvertPictures;

    (**
     * If two or more spaces are found in sequence, they will be converted to &amp;nbsp;
     *)
    property ConvertSpaces: Boolean read FConvertSpaces write FConvertSpaces;

    (**
     * Convert to plain text.
     *)
    property ConvertToPlainText: Boolean read FConvertToPlainText write
      FConvertToPlainText;

    (**
     * ScroogeXHTML generates output documents with 'pretty printed' formatting
     * by default. Some web browsers however have problems with line breaks
     * between html tags, which cause rendering errors. To provide support for
     * more web browsers, the ConvertUsingPrettyIndents property should be set
     * to false.
     * Default: <em>True</em> for backward compatibility
     * \since 4.4
     *)
    property ConvertUsingPrettyIndents: Boolean read FConvertUsingPrettyIndents write SetConvertUsingPrettyIndents;

    (**
    * In debug mode, the HTML code includes all elements of the RTF document
    * (RTF tokens, control characters...).
    * \li Unknown RTF tokens are red
    * \li Known RTF tokens are green
    * \li Font names and other unprinted text is silver
    * \li Document groups are blue
    * \li Document text is black
    * \note
    * The Debug mode builds very large HTML files.
    *)
    property DebugMode: Boolean read FDebugMode write SetDebugMode;

    (**
     * Use this property to set the default language of the document.
     *)
    property DefaultLanguage: AnsiString read GetDefaultLanguage write
      FDefaultLanguage;

    (**
     * The document type. For the selected document type, the component will
     * instantiate an object which implements the ISxTranslator interface
     * and assign it to the public #Translator property.
     * \note
     * Depending on the document type, some HTML/XHTML elements or parameters
     * are not supported.
     *
     *)
    property DocumentType: TDocumentType read FDocumentType write
      SetDocumentType;

    (**
     * A list of name-value pairs which defines the class="..." parameter for
     * the elements 'p', 'br', 'ol', 'ul' and 'li'.
     *)
    property ElementClasses: TStrings read FElementClasses;

    (**
     * A list of name-value pairs which defines the style="..." parameter for
     * the elements 'p', 'br', 'ol', 'ul' and 'li'.
     *)
    property ElementStyles: TStrings read FElementStyles;

    (**
     * Set these options to control which character properties are converted.
     * \li opFontSize enables conversion of font sizes. Default: <em>enabled</em>.
     * \li opFontName enables conversion of font names. See also TCustomScrooge#ReplaceFonts . Default: <em>enabled</em>.
     * \li opFontStyle enables conversion of font styles (bold, italic, underlined, strikeout). Default: <em>enabled</em>.
     * \li opFontColor enables conversion of font colors. Default: <em>enabled</em>
     * \li opFontBGColor enables conversion of background font colors. Default: <em>enabled</em>.
     * \li opFontHLColor enables conversion of highlight font colors. Default: <em>disabled</em>.
     *)
    property FontConversionOptions: TFontConversionOptions read
      GetFontConversionOptions write FFontConversionOptions;

    (**
     * Use this option to set the font size scale. The following units are supported:
     * \li point (pt)
     * \li em
     * \li ex
     * \li percent
     * \note Point is an absolute size scale, all others are relative scales.
     *)
    property FontSizeScale: TFontSizeScale read FFontSizeScale write
      FFontSizeScale;

    (**
     * In this list of name value pairs, the visible link text for all known
     * target addresses is associated with an URL.
     * \note
     * \li HyperlinkList works only with link text if it is formatted blue and underlined.
     * \li #ConvertHyperlinks and #HyperlinkOptions hoUseHyperlinkList option
     * have to be enabled
     *)
    property HyperlinkList: TStrings read FHyperlinkList write SetHyperlinkList;

    (**
     *  This property controls additional options for the hyperlink conversion.
     * \li hoOpenInNewBrowser the target page will be opened in a new browser
     *     window.
     *     This option works only in HTML/XHTML Transitional mode,
     *     the Strict mode does not support the target-parameter.
     *     Default: false
     * \li hoReplaceEMailLinks e-mail links will be replaced
     *     by a 'mailto:' - link.  Default: false
     * \li hoUseHyperlinkList the HyperlinkList will used.
     *     Default: false
     * \li hoRequireHTTP the link will be replaced even if the link text does
     *     not start with 'http:'
     * \note if the #OnHyperlink event handler is assigned to a custom method,
     * all settings of the #HyperlinkOptions property will have no effect.
     * \note The ConvertHyperlink property has to be set to True.
     *)
    property HyperlinkOptions: THyperlinkOptions read FHyperlinkOptions write
      FHyperlinkOptions;

    (**
     * Include DOCTYPE at the beginning of the document.
     * Default: True.
     * \note
     * Some HTML browsers check this element, and use the information in it to
     * verify the document code.
     * \note
     * XHTML 1.1 will always be generated with DOCTYPE.
     *)
    property IncludeDocType: Boolean read FIncludeDocType write FIncludeDocType;

    (**
     * Includes the XML declaration line at the beginning of the document.
     * Default: True
     * \verbatim
     * <?xml version="1.0"?> \endverbatim
     * \note
     * the default encodig for documents which use this declaration is UTF-8
     *)
    property IncludeXMLDeclaration: Boolean read FIncludeXMLDeclaration write
      FIncludeXMLDeclaration;

    (**
     * This property can be used to control the detail level of the logging procedure.
     * Default: logInfo
     *)
    property LogLevel: TLogLevel read FLogLevel write FLogLevel;

    (**
     * \property ReplaceFonts
     * Font names which will be replaced.
     *)
    property ReplaceFonts: TStrings read FReplaceFonts write SetReplaceFonts;

    (**
     * the HTML representation of a TAB charcter
     *)
    property TabString: AnsiString read GetTabString write FTabString;

    (**
     * the ScroogeXHTML version
     *)
    property Version: AnsiString read GetVersion write SetVersion stored false;

{$IFNDEF VER130}
    property OptionsHead: TSxOptionsHead read FOptionsHead write SetOptionsHead;

    property OptionsOptimize: TSxOptionsOptimize read GetOptionsOptimize write
      SetOptionsOptimize;

{$ENDIF}
    //@)

    (** \name TSxBase events *)
    //@{
    (**
     *  This event handler will be called after the conversion.
     *)
    property OnAfterConvert: TNotifyEvent read FOnAfterConvert write
      FOnAfterConvert;

    (**
     * Event handler which will be called after the encoding
     *)
    property OnAfterEncode: TEncodingEvent read FOnAfterEncode write
      FOnAfterEncode;

    (**
     * Event handler which will be called before the conversion
     *)
    property OnBeforeConvert: TNotifyEvent read FOnBeforeConvert write
      FOnBeforeConvert;

    (**
     * Event handler which will be called before the encoding
     *)
    property OnBeforeEncode: TEncodingEvent read FOnBeforeEncode write
      FOnBeforeEncode;

    (**
     * This event handler will be called if a hyperlink is detected.
     * It can be used to modify the hyperlink text.
     * \note if the #OnHyperlink event handler is assigned to a custom method,
     * all settings of the #HyperlinkOptions property will have no effect.
     * \note The ConvertHyperlink property has to be set to True.
     *)
    property OnHyperlink: THyperlinkEvent read FOnHyperlink write FOnHyperlink;

    (**
     * Event handler for log messages
     * \sa #LogLevel
     *)
    property OnLog: TLogEvent read FOnLog write FOnLog;

    (**
     * This event is called periodically during the conversion.
     * It can be used to display the conversion progress.
     * \par
     * Example:
     * \code
      procedure TfrmMain.converterProgress(Sender: TObject;
        const Position: Integer; var continue: Boolean);
      begin
        Label1.Caption := IntToStr(Position)+'%';
        Application.ProcessMessages;
      end;
      \endcode
     *)
    property OnProgress: TProgressEvent read FOnProgress write FOnProgress;

    (**
     * This event handler can be used to define a font substition.
     *)
    property OnReplaceFont: TReplaceFontEvent read FOnReplaceFont write
      FOnReplaceFont;

    //@}

  end;

implementation

uses
  SxFormatter, SxUnicode, SxHtmlTranslator, SxXhtmlTranslator;

{------------------------------------------------------------------------------
    Procedure: TSxBase.Create
  Description: create an instance of Scrooge
       Author: Michael Justin
 Date created: 2001-06-14
Date modified: 2002-07-20
      Purpose: do not use 'if csDesigning in ComponentState'
 Known Issues:
 ------------------------------------------------------------------------------}

constructor TSxBase.Create(AOwner: TComponent);
begin
  inherited;

  FFontConversionOptions := [opFontStyle, opFontSize, opFontName, opFontColor,
    opFontBGColor];
  FFormatter := TSxFormatter.Create;
  FHyperlinkList := TStringlist.Create;
  FDocumentType := dtXHTML_10_Strict;
  FPictureAdapter := nil;
  FIncludeDocType := True;
  FIncludeXMLDeclaration := True;
  FLogLevel := logInfo;
  FTabString := DEFAULT_TAB_STRING;
  FTranslator := TXHTML10StrictTranslator.Create;
  FElementClasses := TStringlist.Create;
  FElementStyles := TStringlist.Create;

  FOptionsHead := TSxOptionsHead.Create(Self);
  FOptionsOptimize := TSxOptionsOptimize.Create(Self);

  FConvertUsingPrettyIndents := True;

  FReplaceFonts := TStringlist.Create;
  FReplaceFonts.Add('Arial=Arial,Helvetica,sans-serif');
  FReplaceFonts.Add('Courier=Courier,monospace');
  FReplaceFonts.Add('Symbol=Symbol');
  FReplaceFonts.Add('Times=Times,serif');
end;

destructor TSxBase.Destroy;
begin
  FHyperlinkList.Clear;
  FHyperlinkList.Free;

  FElementClasses.Clear;
  FElementClasses.Free;

  FElementStyles.Clear;
  FElementStyles.Free;

  FOptionsHead.Free;
  FOptionsOptimize.Free;

  FReplaceFonts.Clear;
  FReplaceFonts.Free;

  inherited;
end;

procedure TSxBase.SetAbortConversion(const Value: Boolean);
begin
  FAbortConversion := Value;
  if Value then
    RtfEnd := True;
end;

{$IFDEF SX_DEBUG}
function TSxBase.IsDebugging: Boolean;
begin
  Result := FDebugMode;
end;
{$ENDIF}

function TSxBase.GetVersion;
begin
  result := VersionString;
end;

procedure TSxBase.SetVersion(const Value: AnsiString);
begin
  // nothing to do
end;

procedure TSxBase.SetHyperlinkList(Value: TStrings);
begin
  FHyperlinkList.Assign(Value);
end;

procedure TSxBase.Log(const alogLevel: TLogLevel; const logText:
  WideString);
begin
  if Assigned(FOnLog) and (Ord(alogLevel) >= Ord(FLogLevel)) then
  begin
    FOnlog(self, alogLevel, AnsiString(logText));
  end;
end;

procedure TSxBase.ReplaceHyperlink(const TextElement:
  ISimpleDomTextNode);
var
  TargetParam: AnsiString;
  LinkText: WideString;

  function ReplaceLinkUsingList: Boolean;
  var
    LinkURL: AnsiString;
  begin
    Result := False;
    // is the option set to True?
    if not (hoUseHyperlinkList in FHyperlinkOptions) then
      exit;
    // look up the URL for this hyperlink
    LinkURL := AnsiString(FHyperlinkList.Values[LinkText]);
    // if we found one
    if LinkURL <> '' then
    begin
      // we can convert the text to a hyperlink here
      Result := True;
      // include hyperlink
      LinkText := '<a href="' + LinkURL + '"' + TargetParam + '>' + LinkText +
        '</a>';
    end
    else
    begin
      Log(logWarning, 'Unknown hyperlink text: "' + LinkText + '"');
    end
  end;

  procedure ReplaceBySimpleLink;
  begin
    if (hoReplaceEMailLinks in FHyperlinkOptions) and (Pos('@', linkText) > 1)
      then
      linkText := '<a href="mailto:' + linkText + '">' + linkText + '</a>'
    else if (Pos(WideString('http:'), linkText) = 1) or not (hoRequireHTTP in
      FHyperlinkOptions) then
      linkText := '<a href="' + linkText + '"' + TargetParam + '>' + linkText +
        '</a>';
  end;

begin

  LinkText := textElement.TextContent;

  if Assigned(FOnHyperlink) then
    // use the user-defined event handler
    FOnHyperlink(Self, LinkText)
  else
  begin
    // open a new browser window?
    if (hoOpenInNewBrowser in FHyperlinkOptions) and
      Translator.SupportsParameter('a', 'target') then
      targetParam := ' target="_blank"'
    else
      targetParam := '';

    // if the link text is not in the hyperlink list,
    if not ReplaceLinkUsingList then
      // create a simple link
      ReplaceBySimpleLink;

  end;

  {#todo1 use a DomTextElement with AnisTring content and AttributeList }
  textElement.TextContent := linkText;

end;

{#todo1 check verify simplify }

function TSxBase.TextElementToXHTML(const TextElement: ISimpleDomTextNode): SxText;
var
  Attributes: TCharacterProperties;
begin
  // before encoding event handler
  if Assigned(OnBeforeEncode) then
    OnBeforeEncode(Self, TextElement);

  Attributes := TCharacterProperties(TextElement.Data);
  // clear default font properties
  if IncludeDefaultFontStyle then
  begin
    if Attributes.FontName = DefaultFontName then
      Attributes.FontName := '';
    if Attributes.FontColor = DefaultFontColor then
      Attributes.FontColor := '';
    if Attributes.FontSize = DefaultFontSize then
      Attributes.FontSize := 0;
  end;

  // replace symbol
  if Attributes.FontName = 'Symbol' then
  begin
    Attributes.FontName := '';
    TextElement.TextContent := SymbolToUnicode(TextElement.TextContent)
  end;

  // Encode
  if not TextElement.Encoded then
  begin
    TextElement.TextContent := Translator.Encode(TextElement.TextContent);
    TextElement.Encoded := True;
  end;

  // call the hyperlink event handler
  if ConvertHyperlinks and (Attributes.IsUnderline) and (Attributes.FontColor =
    dcBlue) then
  begin
    // call the replace hyperlink event handler or use the default
    ReplaceHyperlink(TextElement);
    // reset the formatting to support CSS definitions
    Attributes.Underline := False;
    Attributes.FontColor := '';
  end;

  // replace '  ' with &nbsp;
  if ConvertSpaces then
  begin
    while Pos(WideString('  '), TextElement.TextContent) > 0 do
      TextElement.TextContent := StringReplace(TextElement.TextContent, '  ',
        '&nbsp;&nbsp;', []);
  end;

  // after encoding event handler
  if Assigned(OnAfterEncode) then
    OnAfterEncode(Self, TextElement);

  // convert text to XHTML
  Result := Translator.FormatElement(TextElement.TextContent, Attributes);

end;

procedure TSxBase.SetDocumentType(const Value: TDocumentType);
begin
  if (FDocumentType <> Value) then
  begin
    FDocumentType := Value;
    case FDocumentType of
      dtHTML_401_Transitional:
        FTranslator := THTML401TransitionalTranslator.Create;
      dtHTML_401_Strict:
        FTranslator := THTML401StrictTranslator.Create;
      dtHTML_50:
        FTranslator := THTML50Translator.Create;
      dtXHTML_10_Transitional:
        FTranslator := TXHTML10TransitionalTranslator.Create;
      dtXHTML_10_Strict:
        FTranslator := TXHTML10StrictTranslator.Create;
      dtXHTML_Basic_10:
        FTranslator := TXHTMLBasic10Translator.Create;
      dtXHTML_MP_10:
        FTranslator := TXHTMLMobileProfile10Translator.Create;
      dtXHTML_11:
        FTranslator := TXHTML11Translator.Create;
      dtXHTML_50:
        FTranslator := TXHTML50Translator.Create;
    end;
  end;
end;

function TSxBase.GetCloseEmptyElement: AnsiString;
begin
  result := Translator.GetCloseEmptyElement;
end;

function TSxBase.GetEmptyParagraph: AnsiString;
begin
  Result := '    ' + GetParOpen + GetElementClassParam('p')
    + GetElementStyleParam('p') + '>' + CrLf + '    </p>' + CrLf;
end;

function TSxBase.GetParOpen: AnsiString;
begin
  result := '<p';
end;

function TSxBase.GetOrderedListTag;
begin
  Result := '<ol' + GetElementClassParam('ol') + GetElementStyleParam('ol') + '>'
end;

function TSxBase.GetUnorderedListTag;
begin
  Result := '<ul' + GetElementClassParam('ul') + GetElementStyleParam('ul') + '>'
end;

function TSxBase.GetListItemTag: AnsiString;
begin
  Result := '<li' + GetElementClassParam('li') + GetElementStyleParam('li') +
    '>';
end;

function TSxBase.GetElementStyle(const ElementName: AnsiString):
  AnsiString;
begin
  Result := AnsiString(ElementStyles.Values[string(ElementName)]);
end;

function TSxBase.GetElementClassParam(const ElementName: AnsiString):
  AnsiString;
begin
  Result := AnsiString(ElementClasses.Values[string(ElementName)]);
  if Result <> '' then
    Result := ' class="' + Result + '"'
end;

function TSxBase.GetElementStyleParam(const ElementName: AnsiString):
  AnsiString;
begin
  Result := AnsiString(ElementStyles.Values[string(ElementName)]);
  if Result <> '' then
    Result := ' style="' + Result + '"'
end;

procedure TSxBase.ReplaceFont(var Fontname: AnsiString);
var
  I: Integer;
begin
  if Assigned(OnReplaceFont) then
    OnReplaceFont(Self, Fontname)
  else if FReplaceFonts.Count > 0 then
  begin
    for I := 0 to FReplaceFonts.Count - 1 do
    begin
      if Pos(FReplaceFonts.Names[I], string(Fontname)) = 1 then
      begin
        Fontname := AnsiString(FReplaceFonts.Values[FReplaceFonts.Names[i]]);
      end
    end
  end
end;

function TSxBase.GetLineBreakTag: AnsiString;
begin
  Result := '<br' + GetElementClassParam('br') + GetElementStyleParam('br')
    + Translator.GetCloseEmptyElement;
end;

procedure TSxBase.SetOptionsOptimize(const Value: TSxOptionsOptimize);
begin
  FOptionsOptimize := Value;
end;

function TSxBase.GetOptionsOptimize: TSxOptionsOptimize;
begin
  Result := FOptionsOptimize;
end;

function TSxBase.GetDefaultFontColor: AnsiString;
begin
  Result := OptionsOptimize.DefaultFontColor;
end;

procedure TSxBase.SetDefaultFontColor(const Value: AnsiString);
begin
  OptionsOptimize.DefaultFontColor := Value;
end;

function TSxBase.GetDefaultFontName: AnsiString;
begin
  Result := OptionsOptimize.DefaultFontName;
end;

function TSxBase.GetDefaultFontSize: Integer;
begin
  Result := OptionsOptimize.DefaultFontSize;
end;

procedure TSxBase.SetDefaultFontName(const Value: AnsiString);
begin
  OptionsOptimize.DefaultFontName := Value;
end;

procedure TSxBase.SetDefaultFontSize(const Value: Integer);
begin
  OptionsOptimize.DefaultFontSize := Value;
end;

function TSxBase.GetIncludeDefaultFontStyle: Boolean;
begin
  Result := OptionsOptimize.IncludeDefaultFontStyle;
end;

procedure TSxBase.SetIncludeDefaultFontStyle(
  const Value: Boolean);
begin
  OptionsOptimize.IncludeDefaultFontStyle := Value;
end;

procedure TSxBase.SetOptionsHead(
  const Value: TSxOptionsHead);
begin
  FOptionsHead := Value;
end;

function TSxBase.GetAddOuterHTML: Boolean;
begin
  Result := OptionsHead.AddOuterHTML;
end;

procedure TSxBase.SetAddOuterHTML(const Value: Boolean);
begin
  OptionsHead.AddOuterHTML := Value;
end;

procedure TSxBase.SetConvertUsingPrettyIndents(const Value: Boolean);
begin
  FConvertUsingPrettyIndents := Value;
end;

function TSxBase.GetMetaTags: TStrings;
begin
  Result := OptionsHead.MetaTags;
end;

procedure TSxBase.SetMetaTags(Value: TStrings);
begin
  OptionsHead.MetaTags.Assign(Value);
end;

function TSxBase.GetDocumentTitle: AnsiString;
begin
  Result := OptionsHead.DocumentTitle;
end;

procedure TSxBase.SetDocumentTitle(const Value: AnsiString);
begin
  OptionsHead.DocumentTitle := Value;
end;

function TSxBase.GetHeadTags: TStrings;
begin
  Result := OptionsHead.HeadTags;
end;

procedure TSxBase.SetHeadTags(Value: TStrings);
begin
  OptionsHead.HeadTags.Assign(Value);
end;

procedure TSxBase.SetStyleSheetInclude(Value: TStrings);
begin
  OptionsHead.StyleSheetInclude.Assign(Value);
end;

function TSxBase.GetStyleSheetInclude: TStrings;
begin
  Result := OptionsHead.StyleSheetInclude;
end;

function TSxBase.GetStyleSheetLink: AnsiString;
begin
  Result := OptionsHead.StyleSheetLink;
end;

procedure TSxBase.SetStyleSheetLink(const Value: AnsiString);
begin
  OptionsHead.StyleSheetLink := Value;
end;

function TSxBase.GetMetaAuthor: AnsiString;
begin
  Result := OptionsHead.MetaAuthor;
end;

procedure TSxBase.SetMetaAuthor(const Value: AnsiString);
begin
  OptionsHead.MetaAuthor := Value;
end;

function TSxBase.GetMetaContentType: AnsiString;
begin
  Result := OptionsHead.MetaContentType;
end;

procedure TSxBase.SetMetaContentType(const Value: AnsiString);
begin
  OptionsHead.MetaContentType := Value;
end;

function TSxBase.GetMetaDescription: AnsiString;
begin
  Result := OptionsHead.MetaDescription;
end;

procedure TSxBase.SetMetaDescription(const Value: AnsiString);
begin
  OptionsHead.MetaDescription := Value;
end;

function TSxBase.GetMetaKeywords: AnsiString;
begin
  Result := OptionsHead.MetaKeywords;
end;

procedure TSxBase.SetMetaKeywords(const Value: AnsiString);
begin
  OptionsHead.MetaKeywords := Value;
end;

function TSxBase.GetMetaOptions: TMetaOptions;
begin
  Result := OptionsHead.MetaOptions;
end;

procedure TSxBase.SetMetaOptions(const Value: TMetaOptions);
begin
  OptionsHead.MetaOptions := Value;
end;

procedure TSxBase.SetReplaceFonts(Value: TStrings);
begin
  FReplaceFonts.Assign(Value);
end;

function TSxBase.GetTabString: AnsiString;
begin
  Result := FTabString;
end;

procedure TSxBase.VerifySettings;
begin
  // hoOpenInNewBrowser allowed?
  if (hoOpenInNewBrowser in FHyperlinkOptions) and
    not Translator.SupportsParameter('a', 'target') then
    raise
      Exception.Create('VerifySettings: hoOpenInNewBrowser is not supported for this document type');

  // Styleheets allowed?
  if ((StyleSheetInclude.Count > 0) or IncludeDefaultFontStyle)
    and not Translator.SupportsElement('style') then
    raise
      Exception.Create('VerifySettings: style sheets are not supported for this document type');
end;

function TSxBase.GetFontConversionOptions: TFontConversionOptions;
begin
  Result := FFontConversionOptions;
end;

function TSxBase.GetConvertLanguage: Boolean;
begin
  Result := FConvertLanguage;
end;

function TSxBase.GetDefaultLanguage: AnsiString;
begin
  Result := FDefaultLanguage;
end;

function TSxBase.GetPictureAdapter: ISxPictureAdapter;
begin
  if ConvertPictures and not Assigned(FPictureAdapter) then
    raise Exception.Create('Property TSxBase.PictureAdapter is not assigned');
  Result := FPictureAdapter;
end;

procedure TSxBase.SetDebugMode(const Value: Boolean);
begin
{$IFNDEF SX_DEBUG}
  if Value then
    raise Exception.Create('Please compile with symbol SX_DEBUG first');
{$ENDIF}
  FDebugMode := Value;
end;

end.

