defmodule MiniatureSniffle.Requisition.Patient do
  use Ecto.Schema
  import Ecto.Changeset

  # allows duplicate patients because deduplicating people is hard

  schema "patients" do
    field :first_name, :string
    field :last_name, :string
    timestamps()
  end

  @doc false
  def changeset(patient, attrs) do
    patient
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end
end
