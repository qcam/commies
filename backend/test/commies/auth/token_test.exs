defmodule Commies.Auth.TokenTest do
  use ExUnit.Case, async: true

  alias Commies.Auth.Token

  test "signs and verifies access token" do
    signed_at = DateTime.utc_now()
    provider = "github"
    access_token = "yoyo"
    token = Token.generate(provider, access_token, signed_at)

    assert {:ok, payload} = Token.verify(token)
    assert payload.provider == provider
    assert payload.token == access_token
    assert payload.signed_at == DateTime.to_iso8601(signed_at)
  end
end
