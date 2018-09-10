(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

unit SxDocumentText;

interface
uses SxDocumentNode,
  SxSimpleDomInterfaces,
  SxTypes,
  Classes;

type
  (**
   * A class which represents a text block which has the same attributes
   *)
  TTextNode = class(TSimpleDomNode, ISimpleDomTextNode)
  private
    FEncoded: Boolean;

    function GetEncoded: Boolean;
    procedure SetEncoded(const Value: Boolean);

  public
    (** create a new instance of the TTextNode class *)
    constructor Create(const AOwner: TSimpleDomNode);

    (** set all text properties of the TTextNode object *)
    procedure SetTextProperties(const CP: TCharacterProperties);

    (** true = already encoded *)
    property Encoded: Boolean read GetEncoded write SetEncoded;

  end;

implementation

constructor TTextNode.Create(const AOwner: TSimpleDomNode);
begin
  inherited Create(AOwner, etText);
  Data := TCharacterProperties.Create;
end;

procedure TTextNode.SetTextProperties(const CP: TCharacterProperties);
begin
  TCharacterProperties(Data).CopyFrom(CP);
end;

function TTextNode.GetEncoded: Boolean;
begin
  Result := FEncoded;
end;

procedure TTextNode.SetEncoded(const Value: Boolean);
begin
  FEncoded := Value;
end;

end.

