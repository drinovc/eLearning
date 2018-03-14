(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

{** this unit defines basic types and simple helper classes }
unit SxTypes;

interface

uses
  SysUtils; // Exception

const
  dcBlack = '#000000';
  dcBlue = '#0000ff';

  CrLf = #13#10;

  XML_DECLARATION = '<?xml version="1.0"?>';

  ContentTypeUTF_8 = 'text/html; charset=UTF-8';

  DEFAULT_FONT_NAME = 'Times,serif';
  DEFAULT_FONT_SIZE = 12;
  DEFAULT_FONT_COLOR = '#000000';

  DEFAULT_TAB_STRING = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';

  // numbered list levels
  NL_NONE = 0;
  NL_BODY = 10;
  NL_BULLET = 11;

type
  {$IFDEF SCROOGE_UTF8}
    {.$IFDEF UNICODE}
  SxText = WideString;
    {.$ELSE}
  // SxText = string;
    {.$ENDIF}
  {$ELSE}
  SxText = AnsiString;
  {$ENDIF}

  TFontStyle = (fsBold, fsItalic, fsUnderline, fsStrikeOut);
  TFontStyles = set of TFontStyle;

  TCodepage = Integer;
  TCharset = Integer;

  (**
   * \enum TFontOption
   *)
  TFontOption = (opFontName, opFontSize, opFontStyle, opFontColor,
    opFontBGColor, opFontHLColor);

  (**
   * conversion options
   *)
  TFontConversionOptions = set of TFontOption;

  THyperlinkOption = ((* hoHyperlinkFootnotes, *)hoOpenInNewBrowser,
    hoReplaceEMailLinks, hoUseHyperlinkList, hoRequireHTTP);
  THyperlinkOptions = set of THyperlinkOption;

  TMetaOption = (moMetaDate, moMetaGenerator);
  TMetaOptions = set of TMetaOption;

  TFontSizeScale = (fsPoint, fsEM, fsEX, fsPercent);

  (**
   * TDocumentType
   *)
  TDocumentType = (dtHTML_401_Transitional, dtHTML_401_Strict, dtHTML_50,
    dtXHTML_10_Transitional, dtXHTML_10_Strict,
    dtXHTML_Basic_10, dtXHTML_MP_10, dtXHTML_11, dtXHTML_50);

  (**
   * TLogLevel
   *)
  TLogLevel = (logDebug, logInfo, logWarning, logError, logFatal);

  TParagraphAlignment = (paLeftJustify, paRightJustify, paCenter, paJustify);

  TNumberingLevel = NL_NONE..NL_BULLET;

  TVerticalAlignment = (vaBaseline, vaSub, vaSuper);

  TDirection = (diLTR, diRTL);

  (** CSS list-stlye-type *)
  TOrderedListStyleType = (lsNone, lsDecimal, lsLowerAlpha, lsUpperAlpha);

  (** CSS list-stlye-type *)
  TUnOrderedListStyleType = (ulNone, ulBullet, ulDisc);

  (**
   * TFontOption
   * A class which stores character properties
   *)
  TCharacterProperties = class(TObject)
  private
    FLanguage: AnsiString;
    procedure SetUnderline(const Value: Boolean);
    procedure SetLanguage(const Value: AnsiString);

  public
    (** Text direction (ltr/rtl) *)
    Direction: TDirection;
    (** Font name *)
    FontName: AnsiString;
    (** Font color in hex code *)
    FontColor: AnsiString;
    (** Background color in hex code *)
    FontBGColor: AnsiString;
    (** Hilight color in hex code *)
    FontHLColor: AnsiString;
    (** Font style *)
    FontStyle: TFontstyles;
    (** Font size in points *)
    FontSize: Integer;
    (** Font character set *)
    FontCharSet: TCharset;
    (** vertical alignment *)
    VerticalAlignment: SxTypes.TVerticalAlignment;

    (** Copy properties *)
    procedure CopyFrom(const CP: TCharacterProperties);

    (** Clone Self. *)
    function Clone: TCharacterProperties;

    (** Getter for Bold *)
    function IsBold: Boolean;
    (** Getter for Italic *)
    function IsItalic: Boolean;
    (** Getter for Underline *)
    function IsUnderline: Boolean;
    (** Getter for Strike *)
    function IsStrike: Boolean;

    // Properties
    (**
     * \property Language.
     *)
    property Language: AnsiString read FLanguage write SetLanguage;

    (**
     * \property Underline.
     *)
    property Underline: Boolean read IsUnderline write SetUnderline;

  end;

  (**
   * A class which stores paragraph properties.
   *)
  TParagraphProperties = class(TObject)
  public
    (** Paragraph alignment. *)
    Alignment: TParagraphAlignment;
    (** Paragraph direction (ltr/rtl). *)
    Direction: TDirection;
    (** Paragraph numbering. *)
    Numbered: Boolean;
    (** Paragraph numbering. *)
    NumberingLevel: TNumberingLevel;
    (** Paragraph indent from left border. *)
    LeftIndent: Integer;
    (** Paragraph indent from right border. *)
    RightIndent: Integer;
    (** Paragraph indent for first line. *)
    FirstIndent: Integer;

    (** Constructor *)
    constructor Create;

    (** Copy Self. *)
    function Clone: TParagraphProperties;

    (** Copy properties. *)
    procedure CopyFrom(const PP: TParagraphProperties);

  end;

  {** RTF internal states }
  TInternalState = (isNorm, isBin, isHex);

  {** used in the tokenTable to identify the token type }
  TRTFKeyType = (ktChar, ktDest, ktProp, ktFnct, ktFamily);

  {** used in the tokenTable to identify the associated property (KeyType = ktProp) }
  TRTFProperty = (propANSI, propMAC,
    propPlain, propLeftInd, propRightInd, propFirstInd,
    propBold, propItalic, propUnderline,
    propHidden,
    propJustL, propJustC, propJustR, propJustified,
    propPard, propRed, propGreen, propBlue,
    propFontSize, propFontNumber, propFontColor, propFontCharSet,
    propFontBGColor, propFontHLColor,
    propStrikeOut, propPnLvl, propPnLvlCont,
    propDeff,
    propSuper, propSub, propNoSuper,
    propLanguage,
    propLTR, propRTL, propLTRPar, propRTLPar,
    propUnicode, propUnicodeSkip,
    propEMF, propPNG, propJPEG, propPICT, propWMF,
    propPicW, propPicH, propWGoal, propHGoal);

  {** used in the tokenTable to specify the RTF destination (KeyType = ktDest) }
  TRTFDestination = (destUnknown,
    destFontTable,
    destFileTable,
    destColorTable,
    destStyleSheet,
    destRevisionTable,
    destListTable,
    destTemplate,
    destBodyText,
    destBookmark,
    destInformation,
    destUpr,
    destBullet,
    destPicture,
    destPnText
    );

  {** used in the tokenTable to specify the RTF special function }
  TRTFFunction = (fnctBin,
    fnctHex,
    fnctSkipDest,
    fnctPlain,
    fnctSkipWord,
    fnctLinebreak,
    fnctMiddot);

  {** used in the tokenTable to specify a RTF font family }
  TFontFamily = (ffNil, ffRoman, ffSwiss, ffModern, ffScript, ffDecor,
    ffTech, ffBidi);

  (**
   * A class which stores a font table font definition.
   *)
  TFontDescriptor = class(TObject)
  public
    (** Font name. *)
    FontName: AnsiString;
    (** Font family. *)
    FontFamily: TFontFamily;
    (** Font character set. *)
    FontCharSet: TCharset;

    (** Create an instance with a given font name *)
    constructor Create(const AFontName: AnsiString; const ACharset: TCharset);
  end;

  (**
   * A TTokenDef object stores the description of a RTF token.
   *)
  TTokenDef = record
    (** Token name. *)
    Token: AnsiString;
    (** Default value. *)
    DefVal: Integer;
    (** True: pass default. *)
    PassDef: Boolean;
    (** Key type. *)
    KeyType: TRTFKeyType;
    (** Index to property table if KeyType == ktProp. *)
    RTFProp: TRTFProperty;
    (** Character to print if KeyType == ktChar. *)
    UseChar: AnsiChar;
    (** Index to destination if keyType == ktDest. *)
    IdxDest: TRTFDestination;
    (** Index if KeyType == ktSpec. *)
    RTFFnct: TRTFFunction;
    (** Font family. *)
    FFamily: TFontFamily;
  end;

  (**
   * A class which stores the current reader state
   *)
  TReaderProperties = class(TObject)
  public
    (** Current character properties. *)
    CharProps: TCharacterProperties;
    (** Current paragraph properties. *)
    ParProps: TParagraphProperties;
    (** Current internal state. *)
    InternalState: TInternalState;
    (** Current output destination *)
    RTFDestination: TRTFDestination;

    (** create an instance with the given properties. *)
    constructor Create(
      const ACharProps: TCharacterProperties;
      const AParProps: TParagraphProperties;
      const AIntState: TInternalState;
      const ARTFDestination: TRTFDestination
      );

    (** Destructor. *)
    destructor Destroy; override;

  end;

const
  // Metafile Mapping Mode
  MM_TEXT = 1;
  MM_LOMETRIC = 2;
  MM_HIMETRIC = 3;
  MM_LOENGLISH = 4;
  MM_HIENGLISH = 5;
  MM_TWIPS = 6;
  MM_ISOTROPIC = 7;
  MM_ANISOTROPIC = 8;

type
  TMappingMode = MM_TEXT..MM_ANISOTROPIC;

  TPictureSource = (psUnknown, psEMF, psPNG, psJPEG, psPICT, psWMF);

  (**
   * Class which stores picture informations
   *)
  TPictureInformation = class(TObject)
  private
    FHGoal: Cardinal;
    FWGoal: Cardinal;

    function GetHGoalPx: cardinal;
    function GetWGoalPx: cardinal;

  public
    (** Picture file type. *)
    PictureSource: TPictureSource;

    (** Metafile mapping mode. *)
    MappingMode: TMappingMode;

    (**
     * xExt field if the picture is a Windows metafile,
     * height in pixels if the picture is a bitmap or from QuickDraw.
     *)
    Height: Cardinal;

    (**
     * xExt field if the picture is a Windows metafile,
     * width in pixels if the picture is a bitmap or from QuickDraw.
     *)
    Width: Cardinal;

    (**
     * \property HGoalTwips
     *
     * \brief Desired height of the picture in twips (1/1440 inch).
     *)
    property HGoalTwips: Cardinal read FHGoal write FHGoal;

    (**
     * \property WGoalTwips
     *
     * \brief Desired width of the picture in twips (1/1440 inch).
     *)
    property WGoalTwips: Cardinal read FWGoal write FWGoal;

    (**
     * \property HGoalPx
     *
     * \brief Height of the picture in pixel.
     *)
    property HGoalPx: Cardinal read GetHGoalPx;

    (**
     * \property WGoalPx
     *
     * \brief Width of the picture in pixel.
     *)
    property WGoalPx: Cardinal read GetWGoalPx;

  end;

const
  {** size of fontTable }
  maxToken = 118;

  {** the RTF token definition table }
  TokenTable: array[0..maxToken] of TTokenDef = (
    // Category A) - RTF tokens which appear very often
    (Token: 'par'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar: #10),
    (Token: 'pard'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propPard),
    (Token: 'b'; DefVal: 1; PassDef: False; KeyType: ktProp; RTFprop: propBold),
    (Token: 'i'; DefVal: 1; PassDef: False; KeyType: ktProp; RTFprop:
    propItalic),
    (Token: 'f'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propFontNumber),
    (Token: 'fs'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propFontSize),
    (Token: 'plain'; DefVal: 0; PassDef: False; KeyType: ktFnct; RTFFnct:
    fnctPlain),

    // Category B) - character properties
    (Token: 'ul'; DefVal: 1; PassDef: False; KeyType: ktProp; RTFprop:
    propUnderline),
    (Token: 'uldb'; DefVal: 1; PassDef: False; KeyType: ktProp; RTFprop:
    propUnderline),
    (Token: 'ulnone'; DefVal: 0; PassDef: true; KeyType: ktProp; RTFprop:
    propUnderline),
    (Token: 'cf'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propFontColor),
    (Token: 'cb'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propFontBGColor),
    (Token: 'chcbpat'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propFontBGColor),
    (Token: 'highlight'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propFontHLColor),
    (Token: 'strike'; DefVal: 1; PassDef: False; KeyType: ktProp; RTFprop:
    propStrikeOut),
    (Token: 'super'; DefVal: 1; PassDef: False; KeyType: ktProp; RTFprop:
    propSuper),
    (Token: 'sub'; DefVal: 1; PassDef: False; KeyType: ktProp; RTFprop:
    propSub),
    (Token: 'nosupersub'; DefVal: 0; PassDef: true; KeyType: ktProp; RTFprop:
    propNoSuper),
    (Token: 'up'; DefVal: 1; PassDef: False; KeyType: ktProp; RTFprop:
    propSuper),
    (Token: 'dn'; DefVal: 1; PassDef: False; KeyType: ktProp; RTFprop: propSub),
    (Token: 'u'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propUnicode),
    (Token: 'uc'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propUnicodeSkip),
    (Token: 'lang'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propLanguage),
    (Token: 'ltrch'; DefVal: 1; PassDef: true; KeyType: ktProp; RTFprop:
    propLTR),
    (Token: 'rtlch'; DefVal: 1; PassDef: true; KeyType: ktProp; RTFprop:
    propRTL),
    (Token: 'ltrpar'; DefVal: 1; PassDef: true; KeyType: ktProp; RTFprop:
    propLTRPar),
    (Token: 'rtlpar'; DefVal: 1; PassDef: true; KeyType: ktProp; RTFprop:
    propRTLPar),
    (Token: 'v'; DefVal: 1; PassDef: False; KeyType: ktProp; RTFprop:
    propHidden),

    // Category C) - characters
    (Token: '{'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar: '{'),
    (Token: '}'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar: '}'),
    (Token: '\'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar: '\'),
    (Token: 'tab'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar: #9),
    {#todo2 rtfFnct fnctNbsp }
    (Token: '~'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar: #160),
    (Token: #10; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar: #10),
    (Token: #13; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar: #10),
    (Token: 'line'; DefVal: 0; PassDef: False; KeyType: ktFnct; RTFFnct:
    fnctLinebreak),
    (Token: 'ldblquote'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar:
    '"'),
    (Token: 'rdblquote'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar:
    '"'),
    (Token: 'lquote'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar:
    ''''),
    (Token: 'rquote'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar:
    ''''),
    (Token: 'emdash'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar: '-'),
    (Token: 'endash'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar: '-'),
    (Token: 'emspace'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar:
    ' '),
    (Token: 'enspace'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar:
    ' '),
    {#todo3 zwj }
    {#todo3 zwnj }
    (Token: 'bullet'; DefVal: 0; PassDef: False; KeyType: ktFnct; RTFFnct:
    fnctMiddot),

    // Category D) - paragraph properties
    (Token: 'qc'; DefVal: Integer(paCenter); PassDef: true; KeyType: ktProp;
    RTFprop: propJustC),
    (Token: 'ql'; DefVal: Integer(paLeftJustify); PassDef: true; KeyType:
    ktProp; RTFprop: propJustL),
    (Token: 'qr'; DefVal: Integer(paRightJustify); PassDef: true; KeyType:
    ktProp; RTFprop: propJustR),
    (Token: 'qj'; DefVal: Integer(paJustify); PassDef: true; KeyType: ktProp;
    RTFprop: propJustified),
    (Token: 'li'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propLeftInd),
    (Token: 'ri'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propRightInd),
    (Token: 'fi'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propFirstInd),
    // Contains all automatically generated text and formatting. This is a destination control word.
    (Token: 'pntext'; DefVal: 1; PassDef: true; KeyType: ktDest; IdxDest:
    destUnknown),
    // text before number
    // (Token: 'pntxtb'   ; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest: destBullet),
    // Turns on paragraph numbering. This is a destination control word.
    (Token: 'pn'; DefVal: 1; PassDef: true; KeyType: ktDest; IdxDest:
    destBullet),
    // Paragraph level, where N is a level from 1 to 9. Default set by \pnseclvlN section formatting property
    (Token: 'pnlvl'; DefVal: NL_BODY; PassDef: False; KeyType: ktProp; RTFprop:
    propPnLvl),
    // Simple paragraph numbering (corresponds to level 10).
    (Token: 'pnlvlbody'; DefVal: NL_BODY; PassDef: true; KeyType: ktProp;
    RTFprop: propPnLvl),
    // Bullet level = pnlvl11
    (Token: 'pnlvlblt'; DefVal: NL_BULLET; PassDef: true; KeyType: ktProp;
    RTFprop: propPnLvl),
    // continue numbering but do not display number (“skip numbering”).
    (Token: 'pnlvlcont'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
      propPnLvlCont),

    // Category E) - header properties
    (Token: 'deff'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propDeff),
    (Token: 'ansi'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propANSI),
    (Token: 'mac'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propMAC),
    {#todo3 ansicpg }
    (Token: 'colortbl'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destColorTable),
    (Token: 'red'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propRed),
    (Token: 'green'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propGreen),
    (Token: 'blue'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propBlue),
    (Token: 'filetbl'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destFileTable),
    (Token: 'file'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    (Token: 'fonttbl'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destFontTable),
    (Token: 'fcharset'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propFontCharSet),
    (Token: 'fnil'; DefVal: 0; PassDef: False; KeyType: ktFamily; FFamily:
    ffNil),
    (Token: 'froman'; DefVal: 0; PassDef: False; KeyType: ktFamily; FFamily:
    ffRoman),
    (Token: 'fswiss'; DefVal: 0; PassDef: False; KeyType: ktFamily; FFamily:
    ffSwiss),
    (Token: 'fmodern'; DefVal: 0; PassDef: False; KeyType: ktFamily; FFamily:
    ffModern),
    (Token: 'fscript'; DefVal: 0; PassDef: False; KeyType: ktFamily; FFamily:
    ffScript),
    (Token: 'fdecor'; DefVal: 0; PassDef: False; KeyType: ktFamily; FFamily:
    ffDecor),
    (Token: 'ftech'; DefVal: 0; PassDef: False; KeyType: ktFamily; FFamily:
    ffTech),
    (Token: 'fbidi'; DefVal: 0; PassDef: False; KeyType: ktFamily; FFamily:
    ffBidi),
    (Token: 'info'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destInformation),
    (Token: 'listtable'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destListTable),
    (Token: 'listoverridetable'; DefVal: 0; PassDef: False; KeyType: ktDest;
    IdxDest: destListTable),
    (Token: 'revtbl'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destRevisionTable),
    (Token: 'stylesheet'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destStyleSheet),
    (Token: 'template'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destTemplate),

    // Category F) - section properties
    (Token: 'footer'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    (Token: 'footerf'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    (Token: 'footerl'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    (Token: 'footerr'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    (Token: 'header'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    (Token: 'headerf'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    (Token: 'headerl'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    (Token: 'headerr'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    (Token: 'footnote'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),

    // Category G) - other destinations
    (Token: 'author'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    (Token: 'annotation'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    (Token: 'bkmkstart'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destBookmark),
    (Token: 'bkmkend'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    (Token: 'field'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    (Token: 'docvar'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    // fldrslt (Field Result) may appear
    // a) in the document body
    // b) within other destinations
    // so it is not correct to switch to destBodyText always
    (Token: 'fldrslt'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUnknown),
    // Unicode
    (Token: 'upr'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destUpr),

    // Category H) - commands
    (Token: '*'; DefVal: 0; PassDef: False; KeyType: ktFnct; RTFFnct:
    fnctSkipDest),
    (Token: ''''; DefVal: 0; PassDef: False; KeyType: ktFnct; RTFFnct: fnctHex),
    (Token: 'bin'; DefVal: 0; PassDef: False; KeyType: ktFnct; RTFFnct:
    fnctBin),
    (Token: 'clfts'; DefVal: 0; PassDef: False; KeyType: ktFnct; RTFFnct:
    fnctSkipWord),
    (Token: 'clw'; DefVal: 0; PassDef: False; KeyType: ktFnct; RTFFnct:
    fnctSkipWord),
    (Token: 'trfts'; DefVal: 0; PassDef: False; KeyType: ktFnct; RTFFnct:
    fnctSkipWord),
    (Token: 'trw'; DefVal: 0; PassDef: False; KeyType: ktFnct; RTFFnct:
    fnctSkipWord),

    // Category I) - pictures
    (Token: 'pict'; DefVal: 0; PassDef: False; KeyType: ktDest; IdxDest:
    destPicture),
    (Token: 'picw'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propPicW),
    (Token: 'pich'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propPicH),
    // Desired width of the picture in twips. The N argument is a long Integer.
    (Token: 'picwgoal'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propWGoal),
    (Token: 'pichgoal'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propHGoal),
    // picture source
    (Token: 'emfblip'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propEMF),
    (Token: 'pngblip'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propPNG),
    (Token: 'jpegblip'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propJPEG),
    (Token: 'macpict'; DefVal: 0; PassDef: False; KeyType: ktProp; RTFprop:
    propPICT),
    (Token: 'wmetafile'; DefVal: 1; PassDef: False; KeyType: ktProp; RTFprop:
    propWMF),

    // Category J - tables
    (Token: 'row'; DefVal: 0; PassDef: False; KeyType: ktFnct; RTFFnct:
    fnctLinebreak),
    (Token: 'cell'; DefVal: 0; PassDef: False; KeyType: ktChar; UseChar: #9)

    );

implementation
uses Math; // Ceil

constructor TReaderProperties.Create(
  const ACharProps: TCharacterProperties;
  const AParProps: TParagraphProperties;
  const AIntState: TInternalState;
  const ARTFDestination: TRTFDestination
  );
begin
  inherited Create;
  CharProps := ACharProps;
  ParProps := AParProps;
  InternalState := AIntState;
  RTFDestination := ARTFDestination
end;

destructor TReaderProperties.Destroy;
begin
  CharProps.Free;
  ParProps.Free;
  inherited;
end;

constructor TFontDescriptor.Create(const AFontName: AnsiString; const ACharset:
  TCharset);
begin
  inherited Create;
  Self.FontName := AFontName;
  Self.FontCharSet := ACharSet;
end;

{ TCharacterProperties }

function TCharacterProperties.Clone: TCharacterProperties;
begin
  Result := TCharacterProperties.Create;
  Result.CopyFrom(Self);
end;

procedure TCharacterProperties.CopyFrom(const CP: TCharacterProperties);
begin
  Direction := CP.Direction;
  FontBGColor := CP.FontBGColor;
  FontHLColor := CP.FontHLColor;
  FontColor := CP.FontColor;
  FontSize := CP.FontSize;
  FontStyle := CP.FontStyle;
  FontName := CP.FontName;
  FontCharSet := CP.FontCharSet;
  Language := CP.Language;
  VerticalAlignment := CP.VerticalAlignment;
end;

function TCharacterProperties.IsBold: Boolean;
begin
  Result := fsBold in FontStyle;
end;

function TCharacterProperties.IsItalic: Boolean;
begin
  Result := fsItalic in FontStyle;
end;

function TCharacterProperties.IsStrike: Boolean;
begin
  Result := fsStrikeOut in FontStyle;
end;

function TCharacterProperties.IsUnderline: Boolean;
begin
  Result := fsUnderline in FontStyle;
end;

procedure TCharacterProperties.SetLanguage(const Value: AnsiString);
begin
  FLanguage := Value;
end;

procedure TCharacterProperties.SetUnderline(const Value: Boolean);
begin
  if Value then
    FontStyle := FontStyle + [fsUnderline]
  else
    FontStyle := FontStyle - [fsUnderline];
end;

{ TParagraphProperties }

constructor TParagraphProperties.Create;
begin
  inherited;
  Alignment := paLeftJustify;
end;

procedure TParagraphProperties.CopyFrom(const PP: TParagraphProperties);
begin
  Alignment := PP.Alignment;
  Direction := PP.Direction;
  Numbered := PP.Numbered;
  NumberingLevel := PP.NumberingLevel;
  LeftIndent := PP.LeftIndent;
  RightIndent := PP.RightIndent;
  FirstIndent := PP.FirstIndent;
end;

function TParagraphProperties.Clone: TParagraphProperties;
begin
  Result := TParagraphProperties.Create;
  Result.CopyFrom(Self);
end;

{twips calculation: 1440 / 96 = 15 !}

function TPictureInformation.GetHGoalPx: cardinal;
begin
  Result := Ceil(FHGoal / 15);
end;

function TPictureInformation.GetWGoalPx: cardinal;
begin
  Result := Ceil(FWGoal / 15);
end;

end.

