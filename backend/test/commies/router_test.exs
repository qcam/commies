defmodule Commies.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Commies.Router

  describe "GET /probe" do
    @describetag :capture_log

    test "responds health-check status" do
      conn =
        :get
        |> conn("/probe")
        |> Router.call([])

      assert conn.status == 200
      assert conn.resp_body == ""
    end
  end

  describe "non exisiting route" do
    @describetag :capture_log

    test "reponds with corresponding status" do
      body =
        :get
        |> conn("/i-dont-exist")
        |> Router.call([])
        |> json_response(404)

      assert body == %{"errors" => ["not found"]}
    end
  end

  defp json_response(conn, status) do
    assert conn.status == status
    assert get_resp_header(conn, "content-type") == ["application/json"]

    Jason.decode!(conn.resp_body)
  end
end
