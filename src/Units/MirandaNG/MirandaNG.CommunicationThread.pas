unit MirandaNG.CommunicationThread;

interface

uses
  Windows, Classes, SyncObjs, App.Utils;

type
  TCommunicationThread = class(TThread)
  strict protected
    FLock: TCriticalSection;
    FEvent: TEvent;
    FTrackInfo: TTrackInfo;
    function GetTrackInfo: TTrackInfo;
    procedure SetTrackInfo(const ATrackInfo: TTrackInfo);

    procedure SendTrackInfo;
  strict protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    property TrackInfo: TTRackInfo read GetTrackInfo write SetTrackInfo;

    procedure WakeUp;
  end;


implementation

uses
  SysUtils, Messages;

const
  MIRANDA_WINDOWCLASS = 'Miranda.ListeningTo';
  MIRANDA_DW_PROTECTION = $8754;

const
  SLEEP_TIMEOUT = 1 * 60 * 1000; // 1 min

function FormatTrackInfo(const ATrackInfo: TTrackInfo; const Delimiter: string = #0): string;
const
  IS_PLAYING: array [TrackType] of string = ('0', '1', '1', '1');
  TRACK_TYPE: array [TrackType] of string = ('', 'Music', 'Video', 'Radio');
var
  info: TTrackInfo;
  year, length: string;
begin
  if ATrackInfo.TrackType <> TrackType.None then
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
    + IS_PLAYING[ATrackInfo.TrackType] + Delimiter
    + ATrackInfo.PlayerName + Delimiter
    + TRACK_TYPE[info.TrackType] + Delimiter
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

function EnumListeningToHookWindows(wnd: HWND; lParam: LPARAM): BOOL; stdcall;
var
  buf: array [Byte] of WideChar;
begin
  FillChar(buf, SizeOf(buf), 0);
  if GetClassName(wnd, buf, SizeOf(buf)) <> 0 then
  begin
    buf[High(buf)] := #0;
    if PWideChar(@buf[0]) = MIRANDA_WINDOWCLASS then
      SendMessage(wnd, WM_COPYDATA, 0, lParam);
  end;
  Result := true;
end;

constructor TCommunicationThread.Create;
begin
  inherited Create;
  FreeOnTerminate := true;
  FLock := TCriticalSection.Create;
  FEvent := TEvent.Create();
end;

destructor TCommunicationThread.Destroy;
begin
  FreeAndNil(FEvent);
  FreeAndNil(FLock);
  inherited;
end;

procedure TCommunicationThread.Execute;
begin
  while not Terminated do
  begin
    {$IFDEF DEBUG}
    DebugOutput('Communication Thread: iteration');
    {$ENDIF}
    SendTrackInfo;
    FEvent.WaitFor(SLEEP_TIMEOUT);
    FEvent.ResetEvent;
  end;
  SendTrackInfo;
end;

function TCommunicationThread.GetTrackInfo: TTrackInfo;
begin
  FLock.Acquire;
  try
    Result := FTrackInfo;
  finally
    FLock.Release;
  end;
end;

procedure TCommunicationThread.SendTrackInfo;
var
  s: WideString;
  cds: COPYDATASTRUCT;
  info: TTrackInfo;
begin
  info := TrackInfo;

  {$IFDEF DEBUG}
  DebugOutput(FormatTrackInfo(info, '\0'));
  {$ENDIF}
  s := WideString(FormatTrackInfo(info));
  cds.dwData := MIRANDA_DW_PROTECTION;
  cds.lpData := PWideChar(s);
  cds.cbData := Length(s) * SizeOf(WideChar);

  EnumWindows(@EnumListeningToHookWindows, LPARAM(@cds));
end;

procedure TCommunicationThread.SetTrackInfo(const ATrackInfo: TTrackInfo);
begin
  FLock.Acquire;
  try
    FTrackInfo := ATrackInfo;
    WakeUp;
  finally
    FLock.Release;
  end;
end;

procedure TCommunicationThread.WakeUp;
begin
  FEvent.SetEvent;
end;

end.
