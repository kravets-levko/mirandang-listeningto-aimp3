unit Utils;

interface

procedure DebugOutput(const AString: string);

implementation

{$IFDEF DEBUG}
uses
  Windows;
{$ENDIF}

procedure DebugOutput(const AString: string);
begin
  {$IFDEF DEBUG}
  OutputDebugString(PChar(AString));
  {$ENDIF}
end;

end.
