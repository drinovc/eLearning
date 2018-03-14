(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

{** base class for picture support }
unit ExamplePictureSupport;

interface

uses
  SxInterfaces, SxTypes,
  SysUtils, Classes;

type
  (**
   * Picture conversion support adapter class.
   *)
  TPictureAdapter = class(TInterfacedObject, ISxPictureAdapter)
  private
    FImagePath: AnsiString;
    FOutStream: TStream;
    FDocName: AnsiString;
    FPicInfo: TPictureInformation;
    FPictNumber: Integer;
    function GetImagePath: AnsiString;
    function GetOutStream: TStream;
    procedure SetImagePath(const Value: AnsiString);
    procedure SetDocName(const Value: TFileName);
    procedure SetOutStream(const Value: TStream);
    function GetDocName: TFileName;
    procedure SetPictNumber(const Value: Integer);
    function GetPictNumber: Integer;
    function GetPicInfo: TPictureInformation;

  protected
    (** Picture file name. *)
    function PictureFile: TFileName;
    (** Default picture file extension. *)
    function DefaultPictExtension: AnsiString;

  public
    constructor Create;
    destructor Destroy; override;

    (**
     * Increment the picture number.
     * 1 = first picture in this document, 2 = second picture ...
     *)
    procedure IncPictNumber;

    (** Initialize the new picture. *)
    procedure Init; virtual; abstract;

    (** Add the next byte to the picture data buffer. *)
    procedure Write(const B: Byte); virtual; abstract;

    (** Clean up. *)
    procedure Finalize; virtual; abstract;

    (** Returns the picture code for the document. *)
    function PictureHTML: AnsiString; virtual;

    (** Current input document name. *)
    property DocName: TFileName read GetDocName write SetDocName;

    (** Output path. *)
    property ImagePath: AnsiString read GetImagePath write SetImagePath;

    (** Output stream. *)
    property OutStream: TStream read GetOutStream write SetOutStream;

    (** Picture sequence number. *)
    property PictNumber: Integer read GetPictNumber write SetPictNumber;

    (** Picture information structure. *)
    property PicInfo: TPictureInformation read GetPicInfo;

  end;

  (**
   * Empty picture converter
   *)
  TNullPictureAdapter = class(TPictureAdapter)
  public
    procedure Init; override;
    procedure Write(const B: Byte); override;
    procedure Finalize; override;
  end;

implementation

constructor TPictureAdapter.Create;
begin
  inherited;
  FPicinfo := TPictureInformation.Create;
end;

destructor TPictureAdapter.Destroy;
begin
  FPicinfo.Free;
  inherited;
end;

function TPictureAdapter.DefaultPictExtension;
begin
  Assert(Picinfo.PictureSource <> psUnknown);
  case Picinfo.PictureSource of
    psEMF: Result := '.emf';
    psPNG: Result := '.png';
    psJPEG: Result := '.jpg';
    psPICT: Result := '.pict';
    psWMF: Result := '.wmf';
  else
    Assert(False);
  end;
end;

function TPictureAdapter.PictureFile: TFileName;
begin
  if DocName = '' then
    Result := 'picture' + IntToStr(PictNumber) + DefaultPictExtension
  else
    Result := ExtractFileName(ChangeFileExt(DocName, '') + '_' +
      IntToStr(PictNumber)
      + DefaultPictExtension);
end;

function TPictureAdapter.PictureHTML;
begin
  Result := '<img src="' + ImagePath + PictureFile
    + '" height="' + IntToStr(PicInfo.HGoalPx)
    + '" width="' + IntToStr(PicInfo.WGoalPx) + '" alt="' + PictureFile +
    '" />';
end;

procedure TNullPictureAdapter.Init;
begin
  // nothing to do here
end;

procedure TNullPictureAdapter.Write(const B: Byte);
begin
  // nothing to do here
end;

procedure TNullPictureAdapter.Finalize;
begin
  // nothing to do here
end;

function TPictureAdapter.GetImagePath: AnsiString;
begin
  Result := FImagePath;
end;

function TPictureAdapter.GetOutStream: TStream;
begin
  Result := FOutStream;
end;

procedure TPictureAdapter.SetImagePath(const Value: AnsiString);
begin
  FImagePath := Value;
end;

procedure TPictureAdapter.SetDocName(const Value: TFileName);
begin
  FDocName := Value;
end;

procedure TPictureAdapter.SetOutStream(const Value: TStream);
begin
  FOutStream := Value;
end;

function TPictureAdapter.GetDocName: TFileName;
begin
  Result := FDocName;
end;

procedure TPictureAdapter.SetPictNumber(const Value: Integer);
begin
  FPictNumber := Value;
end;

function TPictureAdapter.GetPictNumber: Integer;
begin
  Result := FPictNumber;
end;

function TPictureAdapter.GetPicInfo: TPictureInformation;
begin
  Result := FPicInfo;
end;

procedure TPictureAdapter.IncPictNumber;
begin
  Inc(FPictNumber);
end;

end.

