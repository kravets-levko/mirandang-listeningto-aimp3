{************************************************}
{*                                              *}
{*          AIMP Programming Interface          *}
{*                Basic Wrappers                *}
{*                                              *}
{*                Artem Izmaylov                *}
{*                (C) 2006-2014                 *}
{*                 www.aimp.ru                  *}
{*              ICQ: 345-908-513                *}
{*            Mail: support@aimp.ru             *}
{*                                              *}
{************************************************}

unit apiWrappers;

{$I apiConfig.inc}

interface

uses
  Windows, Classes, apiCore, apiObjects, apiFileManager, apiMUI;

type
{$IFNDEF UNICODE}
  UnicodeString = WideString;
{$ENDIF}

  { TAIMPAPIWrappers }

  TAIMPAPIWrappers = class
  public
    class procedure Finalize;
    class procedure Initialize(Core: IAIMPCore);
  end;

  { TAIMPExtensionFileFormat }

  TAIMPExtensionFileFormat = class(TInterfacedObject, IAIMPExtensionFileFormat)
  private
    FDescription: UnicodeString;
    FExtList: UnicodeString;
    FFlags: Cardinal;
  public
    constructor Create(const ADescription, AExtList: UnicodeString; AFlags: Cardinal = AIMP_SERVICE_FILEFORMATS_CATEGORY_AUDIO);
    // IAIMPExtensionFileFormat
    function GetDescription(out S: IAIMPString): HRESULT; stdcall;
    function GetExtList(out S: IAIMPString): HRESULT; stdcall;
    function GetFlags(out Flags: Cardinal): HRESULT; stdcall;
  end;

  { TAIMPPropertyList }

  TAIMPPropertyList = class(TInterfacedObject, IAIMPPropertyList)
  private
    // IAIMPPropertyList
    procedure BeginUpdate; stdcall;
    procedure EndUpdate; stdcall;
    function GetValueAsFloat(PropertyID: Integer; out Value: Double): HRESULT; stdcall;
    function GetValueAsInt32(PropertyID: Integer; out Value: Integer): HRESULT; stdcall;
    function GetValueAsInt64(PropertyID: Integer; out Value: Int64): HRESULT; stdcall;
    function GetValueAsObject(PropertyID: Integer; const IID: TGUID; out Value): HRESULT; stdcall;
    function SetValueAsFloat(PropertyID: Integer; const Value: Double): HRESULT; stdcall;
    function SetValueAsInt32(PropertyID: Integer; Value: Integer): HRESULT; stdcall;
    function SetValueAsInt64(PropertyID: Integer; const Value: Int64): HRESULT; stdcall;
    function SetValueAsObject(PropertyID: Integer; Value: IInterface): HRESULT; stdcall;
    function Reset: HRESULT; stdcall;
  protected
    FCustomObject: IUnknown;
    function CheckAccess(var AResult: HRESULT): Boolean; virtual;
    // IAIMPPropertyList
    procedure DoBeginUpdate; virtual;
    procedure DoEndUpdate; virtual;
    function DoGetValueAsFloat(PropertyID: Integer; out Value: Double): HRESULT; virtual;
    function DoGetValueAsInt32(PropertyID: Integer; out Value: Integer): HRESULT; virtual;
    function DoGetValueAsInt64(PropertyID: Integer; out Value: Int64): HRESULT; virtual;
    function DoGetValueAsObject(PropertyID: Integer): IUnknown; virtual;
    function DoSetValueAsFloat(PropertyID: Integer; const Value: Double): HRESULT; virtual;
    function DoSetValueAsInt32(PropertyID: Integer; const Value: Integer): HRESULT; virtual;
    function DoSetValueAsInt64(PropertyID: Integer; const Value: Int64): HRESULT; virtual;
    function DoSetValueAsObject(PropertyID: Integer; const Value: IUnknown): HRESULT; virtual;
    function DoReset: HRESULT; virtual;
  end;

  { TAIMPServiceConfig }

  TAIMPServiceConfig = class(TObject)
  private
    FService: IAIMPServiceConfig;
  public
    constructor Create;
    // Reading
    function ReadBool(const AKeyPath: UnicodeString; const ADefault: Boolean = False): Boolean;
    function ReadFloat(const AKeyPath: UnicodeString; const ADefault: Double = 0): Double;
    function ReadInt64(const AKeyPath: UnicodeString; const ADefault: Int64 = 0): Int64;
    function ReadInteger(const AKeyPath: UnicodeString; const ADefault: Integer = 0): Integer;
    function ReadString(const AKeyPath: UnicodeString; const ADefault: UnicodeString = ''): UnicodeString;
    // Writing
    procedure WriteBool(const AKeyPath: UnicodeString; const AValue: Boolean);
    procedure WriteFloat(const AKeyPath: UnicodeString; const AValue: Double);
    procedure WriteInt64(const AKeyPath: UnicodeString; const AValue: Int64);
    procedure WriteInteger(const AKeyPath: UnicodeString; const AValue: Integer);
    procedure WriteString(const AKeyPath: UnicodeString; const AValue: UnicodeString);
    //
    property Service: IAIMPServiceConfig read FService;
  end;

  { TAIMPStreamWrapper }

  TAIMPStreamWrapper = class(TStream)
  private
    FSource: IAIMPStream;
  protected
    function GetSize: Int64; override;
    procedure SetSize(const NewSize: Int64); override;
  public
    constructor Create(ASource: IAIMPStream); virtual;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

  { TAIMPStreamAdapter }

  TAIMPStreamAdapter = class(TInterfacedObject, IAIMPStream)
  strict private
    FOwnership: TStreamOwnership;
  protected
    FSource: TStream;
    FSourceIsReadOnly: Boolean;

    function TestSource(ASource: TStream): Boolean; virtual;
    // IAIMPStream
    function GetSize: Int64; stdcall;
    function SetSize(const Value: Int64): HRESULT; stdcall;
    function GetPosition: Int64; stdcall;
    function Seek(const Offset: Int64; Mode: Integer): HRESULT; stdcall;
    function Read(Buffer: PByte; Count: DWORD): Integer; stdcall;
    function Write(Buffer: PByte; Count: DWORD; Written: PDWORD = nil): HRESULT; stdcall;
  public
    constructor Create(ASource: TStream; AOwnership: TStreamOwnership = soOwned);
    destructor Destroy; override;
  end;

  { TAIMPMemoryStreamAdapter }

  TAIMPMemoryStreamAdapter = class(TAIMPStreamAdapter, IAIMPMemoryStream)
  protected
    function TestSource(ASource: TStream): Boolean; override;
    // IAIMPMemoryStream
    function GetData: PByte; stdcall;
  public
    constructor Create; overload;
  end;

  { TAIMPFileStreamAdapter }

  TAIMPFileStreamAdapter = class(TAIMPStreamAdapter, IAIMPFileStream)
  protected
    function CreateStream(const AFileName: UnicodeString; AMode: Integer): TStream; virtual;
    function TestSource(ASource: TStream): Boolean; override;
    // IAIMPFileStream
    function GetClipping(out Offset, Size: Int64): HRESULT; virtual; stdcall;
    function GetFileName(out S: IAIMPString): HRESULT; stdcall;
  public
    constructor Create(const AFileName: IAIMPString; AMode: Integer); overload;
    constructor Create(const AFileName: UnicodeString; AMode: Integer); overload;
  end;

