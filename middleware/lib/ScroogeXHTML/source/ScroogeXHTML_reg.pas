(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

(**
 * The Component registration unit
 *)
unit ScroogeXHTML_reg;

interface

(**
 * The Component registration method
 *)
procedure Register;

implementation

uses
  ScroogeXHTML,
  Classes;

procedure Register;
begin
  RegisterComponents('BetaTools', [TBTScroogeXHTML]);
end;

(** \mainpage ScroogeXHTML for Delphi&reg;
 *
 * \section intro Introduction
 *
 * ScroogeXHTML for Delphi&reg; is a component which can convert RTF stored in
 * files, strings or a RichEdit component to HTML 4.01, HTML5 and XHTML.
 * It is fast, easy to customize and use and comes with full source code.
 *
 * \li TSxBase - documentation of properties
 * \li TSxMain - documentation of core conversion method
 * \li TCustomScrooge - documentation of additional conversion methods
 *
 * Additional information:
 * \li \subpage version
 *
 * \section warranty Limited Warranty
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS. BETASOFT DISCLAIMS ALL
 * WARRANTIES RELATING TO THIS SOFTWARE, WHETHER EXPRESS OR IMPLIED, INCLUDING
 * BUT NOT LIMITED TO ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR
 * A PARTICULAR PURPOSE. NEITHER BETASOFT NOR ANYONE ELSE WHO HAS BEEN INVOLVED
 * IN THE CREATION, PRODUCTION, OR DELIVERY OF THIS SOFTWARE SHALL BE LIABLE
 * FOR ANY INDIRECT, CONSEQUENTIAL, OR INCIDENTAL DAMAGES ARISING OUT OF THE
 * USE OR INABILITY TO USE SUCH SOFTWARE, EVEN IF BETASOFT HAS BEEN ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGES OR CLAIMS. THE PERSON USING THE SOFTWARE
 * BEARS ALL RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE.
 *
 * \section trademarks TRADEMARKS
 * The names of actual companies and products mentioned herein may be the
 * trademarks of their respective owners.
 * Embarcadero, the Embarcadero Technologies logos and all other Embarcadero
 * Technologies product or service names are trademarks, servicemarks, and/or
 * registered trademarks of Embarcadero Technologies, Inc. and are protected by
 * the laws of the United States and other countries.
 * Oracle and Java are registered trademarks of Oracle and/or its affiliates.
 * Microsoft, Windows, Windows NT, and/or other Microsoft products referenced
 * herein are either registered trademarks or trademarks of Microsoft
 * Corporation in the United States and/or other countries.
 *)

 (**
  * \page version Release notes
  *
  * \section s5_0 Revision 5.0 (released ...)
  * \li Ready for Delphi XE
  * \li UTF-8 support (SCROOGE_UTF8 compiler switch)
  * \li Upgraded to doxygen 1.7.1
  * \li Improved picture support
  *
  * \section s4_9 Revision 4.9 (released 2010-03-07)
  * \li Support for HTML5
  * \li Removed XHTML 2.0 support (see http://www.w3.org/News/2009#item119)
  * \li Code cleanup (remaining conditional CLR / Kylix parts)
  * \li Fixed Delphi 5 support (soFromBeginning in TCustomScrooge.RichEditToHTML)
  *
  * \section s4_8 Revision 4.8 (released 2009-09-01)
  * \li Ready for Delphi 2010
  * \li Upgraded to doxygen 1.6.1
  *
  * \section s4_7 Revision 4.7 (released 2009-04-07)
  * \li Fixed Delphi 2009 warnings
  * \li Removed Kylix code (support for Kylix has been replaced by Free Pascal support).
  * \li Upgraded to doxygen 1.5.8
  *
  * \section s4_6 Revision 4.6 (released 2008-09-14)
  * \li Prepared for Delphi 2009
  * \li Removed conversion of single quotes to apos in XHTML translator. Some
  * browsers do not understand this code in web pages.
  *
  * \section s4_5 Revision 4.5 (released 2008-03-22)
  * \li Added full source code and documentation to demo distribution
  * \li ScroogeXHTMLDemo uses runtime creation of ScroogeXHTML and btRichPop component
  * \li Full distribution uses a new folder structure
  * \li Added package folder with prepared packages for Delphi 6 to 2007
  * \li Added ScroogeXHTML palette bitmap to packages
  * \li Added lib folder for compiled packages
  * \li Removed deprecated XmlValidator
  * \li Removed SX_FLATPROPERTIES compiler switch
  * \li Replaced string with AnsiString (for Tiburon)
  * \li Kylix no longer tested (but still handled in the source code)
  * \li (Tested with Turbo Delphi 2006 .NET)
  *
  * \section s4_4 Revision 4.4 (released 2008-02-01)
  * \li Added ConvertUsingPrettyIndents property
  * \li Added warning if compatibility switch SX_FLATPROPERTIES is defined
  * \li Upgraded to doxygen 1.5.4
  * \li Fixed minor documentation errors
  *
  * \section s4_3 Revision 4.3 (released 2007-12-12)
  * \li Added support for FreePascal compiler
  * \li Added PDF documentation (Getting started with ScroogeXHTML)
  * \li Added new switch SX_FLATPROPERTIES to move deprecated options to public section
  * \li Fixed minor documentation errors
  *
  * \section s4_2 Revision 4.2 (released 2007-07-08)
  * \li Added package (\*.dpk) files for Delphi 6 to Delphi 2007 and Kylix 3.
  * \li Added basic support for parameter values in the range -2^63..2^63 -1.
  * \li Fixed a bug in "hidden text" support
  *
  * \subsection min_4_2 Minor changes
  * \li Fixed a small bug in TCharacterProperties.SetUnderline
  * \li Added Kylix compilation to the automated build process.
  *
  * \section s4_1 Revision 4.1 (released 2006-12-23)
  * \subsection maj_4_1 Major changes
  * \li Added support for Delphi VCL.NET (still beta)
  * \li Added support for Delphi 2006
  * \li Added support for Delphi 5
  * \li Improved support for hidden text
  *
  * \subsection min_4_1 Minor changes
  * \li Added BtCompilerDefines.inc
  * \li Changed string to AnsiString where neccessary
  * \li Changed deprecated soFromBeginning to soBeginning in TCustomScrooge.RichEditToHTML
  * \li Added TSxFormatter class and ISxFormatter interface
  *
  * \section s4_0 Revision 4.0 (released 2005-01-07)
  *
  * \subsection maj_4_0 Major changes
  *
  * \li Renamed core classes and filenames to start with Sx (instead of ScroogeXHTML)
  * \li Added TXHTML11Translator for XHTML 1.1
  * \li Added TXHTML20Translator for XHTML 2.0
  * \li Added language support (lang="..", xml:lang="..")
  * \li Added simple plain text export
  * \li Added nested properties OptionsHead and OptionsOptimize, these keep
  *     related properties for the HTML HEAD section and for optimization
  *     in two property groups. The old properties are still there but are
  *     only work as a redirection to the new properties.
  *
  * \attention
  * The old properties for the HTML header and for optimization options
  * are now marked as 'deprecated', and will be removed in the next major
  * release.
  *
  * \subsection min_4_0 Minor changes
  *
  * \li Removed dependency of SxBase on ExamplePictureSupport
  * \li Improved handling of fonttables
  * \li Improved handling of 'up' and 'dn' tokens
  * \li Moved property TScroogeXHTMLWriter.IsNumbered to private
  * \li Renamed ParAlignment and ParDirection to Alignment and Direction
  * \li \{\$IFDEF SX_DEBUG\} may be used to minimize code size when debugging
  *     is not neccessary
  * \li Added TScroogeXHTMLBase.VerifySettings; to verify property settings
  * \li ExamplePictureAdapter will set the picture number to 1 in Init;
  * \li The PictureAdapter will auto-generate a value for the DocName property
  * \li Moved ReplaceFonts property to ScroogeXHTMLBase class
  * \li Removed deprecated function GetSettings: AnsiString;
  * \li Removed deprecated option hoHyperlinkFootnotes (comments) and related
  *     protected property LinkCollection
  * \li TParagraphProperties new property NumberingLevel, simplified all
  *     SetParProperties methods
  * \li Refactorings to simplify SimpleDomNode: added Data property which
  *     contains Character- and ParagraphProperties
  * \li Added support for pnlvlcont token
  * \li Fixed some unit test reference files
  * \li never generate the xml tag if the document type is HTML, even if
  *     the property IncludeXMLDeclaration has been set to True.
  * \li Removed paragraph alignment paNone
  * \li Removed method GetStatistics
  * \li XHTML 1.1 always has a DOCTYPE declaration
  * \li Added Trim(CurFontName) in method FinishFontName
  * \li Fixed TCustomTranslator.GetStyleParam
  * \li Added property XmlValidator and example validator class TXDomValidator
  *     (based on XDOM_3_1) in unit SxSimpleValidator
  *
  * \attention
  * XmlValidator is still experimental and may cause memory leaks.
  * Please do not use in production environments.
  *
  * \section s3_8 Revision 3.8 (released 2005-08-13)
  * \subsection maj_3_8 Major changes
  * \li New: function ConvertRTF(const RTFfilename: AnsiString): AnsiString;
  * \li Improved: conversion speed increased by 10-20%
  *
  * \subsection min_3_8 Minor changes
  * \li Documentation cleaned
  * \li Fixed type mismatch in ScroogeXHTMLBase.pas
  * \li Fixed usage of Interface IUnicodeTranslator
  * \li Removed unneccessary revision control tags
  * \li Added const modifier to procedure and function parameters
  * \li AbortConversion is now a public property
  * \li TCharacterProperties unneccessary properties and methods
  * \li added DeepCopy method for TCharacterProperties and TParagraphProperties
  * \li use DeepCopy method in ScroogeXHTMLWriter
  * \li replaced TTextAttributes with TCharacterProperties
  * \li removed unneccessary getter methods in ScroogeXHTMLWriter
  * \li removed unneccessary setter methods in ScroogeXHTMLBase
  * \li Added const keyword to EncodingEvent type declaration to fix a strange
  *     access violation when converting embedded WMF pictures
  * \li Added interface IPictureAdapter for PictureAdapter classes
  *
  * \section s3_7 Revision 3.7 (released 2005-02-08)
  *
  * \li New: support for Delphi 2005
  * \li New: help in CHM format
  * \li New: support for RTF tokens 'uldb' (double underline),
  *     'v' (hidden) and 'footnote'
  * \li Fixed usage of Interface ISxTranslator
  * \li Replaced _new by _blank (the standard target name).
  *     Note: this will open *each* clicked link in a new window.
  *
  * \section s3_6 Revision 3.6 (released 2004-01-03)
  *
  * \subsection maj_3_6 Major changes
  *
  * \li New: basic support for right-to-left languages
  * \li New: basic Kylix compatibility
  * \li New: support for relative font sizes ('em', 'ex' and percent values)
  *
  * \subsection min_3_6 Minor changes
  *
  * \li Fixed a bug which appeared with RTF files created by MS Powerpoint(tm)
  * \li Improved SymbolToUnicode function for Symbol font
  * \li Replaced deprecated EScroogeException type by standard Exception type
  * \li Changed TInternalState enumeration values to (isNorm, isBin, isHex)
  *
  * \section s3_5 Revision 3.5 (released 2003-08-31)
  *
  * \subsection maj_3_5 Major changes
  *
  * \li New: support for HTML 4.01, XHTML Basic 1.0 and XHTML Mobile Profile 1.0 (WAP 2.0)
  * \li Improved: this version includes a much faster XHTML 1.0 Strict and Transitional converter
  * \li New: the OnBeforeEncode event allows to intercept and modify the document text as Unicode WideStrings before its conversion to UTF-8
  * \li New: Translator interface and subclass structure allows easy integration of new document types
  * \li New: API documentation created with Doxygen
  *
  * \section s3_4 Revision 3.4 (released 2003-08-03)
  *
  * \subsection maj_3_4 Major changes
  *
  * \li New: Double Byte Character Set support for Japanese, Simplified Chinese, Traditional Chinese and Korean
  * \li New: property ConvertEmptyParagraphs which converts empty paragraphs (\<p>\</p>) by a line break tag (\<br />)
  *)

end.

