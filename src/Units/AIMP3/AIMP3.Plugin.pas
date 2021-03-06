unit AIMP3.Plugin;

interface

uses
  Windows, apiCore, apiPlugin, apiMessages;

type
  TAIMPCustomServicePlugin = class(TInterfacedObject, IAIMPPlugin)
  protected
    FMessageDispatcher: IAIMPServiceMessageDispatcher;
    FHook: IAIMPMessageHook;
  protected
    FPluginName: string;
    FPluginAuthor: string;
    FPluginShortDescription: string;
  protected
    { IAIMPPlugin }
    function InfoGet(Index: Integer): PWideChar; stdcall;
    function InfoGetCategories: DWORD; stdcall;
    function Initialize(Core: IAIMPCore): HRESULT; stdcall;
    procedure Finalize; stdcall;
    procedure SystemNotification(NotifyID: Integer; Data: IUnknown); stdcall;
  public
    constructor Create;
  end;

implementation

uses
  SysUtils, App.Utils, AIMP3.EventsHook;

constructor TAIMPCustomServicePlugin.Create;
begin
  GetThisModuleVerInfo(FPluginName, FPluginShortDescription, FPluginAuthor);
  {$IFDEF DEBUG}
  DebugOutput('Plugin.Name: ' + FPluginName);
  DebugOutput('Plugin.ShortDescription: ' + FPluginShortDescription);
  DebugOutput('Plugin.Author: ' + FPluginAuthor);
  {$ENDIF}
end;

function TAIMPCustomServicePlugin.InfoGet(Index: Integer): PWideChar;
begin
  case Index of
  AIMP_PLUGIN_INFO_NAME: Result := PWideChar(FPluginName);
  AIMP_PLUGIN_INFO_AUTHOR: Result := PWideChar(FPluginAuthor);
  AIMP_PLUGIN_INFO_SHORT_DESCRIPTION: Result := PWideChar(FPluginShortDescription);
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
      FHook := TPlaybackMessageHook.Create(Core) as IAIMPMessageHook;
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

end.
