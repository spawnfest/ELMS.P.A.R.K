defmodule Elmspark.Elmspark.Events do
  alias Phoenix.PubSub

  def broadcast(event, payload) do
    PubSub.broadcast(Elmspark.PubSub, "events", {event, payload})
    payload
  end

  def subscribe() do
    PubSub.subscribe(Elmspark.PubSub, "events")
  end
end
