defmodule Profile.Graph.Node do
  @moduledoc """
  Graph node schema supporting polymorphic node types with flexible data.

  Nodes are the vertices in the graph structure. Each node has:
  - A type (e.g., "person", "organization", "document") for polymorphism
  - JSONB data for flexible, schema-less attributes validated by type modules
  - Soft delete support via deleted_at

  ## Type Registration

  Node types are registered by implementing `Profile.Graph.Node.Behaviour` and
  adding the module to the `@type_registry`. Each type module validates its own
  data structure using Ecto embedded schemas.

  ## Examples

      # Create a person node (data is validated by Person type module)
      %Node{}
      |> Node.changeset(%{type: "person", data: %{name: "Alice", email: "alice@example.com"}})
      |> Repo.insert()

      # Query with data
      from(n in Node, where: fragment("? ->> ? = ?", n.data, "email", "alice@example.com"))
  """

  use Profile.Schema

  alias Profile.Graph.Edge

  # Type registry: maps type strings to their implementing modules
  @type_registry %{
    "person" => Profile.Graph.Node.Person
  }

  @doc """
  Returns the type registry mapping type strings to modules.
  """
  @spec type_registry() :: %{String.t() => module()}
  def type_registry, do: @type_registry

  @doc """
  Gets the module for a given type string.
  Returns `{:ok, module}` or `:error` if type is not registered.
  """
  @spec get_type_module(String.t()) :: {:ok, module()} | :error
  def get_type_module(type) when is_binary(type) do
    Map.fetch(@type_registry, type)
  end

  @doc """
  Returns all registered type names.
  """
  @spec registered_types() :: [String.t()]
  def registered_types, do: Map.keys(@type_registry)

  @type t :: %__MODULE__{
          id: Ecto.UUID.t() | nil,
          type: String.t() | nil,
          data: map(),
          deleted_at: DateTime.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "nodes" do
    field :type, :string
    field :data, :map, default: %{}
    field :deleted_at, :utc_datetime_usec

    has_many :outgoing_edges, Edge, foreign_key: :source_id, where: [deleted_at: nil]
    has_many :incoming_edges, Edge, foreign_key: :target_id, where: [deleted_at: nil]

    timestamps()
  end

  @required_fields ~w(type)a
  @optional_fields ~w(data deleted_at)a

  @doc """
  Creates a changeset for a node.

  If the type is registered, validates the data field using the type module.
  Unregistered types are allowed with any data (for flexibility).
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(node, attrs) do
    node
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:type, min: 1, max: 255)
    |> validate_data_for_type()
    |> maybe_add_type_constraints()
  end

  defp maybe_add_type_constraints(changeset) do
    case get_field(changeset, :type) do
      "person" ->
        unique_constraint(changeset, :data,
          name: :nodes_person_slug_unique,
          message: "slug already taken"
        )

      _ ->
        changeset
    end
  end

  defp validate_data_for_type(changeset) do
    type = get_field(changeset, :type)
    data = get_field(changeset, :data) || %{}

    case get_type_module(type) do
      {:ok, module} ->
        case module.validate(data) do
          {:ok, validated_data} ->
            put_change(changeset, :data, validated_data)

          {:error, data_changeset} ->
            merge_data_errors(changeset, data_changeset)
        end

      :error ->
        # Unregistered type - allow any data
        changeset
    end
  end

  defp merge_data_errors(changeset, data_changeset) do
    errors = traverse_data_errors(data_changeset)
    add_error(changeset, :data, "is invalid", validation: :data, errors: errors)
  end

  defp traverse_data_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  @doc """
  Marks a node as deleted (soft delete).
  """
  @spec soft_delete_changeset(t()) :: Ecto.Changeset.t()
  def soft_delete_changeset(node) do
    change(node, deleted_at: DateTime.utc_now())
  end
end
