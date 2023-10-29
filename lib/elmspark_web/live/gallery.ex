defmodule ElmsparkWeb.GalleryLive do
  use ElmsparkWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <ul id="projects" phx-update="stream">
        <a
          :for={{dom_id, project} <- @streams.projects}
          id={dom_id}
          href={~p"/projects/#{project.id}"}
        >
          <li>
            <p><%= project.blueprint.title %></p>
          </li>
        </a>
      </ul>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    projects = Elmspark.Projects.list_compiled_projects()
    {:ok, stream(socket, :projects, projects)}
  end
end
