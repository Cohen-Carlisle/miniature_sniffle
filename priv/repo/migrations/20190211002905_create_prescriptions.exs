defmodule MiniatureSniffle.Repo.Migrations.CreatePrescriptions do
  use Ecto.Migration

  def change do
    create table(:prescriptions) do
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:prescriptions, [:name])
  end
end
