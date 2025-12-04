defmodule Profile.Graph.Vector.Adapter do
  @moduledoc """
  Behaviour for embedding adapters.

  Implement this behaviour to add new embedding providers.
  """

  @doc """
  Generates an embedding vector for the given text.

  Returns a 1536-dimensional vector (OpenAI text-embedding-3-small compatible).
  """
  @callback generate(text :: String.t()) :: {:ok, [float()]} | {:error, term()}
end
