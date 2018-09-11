(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

(** main reader and writer routine *)
unit SxReader;

interface

uses
  SxInterfaces,
  SxTypes,
  SxBase,
  Classes; // TStrings

type
  (**
   *  This class reads the RTF input and sends the property changes to an instance
   *  of TSxWriter.
   *
   *  \sa TSxWriter
   *
   *)
  TSxReader = class(TInterfacedObject, ISxReader)
  private
    // properties
    FSkipUnkDest: boolean;
    FDestination: TRTFDestination; // current destination
    //
    Converter: TSxBase;
    Writer: ISxWriter;
    GroupLevel: Integer;
    BinByteCount: Int64;
    ParamVal: Int64;
    IntState: TInternalState;
    DefaultFontNr: Integer; // 'deff' token
    ColorTable: TStrings; // color table
    FontTable: TStrings; // font table
    PropertyStack: TStrings;
    RTFLength: Integer;
    // Header properties: current font
    CurFontNr: Integer;
    CurFontName: AnsiString;
    CurFontFamily: TFontFamily;
    //
    CurFontCSet: Integer;
    // Header properties: current color
    Red, Green, Blue: Integer;
    UnicodeSkip: Integer;
    CurrUniSkip: Integer;
    // decode picture date (2 hex characters -> 1 byte)
    PictNibble: Integer;
    PictHex: AnsiString;

    (** save the current reader state *)
    procedure PushRTFState;
    (** restore the last reader state *)
    procedure PopRTFState;
    (** add a color (RGB-value) to the color table *)
    procedure FinishColorTableEntry;
    (** used for debugging only *)
    procedure FinishColorTable;
    (** replace fonts and set the default font name *)
    procedure FinishFontTable;
    (** get a font name using its number as key *)
    function GetFontNameByNr(const FontNr: Integer): AnsiString;
    (** get a font character set using its number as key *)
    function GetFontCharSetByNr(const FontNr: Integer): TCharset;
    (** change a property to a new value *)
    procedure SetProperty(const Prop: TRTFProperty; const Value: Int64);
    (** change the destination *)
    procedure SetDestination(const Value: TRTFDestination);
    (** change the 'skip unknown destination' flag *)
    procedure SetSkipUnknownDestination(const Value: boolean);
    (** the current Destination *)
    property Destination: TRTFDestination read FDestination write
      SetDestination;
    (** the 'skip unknown destination' flag *)
    property SkipUnknownDestination: boolean read FSkipUnkDest write
      SetSkipUnknownDestination;

  public
    (** create a new instance of a TSxReader *)
    constructor Create(const AOwner: TSxBase; const AWriter:
      ISxWriter);

    (** destroy the TSxReader *)
    destructor Destroy; override;

    (** the main converter procedure *)
    procedure ConvertRTFToHTML(const RTFsource: AnsiString);

  end;

implementation

{$IFNDEF DOXYGEN_SKIP}

uses
  SxUnicode, // Charsets
  Sysutils,
  SxLanguage; // IntToStr

{------------------------------------------------------------------------------
    Procedure: TSxReader.Create
  Description:
       Author: Michael Justin
 Date created: 2001-06-16
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

constructor TSxReader.Create(const AOwner: TSxBase; const
  AWriter: ISxWriter);
begin
  inherited Create;
  
  Converter := AOwner;
  Writer := AWriter;

  PropertyStack := TStringlist.Create;
  FontTable := TStringlist.Create;
  ColorTable := TStringlist.Create;

  GroupLevel := 0;
  SkipUnknownDestination := false;
  BinByteCount := 0;
  ParamVal := 0;
  IntState := isNorm;
  Destination := destBodyText;
  UnicodeSkip := 1;
  // fontTable
  CurFontName := '';
  CurFontNr := 0;
  CurFontCSet := 0;
  // colorTable
  Red := 0;
  Green := 0;
  Blue := 0;

  Converter.Log(logDebug, 'ScroogeXHTMLReader created');

end;

{------------------------------------------------------------------------------
    Procedure: TSxReader.Destroy
  Description:
       Author: Michael Justin
 Date created: 2001-06-14
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

destructor TSxReader.Destroy;
var
  I: Integer;
begin
  for i := 0 to propertyStack.count - 1 do
    propertyStack.objects[i].Free;
  propertyStack.Clear;
  propertyStack.Free;

  for i := 0 to FontTable.count - 1 do
    FontTable.Objects[i].Free;
  FontTable.Clear;
  FontTable.Free;

  colorTable.Clear;
  colorTable.Free;

  inherited;

end;

{------------------------------------------------------------------------------
    Procedure: TSxReader.SetDestination
  Description: set the Destination field
       Author: Michael Justin
 Date created: 2001-06-14
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxReader.SetDestination(const Value: TRTFDestination);
begin
  if Value <> FDestination then
  begin
{$IFDEF SX_DEBUG}
    if Converter.isDebugging then
      case Value of
        destUnknown: writer.Debug('blue', 'destUnknown');
        destBodyText: writer.Debug('blue', 'destBody');
        destFontTable: writer.Debug('blue', 'destFontTable');
        destFileTable: writer.Debug('blue', 'destFileTable>');
        destColorTable: writer.Debug('blue', 'destColorTable');
        destStyleSheet: writer.Debug('blue', 'destStyleSheet');
        destRevisionTable: writer.Debug('blue', 'destRevisionTable');
        destBookmark: writer.Debug('blue', 'destBookmark');
        destTemplate: writer.Debug('blue', 'destTemplate');
        destListTable: writer.Debug('blue', 'destListTable');
        destInformation: writer.Debug('blue', 'destInformation');
        destUpr: writer.Debug('blue', 'destUpr');
        destBullet: writer.Debug('blue', 'destBullet');
        destPicture: writer.Debug('blue', 'destPicture');
        destPnText: writer.Debug('blue', 'destPnText');
      else
        Assert(false, 'No text defined for destination');
      end;
{$ENDIF}
    FDestination := Value;
  end;
end;

{------------------------------------------------------------------------------
    Procedure: SetSkipUnknownDestination
  Description:
       Author: Michael Justin
 Date created: 2001-0
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxReader.SetSkipUnknownDestination(const Value: boolean);
begin
  if Value <> FSkipUnkDest then
  begin
    FSkipUnkDest := Value;
{$IFDEF SX_DEBUG}
    if converter.isDebugging then
    begin
      if FSkipUnkDest then
        writer.Debug('yellow', 'skipUnknownDestination(')
      else
        writer.Debug('yellow', ')end')
    end;
{$ENDIF}
  end;
end;

{------------------------------------------------------------------------------
    Procedure: TSxReader.PushRTFState
  Description: put state to stack
       Author: Michael Justin
 Date created: 2001-06-14
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxReader.PushRTFState;
begin
  try
    // save state
    propertyStack.AddObject('', TReaderProperties.Create(
      Writer.CloneCharacterProperties,
      Writer.CloneParagraphProperties,
      IntState,
      Destination
      ));

{$IFDEF SX_DEBUG}
    if converter.isDebugging then
      writer.Debug('{<u>' + IntToStr(groupLevel) + '</u>');
{$ENDIF}

    IntState := isNorm;
    Inc(groupLevel);

  except
    raise Exception.Create('Property stack overflow');
  end;

end;

{------------------------------------------------------------------------------
    Procedure: TSxReader.PopRTFState
  Description: get last state from stack
       Author: Michael Justin
 Date created: 2001-06-14
Date modified: 2002-07-20
      Purpose: init default font - not active - needs testing
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxReader.PopRTFState;
var
  leavingDestination: TRTFDestination;
  rp: TReaderProperties;

  // perform end of group actions
  procedure BeforeEndGroup;

    procedure FinishFontName;
    var
      P: Integer;
    begin
      // remove trailing ';'
      P := Pos(';', CurFontName);
      if p > 0 then
        Delete(CurFontName, p, Length(CurFontName) - p + 1);

      // Trim Font
      CurFontName := string(Trim(CurFontName));

      // search and replace the rtfFontName using the replaceFonts property
      converter.ReplaceFont(CurFontName);

      // if it contains a space character, add quotes
      if Pos(' ', CurFontName) > 0 then
        CurFontName := '''' + CurFontName + '''';

      // if there is a font type information, use it
      if curFontFamily <> ffNil then
      begin
        case curFontFamily of
          ffRoman, ffScript: CurFontName := CurFontName + ',serif';
          ffSwiss: CurFontName := CurFontName + ',sans-serif';
        end;
      end;

      // add font to fontTable, use curFontNr as 'key'
      // because fontTables can have "gaps" (f4, f28, ...)
      FontTable.AddObject(IntToStr(curFontNr),
        TFontDescriptor.Create(CurFontName, curFontCSet));

      // initialize
      CurFontName := '';
      curFontFamily := ffNil;
      curFontCSet := writer.DocCharset;

    end;

  begin
    // end group action
    case GroupLevel of
      0: Converter.RtfEnd := true;
      1: case leavingDestination of
          destFontTable:
            begin
              FinishFontName;
              FinishFontTable;
            end;
          destColorTable: FinishColorTable;
        end;
      2: case leavingDestination of
          destFontTable: FinishFontName;
        end;
    end;

    case LeavingDestination of
      destPicture:
        begin
{$IFDEF SX_DEBUG}
          if Converter.IsDebugging then
            Writer.Debug(' /PICTURE]');
{$ENDIF}
          if Converter.ConvertPictures then
             if Assigned(Converter.PictureAdapter) then
          begin
            Converter.PictureAdapter.Finalize;
            Writer.DomDocument.AddEncoded(Converter.PictureAdapter.PictureHTML);
          end;
        end;
    end;
  end;

begin
  Dec(groupLevel);

  // which Destination are we about to leave?
  leavingDestination := Destination;

  // first, perform actions for the end of this group
  BeforeEndGroup;

  // then, get the last properties back from the property stack
  if groupLevel > 0 then
  begin
    if propertyStack.count = 0 then
    begin
{$IFDEF SX_DEBUG}
      if Converter.IsDebugging then
        raise Exception.Create('Property stack underflow');
{$ENDIF}
    end
    else
    begin
      // revert to the properties of the enclosing group
      rp := TReaderProperties(propertyStack.objects[propertyStack.count -
        1]);
      Writer.SetCharacterProperties(rp.CharProps);
      Writer.SetParagraphProperties(rp.ParProps);

      if Writer.IsNumbered then
        Writer.NumberingStyle := True;

      self.IntState := rp.InternalState;
      Destination := rp.RTFDestination;
      rp.Free;
      propertyStack.Delete(propertyStack.count - 1);

      if (groupLevel = 1) and (leavingDestination = destFontTable) then
        Writer.FontName := writer.DefaultFontName;

      // now the properties of the previous group are valid again
{$IFDEF SX_DEBUG}
      if converter.isDebugging then
        writer.Debug('}<u>' + IntToStr(groupLevel) + '</u>');
{$ENDIF}
    end
  end;
end;

{------------------------------------------------------------------------------
    Procedure: TSxReader.ConvertRTFToHTML
  Description:
       Author: Michael Justin
 Date created: 2001-06-14
Date modified: 2002-07-20
      Purpose: GetNextCharacter: avoid RangeCheckError if sourcePos > RTFLength
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxReader.ConvertRTFToHTML(const RTFsource: AnsiString);
var
  SourcePos: Integer;
  NextChar: AnsiChar;
  HexCode: AnsiString;
  Nibble: Shortint;

  Position,
    SubPosition,
    NextIncrement: Integer;

  procedure ShowProgress;
  var
    AllowContinue: boolean;
  begin
    if Assigned(Converter.OnProgress) then
    begin
      AllowContinue := True;
      Converter.OnProgress(Self, Position, AllowContinue);
      Converter.AbortConversion := not AllowContinue;
    end;
  end;

  function GetNextCharacter: AnsiChar;
  begin
    if Assigned(Converter.OnProgress) then
    begin
      Inc(SubPosition);
      if SubPosition > NextIncrement then
      begin
        SubPosition := 0;
        Inc(Position, 10);
        ShowProgress;
      end;
    end;

    // avoid RangeCheckError if sourcePos > RTFLength (needs testing)
    Inc(SourcePos);
    if SourcePos <= RTFLength then
    begin
      NextChar := RTFsource[SourcePos];
    end
    else
      NextChar := #0;

    Result := NextChar;
  end;

  function UndoGetNextCharacter: AnsiChar;
  begin
    Dec(SourcePos);
    NextChar := RTFsource[SourcePos];
    Result := NextChar;
  end;

  procedure PrintCharacter(const Ch: AnsiChar);
  begin
    case Destination of
      destBodyText:
{$IFDEF SX_DEBUG}
        if Converter.IsDebugging then
        begin
          Writer.Debug('<b>' + Ch + '</b>')
        end
        else
{$ENDIF}
        begin
          if CurrUniSkip > 0 then
            Dec(CurrUniSkip)
          else
            Writer.AddChar(Ch);
        end;
      destColorTable:
        begin
          if Ch = ';' then
            FinishColorTableEntry;
{$IFDEF SX_DEBUG}
          if Converter.IsDebugging then
            Writer.Debug('gray', Ch);
{$ENDIF}
        end;
      destFontTable:
        begin
          CurFontName := CurFontName + Ch;
{$IFDEF SX_DEBUG}
          if converter.isDebugging then
            writer.Debug('gray', Ch);
{$ENDIF}
        end;
      destPicture:
        if converter.ConvertPictures then
        begin
          pictHex := pictHex + Ch;
          Dec(pictNibble);
          if pictNibble = 0 then
          begin
            if Assigned(Converter.PictureAdapter) then
            Converter.PictureAdapter.Write(byte(StrToInt('$' + pictHex)));
            pictNibble := 2;
            pictHex := '';
          end;
        end;
      // destPnText:
      //  PnText := PnText + Ch;
    else
      // ignore (and do not print #0)
{$IFDEF SX_DEBUG}
      if Converter.IsDebugging and (Ch <> #0) then
        Writer.Debug('gray', Ch);
{$ENDIF}
    end;
  end;

  // Change to the destination specified by dest
  procedure ChangeDestination(ADestination: TRTFDestination);
  begin
    case ADestination of
      destUnknown,
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
        destUpr: Destination := ADestination;
      destPicture:
        begin
          Destination := ADestination;
{$IFDEF SX_DEBUG}
          if converter.isDebugging then
            writer.Debug('[PICTURE ');
{$ENDIF}
          if Converter.ConvertPictures then
          if Assigned(Converter.PictureAdapter) then
          begin
            Converter.PictureAdapter.IncPictNumber;
            pictNibble := 2;
            pictHex := '';
          end;
        end;
      destBullet:
        begin
{$IFDEF SX_DEBUG}
          if converter.isDebugging then
            writer.Debug('[BULLET ');
{$ENDIF}
          Destination := destBullet;
          Writer.IsNumbered := True;
        end;
      // destPnText:
      //  Destination := destPnText;
    else
      Destination := destUnknown;
    end;
  end;

  procedure ParseCharacter(c: AnsiChar);
  begin
    if (IntState = isBin) then
    begin
      Dec(BinByteCount);
      if BinByteCount <= 0 then
        IntState := isNorm;
    end;
    PrintCharacter(c);
  end;

  procedure ParseSpecialKeyword(RTFFnct: TRTFFunction);

    procedure SkipWord;
    begin
      while nextChar <> '\' do
        GetNextCharacter;
      UndoGetNextCharacter;
    end;

  begin
    // if we're skipping, and it's not
    // the \bin keyword, ignore it.
    if (Destination = destUnknown) and (RTFFnct <> fnctBin) then
    begin
{$IFDEF SX_DEBUG}
      if Converter.IsDebugging then
        writer.Debug('yellow', 'destUnknown')
{$ENDIF}
    end
    else
    begin
      case RTFFnct of
        fnctPlain: Writer.ResetCharacterAttributes;
        fnctBin:
          begin
            IntState := IsBin;
            BinByteCount := ParamVal;
          end;
        // it was the \* token, skip unknown destinations
        fnctSkipDest: SkipUnknownDestination := true;
        fnctHex: IntState := isHex;
        fnctSkipWord: SkipWord;
        fnctLinebreak:
          begin
            Writer.DomDocument.AddEncoded(Converter.GetLinebreakTag);
            // Writer.AddElement('br', '*');
            Writer.StoreTextProperties;
          end;
        fnctMiddot: Writer.DomDocument.Add(WideChar(183));
      else
        raise Exception.Create('Bad table (1)');
      end; // case

    end;

  end;

  procedure TranslateKeyword(const AToken: AnsiString; AParamValue: Int64;
    const hasParam: boolean);
  var
    I: Integer;
    Found: boolean;
    TD: TTokenDef;

  {$IFDEF SX_DEBUG}
    procedure DebugInfo(const color: AnsiString);
    begin
      if converter.isDebugging then
      begin
        if hasParam then
          writer.Debug(color, '\' + aToken + IntToStr(AParamValue))
        else
          writer.Debug(color, '\' + aToken);
      end;
    end;
  {$ENDIF}

  begin
    Assert(AToken <> '');

    Found := False;
    // search the token in the token definition table
    for I := 0 to maxToken do
      if tokenTable[I].token = AToken then
      begin
        Found := True;
        TD := TokenTable[I];
        Break;
      end;

    if not Found then
    begin
{$IFDEF SX_DEBUG}
      DebugInfo('red');
{$ENDIF}
      if skipUnknownDestination then // if this is a new destination
        Destination := destUnknown; // skip the destination
      skipUnknownDestination := false;
    end
    else
    begin
{$IFDEF SX_DEBUG}
      DebugInfo('green');
{$ENDIF}
      skipUnknownDestination := false;
      case TD.keytype of
        ktProp:
          begin
            if (TD.passDef or not hasParam) then
              AParamValue := TD.defVal;
            SetProperty(TD.RTFprop, AParamValue);
          end;
        ktChar: ParseCharacter(TD.useChar);
        ktDest: ChangeDestination(TD.idxDest);
        ktFnct: ParseSpecialKeyword(TD.RTFFnct);
        ktFamily:
          curFontFamily := TD.ffamily;
      else
        raise Exception.Create('Bad table (2)');
      end; // case
    end; // if not Found
  end;

  procedure ParseRTFKeyword;
  var
    keyword: AnsiString;
    isNegative: boolean;
    isParam: boolean;
    numpar: AnsiString;
    ParVal: Int64;
  begin
    isNegative := false;
    isParam := false;
    ParVal := 0;

    case GetNextCharacter of
      'a'..'z':
        begin
          keyword := nextChar;
          while GetNextCharacter in ['a'..'z'] do
            keyword := keyword + nextChar;
          if nextChar = '-' then
          begin
            isNegative := true;
            GetNextCharacter;
          end;
          if nextChar in ['0'..'9'] then
          begin
            isParam := true;
            numpar := nextChar;
            while GetNextCharacter in ['0'..'9'] do
              numpar := numpar + nextChar;
          end;
          if isParam then
          begin
            ParVal := StrToInt64Def(numpar,0);
            ParamVal := ParVal; // global!
            if isNegative then
              ParVal := -1 * ParVal
          end;
          if nextChar <> ' ' then
            UndoGetNextCharacter;
          translateKeyword(keyword, ParVal, isParam);
        end
    else
      begin
        keyword := nextChar;
        translateKeyword(keyword, 0, false);
      end
    end;
  end;

begin
  RTFLength := Length(RTFsource);
  position := 0;
  subPosition := 0;
  nextIncrement := Round(RTFLength / 10);
  ShowProgress;

  sourcePos := 0;
  nibble := 2;
  hexCode := '';

  Converter.RtfEnd := False;

  GetNextCharacter;

  while (SourcePos < RTFLength + 1) and not (Converter.RtfEnd) do
  begin
{$IFDEF SX_DEBUG}
    if converter.isDebugging then
      Assert(groupLevel >= 0, 'ScroogeXHTML: stack underflow');
{$ENDIF}
    case nextChar of
      '{': pushRTFState;
      '}': popRTFState;
      '\': parseRTFKeyword;
      #10, #13: ;
    else
      begin
        if (intState = isNorm) then
          ParseCharacter(nextChar)
        else
        begin
          // parsing hex data
          hexCode := hexCode + nextChar;
          Dec(nibble);
          if nibble = 0 then
          begin
            try
{$IFDEF SX_DEBUG}
              if converter.isDebugging then
              begin
                if hexCode = '00' then
                  writer.Debug('$' + hexCode);
              end;
{$ENDIF}
              ParseCharacter(AnsiChar(StrToInt('$' + hexCode)));
            except
              raise Exception.Create('ceUnknownCharacter');
            end; // try
            nibble := 2;
            hexCode := '';
            intState := isNorm;
          end // if nibble
        end; // if intState
      end // begin
    end; // case
    GetNextCharacter;
  end; // while

end;

function Hex(const C: Integer): AnsiString;
begin
  if C < 16 then
    Result := '0' + Format('%x', [c])
  else
    Result := Format('%x', [c])
end;

{------------------------------------------------------------------------------
    Procedure: TSxReader.FinishColorTableEntry
  Description:
       Author: Michael Justin
 Date created: 2001-06-14
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxReader.FinishColorTableEntry;
begin
  inherited;
  colorTable.Add('#' + LowerCase(Hex(red) + Hex(green) + Hex(blue)));
  red := 0;
  green := 0;
  blue := 0;
{$IFDEF SX_DEBUG}
  if Converter.IsDebugging then
    writer.Debug('gray', colorTable[colorTable.count - 1]);
{$ENDIF}
end;

{------------------------------------------------------------------------------
    Procedure: FinishColorTable
  Description: debug information for color table
       Author: Michael Justin
 Date created: 2001-07-29
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxReader.FinishColorTable;
{$IFDEF SX_DEBUG}
var
  i: Integer;
{$ENDIF}
begin
{$IFDEF SX_DEBUG}
  if converter.isDebugging then
  begin
    writer.Debug('<hr />');
    writer.Debug('black', 'FinishColorTable');
    writer.Debug('<br />');
    for i := 0 to colorTable.count - 1 do
    begin
      writer.Debug('black', 'Color' + IntToStr(i) + '=');
      writer.Debug('blue', colorTable[i]);
      writer.Debug('<br />');
    end;
    writer.Debug('<hr />');
  end;
{$ENDIF}
end;

{------------------------------------------------------------------------------
    Procedure: TSxReader.FinishFontTable
  Description: clean up font table and replace platform dependent font names
       Author: Michael Justin
 Date created: 2001-06-14
Date modified: 2001-06-24
      Purpose: added FReplaceFonts property
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxReader.FinishFontTable;
var
  i: Integer;
  s: AnsiString;
  d: TFontDescriptor;

begin
{$IFDEF SX_DEBUG}
  if converter.isDebugging then
  begin
    writer.Debug('<hr />');
    writer.Debug('black', 'FinishFontTable');
    writer.Debug('<br />');
  end;
{$ENDIF}

  if FontTable.count = 0 then
  begin
    converter.log(logWarning, 'Font table is empty');
    FontTable.AddObject('0',
      TFontDescriptor.Create(converter.DefaultFontName,
      0))
  end
  else
    for i := 0 to FontTable.Count - 1 do
    begin
      // get font name and remove the trailing ";"
      d := TFontDescriptor(fontTable.objects[i]);
      s := d.FontName;
      // change font name
      converter.ReplaceFont(s);
      // put the font back in the font table
      d.FontName := s;
{$IFDEF SX_DEBUG}
      if converter.isDebugging then
      begin
        writer.Debug('black', 'Font' + FontTable[i] + '=');
        writer.Debug('blue', s + ' (' + IntToStr(d.FontCharSet) +
          ')<br />');
      end;
{$ENDIF}
    end;

  // now it is safe to pass the default font name to the writer:
  writer.DefaultFontName := GetFontNameByNr(DefaultFontNr);

{$IFDEF SX_DEBUG}
  if converter.isDebugging then
  begin
    writer.Debug('black', 'Default font=' + IntToStr(DefaultFontNr) + '=' +
      writer.DefaultFontName + '<br />');
    writer.Debug('<hr' + converter.GetCloseEmptyElement);
  end;
{$ENDIF}

end;

{------------------------------------------------------------------------------
    Procedure: GetFontNameByNr
  Description: find font name by number
       Author: Michael Justin
 Date created: 2001-07-30
Date modified:
      Purpose:
 Known Issues:
 ------------------------------------------------------------------------------}

function TSxReader.GetFontNameByNr(const fontNr: Integer):
  AnsiString;
var
  i: Integer;
begin
  // search the font number in the font table index
  i := FontTable.IndexOf(IntToStr(fontNr));
  if i > -1 then
  begin
    result := TFontDescriptor(FontTable.Objects[i]).FontName;
  end
  else
  begin
    converter.Log(logWarning, 'Font ' + IntToStr(fontNr) + ' not found');
    result := converter.DefaultFontName;
  end
end;

function TSxReader.GetFontCharSetByNr(const fontNr: Integer):
  TCharset;
var
  i: Integer;
begin
  // search the font number in the font table index
  i := FontTable.IndexOf(IntToStr(fontNr));
  if i > -1 then
  begin
    result := TFontDescriptor(FontTable.Objects[i]).FontCharSet;
  end
  else
  begin
    result := writer.DocCharset;
  end
end;

{------------------------------------------------------------------------------
    Procedure: TSxReader.SetProperty
  Description: notify writer about property changes
       Author: Michael Justin
 Date created: 2001-06-14
Date modified: 2001-06-17
      Purpose: apply changes only when in Destination destBody (e.g. not in stylesheet)
Date modified: 2001-07-03
      Purpose: added paJustify
 Known Issues:
 ------------------------------------------------------------------------------}

procedure TSxReader.SetProperty;
begin
  if (Destination = destUnknown) then
    Exit // If we're skipping text, don't do anything.
  else
    case Destination of
      destFontTable:
        case Prop of
          propFontNumber: if (opFontName in Converter.FontConversionOptions)
            then
              CurFontNr := Value;
          propFontCharSet: CurFontCSet := Value;
        end;
      destColorTable:
        case Prop of
          propRed: Red := Value;
          propGreen: Green := Value;
          propBlue: Blue := Value;
        end;
      destBullet:
        case Prop of
          propPnLvl: Writer.NumberingLevel := Value;
          propPnLvlCont: Writer.IsNumbered := False;
        end;
      destPicture:
        if Converter.ConvertPictures then
         if Assigned(Converter.PictureAdapter) then
          with Converter.PictureAdapter do
          begin
            case Prop of
              propEMF: PicInfo.PictureSource := psEMF;
              propPNG: PicInfo.PictureSource := psPNG;
              propJPEG: PicInfo.PictureSource := psJPEG;
              propPICT: PicInfo.PictureSource := psPICT;
              propWMF:
                begin
                  picinfo.pictureSource := psWMF;
                  picinfo.mappingmode := Value;
                end;
              propPicH: picinfo.height := Value;
              propPicW: picinfo.width := Value;
              propHGoal: picinfo.HGoalTwips := Value;
              propWGoal: picinfo.WGoalTwips := Value;
            else
              //
            end;
          end; // with

      destBodyText:
        case Prop of
          propANSI: Writer.DocCharset := SxUnicode.ANSI_CHARSET;
          propMAC: Writer.DocCharset := SxUnicode.MAC_CHARSET;
          propDeff: DefaultFontNr := Value;

          propBold: if opFontStyle in converter.FontConversionOptions then
            begin
              if Value = 1 then
                Writer.FontStyle := Writer.FontStyle + [fsBold]
              else
                Writer.FontStyle := Writer.FontStyle - [fsBold];
            end;

          propItalic: if opFontStyle in converter.FontConversionOptions then
            begin
              if Value = 1 then
                Writer.FontStyle := Writer.FontStyle + [fsItalic]
              else
                Writer.FontStyle := Writer.FontStyle - [fsItalic];
            end;

          propUnderline: if opFontStyle in converter.FontConversionOptions then
            begin
              if Value = 1 then
                Writer.FontStyle := Writer.FontStyle + [fsUnderline]
              else
                Writer.FontStyle := Writer.FontStyle - [fsUnderline];
            end;

          propStrikeOut: if opFontStyle in converter.FontConversionOptions then
            begin
              if Value = 1 then
                Writer.FontStyle := Writer.FontStyle + [fsStrikeOut]
              else
                Writer.FontStyle := Writer.FontStyle - [fsStrikeOut];
            end;

          propHidden:
             Writer.IsHidden := Value = 1;

          propFontSize: if opFontSize in converter.FontConversionOptions then
             Writer.FontSize := Value div 2;

          propFontNumber:
            begin
              if opFontName in converter.FontConversionOptions then
              begin
                Writer.FontName := GetFontNameByNr(Value);
              end;
              Writer.FontCharSet := GetFontCharSetByNr(Value);
            end;

          propFontColor: if opFontColor in converter.FontConversionOptions then
            begin
              if ColorTable.Count = 0 then
                Writer.FontColor := converter.DefaultFontColor
              else
              try
                Writer.FontColor := colorTable[Value];
              except
                begin
                  Converter.Log(logWarning, 'Color ' + IntToStr(Value) +
                    ' not found');
                  Writer.FontColor := converter.DefaultFontColor;
                end;
              end;
            end;

          propFontBGColor: if opFontBGColor in converter.FontConversionOptions
            then
            begin
              if (Value = 0) or (colorTable.count = 0) then
                Writer.FontBGColor := ''
              else
              try
                Writer.FontBGColor := colorTable[Value];
              except
                begin
                  converter.Log(logWarning, 'Color ' + IntToStr(Value) +
                    ' not found');
                  Writer.FontBGColor := '';
                end;
              end;
            end;

          propFontHLColor: if opFontHLColor in converter.FontConversionOptions
            then
            begin
              if (Value = 0) or (colorTable.count = 0) then
                Writer.FontHLColor := ''
              else
              try
                Writer.FontHLColor := colorTable[Value];
              except
                begin
                  converter.Log(logWarning, 'Color ' + IntToStr(Value) +
                    ' not found');
                  Writer.FontHLColor := '';
                end;
              end;
            end;

          propJustC: Writer.Alignment := paCenter;
          propJustL: Writer.Alignment := paLeftJustify;
          propJustR: Writer.Alignment := paRightJustify;
          propJustified: Writer.Alignment := paJustify;

          propLeftInd,
            propRightInd,
            propFirstInd: if converter.ConvertIndent and not writer.isNumbered
              then
              case prop of
                propLeftInd: Writer.LeftIndent := Value;
                propRightInd: Writer.RightIndent := Value;
                propFirstInd: Writer.FirstIndent := Value;
              else
                Assert(false);
              end;

          propSuper: Writer.Superscript := Value > 0;
          propSub: Writer.Subscript := Value > 0;
          propNoSuper:
            begin
              Writer.Superscript := false;
              Writer.Subscript := false;
            end;

          propLanguage: Writer.Language := GetLanguageCode(Value);

          propLTR: Writer.Direction := diLTR;
          propRTL: Writer.Direction := diRTL;

          propLTRPar: Writer.ParDirection := diLTR;
          propRTLPar: Writer.ParDirection := diRTL;

          propPard: Writer.ResetParagraphAttributes;

          propUnicode:
            begin
              if Value > 0 then
                Writer.DomDocument.Add(WideChar(Value))
              else
                // Unicode Values greater than 32767 are
                // expressed as negative numbers
                Writer.DomDocument.Add(WideChar(65536 + Value));
              currUniSkip := unicodeSkip;
            end;

          propUnicodeSkip: unicodeSkip := Value;

        else
          //
        end; // case prop of
    else
      //
    end; // case Destination of
end;

{$ENDIF}

end.

