defmodule FollowThrough.MixProject do
  use Mix.Project

  def project do
    [
      app: :follow_through,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_add_deps: :transitive]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {FollowThrough.Application, []},
      extra_applications: [:logger, :runtime_tools, :sentry]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bamboo, "~> 1.2"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:ecto_sql, "~> 3.0"},
      {:ex_machina, "~> 2.3", only: :test},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 1.5", override: true},
      {:jason, "~> 1.0"},
      {:mox, "~> 0.5", only: :test},
      {:phoenix, "~> 1.4.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_inline_svg, git: "https://github.com/nikkomiu/phoenix_inline_svg.git"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:sentry, "~> 7.0"},
      {:slack, "~> 0.14.0"},
      {:timex, "~> 3.1"},
      {:ueberauth_github, git: "https://github.com/ueberauth/ueberauth_github.git"},
      {:ueberauth_google, "~> 0.8"},
      {:wallaby, "~> 0.22.0", [runtime: false, only: :test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "assets.compile": &compile_assets/1
    ]
  end

  defp compile_assets(_) do
    Mix.shell().cmd("(cd assets && ./node_modules/webpack/bin/webpack.js --mode development)",
      quiet: true
    )
  end
end
