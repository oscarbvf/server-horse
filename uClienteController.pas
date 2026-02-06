unit uClienteController;

interface

uses
  Horse, System.SysUtils, System.Classes, FireDAC.Comp.Client, Data.DB,
  FireDAC.Stan.Param, System.JSON, uDataModule, System.Generics.Collections;

procedure RegisterClienteRoutes;

implementation

uses
  Horse.Request, Horse.Response, uClienteJsonMapper, Horse.Jhonson, Horse.HandleException;

procedure GetClientes(Req: THorseRequest; Res: THorseResponse);
var
  DM: TDataModule1;
  Arr: TJSONArray;
begin
  DM := TDataModule1.Create(nil);
  try
    DM.OpenClientes;

    Arr := QueryToJSONArray(DM.FDQuery1); // ClientesQueryToJSONArray(DM.FDQuery1);
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
  if not TryStrToInt(Req.Params['id'], Id) or (Id <= 0) then begin
    Res.Status(400).Send('{"error":"invalid id"}');
    Exit;
  end;

  DM := TDataModule1.Create(nil);
  try
    Obj := TJSONObject.Create;
    try
      if not DM.LoadClienteById(Id, Obj) then begin
        Res.Status(404).Send('{"error":"not found"}');
        Exit;
      end;

      Res.Status(200)
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
  Jo := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
  if not Assigned(Jo) then begin
    Res.Status(400)
       .ContentType('application/json')
       .Send('{"error":"invalid json"}');
    Exit;
  end;

  if not Jo.TryGetValue<string>('Nome', Nome) or Nome.Trim.IsEmpty or
     not Jo.TryGetValue<string>('Email', Email) or Email.Trim.IsEmpty then //begin
    raise EHorseException.New.Status(THTTPStatus.BadRequest).Error('nome and email are required}');

//    Res.Status(400)
//         .ContentType('application/json')
//         .Send('{"error":"nome and email are required"}');
//    Exit;
//  end;

  try

    Jo.TryGetValue<string>('Telefone', Telefone);

    DM := TDataModule1.Create(nil);
    try
      try
        NovoId := DM.InsertCliente(Nome, Email, Telefone);

        Res.Status(201)
           .ContentType('application/json')
           .Send(Format('{"id":%d}', [NovoId]));
      except
        on E: Exception do begin
          Res.Status(500)
             .ContentType('application/json')
             .Send('{"error":"internal server error"}');
        end;
      end;
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
  Jo := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
  if not Assigned(Jo) then
    raise EHorseException.New.Status(THTTPStatus.BadRequest).Error('{"error":"invalid json"}');
//    Res.Status(400).Send('{"error":"invalid json"}');
//    Exit;
//  end;

  try
    if not TryStrToInt(Req.Params['id'], Id) or (Id <= 0) then
        raise EHorseException.New.Status(THTTPStatus.BadRequest).Error('{"error":"invalid id"}');
//      Res.Status(400).Send('{"error":"invalid id"}');
//      Exit;
//    end;

    if not (Jo.TryGetValue<string>('Nome', Nome) and not Nome.Trim.IsEmpty and
            Jo.TryGetValue<string>('Email', Email) and not Email.Trim.IsEmpty) then
        raise EHorseException.New.Status(THTTPStatus.BadRequest).Error('nome and email are required}');
//      Res.Status(400).Send('{"error":"nome and email are required"}');
//      Exit;
//    end;

    Jo.TryGetValue<string>('Telefone', Telefone);

    DM := TDataModule1.Create(nil);
    try
      if DM.UpdateCliente(Id, Nome, Email, Telefone) then
        Res.Status(200).Send('{"ok":true}')
      else
        Res.Status(404).Send('{"error":"not found"}');
    finally
      DM.Free;
    end;

  finally
    Jo.Free;
  end;
end;

procedure DeleteCliente(Req: THorseRequest; Res: THorseResponse);
var
  DM: TDataModule1;
  Id: Integer;
begin
  if not TryStrToInt(Req.Params['id'], Id) or (Id <= 0) then begin
    Res.Status(400)
       .ContentType('application/json')
       .Send('{"error":"invalid id"}');
    Exit;
  end;

  DM := TDataModule1.Create(nil);
  try
    try
      if not DM.DeleteCliente(Id) then begin
        Res.Status(404)
           .ContentType('application/json')
           .Send('{"error":"not found"}');
        Exit;
      end;

      Res.Status(200)
         .ContentType('application/json')
         .Send('{"ok":true}');
    except
      on E: Exception do begin
        Res.Status(500)
           .ContentType('application/json')
           .Send('{"error":"internal server error"}');
      end;
    end;
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
