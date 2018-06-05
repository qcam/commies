defmodule Commies.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/probe" do
    send_resp(conn, 200, [])
  end
end
