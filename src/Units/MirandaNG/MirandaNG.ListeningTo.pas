unit MirandaNG.ListeningTo;

interface

uses
  App.Utils, MirandaNG.CommunicationThread;

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
    info.TrackType := TrackType.None;
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
    FThread.TrackInfo := ATrackInfo;
  end;
end;

procedure TPluginInterface.SendStopped(const APlayerName: string);
var
  info: TTrackInfo;
begin
  if Assigned(FThread) then
  begin
    info := TTrackInfo.Empty;
    info.PlayerName := APlayerName;
    FThread.TrackInfo := info;
  end;
end;

end.
