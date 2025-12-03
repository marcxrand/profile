defmodule ProfileWeb.TailwindFormatter do
  @moduledoc """
  Sorts Tailwind CSS classes in HTML templates.

  Sorting rules:
  1. Sort classes alphabetically by base name (part after last `:`)
  2. Ignore negative prefixes (-) when sorting
  3. State classes (hover:, focus:, etc.) go at the end
  """

  # MapSet for O(1) lookup instead of O(n) list membership
  @state_keywords MapSet.new(
                    ~w(hover focus active disabled visited first last odd even group-hover peer-hover focus-within focus-visible)
                  )

  @doc """
  Called by Phoenix.LiveView.HTMLFormatter to format the class attribute.
  """
  def render_attribute({name, {:string, value, meta}, attr_meta}, _opts) do
    sorted = sort_classes(value)
    {name, {:string, sorted, meta}, attr_meta}
  end

  def render_attribute(attr, _opts), do: attr

  defp sort_classes(value) do
    value
    |> String.split()
    |> Enum.sort_by(&sort_key/1)
    |> Enum.join(" ")
  end

  # Single split, compute both priority and base_name together
  defp sort_key(class) do
    parts = :binary.split(class, ":", [:global])
    base = parts |> List.last() |> String.trim_leading("-")
    priority = if has_state_prefix?(parts), do: 1, else: 0
    {priority, base}
  end

  # Pattern matching to avoid Enum.drop(-1) allocation
  defp has_state_prefix?([_single]), do: false
  defp has_state_prefix?(parts), do: check_prefixes(parts)

  defp check_prefixes([_last]), do: false

  defp check_prefixes([head | tail]) do
    MapSet.member?(@state_keywords, head) or check_prefixes(tail)
  end
end
