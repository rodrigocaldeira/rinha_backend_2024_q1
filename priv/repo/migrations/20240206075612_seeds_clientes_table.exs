defmodule RinhaBackend.Repo.Migrations.SeedsClientesTable do
  use Ecto.Migration

  def up do
    RinhaBackend.Repo.insert!(%RinhaBackend.Cliente{
      id: 1,
      nome: "o barato sai caro",
      limite: 1000 * 100
    })

    RinhaBackend.Repo.insert!(%RinhaBackend.Cliente{
      id: 2,
      nome: "zan corp ltda",
      limite: 800 * 100
    })

    RinhaBackend.Repo.insert!(%RinhaBackend.Cliente{
      id: 3,
      nome: "les cruders",
      limite: 10000 * 100
    })

    RinhaBackend.Repo.insert!(%RinhaBackend.Cliente{
      id: 4,
      nome: "padaria joia de cocaia",
      limite: 100_000 * 100
    })

    RinhaBackend.Repo.insert!(%RinhaBackend.Cliente{id: 5, nome: "kid mais", limite: 5000 * 100})
  end

  def down do
    RinhaBackend.Repo.delete_all(RinhaBackend.Cliente)
  end
end
