defmodule Profile.Graph.Vector.OpenAIAdapter do
  @behaviour Profile.Graph.Vector.Adapter

  def generate(text) do
    response = Profile.Clients.OpenAI.embedding!(text)
    {:ok, response}
  end
end
