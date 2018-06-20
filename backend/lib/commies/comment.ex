defmodule Commies.Comment do
  use Ecto.Schema

  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :content, :link_id]}

  schema "comments" do
    belongs_to(:user, Commies.User)

    field(:content, :string)
    field(:link_id, :string)

    timestamps()
  end

  def create_changeset(params) do
    allowed_fields = [:content, :link_id, :user_id]
    required_fields = [:content, :link_id]

    %__MODULE__{}
    |> cast(params, allowed_fields)
    |> validate_required(required_fields)
    |> foreign_key_constraint(:user_id)
  end

  def update_changeset(%__MODULE__{} = comment, params) do
    allowed_fields = [:content, :link_id]
    required_fields = [:content, :link_id]

    comment
    |> cast(params, allowed_fields)
    |> validate_required(required_fields)
  end
end
