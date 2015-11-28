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

unit apiDecoders;

{$I apiConfig.inc}

interface

uses
  Windows, apiObjects, apiFileManager, apiCore;

const
  SID_IAIMPAudioDecoder = '{41494D50-4175-6469-6F44-656300000000}';
  IID_IAIMPAudioDecoder: TGUID = SID_IAIMPAudioDecoder;

  SID_IAIMPExtensionAudioDecoder = '{41494D50-4578-7441-7564-696F44656300}';
  IID_IAIMPExtensionAudioDecoder: TGUID = SID_IAIMPExtensionAudioDecoder;

  SID_IAIMPExtensionAudioDecoderOld = '{41494D50-4578-7441-7564-696F4465634F}';
  IID_IAIMPExtensionAudioDecoderOld: TGUID = SID_IAIMPExtensionAudioDecoderOld;

  SID_IAIMPServiceAudioDecoders = '{41494D50-5372-7641-7564-696F44656300}';
  IID_IAIMPServiceAudioDecoders: TGUID = SID_IAIMPServiceAudioDecoders;

const
  AIMP_DECODER_SAMPLEFORMAT_08BIT      = 1;
  AIMP_DECODER_SAMPLEFORMAT_16BIT      = 2;
  AIMP_DECODER_SAMPLEFORMAT_24BIT      = 3;
  AIMP_DECODER_SAMPLEFORMAT_32BIT      = 4;
  AIMP_DECODER_SAMPLEFORMAT_32BITFLOAT = 5;

  // Flags for IAIMPExtensionAudioDecoder / IAIMPExtensionAudioDecoderOld
  AIMP_DECODER_FLAGS_FORCE_CREATE_INSTANCE = $1000;

type

  { IAIMPAudioDecoder }

  IAIMPAudioDecoder = interface(IUnknown)
  [SID_IAIMPAudioDecoder]
    function GetFileInfo(FileInfo: IAIMPFileInfo): LongBool; stdcall;
    function GetStreamInfo(out SampleRate, Channels, SampleFormat: Integer): LongBool; stdcall; 

    function IsSeekable: LongBool; stdcall;
    function IsRealTimeStream: LongBool; stdcall;

    function GetAvailableData: Int64; stdcall;
    function GetSize: Int64; stdcall;
    function GetPosition: Int64; stdcall;
    function SetPosition(const Value: Int64): LongBool; stdcall;

    function Read(Buffer: PByte; Count: Integer): Integer; stdcall;
  end;

  { IAIMPExtensionAudioDecoder }

  IAIMPExtensionAudioDecoder = interface(IUnknown)
  [SID_IAIMPExtensionAudioDecoder]
    function CreateDecoder(Stream: IAIMPStream; Flags: DWORD;
      ErrorInfo: IAIMPErrorInfo; out Decoder: IAIMPAudioDecoder): HRESULT; stdcall;
  end;

  { IAIMPExtensionAudioDecoderOld }

  IAIMPExtensionAudioDecoderOld = interface(IUnknown)
  [SID_IAIMPExtensionAudioDecoderOld]
    function CreateDecoder(FileName: IAIMPString; Flags: DWORD;
      ErrorInfo: IAIMPErrorInfo; out Decoder: IAIMPAudioDecoder): HRESULT; stdcall;
  end;

  { IAIMPServiceAudioDecoders }

  IAIMPServiceAudioDecoders = interface
  [SID_IAIMPServiceAudioDecoders]
    function CreateDecoderForStream(Stream: IAIMPStream; Flags: DWORD;
      ErrorInfo: IAIMPErrorInfo; out Decoder: IAIMPAudioDecoder): HRESULT; stdcall;
    function CreateDecoderForFileURI(FileURI: IAIMPString; Flags: DWORD;
      ErrorInfo: IAIMPErrorInfo; out Decoder: IAIMPAudioDecoder): HRESULT; stdcall;
  end;

implementation

end.
