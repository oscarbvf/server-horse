unit uClienteController;

interface

uses
  Horse, System.SysUtils, System.Classes, FireDAC.Comp.Client, Data.DB,
  FireDAC.Stan.Param, System.JSON, uDataModule, System.Generics.Collections;

procedure RegisterClienteRoutes;

implementation

uses
  Horse.Request, Horse.Response, uClienteJsonMapper, Horse.Jhonson, Horse.HandleException,
  uHttpHelpers, uClienteService, uClienteModel;

procedure GetClientes(Req: THorseRequest; Res: THorseResponse);
var
  Service: TClienteService;
  Lista: TObjectList<TCliente>;
  Arr: TJSONArray;
  Cliente: TCliente;
begin
  Service := TClienteService.Create;
  try
    Lista := Service.Listar;

    Arr := TJSONArray.Create;
    try
      for Cliente in Lista do
        Arr.AddElement(ClienteToJson(Cliente));

      Res
        .Status(THTTPStatus.OK)
        .ContentType('application/json')
        .Send(Arr.ToJSON);
    finally
      Arr.Free;
      Lista.Free;
    end;
  finally
    Service.Free;
  end;
end;

procedure GetClienteById(Req: THorseRequest; Res: THorseResponse);
var
  Id: Integer;
  Obj: TJSONObject;
  Service: TClienteService;
  Cliente: TCliente;
begin
  Id := GetIdParam(Req);

  Service := TClienteService.Create;
  try
    Cliente := Service.ObterPorId(Id);
    if not Assigned(Cliente) then
      raise EHorseException.New.Status(THTTPStatus.NotFound).Error('cliente not found');

    Obj := ClienteToJson(Cliente);
    try
      Res.Status(THTTPStatus.OK)
         .ContentType('application/json')
         .Send(Obj.ToJSON);
    finally
      Obj.Free;
      Cliente.Free;
    end;

  finally
    Service.Free;
  end;
end;


procedure CreateCliente(Req: THorseRequest; Res: THorseResponse);
var
  Service: TClienteService;
  Cliente: TCliente;
  Jo: TJSONObject;
  NovoId: Integer;
begin
  Jo := GetBodyAsJSON(Req);
  try
    Cliente := TCliente.Create;
    Service := TClienteService.Create;
    try
      Cliente.Nome     := GetRequiredString(Jo, 'Nome');
      Cliente.Email    := GetRequiredString(Jo, 'Email');
      Cliente.Telefone := GetOptionalString(Jo, 'Telefone');

      NovoId := Service.Inserir(Cliente);

      Res.Status(201)
         .ContentType('application/json')
         .Send(Format('{"id":%d}', [NovoId]));

    finally
      Service.Free;
      Cliente.Free;
    end;
  finally
    Jo.Free;
  end;
end;

procedure UpdateCliente(Req: THorseRequest; Res: THorseResponse);
var
  Id: Integer;
  DM: TDataModule1;
  Jo: TJSONObject;
  Nome, Email, Telefone: string;
begin
  Jo := GetBodyAsJSON(Req);

  try
    Id := GetIdParam(Req);

    Nome := GetRequiredString(Jo, 'Nome');
    Email := GetRequiredString(Jo, 'Email');
    Telefone := GetOptionalString(Jo, 'Telefone');

    DM := TDataModule1.Create(nil);
    try
      if not DM.UpdateCliente(Id, Nome, Email, Telefone) then
        raise EHorseException.New.Status(THTTPStatus.NotFound).Error('cliente not found');
    finally
      DM.Free;
    end;

    Res.Status(THTTPStatus.NoContent);

  finally
    Jo.Free;
  end;
end;

procedure DeleteCliente(Req: THorseRequest; Res: THorseResponse);
var
  DM: TDataModule1;
  Id: Integer;
begin
  Id := GetIdParam(Req);

  DM := TDataModule1.Create(nil);
  try
    if not DM.DeleteCliente(Id) then
      raise EHorseException.New.Status(THTTPStatus.NotFound).Error('cliente not found');

    Res.Status(THTTPStatus.NoContent);

  finally
    DM.Free;
  end;
end;

procedure RegisterClienteRoutes;
begin
  with THorse do begin
    Use(Jhonson);
    Use(HandleException);
    Get('/clientes', GetClientes);
    Get('/clientes/:id', GetClienteById);
    Post('/clientes', CreateCliente);
    Put('/clientes/:id', UpdateCliente);
    Delete('/clientes/:id', DeleteCliente);
  end;
end;

end.
