defmodule ElmsparkWeb.ProgramViewerLive do
  use ElmsparkWeb, :live_view
  alias Elmspark.Elmspark.Events
  alias Elmspark.Elmspark.EllmProgram

  def render(assigns) do
    ~H"""
    <div class="flex divide-solid divide-x">
      <div class="w-1/2">
        <.button>Retry</.button>
        <ul id="events" phx-update="stream">
          <li :for={{dom_id, event} <- @streams.events} id={dom_id}>
            <span><%= event.payload.stage %></span>
            - <%= event.name %>
            <div :if={event.name == "elm_compile_failed"} class="pr-4">
              <pre><%= event.payload.error %></pre>
              <pre><%= EllmProgram.to_code(event.payload) %></pre>
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

  def handle_info({event_name, payload}, socket) do
    event = %{id: Ecto.UUID.generate(), name: event_name, payload: payload}
    IO.inspect(payload, label: "PAYLOADDDDDD")
    {:noreply, socket |> assign(html: payload.code) |> stream_insert(:events, event)}
  end
end
