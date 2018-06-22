defmodule Commies.Router.AuthTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mox

  alias Commies.{
    Repo,
    Router
  }

  setup :verify_on_exit!

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    :ok
  end

  @moduletag :capture_log

  describe "GET /oauth/login/github" do
    test "redirects to Github" do
      conn =
        :get
        |> conn("/oauth/login/github")
        |> Router.call([])

      assert conn.resp_body == ""
      assert [redirect_url] = get_resp_header(conn, "location")

      assert uri = URI.parse(redirect_url)

      assert uri.host == "github.com"
      assert uri.path == "/login/oauth/authorize"

      assert query =
               uri.query
               |> URI.query_decoder()
               |> Enum.into(%{})

      assert query["client_id"] == "dummy"
      assert query["redirect_uri"] == "http://localhost:3000/oauth/auth/github"
      assert query["scope"] == "user:email"
    end
  end

  describe "GET /oauth/auth/github" do
    test "exchanges access token with Github API" do
      req_params = %{
        "code" => "foo:bar"
      }

      stub(Commies.HTTP.FakeClient, :request, fn
        :post, req_url, _req_headers, _req_body, _req_options ->
          assert req_url == "https://github.com/login/oauth/access_token"
          {:ok, 200, [], Jason.encode!(%{access_token: "123456"})}

        :get, "https://api.github.com/user", _req_headers, _req_body, _req_options ->
          {:ok, 200, [], Jason.encode!(%{id: 123_456, login: "foo"})}

        :get, "https://api.github.com/user/emails", _req_headers, _req_body, _req_options ->
          {:ok, 200, [], Jason.encode!([%{email: "test@test.com", primary: true}])}
      end)

      body =
        :get
        |> conn("/oauth/auth/github")
        |> Map.put(:query_params, req_params)
        |> Router.call([])
        |> json_response(200)

      assert Map.has_key?(body, "access_token")
    end

    test "handles bad request" do
      body =
        :get
        |> conn("/oauth/auth/github")
        |> Router.call([])
        |> json_response(400)

      assert body == %{"errors" => ["unable to authenticate user"]}
    end
  end

  defp json_response(conn, status) do
    assert conn.status == status
    assert get_resp_header(conn, "content-type") == ["application/json"]

    Jason.decode!(conn.resp_body)
  end
end
