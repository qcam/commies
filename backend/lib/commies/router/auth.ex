defmodule Commies.Router.Auth do
  use Plug.Router

  alias Commies.{
    Auth,
    Repo,
    RouteHelper,
    User
  }

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  @frontend_endpoint :commies
                     |> Application.fetch_env!(:frontend)
                     |> Keyword.fetch!(:endpoint)

  get "/login/github" do
    callback_url = RouteHelper.append_base("/oauth/auth/github")

    location = Auth.Github.oauth_url("user:email", callback_url, generate_state(32))

    conn
    |> put_resp_header("location", location)
    |> send_resp(302, [])
  end

  get "/auth/github" do
    with {:ok, code} <- Map.fetch(conn.query_params, "code"),
         {:ok, state} <- Map.fetch(conn.query_params, "state"),
         :ok <- verify_state(state),
         {:ok, provider_access_token} <- Auth.Github.exchange_access_token(code),
         {:ok, user} <- Auth.Github.get_user(provider_access_token),
         {:ok, email} <- Auth.Github.get_user_email(provider_access_token),
         params = %{
           name: user.name,
           email: email,
           auth_provider: "github",
           auth_user_id: user.id
         },
         {:ok, user} <- upsert_user(params) do
      access_token = Auth.Token.generate("github", provider_access_token)

      body = """
      <html><head></head><body><script>
      var payload = "#{access_token}";
      window.opener.postMessage({
        type: "AUTH_SUCCESS",
        payload: {
          token: payload,
          user: #{render_user(user)}
        }
      }, "#{@frontend_endpoint}");
      </script></body></html>
      """

      conn
      |> put_resp_header("content-type", "text/html")
      |> send_resp(200, body)
    else
      _other ->
        body = """
        <html><head></head><body><script>
        window.opener.postMessage({
          type: "AUTH_FAILURE",
          payload: {errors: ["unable to authenticate user"]}
        }, "#{@frontend_endpoint}");
        </script></body></html>
        """

        conn
        |> put_resp_header("content-type", "text/html")
        |> send_resp(200, body)
    end
  end

  defp generate_state(length) do
    random_bytes =
      length
      |> :crypto.strong_rand_bytes()
      |> Base.encode64()

    signature =
      random_bytes
      |> Auth.Token.sign()
      |> Base.encode64()

    random_bytes <> "." <> signature
  end

  defp verify_state(state) do
    with [encoded_bytes, encoded_signature] <- String.split(state, ".", parts: 2),
         {:ok, signature} <- Base.decode64(encoded_signature),
         ^signature <- Auth.Token.sign(encoded_bytes) do
      :ok
    else
      _other -> :error
    end
  end

  defp upsert_user(params) do
    changeset = User.upsert_changeset(params)

    insert_options = [
      returning: [:id],
      on_conflict: :replace_all,
      conflict_target: [:auth_provider, :auth_user_id]
    ]

    Repo.insert(changeset, insert_options)
  end

  defp render_user(%User{} = user) do
    Jason.encode!(%{
      name: user.name,
      auth_provider: user.auth_provider,
      avatar_url: "https://avatars1.githubusercontent.com/u/#{user.auth_user_id}?v=4"
    })
  end
end
