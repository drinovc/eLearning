unit MxADO;

interface

uses
  SysUtils, Classes, DB, ADODB, Dialogs
  //, DesignEditors, DesignIntf
  ;

type
  (*TADOMXConnectionEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;*)

  (*TFieldsProperty = class(TClassProperty)
  public
    procedure Edit; override;
  end;*)

  TADOQueryMX = class(TADOQuery)
  private
    //FConnection: TADOConnection;
    //FSelectQuery: TADOQuery;
    FInsertQuery: TADOQuery;
    FDeleteQuery: TADOQuery;
    FUpdateQuery: TADOQuery;

    //function GetConnection: TADOConnection;
  protected
    procedure SetConnection(const Value: TADOConnection); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    //property Connection: TADOConnection read GetConnection write SetConnection;
    //property SelectQuery: TADOQuery read FSelectQuery;
    property InsertQuery: TADOQuery read FInsertQuery;
    property DeleteQuery: TADOQuery read FDeleteQuery;
    property UpdateQuery: TADOQuery read FUpdateQuery;
  end;

procedure Register;

implementation

//uses DSDesign;

(*procedure TFieldsProperty.Edit;
begin
end;*)

{procedure TADOMXConnectionEditor.ExecuteVerb(Index: Integer);
var ComponentEditor: IComponentEditor;
    designer: IDesigner;
begin
  try
    with GetComponent as TADOQueryMX do
    begin
      ComponentEditor := GetComponentEditor(FSelectQuery, nil);
      designer := ComponentEditor.GetDesigner;
      if designer = nil then
      begin
        ShowMessage('ComponentEditor designer is nil');
        Exit;
      end;

      if ComponentEditor <> nil then
        //ComponentEditor.Edit
        ComponentEditor.ExecuteVerb(0)
      else
        ShowMessage('ComponentEditor');

      (*if FSelectQuery.Designer <> nil then
        (FSelectQuery.Designer as TDSDesigner).FieldsEditor.Show
      else
        ShowMessage('No Designer');*)
    end;
  except
    on e: exception do
      ShowMessage(e.Message);
  end;
end;

function TADOMXConnectionEditor.GetVerb(Index: Integer): string;
begin
  Result := 'Edit Fields...';//SADOConnectionEditor;
end;

function TADOMXConnectionEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;}

constructor TADOQueryMX.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //FConnection := nil;
  (*FSelectQuery := TADOQuery.Create(Self);
  FSelectQuery.Name := 'SelectQuery';
  FSelectQuery.SetSubComponent(true);*)

  //ShowFieldsEditor(FSelectQuery.Designer)

  FInsertQuery := TADOQuery.Create(Self);
  FInsertQuery.Name := 'InsertQuery';
  FInsertQuery.SetSubComponent(true);

  FDeleteQuery := TADOQuery.Create(Self);
  FDeleteQuery.Name := 'DeleteQuery';
  FDeleteQuery.SetSubComponent(true);

  FUpdateQuery := TADOQuery.Create(Self);
  FUpdateQuery.Name := 'UpdateQuery';
  FUpdateQuery.SetSubComponent(true);
end;

destructor TADOQueryMX.Destroy;
begin
  //FSelectQuery := nil;
  //FConnection := nil;
  FreeAndNil(FInsertQuery);
  FreeAndNil(FDeleteQuery);
  FreeAndNil(FUpdateQuery);
  inherited Destroy;
end;

(*function TADOQueryMX.GetConnection: TADOConnection;
begin
  if Assigned(FConnection) then
    Result := FConnection
  else
    Result := nil;
end;*)

procedure TADOQueryMX.SetConnection(const Value: TADOConnection);
begin
  (*FConnection := Value;
  if Assigned(FSelectQuery) then
    FSelectQuery.Connection := Value;*)
  if Assigned(FInsertQuery) then
    FInsertQuery.Connection := Value;
  if Assigned(FDeleteQuery) then
    FDeleteQuery.Connection := Value;
  if Assigned(FUpdateQuery) then
    FUpdateQuery.Connection := Value;

  inherited;

  (*if FSelectQuery.Designer <> nil then
    (FSelectQuery.Designer as TDSDesigner).FieldsEditor.Show;*)
end;

procedure Register;
begin
  //RegisterComponentEditor(TADOQueryMX, TADOMXConnectionEditor);

  RegisterComponents('Samples', [TADOQueryMX]);
end;

end.
