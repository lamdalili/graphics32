unit MainUnit;

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
 * The Original Code is TextDemoVPR Example (based on VPR example)
 *
 * The Initial Developer of the Original Code is
 * Mattias Andersson <mattias@centaurix.com>
 *
 * Portions created by the Initial Developer are Copyright (C) 2000-2005
 * the Initial Developer. All Rights Reserved.
 *
 * ***** END LICENSE BLOCK ***** *)

interface

{$include GR32.inc}

uses
{$ifdef FPC}
  LCLIntf, LResources, LCLType,
{$endif}
{$ifdef WINDOWS}
  Windows,
{$endif}
  Messages, SysUtils,
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  Buttons,
  ComCtrls,

  GR32, GR32_Paths, GR32_Image, GR32_Layers, GR32.Text.Types;

{$ifdef WINDOWS}
type
  TTrackBar = class(ComCtrls.TTrackBar)
  protected
    procedure WndProc(var Message: TMessage); override;
{$ifdef FPC}
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
{$endif}
  end;
{$endif}

type
  TMainForm = class(TForm)
    ButtonExit: TButton;
    ButtonSelectFont: TButton;
    CheckBoxSingleLine: TCheckBox;
    CheckBoxWordbreak: TCheckBox;
    FontDialog: TFontDialog;
    GroupBoxFont: TGroupBox;
    GroupBoxLayout: TGroupBox;
    GroupBoxRendering: TGroupBox;
    Img: TImage32;
    LblFontInfo: TLabel;
    PaintBox32: TPaintBox32;
    PnlControl: TPanel;
    PnlImage: TPanel;
    PnlZoom: TPanel;
    RadioGroupMethod: TRadioGroup;
    StatusBar: TStatusBar;
    TrackBarGamma: TTrackBar;
    GroupBoxGamma: TGroupBox;
    PanelLeft: TPanel;
    CheckBoxKerning: TCheckBox;
    GroupBoxAlignHorizontal: TGroupBox;
    GroupBoxAlignVertical: TGroupBox;
    GroupBoxJustification: TGroupBox;
    TrackBarZoom: TTrackBar;
    PanelAlignHor: TPanel;
    ButtonAlignHorLeft: TSpeedButton;
    ButtonAlignHorCenter: TSpeedButton;
    ButtonAlignHorRight: TSpeedButton;
    ButtonAlignHorJustify: TSpeedButton;
    PanelAlignVer: TPanel;
    ButtonAlignVerTop: TSpeedButton;
    ButtonAlignVerCenter: TSpeedButton;
    ButtonAlignVerBottom: TSpeedButton;
    PanelJustification: TPanel;
    Label1: TLabel;
    TrackBarInterChar: TTrackBar;
    Label3: TLabel;
    TrackBarInterWordMax: TTrackBar;
    GroupBoxClipping: TGroupBox;
    CheckBoxClipRaster: TCheckBox;
    CheckBoxClipLayout: TCheckBox;
    Shape1: TShape;
    ComboBoxExample: TComboBox;
    TxtContent: TMemo;
    CheckBoxRTL: TCheckBox;
    ImgPage: TPageControl;
    ViewTab: TTabSheet;
    TextTab: TTabSheet;
    Panel1: TPanel;
    ReturnAuto: TCheckBox;
    CheckBoxEnableShaping: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonExitClick(Sender: TObject);
    procedure ButtonSelectFontClick(Sender: TObject);
    procedure ImgClick(Sender: TObject);
    procedure ImgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);
    procedure RadioGroupMethodClick(Sender: TObject);
    procedure TrackBarGammaChange(Sender: TObject);
    procedure TrackBarInterCharChange(Sender: TObject);
    procedure TrackBarInterWordMaxChange(Sender: TObject);
    procedure ImgMouseLeave(Sender: TObject);
    procedure ButtonAlignHorClick(Sender: TObject);
    procedure ButtonAlignVerClick(Sender: TObject);
    procedure TrackBarZoomChange(Sender: TObject);
    procedure DoLayoutAndRender(Sender: TObject);
    procedure DoRender(Sender: TObject);
    procedure CheckBoxRTLClick(Sender: TObject);
    procedure ComboBoxExampleChange(Sender: TObject);
    procedure ReturnAutoClick(Sender: TObject);
  private
    FCanvas: TCanvas32;
    FTextLayout: TTextLayout;
    FApplyOptions: boolean;
    FLayoutTime: Int64;
    FRenderTime: Int64;

  private
    procedure BuildPolygonFromText;
    procedure RenderText;
    procedure DisplayFontInfo;
    procedure DrawZoom(X, Y: integer);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
{$ifndef FPC}
  Types,
  System.UITypes,
{$endif}