procedure CheckResult(R: HRESULT; const AMessage: string = '%d');

// Core
procedure CoreCreateObject(const IID: TGUID; out Obj);
function CoreGetProfilePath: UnicodeString;
function CoreGetService(const IID: TGUID; out Obj): LongBool; {$IFDEF INLINE_SUPPORTED}inline;{$ENDIF}
function CoreIntf: IAIMPCore;

// Window Handles
function MainWindowGetHandle: HWND;

// Localizations
function LangGetName: UnicodeString;
function LangLoadString(const KeyPath: UnicodeString): UnicodeString; overload;
function LangLoadString(const KeyPath: UnicodeString; out AValue: IAIMPString): HRESULT; overload;
function LangLoadString(const KeyPath: UnicodeString; APartIndex: Integer): UnicodeString; overload;
function LangLoadString(const KeyPath: UnicodeString; APartIndex: Integer; out AValue: IAIMPString): HRESULT; overload;

// Strings
function IAIMPStringToString(const S: IAIMPString): UnicodeString; {$IFDEF INLINE_SUPPORTED}inline;{$ENDIF}
function MakeString(const S: PWideChar; ALength: Integer): IAIMPString; overload;
function MakeString(const S: PWideChar; ALength: Integer; out R: IAIMPString): HRESULT; overload;
function MakeString(const S: UnicodeString): IAIMPString; overload; {$IFDEF INLINE_SUPPORTED}inline;{$ENDIF}
function MakeString(const S: UnicodeString; out R: IAIMPString): HRESULT; overload; {$IFDEF INLINE_SUPPORTED}inline;{$ENDIF}
function PropListGetStr(const List: IAIMPPropertyList; ID: Integer; out S: IAIMPString): LongBool; overload; {$IFDEF INLINE_SUPPORTED}inline;{$ENDIF}
function PropListGetStr(const List: IAIMPPropertyList; ID: Integer; out S: UnicodeString): LongBool; overload; {$IFDEF INLINE_SUPPORTED}inline;{$ENDIF}

