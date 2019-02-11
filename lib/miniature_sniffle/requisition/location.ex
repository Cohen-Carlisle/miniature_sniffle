defmodule MiniatureSniffle.Requisition.Location do
  use Ecto.Schema
  import Ecto.Changeset
  alias MiniatureSniffle.{Account, Requisition}

  # latitude and longitude as strings is not ideal

  schema "locations" do
    field :latitude, :string
    field :longitude, :string
    belongs_to :pharmacy, Account.Pharmacy
    timestamps()
    has_many :orders, Requisition.Order
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:latitude, :longitude, :pharmacy_id])
    |> validate_required([:latitude, :longitude, :pharmacy_id])
    |> assoc_constraint(:pharmacy)
    |> unique_constraint(:latitude_and_longitude,
      name: :locations_latitude_longitude_pharmacy_id_index
    )
  end
end
