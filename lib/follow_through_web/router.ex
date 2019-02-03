defmodule FollowThroughWeb.Router do
  use FollowThroughWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authenticate do
    plug Ueberauth
  end

  pipeline :authorize do
    plug :logged_in?
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

    resources "/obligations", ObligationController
  end

  scope "/", FollowThroughWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  defp logged_in?(conn, _) do
    case FollowThroughWeb.View.Helpers.current_user(conn) do
      nil ->
        conn
        |> Phoenix.Controller.put_flash(:info, "You must be logged in to continue")
        |> Phoenix.Controller.redirect(to: "/login")
        |> halt()

      _ ->
        conn
    end
  end
end
