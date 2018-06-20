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
end
