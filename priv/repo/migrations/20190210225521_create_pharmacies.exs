defmodule MiniatureSniffle.Repo.Migrations.CreatePharmacies do
  use Ecto.Migration

  def change do
    create table(:pharmacies) do
      add :name, :string

      timestamps()
    end

    create unique_index(:pharmacies, [:name])
  end
end
