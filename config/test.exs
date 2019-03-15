use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :follow_through, FollowThroughWeb.Endpoint,
  http: [port: 4002],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :follow_through, FollowThrough.Repo,
  username: "postgres",
  password: "postgres",
  database: "follow_through_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :follow_through, :sql_sandbox, true

config :wallaby,
  driver: Wallaby.Experimental.Chrome,
  chrome: [headless: true]

config :follow_through, :test, true
config :follow_through, :digest_supervisor, nil
config :follow_through, :http, FollowThrough.HttpMock
