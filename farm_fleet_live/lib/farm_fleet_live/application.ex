defmodule FarmFleetLive.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FarmFleetLiveWeb.Telemetry,
      #FarmFleetLive.Repo,
      FarmFleetLive.VehicleSupervisor,
      {DNSCluster, query: Application.get_env(:farm_fleet_live, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FarmFleetLive.PubSub},
      # Start a worker by calling: FarmFleetLive.Worker.start_link(arg)
      # {FarmFleetLive.Worker, arg},
      # Start to serve requests, typically the last entry
      FarmFleetLiveWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FarmFleetLive.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    FarmFleetLive.DemoRunner.start_demo()

    {:ok, pid}
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FarmFleetLiveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
