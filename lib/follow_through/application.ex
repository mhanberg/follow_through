defmodule FollowThrough.Application do
  @moduledoc false
  @digest_supervisor Application.get_env(:follow_through, :digest_supervisor)

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        FollowThrough.Repo,
        FollowThroughWeb.Endpoint,
        @digest_supervisor
      ]
      |> Enum.filter(& &1)

    if Application.get_all_env(:sentry) != [] do
      {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)
    end

    Supervisor.start_link(children, strategy: :one_for_one, name: FollowThrough.Supervisor)
  end

  @impl true
  def config_change(changed, _new, removed) do
    FollowThroughWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
