defmodule FollowThroughWeb.ObligationController do
  use FollowThroughWeb, :controller
  alias FollowThrough.Obligation

  def new(conn, %{"team_id" => team_id}) do
    render(conn, :new, obligation: Obligation.new(), team_id: team_id)
  end

  def create(conn, %{"team_id" => team_id, "obligation" => params}) do
    case params
         |> Map.put("user_id", current_user(conn).id)
         |> Map.put("team_id", team_id)
         |> Obligation.create() do
      {:ok, _obligation} ->
        conn
        |> put_flash(:info, "Successfully created a follow through!")
        |> redirect(to: "/")

      {:error, changeset} ->
        conn
        |> render(:new, obligation: changeset, team_id: team_id)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Obligation{} = obligation <- Obligation.get(id),
         true <- obligation.user_id == current_user(conn),
         {:ok, %Obligation{}} <- Obligation.delete(obligation) do
      conn
      |> put_flash(:info, "Successfully deleted an obligation")
    else
      false ->
        conn
        |> put_flash(:error, "You are not authorized to perform that action")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "It looks like something went wrong")

      nil ->
        conn
        |> put_flash(:error, "It looks like that obligation doesn't exist")
    end
    |> redirect(to: "/")
  end
end
