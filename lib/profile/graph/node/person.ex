defmodule Profile.Graph.Node.Person do
  use Profile.Graph.Node.Behaviour

  embedded_schema do
    field :name, :string
    field :slug, :string
    field :description, :string
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
end
