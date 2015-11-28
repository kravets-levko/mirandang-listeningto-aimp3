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

unit apiPlaylists;

{$I apiConfig.inc}

interface

uses
  Windows, apiObjects;

const
  SID_IAIMPPlaylist = '{41494D50-506C-7300-0000-000000000000}';
  IID_IAIMPPlaylist: TGUID = SID_IAIMPPlaylist;

  SID_IAIMPPlaylistItem = '{41494D50-506C-7349-7465-6D0000000000}';
  IID_IAIMPPlaylistItem: TGUID = SID_IAIMPPlaylistItem;

  SID_IAIMPPlaylistGroup = '{41494D50-506C-7347-726F-757000000000}';
  IID_IAIMPPlaylistGroup: TGUID = SID_IAIMPPlaylistGroup;

  SID_IAIMPPlaylistListener = '{41494D50-506C-734C-7374-6E7200000000}';
  IID_IAIMPPlaylistListener: TGUID = SID_IAIMPPlaylistListener;

  SID_IAIMPPlaylistQueue = '{41494D50-506C-7351-7565-756500000000}';
  IID_IAIMPPlaylistQueue: TGUID = SID_IAIMPPlaylistQueue;

  SID_IAIMPExtensionPlaylistManagerListener = '{41494D50-4578-7450-6C73-4D616E4C7472}';
  IID_IAIMPExtensionPlaylistManagerListener: TGUID = SID_IAIMPExtensionPlaylistManagerListener;

  SID_IAIMPServicePlaylistManager = '{41494D50-5372-7650-6C73-4D616E000000}';
  IID_IAIMPServicePlaylistManager: TGUID = SID_IAIMPServicePlaylistManager;

  // Property IDs for IAIMPPlaylistItem
  AIMP_PLAYLISTITEM_PROPID_DISPLAYTEXT        = 1;
  AIMP_PLAYLISTITEM_PROPID_FILEINFO           = 2;
  AIMP_PLAYLISTITEM_PROPID_FILENAME           = 3;
  AIMP_PLAYLISTITEM_PROPID_GROUP              = 4;
  AIMP_PLAYLISTITEM_PROPID_INDEX              = 5;
  AIMP_PLAYLISTITEM_PROPID_MARK               = 6;
  AIMP_PLAYLISTITEM_PROPID_PLAYINGSWITCH      = 7;
  AIMP_PLAYLISTITEM_PROPID_PLAYLIST           = 8;
  AIMP_PLAYLISTITEM_PROPID_SELECTED           = 9;
  AIMP_PLAYLISTITEM_PROPID_PLAYBACKQUEUEINDEX = 10;

  // Property IDs for IAIMPPlaylistGroup
  AIMP_PLAYLISTGROUP_PROPID_NAME      = 1;
  AIMP_PLAYLISTGROUP_PROPID_EXPANDED  = 2;
  AIMP_PLAYLISTGROUP_PROPID_DURATION  = 3;
  AIMP_PLAYLISTGROUP_PROPID_INDEX     = 4;
  AIMP_PLAYLISTGROUP_PROPID_SELECTED  = 5;

  // Property IDs for IAIMPPropertyList from IAIMPPlaylistQueue
  AIMP_PLAYLISTQUEUE_PROPID_SUSPENDED = 1;

  // Property IDs for IAIMPPropertyList from IAIMPPlaylist
  AIMP_PLAYLIST_PROPID_NAME                     = 1;
  AIMP_PLAYLIST_PROPID_READONLY                 = 2;
  AIMP_PLAYLIST_PROPID_FOCUSED_OBJECT           = 3;
  AIMP_PLAYLIST_PROPID_ID                       = 4;
  AIMP_PLAYLIST_PROPID_GROUPPING                = 10;
  AIMP_PLAYLIST_PROPID_GROUPPING_OVERRIDEN      = 11;
  AIMP_PLAYLIST_PROPID_GROUPPING_TEMPLATE       = 12;
  AIMP_PLAYLIST_PROPID_GROUPPING_AUTOMERGING    = 13;
  AIMP_PLAYLIST_PROPID_FORMATING_OVERRIDEN      = 20;
  AIMP_PLAYLIST_PROPID_FORMATING_LINE1_TEMPLATE = 21;
  AIMP_PLAYLIST_PROPID_FORMATING_LINE2_TEMPLATE = 22;
  AIMP_PLAYLIST_PROPID_VIEW_OVERRIDEN           = 30;
  AIMP_PLAYLIST_PROPID_VIEW_DURATION            = 31;
  AIMP_PLAYLIST_PROPID_VIEW_EXPAND_BUTTONS      = 32;
  AIMP_PLAYLIST_PROPID_VIEW_MARKS               = 33;
  AIMP_PLAYLIST_PROPID_VIEW_NUMBERS             = 34;
  AIMP_PLAYLIST_PROPID_VIEW_NUMBERS_ABSOLUTE    = 35;
  AIMP_PLAYLIST_PROPID_VIEW_SECOND_LINE         = 36;
  AIMP_PLAYLIST_PROPID_VIEW_SWITCHES            = 37;
  AIMP_PLAYLIST_PROPID_FOCUSINDEX               = 50;
  AIMP_PLAYLIST_PROPID_PLAYBACKCURSOR           = 51;
  AIMP_PLAYLIST_PROPID_PLAYINGINDEX             = 52;
  AIMP_PLAYLIST_PROPID_SIZE                     = 53;
  AIMP_PLAYLIST_PROPID_DURATION                 = 54;
  AIMP_PLAYLIST_PROPID_PREIMAGE                 = 60;

  // Flags for IAIMPPlaylist.Add & IAIMPPlaylist.AddList
  AIMP_PLAYLIST_ADD_FLAGS_NOCHECKFORMAT = 1;
  AIMP_PLAYLIST_ADD_FLAGS_NOEXPAND      = 2;
  AIMP_PLAYLIST_ADD_FLAGS_NOASYNC       = 4;
  AIMP_PLAYLIST_ADD_FLAGS_FILEINFO      = 8;

  // Flags for IAIMPPlaylist.Sort
  AIMP_PLAYLIST_SORTMODE_TITLE      = 1;
  AIMP_PLAYLIST_SORTMODE_FILENAME   = 2;
  AIMP_PLAYLIST_SORTMODE_DURATION   = 3;
  AIMP_PLAYLIST_SORTMODE_ARTIST     = 4;
  AIMP_PLAYLIST_SORTMODE_INVERSE    = 5;
  AIMP_PLAYLIST_SORTMODE_RANDOMIZE  = 6;

  // Flags for IAIMPPlaylist.Close
  AIMP_PLAYLIST_CLOSE_FLAGS_FORCE_REMOVE = 1;
  AIMP_PLAYLIST_CLOSE_FLAGS_FORCE_UNLOAD = 2;

  // Flags for IAIMPPlaylist.GetFiles:
  AIMP_PLAYLIST_GETFILES_FLAGS_SELECTED_ONLY    = $1;
  AIMP_PLAYLIST_GETFILES_FLAGS_VISIBLE_ONLY     = $2;
  AIMP_PLAYLIST_GETFILES_FLAGS_COLLAPSE_VIRTUAL = $4;

  // Flags for IAIMPPlaylistListener.Changed
  AIMP_PLAYLIST_NOTIFY_NAME           = 1;
  AIMP_PLAYLIST_NOTIFY_SELECTION      = 2;
  AIMP_PLAYLIST_NOTIFY_PLAYBACKCURSOR = 4;
  AIMP_PLAYLIST_NOTIFY_READONLY       = 8;
  AIMP_PLAYLIST_NOTIFY_FOCUSINDEX     = 16;
  AIMP_PLAYLIST_NOTIFY_CONTENT        = 32;
  AIMP_PLAYLIST_NOTIFY_FILEINFO       = 64;
  AIMP_PLAYLIST_NOTIFY_STATISTICS     = 128;
  AIMP_PLAYLIST_NOTIFY_PLAYINGSWITCHS = 256;
  AIMP_PLAYLIST_NOTIFY_PREIMAGE       = 512;

