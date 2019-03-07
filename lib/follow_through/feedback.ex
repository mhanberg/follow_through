defmodule FollowThrough.Feedback do
  use FollowThrough, :schema
  require Logger

  embedded_schema do
    field :title, :string
    field :message, :string
    field :user_id, :id
    field :user_name, :string
  end

  def changeset(feedback, attrs \\ %{}) do
    feedback
    |> cast(attrs, [:title, :message, :user_id, :user_name])
    |> validate_required([:title, :message, :user_id, :user_name])
  end

  def create!(feedback) do
    if feedback.valid? do
      {:ok, %{status_code: 201}} =
        HTTPoison.post(
          "https://api.github.com/repos/mhanberg/follow_through/issues",
          Jason.encode!(%{
            title: "#{feedback.changes.user_name} (#{feedback.changes.user_id}) #{feedback.changes.title}",
            body: feedback.changes.message,
            label: ["feedback"]
          }),
          [{"Authorization", "token #{System.get_env("GITHUB_TOKEN")}"}]
        )
    else
      Logger.error inspect feedback
      raise "Feedback not valid"
    end
  end
end
