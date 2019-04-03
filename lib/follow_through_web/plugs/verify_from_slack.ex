defmodule FollowThroughWeb.VerifyFromSlack do
  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(options), do: options

  @impl true
  def call(conn, _) do
    signing_salt = System.get_env("SLACK_SIGNING_SECRET")
    [request_body] = conn.assigns[:raw_body]

    timestamp =
      conn
      |> get_req_header("x-slack-request-timestamp")
      |> List.first()
      |> String.to_integer()

    now =
      DateTime.utc_now()
      |> DateTime.to_unix()

    sig_base_string = "v0:#{timestamp}:#{request_body}"
    [slack_signature] = conn |> get_req_header("x-slack-signature")

    hash =
      "v0=#{:crypto.hmac(:sha256, signing_salt, sig_base_string) |> Base.encode16(case: :lower)}"

    with true <-
           now
           |> Kernel.-(timestamp)
           |> Kernel.abs()
           |> Kernel.<(60 * 5),
         true <- slack_signature == hash do
      conn
    else
      false ->
        conn
        |> Phoenix.Controller.put_view(FollowThroughWeb.ErrorView)
        |> Phoenix.Controller.render("403.json")
    end
  end
end
