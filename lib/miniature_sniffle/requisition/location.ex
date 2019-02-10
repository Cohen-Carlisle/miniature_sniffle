defmodule MiniatureSniffle.Requisition.Location do
  use Ecto.Schema
  import Ecto.Changeset


  schema "locations" do
    field :latitude, :string
    field :longitude, :string
    field :pharmacy_id, :id

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:latitude, :longitude])
    |> validate_required([:latitude, :longitude])
  end
end
