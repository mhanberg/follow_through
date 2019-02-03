defmodule FollowThroughWeb.ObligationController do
  use FollowThroughWeb, :controller
  alias FollowThrough.Obligation

  def new(conn, _params) do
    render(conn, :new, obligation: Obligation.new())
  end

  def create(conn, %{"obligation" => params}) do
    case params
         |> Map.put("user_id", FollowThroughWeb.View.Helpers.current_user(conn).id)
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
