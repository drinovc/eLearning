(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

unit SxInterfaces;

interface

uses
  SxOptions, SxSimpleDomInterfaces, SxTypes,
  SysUtils, Classes;

type
  (**
   * \interface ISxReader
   * RTF reader methods
   *)
  ISxReader = interface
    (**
     * Convert the given RTF input.
     *)
    procedure ConvertRTFToHTML(const RTFsource: AnsiString);
  end;

  (**
   * \interface ISxOutputWriter
   * HTML OutputWriter methods
   *)
  ISxOutputWriter = interface
    (**
     * placeholder
     *)
    function GetDomDocument: ISimpleDomDocument;

    (**
     * placeholder
     *)
    procedure SetDomDocument(const Value: ISimpleDomDocument);

    (**
     * placeholder
     *)
    procedure SetConvertToPlainText(const Value: Boolean);

    (**
     * placeholder
     *)
    procedure Write;

    // properties
    property DomDocument: ISimpleDomDocument read GetDomDocument write
      SetDomDocument;

    property ConvertToPlainText: Boolean write SetConvertToPlainText;
  end;


  IWriterOptions = interface
{$IFDEF SX_DEBUG}
    function IsDebugging: Boolean;
{$ENDIF}
    // function TabString: WideString;
    // property TabString: AnsiString read FTabString write FTabString;
    // property DefaultFontColor: AnsiString read FDefaultFontColor write
    //  FDefaultFontColor;
    // property DefaultFontSize: Integer read FDefaultFontSize write
    //  FDefaultFontSize;
    // property DefaultFontName: AnsiString read FDefaultFontName write
    //  FDefaultFontName;
    // property FontConversionOptions: TFontConversionOptions read
    //  FFontConversionOptions write FFontConversionOptions;
  end;

  ISxWriterOptions = interface
    function GetConvertLanguage: Boolean;
    function GetDefaultLanguage: AnsiString;
    function GetFontConversionOptions: TFontConversionOptions;
    function GetOptionsOptimize: TSxOptionsOptimize;
    function GetTabString: AnsiString;
{$IFDEF SX_DEBUG}
    function IsDebugging: Boolean;
{$ENDIF}
    property ConvertLanguage: Boolean read GetConvertLanguage;
    property DefaultLanguage: AnsiString read GetDefaultLanguage;
    property FontConversionOptions: TFontConversionOptions read GetFontConversionOptions;
    property OptionsOptimize: TSxOptionsOptimize read GetOptionsOptimize;
    property TabString: AnsiString read GetTabString;
  end;


    (**
     * \interface ISxWriter
     * placeholder
     *)
  ISxWriter = interface

    (**
     * placeholder
     *)
    function CloneCharacterProperties: TCharacterProperties;

    (**
     * placeholder
     *)
    procedure SetCharacterProperties(const Value: TCharacterProperties);

    (**
     * placeholder
     *)
    function CloneParagraphProperties: TParagraphProperties;

    (**
     * placeholder
     *)
    procedure SetParagraphProperties(const Value: TParagraphProperties);


    (**
     * placeholder
     *)
    procedure ResetCharacterAttributes;

    (**
     * placeholder
     *)
    procedure StoreTextProperties;

{$IFDEF SX_DEBUG}

    (**
     * placeholder
     *)
    procedure Debug(const s: AnsiString); overload;

    (**
     * placeholder
     *)
    procedure Debug(const color, s: AnsiString); overload;
{$ENDIF}


    (**
     * placeholder
     *)
    procedure SetAlignment(const Value: TParagraphAlignment);


    (**
     * placeholder
     *)
    function GetDocCharset: TCharset;

    (**
     * placeholder
     *)
    procedure SetDocCharset(const Value: TCharset);


    (**
     * placeholder
     *)
    function GetIsNumbered: Boolean;

    (**
     * placeholder
     *)
    procedure SetIsNumbered(const Value: Boolean);


    (**
     * placeholder
     *)
    procedure SetNumberingLevel(const Value: TNumberingLevel);

    (**
     * placeholder
     *)
    function GetNumberingLevel: TNumberingLevel;


    (**
     * placeholder
     *)
    procedure SetNumberingStyle(const Value: Boolean);

    (**
     * placeholder
     *)
    function GetNumberingStyle: Boolean;


    (**
     * placeholder
     *)
    procedure SetDefaultFontName(const Value: AnsiString);

    (**
     * placeholder
     *)
    function GetDefaultFontName: AnsiString;


    (**
     * placeholder
     *)
    procedure SetFontColor(const Value: AnsiString);

    (**
     * placeholder
     *)
    procedure SetFontBGColor(const Value: AnsiString);

    (**
     * placeholder
     *)
    procedure SetFontHLColor(const Value: AnsiString);

    (**
     * placeholder
     *)
    procedure SetFontCharSet(const Value: TCharSet);

    (**
     * placeholder
     *)
    procedure SetFontStyle(const Value: TFontstyles);

    (**
     * placeholder
     *)
    function GetFontStyle: TFontstyles;

    (**
     * placeholder
     *)
    procedure SetFontSize(const Value: Integer);

    (**
     * placeholder
     *)
    function GetHidden: Boolean;

    (**
     * placeholder
     *)
    procedure SetHidden(const Value: Boolean);

    (**
     * placeholder
     *)
    procedure SetSuperscript(const Value: Boolean);

    (**
     * placeholder
     *)
    function GetSubscript: boolean;

    (**
     * placeholder
     *)
    procedure SetSubscript(const Value: boolean);

    (**
     * placeholder
     *)
    function GetSuperscript: boolean;

    (**
     * placeholder
     *)
    procedure SetLanguage(const Value: AnsiString);

    (**
     * placeholder
     *)
    procedure SetLeftIndent(const Value: Integer);

    (**
     * placeholder
     *)
    procedure SetRightIndent(const Value: Integer);

    (**
     * placeholder
     *)
    procedure SetFirstIndent(const Value: Integer);

    (**
     * placeholder
     *)
    function GetDomDocument: ISimpleDomDocument;

    (**
     * placeholder
     *)
    procedure SetFontName(const Value: AnsiString);

    (**
     * placeholder
     *)
    procedure SetDirection(const Value: TDirection);

    (**
     * placeholder
     *)
    procedure SetParDirection(const Value: TDirection);

    (**
     * placeholder
     *)
    procedure AddChar(const ch: AnsiChar);


    (**
     * placeholder
     *)
    procedure ResetParagraphAttributes;

    // Properties
    property Alignment: TParagraphAlignment write SetAlignment;
    property DefaultFontName: AnsiString read GetDefaultFontName write
      SetDefaultFontName;
    property Direction: TDirection write SetDirection;
    property DocCharset: TCharset read GetDocCharset write SetDocCharset;
    property DomDocument: ISimpleDomDocument read GetDomDocument;
    property FirstIndent: Integer write SetFirstIndent;
    property FontBGColor: AnsiString write SetFontBGColor;
    property FontCharSet: TCharset write SetFontCharSet;
    property FontColor: AnsiString write SetFontColor;
    property FontHLColor: AnsiString write SetFontHLColor;
    property FontName: AnsiString write SetFontName;
    property FontStyle: TFontstyles read GetFontStyle write SetFontStyle;
    property FontSize: Integer write SetFontSize;
    property IsHidden: Boolean read GetHidden write SetHidden;
    property IsNumbered: Boolean read GetIsNumbered write SetIsNumbered;
    property Language: AnsiString write SetLanguage;
    property LeftIndent: Integer write SetLeftIndent;
    property NumberingLevel: TNumberingLevel read GetNumberingLevel write
      SetNumberingLevel;
    property NumberingStyle: Boolean read GetNumberingStyle write
      SetNumberingStyle;
    property ParDirection: TDirection write SetParDirection;
    property RightIndent: Integer write SetRightIndent;
    property Subscript: boolean read GetSubscript write SetSubscript;
    property Superscript: boolean read GetSuperscript write SetSuperscript;

  end;

  (**
   * \interface IUnicodeConverter
   * Interface for Unicode converter.
   *)
  IUnicodeConverter = interface
    (**
     * Get the CharSet value.
     *)
    function GetCharSet: TCharSet;

    (**
     * Set the CharSet value.
     *)
    procedure SetCharSet(const Value: TCharSet);

    (**
     * Get the DBCS value.
     *)
    function IsDBCS: Boolean;

    (**
     * Set the DBCS value.
     *)
    procedure SetDBCS(const Value: Boolean);

    (**
     * Convert a character to a WideChar character.
     *)
    function CharToUnicode(const C: AnsiChar): WideString;

    // properties
    (**
     * The Charset property contains the current text node's character set.
     *)
    property CharSet: TCharSet read GetCharSet write SetCharSet;

    (**
     * The DBCS property indicates a double byte character set.
     *)
    property DBCS: Boolean read IsDBCS write SetDBCS;
  end;

  (**
   * \interface ISxTranslator
   * Interface for Translator
   *)
  ISxTranslator = interface
    (**
     * placeholder
     *)
    function BuildLangAttribute(const Language: AnsiString): AnsiString;

    (**
     * placeholder
     *)
    function Encode(const S: WideString): WideString;

    (**
     * placeholder
     *)

    function FormatElement(const Text: SxText; const CP: TCharacterProperties):
      SxText;

    (**
     * placeholder
     *)
    function GetCloseEmptyElement: AnsiString;

    (**
     * placeholder
     *)
    function GetDocType: AnsiString;

    (**
     * placeholder
     *)
    function GetFontSizeStyle(const PT: Integer): AnsiString;

    (**
     * placeholder
     *)
    function GetMargin: AnsiString;

    (**
     * placeholder
     *)
    function GetParagraph(const AdditionalStyle: AnsiString; const AdditionalParams:
      AnsiString = ''): AnsiString;

    (**
     * placeholder
     *)
    function GetParagraphStyle(const PP: TParagraphProperties): AnsiString;

    (**
     * placeholder
     *)
    function GetRootElement: AnsiString;

    (**
     * placeholder
     *)
    function GetStyleParam(const AdditionalStyle: AnsiString): AnsiString;

    (**
     * placeholder
     *)
    function IsTransitional: Boolean;

    (**
     * placeholder
     *)
    function IsXml: Boolean;

    (**
     * placeholder
     *)
    function IsDocTypeRequired: Boolean;

    (**
     * placeholder
     *)
    procedure SetFontSizeScale(const FSS: TFontSizeScale);

    (**
     * placeholder
     *)
    procedure SetParOpen(const TagAndClass: AnsiString; const DefaultStyle: AnsiString);

    (**
     * placeholder
     *)
    function SupportsElement(const ElementName: AnsiString): Boolean;

    (**
     * placeholder
     *)
    function SupportsParameter(const ElementName, ParamName: AnsiString): Boolean;
  end;

  (**
   * \interface ISxPictureAdapter
   * Defines methods for image extraction.
   *)
  ISxPictureAdapter = interface

    (**
     * placeholder
     *)
    function GetDocName: TFileName;

    (**
     * placeholder
     *)
    procedure SetDocName(const Value: TFileName);


    (**
     * placeholder
     *)
    function GetImagePath: AnsiString;

    (**
     * placeholder
     *)
    procedure SetImagePath(const Value: AnsiString);


    (**
     * placeholder
     *)
    function GetOutStream: TStream;

    (**
     * placeholder
     *)
    procedure SetOutStream(const Value: TStream);


    (**
     * placeholder
     *)
    // current picture
    function GetPicInfo: TPictureInformation;
    // 1 = first picture in this document, 2 = second ...

    (**
     * placeholder
     *)
    procedure IncPictNumber;

    (**
     * placeholder
     *)
    procedure Init;

    (**
     * placeholder
     *)
    procedure Write(const B: Byte);

    (**
     * placeholder
     *)
    procedure Finalize;

    (**
     * placeholder
     *)
    function PictureHTML: AnsiString;

    // properties
    property DocName: TFileName read GetDocName write SetDocName;
    property ImagePath: AnsiString read GetImagePath write SetImagePath;
    property OutStream: TStream read GetOutStream write SetOutStream;
    property PicInfo: TPictureInformation read GetPicInfo;

  end;

  {** event called for a detected hyperlink }
  TValidateErrorEvent = procedure(Sender: TObject;
    const ErrorMessage: WideString) of object;


    (**
     * \interface ISxFormatter
     * placeholder
     *)
  ISxFormatter = interface

    (**
     * placeholder
     *)
    procedure SetIndentLevel(const Value: Integer);

    (**
     * placeholder
     *)
    procedure SetSpaces(const Value: AnsiString);

    (**
     * placeholder
     *)
    procedure SetNewLine(const Value: AnsiString);

    (**
     * placeholder
     *)
    function GetIndentLevel: Integer;

    (**
     * placeholder
     *)
    function GetNewLine: AnsiString;

    (**
     * placeholder
     *)
    function GetSpaces: AnsiString;

    (**
     * placeholder
     *)
    function Add(const Text: AnsiString): AnsiString;

    (**
     * placeholder
     *)
    function Indent(const Text: AnsiString): AnsiString;

    (**
     * placeholder
     *)
    function UnIndent(const Text: AnsiString): AnsiString;

    (**
     * placeholder
     *)
    function GetIndent(const Level: Integer): AnsiString; overload;

    (**
     * placeholder
     *)
    function GetIndent: AnsiString; overload;

    // properties
    property IndentLevel: Integer read GetIndentLevel write SetIndentLevel;
    property NewLine: AnsiString read GetNewLine write SetNewLine;
    property Spaces: AnsiString read GetSpaces write SetSpaces;
  end;

implementation

end.

