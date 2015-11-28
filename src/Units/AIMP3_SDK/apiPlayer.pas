{************************************************}
{*                                              *}
{*          AIMP Programming Interface          *}
{*               v3.60 build 1455               *}
{*                                              *}
{*                Artem Izmaylov                *}
{*                (C) 2006-2015                 *}
{*                 www.aimp.ru                  *}
{*              ICQ: 345-908-513                *}
{*            Mail: support@aimp.ru             *}
{*                                              *}
{************************************************}

unit apiPlayer;

{$I apiConfig.inc}

interface

uses
  Windows, apiCore, apiFileManager, apiObjects, apiPlaylists;

const
  SID_IAIMPPlaybackQueueItem = '{41494D50-506C-6179-6261-636B5149746D}';
  IID_IAIMPPlaybackQueueItem: TGUID = SID_IAIMPPlaybackQueueItem;

  SID_IAIMPExtensionPlaybackQueue = '{41494D50-4578-7450-6C61-796261636B51}';
  IID_IAIMPExtensionPlaybackQueue: TGUID = SID_IAIMPExtensionPlaybackQueue;

  SID_IAIMPServicePlaybackQueue = '{41494D50-5372-7650-6C62-61636B510000}';
  IID_IAIMPServicePlaybackQueue: TGUID = SID_IAIMPServicePlaybackQueue;

  SID_IAIMPServicePlayer = '{41494D50-5372-7650-6C61-796572000000}';
  IID_IAIMPServicePlayer: TGUID = SID_IAIMPServicePlayer;

  SID_IAIMPExtensionPlayerHook = '{41494D50-4578-7450-6C72-486F6F6B0000}';
  IID_IAIMPExtensionPlayerHook: TGUID = SID_IAIMPExtensionPlayerHook;

  // PropIDs for IAIMPPlaybackQueueItem
  AIMP_PLAYBACKQUEUEITEM_PROPID_CUSTOM       = 0;
  AIMP_PLAYBACKQUEUEITEM_PROPID_PLAYLISTITEM = 1;

  // Flags for IAIMPExtensionPlaybackQueue.GetNext / GetPrev
  AIMP_PLAYBACKQUEUE_FLAGS_START_FROM_BEGINNING = 1;
  AIMP_PLAYBACKQUEUE_FLAGS_START_FROM_CURSOR    = 2;
  AIMP_PLAYBACKQUEUE_FLAGS_START_FROM_ITEM      = 3;

  // Flags for IAIMPServicePlayer.Play4
  AIMP_SERVICE_PLAYER_FLAGS_PLAY_FROM_PLAYLIST              = 1;
  AIMP_SERVICE_PLAYER_FLAGS_PLAY_FROM_PLAYLIST_CAN_ADD      = 2;
  AIMP_SERVICE_PLAYER_FLAGS_PLAY_WITHOUT_ADDING_TO_PLAYLIST = 4;
  
type

  { IAIMPPlaybackQueueItem }

  IAIMPPlaybackQueueItem = interface(IAIMPPropertyList)
  [SID_IAIMPPlaybackQueueItem]
  end;

  { IAIMPExtensionPlayerHook }

  IAIMPExtensionPlayerHook = interface(IUnknown)
  [SID_IAIMPExtensionPlayerHook]
    procedure OnCheckURL(URL: IAIMPString; var Handled: LongBool); stdcall;
  end;

  { IAIMPExtensionPlaybackQueue }

  IAIMPExtensionPlaybackQueue = interface(IUnknown)
  [SID_IAIMPExtensionPlaybackQueue]
    function GetNext(Current: IUnknown; Flags: DWORD; QueueItem: IAIMPPlaybackQueueItem): LongBool; stdcall;
    function GetPrev(Current: IUnknown; Flags: DWORD; QueueItem: IAIMPPlaybackQueueItem): LongBool; stdcall;
    procedure OnSelect(Item: IAIMPPlaylistItem; QueueItem: IAIMPPlaybackQueueItem); stdcall;
  end;

  { IAIMPServicePlayer }

  IAIMPServicePlayer = interface(IUnknown)
  [SID_IAIMPServicePlayer]
    // Start Playback
    function Play(Item: IAIMPPlaybackQueueItem): HRESULT; stdcall;
    function Play2(Item: IAIMPPlaylistItem): HRESULT; stdcall;
    function Play3(Playlist: IAIMPPlaylist): HRESULT; stdcall;
    function Play4(FileURI: IAIMPString; Flags: DWORD): HRESULT; stdcall;
    // Navigation
    function GoToNext: HRESULT; stdcall;
    function GoToPrev: HRESULT; stdcall;
    // Playable File Control
    function GetDuration(out Seconds: Double): HRESULT; stdcall;
    function GetPosition(out Seconds: Double): HRESULT; stdcall;
    function SetPosition(const Seconds: Double): HRESULT; stdcall;
    function GetMute(out Value: LongBool): HRESULT; stdcall;
    function SetMute(const Value: LongBool): HRESULT; stdcall;
    function GetVolume(out Level: Single): HRESULT; stdcall;
    function SetVolume(const Level: Single): HRESULT; stdcall;
    function GetInfo(out FileInfo: IAIMPFileInfo): HRESULT; stdcall;
    function GetPlaylistItem(out Item: IAIMPPlaylistItem): HRESULT; stdcall;
    function GetState: Integer; stdcall;
    function Pause: HRESULT; stdcall;
    function Resume: HRESULT; stdcall;
    function Stop: HRESULT; stdcall;
    function StopAfterTrack: HRESULT; stdcall;
  end;

  { IAIMPServicePlaybackQueue }

  IAIMPServicePlaybackQueue = interface(IUnknown)
  [SID_IAIMPServicePlaybackQueue]
    function GetNextTrack(out Item: IAIMPPlaybackQueueItem): HRESULT; stdcall;
    function GetPrevTrack(out Item: IAIMPPlaybackQueueItem): HRESULT; stdcall;
  end;

implementation

end.
