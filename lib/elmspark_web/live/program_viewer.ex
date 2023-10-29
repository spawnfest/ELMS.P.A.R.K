defmodule ElmsparkWeb.ProgramViewerLive do
  use ElmsparkWeb, :live_view
  alias Elmspark.Elmspark.Events
  alias Elmspark.Elmspark.EllmProgram

  def render(assigns) do
    ~H"""
    <div>
      Hello World
      <ul id="events" phx-update="stream">
        <li :for={{dom_id, event} <- @streams.events} id={dom_id}>
          <span><%= event.payload.stage %></span>
          - <%= event.name %>
          <div :if={event.name == "elm_compile_failed"}>
            <pre><%= event.payload.error %></pre>
            <pre><%= EllmProgram.to_code(event.payload) %></pre>
          </div>
        </li>
      </ul>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    Events.subscribe()
    {:ok, stream(socket, :events, [])}
  end

  def handle_info({event_name, payload}, socket) do
    event = %{id: Ecto.UUID.generate(), name: event_name, payload: payload}
    IO.inspect(payload, label: "PAYLOADDDDDD")
    {:noreply, stream_insert(socket, :events, event)}
  end
end
