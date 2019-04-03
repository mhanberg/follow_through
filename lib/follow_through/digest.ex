defmodule FollowThrough.Digest do
  require Logger
  alias FollowThrough.Obligation
  @moduledoc false
  use GenServer

  @slack Application.get_env(:follow_through, :slack, FollowThrough.SlackClientImpl)
  @time Application.get_env(:follow_through, :time, FollowThrough.TimeImpl)

  @spec start_link(integer()) :: GenServer.on_start()
  def start_link(subscription_id) do
    GenServer.start_link(__MODULE__, subscription_id,
      name: {:via, Registry, {ProcManager.Registry, subscription_id}}
    )
  end

  @impl true
  def init(subscription_id) do
    case FollowThrough.Repo.get(FollowThrough.Subscription, subscription_id) do
      nil ->
        :ignore

      subscription ->
        schedule(subscription.timezone)

        {:ok, subscription}
    end
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

    if subscription.timezone == nil do
      %{"ok" => true} =
        @slack.post_message(
          subscription.channel_id,
          "Digest Maintenance needed for #{subscription.team.name}",
          %{
            attachments:
              Jason.encode!([
                %{
                  color: "danger",
                  text:
                    "We're having trouble figuring out when to send your daily digest for #{
                      subscription.team.name
                    }, please try unsubscribing and resubscribe."
                }
              ]),
            token: FollowThrough.SlackToken.get_by_team(subscription.service_team_id).token
          }
        )
    else
      day_of_week = Timex.now() |> @time.weekday()

      unless has_incomplete_tasks?(subscription) || weekend?(day_of_week) do
        %{"ok" => true} =
          @slack.post_message(
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
    end

    schedule(subscription.timezone)

    {:noreply, subscription}
  end

  defp has_incomplete_tasks?(sub),
    do: sub.team.obligations |> Enum.reject(& &1.completed) |> Enum.empty?()

  defp weekend?(day), do: day == 6 || day == 7

  @spec text([%Obligation{}]) :: String.t()
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

  defp schedule(timezone) do
    delivery_time_offset =
      Timex.now()
      |> convert_timezone(timezone)
      |> next_available_day()
      |> Timex.set(time: ~T[10:00:00])
      |> Timex.diff(Timex.now(), :milliseconds)

    Process.send_after(self(), :deliver, delivery_time_offset)
  end

  @spec convert_timezone(DateTime.t(), nil | Timex.Types.time_zone()) :: DateTime.t()
  def convert_timezone(datetime, nil) do
    Timex.Timezone.convert(datetime, "Etc/UTC")
  end

  def convert_timezone(datetime, timezone) do
    Timex.Timezone.convert(datetime, timezone)
  end

  defp next_available_day(%DateTime{hour: hour} = time) when hour < 10 do
    time
  end

  defp next_available_day(time) do
    Timex.add(time, Timex.Duration.from_days(1))
  end
end
