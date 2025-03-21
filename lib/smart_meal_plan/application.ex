defmodule SmartMealPlan.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SmartMealPlanWeb.Telemetry,
      SmartMealPlan.Repo,
      {DNSCluster, query: Application.get_env(:smart_meal_plan, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SmartMealPlan.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SmartMealPlan.Finch},
      # Start a worker by calling: SmartMealPlan.Worker.start_link(arg)
      # {SmartMealPlan.Worker, arg},
      # Start to serve requests, typically the last entry
      SmartMealPlanWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SmartMealPlan.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SmartMealPlanWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
