defmodule Elmspark.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias Elmspark.Repo

  alias Elmspark.Projects.Project
  alias Elmspark.Elmspark.EllmProgram
  alias Elmspark.Elmspark.Blueprint
  alias Elmspark.Elmspark.SparkServer

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  def list_compiled_projects do
    # join on ellm_programs
    query =
      from p in Project,
        join: e in EllmProgram,
        on: p.id == e.project_id,
        join: bl in Blueprint,
        on: p.blueprint_id == bl.id,
        preload: [:ellm_program, :blueprint],
        where: not is_nil(e.view) and is_nil(e.error),
        select: p

    Repo.all(query)
  end

  def get_programs(project_id) do
    query =
      from ep in EllmProgram,
        join: p in Project,
        on: p.id == ep.project_id,
        where: p.id == ^project_id,
        order_by: [asc: ep.inserted_at]

    Repo.all(query)
  end

  def retry_build(project_id) do
    case get_project(project_id) do
      nil ->
        {:error, "Project not found"}

      project ->
        {:ok, {_task, project}} = SparkServer.generate_app(project.blueprint_id)
        {:ok, project}
    end
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)
  def get_project(id), do: Repo.get(Project, id)

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end
end
