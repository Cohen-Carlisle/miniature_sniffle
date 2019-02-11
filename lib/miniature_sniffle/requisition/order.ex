defmodule MiniatureSniffle.Requisition.Order do
  use Ecto.Schema
  import Ecto.Changeset


  schema "orders" do
    field :location_id, :id
    field :patient_id, :id
    field :prescription_id, :id

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [])
    |> validate_required([])
  end
end
