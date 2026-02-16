unit uDataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef, FireDAC.Comp.UI,
  FireDAC.Phys.SQLite, System.JSON, uClienteModel, System.Generics.Collections,
  uDatabaseConstants;

type
  TDataModule1 = class(TDataModule)
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    function NewQuery: TFDQuery;
    procedure ExecuteInTransaction(const AProc: TProc);
  public
    { Public declarations }
    procedure OpenClientes;
    procedure OpenClienteById(AId: Integer);
    function LoadClientes: TObjectList<TCliente>;
    function LoadClienteById(AId: Integer): TCliente;
    function EmailExists(const AEmail: string; AIgnoreId: Integer = 0): Boolean;
    function InsertCliente(
      const ANome, AEmail, ATelefone: string
    ): Integer;
    function UpdateCliente(AId: Integer; const ANome, AEmail, ATelefone: string
      ): Boolean;
    function DeleteCliente(AId: Integer): Boolean;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  FDConnection1.ConnectionDefName := CONNECTION_NAME;
  FDConnection1.LoginPrompt := False;
  FDConnection1.Connected := True;
end;

function TDataModule1.DeleteCliente(AId: Integer): Boolean;
var
  Q: TFDQuery;
  LDelId: Boolean;
begin
  LDelId := False;

  ExecuteInTransaction(
    procedure
    begin
      Q := NewQuery;
      try
        Q.SQL.Text :=
          'DELETE FROM Clientes WHERE Id = :Id';

        Q.ParamByName('Id').AsInteger := AId;
        Q.ExecSQL;

        LDelId := Q.RowsAffected > 0;
      finally
        Q.Free;
      end;
    end
  );
  Result := LDelId;
end;

function TDataModule1.InsertCliente(const ANome, AEmail, ATelefone: string): Integer;
var
  Q: TFDQuery;
  LNewId: Integer;
begin
  LNewId := 0;

  ExecuteInTransaction(
    procedure
    begin
      Q := NewQuery;
      try
        Q.SQL.Text :=
          'INSERT INTO Clientes (Nome, Email, Telefone) ' +
          'VALUES (:Nome, :Email, :Telefone)';

        Q.ParamByName('Nome').AsString     := ANome;
        Q.ParamByName('Email').AsString    := AEmail;
        Q.ParamByName('Telefone').AsString := ATelefone;
        Q.ExecSQL;

        Q.Close;
        Q.SQL.Text := 'SELECT last_insert_rowid() AS Id';
        Q.Open;

        LNewId := Q.FieldByName('Id').AsInteger;
      finally
        Q.Free;
      end;
    end
  );
  Result := LNewId;
end;

function TDataModule1.LoadClienteById(AId: Integer): TCliente;
var
  Q: TFDQuery;
begin
  Result := nil;

  Q := NewQuery;
  try
    Q.SQL.Text :=
      'SELECT Id, Nome, Email, Telefone ' +
      'FROM Clientes WHERE Id = :Id';

    Q.ParamByName('Id').AsInteger := AId;
    Q.Open;

    if not Q.IsEmpty then
    begin
      Result := TCliente.Create;
      Result.Id       := Q.FieldByName('Id').AsInteger;
      Result.Nome     := Q.FieldByName('Nome').AsString;
      Result.Email    := Q.FieldByName('Email').AsString;
      Result.Telefone := Q.FieldByName('Telefone').AsString;
    end;
  finally
    Q.Free;
  end;
end;

function TDataModule1.LoadClientes: TObjectList<TCliente>;
var
  Q: TFDQuery;
  Cliente: TCliente;
begin
  Result := TObjectList<TCliente>.Create(True);

  Q := NewQuery;
  try
    Q.SQL.Text :=
      'SELECT Id, Nome, Email, Telefone FROM Clientes';

    Q.Open;

    while not Q.Eof do
    begin
      Cliente := TCliente.Create;
      Cliente.Id       := Q.FieldByName('Id').AsInteger;
      Cliente.Nome     := Q.FieldByName('Nome').AsString;
      Cliente.Email    := Q.FieldByName('Email').AsString;
      Cliente.Telefone := Q.FieldByName('Telefone').AsString;

      Result.Add(Cliente);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TDataModule1.NewQuery: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FDConnection1;
end;

procedure TDataModule1.OpenClienteById(AId: Integer);
begin
  FDQuery1.Close;
  FDQuery1.SQL.Text :=
    'SELECT Id, Nome, Email, Telefone FROM Clientes WHERE Id = :Id';
  FDQuery1.ParamByName('Id').AsInteger := AId;
  FDQuery1.Open;
end;

procedure TDataModule1.OpenClientes;
begin
  FDQuery1.Close;
  FDQuery1.SQL.Text :=
    'SELECT Id, Nome, Email, Telefone FROM Clientes';
  FDQuery1.Open;
end;

function TDataModule1.UpdateCliente(AId: Integer; const ANome, AEmail, ATelefone: string
): Boolean;
var
  Q: TFDQuery;
  LUpdId: Boolean;
begin
  LUpdId := False;

  ExecuteInTransaction(
    procedure
    begin
      Q := NewQuery;
      try
        Q.SQL.Text :=
          'UPDATE Clientes ' +
          'SET Nome = :Nome, Email = :Email, Telefone = :Telefone ' +
          'WHERE Id = :Id';

        Q.ParamByName('Nome').AsString     := ANome;
        Q.ParamByName('Email').AsString    := AEmail;
        Q.ParamByName('Telefone').AsString := ATelefone;
        Q.ParamByName('Id').AsInteger      := AId;

        Q.ExecSQL;

        LUpdId := Q.RowsAffected > 0;
      finally
        Q.Free;
      end;
    end
  );
  Result := LUpdId;
end;

function TDataModule1.EmailExists(const AEmail: string; AIgnoreId: Integer = 0): Boolean;
var
  Q: TFDQuery;
begin
  Q := NewQuery;
  try
    Q.SQL.Text :=
      'SELECT 1 FROM Clientes WHERE Email = :Email';

    if AIgnoreId > 0 then
      Q.SQL.Add('AND Id <> :Id');

    Q.ParamByName('Email').AsString := AEmail;

    if AIgnoreId > 0 then
      Q.ParamByName('Id').AsInteger := AIgnoreId;

    Q.Open;

    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

procedure TDataModule1.ExecuteInTransaction(const AProc: TProc);
begin
  FDConnection1.StartTransaction;
  try
    AProc;
    FDConnection1.Commit;
  except
    FDConnection1.Rollback;
    raise;
  end;
end;

end.