// FileInfo
function FileInfoGetString(const FileInfo: IAIMPFileInfo; PropertyID: Integer): UnicodeString;

// Message Dispatcher
function ApplicationIsLoaded: LongBool;
function MessageDispatcherSend(Message: Integer; Param1: Integer = 0; Param2: Pointer = nil): HRESULT;
function MessageDispatcherGetPropValue(PropertyID: Integer; ValueBuffer: Pointer): HRESULT;
function MessageDispatcherSetPropValue(PropertyID: Integer; ValueBuffer: Pointer): HRESULT;
implementation

uses
  SysUtils, apiMessages;

const
  sErrorCannotCreateObject = 'Cannot create object (%d)';
  sErrorCannotSetDataToString = 'Cannot set data to IAIMPString (%d)';
  sErrroNoCore = 'Plugin is not initialized';

var
  FCore: IAIMPCore = nil;

procedure CheckResult(R: HRESULT; const AMessage: string = '%d');
begin
  if Failed(R) then
    raise Exception.CreateFmt(AMessage, [R]);
end;

//----------------------------------------------------------------------------------------------------------------------
// Core
//----------------------------------------------------------------------------------------------------------------------

procedure CoreCreateObject(const IID: TGUID; out Obj);
begin
  CheckResult(FCore.CreateObject(IID, Obj), sErrorCannotCreateObject);
end;

function CoreCreateObjectEx(const IID: TGUID; out Obj): HRESULT;
begin
  if FCore = nil then
    raise Exception.Create(sErrroNoCore);
  Result := FCore.CreateObject(IID, Obj);
end;

function CoreGetProfilePath: UnicodeString;
var
  S: IAIMPString;
begin
  if Failed(FCore.GetPath(AIMP_CORE_PATH_PROFILE, S)) then
    raise Exception.Create('Profile path is not found');
  Result := IAIMPStringToString(S);
end;

function CoreGetService(const IID: TGUID; out Obj): LongBool;
begin
  Result := Succeeded(FCore.QueryInterface(IID, Obj));
end;

function CoreIntf: IAIMPCore;
begin
  Result := FCore;
end;

//----------------------------------------------------------------------------------------------------------------------
// Window Handles
//----------------------------------------------------------------------------------------------------------------------

function MainWindowGetHandle: HWND;
begin
  if Failed(MessageDispatcherGetPropValue(AIMP_MSG_PROPERTY_HWND, @Result)) then
    Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------
// Localization
//----------------------------------------------------------------------------------------------------------------------

function LangGetName: UnicodeString;
var
  AService: IAIMPServiceMUI;
  AValue: IAIMPString;
begin
  if CoreGetService(IAIMPServiceMUI, AService) and Succeeded(AService.GetName(AValue)) then
    Result := IAIMPStringToString(AValue)
  else
    Result := '';
end;

function LangLoadString(const KeyPath: UnicodeString): UnicodeString;
var
  AValue: IAIMPString;
begin
  if Succeeded(LangLoadString(KeyPath, AValue)) then
    Result := IAIMPStringToString(AValue)
  else
    Result := '';
end;

function LangLoadString(const KeyPath: UnicodeString; out AValue: IAIMPString): HRESULT;
var
  AService: IAIMPServiceMUI;
begin
  if CoreGetService(IAIMPServiceMUI, AService) then
    Result := AService.GetValue(MakeString(KeyPath), AValue)
  else
    Result := E_NOINTERFACE;
end;

function LangLoadString(const KeyPath: UnicodeString; APartIndex: Integer): UnicodeString;
var
  AValue: IAIMPString;
begin
  if Succeeded(LangLoadString(KeyPath, APartIndex, AValue)) then
    Result := IAIMPStringToString(AValue)
  else
    Result := '';
