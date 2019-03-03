defmodule FollowThrough.Repo.Migrations.CreateSlackTokens do
  use Ecto.Migration

  def change do
    create table(:slack_tokens) do
      add :token, :string
      add :workspace_id, :string

      timestamps()
    end

    create unique_index :slack_tokens, [:workspace_id]
    create unique_index :slack_tokens, [:token]
  end
end
