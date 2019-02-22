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
    schedule()

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
              ])
          }
        )
    end

    schedule()

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

  defp schedule do
    delivery_time =
      Timex.now()
      |> case do
        %DateTime{hour: hour} = now when hour < 15 ->
          struct(now, hour: 15, minute: 0, second: 0)

        now ->
          now
          |> Timex.add(Timex.Duration.from_days(1))
          |> struct(hour: 15, minute: 0, second: 0)
      end
      |> Timex.diff(Timex.now(), :milliseconds)


    Process.send_after(self(), :deliver, delivery_time)
  end
end
