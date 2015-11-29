unit MirandaNG.ListeningTo;

interface

type
  TrackType = (Music, Video, Radio);

  TTrackInfo = record
    TrackType: TrackType;
    Title: string;
    Artist: string;
    Album: string;
    Track: string;
    Year: Integer;
    Genre: string;
    Length: Int64; // in seconds
    StationName: string;
  end;

procedure SendTrackInfo(const APlayerName: string; IsPlaying: Boolean; const ATrackInfo: TTrackInfo);
procedure SendCurrentTrack(const APlayerName: string; const ATrackInfo: TTrackInfo);
procedure SendStopped(const APlayerName: string);

implementation

uses
  Windows, Messages, SysUtils, Utils;

const
  MIRANDA_WINDOWCLASS = 'Miranda.ListeningTo';
  MIRANDA_DW_PROTECTION = $8754;

function FormatTrackInfo(const APlayerName: string; IsPlaying: Boolean; const ATrackInfo: TTrackInfo;
  const Delimiter: string = #0): string;
const
  IS_PLAYING: array [Boolean] of string = ('0', '1');
  TRACK_TYPE: array [Boolean, TrackType] of string = (
    ('', '', ''),
    ('Music', 'Video', 'Radio')
  );
var
  info: TTrackInfo;
  year, length: string;
begin
  if IsPlaying then
  begin
    info := ATrackInfo;
  end else
  begin
    Finalize(info);
    FillChar(info, SizeOf(info), 0);
  end;

  if info.Year > 0 then year := IntToStr(info.Year)
    else year := '';
  if info.Length > 0 then length := IntToStr(info.Length)
    else length := '';

  Result := ''
    + IS_PLAYING[IsPlaying] + Delimiter
    + APlayerName + Delimiter
    + TRACK_TYPE[IsPlaying][info.TrackType] + Delimiter
    + info.Title + Delimiter
    + info.Artist + Delimiter
    + info.Album + Delimiter
    + info.Track + Delimiter
    + year + Delimiter
    + info.Genre + Delimiter
    + length + Delimiter
    + info.StationName + Delimiter
    + Delimiter; // Ending Delimiter
end;

function EnumWindowsProc(wnd: HWND; data: LPARAM): BOOL; stdcall;
var
  buf: array [Byte] of WideChar;
begin
  FillChar(buf, SizeOf(buf), 0);
  if GetClassName(wnd, buf, SizeOf(buf)) <> 0 then
  begin
    buf[High(buf)] := #0;
    if PWideChar(@buf[0]) = MIRANDA_WINDOWCLASS then
      SendMessage(wnd, WM_COPYDATA, 0, data);
  end;
  Result := true;
end;

procedure SendTrackInfo(const APlayerName: string; IsPlaying: Boolean; const ATrackInfo: TTrackInfo);
var
  s: WideString;
  cds: COPYDATASTRUCT;
begin
  DebugOutput(FormatTrackInfo(APlayerName, IsPlaying, ATrackInfo, '\0'));
  s := WideString(FormatTrackInfo(APlayerName, IsPlaying, ATrackInfo));
  cds.dwData := MIRANDA_DW_PROTECTION;
  cds.lpData := PWideChar(s);
  cds.cbData := Length(s) * SizeOf(WideChar);
  EnumWindows(@EnumWindowsProc, LPARAM(@cds));
end;

procedure SendCurrentTrack(const APlayerName: string; const ATrackInfo: TTrackInfo);
begin
  SendTrackInfo(APlayerName, true, ATrackInfo);
end;

procedure SendStopped(const APlayerName: string);
var
  dummy: TTrackInfo;
begin
  SendTrackInfo(APlayerName, false, dummy);
end;

end.
