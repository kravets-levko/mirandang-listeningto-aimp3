unit App.Utils;

interface

type
  TrackType = (None, Music, Video, Radio);

  TTrackInfo = record
    PlayerName: string;
    
    TrackType: TrackType;
    Title: string;
    Artist: string;
    Album: string;
    Track: string;
    Year: Integer;
    Genre: string;
    Length: Int64; // in seconds
    StationName: string;

    class function Empty: TTrackInfo; static; inline;
  end;


procedure DebugOutput(const AString: string);
function GetMainModuleVerProductName(DefaultValue: string = ''): string;
procedure GetThisModuleVerInfo(out ProductName, FileDescription, LegalCopyright: string);

implementation

uses
  SysUtils, Windows;

procedure DebugOutput(const AString: string);
begin
  OutputDebugString(PChar(AString));
end;

function GetModuleFileName(hModule: HMODULE): string;
var
  buf: array [WORD] of Char;
begin
  FillChar(buf, SizeOf(buf), 0);
  Windows.GetModuleFileName(hModule, @buf[0], Length(buf));
  buf[High(buf)] := #0;
  Result := PChar(@buf[0]);
  {$IFDEF DEBUG}
  DebugOutput('hModule 0x' + IntToHex(hModule, SizeOf(hModule) * 2) + ' ' + Result);
  {$ENDIF}
end;

function GetVerInfoValue(const Block: Pointer; const SectionName: string): string; inline;
var
  pData: Pointer;
  cbData: DWORD;
begin
  Result := '';
  {$IFDEF DEBUG}
  DebugOutput('VerBlock 0x' + IntToHex(NativeUInt(Block), SizeOf(Block) * 2) + ' ' + SectionName);
  {$ENDIF}
  if VerQueryValue(Block, PChar(SectionName), pData, cbData) then
  begin
    // For ProductName, FileDescription and LegalCopyright cbData is in characters, not bytes
    SetLength(Result, cbData);
    SetString(Result, PChar(pData), Length(Result));
    Result := PChar(Result); // Remove trailing zero char
  end;
end;

function GetMainModuleVerProductName(DefaultValue: string = ''): string;
type
  TTranslationArray = array [Word] of packed record
    Language: WORD;
    CodePage: WORD;
  end;
  PTranslationArray = ^TTranslationArray;
var
  mainModuleFileName: string;
  dwSize: DWORD;
  dwHandle: DWORD;
  buffer: array of Byte;
  pBlock: Pointer;
  pTranslations: PTranslationArray;
  cbTranslations: DWORD;
  nTranslations: Integer;
  section: string;
  i: Integer;
begin
  Result := DefaultValue;

  // ParamStr(0) is compiled into GetModuleFileName with hModule = 0
  // https://msdn.microsoft.com/en-us/library/windows/desktop/ms683197(v=vs.85).aspx
  mainModuleFileName := ParamStr(0);

  dwSize := GetFileVersionInfoSize(PChar(mainModuleFileName), dwHandle);
  if dwSize = 0 then Exit;

  SetLength(buffer, dwSize);
  pBlock := @buffer[0];
  if GetFileVersionInfo(PChar(mainModuleFileName), dwHandle, dwSize, pBlock) then
  begin
    // Get all available translations for VersionInfo resource, and then enum them
    if VerQueryValue(pBlock, '\VarFileInfo\Translation', Pointer(pTranslations), cbTranslations) then
    begin
      nTranslations := cbTranslations div SizeOf(DWORD);
      for i := 0 to nTranslations - 1 do
      begin
        section := '\StringFileInfo\' + IntToHex(pTranslations[i].Language, 4) +
          IntToHex(pTranslations[i].CodePage, 4) + '\ProductName';
        Result := GetVerInfoValue(pBlock, section);
        if Result <> '' then Break; // Return any value
      end;
    end;
  end;

  if Result = '' then
    Result := DefaultValue;
end;

procedure GetThisModuleVerInfo(out ProductName, FileDescription, LegalCopyright: string);
type
  TTranslationArray = array [Word] of packed record
    Language: WORD;
    CodePage: WORD;
  end;
  PTranslationArray = ^TTranslationArray;
var
  moduleFileName: string;
  dwSize: DWORD;
  dwHandle: DWORD;
  buffer: array of Byte;
  pBlock: Pointer;
  pTranslations: PTranslationArray;
  cbTranslations: DWORD;
  nTranslations: Integer;

  section: string;
  i: Integer;
begin
  ProductName := '';
  FileDescription := '';
  LegalCopyright := '';

  // Get path to this module
  moduleFileName := GetModuleFileName(HInstance);

  dwSize := GetFileVersionInfoSize(PChar(moduleFileName), dwHandle);
  if dwSize = 0 then Exit;

  SetLength(buffer, dwSize);
  pBlock := @buffer[0];
  if GetFileVersionInfo(PChar(moduleFileName), dwHandle, dwSize, pBlock) then
  begin
    // Get all available translations for VersionInfo resource, and then enum them
    if VerQueryValue(pBlock, '\VarFileInfo\Translation', Pointer(pTranslations), cbTranslations) then
    begin
      nTranslations := cbTranslations div SizeOf(DWORD);
      for i := 0 to nTranslations - 1 do
      begin
        section := '\StringFileInfo\' + IntToHex(pTranslations[i].Language, 4) +
          IntToHex(pTranslations[i].CodePage, 4) + '\';

        if ProductName = '' then
          ProductName := GetVerInfoValue(pBlock, section + 'ProductName');
        if FileDescription = '' then
          FileDescription := GetVerInfoValue(pBlock, section + 'FileDescription');
        if LegalCopyright = '' then
          LegalCopyright := GetVerInfoValue(pBlock, section + 'LegalCopyright');

        if (ProductName <> '') and (FileDescription <> '') and (LegalCopyright <> '') then
          Break;
      end;
    end;
  end;
end;

{ TTrackInfo }

class function TTrackInfo.Empty: TTrackInfo;
begin
  Finalize(Result);
  FillChar(Result, SizeOf(Result), 0);
end;

end.
