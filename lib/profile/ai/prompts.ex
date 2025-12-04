defmodule Profile.AI.Prompts do
  def person_category(name, description) do
    """
    <instructions>
       Follow the steps below to generate a category for the person. You are given their name and a short description.
    </instructions>
    <steps>
      <step>
        Generate a single word in title case that best captures the person's profession in a general sense.
      </step>
    </steps>
    <input>
      <name>#{name}</name>
      <description>#{description}</description>
    </input>
    """
  end

  def person_description(name, description) do
    """
    <instructions>
      Follow the steps below to generate a description of the person. In addition to their name, you are given a short text to help with deduplication if needed.
    </instructions>
    <steps>
      <step>
        Write and normalize a description of the person that is a concise, semantically rich version optimized for storage in a vector database with embedding size 1536.
        Goals:
        1. Deduplication: Remove redundant phrases, marketing fluff, and filler language so the result captures only the essential, distinctive meaning of the person.
        2. Semantic clarity: Preserve key identifying information such as person's name, main themes, and subject focus.
        3. Consistency: Output should be plain text, neutral in tone, with no formatting, emojis, or special characters.
        4. Length control: Keep it between 100–250 words so embeddings remain efficient but informative.
        5. Retrieval focus: Ensure the text emphasizes what makes this person unique so that near-duplicate or identical people can be detected when embeddings are compared.
      </step>
    </steps>
    <input>
      <name>#{name}</name>
      <text>#{description}</text>
    </input>
    """
  end
end
