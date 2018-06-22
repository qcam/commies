defmodule Commies.Auth.Token do
  @secret :commies |> Application.fetch_env!(__MODULE__) |> Keyword.fetch!(:secret)

  def generate(provider, access_token, signed_at \\ DateTime.utc_now()) do
    payload = %{
      provider: provider,
      token: access_token,
      signed_at: signed_at
    }

    encoded_payload =
      payload
      |> Jason.encode!()
      |> Base.encode64(padding: false)

    signature =
      encoded_payload
      |> sign()
      |> Base.encode64(padding: false)

    "#{encoded_payload}.#{signature}"
  end

  def verify(token) do
    with [encoded_payload, encoded_signature] <- String.split(token, "."),
         {:ok, signature} <- Base.decode64(encoded_signature, padding: false),
         ^signature <- sign(encoded_payload) do
      payload =
        encoded_payload
        |> Base.decode64!(padding: false)
        |> Jason.decode!(keys: :atoms!)

      {:ok, payload}
    else
      _other -> :error
    end
  end

  def sign(payload) do
    :crypto.hmac(:sha256, @secret, payload)
  end
end
