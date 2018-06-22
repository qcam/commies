defmodule Commies.Router do
  use Plug.Router

  alias Commies.{
    Auth,
    Repo,
    RouteHelper,
    User
  }

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(Plug.Logger)
  plug(Commies.Plug.Auth)
  plug(:match)
  plug(:dispatch)

  get "/probe" do
    send_resp(conn, 200, [])
  end

  forward("/links/:link_id/comments", to: Commies.Router.Comment)

  get "/login/github" do
    callback_url = RouteHelper.append_base("/auth/github")
    redirect_url = Auth.Github.oauth_url("user:email", callback_url)

    conn
    |> put_resp_header("location", redirect_url)
    |> send_resp(302, [])
  end

  get "/auth/github" do
    code = Map.fetch!(conn.query_params, "code")

    with {:ok, provider_access_token} <- Auth.Github.exchange_access_token(code),
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

          send_json_resp(conn, 200, body)

        {:error, changeset} ->
          body = %{
            errors: format_changeset_errors(changeset)
          }

          send_json_resp(conn, 400, body)
      end
    else
      _ ->
        body = %{
          errors: ["unable to authenticate user"]
        }

        send_json_resp(conn, 400, body)
    end
  end

  match _ do
    send_json_resp(conn, 404, %{errors: ["not found"]})
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

  def send_json_resp(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  def format_changeset_errors(changeset) do
    Enum.map(changeset.errors, fn {field_name, {error, _}} ->
      "#{field_name} #{error}"
    end)
  end
end
