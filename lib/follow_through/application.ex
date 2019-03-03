defmodule FollowThrough.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      FollowThrough.Repo,
      FollowThroughWeb.Endpoint,
      FollowThrough.DigestSupervisor
    ]

    {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)

    Supervisor.start_link(children, strategy: :one_for_one, name: FollowThrough.Supervisor)
  end

  def config_change(changed, _new, removed) do
    FollowThroughWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
