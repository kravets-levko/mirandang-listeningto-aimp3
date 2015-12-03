unit App.ModuleExports;

interface

implementation

uses
  apiPlugin, AIMP3.Plugin;

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
