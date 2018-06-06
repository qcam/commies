defmodule Commies.Router do
  use Plug.Router

  alias Commies.{
    Auth,
    Comment,
    Repo,
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

  get "/links/:link_id/comments" do
    import Ecto.Query

    comments =
      Comment
      |> where(link_id: ^link_id)
      |> Repo.all()

    body = %{
      comments: comments
    }

    send_json_resp(conn, 200, body)
  end

  post "/links/:link_id/comments" do
    if user = conn.assigns[:authenticated_user] do
      changeset =
        conn.body_params
        |> Map.put("link_id", link_id)
        |> Map.put("user_id", user.id)
        |> Comment.create_changeset()

      case Repo.insert(changeset) do
        {:ok, comment} ->
          send_json_resp(conn, 200, comment)

        {:error, changeset} ->
          body = %{
            errors: format_changeset_errors(changeset)
          }

          send_json_resp(conn, 200, body)
      end
    else
      send_json_resp(conn, 401, [])
    end
  end

  get "/login/github" do
    redirect_url = Auth.Github.oauth_url("user:email", "http://localhost:8000/auth/github")

    conn
    |> put_resp_header("location", redirect_url)
    |> send_resp(302, [])
  end

  get "/auth/github" do
    code = Map.fetch!(conn.query_params, "code")

    with {:ok, access_token} <- Auth.Github.exchange_access_token(code),
         {:ok, user} <- Auth.Github.get_user(access_token),
         {:ok, email} <- Auth.Github.get_user_email(access_token) do
      params = %{
        name: user.name,
        email: email,
        auth_provider: "github",
        auth_user_id: user.id
      }

      case upsert_user(params) do
        {:ok, user} ->
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

  defp upsert_user(params) do
    changeset = User.upsert_changeset(params)

    insert_options = [
      returning: [:id],
      on_conflict: :replace_all,
      conflict_target: [:auth_provider, :auth_user_id]
    ]

    Repo.insert(changeset, insert_options)
  end

  defp send_json_resp(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  defp format_changeset_errors(changeset) do
    Enum.map(changeset.errors, fn {field_name, {error, _}} ->
      "#{field_name} #{error}"
    end)
  end
end
