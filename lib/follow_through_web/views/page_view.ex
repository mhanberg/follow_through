defmodule FollowThroughWeb.PageView do
  use FollowThroughWeb, :view

  @spec sign_in_button(%Plug.Conn{}, atom(), keyword()) :: {:safe, iodata()}
  def sign_in_button(
        conn,
        provider,
        opts \\ []
      ) do
    classes =
      opts[:class] ||
        "btn-primary bg-white hover:bg-white text-blue-700 hover:text-blue-700 inline-flex items-center normal-case"

    path = opts[:path] || "/"

    do_sign_in_button(conn, provider, classes, path)
  end

  defp do_sign_in_button(conn, :github, button_classes, path) do
    link to: Routes.auth_path(conn, :request, "github", state: path), class: button_classes do
      [svg_image(conn, "octocat", class: "h-6 w-6 mr-4"), "Sign in with GitHub"]
    end
  end

  defp do_sign_in_button(conn, :google, button_classes, path) do
    link to: Routes.auth_path(conn, :request, "google", state: path), class: button_classes do
      [svg_image(conn, "google", class: "h-6 w-6 mr-4"), "Sign in with Google"]
    end
  end

  @spec login_link_white(%Plug.Conn{}) :: {:safe, iodata()}
  def login_link_white(conn) do
    link(
      "Sign in today!",
      to: Routes.page_path(conn, :login),
      class:
        "text-lg btn-primary bg-white hover:bg-white text-blue-700 hover:text-blue-700 inline-flex items-center normal-case"
    )
  end

  @spec login_link_dark(%Plug.Conn{}) :: {:safe, iodata()}
  def login_link_dark(conn) do
    link(
      "Sign in today!",
      to: Routes.page_path(conn, :login),
      class:
        "text-lg btn-primary text-white hover:text-white inline-flex items-center normal-case"
    )
  end
end
