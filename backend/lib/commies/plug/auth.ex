defmodule Commies.Plug.Auth do
  import Plug.Conn

  import Ecto.Query

  alias Commies.{
    Auth,
    Repo,
    User
  }

  require Logger

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
    with {:ok, payload} <- fetch_auth_payload(conn),
         {:ok, provider_user} <- auth_provider(payload.provider).get_user(payload.token) do
      user =
        User
        |> where(auth_user_id: ^provider_user.id, auth_provider: ^payload.provider)
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

  defp fetch_auth_payload(conn) do
    with authorizations when authorizations != [] <- get_req_header(conn, "authorization"),
         access_token <- List.first(authorizations),
         {:ok, payload} <- Auth.Token.verify(access_token) do
      {:ok, payload}
    else
      _ -> :error
    end
  end

  defp auth_provider("github"), do: Auth.Github
end
