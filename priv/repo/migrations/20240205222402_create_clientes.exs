defmodule RinhaBackend.Repo.Migrations.CreateClientes do
  use Ecto.Migration

  def change do
    create table(:clientes, primary_key: false) do
      add :id, :integer, primary_key: true
      add :nome, :string, null: false
      add :limite, :integer, null: false
      add :saldo, :integer, null: false, default: 0

      timestamps()
    end

    create constraint(:clientes, :saldo,
             name: :saldo_maior_que_o_limite,
             check: "saldo >= limite * -1"
           )
  end
end
