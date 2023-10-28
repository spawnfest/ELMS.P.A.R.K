defmodule Elmspark.Elmspark.AppGenServer do
  use GenServer
  require Logger

  alias Elmspark.Elmspark

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:ok, opts}
  end

  def handle_call({:generate_app_from_blueprint, blueprint_id}, _from, state) do
    case generate_app_from_blueprint(blueprint_id) do
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
        Elmspark.gen_app(blueprint)
    end
  end
end
