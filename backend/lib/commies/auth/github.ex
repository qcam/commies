defmodule Commies.Auth.Github do
  require Logger

  @req_options [
    :with_body,
    recv_timeout: 5_000,
    pool: :auth_pool
  ]

  github_credential = Application.fetch_env!(:commies, __MODULE__)

  @client_id Keyword.fetch!(github_credential, :client_id)
  @client_secret Keyword.fetch!(github_credential, :client_secret)

  def exchange_access_token(code) do
    req_headers = [
      {"content-type", "application/json"},
      {"accept", "application/json"}
    ]

    req_body =
      Jason.encode!(%{
        code: code,
        client_id: @client_id,
        client_secret: @client_secret
      })

    req_url = "https://github.com/login/oauth/access_token"

    case :hackney.request(:post, req_url, req_headers, req_body, @req_options) do
      {:ok, 200, _resp_headers, resp_body} ->
        payload = Jason.decode!(resp_body)

        case Map.fetch(payload, "access_token") do
          {:ok, access_token} ->
            {:ok, access_token}

          :error ->
            Logger.warn(
              "Got unexpected response from Github OAuth API, payload: #{inspect(payload)}"
            )

            :error
        end

      {:ok, status, _resp_headers, _resp_body} ->
        Logger.error(
          "Received unexpected response from Github OAuth API, status: #{inspect(status)}"
        )

        :error

      {:error, reason} ->
        Logger.error("Could not reach Github OAuth API, reason: #{inspect(reason)}")
        :error
    end
  end

  def get_user(access_token) do
    req_headers = [
      {"content-type", "application/json"},
      {"accept", "application/json"},
      {"authorization", "token #{access_token}"}
    ]

    req_body = []

    req_url = "https://api.github.com/user"

    case :hackney.request(:get, req_url, req_headers, req_body, @req_options) do
      {:ok, 200, _resp_headers, resp_body} ->
        %{
          "id" => id,
          "login" => name
        } = Jason.decode!(resp_body)

        {:ok,
         %{
           id: Integer.to_string(id),
           name: name
         }}

      {:ok, status, _resp_headers, _resp_body} ->
        Logger.error("Received unexpected response from Github API, status: #{inspect(status)}")
        :error

      {:error, reason} ->
        Logger.error("Could not reach Github API, reason: #{inspect(reason)}")
        :error
    end
  end

  def get_user_email(access_token) do
    req_headers = [
      {"content-type", "application/json"},
      {"accept", "application/json"},
      {"authorization", "token #{access_token}"}
    ]

    req_body = []

    req_url = "https://api.github.com/user/emails"

    case :hackney.request(:get, req_url, req_headers, req_body, @req_options) do
      {:ok, 200, _resp_headers, resp_body} ->
        email =
          resp_body
          |> Jason.decode!()
          |> Enum.find(& &1["primary"])
          |> Map.fetch!("email")

        {:ok, email}

      {:ok, status, _resp_headers, _resp_body} ->
        Logger.error("Received unexpected response from Github API, status: #{inspect(status)}")
        :error

      {:error, reason} ->
        Logger.error("Could not reach Github API, reason: #{inspect(reason)}")
        :error
    end
  end

  def oauth_url(scope, redirect_uri) do
    query_params = %{
      client_id: @client_id,
      redirect_uri: redirect_uri,
      scope: scope
    }

    "https://github.com/login/oauth/authorize?#{URI.encode_query(query_params)}"
  end
end
