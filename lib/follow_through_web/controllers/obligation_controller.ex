defmodule FollowThroughWeb.ObligationController do
  use FollowThroughWeb, :controller
  alias FollowThrough.Obligation

  def new(conn, %{"team_id" => team_id}) do
    render(conn, :new, obligation: Obligation.new(), team_id: team_id)
  end

  def create(conn, %{"team_id" => team_id, "obligation" => params}) do
    case params
         |> Map.put("user_id", FollowThroughWeb.View.Helpers.current_user(conn).id)
         |> Map.put("team_id", team_id)
         |> Obligation.create() do
      {:ok, _obligation} ->
        conn
        |> put_flash(:info, "Successfully created a follow through!")
        |> redirect(to: "/")

      {:error, changeset} ->
        conn
        |> render(:new, obligation: changeset)
    end
  end
end
