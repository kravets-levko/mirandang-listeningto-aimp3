unit MirandaNG.ListeningTo;

interface

uses
  Utils, MirandaNG.CommunicationThread;

type
  TPluginInterface = class(TObject)
  strict protected
    FThread: TCommunicationThread;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SendPlaying(const APlayerName: string; ATrackInfo: TTrackInfo);
    procedure SendStopped(const APlayerName: string);
  end;

implementation

constructor TPluginInterface.Create;
begin
  FThread := TCommunicationThread.Create;
end;

destructor TPluginInterface.Destroy;
var
  info: TTrackInfo;
begin
  if Assigned(FThread) then
  begin
    info := FThread.TrackInfo;
    info.IsPlaying := false;
    FThread.TrackInfo := info;

    FThread.WakeUp;
    FThread.Terminate;
    FThread := nil;
  end;
  inherited;
end;

procedure TPluginInterface.SendPlaying(const APlayerName: string; ATrackInfo: TTrackInfo);
begin
  if Assigned(FThread) then
  begin
    ATrackInfo.PlayerName := APlayerName;
    ATrackInfo.IsPlaying := true;
    FThread.TrackInfo := ATrackInfo;
  end;
end;

procedure TPluginInterface.SendStopped(const APlayerName: string);
var
  info: TTrackInfo;
begin
  if Assigned(FThread) then
  begin
    info.PlayerName := APlayerName;
    info.IsPlaying := false;
    FThread.TrackInfo := info;
  end;
end;

end.
