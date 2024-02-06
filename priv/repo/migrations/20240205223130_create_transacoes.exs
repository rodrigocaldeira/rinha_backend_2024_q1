defmodule RinhaBackend.Repo.Migrations.CreateTransacoes do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE tipo AS ENUM ('c', 'd')"
    drop_query = "DROP TYPE tipo"
    execute(create_query, drop_query)

    create table(:transacoes) do
      add :valor, :integer, null: false
      add :tipo, :tipo, null: false
      add :descricao, :string, null: false
      add :cliente_id, references(:clientes, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:transacoes, [:cliente_id])
  end
end
