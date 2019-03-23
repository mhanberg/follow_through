use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :follow_through, FollowThroughWeb.Endpoint,
  http: [port: 4000],
  url: [scheme: "https", host: "003bc72d.ngrok.io", port: 443],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# Watch static and templates for browser reloading.
config :follow_through, FollowThroughWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/follow_through_web/views/.*(ex)$},
      ~r{lib/follow_through_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Configure your database
config :follow_through, FollowThrough.Repo,
  username: "postgres",
  password: "postgres",
  database: "follow_through_dev",
  hostname: "localhost",
  pool_size: 10

config :follow_through, FollowThrough.Mailer, adapter: Bamboo.LocalAdapter

config :follow_through, :google_feature, true
