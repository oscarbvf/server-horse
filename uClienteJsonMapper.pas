unit uClienteJsonMapper;

interface

uses
  System.JSON, FireDAC.Comp.Client;

function ClientesQueryToJSONArray(AQuery: TFDQuery): TJSONArray;

implementation

function ClientesQueryToJSONArray(AQuery: TFDQuery): TJSONArray;
var
  Obj: TJSONObject;
begin
  Result := TJSONArray.Create;

  AQuery.First;
  while not AQuery.Eof do
  begin
    Obj := TJSONObject.Create;
    Obj.AddPair('id', TJSONNumber.Create(AQuery.FieldByName('Id').AsInteger));
    Obj.AddPair('nome', AQuery.FieldByName('Nome').AsString);
    Obj.AddPair('email', AQuery.FieldByName('Email').AsString);
    Obj.AddPair('telefone', AQuery.FieldByName('Telefone').AsString);

    Result.AddElement(Obj);
    AQuery.Next;
  end;
end;

end.

