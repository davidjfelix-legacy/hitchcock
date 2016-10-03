defmodule Hitchcock.Repo.Migrations.CreateVideoPermissions do
  use Ecto.Migration

  def change do
    
    ### Video Permissions
    create table(:video_permissions, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :video_id, references(:videos, on_delete: :delete_all, type: :uuid), null: false
      add :permission_id, references(:permissions, on_delete: :delete_all, type: :uuid), null: false
    end

    # Prevent Bad data. No more than one video permission per permission
    create unique_index(:video_permissions, [:permission_id])

  end
end
