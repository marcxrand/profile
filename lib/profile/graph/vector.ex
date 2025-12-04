defmodule Profile.Graph.Vector do
  @moduledoc """
  Schema and functions for vector embeddings.
  """
  use Profile.Schema

  schema "vectors" do
    field :embedding, Pgvector.Ecto.Vector
    field :model, :string
    field :text, :string
    field :type, :string

    belongs_to :node, Profile.Graph.Node

    timestamps()
  end

  def changeset(vector, attrs) do
    vector
    |> cast(attrs, [:embedding, :model, :text, :type, :node_id])
    |> validate_required([:embedding, :model, :text, :type, :node_id])
  end
end
