unit MXP_App_Lookups;

interface

uses
  SysUtils, Classes, DB, ADODB, MxADO;

type
  TLookups = class(TDataModule)
    ProgramPageCategories: TADOQueryMX;
    ADOConnection1: TADOConnection;
    ProgramCategories: TADOQueryMX;
    CoursesAndCertificates: TADOQueryMX;
    ProgramStatuses: TADOQueryMX;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Lookups: TLookups;

implementation

{$R *.dfm}

initialization
  RegisterClass(TLookups);

end.
