defmodule RinhaBackend do
  @moduledoc """
  RinhaBackend keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias RinhaBackend.Cliente
  alias RinhaBackend.Repo
  alias RinhaBackend.Transacao

  import Ecto.Query

  def busca_cliente(cliente_id) do
    query_transacoes = monta_query_transacoes(cliente_id)

    query_cliente =
      from(c in Cliente,
        where: c.id == ^cliente_id,
        preload: [ultimas_transacoes: ^query_transacoes]
      )

    Repo.all(query_cliente)
    |> Enum.at(0)
    |> case do
      nil -> {:error, :not_found}
      cliente -> {:ok, cliente}
    end
  end

  def registra_transacao(attrs) do
    Repo.get(Cliente, attrs.cliente_id)
    |> case do
      nil ->
        {:error, :not_found}

      cliente ->
        novo_saldo = define_novo_saldo(cliente, attrs)

        if novo_saldo < -cliente.limite do
          {:error, :transacao_invalida}
        else
          Ecto.Multi.new()
          |> Ecto.Multi.update(:cliente, Cliente.changeset(cliente, %{saldo: novo_saldo}))
          |> Ecto.Multi.insert(:transacao, Transacao.changeset(%Transacao{}, attrs))
          |> Repo.transaction()
          |> case do
            {:ok, %{cliente: cliente}} ->
              query_transacoes = monta_query_transacoes(cliente.id)
              {:ok, Repo.preload(cliente, [ultimas_transacoes: query_transacoes])}

            _error ->
              {:error, :transacao_invalida}
          end
        end
    end
  end

  defp define_novo_saldo(cliente, attrs) do
    case attrs.tipo do
      :c -> cliente.saldo + attrs.valor
      :d -> cliente.saldo - attrs.valor
    end
  end

  def monta_query_transacoes(cliente_id) do
    from(t in Transacao,
      where: t.cliente_id == ^cliente_id,
      order_by: [desc: t.inserted_at],
      limit: 10
    )
  end
end
