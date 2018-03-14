(*
 ------------------------------------------------------------------------------

 ScroogeXHTML 5.0
 RTF to HTML / XHTML converter component for Delphi(r)

 Copyright (c) 1998-2010 Michael Justin
 http://www.mikejustin.com/
 ------------------------------------------------------------------------------
*)
					

{** example class for picture support }
unit ExamplePictureAdapter;

interface

uses
  ExamplePictureSupport;

type
  (**
   * A WMF graphic converter
   *)
  TWMFAdapter = class(TPictureAdapter)
    function PictureHTML: AnsiString; override;

  public
    procedure Init; override;
    procedure Write(const B: Byte); override;
    procedure Finalize; override;
  end;

implementation

uses
  SxTypes,
  PngImage, Graphics, Windows, SysUtils, Classes;

procedure TWMFAdapter.Init;

type
  TMetafileHeader = packed record
    Key: Longint;
    Handle: SmallInt;
    Box: TSmallRect;
    Inch: Word;
    Reserved: Longint;
    CheckSum: Word;
  end;

  function ComputeChecksum(var WMF: TMetafileHeader): Word;
  begin
    Result := 0;
    Result := Result xor Word(WMF.Key);
    Result := Result xor HiWord(WMF.Key);
    Result := Result xor Word(WMF.Handle);
    Result := Result xor Word(WMF.Box.Left);
    Result := Result xor Word(WMF.Box.Top);
    Result := Result xor Word(WMF.Box.Right);
    Result := Result xor Word(WMF.Box.Bottom);
    Result := Result xor WMF.Inch;
    Result := Result xor Word(WMF.Reserved);
    Result := Result xor HiWord(WMF.Reserved);
  end;

  procedure WriteHeader;
  var
    Header: TMetafileHeader;
  begin
    Header.Key := Integer($9AC6CDD7);
    Header.Box.Left := 0;
    Header.Box.Top := 0;
    Header.Inch := 96;
    Header.Box.Right := PicInfo.WGoalPx;
    Header.Box.Bottom := PicInfo.HGoalPx;
    Header.CheckSum := ComputeChecksum(Header);
    OutStream.Write(Header, SizeOf(Header));
  end;

begin
  OutStream := TMemoryStream.Create;
  WriteHeader;
end;

procedure TWMFAdapter.Write(const B: Byte);
begin
  if not Assigned(OutStream) then
    Init;

  if PicInfo.MappingMode <> MM_ANISOTROPIC then
    Exit;

  OutStream.Write(B, 1);
end;

procedure TWMFAdapter.Finalize;
var
  p: TMetafile;
  png: TPngImage;
begin
  OutStream.Seek(0, soBeginning);

  p := TMetafile.Create;
  try
    p.LoadFromStream(OutStream);
    png := TPngImage.CreateBlank(COLOR_RGB, 8, p.Width, p.Height);
    try
      png.Canvas.Draw(0, 0, p);
      png.SaveToFile(ImagePath + PictureFile + '.png');
    finally
      Png.Free;
    end;
  finally
    p.Free;
  end;

  OutStream.Free;
end;

function TWMFAdapter.PictureHTML;
begin
  Result := '<img src="file://' + ImagePath + PictureFile + '.png'
    + '" height="' + IntToStr(picinfo.HGoalPx)
    + '" width="' + IntToStr(picinfo.WGoalPx) + '" alt="picture"/>';
end;

end.

