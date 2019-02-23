defmodule FollowThroughWeb.SlackView do
  use FollowThroughWeb, :view

  def render("list.json", %{channel_id: channel_id, teams: teams}) do
    %{
      "channel" => channel_id,
      "attachments" => [
        %{
          "color" => "#026AA7",
          "title" => "Your teams",
          "text" => teams |> Enum.map(& &1.name) |> Enum.join("\n")
        }
      ]
    }
  end

  def render("subscription.json", %{channel_id: channel_id, team: team}) do
    %{
      "channel" => channel_id,
      "attachments" => [
        %{
          "color" => "good",
          "title" => "Success!",
          "text" => "You've successfully subscribed to updates from #{team.name}."
        }
      ]
    }
  end

  def render("unsubscribe.json", %{channel_id: channel_id, team: team}) do
    %{
      "channel" => channel_id,
      "attachments" => [
        %{
          "color" => "good",
          "title" => "Success!",
          "text" => "You've successfully unsubscribed to updates from #{team.name}."
        }
      ]
    }
  end

  def render("login.json", %{channel_id: channel_id, user_id: user_id}) do
    %{
      "text" => "Finish connecting your Follow Through account",
      "channel" => channel_id,
      "attachments" => [
        %{
          "color" => "#026AA7",
          "fallback" =>
            "Finish connecting your Follow Through account at #{Routes.slack_auth_url(FollowThroughWeb.Endpoint, :new, user_id: user_id)}",
          "actions" => [
            %{
              "type" => "button",
              "text" => "Connect Follow Through account",
              "url" => Routes.slack_auth_url(FollowThroughWeb.Endpoint, :new, user_id: user_id),
              "style" => "primary"
            }
          ]
        }
      ]
    }
  end

  def render("error.json", %{channel_id: channel_id, error: error}) do
    %{
      "channel" => channel_id,
      "attachments" => [
        %{
          "color" => "danger",
          "text" => error
        }
      ]
    }
  end

  def render("error.json", assigns) do
    render("error.json", Map.put(assigns, :error, "Unidentified command."))
  end
end
