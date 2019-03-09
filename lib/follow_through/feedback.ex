defmodule FollowThrough.Feedback do
  use FollowThrough, :schema
  require Logger

  @feedback_repo Application.get_env(:follow_through, :feedback_repo)

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

  def create(feedback) do
    feedback
    |> apply_action(:insert)
    |> case do
      {:ok, feedback} ->
        HTTPoison.post(
          @feedback_repo,
          Jason.encode!(%{
            title: "#{feedback.user_name} (#{feedback.user_id}) #{feedback.title}",
            body: feedback.message,
            label: ["feedback"]
          }),
          [{"Authorization", "token #{System.get_env("GITHUB_TOKEN")}"}]
        )
        |> case do
          {:ok, %{status_code: 201}} ->
            :ok

          _ ->
            {:github_error, feedback}
        end

      {:error, feedback} ->
        {:error, feedback}
    end
  end
end
