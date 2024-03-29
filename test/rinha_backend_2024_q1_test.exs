defmodule RinhaBackendTest do
  use RinhaBackend.DataCase

  alias RinhaBackend.Cliente
  alias RinhaBackend.Repo

  describe "Clientes" do
    test "Busca um cliente cadastrado" do
      {:ok, cliente} = Repo.insert(%Cliente{id: 6, nome: "Fulano", limite: 1000})
      {:ok, resultado} = RinhaBackend.busca_cliente(cliente.id)
      assert resultado.limite == cliente.limite
      assert resultado.saldo == cliente.saldo
    end

    test "Busca um cliente não cadastrado" do
      assert {:error, :not_found} = RinhaBackend.busca_cliente(0)
    end
  end

  describe "Transações" do
    setup do
      {:ok, cliente} = Repo.insert(%Cliente{id: 6, nome: "Fulano", limite: 1000})
      {:ok, cliente: cliente}
    end

    test "Insere uma transação de crédito", %{cliente: cliente} do
      assert {:ok, cliente} =
               RinhaBackend.registra_transacao(%{
                 valor: 100,
                 tipo: "c",
                 descricao: "Crédito",
                 cliente_id: cliente.id
               })

      assert cliente.saldo == 100

      [transacao] = cliente.ultimas_transacoes
      assert transacao.valor == 100
      assert transacao.tipo == "c"
    end

    test "Insere uma transação de débito", %{cliente: cliente} do
      assert {:ok, cliente} =
               RinhaBackend.registra_transacao(%{
                 valor: 100,
                 tipo: "d",
                 descricao: "Débito",
                 cliente_id: cliente.id
               })

      assert cliente.saldo == -100

      [transacao] = cliente.ultimas_transacoes
      assert transacao.valor == 100
      assert transacao.tipo == "d"
    end

    test "Insere uma transação de débito sem saldo suficiente", %{cliente: cliente} do
      assert {:error, :transacao_invalida} =
               RinhaBackend.registra_transacao(%{
                 valor: 1001,
                 tipo: "d",
                 descricao: "Débito",
                 cliente_id: cliente.id
               })

      {:ok, cliente} = RinhaBackend.busca_cliente(cliente.id)
      assert cliente.saldo == 0

      assert cliente.ultimas_transacoes == []
    end

    test "Várias transações acontecendo em paralelo", %{cliente: cliente} do
      1..25
      |> Enum.map(fn _ ->
        Task.async(fn ->
          RinhaBackend.registra_transacao(%{
            valor: 1,
            tipo: "d",
            descricao: "Débito",
            cliente_id: cliente.id
          })
        end)
      end)
      |> Enum.map(&Task.await/1)

      {:ok, cliente} = RinhaBackend.busca_cliente(cliente.id)
      assert cliente.saldo == -25

      1..25
      |> Enum.map(fn _ ->
        Task.async(fn ->
          RinhaBackend.registra_transacao(%{
            valor: 1,
            tipo: "c",
            descricao: "Crédito",
            cliente_id: cliente.id
          })
        end)
      end)
      |> Enum.map(&Task.await/1)

      {:ok, cliente} = RinhaBackend.busca_cliente(cliente.id)
      assert cliente.saldo == 0
    end
  end
end
