defmodule Commies.User do
  use Ecto.Schema

  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :auth_provider]}

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:auth_provider, :string)
    field(:auth_user_id, :string)

    timestamps()
  end

  def upsert_changeset(user) do
    allowed_fields = [:name, :email, :auth_provider, :auth_user_id]
    required_fields = [:name, :email, :auth_provider, :auth_user_id]

    %__MODULE__{}
    |> cast(user, allowed_fields)
    |> validate_required(required_fields)
  end
end
