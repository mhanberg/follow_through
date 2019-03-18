defmodule FollowThrough.SlackClientImpl do
  @behaviour FollowThrough.SlackClient

  alias Slack.Web.Chat
  alias Slack.Web.Users

  @impl true
  def post_message(channel_id, message, options \\ %{}) do
    Chat.post_message(channel_id, message, options)
  end

  @impl true
  def info(user_id, options \\ %{}) do
    Users.info(user_id, options)
  end
end
