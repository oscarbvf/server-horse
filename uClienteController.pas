unit uClienteController;

interface

uses
  Horse, System.SysUtils, System.Classes, FireDAC.Comp.Client, Data.DB,
  FireDAC.Stan.Param, System.JSON, uDataModule, System.Generics.Collections;

procedure RegisterClienteRoutes;

implementation

uses
  Horse.Request, Horse.Response;

function QueryToJSONArray(AQuery: TFDQuery): TJSONArray;
var
  arr: TJSONArray;
  obj: TJSONObject;
begin
  arr := TJSONArray.Create;
  AQuery.First;
  while not AQuery.Eof do
  begin
    obj := TJSONObject.Create;
    obj.AddPair('Id', TJSONNumber.Create(AQuery.FieldByName('Id').AsInteger));
    obj.AddPair('Nome', TJSONString.Create(AQuery.FieldByName('Nome').AsString));
    obj.AddPair('Email', TJSONString.Create(AQuery.FieldByName('Email').AsString));
    obj.AddPair('Telefone', TJSONString.Create(AQuery.FieldByName('Telefone').AsString));
    arr.Add(obj);
    AQuery.Next;
  end;
  Result := arr;
end;

procedure GetClientes(Req: THorseRequest; Res: THorseResponse);
var
  DM: TDataModule1;
  Arr: TJSONArray;
begin
  DM := TDataModule1.Create(nil);
  try
    DM.FDQuery1.SQL.Text := 'SELECT Id, Nome, Email, Telefone FROM Clientes';
    DM.FDQuery1.Open;

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
    DM.FDQuery1.Close;
    DM.Free;
  end;
end;

procedure GetClienteById(Req: THorseRequest; Res: THorseResponse);
var
  Id: Integer;
  DM: TDataModule1;
  Obj: TJSONObject;
begin
  if not TryStrToInt(Req.Params['Id'], Id) or (Id <= 0) then begin
    Res
      .Status(400)
      .Send<TJSONObject>(
        TJSONObject.Create.AddPair('error', 'invalid id')
      );
    Exit;
  end;

  DM := TDataModule1.Create(nil);
  try
    with DM.FDQuery1 do begin
      SQL.Text := 'SELECT Id, Nome, Email, Telefone FROM Clientes WHERE Id = :Id';
      ParamByName('Id').AsInteger := Id;
      Open;

      if IsEmpty then begin
        Res
          .Status(404)
          .Send<TJSONObject>(
            TJSONObject.Create.AddPair('error', 'not found')
          );
        Exit;
      end;
    end;

    Obj := TJSONObject.Create;
    try
      with DM.FDQuery1 do begin
        Obj.AddPair('Id', TJSONNumber.Create(FieldByName('Id').AsInteger));
        Obj.AddPair('Nome', TJSONString.Create(FieldByName('Nome').AsString));
        Obj.AddPair('Email', TJSONString.Create(FieldByName('Email').AsString));
        Obj.AddPair('Telefone', TJSONString.Create(FieldByName('Telefone').AsString));
      end;

      Res
        .Status(200)
        .ContentType('application/json')
        .Send(Obj.ToJSON);
    finally
      Obj.Free;
    end;
  finally
    DM.FDQuery1.Close;
    DM.Free;
  end;
end;

procedure CreateCliente(Req: THorseRequest; Res: THorseResponse);
var
  DM: TDataModule1;
  jo: TJSONObject;
  NovoId: Integer;
  nome, email, telefone: string;
begin
  jo := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;

  if not Assigned(jo) then begin
    Res.Status(400)
      .ContentType('application/json')
      .Send('{"error":"invalid json"}');
    Exit;
  end;

  try
    if not Jo.TryGetValue<string>('Nome', nome) or
       not Jo.TryGetValue<string>('Email', email) then begin
      Res
        .Status(400)
        .ContentType('application/json')
        .Send('{"error":"nome and email are required"}');
      Exit;
    end;

    Jo.TryGetValue<string>('Telefone', telefone);

    DM := TDataModule1.Create(nil);
    try
      DM.FDConnection1.Connected := True;
      DM.FDConnection1.StartTransaction;
      try
        with DM.FDQuery1 do begin
          SQL.Text :=
            'INSERT INTO Clientes (Nome, Email, Telefone) ' +
            'VALUES (:Nome, :Email, :Telefone)';

          ParamByName('Nome').AsString := nome;
          ParamByName('Email').AsString := email;
          ParamByName('Telefone').AsString := telefone;
          ExecSQL;

          SQL.Text := 'SELECT last_insert_rowid() AS Id';
          Open;
          NovoId := FieldByName('Id').AsInteger;
        end;

        DM.FDConnection1.Commit;
        Res
          .Status(201)
          .ContentType('application/json')
          .Send(Format('{"id":%d}', [NovoId]));
      except
        on E: Exception do
        begin
          DM.FDConnection1.Rollback;

          Res
            .Status(500)
            .ContentType('application/json')
            .Send('{"error":"internal server error"}');
        end;
      end;
    finally
      DM.FDQuery1.Close;
      DM.Free;
    end;
  finally
    Jo.Free;
  end;
