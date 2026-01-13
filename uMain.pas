unit uMain;

interface

uses
  Horse, System.SysUtils, uDataModule, uClienteController;

procedure StartServer;

implementation


procedure StartServer;
begin
  DataModule1 := TDataModule1.Create(nil); // instancia o DataModule e conecta
  RegisterClienteRoutes;
  Writeln('Server starting on http://0.0.0.0:9000 ...');
  THorse.Listen(9000); // bloqueia thread principal
end;

end.

