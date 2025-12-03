defmodule Profile.Repo.Migrations.AddNodes do
  use Ecto.Migration

  def change do
    create table(:nodes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :data, :map, default: %{}, null: false
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end
  end
end
