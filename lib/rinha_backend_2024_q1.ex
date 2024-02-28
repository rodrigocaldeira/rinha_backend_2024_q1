defmodule RinhaBackend do
  @moduledoc """
  RinhaBackend keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias RinhaBackend.Cliente
  alias RinhaBackend.Repo

  import Ecto.Query

  def busca_cliente(cliente_id) do
    Repo.get(Cliente, cliente_id)
    |> case do
      nil -> {:error, :not_found}
      cliente -> {:ok, cliente}
    end
  end

  def registra_transacao(attrs) do
    Repo.transaction(fn ->
      Cliente
      |> where([c], c.id == ^attrs.cliente_id)
      |> lock("FOR UPDATE")
      |> Repo.one()
      |> case do
        nil ->
          Repo.rollback(:not_found)
          {:error, :not_found}

        cliente ->
          valor = define_valor(attrs)
          ultimas_transacoes = insere_transacao(cliente.ultimas_transacoes, attrs)

          changeset =
            Cliente.changeset(cliente, %{
              nome: cliente.nome,
              limite: cliente.limite,
              saldo: cliente.saldo + valor,
              ultimas_transacoes: ultimas_transacoes
            })

          Repo.update(changeset)
          |> case do
            {:ok, cliente} -> cliente
            _error -> {:error, :transacao_invalida}
          end
      end
    end)
    |> case do
      {:ok, cliente} -> {:ok, cliente}
      {:error, :not_found} -> {:error, :not_found}
      _error -> {:error, :transacao_invalida}
    end
  end

  defp define_valor(attrs) do
    case attrs.tipo do
      "c" -> attrs.valor
      "d" -> -attrs.valor
    end
  end

  defp insere_transacao(ultimas_transacoes, attrs) do
    nova_transacao = %{
      valor: attrs.valor,
      tipo: attrs.tipo,
      descricao: attrs.descricao,
      realizada_em: DateTime.utc_now()
    }

    [nova_transacao | ultimas_transacoes]
    |> Enum.take(10)
  end
end
