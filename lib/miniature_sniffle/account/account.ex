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
      %Pharmacy{name: "Alfa Pharmacy"}

      iex> get_pharmacy("Zooloo Pharmacy")
      nil

  """
  def get_pharmacy(name) do
    Repo.get_by(Pharmacy, name: name)
  end
end
