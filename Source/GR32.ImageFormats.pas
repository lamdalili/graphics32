unit GR32.ImageFormats;

(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1 or LGPL 2.1 with linking exception
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * Alternatively, the contents of this file may be used under the terms of the
 * Free Pascal modified version of the GNU Lesser General Public License
 * Version 2.1 (the "FPC modified LGPL License"), in which case the provisions
 * of this license are applicable instead of those above.
 * Please see the file LICENSE.txt for additional information concerning this
 * license.
 *
 * The Original Code is Image Format support for Graphics32
 *
 * The Initial Developer of the Original Code is
 * Anders Melander <anders@melander.dk>
 *
 * Portions created by the Initial Developer are Copyright (C) 2008-2022
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

interface

{$include GR32.inc}

uses
  Classes,
{$ifdef FPC}
  Graphics,
  LCLType,
{$endif FPC}
  Generics.Defaults,
  Generics.Collections,
  GR32;

{$ifndef FPC}
{$define ANONYMOUS_METHODS}
{$endif FPC}

(*******************************************************************************
**
**              Interfaces implemented by the individual image formats
**
*******************************************************************************)

//------------------------------------------------------------------------------
//
//      IImageFormat
//
//------------------------------------------------------------------------------
type
  IImageFormat = interface
    ['{E457B520-80B3-403D-8658-4C9ADAF3A7A0}']
  end;

//------------------------------------------------------------------------------
//
//      IImageFormatAdapter
//
//------------------------------------------------------------------------------
// Handles Assign/AssignTo between TBitmap32 and other formats.
//------------------------------------------------------------------------------
type
  IImageFormatAdapter = interface
    ['{5C4DC69F-F3A0-4265-A855-495CF54AB808}']
    // Copy from image format
    function CanAssignFrom(Source: TPersistent): boolean;
    function AssignFrom(Dest: TCustomBitmap32; Source: TPersistent): boolean;

    // Copy to image format
    function CanAssignTo(Dest: TPersistent): boolean;
    function AssignTo(Source: TCustomBitmap32; Dest: TPersistent): boolean;
  end;


//------------------------------------------------------------------------------
//
//      IImageFormatFileInfo
//
//------------------------------------------------------------------------------
// File related image format info.
//------------------------------------------------------------------------------
type
  TFileTypes = array of string;

  IImageFormatFileInfo = interface
    ['{EC7037E2-DE93-43A8-AD5D-7BDD91E59E04}']
    function ImageFormatDescription: string;
    function ImageFormatFileTypes: TFileTypes;
  end;


//------------------------------------------------------------------------------
//
//      IImageFormatClipboardFormat
//
//------------------------------------------------------------------------------
// Reads data from the clipboard.
//------------------------------------------------------------------------------
// When data is read from the clipboard, we iterate all image formats that
// IImageFormatClipboardFormat; We first try calling PasteFromClipboard on the
// image format and if that isn't sucessful, we then iterate the available
// clipboard formats and call LoadFromClipboardFormat on each in turn.
// If both of the above methods return False, we fall back to using the
// IImageFormatReader interface to try and read the data.
//------------------------------------------------------------------------------
type
{$ifdef FPC}
  TClipboardFormat = LCLType.TClipboardFormat;
{$else FPC}
  TClipboardFormat = Word;
{$endif FPC}

  IImageFormatClipboardFormat = interface
    ['{E5550CCE-5D78-46C7-8714-11E0CF44561B}']
    function SupportsClipboardFormat(AFormat: TClipboardFormat): Boolean;
    function PasteFromClipboard(ADest: TCustomBitmap32): boolean;
    function LoadFromClipboardFormat(ADest: TCustomBitmap32; AFormat: TClipboardFormat; AData: THandle; APalette: THandle): boolean;
  end;


//------------------------------------------------------------------------------
//
//      IImageFormatReader
//
//------------------------------------------------------------------------------
// Reads from an image format into TBitmap32.
//------------------------------------------------------------------------------
type
  IImageFormatReader = interface
    ['{D90E2FCD-65ED-4A1B-8A13-2D25618F7EE7}']
    function CanLoadFromStream(AStream: TStream): boolean;
    function LoadFromStream(ADest: TCustomBitmap32; AStream: TStream): boolean;
  end;


//------------------------------------------------------------------------------
//
//      IImageFormatFileReader
//
//------------------------------------------------------------------------------
// Reads from an image format into TBitmap32.
// The Filename parameter should be used to determine the image format.
//------------------------------------------------------------------------------
type
  IImageFormatFileReader = interface
    ['{F255F49D-E49A-47CE-AC7A-485FC5A4B2CE}']
    function LoadFromFile(ADest: TCustomBitmap32; const AFilename: string): boolean;
  end;


//------------------------------------------------------------------------------
//
//      IImageFormatResourceReader
//
//------------------------------------------------------------------------------
// Reads from an image format into TBitmap32.
// The ResourceType and Stream parameters should be used to determine the image
// format.
//------------------------------------------------------------------------------
type
  IImageFormatResourceReader = interface
    ['{7DB70759-6079-4C5D-96FB-55905BE9FBEC}']
    function LoadFromResource(ADest: TCustomBitmap32; AResourceType: PChar; AStream: TStream): boolean;
  end;


//------------------------------------------------------------------------------
//
//      IImageFormatWriter
//
//------------------------------------------------------------------------------
// Writes TBitmap32 as an image format.
//------------------------------------------------------------------------------
type
  IImageFormatWriter = interface
    ['{78358E48-60E3-4119-88D1-CB0CFADEE5CF}']
    procedure SaveToStream(ASource: TCustomBitmap32; AStream: TStream);
  end;


(*******************************************************************************
**
**              Interfaces implemented by the Image Format Manager
**
*******************************************************************************)

//------------------------------------------------------------------------------
//
//      IImageFormatClipboardFormats
//
//------------------------------------------------------------------------------
// Perform clipboard related stuff on all the registered image format adapters.
//------------------------------------------------------------------------------
type
  IImageFormatClipboardFormats = interface
    ['{EC307484-A5D2-455D-AD4A-D96263A8E775}']
    function SupportsClipboardFormat(AFormat: TClipboardFormat): Boolean;
    function CanPasteFromClipboard: boolean;
    function PasteFromClipboard(ADest: TCustomBitmap32): boolean;
  end;


//------------------------------------------------------------------------------
//
//      IImageFormatReaders
//
//------------------------------------------------------------------------------
// List of IImageFormatReader.
//------------------------------------------------------------------------------
type
  IImageFormatReaders = interface
    ['{1D2B1F37-D85E-4E6F-BFEC-7C8CC02B4B9B}']
    function FindReader(const AFileType: string): IImageFormatReader; overload;
    function FindReader(AStream: TStream): IImageFormatReader; overload;
    function CanLoadFromStream(AStream: TStream): boolean;
    function LoadFromStream(ADest: TCustomBitmap32; AStream: TStream): boolean; overload;
    // Note: LoadFromStream(...AFilename) only uses readers that implement both
    // IImageFormatReader and IImageFormatFileInfo.
    // The file extension of the Filename parameter must match one of the values
    // in IImageFormatFileInfo.ImageFormatFileTypes.
    function LoadFromStream(ADest: TCustomBitmap32; AStream: TStream; const AFilename: string): boolean; overload;
    // Note: LoadFromFile only uses readers that implement IImageFormatFileReader
    // it does not fall back to IImageFormatReader.LoadFromStream
    function LoadFromFile(ADest: TCustomBitmap32; const AFilename: string): boolean;
    function LoadFromResource(ADest: TCustomBitmap32; AResourceType: TResourceType; AStream: TStream): boolean;
  end;


//------------------------------------------------------------------------------
//
//      IImageFormatWriters
//
//------------------------------------------------------------------------------
// List of IImageFormatWriter.
//------------------------------------------------------------------------------
type
  IImageFormatWriters = interface
    ['{5D09FAA7-7A7F-4A7B-BFA0-1D9C16DA6444}']
    function FindWriter(const AFileType: string): IImageFormatWriter;
  end;


//------------------------------------------------------------------------------
//
//      IImageFormatManager
//
//------------------------------------------------------------------------------
const
  ImageFormatPriorityWorst      = 2000;
  ImageFormatPriorityWorse      = 1000;
  ImageFormatPriorityNormal     = 0;
  ImageFormatPriorityBetter     = -1000;
  ImageFormatPriorityBest       = -2000;

type
  IImageFormatEnumerator = interface
    function GetCurrent: IImageFormat;
    function MoveNext: Boolean;
    property Current: IImageFormat read GetCurrent;
  end;

  IImageFormats = interface
    function GetEnumerator: IImageFormatEnumerator;
  end;

  IImageFormatManager = interface
    ['{91478233-7F42-4F47-AF1B-0F27D6912CC7}']
    procedure RegisterImageFormat(const AImageFormat: IImageFormat; APriority: integer = ImageFormatPriorityNormal);

    function ImageFormats: IImageFormats; overload;
    function ImageFormats(Intf: TGUID): IImageFormats; overload;

    function GetAdapters: IImageFormatAdapter;
    property Adapters: IImageFormatAdapter read GetAdapters;

    function GetReaders: IImageFormatReaders;
    property Readers: IImageFormatReaders read GetReaders;

    function GetWriters: IImageFormatWriters;
    property Writers: IImageFormatWriters read GetWriters;

    function GetClipboardFormats: IImageFormatClipboardFormats;
    property ClipboardFormats: IImageFormatClipboardFormats read GetClipboardFormats;

    function BuildFileFilter(Intf: TGUID; IncludeAll: boolean = False): string;
  end;


//------------------------------------------------------------------------------
//
//      TCustomImageFormat
//
//------------------------------------------------------------------------------
// Example, abstract base class for implementation of IImageFormat
//------------------------------------------------------------------------------
type
  TCustomImageFormat = class abstract(TInterfacedObject, IImageFormat)
  end;


//------------------------------------------------------------------------------
//
//      TCustomImageFormatAdapter
//
//------------------------------------------------------------------------------
// Example, abstract base class for implementation of IImageFormatAdapter
//------------------------------------------------------------------------------
type
  TCustomImageFormatAdapter = class abstract(TCustomImageFormat, IImageFormatAdapter)
  strict protected
    // IImageFormatAdapter
    function CanAssignFrom(Source: TPersistent): boolean; virtual;
    function AssignFrom(Dest: TCustomBitmap32; Source: TPersistent): boolean; virtual;
    function CanAssignTo(Dest: TPersistent): boolean; virtual;
    function AssignTo(Source: TCustomBitmap32; Dest: TPersistent): boolean; virtual;
  end;


//------------------------------------------------------------------------------
//
//      ImageFormatManager
//
//------------------------------------------------------------------------------
// Main entry point for the image format manager.
//------------------------------------------------------------------------------
function ImageFormatManager: IImageFormatManager;


//------------------------------------------------------------------------------
//
//      File signature utilities
//
//------------------------------------------------------------------------------
function CheckFileSignature(Stream: TStream; const Signature, Mask: AnsiString; Offset: int64 = 0): boolean; overload;
function CheckFileSignature(Stream: TStream; const Signature: AnsiString; Offset: int64 = 0): boolean; overload;

function CheckFileSignature(Stream: TStream; const Signature; Size: Cardinal; const Mask; MaskSize: Cardinal; Offset: int64 = 0): boolean; overload;
function CheckFileSignature(Stream: TStream; const Signature; Size: Cardinal; Offset: int64): boolean; overload;

function CheckFileSignatureWide(Stream: TStream; const Signature: UnicodeString; Offset: int64 = 0): boolean;

// Unicode string: For each WideChar in the string, lower byte contains value, upper byte contains mask
function CheckFileSignatureComposite(Stream: TStream; const Signature: UnicodeString; Offset: int64 = 0): boolean;

//------------------------------------------------------------------------------

resourcestring
  sUnknownImageFormat = 'Unknown image format';


//------------------------------------------------------------------------------
//
//      FPC compatibility
//
//------------------------------------------------------------------------------
{$ifdef FPC}
type
  TGraphicHelper = class helper for TGraphic
    class function CanLoadFromStream(Stream: TStream): Boolean;
  end;
{$endif FPC}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
{$ifndef FPC}
  Consts,
  IOUtils,
{$endif FPC}
  ClipBrd,
  Windows,
  SysUtils,
  GR32_Clipboard;

//------------------------------------------------------------------------------
//
//      FPC compatibility
//
//------------------------------------------------------------------------------
{$ifdef FPC}
resourcestring
  sAllFilter = 'All';


type
  EClipboardException = Exception;

type
  TPath = class
  public
    class function GetExtension(const APath: string): string; static;
  end;

class function TPath.GetExtension(const APath: string): string;
begin
  Result := ExtractFileExt(APath);
end;

class function TGraphicHelper.CanLoadFromStream(Stream: TStream): Boolean;
begin
  Result := IsStreamFormatSupported(Stream);
end;
{$endif FPC}

//------------------------------------------------------------------------------
//
//      File signature utilities
//
//------------------------------------------------------------------------------
function CheckFileSignature(Stream: TStream; const Signature; Size: Cardinal; const Mask; MaskSize: Cardinal; Offset: int64): boolean; overload;
var
  Buffer: TBytes;
  Count: Cardinal;
  SavePos: int64;
  BufferByte, SigByte, MaskByte: PByte;
begin
  ASSERT(Size >= MaskSize);
  ASSERT(Size > 0);

  SetLength(Buffer, Size);

  SavePos := Stream.Position;
  try
    Stream.Position := Offset;

    if (Stream.Read(Buffer[0], Size) = Int64(Size)) then
    begin
      Result := True;
      BufferByte := @Buffer[0];
      SigByte := PByte(@Signature);
      MaskByte := PByte(@Mask);
      Count := 1;
      while (Result) and (Count <= Size) do
      begin
        if (Count <= MaskSize) then
          Result := ((BufferByte^ and MaskByte^) = (SigByte^ and MaskByte^))
        else
          Result := (BufferByte^ = SigByte^);
        inc(Count);
        inc(BufferByte);
        inc(SigByte);
        inc(MaskByte);
      end;
    end else
      Result := False;

  finally
    Stream.Position := SavePos;
  end;
end;

function CheckFileSignature(Stream: TStream; const Signature; Size: Cardinal; Offset: int64): boolean;
begin
  Result := CheckFileSignature(Stream, Signature, Size, nil^, 0, Offset);
end;

function CheckFileSignature(Stream: TStream; const Signature, Mask: AnsiString; Offset: int64): boolean;
begin
  Result := CheckFileSignature(Stream, Signature[1], Length(Signature), Mask[1], Length(Mask), Offset);
end;

function CheckFileSignature(Stream: TStream; const Signature: AnsiString; Offset: int64): boolean;
begin
  Result := CheckFileSignature(Stream, Signature[1], Length(Signature), Offset);
end;

function CheckFileSignatureWide(Stream: TStream; const Signature: UnicodeString; Offset: int64): boolean;
begin
  Result := CheckFileSignature(Stream, Signature[1], Length(Signature)*SizeOf(WideChar), nil^, 0, Offset);
end;

function CheckFileSignatureComposite(Stream: TStream; const Signature: UnicodeString; Offset: int64 = 0): boolean;
var
  Values: AnsiString;
  Mask: AnsiString;
  i: integer;
  p: PAnsiChar;
begin
  SetLength(Values, Length(Signature));
  SetLength(Mask, Length(Signature));
  p := @(Signature[1]);
  for i := 1 to Length(Signature) do
  begin
    Values[i] := p^;
    inc(p);
    Mask[i] := p^;
    inc(p);
  end;
  Result := CheckFileSignature(Stream, Values, Mask, Offset);
end;

//------------------------------------------------------------------------------
//
//      TCustomImageFormatAdapter
//
//------------------------------------------------------------------------------
function TCustomImageFormatAdapter.CanAssignFrom(Source: TPersistent): boolean;
begin
  Result := False;
end;

function TCustomImageFormatAdapter.AssignFrom(Dest: TCustomBitmap32; Source: TPersistent): boolean;
begin
  if (CanAssignFrom(Source)) then
  begin
    Dest.Assign(Source);
    Result := True;
  end else
    Result := False;
end;

//------------------------------------------------------------------------------

function TCustomImageFormatAdapter.CanAssignTo(Dest: TPersistent): boolean;
begin
  Result := False;
end;

function TCustomImageFormatAdapter.AssignTo(Source: TCustomBitmap32; Dest: TPersistent): boolean;
begin
  if (CanAssignTo(Dest)) then
  begin
    Dest.Assign(Source);
    Result := True;
  end else
    Result := False;
end;

//------------------------------------------------------------------------------
//
//      TImageFormatManager
//
//------------------------------------------------------------------------------
// Implements IImageFormatManager.
//------------------------------------------------------------------------------
type
  TImageFormatManager = class(TInterfacedObject, IImageFormatManager,
    IImageFormatAdapter,
    IImageFormatReaders,
    IImageFormatWriters,
    IImageFormatClipboardFormats)
{$ifdef ANONYMOUS_METHODS}
  strict private type
{$else ANONYMOUS_METHODS}
  private type
{$endif ANONYMOUS_METHODS}
    TImageFormatItem = record
      Priority: integer;
      ImageFormat: IImageFormat;
    end;

{$ifdef FPC}
    // FPC's TList<T>.BinarySearch doesn't return insertion point and doesn't handle search in empty list...
    TImageFormatList = class(TList<TImageFormatItem>)
    private
      FComparer: IComparer<TImageFormatItem>;
    public
      constructor Create(const AComparer: IComparer<TImageFormatItem>);
      function BinarySearch(const Item: TImageFormatItem; out FoundIndex: Integer): Boolean;
    end;
{$else FPC}
    TImageFormatList = TList<TImageFormatItem>;
{$endif FPC}

    TImageFormatEnumerator = class(TInterfacedObject, IImageFormats, IImageFormatEnumerator)
    private
      FList: TImageFormatList;
      FGUID: TGUID;
      FIndex: Integer;
    private
      // IImageFormats
      function GetEnumerator: IImageFormatEnumerator;
      // IImageFormatEnumerator
      function GetCurrent: IImageFormat;
      function MoveNext: Boolean;
    public
      constructor Create(AList: TImageFormatList; const AGUID: TGUID);
    end;

  strict private
    // List of image format, ordered by priority
    FFormats: TImageFormatList;
  private
    // IImageFormatManager
    procedure RegisterImageFormat(const AImageFormat: IImageFormat; APriority: integer = 0);
    function ImageFormats: IImageFormats; overload;
    function ImageFormats(Intf: TGUID): IImageFormats; overload;
    function GetAdapters: IImageFormatAdapter;
    function GetReaders: IImageFormatReaders;
    function GetWriters: IImageFormatWriters;
    function GetClipboardFormats: IImageFormatClipboardFormats;
    function BuildFileFilter(Intf: TGUID; IncludeAll: boolean): string;
  private
    // IImageFormatAdapter
    function CanAssignFrom(Source: TPersistent): boolean;
    function AssignFrom(Dest: TCustomBitmap32; Source: TPersistent): boolean;
    function CanAssignTo(Dest: TPersistent): boolean;
    function AssignTo(Source: TCustomBitmap32; Dest: TPersistent): boolean;
  private
    // IImageFormatReaders
    function FindReader(const AFileType: string): IImageFormatReader; overload;
    function FindReader(AStream: TStream): IImageFormatReader; overload;
    function CanLoadFromStream(AStream: TStream): boolean;
    function LoadFromStream(ADest: TCustomBitmap32; AStream: TStream): boolean; overload;
    function LoadFromStream(ADest: TCustomBitmap32; AStream: TStream; const AFilename: string): boolean; overload;
    function LoadFromFile(ADest: TCustomBitmap32; const AFilename: string): boolean;
    function LoadFromResource(ADest: TCustomBitmap32; AResourceType: TResourceType; AStream: TStream): boolean;
  private
    // IImageFormatWriters
    function FindWriter(const AFileType: string): IImageFormatWriter;
  private
    // IImageFormatClipboardFormats
    function SupportsClipboardFormat(AFormat: TClipboardFormat): Boolean;
    function CanPasteFromClipboard: boolean;
    function PasteFromClipboard(ADest: TCustomBitmap32): boolean;
  public
    destructor Destroy; override;
  end;

//------------------------------------------------------------------------------

destructor TImageFormatManager.Destroy;
begin
  FFormats.Free;
  inherited;
end;


//------------------------------------------------------------------------------
// IImageFormatAdapter
//------------------------------------------------------------------------------

function TImageFormatManager.AssignFrom(Dest: TCustomBitmap32; Source: TPersistent): boolean;
var
  Item: TImageFormatItem;
  Adapter: IImageFormatAdapter;
begin
  if (FFormats = nil) then
    exit(False);

  for Item in FFormats do
    if (Supports(Item.ImageFormat, IImageFormatAdapter, Adapter)) and (Adapter.AssignFrom(Dest, Source)) then
      exit(True);

  Result := False;
end;

function TImageFormatManager.AssignTo(Source: TCustomBitmap32; Dest: TPersistent): boolean;
var
  Item: TImageFormatItem;
  Adapter: IImageFormatAdapter;
begin
  if (FFormats = nil) then
    exit(False);

  for Item in FFormats do
    if (Supports(Item.ImageFormat, IImageFormatAdapter, Adapter)) and (Adapter.AssignTo(Source, Dest)) then
      exit(True);

  Result := False;
end;

function TImageFormatManager.CanAssignFrom(Source: TPersistent): boolean;
var
  Item: TImageFormatItem;
  Adapter: IImageFormatAdapter;
begin
  if (FFormats = nil) then
    exit(False);

  for Item in FFormats do
    if (Supports(Item.ImageFormat, IImageFormatAdapter, Adapter)) and (Adapter.CanAssignFrom(Source)) then
      exit(True);

  Result := False;
end;

function TImageFormatManager.CanAssignTo(Dest: TPersistent): boolean;
var
  Item: TImageFormatItem;
  Adapter: IImageFormatAdapter;
begin
  if (FFormats = nil) then
    exit(False);

  for Item in FFormats do
    if (Supports(Item.ImageFormat, IImageFormatAdapter, Adapter)) and (Adapter.CanAssignTo(Dest)) then
      exit(True);

  Result := False;
end;

//------------------------------------------------------------------------------
// IImageFormatReaders
//------------------------------------------------------------------------------

function TImageFormatManager.FindReader(const AFileType: string): IImageFormatReader;
var
  Item: TImageFormatItem;
  Reader: IImageFormatReader;
  FileInfo: IImageFormatFileInfo;
  FileType: string;
begin
  Result := nil;

  if (FFormats = nil) then
    exit;

  for Item in FFormats do
    if (Supports(Item.ImageFormat, IImageFormatReader, Reader)) and
      (Supports(Item.ImageFormat, IImageFormatFileInfo, FileInfo)) then
    begin
      for FileType in FileInfo.ImageFormatFileTypes do
        if (SameText(AFileType, FileType)) then
          exit(Reader);
    end;
end;

function TImageFormatManager.FindReader(AStream: TStream): IImageFormatReader;
var
  Item: TImageFormatItem;
  Reader: IImageFormatReader;
  SavePos: Int64;
begin
  Result := nil;

  if (FFormats = nil) then
    exit;

  SavePos := AStream.Position;

  for Item in FFormats do
    if (Supports(Item.ImageFormat, IImageFormatReader, Reader)) then
    begin
      if (Reader.CanLoadFromStream(AStream)) then
      begin
        AStream.Position := SavePos;
        exit(Reader);
      end;

      AStream.Position := SavePos;
    end;
end;

function TImageFormatManager.CanLoadFromStream(AStream: TStream): boolean;
var
  Reader: IImageFormatReader;
begin
  Reader := FindReader(AStream);
  Result := (Reader <> nil);
end;

function TImageFormatManager.LoadFromFile(ADest: TCustomBitmap32; const AFilename: string): boolean;
var
  Item: TImageFormatItem;
  Reader: IImageFormatFileReader;
begin
  for Item in FFormats do
    if (Supports(Item.ImageFormat, IImageFormatFileReader, Reader)) then
    begin
      if (Reader.LoadFromFile(ADest, AFilename)) then
        exit(True);
    end;

  Result := False;
end;

function TImageFormatManager.LoadFromResource(ADest: TCustomBitmap32; AResourceType: TResourceType;
  AStream: TStream): boolean;
var
  Item: TImageFormatItem;
  Reader: IImageFormatResourceReader;
  SavePos: Int64;
begin
  SavePos := AStream.Position;

  for Item in FFormats do
    if (Supports(Item.ImageFormat, IImageFormatResourceReader, Reader)) then
    begin
      if (Reader.LoadFromResource(ADest, AResourceType, AStream)) then
        exit(True);
      AStream.Position := SavePos;  // Restore pos after LoadFromResource
    end;

  Result := False;
end;

function TImageFormatManager.LoadFromStream(ADest: TCustomBitmap32; AStream: TStream): boolean;
var
  Item: TImageFormatItem;
  Reader: IImageFormatReader;
  SavePos: Int64;
begin
  SavePos := AStream.Position;

  for Item in FFormats do
    if (Supports(Item.ImageFormat, IImageFormatReader, Reader)) then
    begin
      if (Reader.CanLoadFromStream(AStream)) and (Reader.LoadFromStream(ADest, AStream)) then
        exit(True);

      AStream.Position := SavePos;
    end;

  Result := False;
end;

function TImageFormatManager.LoadFromStream(ADest: TCustomBitmap32; AStream: TStream;
  const AFilename: string): boolean;
var
  Item: TImageFormatItem;
  Reader: IImageFormatReader;
  FileInfo: IImageFormatFileInfo;
  Extension: string;
  FileType: string;
  SavePos: Int64;
begin
  SavePos := AStream.Position;

  Extension := Copy(TPath.GetExtension(AFilename), 2, MaxInt);

  for Item in FFormats do
    if (Supports(Item.ImageFormat, IImageFormatReader, Reader)) and
      (Supports(Item.ImageFormat, IImageFormatFileInfo, FileInfo)) then
    begin
      for FileType in FileInfo.ImageFormatFileTypes do
        if (SameText(Extension, FileType)) then
        begin
          if (Reader.CanLoadFromStream(AStream)) then
          begin
            AStream.Position := SavePos; // Restore pos after CanLoadFromStream
            if (Reader.LoadFromStream(ADest, AStream)) then
              exit(True);
          end;
          AStream.Position := SavePos;  // Restore pos after CanLoadFromStream or LoadFromStream
        end;
    end;

  Result := False;
end;

//------------------------------------------------------------------------------
// IImageFormatWriters
//------------------------------------------------------------------------------

function TImageFormatManager.FindWriter(const AFileType: string): IImageFormatWriter;
var
  Item: TImageFormatItem;
  Writer: IImageFormatWriter;
  FileInfo: IImageFormatFileInfo;
  FileType: string;
begin
  Result := nil;

  if (FFormats = nil) then
    exit;

  for Item in FFormats do
    if (Supports(Item.ImageFormat, IImageFormatWriter, Writer)) and
      (Supports(Item.ImageFormat, IImageFormatFileInfo, FileInfo)) then
    begin
      for FileType in FileInfo.ImageFormatFileTypes do
        if (SameText(AFileType, FileType)) then
          exit(Writer);
    end;
end;

//------------------------------------------------------------------------------
// IImageFormatClipboardFormat
//------------------------------------------------------------------------------

function TImageFormatManager.SupportsClipboardFormat(AFormat: TClipboardFormat): Boolean;
var
  Item: TImageFormatItem;
  ImageFormatClipboard: IImageFormatClipboardFormat;
begin
  Result := False;

  if (FFormats = nil) then
    exit;

  for Item in FFormats do
    if (Supports(Item.ImageFormat, IImageFormatClipboardFormat, ImageFormatClipboard)) and
      (Supports(Item.ImageFormat, IImageFormatReader)) then
      if (ImageFormatClipboard.SupportsClipboardFormat(AFormat)) then
        Exit(True);
end;

function TImageFormatManager.CanPasteFromClipboard: boolean;
var
  i: integer;
begin
  Result := False;

  try
    // FPC doesn't actually read from the clipboard within Open and Close so we
    // can't acquire it while we're reading from it. This is clearly a bug.
{$ifndef FPC}
    Clipboard.Open;
{$endif FPC}
  except
    on E: EClipboardException do
      exit; // Something else has the clipboard open
  end;
  try
    // For some reason EnumClipboardFormats doesn't work with FPC, so we have to
    // use the incredibly inefficient (but more portable) Clipboard.Formats[]
    for i := 0 to Clipboard.FormatCount-1 do
      if (SupportsClipboardFormat(Clipboard.Formats[i])) then
        Exit(True);
  finally
{$ifndef FPC}
    Clipboard.Close;
{$endif FPC}
  end;
end;

function TImageFormatManager.PasteFromClipboard(ADest: TCustomBitmap32): boolean;
var
  Item: TImageFormatItem;
  ImageFormatClipboard: IImageFormatClipboardFormat;
  Reader: IImageFormatReader;
  ClipboardFormat: TClipboardFormat;
  Stream: TStream;
  i: integer;
{$ifndef FPC}
var
  Data: HGlobal;
  Palette: HPALETTE;
{$else FPC}
const
  Palette = 0;
  Data = 0;
{$endif FPC}
begin
  Result := False;

  if (FFormats = nil) then
    exit;

  // Attempt to paste from clipboard in image format order instead of clipboard
  // format order; We want to give priority to the most important image formats.

  try
    // FPC doesn't actually read from the clipboard within Open and Close so we
    // can't acquire it while we're reading from it. This is clearly a bug.
{$ifndef FPC}
    Clipboard.Open;
{$endif FPC}
  except
    on E: EClipboardException do
      exit; // Something else has the clipboard open
  end;
  try
{$ifndef FPC}
    Palette := GetClipboardData(CF_PALETTE);
{$endif FPC}

    for Item in FFormats do
      if (Supports(Item.ImageFormat, IImageFormatClipboardFormat, ImageFormatClipboard)) then
      begin
        // First let image format give it a go directly...
        if (ImageFormatClipboard.PasteFromClipboard(ADest)) then
          exit(True);

        // ...then try to load the individual formats
        for i := 0 to Clipboard.FormatCount-1 do
        begin
          ClipboardFormat := Clipboard.Formats[i];
          if (ImageFormatClipboard.SupportsClipboardFormat(ClipboardFormat)) then
          begin
{$ifndef FPC}
            Data := GetClipboardData(ClipboardFormat);
            if (Data = 0) then
              RaiseLastOSError;
{$endif FPC}
            if (ImageFormatClipboard.LoadFromClipboardFormat(ADest, ClipboardFormat, Data, Palette)) then
              Exit(True)
          end;
        end;
      end;

    // ...finally give it a last go with the individual formats via a stream
    for Item in FFormats do
      if (Supports(Item.ImageFormat, IImageFormatReader, Reader)) then
      begin
        for i := 0 to Clipboard.FormatCount-1 do
        begin
          ClipboardFormat := Clipboard.Formats[i];
          if (ImageFormatClipboard.SupportsClipboardFormat(ClipboardFormat)) then
          begin
{$ifndef FPC}
            Stream := TClipboardMemoryStream.Create(ClipboardFormat);
            try
{$else FPC}
            Stream := TMemoryStream.Create;
            try
              if (not Clipboard.GetFormat(ClipboardFormat, Stream)) then
                continue;
{$endif FPC}

              Result := Reader.LoadFromStream(ADest, Stream);
              if (Result) then
                exit;
            finally
              Stream.Free;
            end;
          end;
        end;
      end;

  finally
{$ifndef FPC}
    Clipboard.Close;
{$endif FPC}
  end;
end;

//------------------------------------------------------------------------------
// IImageFormatManager
//------------------------------------------------------------------------------

function TImageFormatManager.GetAdapters: IImageFormatAdapter;
begin
  Result := Self;
end;

function TImageFormatManager.GetClipboardFormats: IImageFormatClipboardFormats;
begin
  Result := Self;
end;

function TImageFormatManager.GetReaders: IImageFormatReaders;
begin
  Result := Self;
end;

function TImageFormatManager.GetWriters: IImageFormatWriters;
begin
  Result := Self;
end;

function TImageFormatManager.ImageFormats: IImageFormats;
begin
  Result := TImageFormatEnumerator.Create(FFormats, IImageFormat);
end;

function TImageFormatManager.ImageFormats(Intf: TGUID): IImageFormats;
begin
  Result := TImageFormatEnumerator.Create(FFormats, Intf);
end;

{$ifndef ANONYMOUS_METHODS}
function ImageFormatItemComparer(const A, B: TImageFormatManager.TImageFormatItem): integer;
begin
  Result := A.Priority - B.Priority;
end;
{$endif ANONYMOUS_METHODS}

procedure TImageFormatManager.RegisterImageFormat(const AImageFormat: IImageFormat; APriority: integer);
var
  Index: integer;
  Item: TImageFormatItem;
begin
  if (FFormats = nil) then
  begin
    FFormats := TImageFormatList.Create(TComparer<TImageFormatItem>.Construct(
{$ifdef ANONYMOUS_METHODS}
      function(const A, B: TImageFormatItem): integer
      begin
        Result := A.Priority - B.Priority;
      end
{$else ANONYMOUS_METHODS}
      @ImageFormatItemComparer
{$endif ANONYMOUS_METHODS}
      ));
  end;

  Item.Priority := APriority;
  Item.ImageFormat := AImageFormat;

  FFormats.BinarySearch(Item, Index);
  FFormats.Insert(Index, Item);
end;

{$ifdef FPC}
constructor TImageFormatManager.TImageFormatList.Create(const AComparer: IComparer<TImageFormatItem>);
begin
  inherited Create;
  FComparer := AComparer;
end;

function DoBinarySearch<T>(const Values: array of T; const Item: T;
  out FoundIndex: Integer; const Comparer: IComparer<T>; Index, Count: Integer): Boolean;
var
  L, H: Integer;
  mid, cmp: Integer;
begin
  if (Index < Low(Values)) or ((Index > High(Values)) and (Count > 0))
     or (Index + Count - 1 > High(Values)) or (Count < 0)
     or (Index + Count < 0) then
    Assert(False);

  if Count = 0 then
  begin
    FoundIndex := Index;
    Exit(False);
  end;

  Result := False;
  L := Index;
  H := Index + Count - 1;
  while L <= H do
  begin
    mid := L + (H - L) shr 1;
    cmp := Comparer.Compare(Values[mid], Item);
    if cmp < 0 then
      L := mid + 1
    else if cmp > 0 then
      H := mid - 1
    else
    begin
      repeat
        Dec(mid);
      until (mid < Index) or (Comparer.Compare(Values[mid], Item) <> 0);
      FoundIndex := mid + 1;
      Exit(True);
    end;
  end;
  FoundIndex := L;
end;

function TImageFormatManager.TImageFormatList.BinarySearch(const Item: TImageFormatManager.TImageFormatItem; out FoundIndex: Integer): Boolean;
begin
  Result := DoBinarySearch<TImageFormatManager.TImageFormatItem>(FItems, Item, FoundIndex, FComparer, 0, Count);
end;
{$endif FPC}

function TImageFormatManager.BuildFileFilter(Intf: TGUID; IncludeAll: boolean): string;
var
  ImageFormat: IImageFormat;
  FileInfo: IImageFormatFileInfo;
  AllFilter: string;
  Extensions: TDictionary<string, boolean>;
  FileType: string;
  Count: integer;
  FileTypeCount: integer;
  FileTypes: string;
begin
  Result := '';
  AllFilter := '';
  Count := 0;

  Extensions := TDictionary<string, boolean>.Create;
  try

    for ImageFormat in ImageFormats(Intf) do
      if (Supports(ImageFormat, IImageFormatFileInfo, FileInfo)) then
      begin
        FileTypeCount := 0;
        FileTypes := '';
        for FileType in FileInfo.ImageFormatFileTypes do
        begin
          if (FileType = '') then
            continue;

          // Avoid duplicate extensions
          if (Extensions.ContainsKey(FileType.ToUpper)) then
            continue;
          Extensions.Add(FileType.ToUpper, False);

          if (FileTypeCount > 0) then
            FileTypes := FileTypes + ';';
          FileTypes := FileTypes + '*.' + FileType;
          Inc(FileTypeCount);
        end;

        if (FileTypeCount = 0) then
          continue;

        Result := Result + Format('%0:s (%1:s)|%1:s|', [FileInfo.ImageFormatDescription, FileTypes]);

        Inc(Count);

        if (IncludeAll) then
        begin
          if (AllFilter <> '') then
            AllFilter := AllFilter + ';';
          AllFilter := AllFilter + Format('%s', [FileTypes]);
        end;
      end;

    if (Result <> '') then
      SetLength(Result, Length(Result)-1);

  finally
    Extensions.Free;
  end;

  if (AllFilter <> '') and (Count > 1) then
    Result := Format('%0:s (%1:s)|%1:s|', [sAllFilter, AllFilter]) + Result;
end;

//------------------------------------------------------------------------------
// TImageFormatManager.TImageFormatEnumerator
//------------------------------------------------------------------------------
constructor TImageFormatManager.TImageFormatEnumerator.Create(AList: TImageFormatList; const AGUID: TGUID);
begin
  inherited Create;
  FList := AList;
  FGUID := AGUID;
  FIndex := -1;
end;

function TImageFormatManager.TImageFormatEnumerator.GetCurrent: IImageFormat;
begin
  Result := FList[FIndex].ImageFormat;
end;

function TImageFormatManager.TImageFormatEnumerator.GetEnumerator: IImageFormatEnumerator;
begin
  Result := Self;
end;

function TImageFormatManager.TImageFormatEnumerator.MoveNext: Boolean;
begin
  if (FList = nil) or (FIndex >= FList.Count) then
    exit(False);

  Inc(FIndex);
  while (FIndex < FList.Count) and (not Supports(GetCurrent, FGUID)) do
    Inc(FIndex);

  Result := (FIndex < FList.Count);
end;

//------------------------------------------------------------------------------
//
//      ImageFormatManager
//
//------------------------------------------------------------------------------
var
  FImageFormatManager: IImageFormatManager;

function ImageFormatManager: IImageFormatManager;
begin
  if (FImageFormatManager = nil) then
    FImageFormatManager := TImageFormatManager.Create;

  Result := FImageFormatManager;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

initialization
finalization
  FImageFormatManager := nil;
end.
