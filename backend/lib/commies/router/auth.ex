defmodule Commies.Router.Auth do
  use Plug.Router

  alias Commies.{
    Auth,
    Repo,
    RouteHelper,
    Router,
    User
  }

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/login/github" do
    callback_url = RouteHelper.append_base("/oauth/auth/github")

    with {:ok, redirect_url} <- Map.fetch(conn.query_params, "r") do
      encoded_redirect_url = Base.encode64(redirect_url)
      signature =
        encoded_redirect_url
        |> Auth.Token.sign()
        |> Base.encode64()
      state = "#{encoded_redirect_url}.#{signature}"

      location = Auth.Github.oauth_url("user:email", callback_url, state)
      conn
      |> put_resp_header("location", location)
      |> send_resp(302, [])
    else
      :error ->
        Router.send_json_resp(conn, 400, %{errors: ["bad params"]})
    end
  end

  get "/auth/github" do
    with {:ok, code} <- Map.fetch(conn.query_params, "code"),
         {:ok, state} <- Map.fetch(conn.query_params, "state"),
         {:ok, redirect_url} <- decode_state(state),
         redirect_uri = URI.parse(redirect_url),
         {:ok, provider_access_token} <- Auth.Github.exchange_access_token(code),
         {:ok, user} <- Auth.Github.get_user(provider_access_token),
         {:ok, email} <- Auth.Github.get_user_email(provider_access_token) do
      params = %{
        name: user.name,
        email: email,
        auth_provider: "github",
        auth_user_id: user.id
      }

      case upsert_user(params) do
        {:ok, _user} ->
          access_token = Auth.Token.generate("github", provider_access_token)

          uri =
            redirect_uri
            |> build_redirect_uri(access_token)
            |> URI.to_string()

          conn
          |> put_resp_header("location", uri)
          |> send_resp(302, [])

        {:error, changeset} ->
          body = %{
            errors: Router.format_changeset_errors(changeset)
          }

          Router.send_json_resp(conn, 400, body)
      end
    else
      _ ->
        body = %{
          errors: ["unable to authenticate user"]
        }

        Router.send_json_resp(conn, 400, body)
    end
  end

  defp decode_state(state) do
    with [encoded_url, encoded_signature] <- String.split(state, ".", parts: 2),
         {:ok, signature} <- Base.decode64(encoded_signature),
         ^signature <- Auth.Token.sign(encoded_url) do
      Base.decode64(encoded_url)
    else
      _other -> :error
    end
  end

  defp build_redirect_uri(%URI{} = uri, token) do
    query = if uri.query, do: URI.decode_query(uri.query), else: %{}

    query = Map.put(query, :token, token)

    %{uri | query: URI.encode_query(query)}
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
end
