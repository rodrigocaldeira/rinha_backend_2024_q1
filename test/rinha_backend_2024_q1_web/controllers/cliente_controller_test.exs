defmodule RinhaBackendWeb.ClienteControllerTest do
  use RinhaBackendWeb.ConnCase

  alias RinhaBackend.Cliente
  alias RinhaBackend.Repo

  setup do
    {:ok, cliente} = Repo.insert(%Cliente{id: 6, nome: "Fulano", limite: 1000})
    {:ok, cliente: cliente}
  end

  test "GET /clientes/:id/extrato", %{conn: conn, cliente: cliente} do
    conn = get(conn, ~p"/clientes/#{cliente.id}/extrato")

    assert %{
             "saldo" => %{
               "total" => 0,
               "data_extrato" => _,
               "limite" => 1000
             },
             "ultimas_transacoes" => []
           } = json_response(conn, 200)
  end

  test "GET /clientes/:id/extrato com cliente não cadastrado", %{conn: conn} do
    conn = get(conn, ~p"/clientes/0/extrato")
    assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
  end

  test "GET /clientes/:id/extrato com algumas transações", %{conn: conn, cliente: cliente} do
    RinhaBackend.registra_transacao(%{
      valor: 50,
      tipo: :d,
      descricao: "Débito",
      cliente_id: cliente.id
    })

    RinhaBackend.registra_transacao(%{
      valor: 100,
      tipo: :c,
      descricao: "Crédito",
      cliente_id: cliente.id
    })

    conn = get(conn, ~p"/clientes/#{cliente.id}/extrato")

    assert %{
             "saldo" => %{
               "total" => 50,
               "data_extrato" => _,
               "limite" => 1000
             },
             "ultimas_transacoes" => [
               %{
                 "valor" => 100,
                 "tipo" => "c",
                 "descricao" => "Crédito",
                 "realizado_em" => _
               },
               %{
                 "valor" => 50,
                 "tipo" => "d",
                 "descricao" => "Débito",
                 "realizado_em" => _
               }
             ]
           } = json_response(conn, 200)
  end

  test "POST /clientes/:id/transacoes com transação de crédito", %{conn: conn, cliente: cliente} do
    conn =
      post(conn, ~p"/clientes/#{cliente.id}/transacoes", %{
        "valor" => 100,
        "tipo" => "c",
        "descricao" => "Crédito"
      })

    assert %{
             "saldo" => 100,
             "limite" => 1000
           } = json_response(conn, 200)
  end
end
