defmodule Elmspark.Elmspark.SparkServer do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:ok, opts}
  end

  def generate_app(blueprint_id) do
    GenServer.call(__MODULE__, {:generate_app_from_blueprint, blueprint_id})
  end

  def handle_call({:generate_app_from_blueprint, blueprint_id}, _from, state) do
    case generate_app_from_blueprint(blueprint_id) do
      {:ok, {task, project_id}} ->
        {:reply, {:ok, {task, project_id}}, state}

      {:ok, app} ->
        {:reply, {:ok, app}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def generate_app_from_blueprint(blueprint_id) do
    case Elmspark.Elmspark.get_blueprint(blueprint_id) do
      nil ->
        {:error, "Blueprint not found"}

      blueprint ->
        # TODO: directly calling, and can throw errors.
        {:ok, project} = Elmspark.Projects.create_project(%{blueprint_id: blueprint_id})
        Elmspark.Elmspark.ElmMakeServer.new_project(project.id, blueprint.id)

        {:ok,
         {Task.async(fn -> Elmspark.Elmspark.gen_app(project.id, blueprint) end), project.id}}
    end
  end

  def handle_info({_ref, {:ok, program}}, state) do
    Logger.info("Program generated: #{program.id}")
    {:noreply, state}
  end

  def handle_info({_ref, {:error, {:max_retries_reached, _fun}}}, state) do
    {:noreply, state}
  end

  def handle_info({_ref, {:error, {:max_failures_reached, _fun}}}, state) do
    {:noreply, state}
  end
  def handle_info({:DOWN, _, :process, _, _}, state) do
    {:noreply, state}
  end
end
