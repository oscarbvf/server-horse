unit uMain;

interface

uses
  Horse, System.SysUtils, uClienteController, Horse.Request, Horse.Response,
  Horse.Core, Vcl.Dialogs;

procedure StartServer;

implementation

procedure StartServer;
begin
  RegisterClienteRoutes;

  Writeln('Server starting on http://0.0.0.0:9000 ...');
  THorse.Listen(9000); // bloqueia thread principal
end;

end.

