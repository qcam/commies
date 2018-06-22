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
    redirect_url = Auth.Github.oauth_url("user:email", callback_url)

    conn
    |> put_resp_header("location", redirect_url)
    |> send_resp(302, [])
  end

  get "/auth/github" do
    with {:ok, code} <- Map.fetch(conn.query_params, "code"),
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
        {:ok, user} ->
          access_token = Auth.Token.generate("github", provider_access_token)

          body = %{
            access_token: access_token,
            user: user
          }

          Router.send_json_resp(conn, 200, body)

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
