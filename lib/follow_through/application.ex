defmodule FollowThrough.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      FollowThrough.Repo,
      FollowThroughWeb.Endpoint,
      FollowThrough.DigestSupervisor
    ]

    if Mix.env() == :prod do
      {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)
    end

    Supervisor.start_link(children, strategy: :one_for_one, name: FollowThrough.Supervisor)
  end

  def config_change(changed, _new, removed) do
    FollowThroughWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
