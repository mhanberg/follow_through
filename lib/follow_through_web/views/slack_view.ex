defmodule FollowThroughWeb.SlackView do
  use FollowThroughWeb, :view

  def render("list.json", %{channel_id: channel_id, teams: teams}) do
    %{
      "channel" => channel_id,
      "attachments" => [
        %{
          "color" => "#026AA7",
          "fallback" => teams |> Enum.map(&"• #{&1.name}") |> Enum.join("\n"),
          "title" => "Your teams",
          "text" => teams |> Enum.map(& &1.name) |> Enum.join("\n")
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
            "Finish connecting your Follow Through account at http://localhost:4000/auth/slack/connect",
          "actions" => [
            %{
              "type" => "button",
              "text" => "Connect Follow Through account",
              "url" => "http://localhost:4000/auth/slack/connect?user_id=#{user_id}",
              "style" => "primary"
            }
          ]
        }
      ]
    }
  end

  def render("error.json", %{channel_id: channel_id}) do
    %{
      "channel" => channel_id,
      "attachments" => [
        %{
          "color" => "danger",
          "text" => "Could not understand command"
        }
      ]
    }
  end
end
