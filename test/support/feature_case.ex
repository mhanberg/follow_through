defmodule FollowThroughWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias FollowThrough.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Wallaby.Query
      import FollowThrough.Factory

      alias FollowThroughWeb.Router.Helpers, as: Routes

      @spec login(session :: Wallaby.Browser.session()) ::
              {%FollowThrough.User{}, Wallaby.Browser.session()}
      def login(%{session: session}) do
        user = insert(:user)

        session =
          session
          |> visit("/auth/test/callback?id=#{user.id}")

        %{current_user: user, session: session}
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FollowThrough.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(FollowThrough.Repo, {:shared, self()})
    end

    # start_supervised!(FollowThrough.DigestSupervisor)

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(FollowThrough.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end
