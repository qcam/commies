defmodule Commies.Router do
  use Plug.Router

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
    body = %{
      id: 1024,
      content: "This is gonna be fun"
    }

    send_json_resp(conn, 200, body)
  end

  defp send_json_resp(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end
