defmodule Commies.Router do
  use Plug.Router

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

  forward("/oauth", to: Commies.Router.Auth)

  match _ do
    send_json_resp(conn, 404, %{errors: ["not found"]})
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
