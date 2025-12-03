defmodule Profile.Graph.Edge do
  @moduledoc """
  Graph edge schema representing directed relationships between nodes.

  Edges connect nodes and support:
  - Typed relationships (e.g., "follows", "knows", "owns")
  - Weight for graph algorithms (shortest path, PageRank, centrality)
  - JSONB data for relationship metadata

  Edges are directed (source → target). For bidirectional relationships,
  create edges in both directions or query both incoming and outgoing.

  ## Examples

      # Create a "follows" relationship
      %Edge{}
      |> Edge.changeset(%{
        source_id: alice.id,
        target_id: bob.id,
        type: "follows",
        data: %{since: ~D[2024-01-01]}
      })
      |> Repo.insert()

      # Weighted edge for distance/cost
      %Edge{}
      |> Edge.changeset(%{
        source_id: city_a.id,
        target_id: city_b.id,
        type: "connected_to",
        weight: 150.5
      })
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Profile.Graph.Node

  @type t :: %__MODULE__{
          id: Ecto.UUID.t() | nil,
          type: String.t() | nil,
          weight: float(),
          data: map(),
          source_id: Ecto.UUID.t() | nil,
          target_id: Ecto.UUID.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]

  schema "edges" do
    field :type, :string
    field :weight, :float, default: 1.0
    field :data, :map, default: %{}

    belongs_to :source, Node
    belongs_to :target, Node

    timestamps()
  end

  @required_fields ~w(type source_id target_id)a
  @optional_fields ~w(weight data)a

  @doc """
  Creates a changeset for an edge.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(edge, attrs) do
    edge
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:type, min: 1, max: 255)
    |> validate_number(:weight, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:source_id)
    |> foreign_key_constraint(:target_id)
    |> validate_not_self_referential()
    |> unique_constraint([:source_id, :target_id, :type],
      name: :edges_unique,
      message: "edge of this type already exists between these nodes"
    )
  end

  defp validate_not_self_referential(changeset) do
    source_id = get_field(changeset, :source_id)
    target_id = get_field(changeset, :target_id)

    if source_id && target_id && source_id == target_id do
      add_error(changeset, :target_id, "cannot create edge to self")
    else
      changeset
    end
  end
end
