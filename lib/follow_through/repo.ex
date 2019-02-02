defmodule FollowThrough.Repo do
  use Ecto.Repo,
    otp_app: :follow_through,
    adapter: Ecto.Adapters.Postgres
end