{$ifdef WINDOWS}
  CommCtrl,
{$ifdef FPC}
  Win32Proc,
{$endif}
{$endif}

  Math,
  StrUtils,
  GR32_System,
  GR32_Gamma,
  GR32_Backends,
  GR32_Polygons,
  GR32_Brushes,
  GR32.Examples;

const
  sExamples: array[0..6] of record
    Name: string;
    Title: string;
    FontName: string;
    Flags: set of (LineBreakIsParagraph, DoubleLineBreakIsParagraph, RtlLead);
  end = (
    (Name: 'LoremIpsum'; Title: 'Lorem Ipsum'; FontName: '';   Flags: [LineBreakIsParagraph]),
    (Name: 'MobyDick';   Title: 'Moby Dick';  FontName: '';   Flags: [DoubleLineBreakIsParagraph]),
    (Name: 'DonQuixote'; Title: 'Don Quixote';  FontName: '';   Flags: [DoubleLineBreakIsParagraph]),
    (Name: 'MaBohème';   Title: 'Ma bohème';  FontName: '';   Flags: [DoubleLineBreakIsParagraph]),
    (Name: 'DoOxenLowWhenMangersAreFull'; Title: 'Хіба ревуть воли, як ясла повні'; FontName: ''; Flags: [DoubleLineBreakIsParagraph]),
    (Name: 'dava'; Title: 'Davanagari'; FontName: 'Arial Unicode MS'; Flags: [DoubleLineBreakIsParagraph]),
    (Name: 'Rtl text'; Title: 'Rtl text'; FontName: 'Tahoma'; Flags: [RtlLead, DoubleLineBreakIsParagraph])
  );

const
  InnerMargin = 10;

procedure TMainForm.FormCreate(Sender: TObject);
var
  Brush: TSolidBrush;
  I: integer;
begin
  Img.SetupBitmap(True, clWhite32);
  Img.Bitmap.Font.Name := 'Georgia';
  Img.Bitmap.Font.Size := 9;
  FontDialog.Font.Assign(Img.Bitmap.Font);

  FCanvas := TCanvas32.Create(Img.Bitmap);
  FCanvas.BeginLockUpdate; // Never unlocked; We draw manually
  Brush := TSolidBrush(FCanvas.Brushes.Add(TSolidBrush));
  Brush.FillColor := clBlack32;
  Brush.FillMode := pfNonZero;

  PaintBox32.BufferOversize := 0;
  PaintBox32.Buffer.Clear(clWhite32);

  FTextLayout := DefaultTextLayout;

  FTextLayout.SingleLine := False;
  FTextLayout.WordWrap := True;

  CheckBoxSingleLine.Checked := FTextLayout.SingleLine;
  CheckBoxWordbreak.Checked := FTextLayout.WordWrap;
  CheckBoxKerning.Checked := FTextLayout.Kerning;
  CheckBoxClipLayout.Checked := FTextLayout.ClipLayout;
  CheckBoxClipRaster.Checked := FTextLayout.ClipRaster;
  TrackBarGamma.Position := Round(GAMMA_VALUE * TrackBarGamma.Tag);
  TrackBarInterWordMax.Position := Round(FTextLayout.MaxInterWordSpaceFactor * TrackBarInterWordMax.Tag);
  TrackBarInterChar.Position := Round(FTextLayout.MaxInterCharSpaceFactor * TrackBarInterChar.Tag);

{$ifndef FPC}

  // What the hell is the point of Lazarus aping Delphi and then refusing to stay compatible?
  // Anyway, the PositionToolTip property is called ScalePos in Lazarus and on top of that
  // it's not implemented for Windows. Good job!
  TrackBarGamma.PositionToolTip := ptTop;
  TrackBarInterWordMax.PositionToolTip := ptTop;
  TrackBarInterChar.PositionToolTip := ptTop;
  TrackBarZoom.PositionToolTip := ptTop;

