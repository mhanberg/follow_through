defmodule FollowThroughWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias FollowThrough.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias FollowThroughWeb.Router.Helpers, as: Routes
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FollowThrough.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(FollowThrough.Repo, {:shared, self()})
    end

    start_supervised!(FollowThrough.DigestSupervisor)

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(FollowThrough.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end
