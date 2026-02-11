unit uClienteModel;

interface

type
  TCliente = class
  private
    FId: Integer;
    FNome: string;
    FEmail: string;
    FTelefone: string;
  public
    property Id: Integer read FId write FId;
    property Nome: string read FNome write FNome;
    property Email: string read FEmail write FEmail;
    property Telefone: string read FTelefone write FTelefone;
  end;

implementation

end.

