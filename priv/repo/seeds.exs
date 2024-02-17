# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     RinhaBackend.Repo.insert!(%RinhaBackend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
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
