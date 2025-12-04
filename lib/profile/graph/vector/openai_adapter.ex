defmodule Profile.Graph.Vector.OpenAIAdapter do
  @behaviour Profile.Graph.Vector.Adapter

  def generate(text) do
    embedding = [text]
    model = "openai"
    {:ok, {embedding, model}}
  end
end