end;

function LangLoadString(const KeyPath: UnicodeString; APartIndex: Integer; out AValue: IAIMPString): HRESULT;
var
  AService: IAIMPServiceMUI;
begin
  if CoreGetService(IAIMPServiceMUI, AService) then
    Result := AService.GetValuePart(MakeString(KeyPath), APartIndex, AValue)
  else
    Result := E_NOINTERFACE;
end;

//----------------------------------------------------------------------------------------------------------------------
// Strings
//----------------------------------------------------------------------------------------------------------------------

function IAIMPStringToString(const S: IAIMPString): UnicodeString;
begin
  if S <> nil then
    SetString(Result, S.GetData, S.GetLength)
  else
    Result := EmptyStr;
end;

function MakeString(const S: PWideChar; ALength: Integer): IAIMPString;
begin
  CoreCreateObject(IID_IAIMPString, Result);
  CheckResult(Result.SetData(S, ALength), sErrorCannotSetDataToString);
end;

function MakeString(const S: PWideChar; ALength: Integer; out R: IAIMPString): HRESULT;
begin
  try
    R := MakeString(S, ALength);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

function MakeString(const S: UnicodeString): IAIMPString;
begin
  Result := MakeString(PWideChar(S), Length(S));
end;

function MakeString(const S: UnicodeString; out R: IAIMPString): HRESULT;
begin
  try
    R := MakeString(S);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

function PropListGetStr(const List: IAIMPPropertyList; ID: Integer; out S: IAIMPString): LongBool;
begin
  Result := Succeeded(List.GetValueAsObject(ID, IID_IAIMPString, S));
end;

function PropListGetStr(const List: IAIMPPropertyList; ID: Integer; out S: UnicodeString): LongBool;
var
  AStrIntf: IAIMPString;
begin
  Result := PropListGetStr(List, ID, AStrIntf);
  if Result then
    S := IAIMPStringToString(AStrIntf);
end;

//----------------------------------------------------------------------------------------------------------------------
// FileInfo
//----------------------------------------------------------------------------------------------------------------------

function FileInfoGetString(const FileInfo: IAIMPFileInfo; PropertyID: Integer): UnicodeString;
var
  AValue: IAIMPString;
begin
  if Succeeded(FileInfo.GetValueAsObject(PropertyID, IID_IAIMPString, AValue)) then
    Result := IAIMPStringToString(AValue)
  else
    Result := '';
end;

//----------------------------------------------------------------------------------------------------------------------
// Message Dispatcher
//----------------------------------------------------------------------------------------------------------------------

function ApplicationIsLoaded: LongBool;
begin
  if Failed(MessageDispatcherGetPropValue(AIMP_MSG_PROPERTY_LOADED, @Result)) then
    Result := True; //todo
end;

function MessageDispatcherSend(Message: Integer; Param1: Integer = 0; Param2: Pointer = nil): HRESULT;
var
  AService: IAIMPServiceMessageDispatcher;
begin
  if CoreGetService(IID_IAIMPServiceMessageDispatcher, AService) then
    Result := AService.Send(Message, Param1, Param2)
  else
    Result := E_NOINTERFACE;
end;

function MessageDispatcherGetPropValue(PropertyID: Integer; ValueBuffer: Pointer): HRESULT;
begin
  Result := MessageDispatcherSend(PropertyID, AIMP_MSG_PROPVALUE_GET, ValueBuffer);
end;

function MessageDispatcherSetPropValue(PropertyID: Integer; ValueBuffer: Pointer): HRESULT;
begin
  Result := MessageDispatcherSend(PropertyID, AIMP_MSG_PROPVALUE_SET, ValueBuffer);
end;

{ TAIMPAPIWrappers }

class procedure TAIMPAPIWrappers.Finalize;
begin
  FCore := nil;
end;

class procedure TAIMPAPIWrappers.Initialize(Core: IAIMPCore);
begin
  FCore := Core;
end;

{ TAIMPExtensionFileFormat }

constructor TAIMPExtensionFileFormat.Create(const ADescription, AExtList: UnicodeString;
  AFlags: Cardinal = AIMP_SERVICE_FILEFORMATS_CATEGORY_AUDIO);
begin
  inherited Create;
  FFlags := AFlags;
  FExtList := AExtList;
  FDescription := ADescription;
end;

