(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

(** document object which stores and builds the complete output *)
unit SxDocument;

interface
uses SxDocumentNode,
  SxSimpleDomInterfaces,
  SxTypes,
  Classes;

type
  (**
   * A class which represents a document.
   *)
  TSimpleDomDocument = class(TSimpleDomNode, ISimpleDomDocument)
  private
    (** add a paragraph *)
    procedure AddPar;

  public
    (** create a new instance of the TSimpleDomDocument class *)
    constructor Create(const AOwner: TSimpleDomNode);

    (** add a string to the document *)
    procedure Add(const S: WideString); overload;

    (** add an encoded string to the document *)
    procedure AddEncoded(const S: WideString);

  end;

implementation
uses SxDocumentText,
  SxDocumentParagraph;

constructor TSimpleDomDocument.Create(const AOwner: TSimpleDomNode);
begin
  inherited Create(nil, etDocument);
  AddPar; // add a starting paragraph
end;

procedure TSimpleDomDocument.Add(const S: WideString);
begin
  TTextNode(TParagraphNode(LastChild).LastChild).Add(S);
end;

procedure TSimpleDomDocument.AddPar;
begin
  Append(TParagraphNode.Create(Self));
end;

procedure TSimpleDomDocument.AddEncoded(const S: WideString);
begin
  TParagraphNode(LastChild).AddText;
  with TTextNode(TParagraphNode(LastChild).LastChild) do
  begin
    Encoded := True;
    Add(S);
  end;
  TParagraphNode(LastChild).AddText;
end;

end.

