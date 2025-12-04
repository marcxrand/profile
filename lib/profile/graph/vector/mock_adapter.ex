defmodule Profile.Graph.Vector.MockAdapter do
  @moduledoc """
  Mock embedding adapter for testing.

  Generates deterministic pseudo-random vectors based on text content,
  allowing tests to verify similarity search without API calls.
  """

  @behaviour Profile.Graph.Vector.Adapter

  @dimensions 1536

  @impl true
  def generate(text) when is_binary(text) do
    # Generate deterministic vector from text hash
    # Similar texts will have somewhat similar vectors due to shared words
    vector =
      text
      |> normalize_text()
      |> text_to_vector()
      |> normalize_vector()

    {:ok, {vector, "mock"}}
  end

  defp normalize_text(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^\w\s]/u, "")
    |> String.split()
    |> Enum.uniq()
  end

  defp text_to_vector(words) do
    # Create base vector from word hashes
    base = List.duplicate(0.0, @dimensions)

    Enum.reduce(words, base, fn word, acc ->
      word_vector = word_to_vector(word)
      Enum.zip_with(acc, word_vector, &(&1 + &2))
    end)
  end

  defp word_to_vector(word) do
    # Deterministic pseudo-random vector from word
    seed = :erlang.phash2(word)
    :rand.seed(:exsss, {seed, seed, seed})

    for _ <- 1..@dimensions do
      :rand.uniform() * 2 - 1
    end
  end

  defp normalize_vector(vector) do
    # L2 normalization
    magnitude = :math.sqrt(Enum.reduce(vector, 0, fn x, acc -> acc + x * x end))

    if magnitude > 0 do
      Enum.map(vector, &(&1 / magnitude))
    else
      vector
    end
  end
end
