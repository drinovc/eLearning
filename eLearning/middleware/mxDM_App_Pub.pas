unit mxDM_App_Pub;

interface

uses
  Windows, SysUtils, Classes, DB, ADODB, MxADO, WideStrings, IdMessage, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase,
  IdMessageClient, IdSMTPBase, IdSMTP, IdHashMessageDigest, Variants, WideStrUtils,
  Graphics, Types, jpeg, IdCoderMIME, SuperObject, DateUtils, pngimage, EncdDecd,
  Math, StrUtils, Printers,

  XLSReadWriteII5, XLSComment5, XLSDrawing5, Xc12Utils5, Xc12DataStyleSheet5, XLSSheetData5,
  XLSCmdFormat5, XPMan, XLSFormattedObj5,

  ScroogeXHTML, SxMain, SxTypes,

  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdSASL,
  IdSASLUserPass, IdSASLPlain, Dialogs;

type
  TPub = class(TDataModule)
    ADOConnection1: TADOConnection;
    Login: TADOQueryMX;
    Info: TADOQueryMX;
    UserAccessRights: TADOQueryMX;
    _Library: TADOQueryMX;
    Programs: TADOQueryMX;
    Pages: TADOQueryMX;
    Questions: TADOQueryMX;
    PersonAnswers: TADOQueryMX;
    PersonPrograms: TADOQueryMX;
    function Download(const Params: TWideStrings; InStream: TMemoryStream; var ContentType: WideString): variant;
    function ResizeImage(var imageStream: TMemoryStream; maxWidth, maxHeight : Integer; Out width: Integer; Out height: Integer; const picType: String; const rotateDegrees: Integer = 0): boolean;
    function UploadImage(const Params: TWideStrings; InStream: TMemoryStream; var ContentType: WideString): variant;
    procedure RotateBitmap(Bmp: TBitmap; Rads: Single; AdjustSize: Boolean; BkColor: TColor = clNone);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure AutoCropBitmap(InputBitmap, OutputBitmap: TBitmap; iBleeding : Integer); overload;
  procedure AutoCropBitmap(InputBitmap, OutputBitmap: TBitmap; iBleeding : Integer; BackColor: TColor); overload;
  procedure AutoCropBitmap(BitMapToCrop: TBitmap; iBleeding : Integer); overload;
  procedure AutoCropBitmap(BitMapToCrop: TBitmap; iBleeding : Integer; BackColor: TColor); overload;
var
  Pub: TPub;

implementation

{$R *.dfm}

uses mxDataRequest, mxDataADO, mxDataCommon, mxDataMXPLogin;

function TPub.Download(const Params: TWideStrings; InStream: TMemoryStream; var ContentType: WideString): variant;
var dcid, did : integer;
    dm: TDataModule;
    component: TComponent;
    maxWidth, maxHeight, width, height: Integer;
    subtype: WideString;
    query: TADOQueryMX;
begin
  result := resultFailed('');
  subtype := '';
  try
    maxWidth := 10000;
    maxHeight := 10000;

    if(Params.values['MaxWidth'] <> '') or (Params.values['MaxHeight'] <> '') then
    begin
      if(Params.values['MaxWidth'] <> '') then
      begin
        maxWidth := StrToInt(Params.values['MaxWidth']);
      end;
      if(Params.values['MaxHeight'] <> '') then
      begin
        maxHeight := StrToInt(Params.values['MaxHeight']);
      end;
    end;

    if(Params.values['type'] = 'library') then
    begin
      query := _Library;
    end;

    ProcessParameters(Params, query, nil);
    query.Connection := GetConnection(query.Connection);
    try
      query.Open;
      if not query.eof then
      begin
        InStream.Clear;
        LoadFromBlob(query.Fields[0], InStream);
        subtype := GetImageSubContentType(query.Fields[1].AsString);
        if(maxWidth <> 10000) or (maxHeight <> 10000) then
        begin
           ResizeImage(InStream, maxWidth, maxHeight, width, height, '');
        end;
        result := '#image' + subtype + '{"success": true}';
      end
      else
      begin
        result := resultFailed('No image');
      end;
    finally
      ReleaseConnection(query.Connection);
    end;

  except
    on e : Exception do begin
      result := resultFailed(e.Message);
      LogHttp(e, 'DownloadDocument TourImage ERROR');
    end;
  end;
