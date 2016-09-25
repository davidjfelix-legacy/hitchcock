defmodule Hitchcock.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    ### Permissions
    create table(:permissions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :grant, :string, null: false

      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false

      timestamps
    end

    # TODO: Add a constraint that holds permission into a fixed enum of values
  end
end
