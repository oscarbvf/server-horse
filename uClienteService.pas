unit uClienteService;

interface

uses
  uClienteModel,
  System.Generics.Collections, System.SysUtils, System.RegularExpressions;

type
  TClienteService = class
  public
    function Update(ACliente: TCliente): Boolean;
    function Insert(ACliente: TCliente): Integer;
    function GetClientes: TObjectList<TCliente>;
    function GetById(AId: Integer): TCliente;
    function Delete(AId: Integer): Boolean;
    procedure ValidateCliente(ACliente: TCliente);
  end;

implementation

uses
  uDataModule;

{ TClienteService }

function TClienteService.Update(ACliente: TCliente): Boolean;
var
  DM: TDataModule1;
begin
  ValidateCliente(ACliente);

  DM := TDataModule1.Create(nil);
  try
    if DM.EmailExists(ACliente.Email) then
      raise Exception.Create('Email already exists');

    Result := DM.UpdateCliente(
      ACliente.Id,
      ACliente.Nome,
      ACliente.Email,
      ACliente.Telefone
    );
  finally
    DM.Free;
  end;
end;

procedure TClienteService.ValidateCliente(ACliente: TCliente);
var
  EmailRegex: TRegEx;
begin
  if Trim(ACliente.Nome) = '' then
    raise Exception.Create('Nome is required');

  if Trim(ACliente.Email) = '' then
    raise Exception.Create('Email is required');

  EmailRegex := TRegEx.Create(
    '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    [roIgnoreCase]
  );

  if not EmailRegex.IsMatch(ACliente.Email) then
    raise Exception.Create('Invalid email address');
end;

function TClienteService.Delete(AId: Integer): Boolean;
var
  DM: TDataModule1;
begin
  if AId <= 0 then
    raise Exception.Create('Invalid id');

  DM := TDataModule1.Create(nil);
  try
    Result := DM.DeleteCliente(AId);
  finally
    DM.Free;
  end;
end;

function TClienteService.Insert(ACliente: TCliente): Integer;
var
  DM: TDataModule1;
begin
  ValidateCliente(ACliente);

  DM := TDataModule1.Create(nil);
  try
    if DM.EmailExists(ACliente.Email) then
      raise Exception.Create('Email already exists');

    Result := DM.InsertCliente(
      ACliente.Nome,
      ACliente.Email,
      ACliente.Telefone
    );
  finally
    DM.Free;
  end;
end;

function TClienteService.GetClientes: TObjectList<TCliente>;
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

function TClienteService.GetById(AId: Integer): TCliente;
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

