defmodule Commies.Router.Comment do
  use Plug.Router

  import Ecto.Query

  alias Commies.{
    Comment,
    Repo,
    Router
  }

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  @frontend_endpoint (
    :commies
    |> Application.fetch_env!(:frontend)
    |> Keyword.fetch!(:endpoint)
  )

  get "/" do
    link_id = conn.params["link_id"]

    comments =
      Comment
      |> where(link_id: ^link_id)
      |> order_by(:inserted_at)
      |> preload(:user)
      |> Repo.all()

    body = %{
      comments: render_list(comments)
    }

    conn
    |> put_resp_header("access-control-allow-origin", @frontend_endpoint)
    |> Router.send_json_resp(200, body)
  end

  defp render_list(comments) do
    Enum.map(comments, fn comment ->
      %{
        id: comment.id,
        content: comment.content,
        inserted_at: comment.inserted_at,
        user: render_user(comment.user)
      }
    end)
  end

  defp render_user(user) do
    %{
      name: user.name
    }
  end

  post "/" do
    if user = conn.assigns[:authenticated_user] do
      link_id = conn.params["link_id"]

      changeset =
        conn.body_params
        |> Map.put("link_id", link_id)
        |> Map.put("user_id", user.id)
        |> Comment.create_changeset()

      case Repo.insert(changeset) do
        {:ok, comment} ->
          Router.send_json_resp(conn, 200, comment)

        {:error, changeset} ->
          body = %{
            errors: Router.format_changeset_errors(changeset)
          }

          Router.send_json_resp(conn, 400, body)
      end
    else
      Router.send_json_resp(conn, 401, [])
    end
  end

  put "/:comment_id" do
    if user = conn.assigns[:authenticated_user] do
      comment =
        Comment
        |> where(id: ^comment_id)
        |> where(user_id: ^user.id)
        |> Repo.one()

      if comment do
        changeset = Comment.update_changeset(comment, conn.body_params)

        case Repo.update(changeset) do
          {:ok, comment} ->
            Router.send_json_resp(conn, 200, comment)

          {:error, changeset} ->
            body = %{
              errors: Router.format_changeset_errors(changeset)
            }

            Router.send_json_resp(conn, 400, body)
        end
      else
        Router.send_json_resp(conn, 404, %{errors: ["not found"]})
      end
    else
      Router.send_json_resp(conn, 401, [])
    end
  end

  delete "/:comment_id" do
    if user = conn.assigns[:authenticated_user] do
      delete_result =
        Comment
        |> where(id: ^comment_id)
        |> where(user_id: ^user.id)
        |> Repo.delete_all()

      case delete_result do
        {1, nil} ->
          send_resp(conn, 204, [])

        {0, _} ->
          Router.send_json_resp(conn, 404, %{errors: ["not found"]})
      end
    else
      Router.send_json_resp(conn, 401, [])
    end
  end
end