{$endif}

  // Lazarus resets various properties so we have to set them in code
  StatusBar.SimplePanel := True;
  ButtonAlignHorLeft.Down := True;
  ButtonAlignVerTop.Down := True;

  StatusBar.SimpleText := '';

{$ifndef FPC}
  Self.Padding.SetBounds(4,4,4,4);
  ButtonExit.AlignWithMargins := True;
  ButtonSelectFont.AlignWithMargins := True;
  GroupBoxFont.AlignWithMargins := True;
  GroupBoxLayout.AlignWithMargins := True;
  GroupBoxAlignHorizontal.AlignWithMargins := True;
  GroupBoxAlignVertical.AlignWithMargins := True;
  CheckBoxSingleLine.AlignWithMargins := True;
  CheckBoxWordbreak.AlignWithMargins := True;
  CheckBoxKerning.AlignWithMargins := True;
  CheckBoxRtl.AlignWithMargins := True;
  CheckBoxClipRaster.AlignWithMargins := True;
  CheckBoxClipLayout.AlignWithMargins := True;
  GroupBoxRendering.AlignWithMargins := True;
  GroupBoxClipping.AlignWithMargins := True;
  GroupBoxGamma.AlignWithMargins := True;
  RadioGroupMethod.AlignWithMargins := True;
  GroupBoxJustification.AlignWithMargins := True;
{$else}
  ButtonExit.BorderSpacing.Around := 4;
  ButtonSelectFont.BorderSpacing.Around := 4;
  GroupBoxFont.BorderSpacing.Around := 4;
  GroupBoxLayout.BorderSpacing.Around := 4;
  GroupBoxAlignHorizontal.BorderSpacing.Around := 4;
  GroupBoxAlignVertical.BorderSpacing.Around := 4;
  CheckBoxSingleLine.BorderSpacing.Around := 4;
  CheckBoxWordbreak.BorderSpacing.Around := 4;
  CheckBoxKerning.BorderSpacing.Around := 4;
  CheckBoxClipRaster.BorderSpacing.Around := 4;
  CheckBoxClipLayout.BorderSpacing.Around := 4;
  GroupBoxRendering.BorderSpacing.Around := 4;
  GroupBoxClipping.BorderSpacing.Around := 4;
  GroupBoxGamma.BorderSpacing.Around := 4;
  RadioGroupMethod.BorderSpacing.Around := 4;
  GroupBoxJustification.BorderSpacing.Around := 4;
{$endif}

  // Advanced typography requires ITextToPathSupport2
  if (not Supports(Img.Bitmap.Backend, ITextToPathSupport2)) then
  begin
    GroupBoxJustification.Hint := 'The current backend does not support the required features';
    GroupBoxJustification.Enabled := False;
    TrackBarInterChar.Enabled := False;
    TrackBarInterWordMax.Enabled := False;
  end;

  ComboBoxExample.Enabled := False;
  for I := 0 to High(sExamples)do
   with sExamples[I] do
     ComboBoxExample.Items.Add(Title);
  ComboBoxExample.Enabled := True;

  FApplyOptions := True;

  ComboBoxExample.ItemIndex := 0;
  ComboBoxExampleChange(nil);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FCanvas.Free;
end;

procedure TMainForm.ButtonSelectFontClick(Sender: TObject);
begin
  FontDialog.Font := Img.Bitmap.Font;
  if FontDialog.Execute then
  begin
    Img.Bitmap.Font.Assign(FontDialog.Font);
    DoLayoutAndRender(nil);
  end;
end;

procedure TMainForm.CheckBoxRTLClick(Sender: TObject);
begin
  if CheckBoxRTL.Checked xor (FTextLayout.AlignmentHorizontal=TextAlignHorRight) then
  begin
     if CheckBoxRTL.Checked  then
        CheckBoxRTL.Tag := Ord(TextAlignHorRight)
     else
        CheckBoxRTL.Tag := Ord(TextAlignHorLeft);
     ButtonAlignHorRight.Down := CheckBoxRTL.Checked;
     ButtonAlignHorLeft.Down := not CheckBoxRTL.Checked ;
     ButtonAlignHorClick(CheckBoxRTL);
  end;
