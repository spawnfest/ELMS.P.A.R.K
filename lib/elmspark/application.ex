defmodule Elmspark.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElmsparkWeb.Telemetry,
      Elmspark.Repo,
      {DNSCluster, query: Application.get_env(:elmspark, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Elmspark.PubSub},
      {Elmspark.Elmspark.ElmMakeServer, name: Elmspark.ElmMakeServer},
      {Elmspark.Elmspark.SparkServer, name: Elmspark.Elmspark.SparkServer},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Elmspark.Finch},
      # Start a worker by calling: Elmspark.Worker.start_link(arg)
      # {Elmspark.Worker, arg},
      # Start to serve requests, typically the last entry
      ElmsparkWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Elmspark.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElmsparkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
