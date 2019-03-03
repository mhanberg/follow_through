defmodule FollowThrough.Digest do
  require Logger
  @moduledoc false
  use GenServer

  def start_link(subscription) do
    GenServer.start_link(__MODULE__, subscription,
      name: {:via, Registry, {ProcManager.Registry, subscription.id}}
    )
  end

  @impl true
  def init(subscription) do
    schedule(subscription.delivery_time)

    {:ok, subscription}
  end

  @impl true
  def handle_info(:deliver, subscription) do
    subscription =
      subscription
      |> FollowThrough.Repo.preload(
        [
          team: [
            obligations: :user
          ]
        ],
        force: true
      )

    unless subscription.team.obligations |> Enum.empty?() do
      %{"ok" => true} =
        Slack.Web.Chat.post_message(
          subscription.channel_id,
          "Daily digest for #{subscription.team.name}!",
          %{
            attachments:
              Jason.encode!([
                %{
                  color: "#026AA7",
                  text:
                    subscription.team.obligations
                    |> Enum.reject(& &1.completed)
                    |> text()
                }
              ]),
            token: FollowThrough.SlackToken.get_by_team(subscription.service_team_id).token
          }
        )
    end

    schedule(subscription.delivery_time)

    {:noreply, subscription}
  end

  def text(obligations) do
    obligations
    |> Enum.group_by(&{&1.user_id, &1.user.name})
    |> Enum.map(fn {{_user_id, user_name}, obs} ->
      obs_list =
        obs
        |> Enum.map(fn ob -> "- #{ob.description} (#{Timex.from_now(ob.inserted_at)})" end)

      ["_#{user_name}_" | obs_list]
      |> Enum.join("\n")
    end)
    |> Enum.join("\n\n")
  end

  defp schedule(delivery_time) do
    delivery_time_offset =
      Timex.now()
      |> case do
        %DateTime{hour: hour} = now when hour < 15 ->
          now

        now ->
          now
          |> Timex.add(Timex.Duration.from_days(1))
      end
      |> Timex.set(time: delivery_time)
      |> Timex.diff(Timex.now(), :milliseconds)

    Process.send_after(self(), :deliver, delivery_time_offset)
  end
end
