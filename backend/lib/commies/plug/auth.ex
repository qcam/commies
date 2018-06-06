defmodule Commies.Plug.Auth do
  import Plug.Conn

  import Ecto.Query

  alias Commies.{
    Auth,
    Repo,
    User
  }

  require Logger

  @supported_auth_providers ["github"]

  def init(options), do: options

  def call(%Plug.Conn{} = conn, _options) do
    case authorize(conn) do
      {:ok, user} ->
        assign(conn, :authenticated_user, user)

      :error ->
        conn
    end
  end

  defp authorize(conn) do
    with {:ok, provider, access_token} <- fetch_authorization(conn),
         {:ok, provider_user} <- auth_provider(provider).get_user(access_token) do
      user =
        User
        |> where(auth_user_id: ^provider_user.id, auth_provider: ^provider)
        |> select([:id])
        |> Repo.one()

      if user do
        {:ok, user}
      else
        :error
      end
    else
      _ -> :error
    end
  end

  defp fetch_authorization(conn) do
    with authorizations when authorizations != [] <- get_req_header(conn, "authorization"),
         authorization <- List.first(authorizations),
         [provider, access_token] when provider in @supported_auth_providers <-
           String.split(authorization, ":", parts: 2) do
      {:ok, provider, access_token}
    else
      _ -> :error
    end
  end

  defp auth_provider("github"), do: Auth.Github
end
