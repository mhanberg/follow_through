defmodule FollowThroughWeb.Router do
  use FollowThroughWeb, :router

  if Application.get_all_env(:sentry) != [] do
    use Plug.ErrorHandler
    use Sentry.Plug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :authenticate do
    plug Ueberauth
  end

  pipeline :authorize do
    plug :logged_in?
  end

  pipeline :slack do
    plug FollowThroughWeb.VerifyFromSlack
    plug :slack_auth
  end

  if Mix.env() == :dev, do: forward("/sent_emails", Bamboo.SentEmailViewerPlug)

  scope "/auth", FollowThroughWeb do
    pipe_through [:browser, :authorize]

    get "/slack/callback", SlackAuthController, :callback
    get "/slack/connect", SlackAuthController, :new
    post "/slack/connect", SlackAuthController, :create
  end

  scope "/auth", FollowThroughWeb do
    pipe_through [:api]

    post "/slack/events/callback", SlackEventController, :callback
  end

  scope "/auth", FollowThroughWeb do
    pipe_through [:browser]

    resources "/", AuthController, only: [:new, :create]
  end

  scope "/auth", FollowThroughWeb do
    pipe_through [:authenticate, :browser]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback

    delete "/logout", AuthController, :delete
  end

  scope "/", FollowThroughWeb do
    pipe_through [:browser, :authorize]

    resources "/teams", TeamController do
      resources "/obligations", ObligationController
      resources "/member", TeamMemberController, only: [:delete]
    end

    resources "/invitations", InvitationController, only: [:create]
    resources "/feedback", FeedbackController, only: [:new, :create]

    get "/join/:code", JoinTeamController, :new
    post "/join/:code", JoinTeamController, :join
  end

  scope "/", FollowThroughWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/login", PageController, :login
    get "/privacy", PageController, :privacy
    get "/slack/install", SlackAuthController, :install
  end

  scope "/", FollowThroughWeb do
    pipe_through [:api, :slack]

    post "/slack", SlackController, :slash
  end

  defp logged_in?(conn, _) do
    case current_user(conn) do
      nil ->
        conn
        |> Phoenix.Controller.redirect(to: "/")
        |> halt()

      _ ->
        conn
    end
  end

  defp slack_auth(conn, _) do
    slack_user_id = conn.params["user_id"]
    slack_channel_id = conn.params["channel_id"]

    FollowThrough.SlackConnection
    |> FollowThrough.Repo.get_by(slack_id: slack_user_id)
    |> FollowThrough.Repo.preload(:user)
    |> case do
      %FollowThrough.SlackConnection{user: user} ->
        conn
        |> put_session(:current_user, user)

      nil ->
        conn
        |> put_status(200)
        |> put_view(FollowThroughWeb.SlackView)
        |> render(:login, channel_id: slack_channel_id, user_id: slack_user_id)
        |> halt()
    end
  end
end
