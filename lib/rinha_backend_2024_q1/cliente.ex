defmodule RinhaBackend.Cliente do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clientes" do
    field :nome, :string
    field :limite, :integer
    field :saldo, :integer, default: 0
    field :ultimas_transacoes, {:array, :map}, default: []

    timestamps()
  end

  @doc false
  def changeset(cliente, attrs) do
    cliente
    |> cast(attrs, [:nome, :limite, :saldo, :ultimas_transacoes])
    |> validate_required([:nome, :limite, :saldo])
    |> check_constraint(:saldo, name: :saldo_maior_que_o_limite)
  end
end
