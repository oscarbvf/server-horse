unit uDataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef, FireDAC.Comp.UI,
  FireDAC.Phys.SQLite, System.JSON;

type
  TDataModule1 = class(TDataModule)
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    function GetDatabaseFilePath: string;
    procedure ConfigureConnection;
    procedure ConnectDatabase;
    procedure InitializeDatabase;
    procedure CreateClientesTable;
  public
    { Public declarations }
    procedure OpenClientes;
    procedure OpenClienteById(AId: Integer);
    function LoadClienteById(AId: Integer; AJson: TJSONObject): Boolean;
    function InsertCliente(
      const ANome, AEmail, ATelefone: string
    ): Integer;
    function UpdateCliente(
      AId: Integer;
      const ANome, AEmail, ATelefone: string
    ): Boolean;
    function DeleteCliente(AId: Integer): Boolean;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TDataModule1.ConfigureConnection;
begin
  FDConnection1.LoginPrompt := False;
  FDConnection1.Params.Clear;
  FDConnection1.Params.DriverID := 'SQLite';
  FDConnection1.Params.Add('LockingMode=Normal');
  FDConnection1.Params.Database := GetDatabaseFilePath;
end;

procedure TDataModule1.ConnectDatabase;
begin
  try
    FDConnection1.Connected := True;
  except
    on E: Exception do
      raise Exception.Create(
        'Failed to connect to SQLite database. ' + E.Message
      );
  end;
end;

procedure TDataModule1.CreateClientesTable;
begin
  FDQuery1.Connection := FDConnection1;
  FDQuery1.SQL.Text :=
    'CREATE TABLE IF NOT EXISTS Clientes (' +
    ' Id INTEGER PRIMARY KEY AUTOINCREMENT,' +
    ' Nome TEXT NOT NULL,' +
    ' Email TEXT,' +
    ' Telefone TEXT' +
    ')';

  FDQuery1.ExecSQL;
end;

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  ConfigureConnection;
  ConnectDatabase;
  InitializeDatabase;
end;

function TDataModule1.DeleteCliente(AId: Integer): Boolean;
begin

  if not FDConnection1.Connected then
    FDConnection1.Connected := True;

  FDConnection1.StartTransaction;
  try
    FDQuery1.Close;
    FDQuery1.SQL.Text :=
      'DELETE FROM Clientes WHERE Id = :Id';

    FDQuery1.ParamByName('Id').AsInteger := AId;
    FDQuery1.ExecSQL;

    Result := FDQuery1.RowsAffected > 0;

    if Result then
      FDConnection1.Commit
    else
      FDConnection1.Rollback;
  except
    FDConnection1.Rollback;
    raise;
  end;
end;

function TDataModule1.GetDatabaseFilePath: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'db\database.db';
end;

procedure TDataModule1.InitializeDatabase;
begin
  FDConnection1.StartTransaction;
  try
    CreateClientesTable;
    FDConnection1.Commit;
  except
    FDConnection1.Rollback;
    raise;
  end;
end;

function TDataModule1.InsertCliente(const ANome, AEmail,
  ATelefone: string): Integer;
begin

  if not FDConnection1.Connected then
    FDConnection1.Connected := True;

  FDConnection1.StartTransaction;
  try
    FDQuery1.Close;
    FDQuery1.SQL.Text :=
      'INSERT INTO Clientes (Nome, Email, Telefone) ' +
      'VALUES (:Nome, :Email, :Telefone)';

    FDQuery1.ParamByName('Nome').AsString := ANome;
    FDQuery1.ParamByName('Email').AsString := AEmail;
    FDQuery1.ParamByName('Telefone').AsString := ATelefone;
    FDQuery1.ExecSQL;

    FDQuery1.Close;
    FDQuery1.SQL.Text := 'SELECT last_insert_rowid() AS Id';
    FDQuery1.Open;

    Result := FDQuery1.FieldByName('Id').AsInteger;

    FDConnection1.Commit;
  except
    FDConnection1.Rollback;
    raise; // deixa o controller decidir o HTTP
  end;
end;

function TDataModule1.LoadClienteById(AId: Integer;
  AJson: TJSONObject): Boolean;
begin
  OpenClienteById(AId);

  Result := not FDQuery1.IsEmpty;
  if not Result then
    Exit;

  AJson.AddPair('Id', TJSONNumber.Create(FDQuery1.FieldByName('Id').AsInteger));
  AJson.AddPair('Nome', FDQuery1.FieldByName('Nome').AsString);
  AJson.AddPair('Email', FDQuery1.FieldByName('Email').AsString);
  AJson.AddPair('Telefone', FDQuery1.FieldByName('Telefone').AsString);
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

function TDataModule1.UpdateCliente(AId: Integer; const ANome, AEmail,
  ATelefone: string): Boolean;
begin

  if not FDConnection1.Connected then
    FDConnection1.Connected := True;

  FDConnection1.StartTransaction;
  try
    FDQuery1.Close;
    FDQuery1.SQL.Text :=
      'UPDATE Clientes ' +
      'SET Nome = :Nome, Email = :Email, Telefone = :Telefone ' +
      'WHERE Id = :Id';

    FDQuery1.ParamByName('Nome').AsString := ANome;
    FDQuery1.ParamByName('Email').AsString := AEmail;
    FDQuery1.ParamByName('Telefone').AsString := ATelefone;
    FDQuery1.ParamByName('Id').AsInteger := AId;
    FDQuery1.ExecSQL;

    Result := FDQuery1.RowsAffected > 0;

    if Result then
      FDConnection1.Commit
    else
      FDConnection1.Rollback;
  except
    FDConnection1.Rollback;
    raise;
  end;
end;

end.
