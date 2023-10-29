defmodule Elmspark.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :blueprint_id, references(:blueprints, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    alter table(:blueprints) do
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
    end

    alter table(:ellm_programs) do
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
    end

    create index(:projects, [:blueprint_id])
  end
end
