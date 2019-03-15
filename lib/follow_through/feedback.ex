defmodule FollowThrough.Feedback do
  use FollowThrough, :schema
  @http Application.get_env(:follow_through, :http, FollowThrough.HttpImpl)
  require Logger

  @feedback_repo Application.get_env(
                   :follow_through,
                   :feedback_repo,
                   "https://api.github.com/repos/mhanberg/feedback_test/issues"
                 )
  embedded_schema do
    field :title, :string
    field :message, :string
    field :user_id, :id
    field :user_name, :string
  end

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
  def changeset(feedback, attrs \\ %{}) do
    feedback
    |> cast(attrs, [:title, :message, :user_id, :user_name])
    |> validate_required([:title, :message, :user_id, :user_name])
  end

  @spec create(Ecto.Changeset.t()) ::
          :ok | {:github_error, Ecto.Changeset.t()} | {:error, Ecto.Changeset.t()}
  def create(feedback) do
    feedback
    |> apply_action(:insert)
    |> post_feedback()
  end

  defp post_feedback({:ok, feedback}) do
    body =
      Jason.encode!(%{
        title: "#{feedback.user_name} (#{feedback.user_id}) #{feedback.title}",
        body: feedback.message,
        label: ["feedback"]
      })

    @feedback_repo
    |> @http.post(body, [{"Authorization", "token #{System.get_env("GITHUB_TOKEN")}"}])
    |> handle_resp(feedback)
  end

  defp post_feedback({:error, feedback}), do: {:error, feedback}

  defp handle_resp({:ok, %HTTPoison.Response{status_code: 201}}, _feedback), do: :ok
  defp handle_resp({:ok, _}, feedback), do: {:github_error, feedback |> changeset()}
end
