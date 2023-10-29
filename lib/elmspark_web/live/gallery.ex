defmodule ElmsparkWeb.GalleryLive do
  use ElmsparkWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="p-8 min-h-screen flex flex-col items-center bg-green-100">
      <h1 class="text-5xl mb-4 px-6 py-4 rounded bg-red-600 text-white shadow-xl transform hover:scale-105 transition-transform">
        Sector E(LLM) Gallery
      </h1>
      <p class="text-xl mb-6 font-bold text-gray-700">Top Secret Missions:</p>
      <ul id="projects" phx-update="stream" class="list-decimal list-inside w-full">
        <a
          :for={{dom_id, project} <- @streams.projects}
          id={dom_id}
          href={~p"/projects/#{project.id}"}
          class="block mb-4 bg-white p-5 border-4 border-orange-500 rounded-xl transition-transform transform hover:scale-105 shadow-xl"
        >
          <li class="flex items-center space-x-4">
            <span class="text-3xl">📁</span>
            <p class="text-gray-800 text-xl font-bold"><%= project.blueprint.title %></p>
          </li>
        </a>
      </ul>
      <a href={~p"/projects/new"} class="mt-8">
        <button class="bg-blue-600 hover:bg-blue-800 text-white font-bold py-3 px-5 rounded-xl shadow-xl transform hover:scale-105 transition-transform">
          Add New Blueprint
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
