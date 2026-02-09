unit uHttpHelpers;

interface

uses
  Horse,
  System.SysUtils,
  System.JSON,
  Web.HTTPApp;

function GetIdParam(const Req: THorseRequest): Integer;
function GetBodyAsJSON(const Req: THorseRequest): TJSONObject;
function GetRequiredString(const Jo: TJSONObject; const FieldName: string): string;
function GetOptionalString(const Jo: TJSONObject; const FieldName: string): string;

implementation

function GetIdParam(const Req: THorseRequest): Integer;
begin
  if not TryStrToInt(Req.Params['id'], Result) or (Result <= 0) then
    raise EHorseException.New.Status(THTTPStatus.BadRequest).Error('invalid id');
end;

function GetBodyAsJSON(const Req: THorseRequest): TJSONObject;
begin
  Result := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
  if not Assigned(Result) then
    raise EHorseException.New.Status(THTTPStatus.BadRequest).Error('invalid json');
end;

function GetRequiredString(const Jo: TJSONObject; const FieldName: string): string;
begin
  if (Jo = nil) or
     (not Jo.TryGetValue<string>(FieldName, Result)) or
     Result.Trim.IsEmpty then
  begin
    raise EHorseException.New
      .Status(THTTPStatus.BadRequest)
      .Error(Format('%s is required', [FieldName]));
  end;

  Result := Result.Trim;
end;

function GetOptionalString(const Jo: TJSONObject; const FieldName: string): string;
begin
  if (Jo = nil) or (not Jo.TryGetValue<string>(FieldName, Result)) then
    Exit('');

  Result := Result.Trim;
end;

end.

