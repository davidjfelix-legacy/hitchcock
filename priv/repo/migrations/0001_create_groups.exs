defmodule Hitchcock.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    ### Groups
    create table(:groups, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :is_user_group, :boolean, default: false, null: false

      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false

      timestamps
    end

    ### User Groups
    create table(:user_groups, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false
      add :group_id, references(:groups, on_delete: :delete_all, type: :uuid), null: false

      timestamps
    end

    # Groups use name as a changable identifier in the API
    create unique_index(:groups, [:name])

    # Can't have more than one UserGroup per Group
    create unique_index(:user_groups, [:group_id])

    # Can't have more than one UserGroup per User
    create unique_index(:user_groups, [:user_id])
  end
end
