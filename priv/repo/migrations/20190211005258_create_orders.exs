defmodule MiniatureSniffle.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :location_id, references(:locations, on_delete: :nothing), null: false
      add :patient_id, references(:patients, on_delete: :nothing), null: false
      add :prescription_id, references(:prescriptions, on_delete: :nothing), null: false
      timestamps()
    end
    create index(:orders, [:location_id])
    create index(:orders, [:patient_id])
    create index(:orders, [:prescription_id])
  end
end
