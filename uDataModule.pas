unit uDataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef, FireDAC.Comp.UI,
  FireDAC.Phys.SQLite;

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
  end;

var
  DataModule1: TDataModule1;

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

end.
