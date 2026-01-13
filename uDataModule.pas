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
  public
    { Public declarations }
    procedure EnsureDB;
  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  // Ajuste do caminho do DB: arquivo na mesma pasta do EXE
  FDConnection1.Params.DriverID := 'SQLite';
  FDConnection1.Params.Database := ExtractFilePath(ParamStr(0)) + 'db\database.db';
  FDConnection1.Params.Add('LockingMode=Normal');
  FDConnection1.LoginPrompt := False;
  FDConnection1.Connected := True;
  EnsureDB;
end;

procedure TDataModule1.EnsureDB;
begin
  // Se não existir, cria tabela Clientes simples
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

end.
