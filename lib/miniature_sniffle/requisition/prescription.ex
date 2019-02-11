defmodule MiniatureSniffle.Requisition.Prescription do
  use Ecto.Schema
  import Ecto.Changeset
  alias MiniatureSniffle.Requisition

  schema "prescriptions" do
    field :name, :string
    timestamps()
    has_many :orders, Requisition.Order
  end

  @doc false
  def changeset(prescription, attrs) do
    prescription
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
