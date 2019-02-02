defmodule FollowThroughWeb.Router do
  use FollowThroughWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug Ueberauth
  end

  scope "/auth", FollowThroughWeb do
    pipe_through [:auth, :browser]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback

    delete "/logout", AuthController, :delete
  end

  scope "/", FollowThroughWeb do
    pipe_through :browser

    get "/", PageController, :index
  end
end
