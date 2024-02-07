defmodule RinhaBackendWeb.ClienteController do
  use RinhaBackendWeb, :controller

  alias RinhaBackend

  def extrato(conn, %{"id" => id}) do
    RinhaBackend.busca_cliente(id)
    |> case do
      {:ok, cliente} ->
        render(conn, :extrato, cliente: cliente)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> put_view(RinhaBackendWeb.ErrorJSON)
        |> render("404.json")
    end
  end

  def transacao(conn, %{"id" => id, "valor" => valor, "tipo" => tipo, "descricao" => descricao}) do
    tipo = String.to_existing_atom(tipo)

    RinhaBackend.registra_transacao(%{
      valor: valor,
      tipo: tipo,
      descricao: descricao,
      cliente_id: id
    })
    |> case do
      {:ok, cliente} ->
        render(conn, :transacao, cliente: cliente)

      {:error, :transacao_invalida} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(RinhaBackendWeb.ErrorJSON)
        |> render("422.json")

      _error ->
        conn
        |> put_status(:internal_server_error)
        |> put_view(RinhaBackendWeb.ErrorJSON)
        |> render("500.json")
    end
  end
end
