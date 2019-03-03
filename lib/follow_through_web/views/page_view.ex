defmodule FollowThroughWeb.PageView do
  use FollowThroughWeb, :view

  def sign_in_button(conn, button_classes \\ "btn-primary bg-white hover:bg-white text-blue-700 hover:text-blue-700 inline-flex items-center normal-case") do

    link to: "/auth/github", class: button_classes do
      [ svg_image(conn, "octocat", class: "h-6 w-6 mr-4"), "Sign in with GitHub" ]
    end
  end
end