end;
// load example
procedure TMainForm.ComboBoxExampleChange(Sender: TObject);
  procedure LoadExample(const AName:string);
  var
     ExamplesPath: string;
  begin
      ExamplesPath := ExtractfilePath(Graphics32Examples.MediaFolder);
      ExamplesPath := ExamplesPath + 'Drawing\TextVPR\Examples\';
      with TStringList.Create do
      try
          LoadFromFile(ExamplesPath + AName +'.template');
          TxtContent.Lines.Text := Text;
      finally
        Free;
      end;
  end;
begin
  if (ComboBoxExample.ItemIndex = -1) then
    exit;
  with sExamples[ComboBoxExample.ItemIndex] do
  begin
     CheckBoxRtl.Checked := RtlLead in Flags;
     LoadExample(Name);
     if FontName <> '' then
        Img.Bitmap.Font.Name := FontName;
  //CheckBoxSingleLine.Checked;
  //CheckBoxWordbreak.Checked;
  //CheckBoxKerning.Checked;
  //CheckBoxClipLayout.Checked;
  //LineBreakIsParagraph
  //DoubleLineBreakIsParagraph
  end;
  DoLayoutAndRender(nil);
end;

procedure TMainForm.DoRender(Sender: TObject);
begin
  if (not FApplyOptions) then
    exit;

  RenderText;

  StatusBar.SimpleText := Format('Layout: %.0n mS.  Render: %.0n mS', [FLayoutTime * 1.0, FRenderTime * 1.0]);
end;

procedure TMainForm.DoLayoutAndRender(Sender: TObject);
begin
  if (not FApplyOptions) then
    exit;

  BuildPolygonFromText;
  DoRender(nil);
end;

procedure TMainForm.ImgClick(Sender: TObject);
begin
  RadioGroupMethod.ItemIndex := (RadioGroupMethod.ItemIndex + 1) mod RadioGroupMethod.Items.Count;
end;

procedure TMainForm.ImgMouseLeave(Sender: TObject);
begin
  DrawZoom(0, 0);
end;

procedure TMainForm.ImgMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer; Layer: TCustomLayer);
begin
  DrawZoom(X, Y);
end;
/// ParseTemplate
{$region}
function ParseTemplate(const AText: string):string;
// converts codepoints between {} to string = {#13} or sequence {#13#10}
// Removes short comments if present //
 function UnEscape(const aStr: string):string;
 var
   P1, P2, nLen, nPos, value, nOut: integer;
   capture: boolean;
   c: char;
 begin
    nLen := length(aStr);
    Setlength(Result, nLen);
    nPos := 0;
    nOut := 0;
    capture := false;
    while nPos < nLen do
    begin
        inc(nPos);
        c := aStr[nPos];
        case c of
          '{': if not capture and (nPos+1 <= nLen) and (aStr[nPos+1] = '#') then
               begin
                  capture := True;
                  continue;
               end;
          '}': if capture then
               begin
                  capture := False;
                  continue;
               end;
          '#': if capture then
               begin
                  P1 := nPos + 1; // skip #
                  P2 := P1 + 1;   // potentiel $
                  while (P2 < nLen) and (aStr[P2] in ['0'..'9', 'A'..'F','a'..'f'])  do
                     inc(P2);
                  if TryStrToInt(copy(aStr, P1, P2-P1), value) and (value > 0)then
                  begin
                      c := char(value);
                      nPos := P2-1;
                  end;
               end;
        end;
        inc(nOut);
        Result[nOut] := c;
    end;
    SetLength(Result, nOut);
 end;
var
  s:string;
  I, Comment: integer;
  Ls: TStringlist;
begin
  Result := '';
  Ls := TStringlist.Create; // to avoid Memo wraps
  try
      Ls.Text := AText;
      for I := 0 to Ls.Count -1 do
      begin
        s := Ls[i];
        Comment := Pos('//', s); // delete any comment
        if Comment <> 0 then
           Delete(s, Comment, MAXINT);
        if s <> '' then // skips comments
        begin
          Result := Result + UnEscape(s);
        end;
      end;
   finally
     Ls.Free;
   end;
end;
{$endregion}

procedure TMainForm.BuildPolygonFromText;
var
  DestRect: TFloatRect;
  StopWatch: TStopWatch;
