defmodule ElmsparkWeb.FormLive do
  use ElmsparkWeb, :live_view

  alias Elmspark.Elmspark.Blueprint
  alias Elmspark.Elmspark.SparkServer
  alias Elmspark.Repo

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        form: to_form(Blueprint.changeset(%Blueprint{}, %{}))
      )
      |> assign(:blueprints, Repo.all(Blueprint))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto">
    <.form
      for={@form}
      phx-change="update-form"
      phx-submit="submit"
      class="space-y-4 bg-white p-6 rounded-lg shadow-md "
    >
      <div class="font-bold text-xl mb-6">Sector E(LLM) Blueprint Form</div>
      <.input
        type="text"
        field={@form[:title]}
        placeholder="Code Name of your Gadget (e.g. G.U.M.Z.O.O.K.A.)"
        phx-debounce="1000"
        class="border-2 rounded px-4 py-2 w-full"
      />
      <.input
        type="textarea"
        field={@form[:description]}
        placeholder="Briefing (Tell us more about this gadget)"
        phx-debounce="1000"
        class="border-2 rounded px-4 py-2 w-full"
      />
      <.input
        type="textarea"
        field={@form[:works]}
        placeholder="Functionality (How does it operate?)"
        phx-debounce="1000"
        class="border-2 rounded px-4 py-2 w-full"
      />
      <.button class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg transition duration-200 transform hover:scale-105">
        Submit for Review
      </.button>
    </.form>
    <.show_blueprints blueprints={@blueprints} />
    </div>
    """
  end

  attr :blueprints, :any, required: true

  def show_blueprints(assigns) do
    ~H"""
    <div class="mt-8 p-6 bg-gradient-to-br from-blue-400 via-purple-500 to-red-500 rounded-lg shadow-lg">
      <h2 class="font-bold text-2xl mb-6 text-white">2x4 Tech Blueprints Archive</h2>
      <ul class="space-y-6">
        <%= for blueprint <- @blueprints do %>
          <li class="bg-white p-4 rounded-lg shadow-md">
            <div class="font-bold text-xl mb-2">
              Code Name: <%= blueprint.title %>
            </div>
            <div class="text-gray-700 mt-2">
              Briefing: <%= blueprint.description %>
            </div>
            <div class="text-gray-500 mt-2 mb-4">
              Functionality: <%= blueprint.works %>
            </div>
            <a :if={project_ready?(blueprint.id)} href={~p"/projects/#{blueprint.id}"}>
              <.button class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg shadow-sm transition duration-200 transform hover:scale-105">
                Operate Gadget
              </.button>
            </a>
            <.button
              phx-click="build_blueprint"
              phx-value-id={blueprint.id}
              class="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg shadow-sm transition duration-200 transform hover:scale-105"
            >
              Construct Blueprint
            </.button>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def handle_event("build_blueprint", %{"id" => id}, socket) do
    with {:ok, {task, project_id}} <- SparkServer.generate_app(id) do
      {:noreply, redirect(socket, to: "/programs/#{project_id}")}
    else
      _ ->
        {:noreply, socket}
    end
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

  defp release_directory(blueprint_id, p \\ []) do
    ["priv", "static", "assets", blueprint_id]
    |> Enum.concat(p)
    |> Path.join()
  end

  defp project_ready?(blueprint_id) do
    File.exists?(release_directory(blueprint_id, ["index.html"]))
  end
end
