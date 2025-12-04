defmodule Profile.Graph.Node.Person do
  use Profile.Graph.Node.Behaviour
  use Oban.Pro.Decorator

  alias Oban.Pro.Workflow
  alias Profile.Graph

  embedded_schema do
    field :name, :string
    field :slug, :string
    field :description, :string
  end

  @impl true
  def insert(data) do
    with {:ok, person} <- Profile.Graph.insert_node(%{type: type(), data: data}) do
      Workflow.new(workflow_name: "insert-person")
      |> Workflow.add(:description, new_update_description(person.id))
      |> Oban.insert_all()

      {:ok, person}
    end
  end

  @impl true
  def update(%Graph.Node{} = node, data) do
    with {:ok, person} <- Graph.update_node(node, %{data: Map.merge(node.data, data)}) do
      if Map.has_key?(data, :name) || Map.has_key?(data, :description) do
        upsert_vector(person.id)
      end

      {:ok, person}
    end
  end

  @impl true
  def type, do: "person"

  @impl true
  def validate(data) do
    %__MODULE__{}
    |> cast(data, [:name, :slug, :description])
    |> validate_required([:name])
    |> maybe_generate_slug()
    |> validate_required([:slug])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must be lowercase letters, numbers, and hyphens only"
    )
    |> to_result()
  end

  def vector_text(person) do
    "[NAME: #{person.name}] #{person.description}"
  end

  defp maybe_generate_slug(changeset) do
    if (name = get_change(changeset, :name)) && !get_change(changeset, :slug) do
      put_change(changeset, :slug, generate_slug(name))
    else
      changeset
    end
  end

  defp generate_slug(nil), do: nil

  defp generate_slug(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^\w\s-]/u, "")
    |> String.replace(~r/\s+/, "-")
    |> String.replace(~r/-+/, "-")
    |> String.trim("-")
  end

  ## Workers
  @job true
  def update_description(person_id) do
    person = get!(person_id)
    prompt = Profile.AI.Prompts.person_description(person.data.name, person.data.description)
    output = Profile.Clients.OpenAI.chat!(prompt, %{schema: %{description: :string}})
    description = Map.get(output, "description")

    update(person, %{description: description})
  end

  @job true
  def upsert_vector(person_id) do
    person = get!(person_id)
    text = vector_text(person.data)
    {embedding, model} = Profile.Graph.generate_embedding!(text)
    attrs = %{embedding: embedding, model: model, text: text, type: type(), node_id: person.id}

    Graph.insert_vector(attrs)
  end
end
