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
        |> halt()
    end
  end

  def call(%{path_info: ["clientes", _id, "transacoes"]} = conn, _opts) do
    case validar_parametros_transacao(conn) do
      :ok ->
        conn

      :error ->
        conn
        |> put_status(:unprocessable_entity)
        |> Phoenix.Controller.put_view(RinhaBackendWeb.ErrorJSON)
        |> Phoenix.Controller.render("422.json")
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

  defp validar_parametros_transacao(%{params: params}) do
    case is_integer(params["valor"]) and params["valor"] > 0 do
      true ->
        case params["tipo"] in ["c", "d"] do
          true ->
            case not is_nil(params["descricao"]) and String.length(params["descricao"]) in 1..10 do
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
