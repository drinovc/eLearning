unit StackTrace;

interface

uses
{.$UNDEF DEBUG}

  SysUtils, Classes
{$IFDEF DEBUG}
, JclDebug
{$ENDIF}
  ;

function GetStackTrace(): string;

implementation

{
  retrieve last exception stack trace and return it as crlf delimited string
}
function GetStackTrace(): string;
var LLines: TStringList;
begin
  result := '';
{$IFDEF DEBUG}
  LLines := TStringList.Create;
  try
    JclLastExceptStackListToStrings(LLines, True, True, True, True);
    result := LLines.Text;
  finally
    LLines.Free;
  end;
{$ENDIF}
end;

initialization
  // Start the Jcl exception tracking and register our Exception stack trace provider.
{$IFDEF DEBUG}
  if JclStartExceptionTracking then
  begin
  end;
{$ENDIF}

finalization
  // Stop Jcl exception tracking and unregister our provider.
{$IFDEF DEBUG}
  if JclExceptionTrackingActive then
  begin
    JclStopExceptionTracking;
  end;
{$ENDIF}

end.

