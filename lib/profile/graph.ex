defmodule Profile.Graph do
  import Ecto.Query

  # alias Profile.Graph.Edge
  alias Profile.Graph.Node
  alias Profile.Repo

  # ===========================================================================
  # Node Operations
  # ===========================================================================
  @doc """
  Gets a node by ID.
  """
  @spec get_node(Ecto.UUID.t()) :: Node.t() | nil
  def get_node(id) do
    Node
    |> where([n], is_nil(n.deleted_at))
    |> Repo.get(id)
  end

  @doc """
  Gets a node by ID, raises if not found.
  """
  @spec get_node!(Ecto.UUID.t()) :: Node.t()
  def get_node!(id) do
    Node
    |> where([n], is_nil(n.deleted_at))
    |> Repo.get!(id)
  end

  @doc """
  Creates a new node.
  """
  @spec insert_node(map()) :: {:ok, Node.t()} | {:error, Ecto.Changeset.t()}
  def insert_node(attrs) do
    %Node{}
    |> Node.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a node.
  """
  @spec update_node(Node.t(), map()) :: {:ok, Node.t()} | {:error, Ecto.Changeset.t()}
  def update_node(%Node{} = node, attrs) do
    node
    |> Node.changeset(attrs)
    |> Repo.update()
  end

  # ===========================================================================
  # Vector Operations
  # ===========================================================================

  def insert_vector(attrs) do
    opts = [
      on_conflict: [set: [updated_at: DateTime.utc_now()]],
      conflict_target: [:node_id, :text, :type],
      returning: true
    ]

    %Profile.Graph.Vector{}
    |> Profile.Graph.Vector.changeset(attrs)
    |> Repo.insert(opts)
  end

  def generate_embedding(text) do
    if Application.fetch_env!(:profile, :env) == :prod do
      Profile.Graph.Vector.OpenAIAdapter.generate(text)
    else
      Profile.Graph.Vector.MockAdapter.generate(text)
    end
  end

  def generate_embedding!(text) do
    {:ok, {embedding, model}} = generate_embedding(text)
    {embedding, model}
  end
end
