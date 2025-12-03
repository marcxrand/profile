defmodule Profile.Repo.Migrations.AddIndexes do
  use Ecto.Migration

  def change do
    create index(:nodes, [:data], using: :gin)
    create index(:nodes, [:type])

    create unique_index(:nodes, ["(data->>'slug')"],
             where: "type = 'person' AND deleted_at IS NULL",
             name: :nodes_person_slug_unique
           )

    create index(:edges, [:data], using: :gin)
    create index(:edges, [:source_id])
    create index(:edges, [:target_id])
    create index(:edges, [:type])

    create index(:edges, [:source_id, :type])
    create index(:edges, [:target_id, :type])

    create index(:edges, [:source_id, :type, :target_id, :weight], name: :edges_outbound)
    create index(:edges, [:target_id, :type, :source_id, :weight], name: :edges_inbound)

    create unique_index(:edges, [:source_id, :target_id, :type], name: :edges_unique)
  end
end
