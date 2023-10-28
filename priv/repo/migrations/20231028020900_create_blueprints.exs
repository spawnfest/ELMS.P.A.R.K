defmodule Elmspark.Repo.Migrations.CreateBlueprints do
  use Ecto.Migration

  def change do
    create table(:blueprints, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :description, :text
      add :works, :text
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:blueprints, [:user_id])
  end
end
