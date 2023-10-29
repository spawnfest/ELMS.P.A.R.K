defmodule ElmsparkWeb.ProgramViewerLive do
  use ElmsparkWeb, :live_view
  alias Elmspark.Elmspark.Events
  alias Elmspark.Elmspark.EllmProgram
  alias Elmspark.Projects
  alias Elmspark.Repo

  def render(assigns) do
    ~H"""
    <div class="flex min-h-screen bg-gray-900">
      <!-- Left: List of Programs -->
      <.program_list project={@project} streams={@streams} />
      <!-- Right: Program Viewer -->
      <.program_viewer html={@html} />
    </div>
    """
  end

  defp program_list(assigns) do
    ~H"""
    <div class="w-72 bg-gray-800 p-8 rounded-lg shadow-xl mr-8">
      <!-- w-72 gives it a fixed width of 18rem -->
      <h1 class="text-2xl font-bold mb-2 text-gray-200">Project: <%= @project.blueprint.title %></h1>
      <h2 class="text-xl font-semibold mb-6 text-gray-300">Programs</h2>

      <button
        phx-click="retry"
        phx-value-id={@project.id}
        class="bg-blue-600 text-white px-4 py-2 rounded shadow mb-4 hover:bg-blue-700 transition duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50"
      >
        Retry
      </button>

      <ul id="events" phx-update="stream">
        <li
          :for={{dom_id, program} <- @streams.programs}
          class="my-3 p-4 bg-gray-700 rounded hover:bg-gray-600 transition duration-200 ease-in-out cursor-pointer"
          phx-click="select"
          phx-value-id={program.id}
          id={dom_id}
        >
          <div class="flex justify-between items-center">
            <span class="font-medium text-gray-400"><%= program.stage %></span>
            <div :if={program.error} class="text-red-600 flex items-center">
              <.icon name="hero-exclamation-circle" class="ml-1 h-4 w-4 animate-spin" />
            </div>
          </div>
        </li>
      </ul>
    </div>
    """
  end

  defp program_viewer(assigns) do
    ~H"""
    <div class="flex-1 bg-gray-800 p-6 rounded-lg shadow-lg">
      <h2 class="text-xl font-semibold mb-4 text-gray-300">Program Viewer</h2>
      <div class="bg-gray-700 p-4 whitespace-pre rounded">
        <pre><code class="language-elm text-gray-300"><%= @html %></code></pre>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    Events.subscribe()
    {:ok, socket |> assign(html: "") |> stream(:events, [])}
  end

  def handle_params(%{"project_id" => project_id}, _params, socket) do
    programs = Projects.get_programs(project_id)
    project = Projects.get_project!(project_id) |> Repo.preload(:blueprint)

    {:noreply,
     socket
     |> assign(html: "")
     |> assign(project: project)
     |> stream(:programs, programs)
     |> assign(:programs, programs)
     |> assign(project_id: project_id)}
  end

  def handle_event("select", %{"id" => id}, socket) do
    program = Enum.find(socket.assigns.programs, fn p -> p.id == id end)
    {:noreply, socket |> assign(html: EllmProgram.to_code(program))}
  end

  def handle_event("retry", %{"id" => id}, socket) do
    with {:ok, project_id} <- Projects.retry_build(id) do
      programs = Projects.get_programs(project_id)
      socket = socket |> assign(:programs, programs) |> stream(:programs, programs)
      {:noreply, socket |> redirect(to: ~p"/programs/#{project_id}")}
    end
  end

  def handle_info({_event_name, payload}, socket) do
    {:noreply,
     socket |> assign(html: EllmProgram.to_code(payload)) |> stream_insert(:programs, payload)}
  end
end