function TAIMPExtensionFileFormat.GetDescription(out S: IAIMPString): HRESULT;
begin
  try
    S := MakeString(FDescription);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TAIMPExtensionFileFormat.GetExtList(out S: IAIMPString): HRESULT;
begin
  try
    S := MakeString(FExtList);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TAIMPExtensionFileFormat.GetFlags(out Flags: Cardinal): HRESULT;
begin
  try
    Flags := FFlags;
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

{ TAIMPPropertyList }

function TAIMPPropertyList.CheckAccess(var AResult: HRESULT): Boolean;
begin
  Result := True;
  AResult := S_OK;
end;

procedure TAIMPPropertyList.DoBeginUpdate;
begin
  // do nothing
end;

procedure TAIMPPropertyList.DoEndUpdate;
begin
  // do nothing
end;

function TAIMPPropertyList.DoGetValueAsFloat(PropertyID: Integer; out Value: Double): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TAIMPPropertyList.DoGetValueAsInt32(PropertyID: Integer; out Value: Integer): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TAIMPPropertyList.DoGetValueAsInt64(PropertyID: Integer; out Value: Int64): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TAIMPPropertyList.DoGetValueAsObject(PropertyID: Integer): IUnknown;
begin
  if PropertyID = 0 then
    Result := FCustomObject
  else
    Result := nil;
end;

function TAIMPPropertyList.DoReset: HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TAIMPPropertyList.DoSetValueAsFloat(PropertyID: Integer; const Value: Double): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TAIMPPropertyList.DoSetValueAsInt32(PropertyID: Integer; const Value: Integer): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TAIMPPropertyList.DoSetValueAsInt64(PropertyID: Integer; const Value: Int64): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TAIMPPropertyList.DoSetValueAsObject(PropertyID: Integer; const Value: IInterface): HRESULT;
begin
  if PropertyID = 0 then
  begin
    FCustomObject := Value;
    Result := S_OK;
  end
  else
    Result := E_NOTIMPL;
end;

procedure TAIMPPropertyList.BeginUpdate;
var
  X: HRESULT;
begin
  if CheckAccess(X) then
    DoBeginUpdate;
end;

procedure TAIMPPropertyList.EndUpdate;
var
  X: HRESULT;
begin
  if CheckAccess(X) then
    DoEndUpdate;
end;

function TAIMPPropertyList.GetValueAsFloat(PropertyID: Integer; out Value: Double): HRESULT;
begin
  if CheckAccess(Result) then
  try
    Result := DoGetValueAsFloat(PropertyID, Value);
  except
    Result := E_UNEXPECTED;
  end;
end;

function TAIMPPropertyList.GetValueAsInt32(PropertyID: Integer; out Value: Integer): HRESULT;
begin
  if CheckAccess(Result) then
  try
    Result := DoGetValueAsInt32(PropertyID, Value);
  except
    Result := E_UNEXPECTED;
  end;
end;

function TAIMPPropertyList.GetValueAsInt64(PropertyID: Integer; out Value: Int64): HRESULT;
begin
  if CheckAccess(Result) then
  try
    Result := DoGetValueAsInt64(PropertyID, Value);
  except
    Result := E_UNEXPECTED;
  end;
end;

function TAIMPPropertyList.GetValueAsObject(PropertyID: Integer; const IID: TGUID; out Value): HRESULT;
var
  AIntf: IUnknown;
begin
  if CheckAccess(Result) then
  try
    AIntf := DoGetValueAsObject(PropertyID);
    if AIntf <> nil then
      Result := AIntf.QueryInterface(IID, Value)
    else
      Result := E_INVALIDARG;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TAIMPPropertyList.SetValueAsFloat(PropertyID: Integer; const Value: Double): HRESULT;
begin
  if CheckAccess(Result) then
  try
    Result := DoSetValueAsFloat(PropertyID, Value);
  except
    Result := E_UNEXPECTED;
  end;
end;

function TAIMPPropertyList.SetValueAsInt32(PropertyID, Value: Integer): HRESULT;
begin
  if CheckAccess(Result) then
  try
    Result := DoSetValueAsInt32(PropertyID, Value);
  except
    Result := E_UNEXPECTED;
  end;
end;

function TAIMPPropertyList.SetValueAsInt64(PropertyID: Integer; const Value: Int64): HRESULT;
begin
  if CheckAccess(Result) then
  try
    Result := DoSetValueAsInt64(PropertyID, Value);
  except
    Result := E_UNEXPECTED;
  end;
