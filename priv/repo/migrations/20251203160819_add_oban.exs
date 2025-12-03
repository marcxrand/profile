defmodule Profile.Repo.Migrations.AddOban do
  use Ecto.Migration

  defdelegate up, to: Oban.Pro.Migrations.DynamicPartitioner
  defdelegate down, to: Oban.Pro.Migrations.DynamicPartitioner
end