end;

procedure AutoCropBitmap(InputBitmap, OutputBitmap: TBitmap; iBleeding : Integer; BackColor: TColor);
const
  PixelCountMax = 32768;

type
  pRGBArray = ^TRGBArray;
  TRGBArray = array[0..PixelCountMax-1] of TRGBTriple;

var Row                      : pRGBArray;
    MyTop, MyBottom, MyLeft,
    i, j, MyRight            : Integer;
begin
  MyTop      := InputBitmap.Height;
  MyLeft     := InputBitmap.Width;
  MyBottom   := 0;
  MyRight    := 0;
  InputBitmap.PixelFormat := pf24bit;
  OutputBitmap.PixelFormat := pf24Bit;
  { Find Top }
  for j := 0 to InputBitmap.Height-1 do
  begin
    if j > MyTop then
      Break;
    Row := pRGBArray(InputBitmap.Scanline[j]);
    for i:= InputBitmap.Width - 1 downto 0 do
      if ((Row[i].rgbtRed   <> GetRvalue(BackColor)) or
          (Row[i].rgbtGreen <> GetGvalue(BackColor)) or
          (Row[i].rgbtBlue  <> GetBvalue(BackColor))) then
      begin
        MyTop := j;
        Break;
      end;
  end;
  if MyTop = InputBitmap.Height then
  { Empty Bitmap }
    MyTop := 0;

  { Find Bottom }
  for j := InputBitmap.Height-1 Downto MyTop do
  begin
    if (j + 1) < MyBottom then
      Break;
    Row := pRGBArray(InputBitmap.Scanline[j]);
    for i:= InputBitmap.Width - 1 downto 0  do
      if ((Row[i].rgbtRed   <> GetRvalue(BackColor)) or
          (Row[i].rgbtGreen <> GetGvalue(BackColor)) or
          (Row[i].rgbtBlue  <> GetBvalue(BackColor))) then
      begin
        MyBottom := j+1;
        Break;
      end;
  end;

  { Find Left }
  for j := MyTop to MyBottom-1 do
  begin
    Row := pRGBArray(InputBitmap.Scanline[j]);
    for i:= 0 to MyLeft-1 do
      if ((Row[i].rgbtRed   <> GetRvalue(BackColor)) or
          (Row[i].rgbtGreen <> GetGvalue(BackColor)) or
          (Row[i].rgbtBlue  <> GetBvalue(BackColor))) then
      begin
        MyLeft := i;
        Break;
      end;
  end;
  if MyLeft = InputBitmap.Width then
  { Empty Bitmap }
    MyLeft := 0;

  { Find Right }
  for j := MyTop to MyBottom -1 do
  begin
    Row := pRGBArray(InputBitmap.Scanline[j]);
    for i:= InputBitmap.Width-1 downto MyRight do
      if ((Row[i].rgbtRed   <> GetRvalue(BackColor)) or
          (Row[i].rgbtGreen <> GetGvalue(BackColor)) or
          (Row[i].rgbtBlue  <> GetBvalue(BackColor))) then
      begin
        MyRight := i+1;
        Break;
      end;
  end;
  if (MyRight = 0) or (MyBottom = 0) then
  { Empty Bitmap }
    iBleeding := 0;

  OutputBitmap.Width  := MyRight - MyLeft + (iBleeding * 2);
  OutputBitmap.Height := MyBottom - MyTop + (iBleeding * 2);
  OutputBitmap.Canvas.Brush.Color := BackColor;
  OutputBitmap.Canvas.FillRect(Rect(0,0,OutputBitmap.Width,OutputBitmap.Height));

  BitBlt(OutputBitmap.canvas.Handle, -MyLeft + iBleeding,
         -MyTop + iBleeding,MyLeft + MyRight,MyTop + MyBottom,
         InputBitmap.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure AutoCropBitmap(BitMapToCrop: TBitmap; iBleeding : Integer);
var bmpTmp : TBitmap;
begin
  bmpTmp := TBitmap.Create;
  try
    AutoCropBitmap(BitMapToCrop,bmpTmp,iBleeding);
    BitMapToCrop.Assign(bmpTmp);
  finally
    bmpTmp.Free;
  end;
end;

procedure AutoCropBitmap(BitMapToCrop: TBitmap; iBleeding : Integer; BackColor: TColor);
var bmpTmp : TBitmap;
begin
  bmpTmp := TBitmap.Create;
  try
    AutoCropBitmap(BitMapToCrop,bmpTmp,iBleeding, BackColor);
    BitMapToCrop.Assign(bmpTmp);
  finally
    bmpTmp.Free;
  end;
end;

procedure AutoCropBitmap(InputBitmap, OutputBitmap: TBitmap; iBleeding : Integer);
begin
  AutoCropBitmap(InputBitmap,OutputBitmap, iBleeding, InputBitmap.Canvas.Pixels[0,0]);
end;

function TPub.ResizeImage(var imageStream: TMemoryStream; maxWidth, maxHeight : Integer; Out width: Integer; Out height: Integer; const picType: String; const rotateDegrees: Integer = 0): boolean;
var image: TWICImage;
    bmp, bmp2: TBitmap;
    StretchMode: Integer;
    scale, scaleX, scaleY: Double;
    jpgout: TJpegImage;
    png: TPngImage;
    //origRotation: Byte;
begin
    image:= TWICImage.Create;
    bmp := TBitmap.Create;
    bmp2 := TBitmap.Create;
  try
    try
      image.LoadFromStream(imageStream);

      //origRotation := (PByte(imageStream.Memory) + 66)^;

//      if (rotateDegrees <> 0) then
//      begin
//          maxWidth := Min(Max(image.Width, image.Height), Max(maxWidth, maxHeight));
//          maxHeight := maxWidth;
//      end;

//      if (image.Height >= maxHeight) or (image.Width >= maxWidth) then
//      begin

        if (image.Height < maxHeight) and (image.Width < maxWidth) then
        begin
          maxWidth := image.Width;
          maxHeight := image.Height;
        end;

        bmp.SetSize(image.Width, image.Height);
        bmp.Canvas.StretchDraw(bmp.Canvas.ClipRect, image);

        scaleX := maxWidth / bmp.Width;
        scaleY := maxHeight / bmp.Height;
        scale := Min(scaleX, scaleY);

        bmp2.SetSize(Round(bmp.Width * scale), Round(bmp.Height * scale));
        StretchMode := SetStretchBltMode(bmp2.Canvas.Handle, HALFTONE);
        StretchBlt(bmp2.Canvas.Handle, 0, 0, bmp2.Width, bmp2.Height, bmp.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, SRCCOPY);
        SetStretchBltMode(bmp2.Canvas.Handle, StretchMode);

        if(rotateDegrees <> 0) then
        begin
          RotateBitmap(bmp2, DegToRad(rotateDegrees), true, clWhite);
        end;

        if imageStream = nil then
          imageStream := TMemoryStream.Create
        else
          imageStream.Clear;

        if (picType = 'jpg') then
        begin
          jpgout := TJpegImage.Create;
          jpgout.Assign(bmp2);
          jpgout.CompressionQuality := 60;
          jpgout.SaveToStream(imageStream);
          //jpgout.SaveToFile('.\OutputImage.jpg');
          jpgout.Free;
        end else if (picType = 'png') then
        begin
          png := TPngImage.Create;
          png.Assign(bmp2);
          png.SaveToStream(imageStream);
          //png.SaveToFile('.\OutputImage.png');
          png.Free;
        end else
        begin
          bmp2.SaveToStream(imageStream);
        end;

        width := bmp2.Width;
        height := bmp2.Height;

        result := true;
//      end
//      else
//      begin
//        width := image.Width;
//        height := image.Height;
//        result := true;
//        //resultStream := imageStream.LoadFromStream(imageStream);
//        //result := imageStream;
//      end;
    except
      on e : Exception do begin
        result := false;
        LogHttp(e, 'Upload Image - NOT IMAGE FILE ERROR');
      end;
    end;
  finally
      image.Free;
      bmp.Free;
      bmp2.Free;
  end;
end;

function TPub.UploadImage(const Params: TWideStrings; InStream: TMemoryStream; var ContentType: WideString): variant;
var dcid, did : integer;
    dm: TDataModule;
    nbrows: integer;
    component: TComponent;
    jRes: ISuperObject;
    width, height, rotate: Integer;
    imgRes: boolean;
    query: TADOQueryMX;
begin
  result := resultFailed('');
  jRes := TSuperObject.Create;

  try
    rotate := 0;
    if (Params.values['rotate'] <> '') then
    begin
      rotate := StrToInt(Params.values['rotate']);
    end;

    imgRes := ResizeImage(InStream, 1600, 1600, width, height, 'jpg', rotate);
    if imgRes = false then
    begin
      result := resultFailed('Invalid image');
    end
    else
    begin

    if not ((AnsiEndsStr('.JPG', UpperCase(Params.values['_FILE_NAME']))) or (AnsiEndsStr('.JPEG', UpperCase(Params.values['_FILE_NAME'])))) then
    begin
      Params.values['_FILE_NAME'] := Params.values['_FILE_NAME'] + '.jpg'
    end;
        
    if (Params.values['type'] = 'library') then
    begin
      query := _Library;
    end;

    try
      ProcessParameters(Params, query.InsertQuery, InStream);
      query.Connection := GetConnection(query.Connection);
      try
        query.InsertQuery.Open;
        if not query.InsertQuery.EOF then
        begin
          result := '{"success": true, "id": ' + IntToStr(query.InsertQuery.Fields[0].Value) + ' }';
        end else
        begin
          result := resultFailed('No image id returned');
        end;
      except
      on e : Exception do
      begin
          result := resultFailed(e.Message);
          LogHttp(e, 'Upload Maintenance Image ERROR');
      end;
    end;
    finally
      ReleaseConnection(query.Connection);
    end;
  end;
  finally
    //
  end;
end;

procedure TPub.RotateBitmap(Bmp: TBitmap; Rads: Single; AdjustSize: Boolean;
  BkColor: TColor = clNone);
var
  C: Single;
  S: Single;
  Tmp: TBitmap;
  OffsetX: Single;
  OffsetY: Single;
  Points: array[0..2] of TPoint;
begin
  C := Cos(Rads);
  S := Sin(Rads);
  Tmp := TBitmap.Create;
  try
    Tmp.TransparentColor := Bmp.TransparentColor;
    Tmp.TransparentMode := Bmp.TransparentMode;
    Tmp.Transparent := Bmp.Transparent;
    Tmp.Canvas.Brush.Color := BkColor;
    if AdjustSize then
    begin
      Tmp.Width := Round(Bmp.Width * Abs(C) + Bmp.Height * Abs(S));
      Tmp.Height := Round(Bmp.Width * Abs(S) + Bmp.Height * Abs(C));
      OffsetX := (Tmp.Width - Bmp.Width * C + Bmp.Height * S) / 2;
      OffsetY := (Tmp.Height - Bmp.Width * S - Bmp.Height * C) / 2;
    end
    else
    begin
      Tmp.Width := Bmp.Width;
      Tmp.Height := Bmp.Height;
      OffsetX := (Bmp.Width - Bmp.Width * C + Bmp.Height * S) / 2;
      OffsetY := (Bmp.Height - Bmp.Width * S - Bmp.Height * C) / 2;
    end;
    Points[0].X := Round(OffsetX);
    Points[0].Y := Round(OffsetY);
    Points[1].X := Round(OffsetX + Bmp.Width * C);
    Points[1].Y := Round(OffsetY + Bmp.Width * S);
    Points[2].X := Round(OffsetX - Bmp.Height * S);
    Points[2].Y := Round(OffsetY + Bmp.Height * C);
    PlgBlt(Tmp.Canvas.Handle, Points, Bmp.Canvas.Handle, 0, 0, Bmp.Width,
      Bmp.Height, 0, 0, 0);
    Bmp.Assign(Tmp);
  finally
    Tmp.Free;
  end;
end;

initialization
  RegisterClass(TPub);

end.
