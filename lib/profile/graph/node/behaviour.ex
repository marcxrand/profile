defmodule Profile.Graph.Node.Behaviour do
  @moduledoc """
  Behaviour for node type definitions.

  Each node type must implement this behaviour to define its data validation
  and default values. Type modules use Ecto embedded schemas for validation,
  providing type coercion and consistent error handling.

  ## Callbacks

  Required:
  - `type/0` - returns the node type string
  - `validate/1` - validates and coerces input data

  Optional (default implementations provided):
  - `insert/1` - creates a new node with validated data
  - `update/2` - updates an existing node, merging data

  ## Example

      defmodule Profile.Graph.Node.Person do
        use Profile.Graph.Node.Behaviour

        embedded_schema do
          field :name, :string
        end

        @impl true
        def type, do: "person"

        @impl true
        def validate(data) do
          %__MODULE__{}
          |> cast(data, [:name])
          |> validate_required([:name])
          |> to_result()
        end
      end

      # Usage:
      Person.insert(%{name: "Alice"})
      Person.update(node, %{name: "Bob"})
  """

  @doc """
  Injects the behaviour and convenience functions into the using module.
  """
  defmacro __using__(_opts) do
    quote do
      @behaviour Profile.Graph.Node.Behaviour

      use Ecto.Schema

      import Ecto.Changeset

      @primary_key false

      def get(id) do
        Profile.Graph.get_node(id)
      end

      def get!(id) do
        Profile.Graph.get_node!(id)
      end

      @impl true
      def insert(data) do
        Profile.Graph.insert_node(%{type: type(), data: data})
      end

      @impl true
      def update(%Profile.Graph.Node{} = node, data) do
        Profile.Graph.update_node(node, %{data: Map.merge(node.data, data)})
      end

      defoverridable insert: 1, update: 2

      defp to_result(changeset) do
        case Ecto.Changeset.apply_action(changeset, :validate) do
          {:ok, struct} ->
            data =
              struct
              |> Map.from_struct()
              |> Map.reject(fn {_k, v} -> is_nil(v) end)

            {:ok, data}

          {:error, changeset} ->
            {:error, changeset}
        end
      end
    end
  end

  @doc """
  Returns the type name string for this node type.
  """
  @callback type() :: String.t()

  @doc """
  Validates the data map for this node type.

  Returns `{:ok, validated_data}` with coerced/cleaned data on success,
  or `{:error, changeset}` with validation errors on failure.
  """
  @callback validate(data :: map()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}

  @doc """
  Inserts a new node with the given data.

  Returns `{:ok, node}` on success, or `{:error, changeset}` on failure.
  """
  @callback insert(data :: map()) :: {:ok, Profile.Graph.Node.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Updates an existing node with the given data, merging with existing data.

  Returns `{:ok, node}` on success, or `{:error, changeset}` on failure.
  """
  @callback update(node :: Profile.Graph.Node.t(), data :: map()) ::
              {:ok, Profile.Graph.Node.t()} | {:error, Ecto.Changeset.t()}
end
