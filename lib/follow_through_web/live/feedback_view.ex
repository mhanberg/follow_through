defmodule FollowThroughWeb.Live.FeedbackView do
  import PhoenixInlineSvg.Helpers
  alias FollowThroughWeb.Endpoint, as: E
  use Phoenix.LiveView
  alias FollowThrough.Feedback

  @impl true
  def mount(%{current_user: current_user}, socket) do
    feedback = %Feedback{} |> Feedback.changeset()

    {:ok,
     assign(socket,
       current_user: current_user,
       feedback: feedback,
       hidden: "hidden",
       message: message(),
       icon: question_icon()
     )}
  end

  @impl true
  def render(assigns) do
    FollowThroughWeb.FeedbackView.render("new.html", assigns)
  end

  @impl true
  def handle_event("toggle-window", _, socket) do
    {:noreply, assign(socket, toggle_window(socket.assigns.hidden))}
  end

  @impl true
  def handle_event("validate", %{"feedback" => params}, socket) do
    changeset =
      %Feedback{}
      |> Feedback.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, feedback: changeset)}
  end

  @impl true
  def handle_event("save", %{"feedback" => params}, socket) do
    %Feedback{}
    |> Feedback.changeset(
      params
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> Map.put("user_name", socket.assigns.current_user.name)
    )
    |> Feedback.create()
    |> case do
      :ok ->
        {:noreply,
         assign(socket,
           feedback: %Feedback{} |> Feedback.changeset(),
           message: message("Thanks for the feedback!", "green-500")
         )}

      {:github_error, changeset} ->
        {:noreply,
         assign(socket, feedback: changeset, message: message("Something went wrong", "red"))}

      {:error, changeset} ->
        {:noreply, assign(socket, feedback: changeset, message: message())}
    end
  end

  defp message(), do: %{message: nil, status: nil}

  defp message(message, status) do
    %{message: message, status: status}
  end

  defp toggle_window(nil) do
    [hidden: "hidden", icon: question_icon()]
  end

  defp toggle_window("hidden") do
    [hidden: nil, icon: close_icon()]
  end

  defp close_icon(),
    do: svg_image(E, "close", class: "h-10 w-10 fill-blue-500")

  defp question_icon(),
    do: svg_image(E, "question", class: "h-12 w-12 bg-white rounded-full fill-blue-500")
end
