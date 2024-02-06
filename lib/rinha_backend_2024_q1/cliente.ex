defmodule RinhaBackend.Cliente do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clientes" do
    field :nome, :string
    field :limite, :integer
    field :saldo, :integer, default: 0
    has_many :ultimas_transacoes, RinhaBackend.Transacao

    timestamps()
  end

  @doc false
  def changeset(cliente, attrs) do
    cliente
    |> cast(attrs, [:nome, :limite, :saldo])
    |> validate_required([:nome, :limite, :saldo])
    |> check_constraint(:saldo,
      name: :saldo_maior_que_o_limite,
      message: "saldo deve ser maior ou igual ao limite * -1",
      check: "saldo >= limite * -1"
    )
  end
end
