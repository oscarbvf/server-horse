unit uClienteJsonMapper;

interface

uses
  System.JSON, FireDAC.Comp.Client;

function QueryToJSONArray(AQuery: TFDQuery): TJSONArray;

implementation

function QueryToJSONArray(AQuery: TFDQuery): TJSONArray;
var
  arr: TJSONArray;
  obj: TJSONObject;
begin
  arr := TJSONArray.Create;
  AQuery.First;
  while not AQuery.Eof do begin
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

end.

