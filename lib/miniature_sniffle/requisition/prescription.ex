defmodule MiniatureSniffle.Requisition.Prescription do
  use Ecto.Schema
  import Ecto.Changeset


  schema "prescriptions" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(prescription, attrs) do
    prescription
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
