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

unit apiFileManager;

{$I apiConfig.inc}

interface

uses
  Windows, apiObjects;
  
const
  SID_IAIMPFileInfo = '{41494D50-4669-6C65-496E-666F00000000}';
  IID_IAIMPFileInfo: TGUID = SID_IAIMPFileInfo;

  SID_IAIMPExtensionFileExpander = '{41494D50-4578-7446-696C-654578706472}';
  IID_IAIMPExtensionFileExpander: TGUID = SID_IAIMPExtensionFileExpander;

  SID_IAIMPExtensionFileFormat = '{41494D50-4578-7446-696C-65466D740000}';
  IID_IAIMPExtensionFileFormat: TGUID = SID_IAIMPExtensionFileFormat;

  SID_IAIMPExtensionFileInfoProvider = '{41494D50-4578-7446-696C-65496E666F00}';
  IID_IAIMPExtensionFileInfoProvider: TGUID = SID_IAIMPExtensionFileInfoProvider;

  SID_IAIMPExtensionFileInfoProviderEx = '{41494D50-4578-7446-696C-65496E666F45}';
  IID_IAIMPExtensionFileInfoProviderEx: TGUID = SID_IAIMPExtensionFileInfoProviderEx;

  SID_IAIMPVirtualFile = '{41494D50-5669-7274-7561-6C46696C6500}';
  IID_IAIMPVirtualFile: TGUID = SID_IAIMPVirtualFile;

  SID_IAIMPServiceFileManager = '{41494D50-5372-7646-696C-654D616E0000}';
  IID_IAIMPServiceFileManager: TGUID = SID_IAIMPServiceFileManager;

  SID_IAIMPServiceFileFormats =  '{41494D50-5372-7646-696C-65466D747300}';
  IID_IAIMPServiceFileFormats: TGUID = SID_IAIMPServiceFileFormats;

  SID_IAIMPServiceFileInfo = '{41494D50-5372-7646-696C-65496E666F00}';
  IID_IAIMPServiceFileInfo: TGUID = SID_IAIMPServiceFileInfo;

  SID_IAIMPServiceFileInfoFormatter = '{41494D50-5372-7646-6C49-6E66466D7400}';
  IID_IAIMPServiceFileInfoFormatter: TGUID = SID_IAIMPServiceFileInfoFormatter;

  SID_IAIMPServiceFileInfoFormatterUtils = '{41494D50-5372-7646-6C49-6E66466D7455}';
  IID_IAIMPServiceFileInfoFormatterUtils: TGUID = SID_IAIMPServiceFileInfoFormatterUtils;

  SID_IAIMPServiceFileStreaming = '{41494D50-5372-7646-696C-655374726D00}';
  IID_IAIMPServiceFileStreaming: TGUID = SID_IAIMPServiceFileStreaming;

  // PropertyID for the IAIMPFileInfo
  AIMP_FILEINFO_PROPID_CUSTOM            = 0;
  AIMP_FILEINFO_PROPID_ALBUM             = 1;
  AIMP_FILEINFO_PROPID_ALBUMART          = 2;
  AIMP_FILEINFO_PROPID_ALBUMARTIST       = 3;
  AIMP_FILEINFO_PROPID_ALBUMGAIN         = 4;
  AIMP_FILEINFO_PROPID_ALBUMPEAK         = 5;
  AIMP_FILEINFO_PROPID_ARTIST            = 6;
  AIMP_FILEINFO_PROPID_BITRATE           = 7;
  AIMP_FILEINFO_PROPID_BPM               = 8;
  AIMP_FILEINFO_PROPID_CHANNELS          = 9;
  AIMP_FILEINFO_PROPID_COMMENT           = 10;
  AIMP_FILEINFO_PROPID_COMPOSER          = 11;
  AIMP_FILEINFO_PROPID_COPYRIGHT         = 12;
  AIMP_FILEINFO_PROPID_CUESHEET          = 13;
  AIMP_FILEINFO_PROPID_DATE              = 14;
  AIMP_FILEINFO_PROPID_DISKNUMBER        = 15;
  AIMP_FILEINFO_PROPID_DISKTOTAL         = 16;
  AIMP_FILEINFO_PROPID_DURATION          = 17;
  AIMP_FILEINFO_PROPID_FILENAME          = 18;
  AIMP_FILEINFO_PROPID_FILESIZE          = 19;
  AIMP_FILEINFO_PROPID_GENRE             = 20;
  AIMP_FILEINFO_PROPID_LYRICS            = 21;
  AIMP_FILEINFO_PROPID_MARK              = 22;
  AIMP_FILEINFO_PROPID_PUBLISHER         = 23;
  AIMP_FILEINFO_PROPID_SAMPLERATE        = 24;
  AIMP_FILEINFO_PROPID_TITLE             = 25;
  AIMP_FILEINFO_PROPID_TRACKGAIN         = 26;
  AIMP_FILEINFO_PROPID_TRACKNUMBER       = 27;
  AIMP_FILEINFO_PROPID_TRACKPEAK         = 28;
  AIMP_FILEINFO_PROPID_TRACKTOTAL        = 29;
  AIMP_FILEINFO_PROPID_URL               = 30;
  AIMP_FILEINFO_PROPID_BITDEPTH          = 31;
  AIMP_FILEINFO_PROPID_CODEC             = 32;
  AIMP_FILEINFO_PROPID_STAT_ADDINGDATE    = 40;
  AIMP_FILEINFO_PROPID_STAT_LASTPLAYDATE  = 41;
  AIMP_FILEINFO_PROPID_STAT_MARK          = 42;
  AIMP_FILEINFO_PROPID_STAT_PLAYCOUNT     = 43;
  AIMP_FILEINFO_PROPID_STAT_RATING        = 44;

  // PropertyID for the IAIMPVirtualFile
  AIMP_VIRTUALFILE_PROPID_FILEURI          = 0;
  AIMP_VIRTUALFILE_PROPID_AUDIOSOURCEFILE  = 1;
  AIMP_VIRTUALFILE_PROPID_CLIPSTART        = 2;
  AIMP_VIRTUALFILE_PROPID_CLIPFINISH       = 3;
  AIMP_VIRTUALFILE_PROPID_INDEXINSET       = 4;
  AIMP_VIRTUALFILE_PROPID_FILEFORMAT       = 5;  

  // Flags for the IAIMPServiceFileFormats and IAIMPExtensionFileFormat
  AIMP_SERVICE_FILEFORMATS_CATEGORY_AUDIO     = 1;
  AIMP_SERVICE_FILEFORMATS_CATEGORY_PLAYLISTS = 2;

  // Flags for the IAIMPServiceFileManager.CreateFileStream
  AIMP_SERVICE_FILESTREAMING_FLAG_CREATENEW   = 1;
  AIMP_SERVICE_FILESTREAMING_FLAG_READWRITE   = 2;
  AIMP_SERVICE_FILESTREAMING_FLAG_MAPTOMEMORY = 4;
  
  // Flags for the IAIMPServiceFileInfo.GetFileInfoXXX
  AIMP_SERVICE_FILEINFO_FLAG_DONTUSEAUDIODECODERS = 1;
  
