defmodule MiniatureSniffle.RequisitionTest do
  use MiniatureSniffle.DataCase

  alias MiniatureSniffle.Requisition

  describe "orders" do
    alias MiniatureSniffle.Requisition.Order

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def order_fixture(attrs \\ %{}) do
      {:ok, order} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Requisition.create_order()

      order
    end

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Requisition.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Requisition.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      assert {:ok, %Order{} = order} = Requisition.create_order(@valid_attrs)
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Requisition.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      assert {:ok, %Order{} = order} = Requisition.update_order(order, @update_attrs)
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Requisition.update_order(order, @invalid_attrs)
      assert order == Requisition.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Requisition.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Requisition.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Requisition.change_order(order)
    end
  end
end
