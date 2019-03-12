ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(FollowThrough.Repo, :manual)

Application.put_env(:wallaby, :base_url, FollowThroughWeb.Endpoint.url())
{:ok, _} = Application.ensure_all_started(:wallaby)
