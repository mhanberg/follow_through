# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :follow_through,
  ecto_repos: [FollowThrough.Repo]

# Configures the endpoint
config :follow_through, FollowThroughWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nY3C0GXIKstZHvdbMRw57Pq2abtpD9DA8wZe+zH5krQlxNUANcVLAB7J/5MNlb4C",
  render_errors: [view: FollowThroughWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: FollowThrough.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "MLnI0zkklTWG1I5Vv1I8D7USDzmaoT+E2ZqLSjKqRt32YCrYN27VBkFw8XKw1doN"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix,
  json_library: Jason,
  template_engines: [leex: Phoenix.LiveView.Engine]

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [allow_private_emails: true]}
  ],
  json_library: Jason

config :oauth2, serializers: %{"application/json" => Jason}

config :follow_through, :digest_supervisor, FollowThrough.DigestSupervisor

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
