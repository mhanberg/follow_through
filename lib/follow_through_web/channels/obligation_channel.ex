defmodule FollowThroughWeb.ObligationChannel do
  use FollowThroughWeb, :channel
  alias FollowThrough.Obligation

  def join(
        "obligation:" <> obligation_id,
        _params,
        %Phoenix.Socket{assigns: %{user_id: user_id}} = socket
      ) do
    if FollowThrough.Obligation.belongs_to_user?(obligation_id, user_id) do
      {:ok, socket}
    else
      {:error, "The user is not authorized to connect to this channel"}
    end
  end

  def handle_in("check:obligation:" <> obligation_id, %{"checked" => checked}, socket) do
    {:safe, svg_string} =
      if checked do
        Obligation.mark_completed!(obligation_id)

        svg_image(FollowThroughWeb.Endpoint, "filled-checkbox",
          class: "h-4 w-4 stroke-current fill-current text-blue-400"
        )
      else
        Obligation.mark_incomplete!(obligation_id)

        svg_image(FollowThroughWeb.Endpoint, "checkbox",
          class: "h-4 w-4 stroke-current fill-current text-blue-400"
        )
      end

    broadcast!(socket, "check_event", %{image: svg_string})

    {:noreply, socket}
  end
end
