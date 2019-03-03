defmodule FollowThroughWeb.Router do
  use FollowThroughWeb, :router

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
    plug :verify_from_slack
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

    get "/join/:code", JoinTeamController, :new
    post "/join/:code", JoinTeamController, :join
  end

  scope "/", FollowThroughWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/", FollowThroughWeb do
    pipe_through [:api, :slack]

    post "/slack", SlackController, :slash
  end

  defp verify_from_slack(conn, _) do
    signing_salt = System.get_env("SLACK_SIGNING_SECRET")
    [request_body] = conn.assigns[:raw_body]

    timestamp =
      conn
      |> get_req_header("x-slack-request-timestamp")
      |> List.first()
      |> String.to_integer()

    now =
      DateTime.utc_now()
      |> DateTime.to_unix()

    sig_base_string = "v0:#{timestamp}:#{request_body}"
    [slack_signature] = conn |> get_req_header("x-slack-signature")

    hash =
      "v0=#{:crypto.hmac(:sha256, signing_salt, sig_base_string) |> Base.encode16(case: :lower)}"

    with true <-
           now
           |> Kernel.-(timestamp)
           |> Kernel.abs()
           |> Kernel.<(60 * 5),
         true <- slack_signature == hash do
      conn
    else
      false ->
        conn
        |> Phoenix.Controller.put_view(FollowThroughWeb.ErrorView)
        |> Phoenix.Controller.render("403.json")
    end
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

    case FollowThrough.Repo.get_by(FollowThrough.User, slack_id: slack_user_id) do
      %FollowThrough.User{} = user ->
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
