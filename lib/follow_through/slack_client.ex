defmodule FollowThrough.SlackClient do
  @callback post_message(channel_id :: String.t(), message :: String.t(), options :: map()) ::
              map()
  @callback info(user_id :: String.t(), options :: map()) :: map()
end
