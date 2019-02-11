defmodule MiniatureSniffle.Repo.Migrations.CreatePatients do
  use Ecto.Migration

  def change do
    create table(:patients) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      timestamps()
    end
  end
end
