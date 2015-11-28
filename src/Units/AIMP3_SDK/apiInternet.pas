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

unit apiInternet;

{$I apiConfig.inc}

interface

uses
  Windows, apiObjects, apiCore;

const
  SID_IAIMPServiceConnectionSettings = '{4941494D-5053-7276-436F-6E6E43666700}';
  IID_IAIMPServiceConnectionSettings: TGUID = SID_IAIMPServiceConnectionSettings;

  SID_IAIMPServiceHTTPClient = '{41494D50-5372-7648-7474-70436C740000}';
  IID_IAIMPServiceHTTPClient: TGUID = SID_IAIMPServiceHTTPClient;

  SID_IAIMPHTTPClientEvents = '{41494D50-4874-7470-436C-744576747300}';
  IID_IAIMPHTTPClientEvents: TGUID = SID_IAIMPHTTPClientEvents;

  // PropIDs for IAIMPServiceConnectionSettings
  AIMP_SERVICE_CONSET_PROPID_CONNECTION_TYPE = 1;
  AIMP_SERVICE_CONSET_PROPID_PROXY_SERVER    = 2;
  AIMP_SERVICE_CONSET_PROPID_PROXY_PORT      = 3;
  AIMP_SERVICE_CONSET_PROPID_PROXY_USERNAME  = 4;
  AIMP_SERVICE_CONSET_PROPID_PROXY_USERPASS  = 5;
  AIMP_SERVICE_CONSET_PROPID_TIMEOUT         = 6;
  AIMP_SERVICE_CONSET_PROPID_USERAGENT       = 7;

  // Connection Types
  AIMP_SERVICE_CONSET_CONNECTIONTYPE_DIRECT         = 0;
  AIMP_SERVICE_CONSET_CONNECTIONTYPE_PROXY          = 1;
  AIMP_SERVICE_CONSET_CONNECTIONTYPE_SYSTEMDEFAULTS = 2;

  // Flags for HTTPClient
  AIMP_SERVICE_HTTPCLIENT_FLAGS_WAITFOR         = 1;
  AIMP_SERVICE_HTTPCLIENT_FLAGS_UTF8            = 2;
  AIMP_SERVICE_HTTPCLIENT_FLAGS_PRIORITY_NORMAL = 0;
  AIMP_SERVICE_HTTPCLIENT_FLAGS_PRIORITY_LOW    = 4;
  AIMP_SERVICE_HTTPCLIENT_FLAGS_PRIORITY_HIGH   = 8;

type

  { IAIMPHTTPClientEvents }

  IAIMPHTTPClientEvents = interface
  [SID_IAIMPHTTPClientEvents]
    procedure OnAccept(ContentType: IAIMPString; const ContentSize: Int64; var Allow: LongBool); stdcall;
    procedure OnComplete(ErrorInfo: IAIMPErrorInfo; Canceled: LongBool); stdcall;
    procedure OnProgress(const Downloaded: Int64; const Total: Int64); stdcall;
  end;

  { IAIMPServiceConnectionSettings }

  IAIMPServiceConnectionSettings = interface(IAIMPPropertyList)
  [SID_IAIMPServiceConnectionSettings]
  end;

  { IAIMPServiceHTTPClient }

  IAIMPServiceHTTPClient = interface(IUnknown)
  [SID_IAIMPServiceHTTPClient]
    function Get(URL: IAIMPString; Flags: DWORD; AnswerData: IAIMPStream;
      EventsHandler: IAIMPHTTPClientEvents; Params: IAIMPConfig; out TaskID: Pointer): HRESULT; stdcall;
    function Post(URL: IAIMPString; Flags: DWORD; AnswerData, PostData: IAIMPStream;
      EventsHandler: IAIMPHTTPClientEvents; Params: IAIMPConfig; out TaskID: Pointer): HRESULT; stdcall;
    function Cancel(TaskID: Pointer; Flags: DWORD): HRESULT; stdcall;
  end;

implementation

end.
