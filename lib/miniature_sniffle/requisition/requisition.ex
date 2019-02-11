defmodule MiniatureSniffle.Requisition do
  @moduledoc """
  The Requisition context.
  """

  import Ecto.Query, warn: false
  alias MiniatureSniffle.Repo
  alias MiniatureSniffle.Requisition.Order

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end
end
