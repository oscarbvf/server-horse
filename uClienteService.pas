unit uClienteService;

interface

uses
  uClienteModel,
  System.Generics.Collections;

type
  TClienteService = class
  public
    procedure Inserir(ACliente: TCliente);
    function Listar: TObjectList<TCliente>;
    function ObterPorId(AId: Integer): TCliente;
  end;

implementation

uses
  uDataModule;

{ TClienteService }

procedure TClienteService.Inserir(ACliente: TCliente);
begin
//  TDataModule1.InsertCliente(ACliente);
end;

function TClienteService.Listar: TObjectList<TCliente>;
var
  DM: TDataModule1;
begin
  DM := TDataModule1.Create(nil);
  try
    Result := DM.LoadClientes;
  finally
    DM.Free;
  end;
end;

function TClienteService.ObterPorId(AId: Integer): TCliente;
var
  DM: TDataModule1;
begin
  DM := TDataModule1.Create(nil);
  try
    Result := DM.LoadClienteById(AId);
  finally
    DM.Free;
  end;
end;

end.

