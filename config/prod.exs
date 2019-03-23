use Mix.Config

config :follow_through, FollowThroughWeb.Endpoint,
  http: [port: System.get_env("PORT")],
  url: [scheme: "https", host: "www.followthrough.app", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Do not print debug messages in production
config :logger, level: :info

config :follow_through, FollowThrough.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :follow_through, FollowThrough.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: System.get_env("MAILGUN_API_KEY"),
  domain: "mail.followthrough.app"

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: :prod,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: "production"
  },
  included_environments: [:prod]

config :follow_through,
       :feedback_repo,
       "https://api.github.com/repos/mhanberg/follow_through/issues"

config :follow_through,
       :analytics,
       true
