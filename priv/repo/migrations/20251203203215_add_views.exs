defmodule Profile.Repo.Migrations.AddViews do
  use Ecto.Migration

  def up do
    execute "CREATE VIEW people_view AS SELECT * FROM nodes WHERE type = 'person'"
  end

  def down do
    execute "DROP VIEW people_view"
  end
end
