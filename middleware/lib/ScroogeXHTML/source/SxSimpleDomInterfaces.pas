(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

unit SxSimpleDomInterfaces;

interface

uses
  SxDocumentNode, SxTypes;

type
  (**
   * \interface ISimpleDomDocument
   * DOM document methods
   *)
  ISimpleDomDocument = interface(ISimpleDomNode)
    (**
     * Add a string
     *)
    procedure AddEncoded(const S: WideString);
    (**
     * Add a paragraph
     *)
    procedure AddPar;
  end;

  (**
   * \interface ISimpleDomParagraph
   * DOM paragraph methods
   *)
  ISimpleDomParagraph = interface(ISimpleDomNode)
    (**
     * Add a new empty text node
     *)
    procedure AddText;
    (**
     * Set paragraph properties
     *)
    procedure SetParProperties(const PP: TParagraphProperties);
  end;

  (**
   * \interface ISimpleDomTextNode
   * DOM textnode methods
   *)
  ISimpleDomTextNode = interface(ISimpleDomNode)
    (**
     * Set text properties
     *)
    procedure SetTextProperties(const CharProps: TCharacterProperties);
    (**
     * Get the Encoded value
     *)
    function GetEncoded: Boolean;
    (**
     * Set the Encoded value
     *)
    procedure SetEncoded(const Value: Boolean);

    // properties
    property Encoded: Boolean read GetEncoded write SetEncoded;
  end;

implementation

end.

