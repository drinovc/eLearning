unit MXP_App_Lookups;

interface

uses
  SysUtils, Classes, DB, ADODB, MxADO;

type
  TLookups = class(TDataModule)
    TrainingProgramPageCategories: TADOQueryMX;
    ADOConnection1: TADOConnection;
    TrainingProgramCategories: TADOQueryMX;
    CoursesAndCertificates: TADOQueryMX;
    TrainingProgramStatus: TADOQueryMX;
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
