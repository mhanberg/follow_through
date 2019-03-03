defmodule FollowThroughWeb.SlackEventController do
  use FollowThroughWeb, :controller
  alias FollowThrough.SlackToken
  alias FollowThrough.Subscription
  import Ecto.Query
  plug FollowThroughWeb.VerifyFromSlack

  def callback(conn, %{"challenge" => challenge}) do
    conn
    |> put_status(200)
    |> put_resp_content_type("text/plain")
    |> text(challenge)
  end

  def callback(
        conn,
        %{
          "event" => %{
            "type" => "tokens_revoked"
          },
          "team_id" => workspace_id,
          "type" => "event_callback"
        }
      ) do
    case FollowThrough.Repo.get_by(SlackToken, workspace_id: workspace_id) do
      %SlackToken{} = token ->
        Ecto.Multi.new()
        |> Ecto.Multi.delete(:slack_token, token)
        |> Ecto.Multi.delete_all(
          :subscriptions,
          from(s in Subscription, where: s.service_team_id == ^workspace_id, select: s.id)
        )
        |> Ecto.Multi.run(:stop_digests, fn _, %{subscriptions: {_, deleted_subs}} ->
          value =
            deleted_subs
            |> Enum.map(&terminate_digest/1)

          {:ok, value}
        end)
        |> FollowThrough.Repo.transaction()
    end

    conn
    |> put_status(200)
    |> text("success")
  end

  defp terminate_digest(deleted_sub) do
    FollowThrough.DigestSupervisor.terminate_child(deleted_sub)
  end
end
