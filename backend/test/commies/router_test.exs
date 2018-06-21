defmodule Commies.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mox

  alias Commies.{
    Comment,
    Repo,
    Router,
    User
  }

  setup :verify_on_exit!

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    :ok
  end

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

  describe "PUT /links/:link_id/comments/:comment_id" do
    @describetag :capture_log

    test "updates comment" do
      link_id = "1"

      user =
        Repo.insert!(%User{
          name: "user-1",
          email: "a@b.c",
          auth_provider: "github",
          auth_user_id: "1024"
        })

      comment =
        Repo.insert!(%Comment{
          link_id: link_id,
          user_id: user.id,
          content: "hello world"
        })

      stub(Commies.HTTP.FakeClient, :request, fn :get,
                                                 req_url,
                                                 _req_headers,
                                                 _req_body,
                                                 _req_options ->
        assert req_url == "https://api.github.com/user"
        {:ok, 200, [], Jason.encode!(%{id: 1024, login: "foo"})}
      end)

      req_body = %{
        content: "a little fox"
      }

      access_token = Commies.Auth.Token.generate("github", "abcdef")

      body =
        :put
        |> conn("/links/#{link_id}/comments/#{comment.id}", Jason.encode!(req_body))
        |> put_req_header("authorization", access_token)
        |> put_req_header("accept", "application/json")
        |> put_req_header("content-type", "application/json")
        |> Router.call([])
        |> json_response(200)

      assert body ==
               %{
                 "content" => "a little fox",
                 "id" => comment.id,
                 "link_id" => link_id
               }
    end

    test "disallows updating another user's comment" do
      link_id = "1"

      Repo.insert!(%User{
        name: "user-1",
        email: "a@b.c",
        auth_provider: "github",
        auth_user_id: "1024"
      })

      other_user =
        Repo.insert!(%User{
          name: "user-2",
          email: "b@c.d",
          auth_provider: "github",
          auth_user_id: "2048"
        })

      comment =
        Repo.insert!(%Comment{
          link_id: link_id,
          user_id: other_user.id,
          content: "hello world"
        })

      stub(Commies.HTTP.FakeClient, :request, fn :get,
                                                 req_url,
                                                 _req_headers,
                                                 _req_body,
                                                 _req_options ->
        assert req_url == "https://api.github.com/user"
        {:ok, 200, [], Jason.encode!(%{id: 1024, login: "foo"})}
      end)

      req_body = %{content: "a little fox"}

      access_token = Commies.Auth.Token.generate("github", "abcdef")

      body =
        :put
        |> conn("/links/#{link_id}/comments/#{comment.id}", Jason.encode!(req_body))
        |> put_req_header("authorization", access_token)
        |> put_req_header("accept", "application/json")
        |> put_req_header("content-type", "application/json")
        |> Router.call([])
        |> json_response(404)

      assert body == %{"errors" => ["not found"]}
    end
  end

  describe "DELETE /links/:link_id/comments/:comment_id" do
    @describetag :capture_log

    test "deletes comment" do
      link_id = "1"

      user =
        Repo.insert!(%User{
          name: "user-1",
          email: "a@b.c",
          auth_provider: "github",
          auth_user_id: "1024"
        })

      comment =
        Repo.insert!(%Comment{
          link_id: link_id,
          user_id: user.id,
          content: "hello world"
        })

      stub(Commies.HTTP.FakeClient, :request, fn :get,
                                                 req_url,
                                                 _req_headers,
                                                 _req_body,
                                                 _req_options ->
        assert req_url == "https://api.github.com/user"
        {:ok, 200, [], Jason.encode!(%{id: 1024, login: "foo"})}
      end)

      access_token = Commies.Auth.Token.generate("github", "abcdef")

      conn =
        :delete
        |> conn("/links/#{link_id}/comments/#{comment.id}")
        |> put_req_header("authorization", access_token)
        |> put_req_header("accept", "application/json")
        |> put_req_header("content-type", "application/json")
        |> Router.call([])

      assert conn.status == 204
    end

    test "disallows updating another user's comment" do
      link_id = "1"

      Repo.insert!(%User{
        name: "user-1",
        email: "a@b.c",
        auth_provider: "github",
        auth_user_id: "1024"
      })

      other_user =
        Repo.insert!(%User{
          name: "user-2",
          email: "b@c.d",
          auth_provider: "github",
          auth_user_id: "2048"
        })

      comment =
        Repo.insert!(%Comment{
          link_id: link_id,
          user_id: other_user.id,
          content: "hello world"
        })

      access_token = Commies.Auth.Token.generate("github", "abcdef")

      stub(Commies.HTTP.FakeClient, :request, fn :get,
                                                 req_url,
                                                 _req_headers,
                                                 _req_body,
                                                 _req_options ->
        assert req_url == "https://api.github.com/user"
        {:ok, 200, [], Jason.encode!(%{id: 1024, login: "foo"})}
      end)

      conn =
        :delete
        |> conn("/links/#{link_id}/comments/#{comment.id}")
        |> put_req_header("authorization", access_token)
        |> put_req_header("accept", "application/json")
        |> put_req_header("content-type", "application/json")
        |> Router.call([])

      assert conn.status == 404
      assert Jason.decode!(conn.resp_body) == %{"errors" => ["not found"]}
    end
  end

  defp json_response(conn, status) do
    assert conn.status == status
    assert get_resp_header(conn, "content-type") == ["application/json"]

    Jason.decode!(conn.resp_body)
  end
end
