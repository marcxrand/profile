defmodule Profile.Graph do
  # import Ecto.Query

  # alias Profile.Graph.Edge
  alias Profile.Graph.Node
  alias Profile.Repo

  # ===========================================================================
  # Node Operations
  # ===========================================================================

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
end
