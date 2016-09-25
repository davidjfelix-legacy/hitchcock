defmodule Hitchcock.Repo.Migrations.CreateGroupPermissions do
  use Ecto.Migration

  def change do
    ### Group Permissions
    create table(:group_permissions, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :group_id, references(:groups, on_delete: :delete_all, type: :uuid), null: false
      add :permission_id, references(:permissions, on_delete: :delete_all, type: :uuid), null: false

      timestamps
    end

    # Prevent Bad data. No more than one group permission per permission
    create unique_index(:group_permissions, [:permission_id])
  end
end
