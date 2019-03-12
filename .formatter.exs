[
  import_deps: [:ecto, :phoenix],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"],
  locals_without_parens: [
    # Kernel
    inspect: 1,
    inspect: 2,

    # Phoenix
    plug: :*,
    action_fallback: 1,
    render: 2,
    render: 3,
    render: 4,
    redirect: 2,
    socket: :*,
    get: :*,
    post: :*,
    resources: :*,
    pipe_through: :*,
    delete: :*,
    forward: :*,
    channel: :*,
    transport: :*,

    # Ecto Schema
    field: 2,
    field: 3,
    belongs_to: 2,
    belongs_to: 3,
    has_one: 2,
    has_one: 3,
    has_many: 2,
    has_many: 3,
    embeds_one: 2,
    embeds_one: 3,
    embeds_many: 2,
    embeds_many: 3,
    many_to_many: 2,
    many_to_many: 3,

    # Ecto Query
    from: 2,

    # Ecto Migrations
    execute: 1,
    add: :*,
    remove: :*,
    create: :*,
    drop: :*,
    modify: :*
  ]
]
