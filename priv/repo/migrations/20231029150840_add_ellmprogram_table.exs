defmodule Elmspark.Repo.Migrations.AddEllmprogramTable do
  use Ecto.Migration

  def change do
    create table(:ellm_programs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :imports, {:array, :string}
      add :model_fields, :text
      add :model_alias, :text
      add :view, :text
      add :init, :text
      add :messages, :text
      add :update, :text
      add :stage, :text
      add :error, {:array, :text}
      add :global_imports, {:array, :string}
      add :blueprint_id, references(:blueprints, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:ellm_programs, [:blueprint_id, :stage])
  end
end