begin
  if (ComboBoxExample.ItemIndex = -1) then
    exit;

  DestRect := FloatRect(Img.BoundsRect);
  GR32.InflateRect(DestRect, -InnerMargin, -InnerMargin);

  FTextLayout.InterLineFactor := 1.2;
  FTextLayout.InterParagraphFactor := 1.6;
  FTextLayout.SingleLine := CheckBoxSingleLine.Checked;
  FTextLayout.WordWrap := CheckBoxWordbreak.Checked;
  FTextLayout.Rtl := CheckBoxRtl.Checked;
  FTextLayout.Kerning := CheckBoxKerning.Checked;
  FTextLayout.ClipLayout := CheckBoxClipLayout.Checked;
  FTextLayout.LineBreakIsParagraph := LineBreakIsParagraph in sExamples[ComboBoxExample.ItemIndex].Flags;
  FTextLayout.DoubleLineBreakIsParagraph := DoubleLineBreakIsParagraph in sExamples[ComboBoxExample.ItemIndex].Flags;
  FTextLayout._EnableShaping := CheckBoxEnableShaping.Checked;

  FCanvas.Clear;

  StopWatch := TStopWatch.StartNew;

  FCanvas.RenderText(DestRect, Parsetemplate(TxtContent.Lines.Text), FTextLayout);

  FLayoutTime := StopWatch.ElapsedMilliseconds;
  DisplayFontInfo;
end;

type
  TCanvas32Cracker = class(TCanvas32);

procedure TMainForm.RenderText;
var
  r: TRect;
  StopWatch: TStopWatch;
begin
  Img.SetupBitmap(True, clWhite32);

  r := Img.Bitmap.BoundsRect;
  GR32.InflateRect(r, -InnerMargin, -InnerMargin);
  Img.Bitmap.FrameRectS(r, $FFD0E0FF);

  // Setup clipping so fonts with swashes don't exceed the text area
  FTextLayout.ClipRaster := CheckBoxClipRaster.Checked;
  if (FTextLayout.ClipRaster) then
    Img.Bitmap.ClipRect := r
  else
    Img.Bitmap.ClipRect := Img.Bitmap.BoundsRect;

  StopWatch := TStopWatch.StartNew;

  TCanvas32Cracker(FCanvas).DrawPath(FCanvas);

  FRenderTime := StopWatch.ElapsedMilliseconds;

  DrawZoom(0, 0);
end;

procedure TMainForm.ReturnAutoClick(Sender: TObject);
begin
  TxtContent.WordWrap := ReturnAuto.Checked;
end;

procedure TMainForm.ButtonAlignVerClick(Sender: TObject);
begin
  if (not FApplyOptions) then
    exit;

  FTextLayout.AlignmentVertical := TTextAlignmentVertical(TControl(Sender).Tag);

  DoLayoutAndRender(nil);
end;


procedure TMainForm.ButtonAlignHorClick(Sender: TObject);
begin

  if (FApplyOptions) then
  begin
    FTextLayout.AlignmentHorizontal := TTextAlignmentHorizontal(TControl(Sender).Tag);
    DoLayoutAndRender(nil);
  end;

  TrackBarInterChar.Enabled := GroupBoxJustification.Enabled and (FTextLayout.AlignmentHorizontal = TextAlignHorJustify);
  TrackBarInterWordMax.Enabled := GroupBoxJustification.Enabled and (FTextLayout.AlignmentHorizontal = TextAlignHorJustify);
end;

function FontStylesToString(FontStyles: TFontStyles): string;
var
  Styles: TFontStyles;
begin
  Styles := [fsBold, fsItalic] * FontStyles;
  if Styles = [] then
    Result := ''
  else
  if Styles = [fsBold] then
    Result := ', Bold'
  else
  if Styles = [fsItalic] then
    Result := ', Italic'
  else
    Result := ', Bold & Italic';
end;

