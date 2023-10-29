defmodule Elmspark.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  alias Elmspark.Elmspark.Blueprint
  alias Elmspark.Elmspark.EllmProgram
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    belongs_to :blueprint, Blueprint

    has_one :ellm_program, EllmProgram
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:blueprint_id])
    |> validate_required([:blueprint_id])
  end
end
