defmodule MiniatureSniffle.Requisition.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias MiniatureSniffle.Requisition

  schema "orders" do
    belongs_to :location, Requisition.Location
    belongs_to :patient, Requisition.Patient
    belongs_to :prescription, Requisition.Prescription
    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:location_id, :patient_id, :prescription_id])
    |> validate_required([:location_id, :patient_id, :prescription_id])
    |> assoc_constraint(:location)
    |> assoc_constraint(:patient)
    |> assoc_constraint(:prescription)
  end
end
