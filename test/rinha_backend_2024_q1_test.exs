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
      assert :ok =
               RinhaBackend.registra_transacao(%{
                 valor: 100,
                 tipo: :c,
                 descricao: "Crédito",
                 cliente_id: cliente.id
               })

      {:ok, cliente} = RinhaBackend.busca_cliente(cliente.id)
      assert cliente.saldo == 100

      [transacao] = cliente.ultimas_transacoes
      assert transacao.valor == 100
      assert transacao.tipo == :c
    end

    test "Insere uma transação de débito", %{cliente: cliente} do
      assert :ok =
               RinhaBackend.registra_transacao(%{
                 valor: 100,
                 tipo: :d,
                 descricao: "Débito",
                 cliente_id: cliente.id
               })

      {:ok, cliente} = RinhaBackend.busca_cliente(cliente.id)
      assert cliente.saldo == -100

      [transacao] = cliente.ultimas_transacoes
      assert transacao.valor == 100
      assert transacao.tipo == :d
    end

    test "Insere uma transação de débito sem saldo suficiente", %{cliente: cliente} do
      assert {:error, :transacao_invalida} =
               RinhaBackend.registra_transacao(%{
                 valor: 1001,
                 tipo: :d,
                 descricao: "Débito",
                 cliente_id: cliente.id
               })

      {:ok, cliente} = RinhaBackend.busca_cliente(cliente.id)
      assert cliente.saldo == 0

      assert cliente.ultimas_transacoes == []
    end

    test "Insere uma transação com valor negativo", %{cliente: cliente} do
      assert {:error, :transacao_invalida} =
               RinhaBackend.registra_transacao(%{
                 valor: -100,
                 tipo: :d,
                 descricao: "Débito",
                 cliente_id: cliente.id
               })

      {:ok, cliente} = RinhaBackend.busca_cliente(cliente.id)
      assert cliente.saldo == 0

      assert cliente.ultimas_transacoes == []
    end

    test "Insere uma transação com descrição nula", %{cliente: cliente} do
      assert {:error, :transacao_invalida} =
               RinhaBackend.registra_transacao(%{
                 valor: 100,
                 tipo: :d,
                 descricao: nil,
                 cliente_id: cliente.id
               })

      {:ok, cliente} = RinhaBackend.busca_cliente(cliente.id)
      assert cliente.saldo == 0

      assert cliente.ultimas_transacoes == []
    end

    test "Insere uma transação com descrição vazia", %{cliente: cliente} do
      assert {:error, :transacao_invalida} =
               RinhaBackend.registra_transacao(%{
                 valor: 100,
                 tipo: :d,
                 descricao: "",
                 cliente_id: cliente.id
               })

      {:ok, cliente} = RinhaBackend.busca_cliente(cliente.id)
      assert cliente.saldo == 0

      assert cliente.ultimas_transacoes == []
    end

    test "Insere uma transação com descrição muito longa", %{cliente: cliente} do
      assert {:error, :transacao_invalida} =
               RinhaBackend.registra_transacao(%{
                 valor: 100,
                 tipo: :d,
                 descricao: "Descrição muito longa",
                 cliente_id: cliente.id
               })

      {:ok, cliente} = RinhaBackend.busca_cliente(cliente.id)
      assert cliente.saldo == 0

      assert cliente.ultimas_transacoes == []
    end
  end
end
