unit uDatabaseConfig;

interface

procedure InitializeDatabaseInfrastructure;

implementation

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  FireDAC.Stan.Intf,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  uDatabaseConstants;

procedure ConfigureConnectionDef;
var
  oDef: IFDStanConnectionDef;
  DBPath: string;
begin
  DBPath := ExtractFilePath(ParamStr(0)) + DB_NAME;

  if FDManager.ConnectionDefs.FindConnectionDef(CONNECTION_NAME) = nil then begin
    oDef := FDManager.ConnectionDefs.AddConnectionDef;

    oDef.Name := CONNECTION_NAME;
    with oDef.Params do begin
      DriverID := 'SQLite';

      Values['Database'] := DBPath;
      Values['LockingMode'] := 'Normal';

      // Pooling
      Values['Pooled'] := 'True';
      Values['POOL_MaximumItems']   := POOL_MAXITEMS;
      Values['POOL_ExpireTimeout']  := POOL_EXPIRE_TIMEOUT;
      Values['POOL_CleanupTimeout'] := POOL_CLEANUP_TIMEOUT;
      Values['JournalMode']         := 'WAL';
      Values['Synchronous']         := 'Normal';
      Values['BusyTimeout']         := '5000';
    end;
    oDef.Apply;
  end;

end;

procedure InitializeSchema;
var
  Conn: TFDConnection;
  Q: TFDQuery;
begin
  Conn := TFDConnection.Create(nil);
  try
    Conn.ConnectionDefName := CONNECTION_NAME;
    Conn.LoginPrompt := False;
    Conn.Connected := True;

    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;

      Q.SQL.Text :=
        'CREATE TABLE IF NOT EXISTS Clientes (' +
        ' Id INTEGER PRIMARY KEY AUTOINCREMENT,' +
        ' Nome TEXT NOT NULL,' +
        ' Email TEXT,' +
        ' Telefone TEXT' +
        ')';

      Q.ExecSQL;

    finally
      Q.Free;
    end;

  finally
    Conn.Free;
  end;
end;

procedure InitializeDatabaseInfrastructure;
begin
  ConfigureConnectionDef;
  InitializeSchema;
end;

end.
