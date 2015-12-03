unit AIMP3.EventsHook;

interface

uses
  Windows, apiCore, apiMessages, apiPlayer, MirandaNG.ListeningTo, App.Utils;

type
  TPlaybackMessageHook = class(TInterfacedObject, IAIMPMessageHook)
  protected
    FPlayerName: string;
    FPlayer: IAIMPServicePlayer;
    FMirandaPlugin: MirandaNG.ListeningTo.TPluginInterface;
    function GetCurrentTrackInfo: TTrackInfo;
    procedure UpdateStatus(Playing: Boolean);
  protected
    procedure CoreMessage(Message: DWORD; Param1: Integer; Param2: Pointer; var Result: HRESULT); stdcall;
  public
    constructor Create(Core: IAIMPCore); virtual;
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils, apiObjects, apiFileManager;

const
  AIMP_PLAYER_STATE_STOPPED = 0;
  AIMP_PLAYER_STATE_PAUSED  = 1;
  AIMP_PLAYER_STATE_PLAYING = 2;

constructor TPlaybackMessageHook.Create(Core: IAIMPCore);
begin
  FPlayerName := GetMainModuleVerProductName('AIMP3');
  {$IFDEF DEBUG}
  DebugOutput('Player Name: ' + FPlayerName);
  {$ENDIF}
  FMirandaPlugin := MirandaNG.ListeningTo.TPluginInterface.Create;
  if Supports(Core, IID_IAIMPServicePlayer, FPlayer) then
    UpdateStatus(FPlayer.GetState <> AIMP_PLAYER_STATE_STOPPED);
end;

destructor TPlaybackMessageHook.Destroy;
begin
  try
    UpdateStatus(false);
    FPlayer := nil;
    FreeAndNil(FMirandaPlugin);
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
  Result := TTrackInfo.Empty;
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
          Result.Title := GetString(info, AIMP_FILEINFO_PROPID_TITLE);
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
  if Playing and Assigned(FMirandaPlugin) then
  begin
    {$IFDEF DEBUG}
    DebugOutput('Playing');
    {$ENDIF}
    FMirandaPlugin.SendPlaying(FPlayerName, GetCurrentTrackInfo);
  end else
  begin
    {$IFDEF DEBUG}
    DebugOutput('Stopped');
    {$ENDIF}
    FMirandaPlugin.SendStopped(FPlayerName);
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

end.
