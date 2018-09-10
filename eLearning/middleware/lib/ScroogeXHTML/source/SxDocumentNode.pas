(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

unit SxDocumentNode;

interface

uses
  Classes;

{$IFNDEF DOXYGEN_SKIP}

type
  TElementType = (etDocument, etParagraph, etText, etElement);

  TSimpleDomNode = class;

  (**
   * \interface ISimpleDomNode
   * Base interface for DOM nodes
   *)
  ISimpleDomNode = interface
    (**
     * Add string to document
     *)
    procedure Add(const S: WideString);
    (**
     * Add node to document
     *)
    function Append(const NewChild: TSimpleDomNode): TSimpleDomNode;

    (**
     * Get the Data value
     *)
    function GetData: TObject;

    (**
     * Set the Data value
     *)
    procedure SetData(const Value: TObject);

    (**
     * Get the TextContent value
     *)
    function GetTextContent: WideString;

    (**
     * Set the TextContent value
     *)
    procedure SetTextContent(const Value: WideString);

    (**
     * Get the node count
     *)
    function GetCount: Integer;

    (**
     * Get the Item at the given index
     *)
    function GetItem(Index: Integer): TSimpleDomNode;

    (**
     * Get the last child
     *)
    function GetLastChild: TSimpleDomNode;

    (**
     * Get the index of the given child node
     *)
    function IndexOf(const Node: TSimpleDomNode): Integer;

    (**
     * Get the previous sibling node
     *)
    function PreviousSibling: TSimpleDomNode;

    (**
     * Get the next sibling node
     *)
    function NextSibling: TSimpleDomNode;

    (**
     * Remove the node
     *)
    procedure Remove(const Node: TSimpleDomNode);

    // properties
    property Data: TObject read GetData write SetData;
    property Item[Index: Integer]: TSimpleDomNode read GetItem; default;
    property LastChild: TSimpleDomNode read GetLastChild;
    property TextContent: WideString read GetTextContent write SetTextContent;

  end;

  (**
   * A class for a light-weight DOM (document object model).
   *)
  TSimpleDomNode = class(TInterfacedObject, ISimpleDomNode)
  private
    FData: TObject;
    FItems: TList;
    FOwner: TSimpleDomNode;
    FTextContent: WideString;

  protected

    function GetData: TObject;
    procedure SetData(const Value: TObject);

    function GetTextContent: WideString;
    procedure SetTextContent(const Value: WideString);

    (**
     * Return the DOM node at the given position.
     *)
    function GetItem(Index: Integer): TSimpleDomNode;

    (**
     * Returns the last DOM child element.
     *)
    function GetLastChild: TSimpleDomNode;

    (**
     * Returns the index of the given node in the node list.
     *)
    function IndexOf(const Node: TSimpleDomNode): Integer;

  public
    (**
     * TSimpleDomNode Constructor.
     *)
    constructor Create(const AOwner: TSimpleDomNode; const AElementType:
      TElementType);

    (*
     * TSimpleDomNode Destructor.
     *)
    destructor Destroy; override;

    (**
     * Add a string to the text.
     *)
    procedure Add(const S: WideString);

    (**
     * Append a DOM node.
     *)
    function Append(const NewChild: TSimpleDomNode): TSimpleDomNode;

    (**
     * Returns the number of child nodes.
     *)
    function GetCount: Integer;

    (**
     * Returns the DOM child node before the current node.
     * Returns nil if the current node is the first node.
     *)
    function PreviousSibling: TSimpleDomNode;

    (**
     * Returns the DOM child node after the current node.
     * Returns nil if the current node is the last node.
     *)
    function NextSibling: TSimpleDomNode;

    (**
     * Removes the DOM node.
     *)
    procedure Remove(const Node: TSimpleDomNode);

    (**
     * \Property Data
     *)
    property Data: TObject read GetData write SetData;

    (**
     * \property Item
     *
     * Returns the DOM child element at the given position.
     *)
    property Item[Index: Integer]: TSimpleDomNode read GetItem; default;

    (**
     * \property LastChild
     *
     * Returns the last DOM child element.
     *)
    property LastChild: TSimpleDomNode read GetLastChild;

    (**
     * \property TextContent
     *
     * Optional text in the Node.
     *)
    property TextContent: WideString read GetTextContent write SetTextContent;

  end;

implementation

{ TSimpleDomNode }

constructor TSimpleDomNode.Create(const AOwner: TSimpleDomNode; const
  AElementType: TElementType);
begin
  inherited Create;
  FItems := TList.Create;
  FOwner := AOwner;
end;

destructor TSimpleDomNode.Destroy;
var
  I: Integer;
begin
  Data.Free;

  for I := 0 to FItems.Count - 1 do
    TSimpleDomNode(FItems[I]).Free;
  FItems.Clear;
  FItems.Free;
  inherited;
end;

function TSimpleDomNode.Append(const NewChild: TSimpleDomNode): TSimpleDomNode;
begin
  FItems.Add(NewChild);
  Result := NewChild;
end;

function TSimpleDomNode.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TSimpleDomNode.PreviousSibling: TSimpleDomNode;
var
  I: Integer;
begin
  I := FOwner.IndexOf(Self);
  if I > 0 then
    Result := TSimpleDomNode(FOwner[I - 1])
  else
    Result := nil;
end;

function TSimpleDomNode.NextSibling: TSimpleDomNode;
var
  I: Integer;
begin
  I := FOwner.IndexOf(Self);
  if I <> FOwner.GetCount - 1 then
    Result := TSimpleDomNode(FOwner[I + 1])
  else
    Result := nil;
end;

function TSimpleDomNode.GetItem(Index: Integer): TSimpleDomNode;
begin
  Result := TSimpleDomNode(FItems[Index]);
end;

function TSimpleDomNode.GetLastChild: TSimpleDomNode;
begin
  Result := TSimpleDomNode(FItems[FItems.Count - 1]);
end;

function TSimpleDomNode.IndexOf(const Node: TSimpleDomNode): Integer;
begin
  Result := FItems.IndexOf(Node);
end;

procedure TSimpleDomNode.Remove(const Node: TSimpleDomNode);
begin
  Node.Free;
  FItems.Remove(Node);
end;

function TSimpleDomNode.GetTextContent: WideString;
begin
  Result := FTextContent;
end;

procedure TSimpleDomNode.SetTextContent(const Value: WideString);
begin
  FTextContent := Value;
end;

procedure TSimpleDomNode.Add(const S: WideString);
begin
  FTextContent := FTextContent + S;
end;

function TSimpleDomNode.GetData: TObject;
begin
  Result := FData;
end;

procedure TSimpleDomNode.SetData(const Value: TObject);
begin
  FData := Value;
end;

{$ENDIF}

end.

