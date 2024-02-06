defmodule RinhaBackendWeb.Router do
  use RinhaBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug RinhaBackendWeb.Plugs.Schema
  end

  scope "/", RinhaBackendWeb do
    pipe_through :api

    get "/clientes/:id/extrato", ClienteController, :extrato
    post "/clientes/:id/transacoes", ClienteController, :transacao
  end
end
