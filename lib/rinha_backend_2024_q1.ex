defmodule RinhaBackend do
  @moduledoc """
  RinhaBackend keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias RinhaBackend.Cliente
  alias RinhaBackend.Repo

  def busca_cliente(cliente_id) do
    Repo.get(Cliente, cliente_id)
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
          update_attrs = %{
            saldo: novo_saldo,
            ultimas_transacoes: insere_transacao(cliente.ultimas_transacoes, attrs)
          }

          Cliente.changeset(cliente, update_attrs)
          |> Repo.update()
          |> case do
            {:ok, cliente} ->
              {:ok, cliente}

            _error ->
              {:error, :transacao_invalida}
          end
        end
    end
  end

  defp define_novo_saldo(cliente, attrs) do
    case attrs.tipo do
      "c" -> cliente.saldo + attrs.valor
      "d" -> cliente.saldo - attrs.valor
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
