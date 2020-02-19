defmodule RumblWeb.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      RumblWeb.Endpoint,
      RumblWeb.Presence
    ]

    opts = [strategy: :one_for_one, name: RumblWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RumblWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