procedure TMainForm.DisplayFontInfo;
begin
 with Img.Bitmap do
  LblFontInfo.Caption := Format('%s'#10'%d px%s', [Font.Name, Font.Size, FontStylesToString(Font.Style)]);
end;

procedure TMainForm.DrawZoom(X, Y: integer);
var
  Zoom: Single;
  SrcRect: TRect;
  SrcW, SrcH: integer;
begin
  PaintBox32.Buffer.Clear(clWhite32);

  Zoom := TrackBarZoom.Tag / TrackBarZoom.Position;

  SrcW := Round(PaintBox32.Width * Zoom);
  SrcH := Round(PaintBox32.Height * Zoom);

  SrcRect := MakeRect(0, 0, SrcW, SrcH);
  X := EnsureRange(X - SrcW div 2, 0, Img.Bitmap.Width-SrcW);
  Y := EnsureRange(Y - SrcW div 2, 0, Img.Bitmap.Height-SrcH);

  GR32.OffsetRect(SrcRect, X, Y);

  PaintBox32.Buffer.Draw(PaintBox32.BoundsRect, SrcRect, Img.Bitmap);
  PaintBox32.Repaint;
end;

procedure TMainForm.RadioGroupMethodClick(Sender: TObject);
begin
  case RadioGroupMethod.ItemIndex of
    0: FCanvas.Renderer := TPolygonRenderer32VPR.Create(FCanvas.Bitmap, pfNonZero);
    1: FCanvas.Renderer := TPolygonRenderer32LCD.Create(FCanvas.Bitmap, pfNonZero);
    2: FCanvas.Renderer := TPolygonRenderer32LCD2.Create(FCanvas.Bitmap, pfNonZero);
  end;

  DoRender(nil);
end;

procedure TMainForm.TrackBarGammaChange(Sender: TObject);
var
  Value: Single;
begin
  StatusBar.SimpleText := 'Gamma correction is currently not implemented for text rendering';

  Value := TTrackBar(Sender).Position / TTrackBar(Sender).Tag;

  SetGamma(Value);

  TTrackBar(Sender).Hint := Format('%.2n', [GAMMA_VALUE]);

  DoRender(nil);
end;

procedure TMainForm.TrackBarInterCharChange(Sender: TObject);
var
  Value: Single;
begin
  Value := TTrackBar(Sender).Position / TTrackBar(Sender).Tag;
  TTrackBar(Sender).Hint := Format('%.2n', [Value]);

  if (not FApplyOptions) then
    exit;

  FTextLayout.MaxInterCharSpaceFactor := Value;

  DoLayoutAndRender(nil);
end;

procedure TMainForm.TrackBarInterWordMaxChange(Sender: TObject);
var
  Value: Single;
begin
  Value := TTrackBar(Sender).Position / TTrackBar(Sender).Tag;
  TTrackBar(Sender).Hint := Format('%.2n', [Value]);

  if (not FApplyOptions) then
    exit;

  FTextLayout.MaxInterWordSpaceFactor := Value;

  DoLayoutAndRender(nil);
end;

procedure TMainForm.TrackBarZoomChange(Sender: TObject);
begin
  DrawZoom(0, 0);
end;

procedure TMainForm.ButtonExitClick(Sender: TObject);
begin
  Close;
end;

{ TTrackBar }
{$ifdef WINDOWS}
{$ifdef FPC}
type
  PNMTTDispInfo = PNMTTDispInfoW;

const
  TTN_NEEDTEXT = TTN_NEEDTEXTW;
{$endif}

procedure TTrackBar.WndProc(var Message: TMessage);
var
{$ifdef FPC}
  s: UnicodeString;
{$else}
  s: string;
{$endif}
  NMTTDispInfo: PNMTTDispInfo;
begin
  inherited;

  if (Tag = 0) or (Message.Msg <> WM_NOTIFY) then
    exit;

  NMTTDispInfo := PNMTTDispInfo(Message.LParam);

  // Cast to cardinal for Lazarus :-/
  if Cardinal(NMTTDispInfo.hdr.code) <> Cardinal(TTN_NEEDTEXT) then
    exit;

  s := Format('%.2n', [Position / Tag]);

  StrLCopy(@NMTTDispInfo.szText[0], PWideChar(s), 79);
end;

{$ifdef FPC}
procedure TTrackBar.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or TBS_TOOLTIPS;
end;

procedure TTrackBar.CreateWnd;
begin
  inherited;

//  UpdateWindowStyle(Handle, TBS_TOOLTIPS, TBS_TOOLTIPS);
  SendMessage(Handle, TBM_SETTIPSIDE, TBTS_TOP, 0);
end;
{$endif}

{$endif}

end.
