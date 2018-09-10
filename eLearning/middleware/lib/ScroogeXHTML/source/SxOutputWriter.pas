(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

unit SxOutputWriter;

interface

uses
  SxInterfaces, SxBase, SxSimpleDomInterfaces, SxTypes,
  Classes;

type
  (**
   * An instance of this class reads the DomDocument and builds the (X)HTML result.
   *)
  TSxOutputWriter = class(TInterfacedObject, ISxOutputWriter)
  private
    FDomDocument: ISimpleDomDocument;
    FEmptyPar: AnsiString;
    FConvertEmpty: Boolean;
    FConvertToPlainText: Boolean;
    FLineTag: AnsiString;
    FConverter: TSxBase;
    SL: TStrings;

    function GetDomDocument: ISimpleDomDocument;
    procedure SetDomDocument(const Value: ISimpleDomDocument);
    procedure SetConverter(const Value: TSxBase);
    procedure SetConvertToPlainText(const Value: Boolean);

    function Translator: ISxTranslator;

    function GetStringResult: SxText;

    (**
     * Write method iterates the DomDocument and builds the (X)HTML result into
     * StringResult.
     *)
    procedure WriteHtml;

    (**
     * Write method iterates the DomDocument and builds the text result into
     * StringResult.
     *)
    procedure WritePlainText;

  public
    constructor Create;

    destructor Destroy; override;

    (**
     * Write method iterates the DomDocument and builds the result into
     * StringResult.
     *)
    procedure Write;

    (**
     * \property ConvertEmpty
     *)
    property ConvertEmpty: Boolean read FConvertEmpty write FConvertEmpty;

    (**
     * \property Converter
     *)
    property Converter: TSxBase read FConverter write SetConverter;

    (**
     * \property ConvertToPlainText
     *)
    property ConvertToPlainText: Boolean write SetConvertToPlainText;

    (**
     * \property DomDocument
     *)
    property DomDocument: ISimpleDomDocument read GetDomDocument write
      SetDomDocument;

    (**
     * \property EmptyPar
     *)
    property EmptyPar: AnsiString read FEmptyPar write FEmptyPar;

    (**
     * \property LineTag
     *)
    property LineTag: AnsiString read FLineTag write FLineTag;

    (**
     * \property StringResult
     *)
    property StringResult: SxText read GetStringResult;

  end;

implementation

uses
  SxDocumentText, SxDocumentParagraph,
  SysUtils;

{ TOutputWriter }

constructor TSxOutputWriter.Create;
begin
  inherited;
  SL := TStringList.Create;
end;

destructor TSxOutputWriter.Destroy;
begin
  SL.Clear;
  SL.Free;
  inherited;
end;

function TSxOutputWriter.GetDomDocument: ISimpleDomDocument;
begin
  Result := FDomDocument;
end;

function TSxOutputWriter.GetStringResult: SxText;
begin
  Result := SL.Text;
end;

procedure TSxOutputWriter.SetConverter(const Value: TSxBase);
begin
  FConverter := Value;
end;

procedure TSxOutputWriter.SetConvertToPlainText(const Value: Boolean);
begin
  FConvertToPlainText := Value;
end;

procedure TSxOutputWriter.SetDomDocument(const Value: ISimpleDomDocument);
begin
  FDomDocument := Value;
end;

function TSxOutputWriter.Translator: ISxTranslator;
begin
  Result := Converter.Translator;
end;

procedure TSxOutputWriter.Write;
begin
  if FConvertToPlainText then
    WritePlainText
  else
    WriteHtml;
end;

procedure TSxOutputWriter.WriteHtml;
var
  I: Integer;
  ParContent: WideString;

  function GetOpenListTags(const Para: ISimpleDomParagraph): AnsiString;
  var
    P: TParagraphNode;

  begin
    P := TParagraphNode(Para.PreviousSibling);
    if (P = nil) or (not TParagraphProperties(P.Data).Numbered) then
    begin
      if TParagraphProperties(Para.Data).NumberingLevel <> NL_BULLET then
        Result := '    ' + Converter.GetOrderedListTag + CrLf
      else
        Result := '    ' + Converter.GetUnOrderedListTag + CrLf
    end
    else
      Result := '';
  end;

  function GetCloseListTags(const Para: ISimpleDomParagraph): AnsiString;
  var
    P: TParagraphNode;
  begin
    P := TParagraphNode(Para.NextSibling);
    if (P = nil) or (not TParagraphProperties(P.Data).Numbered) then
    begin
      if TParagraphProperties(Para.Data).NumberingLevel = NL_BULLET then
        Result := '    </ul>' + CrLf
      else
        Result := '    </ol>' + CrLf
    end
    else
      Result := '';

  end;

  function GetParOpenTag(const Para: ISimpleDomParagraph): AnsiString;
  begin
    if TParagraphProperties(Para.Data).Numbered then
      Result := GetOpenListTags(Para) + '      ' + Converter.GetListItemTag + CrLf + Translator.GetMargin
    else
      Result := Translator.GetParagraphStyle(TParagraphProperties(Para.Data));
  end;

  function GetParCloseTag(const Para: ISimpleDomParagraph): AnsiString;
  begin
    if TParagraphProperties(Para.Data).Numbered then
      Result := CrLf + '      </li>' + CrLf + GetCloseListTags(Para)
    else
    begin
      // Since 4.4. Reason: IE does not like CrLf followed by space
      if Converter.ConvertUsingPrettyIndents then
      begin
        Result := CrLf + '    </p>' + CrLf;
      end
      else
      begin
        Result := '</p>' + CrLf;
      end
    end
  end;

  function GetParaHTML(const Para: ISimpleDomParagraph): SxText;
  var
    I: Integer;
    TextNode: TTextNode;
  begin
    Result := '';

    for I := 0 to Para.GetCount - 1 do
    begin
      TextNode := TTextNode(Para.Item[I]);
      if TextNode.TextContent <> '' then
        Result := Result + Converter.TextElementToXHTML(TextNode)
    end;

    if Trim(Result) = '' then
      Result := EmptyPar
    else
      Result := GetParOpenTag(Para) + Result + GetParCloseTag(Para);

  end;

begin
  SL.Clear;

  {#todo2 option "delete empty paragraphs at document end" }
  // delete empty paragraphs at document end
  while DomDocument.GetCount > 0 do
  begin
    if GetParaHTML(TParagraphNode(DomDocument.LastChild)) = EmptyPar then
      DomDocument.Remove(DomDocument.LastChild)
    else
      Break;
  end;

  // collect all paragraphs
  for I := 0 to DomDocument.GetCount - 1 do
  begin
    ParContent := GetParaHTML(TParagraphNode(DomDocument.Item[I]));
    if ConvertEmpty and (ParContent = EmptyPar) then
      SL.Add('    ' + LineTag)
    else
      // remove CrLf
      SL.Add(Copy(ParContent, 1, Length(ParContent) - 2));
  end;

end;

procedure TSxOutputWriter.WritePlainText;
var
  I: Integer;
  function GetPlainText(const Para: ISimpleDomParagraph): AnsiString;
  var
    I: Integer;
  begin
    Result := '';
    for I := 0 to Para.GetCount - 1 do
      Result := Result + Para.Item[I].TextContent;
  end;
begin
  SL.Clear;
  for I := 0 to DomDocument.GetCount - 1 do
    SL.Add(GetPlainText(TParagraphNode(DomDocument.Item[I])));
end;

end.

