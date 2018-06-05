defmodule Commies.Router do
  use Plug.Router

  alias Commies.{
    Repo,
    Comment
  }

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/probe" do
    send_resp(conn, 200, [])
  end

  get "/links/:link_id/comments" do
    body = %{
      comments: []
    }

    send_json_resp(conn, 200, body)
  end

  post "/links/:link_id/comments" do
    changeset =
      conn.body_params
      |> Map.put("link_id", link_id)
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
