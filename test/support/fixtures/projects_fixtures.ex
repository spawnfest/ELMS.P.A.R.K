defmodule Elmspark.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Elmspark.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{

      })
      |> Elmspark.Projects.create_project()

    project
  end
end
