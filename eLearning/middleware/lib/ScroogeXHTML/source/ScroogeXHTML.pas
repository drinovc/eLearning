(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					
 
(**
 * Main ScroogeXHTML component unit
 *)
unit ScroogeXHTML;

interface

uses
  SxMain,
  SysUtils,
  Classes // TStrings
{$IFNDEF CONSOLE}
{$IFNDEF FPC}
  , Comctrls // TRichEdit
{$ENDIF}
{$ENDIF};

type
  (**
   * This class implements the high-level converter methods
   * #ConvertRTFFile and #RichEditToHTML. The third conversion method,
   * TSxBase#Convert, is defined in the superclass.
   *)
  TCustomScrooge = class(TSxMain)
  public
    (**
    * Convert a RTF file to a HTML file.
    *
    * To write an application which can convert a RTF file to a HTML/XHTML file,
    * \li drop a ScroogeXHTML component on the form
    * \li add a button to the form and enter the following code for the OnClick event:
    * \verbatim
      var
       RTFFile, XHTMLFile: AnsiString;
      begin
        RTFFile := 'c:\windows\desktop\test.rtf';
        XHTMLFile := 'c:\windows\desktop\test.html';
        ScroogeXHTML1.ConvertRTFFile(RTFFile, XHTMLFile);
      end;
      \endverbatim
      \arg RTFFilename The name of the input RTF file
      \arg HTMLFilename The name of the output HTML/XHTML file
    *)
    procedure ConvertRTFFile(const RTFFilename, HTMLFilename: TFileName);

    (**
     * Convert a RTF file to a HTML string.
     * \arg RTFFilename The name of the input RTF file
     *)
    function ConvertRTF(const RTFfilename: TFileName): AnsiString;

    (** Convert the RichEdit RTF code to HTML/XHTML.
     * To write an application which can save the contents of a RichEdit
     * component to XHTML file...
     * \li drop a ScroogeXHTML component on the form
     * \li add a button to the form and enter the following code for the OnClick event:
     * \verbatim
       htmlString := ScroogeXHTML1.RichEditToHTML(RichEdit1);
       \endverbatim
      \arg Source The TRichEdit control instance.
     *)
{$IFNDEF CONSOLE}
{$IFNDEF FPC}
    function RichEditToHTML(const Source: TRichedit): AnsiString;
{$ENDIF}
{$ENDIF}

  end;

  (**
   * This class adds no properties or methods, it only defines the component name
   *)
  TBTScroogeXHTML = class(TCustomScrooge)

  end;

implementation

uses
  SxTypes;

procedure TCustomScrooge.ConvertRTFFile(const RTFFilename, HTMLFilename:
  TFileName);
begin
  with TStringList.Create do
  try
    LoadFromFile(RTFfilename);
    if Assigned(PictureAdapter) then
      PictureAdapter.DocName := HTMLfilename;
    Text := Convert(Text);
    if not AbortConversion then
      SaveToFile(HTMLfilename);
  finally
    if Assigned(PictureAdapter) then
      PictureAdapter.DocName := '';
    Free;
  end;
end;

function TCustomScrooge.ConvertRTF(const RTFfilename: TFileName): AnsiString;
begin
  with TStringList.Create do
  try
    LoadFromFile(RTFfilename);
    Result := Convert(AnsiString(Text));
  finally
    Free;
  end;
end;

{$IFNDEF CONSOLE}
{$IFNDEF FPC}
function TCustomScrooge.RichEditToHTML(const Source: TRichedit): AnsiString;
var
  MyStream: TMemoryStream;
begin
  MyStream := TMemoryStream.create;
  with MyStream do
  try
    {$IFDEF VER130}
    Seek(0, soFromBeginning);
    source.lines.SaveToStream(MyStream);
    Seek(0, soFromBeginning);
    {$ELSE}
    Seek(0, soBeginning);
    source.lines.SaveToStream(MyStream);
    Seek(0, soBeginning);
    {$ENDIF}
    with TStringlist.Create do
    try
      LoadFromStream(MyStream);
      result := Convert(text);
    finally
      Free;
    end;
  finally
    MyStream.Free;
  end;
end;
{$ENDIF}
{$ENDIF}

end.

