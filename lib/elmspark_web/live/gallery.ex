defmodule ElmsparkWeb.GalleryLive do
  use ElmsparkWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="p-8 min-h-screen flex flex-col items-center bg-treehouse-pattern">
      <h1 class="text-4xl font-handwritten mb-4 border-4 border-dashed border-brown px-6 py-3 rounded bg-yellow-300 shadow-lg">
        Gallery
      </h1>
      <p class="text-lg mb-6 font-handwritten">All the secret missions:</p>
      <ul id="projects" phx-update="stream" class="list-decimal list-inside w-full">
        <a
          :for={{dom_id, project} <- @streams.projects}
          id={dom_id}
          href={~p"/projects/#{project.id}"}
          class="block mb-2 hover:bg-gray-100 p-4 border-2 border-brown rounded-lg transition shadow-lg"
        >
          <li class="flex items-center bg-white p-4 rounded-lg">
            <p class="text-gray-800 font-handwritten text-xl"><%= project.blueprint.title %></p>
          </li>
        </a>
      </ul>
      <a href={~p"/projects/new"} class="mt-6">
        <button class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg shadow-lg">
          New Mission
        </button>
      </a>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    projects = Elmspark.Projects.list_compiled_projects()
    {:ok, stream(socket, :projects, projects)}
  end
end
