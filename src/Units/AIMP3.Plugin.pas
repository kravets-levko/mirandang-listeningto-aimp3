unit AIMP3.Plugin;

interface

implementation

uses
  SysUtils, Windows, apiCore, apiPlugin, apiMessages, AIMP3.EventsHook;

const
  sPluginName = 'Miranda NG ListeningTo Support Plugin';
  sPluginAuthor = 'Levko Kravets';
  sPluginShortDescription = 'Allows to send information about current track to Miranda NG ListeningTo plugin.';

type
  TAIMPCustomServicePlugin = class(TInterfacedObject, IAIMPPlugin)
  protected
    FMessageDispatcher: IAIMPServiceMessageDispatcher;
    FHook: IAIMPMessageHook;
  protected
    { IAIMPPlugin }
    function InfoGet(Index: Integer): PWideChar; stdcall;
    function InfoGetCategories: DWORD; stdcall;
    function Initialize(Core: IAIMPCore): HRESULT; stdcall;
    procedure Finalize; stdcall;
    procedure SystemNotification(NotifyID: Integer; Data: IUnknown); stdcall;
  end;

function TAIMPCustomServicePlugin.InfoGet(Index: Integer): PWideChar;
begin
  case Index of
  AIMP_PLUGIN_INFO_NAME: Result := sPluginName;
  AIMP_PLUGIN_INFO_AUTHOR: Result := sPluginAuthor;
  AIMP_PLUGIN_INFO_SHORT_DESCRIPTION: Result := sPluginShortDescription;
  else Result := nil;
  end;
end;

function TAIMPCustomServicePlugin.InfoGetCategories: Cardinal;
begin
  Result := AIMP_PLUGIN_CATEGORY_ADDONS;
end;

function TAIMPCustomServicePlugin.Initialize(Core: IAIMPCore): HRESULT;
begin
  try
    Result := S_OK;
    if Supports(Core, IID_IAIMPServiceMessageDispatcher, FMessageDispatcher) then
    begin
      FHook := AIMP3.EventsHook.Factory.CreatePlayerEventsHook(Core);
      Result := FMessageDispatcher.Hook(FHook);
    end;
  except
    Result := E_FAIL;
  end;
end;

procedure TAIMPCustomServicePlugin.SystemNotification(NotifyID: Integer; Data: IInterface);
begin
end;

procedure TAIMPCustomServicePlugin.Finalize;
begin
  try
    if Assigned(FMessageDispatcher) and Assigned(FHook) then
    begin
      FMessageDispatcher.Unhook(FHook);
    end;
    FMessageDispatcher := nil;
    FHook := nil;
  except
  end;
end;

function AIMPPluginGetHeader(out Header: IAIMPPlugin): HRESULT; stdcall;
begin
  try
    Header := TAIMPCustomServicePlugin.Create;
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

exports
  AIMPPluginGetHeader name 'AIMPPluginGetHeader';

end.