type

  { IAIMPPlaylistItem }

  IAIMPPlaylistItem = interface(IAIMPPropertyList)
  [SID_IAIMPPlaylistItem]
    function ReloadInfo: HRESULT; stdcall;
  end;

  { IAIMPPlaylistGroup }

  IAIMPPlaylistGroup = interface(IAIMPPropertyList)
  [SID_IAIMPPlaylistGroup]
    function GetItem(Index: Integer; const IID: TGUID; out Obj): HRESULT; stdcall;
    function GetItemCount: Integer; stdcall;
  end;

  { IAIMPPlaylistListener }

  IAIMPPlaylistListener = interface(IUnknown)
  [SID_IAIMPPlaylistListener]
    procedure Activated; stdcall; 
    procedure Changed(Flags: DWORD); stdcall;
    procedure Removed; stdcall;
  end;

  { IAIMPPlaylist }

  TAIMPPlaylistCompareProc = function (Item1, Item2: IAIMPPlaylistItem; UserData: Pointer): Integer; stdcall;
  TAIMPPlaylistDeleteProc = function (Item: IAIMPPlaylistItem; UserData: Pointer): LongBool; stdcall;

  IAIMPPlaylist = interface(IUnknown)
  [SID_IAIMPPlaylist]
    // Adding
    function Add(Obj: IUnknown; Flags: DWORD; InsertIn: Integer): HRESULT; stdcall;
    function AddList(ObjList: IAIMPObjectList; Flags: DWORD; InsertIn: Integer): HRESULT; stdcall;
    // Deleting
    function Delete(Item: IAIMPPlaylistItem): HRESULT; stdcall;
    function Delete2(ItemIndex: Integer): HRESULT; stdcall;
    function Delete3(Physically: LongBool; Proc: TAIMPPlaylistDeleteProc; UserData: Pointer): HRESULT; stdcall;
    function DeleteAll: HRESULT; stdcall;
    // Sorting
    function Sort(Mode: Integer): HRESULT; stdcall;
    function Sort2(Template: IAIMPString): HRESULT; stdcall;
    function Sort3(Proc: TAIMPPlaylistCompareProc; UserData: Pointer): HRESULT; stdcall;
    // Locking
    function BeginUpdate: HRESULT; stdcall;
    function EndUpdate: HRESULT; stdcall;
    // Another Commands
    function Close(Flags: DWORD): HRESULT; stdcall;
    function GetFiles(Flags: DWORD; out List: IAIMPObjectList): HRESULT; stdcall;
    function MergeGroup(Group: IAIMPPlaylistGroup): HRESULT; stdcall;
    function ReloadFromPreimage: HRESULT; stdcall;
    function ReloadInfo(Full: LongBool): HRESULT; stdcall;
    // Items
    function GetItem(Index: Integer; const IID: TGUID; out Obj): HRESULT; stdcall;
    function GetItemCount: Integer; stdcall;
    // Groups
    function GetGroup(Index: Integer; const IID: TGUID; out Obj): HRESULT; stdcall;
    function GetGroupCount: Integer; stdcall;
    // Listener
    function ListenerAdd(AListener: IAIMPPlaylistListener): HRESULT; stdcall;
    function ListenerRemove(AListener: IAIMPPlaylistListener): HRESULT; stdcall;
  end;

  { IAIMPPlaylistQueue }

  IAIMPPlaylistQueue = interface(IUnknown)
  [SID_IAIMPPlaylistQueue]
    // Adding
    function Add(Item: IAIMPPlaylistItem; InsertAtBeginning: LongBool): HRESULT; stdcall;
    function AddList(ItemList: IAIMPObjectList; InsertAtBeginning: LongBool): HRESULT; stdcall;
    // Deleting
    function Delete(Item: IAIMPPlaylistItem): HRESULT; stdcall;
    function Delete2(Playlist: IAIMPPlaylist): HRESULT; stdcall;
    // Reorder
    function Move(Item: IAIMPPlaylistItem; TargetIndex: Integer): HRESULT; stdcall;
    function Move2(ItemIndex, TargetIndex: Integer): HRESULT; stdcall;
    // Items
    function GetItem(Index: Integer; const IID: TGUID; out Obj): HRESULT; stdcall;
    function GetItemCount: Integer; stdcall;
  end;

  { IAIMPExtensionPlaylistManagerListener }

  IAIMPExtensionPlaylistManagerListener = interface(IUnknown)
  [SID_IAIMPExtensionPlaylistManagerListener]
    procedure PlaylistActivated(Playlist: IAIMPPlaylist); stdcall;
    procedure PlaylistAdded(Playlist: IAIMPPlaylist); stdcall;
    procedure PlaylistRemoved(Playlist: IAIMPPlaylist); stdcall;
  end;

  { IAIMPServicePlaylistManager }

  IAIMPServicePlaylistManager = interface(IUnknown)
  [SID_IAIMPServicePlaylistManager]
    // Creating Playlist
    function CreatePlaylist(Name: IAIMPString; Activate: LongBool; out Playlist: IAIMPPlaylist): HRESULT; stdcall;
    function CreatePlaylistFromFile(FileName: IAIMPString; Activate: LongBool; out Playlist: IAIMPPlaylist): HRESULT; stdcall;
    // Active Playlist
    function GetActivePlaylist(out Playlist: IAIMPPlaylist): HRESULT; stdcall;
    function SetActivePlaylist(Playlist: IAIMPPlaylist): HRESULT; stdcall;
    // Playable Playlist
    function GetPlayablePlaylist(out Playlist: IAIMPPlaylist): HRESULT; stdcall;
    // Loaded Playlists
    function GetLoadedPlaylist(Index: Integer; out Playlist: IAIMPPlaylist): HRESULT; stdcall;
    function GetLoadedPlaylistByName(Name: IAIMPString; out Playlist: IAIMPPlaylist): HRESULT; stdcall;
    function GetLoadedPlaylistCount: Integer; stdcall;
    function GetLoadedPlaylistByID(ID: IAIMPString; out Playlist: IAIMPPlaylist): HRESULT; stdcall;
  end;

implementation

end.
