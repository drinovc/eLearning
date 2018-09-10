(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					
unit SxFormatter;

interface
uses SxInterfaces;

type
  (**
   * A text formatter for HTML and XHTML output beautification.
   *)
  TSxFormatter = class(TInterfacedObject, ISxFormatter)
  private
    FIndentLevel: Integer;
    FSpaces: AnsiString;
    FNewLine: AnsiString;
    procedure SetIndentLevel(const Value: Integer);
    procedure SetSpaces(const Value: AnsiString);
    procedure SetNewLine(const Value: AnsiString);
    function GetIndentLevel: Integer;
    function GetNewLine: AnsiString;
    function GetSpaces: AnsiString;

  public
    constructor Create;

   (**
    * Add.
    *)
    function Add(const Text: AnsiString): AnsiString;
   (**
    * Indent.
    *)
    function Indent(const Text: AnsiString): AnsiString;
   (**
    * UnIndent.
    *)
    function UnIndent(const Text: AnsiString): AnsiString;
   (**
    * GetIndent.
    *)
    function GetIndent(const Level: Integer): AnsiString; overload;
   (**
    * GetIndent.
    *)
    function GetIndent: AnsiString; overload;

    // properties
    property IndentLevel: Integer read GetIndentLevel write SetIndentLevel;
    property NewLine: AnsiString read GetNewLine write SetNewLine;
    property Spaces: AnsiString read GetSpaces write SetSpaces;
  end;

implementation
uses SxTypes;

{ TFormatter }

function TSxFormatter.Add(const Text: AnsiString): AnsiString;
begin
  Result := getIndent + Text + FNewLine;
end;

constructor TSxFormatter.Create;
begin
  inherited Create;
  FIndentLevel := 0;
  FNewLine := CrLf;
  FSpaces := '  ';
end;

function TSxFormatter.GetIndent(const Level: Integer): AnsiString;
var
  I: Integer;
begin
  Result := '';
  for I:=1 to Level do
    Result := Result + FSpaces;
end;

function TSxFormatter.GetIndent: AnsiString;
begin
  Result := GetIndent(FIndentLevel)
end;

procedure TSxFormatter.SetIndentLevel(const Value: Integer);
begin
  FIndentLevel := Value;
end;

procedure TSxFormatter.SetNewLine(const Value: AnsiString);
begin
  FNewLine := Value;
end;

procedure TSxFormatter.SetSpaces(const Value: AnsiString);
begin
  FSpaces := Value;
end;

(**
 * Indent text.
 *)
function TSxFormatter.Indent(const Text: AnsiString): AnsiString;
begin
  Inc(FIndentLevel);
  Result := Add(Text);
end;

(**
 * Un-Indent text.
 *)
function TSxFormatter.UnIndent(const Text: AnsiString): AnsiString;
begin
  Dec(FIndentLevel);
  Result := Add(Text);
end;

function TSxFormatter.GetIndentLevel: Integer;
begin
  Result := FIndentLevel;
end;

function TSxFormatter.GetNewLine: AnsiString;
begin
  Result := FNewLine;
end;

function TSxFormatter.GetSpaces: AnsiString;
begin
  Result := FSpaces;
end;

end.