type

  { IAIMPFileInfo }

  IAIMPFileInfo = interface(IAIMPPropertyList)
  [SID_IAIMPFileInfo]
    function Assign(Source: IAIMPFileInfo): HRESULT; stdcall;
    function Clone(out Info: IAIMPFileInfo): HRESULT; stdcall;
  end;

  { IAIMPVirtualFile }

  IAIMPVirtualFile = interface(IAIMPPropertyList)
  [SID_IAIMPVirtualFile]
    function CreateStream(out Stream: IAIMPStream): HRESULT; stdcall;
    function GetFileInfo(Info: IAIMPFileInfo): HRESULT; stdcall;
    function IsExists: LongBool; stdcall; 
    function IsInSameStream(VirtualFile: IAIMPVirtualFile): HRESULT; stdcall;
    function Synchronize: HRESULT; stdcall;
  end;

  { IAIMPExtensionFileExpander }

  IAIMPExtensionFileExpander = interface(IUnknown)
  [SID_IAIMPExtensionFileExpander]
    function Expand(FileName: IAIMPString; out List: IAIMPObjectList; ProgressCallback: IAIMPProgressCallback): HRESULT; stdcall;
  end;

  { IAIMPExtensionFileFormat }

  IAIMPExtensionFileFormat = interface(IUnknown)
  [SID_IAIMPExtensionFileFormat]
    function GetDescription(out S: IAIMPString): HRESULT; stdcall;
    function GetExtList(out S: IAIMPString): HRESULT; stdcall;
    function GetFlags(out Flags: DWORD): HRESULT; stdcall;
  end;

  { IAIMPExtensionFileInfoProvider }

  IAIMPExtensionFileInfoProvider = interface(IUnknown)
  [SID_IAIMPExtensionFileInfoProvider]
    function GetFileInfo(FileURI: IAIMPString; Info: IAIMPFileInfo): HRESULT; stdcall;
  end;

  { IAIMPExtensionFileInfoProviderEx }

  IAIMPExtensionFileInfoProviderEx = interface(IUnknown)
  [SID_IAIMPExtensionFileInfoProviderEx]
    function GetFileInfo(Stream: IAIMPStream; Info: IAIMPFileInfo): HRESULT; stdcall;
  end;

  { IAIMPServiceFileManager }

  IAIMPServiceFileManager = interface(IUnknown)
  [SID_IAIMPServiceFileManager]
  end;

  { IAIMPServiceFileFormats }

  IAIMPServiceFileFormats = interface
  [SID_IAIMPServiceFileFormats]
    function GetFormats(Flags: DWORD; out S: IAIMPString): HRESULT; stdcall;
  	function IsSupported(FileName: IAIMPString; Flags: DWORD): HRESULT; stdcall;
  end;

  { IAIMPServiceFileInfo }

  IAIMPServiceFileInfo = interface
  [SID_IAIMPServiceFileInfo]
    // File Info
    function GetFileInfoFromFileURI(FileURI: IAIMPString; Flags: DWORD; Info: IAIMPFileInfo): HRESULT; stdcall;
    function GetFileInfoFromStream(Stream: IAIMPStream; Flags: DWORD; Info: IAIMPFileInfo): HRESULT; stdcall;
    // Virtual Files
    function GetVirtualFile(FileURI: IAIMPString; Flags: DWORD; out Info: IAIMPVirtualFile): HRESULT; stdcall;
  end;

  { IAIMPServiceFileInfoFormatter }

  IAIMPServiceFileInfoFormatter = interface(IUnknown)
  [SID_IAIMPServiceFileInfoFormatter]
    function Format(Template: IAIMPString; FileInfo: IAIMPFileInfo; Reserved: Integer;
      AdditionalInfo: IUnknown; out FormattedResult: IAIMPString): HRESULT; stdcall;
  end;

  { IAIMPServiceFileInfoFormatterUtils }

  IAIMPServiceFileInfoFormatterUtils = interface(IUnknown)
  [SID_IAIMPServiceFileInfoFormatterUtils]
    function ShowMacrosLegend(ScreenTarget: TRect; Reserved: Integer; EventsHandler: IUnknown): HRESULT; stdcall;
  end;

  { IAIMPServiceFileStreaming }

  IAIMPServiceFileStreaming = interface(IUnknown)
  [SID_IAIMPServiceFileStreaming]
    function CreateStreamForFile(FileName: IAIMPString; Flags: DWORD; const Offset, Size: Int64; out Stream: IAIMPStream): HRESULT; stdcall;
    function CreateStreamForFileURI(FileURI: IAIMPString; out VirtualFile: IAIMPVirtualFile; out Stream: IAIMPStream): HRESULT; stdcall;
  end;

implementation

end.
