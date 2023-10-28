defmodule ElmsparkWeb.FormLive do
  use ElmsparkWeb, :live_view

  alias Elmspark.Elmspark.Blueprint

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        form: to_form(Blueprint.changeset(%Blueprint{}, %{}))
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.form for={@form} phx-change="update-form" phx-submit="submit">
      <.input type="text" field={@form[:title]} placeholder="Name your elm app" phx-debounce="1000" />
      <br />
      <.input
        type="textarea"
        field={@form[:description]}
        placeholder="Describe your elm app"
        phx-debounce="1000"
      />
      <br />
      <.input
        type="textarea"
        field={@form[:works]}
        placeholder="How do we know it works"
        phx-debounce="1000"
      />
      <br />
      <.button>
        Submit
      </.button>
    </.form>
    """
  end

  def handle_event(
        "update-form",
        %{"blueprint" => blueprint_params} = _params,
        socket
      ) do
    form =
      Blueprint.changeset(%Blueprint{}, blueprint_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event(
        "submit",
        %{"blueprint" => blueprint_params} = _params,
        socket
      ) do
    case Blueprint.changeset(%Blueprint{}, blueprint_params) |> Repo.insert() do
      {:ok, blueprint} ->
        changeset = Blueprint.changeset(blueprint, %{})
        {:noreply, socket |> assign(form: to_form(changeset))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(form: to_form(changeset))}
    end

    {:noreply, socket}
  end
end
