defmodule FollowThroughWeb.UserSocket do
  use Phoenix.Socket
  alias FollowThrough.User

  channel "obligation:*", FollowThroughWeb.ObligationChannel
  channel "feedback:*", FollowThroughWeb.FeedbackChannel

  @spec connect(%{required(String.t()) => String.t()}, Phoenix.Socket.t(), map()) ::
          {:ok, Phoenix.Socket.t()} | :error
  def connect(%{"token" => token}, socket, _connect_info) do
    with {:ok, verified_user_id} <-
           Phoenix.Token.verify(FollowThroughWeb.Endpoint, "user salt", token, max_age: 86400),
         %User{} = user <- User.get(verified_user_id) do
      {:ok, assign(socket, :current_user, user)}
    else
      {:error, _} ->
        :error

      nil ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     FollowThroughWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @spec id(Phoenix.Socket.t()) :: nil
  def id(_socket), do: nil
end
