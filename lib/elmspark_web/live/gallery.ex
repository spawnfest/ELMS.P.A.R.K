defmodule ElmsparkWeb.GalleryLive do
  use ElmsparkWeb, :live_view

def render(assigns) do
  ~H"""
  <div class="p-8 min-h-screen flex flex-col items-center bg-gray-100">
    <h1 class="text-4xl mb-4 px-6 py-3 rounded bg-blue-600 text-white shadow-lg">
      Gallery
    </h1>
    <p class="text-lg mb-6">All the secret missions:</p>
    <ul id="projects" phx-update="stream" class="list-decimal list-inside w-full">
      <a
        :for={{dom_id, project} <- @streams.projects}
        id={dom_id}
        href={~p"/projects/#{project.id}"}
        class="block mb-2 hover:bg-gray-200 p-4 border-2 border-gray-300 rounded-lg transition shadow-sm"
      >
        <li class="flex items-center bg-white p-4 rounded-lg">
          <p class="text-gray-800 text-xl font-medium"><%= project.blueprint.title %></p>
        </li>
      </a>
    </ul>
    <a href={~p"/projects/new"} class="mt-6">
      <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded shadow-lg">
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
