defmodule Elmspark.Elmspark.SparkServer do
  use GenServer
  require Logger

  alias Elmspark.Elmspark

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
      {:ok, task} ->
        {:reply, {:ok, task}, state}

      {:ok, app} ->
        {:reply, {:ok, app}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def generate_app_from_blueprint(blueprint_id) do
    case Elmspark.get_blueprint(blueprint_id) do
      nil ->
        {:error, "Blueprint not found"}

      blueprint ->
        # TODO: directly calling, and can throw errors.
        Elmspark.ElmMakeServer.new_project(blueprint.id)
        {:ok, Task.async(fn -> Elmspark.gen_app(blueprint) end)}
    end
  end

  def handle_info({ref, {:error, {:max_retries_reached, _fun}}}, state) do
    {:noreply, state}
  end

  def handle_info({:DOWN, _, :process, _, _}, state) do
    {:noreply, state}
  end
end
