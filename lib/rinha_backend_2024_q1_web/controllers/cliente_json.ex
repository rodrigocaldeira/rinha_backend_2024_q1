defmodule RinhaBackendWeb.ClienteJSON do
  def extrato(%{cliente: cliente}) do
    %{
      saldo: %{
        total: cliente.saldo,
        data_extrato: DateTime.utc_now(),
        limite: cliente.limite
      },
      ultimas_transacoes: map_ultimas_transacoes(cliente.ultimas_transacoes)
    }
  end

  def transacao(%{cliente: cliente}) do
    %{
      saldo: cliente.saldo,
      limite: cliente.limite
    }
  end

  defp map_ultimas_transacoes(transacoes) do
    Enum.map(transacoes, &map_transacao/1)
  end

  defp map_transacao(transacao) do
    %{
      valor: transacao["valor"],
      tipo: transacao["tipo"],
      descricao: transacao["descricao"],
      realizada_em: transacao["realizada_em"]
    }
  end
end
