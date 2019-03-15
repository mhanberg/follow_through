defmodule FollowThroughWeb.ErrorView do
  use FollowThroughWeb, :view

  @spec render(String.t(), map()) :: String.t()
  def render("403.json", _assigns) do
    "Unauthorized"
  end

  # credo:disable-for-next-line Credo.Check.Readability.Specs
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
