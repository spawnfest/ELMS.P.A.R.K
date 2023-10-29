defmodule Elmspark.ElmDocumentationServer do
  use GenServer
  require Logger

  # CLIENT

  def available_modules() do
    GenServer.call(__MODULE__, :available_modules)
  end

  def get_module_documentation(module) do
    GenServer.call(__MODULE__, {:get_module_documentation, module})
  end

  # SERVER

  def start_link(opts) do
    Logger.info("hitting start link")
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    {:ok, opts, {:continue, :load_elm_documentation}}
  end

  @impl true
  def handle_continue(:load_elm_documentation, _opts) do
    Logger.info("Loading elm documentation")
    module_documentation = load_elm_documentation()
    {:noreply, module_documentation}
  end

  def load_elm_documentation() do
    renames = fn %{values: values, comment: comment} ->
      %{
        functions:
          Enum.map(values, fn %{comment: comment, name: name, type: type} ->
            %{name: name, type: type, description: comment}
          end),
        description: comment
      }
    end

    module_map =
      :code.priv_dir(:elmspark)
      |> Path.join(["static", "/elm_definitions/core.json"])
      |> Path.expand()
      |> File.read!()
      |> Jason.decode!(keys: :atoms)
      |> Enum.map(fn %{name: name} = available_module -> {name, renames.(available_module)} end)
      |> Map.new()

    Logger.info("loaded")
    module_map
  end

  @impl true
  def handle_call(:available_modules, _from, available_modules) do
    {:reply, Map.keys(available_modules), available_modules}
  end

  @impl true
  def handle_call({:get_module_documentation, module}, _from, available_modules) do
    {:reply, Map.get(available_modules, module), available_modules}
  end
end
