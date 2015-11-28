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

unit apiMUI;

{$I apiConfig.inc}

interface

uses
  Windows, apiObjects;

const
  SID_IAIMPServiceMUI = '{41494D50-5372-764D-5549-000000000000}';
  IID_IAIMPServiceMUI: TGUID = SID_IAIMPServiceMUI;

type
 
  { IAIMPServiceMUI }

  IAIMPServiceMUI = interface(IUnknown)
  [SID_IAIMPServiceMUI]
    function GetName(out Value: IAIMPString): HRESULT; stdcall;
    function GetValue(KeyPath: IAIMPString; out Value: IAIMPString): HRESULT; stdcall;
    function GetValuePart(KeyPath: IAIMPString; Part: Integer; out Value: IAIMPString): HRESULT; stdcall;
  end;

implementation

end.
