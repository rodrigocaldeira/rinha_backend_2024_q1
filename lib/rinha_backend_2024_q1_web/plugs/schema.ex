defmodule RinhaBackendWeb.Plugs.Schema do
  import Plug.Conn

  def init(opts), do: opts

  def call(%{path_info: ["clientes", id, "extrato"]} = conn, _opts) do
    Integer.parse(id)
    |> case do
      {_, _} ->
        conn

      :error ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.put_view(RinhaBackendWeb.ErrorJSON)
        |> Phoenix.Controller.render("400.json")
    end
  end

  def call(%{path_info: ["clientes", id, "transacoes"]} = conn, _opts) do
    Integer.parse(id)
    |> case do
      {_, _} ->
        case validar_parametros_transacao(conn) do
          :ok ->
            conn

          :error ->
            conn
            |> put_status(:bad_request)
            |> Phoenix.Controller.put_view(RinhaBackendWeb.ErrorJSON)
            |> Phoenix.Controller.render("400.json")
            |> halt()
        end

      :error ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.put_view(RinhaBackendWeb.ErrorJSON)
        |> Phoenix.Controller.render("400.json")
        |> halt()
    end
  end

  def call(conn, _opts) do
    conn
    |> put_status(:not_found)
    |> Phoenix.Controller.put_view(RinhaBackendWeb.ErrorJSON)
    |> Phoenix.Controller.render("404.json")
    |> halt()
  end

  defp validar_parametros_transacao(conn) do
    body_params = conn.params

    case Map.has_key?(body_params, "valor") do
      true ->
        case Map.has_key?(body_params, "tipo") and body_params["tipo"] in ["c", "d"] do
          true ->
            case Map.has_key?(body_params, "descricao") do
              true -> :ok
              false -> :error
            end

          false ->
            :error
        end

      false ->
        :error
    end
  end
end
