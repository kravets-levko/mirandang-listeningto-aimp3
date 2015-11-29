unit AIMP3.EventsHook;

interface

uses
  apiCore, apiMessages;

type
  Factory = class
  public
    class function CreatePlayerEventsHook(ACore: IAIMPCore): IAIMPMessageHook;
  end;

implementation

uses
  SysUtils, Windows, Messages, Utils, apiObjects, apiPlayer, apiFileManager, MirandaNG.ListeningTo;

const
  AIMP_PLAYER_STATE_STOPPED = 0;
  AIMP_PLAYER_STATE_PAUSED  = 1;
  AIMP_PLAYER_STATE_PLAYING = 2;

type
  TPlaybackMessageHook = class(TInterfacedObject, IAIMPMessageHook)
  protected
    FPlayerName: string;
    FPlayer: IAIMPServicePlayer;
    function GetCurrentTrackInfo: TTrackInfo;
    procedure UpdateStatus(Playing: Boolean);
  protected
    procedure CoreMessage(Message: DWORD; Param1: Integer; Param2: Pointer; var Result: HRESULT); stdcall;
  public
    constructor Create(Core: IAIMPCore); virtual;
    destructor Destroy; override;
  end;

function GetMainModuleVerProductName(DefaultValue: string = ''): string;
type
  TTranslationArray = array [Word] of packed record
    Language: WORD;
    CodePage: WORD;
  end;
  PTranslationArray = ^TTranslationArray;
var
  mainModuleFileName: string;
  dwSize: DWORD;
  dwHandle: DWORD;
  buffer: array of Byte;
  pBlock: Pointer;
  pTranslations: PTranslationArray;
  cbTranslations: DWORD;
  nTranslations: Integer;
  pData: Pointer;
  cbData: DWORD;
  section: string;
  i: Integer;
begin
  Result := DefaultValue;

  // ParamStr(0) is compiled into GetModuleFileName with hModule = 0
  // https://msdn.microsoft.com/en-us/library/windows/desktop/ms683197(v=vs.85).aspx
  mainModuleFileName := ParamStr(0);

  dwSize := GetFileVersionInfoSize(PChar(mainModuleFileName), dwHandle);
  if dwSize = 0 then Exit;

  SetLength(buffer, dwSize);
  pBlock := @buffer[0];
  if GetFileVersionInfo(PChar(mainModuleFileName), dwHandle, dwSize, pBlock) then
  begin
    // Get all available translations for VersionInfo resource, and then enum them
    if VerQueryValue(pBlock, '\VarFileInfo\Translation', Pointer(pTranslations), cbTranslations) then
    begin
      nTranslations := cbTranslations div SizeOf(DWORD);
      for i := 0 to nTranslations - 1 do
      begin
        section := '\StringFileInfo\' + IntToHex(pTranslations[i].Language, 4) +
          IntToHex(pTranslations[i].CodePage, 4) + '\ProductName';
        if VerQueryValue(pBlock, PChar(section), pData, cbData) then
        begin
          // For ProductName cbData is in characters, not bytes
          SetLength(Result, cbData);
          SetString(Result, PChar(pData), Length(Result));
          Result := PChar(Result); // Remove trailing zero char
          if Result <> '' then Break; // Return any value
        end;
      end;
    end;
  end;

  if Result = '' then
    Result := DefaultValue;
end;

constructor TPlaybackMessageHook.Create(Core: IAIMPCore);
begin
  FPlayerName := GetMainModuleVerProductName('AIMP3');
  DebugOutput('Player Name: ' + FPlayerName);
  if Supports(Core, IID_IAIMPServicePlayer, FPlayer) then
    UpdateStatus(FPlayer.GetState <> AIMP_PLAYER_STATE_STOPPED);
end;

destructor TPlaybackMessageHook.Destroy;
begin
  try
    UpdateStatus(false);
    FPlayer := nil;
  except
  end;
  inherited;
end;

function TPlaybackMessageHook.GetCurrentTrackInfo: TTrackInfo;

  function GetString(info: IAIMPFileInfo; prop: Integer): string; inline;
  var s: IAIMPString;
  begin
    if info.GetValueAsObject(prop, IID_IAIMPString, s) = S_OK then Result := string(s.GetData)
      else Result := '';
  end;

  function GetDouble(info: IAIMPFileInfo; prop: Integer): Double; inline;
  var d: Double;
  begin
    if info.GetValueAsFloat(prop, d) = S_OK then Result := d
      else Result := 0;
  end;

var
  src: string;
  info: IAIMPFileInfo;
begin
  Finalize(Result);
  FillChar(Result, SizeOf(Result), 0);
  if Assigned(FPlayer) then
  begin
    if FPlayer.GetInfo(info) = S_OK then
      if Assigned(info) then
      begin
        src := GetString(info, AIMP_FILEINFO_PROPID_FILENAME);
        if FileExists(src) then
        begin
          Result.TrackType := TrackType.Music;
          Result.Length := Round(GetDouble(info, AIMP_FILEINFO_PROPID_DURATION));
          Result.Title := GetString(info, AIMP_FILEINFO_PROPID_TITLE);
          Result.Artist := GetString(info, AIMP_FILEINFO_PROPID_ARTIST);
          Result.Album := GetString(info, AIMP_FILEINFO_PROPID_ALBUM);
          Result.Track := GetString(info, AIMP_FILEINFO_PROPID_TRACKNUMBER);
          Result.Year := StrToIntDef(GetString(info, AIMP_FILEINFO_PROPID_DATE), 0);
          Result.Genre := GetString(info, AIMP_FILEINFO_PROPID_GENRE);
          Result.StationName := '';
        end else
        begin
          Result.TrackType := TrackType.Radio;
          Result.Length := 0;
          Result.Title := '';
          Result.Artist := GetString(info, AIMP_FILEINFO_PROPID_ARTIST);
          Result.Album := '';
          Result.Track := '';
          Result.Year := 0;
          Result.Genre := GetString(info, AIMP_FILEINFO_PROPID_GENRE);
          Result.StationName := GetString(info, AIMP_FILEINFO_PROPID_TITLE);
        end;
      end;
  end;
end;

procedure TPlaybackMessageHook.UpdateStatus(Playing: Boolean);
begin
  if Playing then
  begin
    DebugOutput('Playing');
    MirandaNG.ListeningTo.SendCurrentTrack(FPlayerName, GetCurrentTrackInfo);
  end else
  begin
    DebugOutput('Stopped');
    MirandaNG.ListeningTo.SendStopped(FPlayerName);
  end;
end;

procedure TPlaybackMessageHook.CoreMessage(Message: DWORD; Param1: Integer; Param2: Pointer; var Result: HRESULT);
begin
  try
    case Message of
    AIMP_MSG_EVENT_STREAM_START: UpdateStatus(true);
    AIMP_MSG_EVENT_STREAM_START_SUBTRACK: UpdateStatus(true);
    AIMP_MSG_EVENT_STREAM_END: UpdateStatus(false);
    end;
  except
  end;
  Result := E_NOTIMPL;
end;

{ Factory }

class function Factory.CreatePlayerEventsHook(ACore: IAIMPCore): IAIMPMessageHook;
begin
  Result := TPlaybackMessageHook.Create(ACore) as IAIMPMessageHook;
end;

end.
