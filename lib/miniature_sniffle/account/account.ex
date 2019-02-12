defmodule MiniatureSniffle.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias MiniatureSniffle.Repo
  alias MiniatureSniffle.Account.Pharmacy

  @doc """
  Gets a single pharmacy by name.
  Returns `nil` if no result was found.

  ## Examples

      iex> get_pharmacy("Alfa Pharmacy")
      {:ok, %Pharmacy{name: "Alfa Pharmacy"}}

      iex> get_pharmacy("Zooloo Pharmacy")
      {:error, :pharmacy_not_found}

  """
  def get_pharmacy(name) do
    case Repo.get_by(Pharmacy, name: name) do
      %Pharmacy{} = pharmacy -> {:ok, pharmacy}
      nil -> {:error, :pharmacy_not_found}
    end
  end
end
