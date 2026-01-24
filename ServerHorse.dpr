program ServerHorse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  uMain in 'uMain.pas';

begin
  try
    StartServer;
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
