unit uClienteService;

interface

uses
  uClienteModel,
  System.Generics.Collections, System.SysUtils;

type
  TClienteService = class
  public
    function Inserir(ACliente: TCliente): Integer;
    function Listar: TObjectList<TCliente>;
    function ObterPorId(AId: Integer): TCliente;
  end;

implementation

uses
  uDataModule;

{ TClienteService }

function TClienteService.Inserir(ACliente: TCliente): Integer;
var
  DM: TDataModule1;
begin
  if Trim(ACliente.Nome) = '' then
    raise Exception.Create('Nome is required');

  if Trim(ACliente.Email) = '' then
    raise Exception.Create('Email is required');

  DM := TDataModule1.Create(nil);
  try
    Result := DM.InsertCliente(
      ACliente.Nome,
      ACliente.Email,
      ACliente.Telefone
    );
  finally
    DM.Free;
  end;
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