end;

procedure UpdateCliente(Req: THorseRequest; Res: THorseResponse);
var
  id: Integer;
  DM: TDataModule1;
  jo: TJSONObject;
  nome, email, telefone: String;
begin
  if not TryStrToInt(Req.Params['Id'], id) or (id <= 0) then begin
    Res.Status(400)
      .ContentType('application/json')
      .Send('{"error":"invalid id"}');
    Exit;
  end;

  jo := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
  if not Assigned(jo) then begin
    Res.Status(400)
      .ContentType('application/json')
      .Send('{"error":"invalid json"}');
    Exit;
  end;

  try
    if not Jo.TryGetValue<string>('Nome', nome) or
       not Jo.TryGetValue<string>('Email', email) then begin
      Res
        .Status(400)
        .ContentType('application/json')
        .Send('{"error":"nome and email are required"}');
      Exit;
    end;

    Jo.TryGetValue<string>('Telefone', telefone);

    DM := TDataModule1.Create(nil);
    try
      DM.FDConnection1.Connected := True;
      DM.FDConnection1.StartTransaction;
      try
        with DM.FDQuery1 do begin
          SQL.Text :=
            'UPDATE Clientes ' +
            'SET Nome = :Nome, Email = :Email, Telefone = :Telefone ' +
            'WHERE Id = :Id';

          ParamByName('Nome').AsString := nome;
          ParamByName('Email').AsString := email;
          ParamByName('Telefone').AsString := telefone;
          ParamByName('Id').AsInteger := id;
          ExecSQL;
        end;

        if DM.FDQuery1.RowsAffected = 0 then begin
          DM.FDConnection1.Rollback;

          Res
            .Status(404)
            .ContentType('application/json')
            .Send('{"error":"not found"}');
          Exit;
        end;

        DM.FDConnection1.Commit;

        Res
          .Status(200)
          .ContentType('application/json')
          .Send('{"ok":true}');
      except
        on E: Exception do
        begin
          DM.FDConnection1.Rollback;

          Res
            .Status(500)
            .ContentType('application/json')
            .Send('{"error":"internal server error"}');
        end;
      end;
    finally
      DM.FDQuery1.Close;
      DM.Free;
    end;
  finally
    Jo.Free;
  end;
end;

procedure DeleteCliente(Req: THorseRequest; Res: THorseResponse);
var
  DM: TDataModule1;
  id: Integer;
begin
  if not TryStrToInt(Req.Params['id'], id) or (id <= 0) then begin
    Res.Status(400)
      .ContentType('application/json')
      .Send('{"error":"invalid id"}');
    Exit;
  end;

  DM := TDataModule1.Create(nil);

  try
    DM.FDConnection1.Connected := True;
    DM.FDConnection1.StartTransaction;
    try
      with DM.FDQuery1 do begin
        Close;
        SQL.Text := 'DELETE FROM Clientes WHERE Id = :Id';
        ParamByName('Id').AsInteger := id;
        ExecSQL;

        if RowsAffected = 0 then begin
          DataModule1.FDConnection1.Rollback;

          Res.Status(404)
            .ContentType('application/json')
            .Send('{"error":"not found"}');
          Exit;
        end;
      end;

      DM.FDConnection1.Commit;

      Res.Status(200)
        .ContentType('application/json')
        .Send('{"ok":true}');

    except
      on E: Exception do begin
        DM.FDConnection1.Rollback;

        Res.Status(500)
          .ContentType('application/json')
          .Send('{"error":"internal server error"}');
      end;
    end;
  finally
    DM.FDQuery1.Close;
    DM.Free;
  end;
end;

procedure RegisterClienteRoutes;
begin
  THorse.Get('/clientes', GetClientes);
  THorse.Get('/clientes/:id', GetClienteById);
  THorse.Post('/clientes', CreateCliente);
  THorse.Put('/clientes/:id', UpdateCliente);
  THorse.Delete('/clientes/:id', DeleteCliente);
end;

end.
