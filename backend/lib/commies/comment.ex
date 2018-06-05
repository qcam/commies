defmodule Commies.Comment do
  use Ecto.Schema

  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:content, :link_id]}

  schema "comments" do
    field(:content, :string)
    field(:link_id, :string)

    timestamps()
  end

  def create_changeset(params) do
    allowed_fields = [:content, :link_id]
    required_fields = [:content, :link_id]

    %__MODULE__{}
    |> cast(params, allowed_fields)
    |> validate_required(required_fields)
  end
end
