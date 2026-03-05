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
    Lista := Service.GetClientes;

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
    Cliente := Service.GetById(Id);
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

      try
        NovoId := Service.Insert(Cliente);
      except
        on E: Exception do
          raise EHorseException.New.Status(THTTPStatus.BadRequest).Error(E.Message);
      end;

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
  Service: TClienteService;
  Cliente: TCliente;
  Jo: TJSONObject;
  Status: Boolean;
begin
  Jo := GetBodyAsJSON(Req);
  try
    Id := GetIdParam(Req);

    Cliente := TCliente.Create;
    Service := TClienteService.Create;
    try
      Cliente.Id := Id;
      Cliente.Nome     := GetRequiredString(Jo, 'Nome');
      Cliente.Email    := GetRequiredString(Jo, 'Email');
      Cliente.Telefone := GetOptionalString(Jo, 'Telefone');

      try
        Status := Service.Update(Cliente);
      except
        on E: Exception do
          raise EHorseException.New.Status(THTTPStatus.BadRequest).Error(E.Message);
      end;

      if not Status then
        raise EHorseException.New.Status(THTTPStatus.NotFound).Error('cliente not found');

      Res.Status(THTTPStatus.NoContent);

    finally
      Service.Free;
      Cliente.Free;
    end;
  finally
    Jo.Free;
  end;
end;

procedure DeleteCliente(Req: THorseRequest; Res: THorseResponse);
var
  Service: TClienteService;
  Id: Integer;
  Status: Boolean;
begin
  Id := GetIdParam(Req);

  Service := TClienteService.Create;
  try
    Status := Service.Delete(Id);

    if not Status then
      raise EHorseException.New.Status(THTTPStatus.NotFound).Error('cliente not found');

    Res.Status(THTTPStatus.NoContent);

  finally
    Service.Free;
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
