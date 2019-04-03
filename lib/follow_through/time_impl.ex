defmodule FollowThrough.TimeImpl do
  @behaviour FollowThrough.Time

  @impl true
  def weekday(datetime), do: Timex.weekday(datetime)
end
