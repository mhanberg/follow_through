defmodule FollowThroughWeb.PageView do
  use FollowThroughWeb, :view
  require Ecto.Query

  def obligations(conn) do
    conn
    |> current_user
    |> Map.fetch!(:id)
    |> FollowThrough.Obligation.for_user()
  end

  def teams(conn) do
    conn
    |> current_user
    |> FollowThrough.Repo.preload(
      teams: [
        users: [
          obligations: Ecto.Query.from(o in FollowThrough.Obligation, where: o.completed == false)
        ]
      ]
    )
    |> Map.fetch!(:teams)
  end

  def has_obligations?(user, team_id) do
    user.obligations
    |> FollowThrough.Obligation.for_team(team_id)
    |> Enum.empty?()
    |> Kernel.!()
  end

  def delete_obligation_link(conn, team, obligation) do
    if current_user(conn).id == obligation.user_id do
      link(
        svg_image(conn, "trash", class: "h-4 w-4"),
        to: Routes.team_obligation_path(conn, :delete, team.id, obligation.id),
        method: :delete,
        title: "Delete this obligation",
        class: "trash",
        data: [confirm: "Are you sure you want to delete this obligation?"]
      )
    end
  end
end
