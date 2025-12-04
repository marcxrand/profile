defmodule Profile.Repo.Migrations.AddVectors do
  use Ecto.Migration

  def change do
    create table(:vectors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :node_id, references(:nodes, type: :binary_id), null: false
      add :model, :string, null: false
      add :text, :text, null: false
      add :type, :string, null: false
      add :embedding, :vector, size: 1536, null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
