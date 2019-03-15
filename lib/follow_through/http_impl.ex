defmodule FollowThrough.HttpImpl do
  @behaviour FollowThrough.Http

  @impl true
  def post(url, body, headers \\ [], options \\ []) do
    HTTPoison.post(url, body, headers, options)
  end
end
