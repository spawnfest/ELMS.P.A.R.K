defmodule ElmsparkWeb.ProgramViewerLive do
  use ElmsparkWeb, :live_view
  alias Elmspark.Elmspark.Events
  alias Elmspark.Elmspark.EllmProgram
  alias Elmspark.Projects
  alias Elmspark.Repo

  def render(assigns) do
    ~H"""
    <div class="flex min-h-screen p-8 bg-gray-100">
      <!-- Left: List of Programs -->
      <div class="flex-none  bg-white p-6 rounded-lg shadow-lg mr-8">
        <h1>Project: <%= @project.blueprint.title %></h1>
        <h2 class="text-xl font-semibold mb-4">Programs</h2>

        <button
          phx-click="retry"
          phx-value-id={@project.id}
          class="bg-blue-600 text-white px-4 py-2 rounded shadow mb-4 hover:bg-blue-700"
        >
          Retry
        </button>

        <ul id="events" phx-update="stream">
          <li
            :for={{_dom_id, program} <- @streams.programs}
            }
            class="my-2 p-4 bg-gray-50 rounded hover:bg-gray-200 transition"
            phx-click="select"
            phx-value-id={program.id}
          >
            <div class="flex justify-between">
              <span class="font-medium text-gray-700"><%= program.stage %></span>
              <div :if={program.error} class="text-red-600">
                <.icon name="hero-exclamation-circle" class="ml-1 h-3 w-3 animate-spin" />
              </div>
            </div>
          </li>
        </ul>
      </div>
      <!-- Right: Program Viewer -->
      <div class="flex-1 bg-white p-6 rounded-lg shadow-lg">
        <h2 class="text-xl font-semibold mb-4">Program Viewer</h2>
        <div class="bg-gray-50 p-4 whitespace-pre rounded">
          <pre><code class="language-elm"><%= @html %></code></pre>
        </div>
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
