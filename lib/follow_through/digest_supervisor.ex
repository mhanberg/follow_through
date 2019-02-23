defmodule FollowThrough.DigestSupervisor do
  @moduledoc false
  use ProcManager

  @impl true
  def on_init(_) do
    FollowThrough.Subscription.all()
    |> Enum.each(&start_digest/1)
  end

  @spec start_child(%FollowThrough.Subscription{}) :: DynamicSupervisor.on_start_child()
  def start_child(sub) do
    ProcManager.start_child(FollowThrough.Digest, sub)
  end

  defp start_digest(sub) do
    Task.start_link(fn -> start_child(sub) end)
  end
end
