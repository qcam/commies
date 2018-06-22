defmodule Commies.Router.CommentTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mox
  import Commies.Factory

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

  describe "GET /links/:link_id/comments" do
    @describetag :capture_log

    test "lists all comments of the link" do
      link_id = "1"

      user = insert(:user)

      comments = insert_list(3, :comment, %{link_id: link_id, user_id: user.id})

      comment_ids =
        comments
        |> Enum.sort_by(& &1.inserted_at)
        |> Enum.map(& &1.id)

      comment1 = List.first(comments)

      body =
        :get
        |> conn("/links/#{link_id}/comments")
        |> Router.call([])
        |> json_response(200)

      assert Enum.map(body["comments"], & &1["id"]) == comment_ids

      assert [comment | _] = body["comments"]
      assert comment["id"] == comment1.id
      assert comment["content"] == comment1.content
      assert comment["inserted_at"] == NaiveDateTime.to_iso8601(comment1.inserted_at)
      assert comment["user"]["name"] == user.name
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
