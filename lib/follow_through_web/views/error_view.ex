defmodule FollowThroughWeb.ErrorView do
  use FollowThroughWeb, :view

  def render("403.json", _assigns) do
    "Unauthorized"
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
