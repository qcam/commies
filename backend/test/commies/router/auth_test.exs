defmodule Commies.Router.AuthTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mox

  alias Commies.{
    Auth,
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
      url = "https://example.com?a=1&b=2"
      state = compute_state(url)

      conn =
        :get
        |> conn("/oauth/login/github")
        |> Map.put(:query_params, %{"r" => url})
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
      assert query["state"] == state
    end
  end

  describe "GET /oauth/auth/github" do
    test "exchanges access token with Github API" do
      location = "http://example.com?a=1&b=2"
      state = compute_state(location)

      req_params = %{
        "code" => "foo:bar",
        "state" => state
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

      conn =
        :get
        |> conn("/oauth/auth/github")
        |> Map.put(:query_params, req_params)
        |> Router.call([])

      assert conn.status == 302
      assert [redirect_url] = get_resp_header(conn, "location")
      assert uri = URI.parse(redirect_url)
      assert uri.host == "example.com"
      assert query = URI.decode_query(uri.query)
      assert query["a"] == "1"
      assert query["b"] == "2"
      assert {:ok, auth_payload} = Auth.Token.verify(query["token"])
      assert auth_payload.provider == "github"
      assert auth_payload.token == "123456"
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

  defp compute_state(url) do
    encoded_url = Base.encode64(url)

    signature =
      encoded_url
      |> Auth.Token.sign()
      |> Base.encode64()

    "#{encoded_url}.#{signature}"
  end
end
