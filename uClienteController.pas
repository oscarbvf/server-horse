unit uClienteController;

interface

uses
  Horse, System.SysUtils, System.Classes, FireDAC.Comp.Client, Data.DB,
  FireDAC.Stan.Param, System.JSON, uDataModule, System.Generics.Collections;

procedure RegisterClienteRoutes;

implementation

uses
  Horse.Request, Horse.Response, uClienteJsonMapper, Horse.Jhonson, Horse.HandleException,
  uHttpHelpers;

procedure GetClientes(Req: THorseRequest; Res: THorseResponse);
var
  DM: TDataModule1;
  Arr: TJSONArray;
begin
  DM := TDataModule1.Create(nil);
  try
    DM.OpenClientes;

    Arr := QueryToJSONArray(DM.FDQuery1);
    try
      Res
        .Status(200)
        .ContentType('application/json')
        .Send(Arr.ToJSON);
    finally
      Arr.Free;
    end;
  finally
    DM.Free;
  end;
end;

procedure GetClienteById(Req: THorseRequest; Res: THorseResponse);
var
  DM: TDataModule1;
  Id: Integer;
  Obj: TJSONObject;
begin
  Id := GetIdParam(Req);

  DM := TDataModule1.Create(nil);
  try
    Obj := TJSONObject.Create;
    try
      if not DM.LoadClienteById(Id, Obj) then
        raise EHorseException.New
          .Status(THTTPStatus.NotFound)
          .Error('cliente not found');

      Res.Status(THTTPStatus.OK)
         .ContentType('application/json')
         .Send(Obj.ToJSON);
    finally
      Obj.Free;
    end;
  finally
    DM.Free;
  end;
end;

procedure CreateCliente(Req: THorseRequest; Res: THorseResponse);
var
  DM: TDataModule1;
  Jo: TJSONObject;
  NovoId: Integer;
  Nome, Email, Telefone: string;
begin
  Jo := GetBodyAsJSON(Req);

  try

    Nome := GetRequiredString(Jo, 'Nome');
    Email := GetRequiredString(Jo, 'Email');
    Telefone := GetOptionalString(Jo, 'Telefone');

    DM := TDataModule1.Create(nil);
    try
      NovoId := DM.InsertCliente(Nome, Email, Telefone);

      Res.Status(201)
         .ContentType('application/json')
         .Send(Format('{"id":%d}', [NovoId]));
    finally
      DM.Free;
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
