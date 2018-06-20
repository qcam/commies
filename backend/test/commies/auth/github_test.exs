defmodule Commies.Auth.GithubTest do
  use ExUnit.Case, async: true

  import Mox

  import ExUnit.CaptureLog

  alias Commies.Auth.Github
  alias Commies.HTTP.FakeClient

  setup :verify_on_exit!

  describe "exchange_access_token/1" do
    test "exchanges auth code for access token" do
      code = "123456"
      access_token = "abcdef"

      expect(FakeClient, :request, fn :post, req_url, req_headers, req_body, _req_options ->
        assert req_url == "https://github.com/login/oauth/access_token"

        assert {"content-type", "application/json"} in req_headers
        assert {"accept", "application/json"} in req_headers

        expected_body = %{
          client_id: "dummy",
          client_secret: "dummy",
          code: code
        }

        assert req_body == Jason.encode!(expected_body)

        {:ok, 200, [], Jason.encode!(%{access_token: access_token})}
      end)

      assert Github.exchange_access_token(code) == {:ok, access_token}
    end

    test "handles unexpected response" do
      code = "123456"

      expect(FakeClient, :request, fn :post, _req_url, _req_headers, _req_body, _req_options ->
        {:ok, 500, [], ""}
      end)

      log =
        capture_log(fn ->
          assert Github.exchange_access_token(code) == :error
        end)

      assert log =~ "Received unexpected response from Github OAuth API, status: 500"
    end
  end
end
