defmodule RinhaBackend.Transacao do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transacoes" do
    field :valor, :integer
    field :tipo, Ecto.Enum, values: [:c, :d]
    field :descricao, :string
    belongs_to :cliente, RinhaBackend.Cliente

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(transacao, attrs) do
    transacao
    |> cast(attrs, [:valor, :tipo, :descricao, :cliente_id])
    |> validate_required([:valor, :tipo, :descricao, :cliente_id])
    |> validate_number(:valor, greater_than: 0)
    |> validate_length(:descricao, min: 1, max: 10)
  end
end