end;

function TAIMPPropertyList.SetValueAsObject(PropertyID: Integer; Value: IInterface): HRESULT;
begin
  if CheckAccess(Result) then
  try
    Result := DoSetValueAsObject(PropertyID, Value);
  except
    Result := E_UNEXPECTED;
  end;
end;

function TAIMPPropertyList.Reset: HRESULT;
begin
  if CheckAccess(Result) then
  try
    Result := DoReset;
  except
    Result := E_UNEXPECTED;
  end;
end;

{ TAIMPServiceConfig }

constructor TAIMPServiceConfig.Create;
begin
  inherited Create;
  if not CoreGetService(IAIMPServiceConfig, FService) then
    raise Exception.Create('The IAIMPServiceConfig is not supported');
end;

function TAIMPServiceConfig.ReadBool(const AKeyPath: UnicodeString; const ADefault: Boolean): Boolean;
begin
  Result := ReadInteger(AKeyPath, Ord(ADefault)) <> 0;
end;

function TAIMPServiceConfig.ReadFloat(const AKeyPath: UnicodeString; const ADefault: Double = 0): Double;
begin
  if Failed(FService.GetValueAsFloat(MakeString(AKeyPath), Result)) then
    Result := ADefault;
end;

function TAIMPServiceConfig.ReadInt64(const AKeyPath: UnicodeString; const ADefault: Int64 = 0): Int64;
begin
  if Failed(FService.GetValueAsInt64(MakeString(AKeyPath), Result)) then
    Result := ADefault;
end;

function TAIMPServiceConfig.ReadInteger(const AKeyPath: UnicodeString; const ADefault: Integer = 0): Integer;
begin
  if Failed(FService.GetValueAsInt32(MakeString(AKeyPath), Result)) then
    Result := ADefault;
end;

function TAIMPServiceConfig.ReadString(const AKeyPath: UnicodeString; const ADefault: UnicodeString = ''): UnicodeString;
var
  AValue: IAIMPString;
begin
  if Succeeded(FService.GetValueAsString(MakeString(AKeyPath), AValue)) then
    Result := IAIMPStringToString(AValue)
  else
    Result := ADefault;
end;

procedure TAIMPServiceConfig.WriteBool(const AKeyPath: UnicodeString; const AValue: Boolean);
begin
  WriteInteger(AKeyPath, Ord(AValue));
end;

procedure TAIMPServiceConfig.WriteFloat(const AKeyPath: UnicodeString; const AValue: Double);
begin
  FService.SetValueAsFloat(MakeString(AKeyPath), AValue);
end;

procedure TAIMPServiceConfig.WriteInt64(const AKeyPath: UnicodeString; const AValue: Int64);
begin
  FService.SetValueAsInt64(MakeString(AKeyPath), AValue);
end;

procedure TAIMPServiceConfig.WriteInteger(const AKeyPath: UnicodeString; const AValue: Integer);
begin
  FService.SetValueAsInt32(MakeString(AKeyPath), AValue);
end;

procedure TAIMPServiceConfig.WriteString(const AKeyPath: UnicodeString; const AValue: UnicodeString);
begin
  FService.SetValueAsString(MakeString(AKeyPath), MakeString(AValue));
end;

{ TAIMPStreamWrapper }

constructor TAIMPStreamWrapper.Create(ASource: IAIMPStream);
begin
  inherited Create;
  FSource := ASource;
end;

function TAIMPStreamWrapper.Read(var Buffer; Count: Integer): Longint;
begin
  Result := FSource.Read(@Buffer, Count);
end;

function TAIMPStreamWrapper.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  case Origin of
    soBeginning:
      FSource.Seek(Offset, AIMP_STREAM_SEEKMODE_FROM_BEGINNING);
    soCurrent:
      FSource.Seek(Offset, AIMP_STREAM_SEEKMODE_FROM_CURRENT);
    soEnd:
      FSource.Seek(Offset, AIMP_STREAM_SEEKMODE_FROM_END);
  end;
  Result := FSource.GetPosition;
end;

function TAIMPStreamWrapper.Write(const Buffer; Count: Integer): Longint;
var
  AWritten: DWORD;
begin
  if Succeeded(FSource.Write(@Buffer, Count, @AWritten)) then
    Result := AWritten
  else
    Result := 0
end;

