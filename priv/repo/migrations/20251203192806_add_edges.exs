defmodule Profile.Repo.Migrations.AddEdges do
  use Ecto.Migration

  def change do
    create table(:edges, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :weight, :float, default: 1.0, null: false
      add :source_id, references(:nodes, type: :binary_id), null: false
      add :target_id, references(:nodes, type: :binary_id), null: false
      add :data, :map, default: %{}, null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
