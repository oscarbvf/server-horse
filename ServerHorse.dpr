program ServerHorse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  uMain in 'uMain.pas',
  uClienteJsonMapper in 'uClienteJsonMapper.pas',
  uClienteModel in 'uClienteModel.pas',
  uClienteService in 'uClienteService.pas';

begin
  try
    StartServer;
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