function TAIMPStreamWrapper.GetSize: Int64;
begin
  Result := FSource.GetSize;
end;

procedure TAIMPStreamWrapper.SetSize(const NewSize: Int64);
begin
  if Failed(FSource.SetSize(NewSize)) then
    Abort;
end;

{ TAIMPStreamAdapter }

constructor TAIMPStreamAdapter.Create(ASource: TStream; AOwnership: TStreamOwnership = soOwned);
begin
  inherited Create;
  if not TestSource(ASource) then
    raise EStreamError.Create('Unsupported stream class');
  FSource := ASource;
  FOwnership := AOwnership;
end;

destructor TAIMPStreamAdapter.Destroy;
begin
  if FOwnership = soOwned then
    FreeAndNil(FSource);
  inherited Destroy;
end;

function TAIMPStreamAdapter.TestSource(ASource: TStream): Boolean;
begin
  Result := True;
end;

function TAIMPStreamAdapter.GetPosition: Int64;
begin
  Result := FSource.Position;
end;

function TAIMPStreamAdapter.GetSize: Int64;
begin
  Result := FSource.Size;
end;

function TAIMPStreamAdapter.Read(Buffer: PByte; Count: DWORD): Integer;
begin
  try
    Result := FSource.Read(Buffer^, Count);
  except
    Result := -1;
  end;
end;

function TAIMPStreamAdapter.Seek(const Offset: Int64; Mode: Integer): HRESULT;
var
  ASeekOrigin: TSeekOrigin;
begin
  case Mode of
    AIMP_STREAM_SEEKMODE_FROM_BEGINNING:
      ASeekOrigin := soBeginning;
    AIMP_STREAM_SEEKMODE_FROM_CURRENT:
      ASeekOrigin := soCurrent;
    AIMP_STREAM_SEEKMODE_FROM_END:
      ASeekOrigin := soEnd;
  else
    Exit(E_INVALIDARG);
  end;

  try
    if FSource.Seek(Offset, ASeekOrigin) = Offset then
      Result := S_OK
    else
      Result := E_FAIL;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TAIMPStreamAdapter.SetSize(const Value: Int64): HRESULT;
begin
  if FSourceIsReadOnly then
    Result := E_NOTIMPL
  else
    try
      FSource.Size := Value;
      Result := S_OK;
    except
      Result := E_UNEXPECTED;
    end;
end;

function TAIMPStreamAdapter.Write(Buffer: PByte; Count: DWORD; Written: PDWORD = nil): HRESULT;
begin
  if FSourceIsReadOnly then
    Result := E_NOTIMPL
  else
    try
      Count := FSource.Write(Buffer^, Count);
      if Written <> nil then
        Written^ := Count;
      Result := S_OK;
    except
      Result := E_UNEXPECTED;
    end;
end;

{ TAIMPMemoryStreamAdapter }

constructor TAIMPMemoryStreamAdapter.Create;
begin
  inherited Create(TMemoryStream.Create);
end;

function TAIMPMemoryStreamAdapter.TestSource(ASource: TStream): Boolean;
begin
  Result := ASource is TMemoryStream;
end;

function TAIMPMemoryStreamAdapter.GetData: PByte;
begin
  Result := TMemoryStream(FSource).Memory;
end;

{ TAIMPFileStreamAdapter }

constructor TAIMPFileStreamAdapter.Create(const AFileName: UnicodeString; AMode: Integer);
begin
  Create(CreateStream(AFileName, AMode));
end;

constructor TAIMPFileStreamAdapter.Create(const AFileName: IAIMPString; AMode: Integer);
begin
  Create(IAIMPStringToString(AFileName), AMode);
end;

function TAIMPFileStreamAdapter.TestSource(ASource: TStream): Boolean;
begin
  Result := ASource is TFileStream;
end;

function TAIMPFileStreamAdapter.GetClipping(out Offset, Size: Int64): HRESULT;
begin
  Result := E_FAIL;
end;

function TAIMPFileStreamAdapter.GetFileName(out S: IAIMPString): HRESULT;
begin
  try
    Result := MakeString(TFileStream(FSource).FileName, S);
  except
    Result := E_UNEXPECTED;
  end;
end;

function TAIMPFileStreamAdapter.CreateStream(const AFileName: UnicodeString; AMode: Integer): TStream;
begin
  Result := TFileStream.Create(AFileName, AMode);
end;

end.
