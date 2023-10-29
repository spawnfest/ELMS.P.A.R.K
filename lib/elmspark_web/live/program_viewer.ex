defmodule ElmsparkWeb.ProgramViewerLive do
  use ElmsparkWeb, :live_view
  alias Elmspark.Elmspark.Events
  alias Elmspark.Elmspark.EllmProgram
  alias Elmspark.Projects

  def render(assigns) do
    ~H"""
    <div class="flex divide-solid divide-x">
      <div class="w-1/2">
        <.button>Retry</.button>
        <ul id="events" phx-update="stream">
          <li :for={{dom_id, program} <- @streams.programs} id={dom_id}>
            <span><%= program.stage %></span>
            <div :if={program.error} class="pr-4">
              <pre><%= program.error %></pre>
              <pre><%= EllmProgram.to_code(program) %></pre>
            </div>
          </li>
        </ul>
      </div>
      <div class="w-1/2"><%= @html %></div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    Events.subscribe()
    {:ok, socket |> assign(html: "") |> stream(:events, [])}
  end

  def handle_params(%{"project_id" => project_id}, _params, socket) do
    programs = Projects.get_programs(project_id)
    {:noreply,
     socket
     |> assign(html: "")
     |> stream(:programs, programs)
     |> assign(project_id: project_id)}
  end

  def handle_info({event_name, payload}, socket) do
    IO.inspect({event_name, payload}, label: "Event")
    event = %{id: Ecto.UUID.generate(), name: event_name, payload: payload}

    {:noreply, socket |> assign(html: payload.code) |> stream_insert(:events, event)}
  end
end
