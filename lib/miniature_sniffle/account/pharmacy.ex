defmodule MiniatureSniffle.Account.Pharmacy do
  use Ecto.Schema
  import Ecto.Changeset
  alias MiniatureSniffle.Requisition

  schema "pharmacies" do
    field :name, :string
    timestamps()
    has_many :locations, Requisition.Location
  end

  @doc false
  def changeset(pharmacy, attrs) do
    pharmacy
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
