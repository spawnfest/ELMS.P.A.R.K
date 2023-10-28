defmodule Elmspark.Elmspark.Blueprint do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "blueprints" do
    field :description, :string
    field :title, :string
    field :works, :string
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(blueprint, attrs) do
    blueprint
    |> cast(attrs, [:title, :description, :works])
    |> validate_required([:title, :description, :works])
  end
end
