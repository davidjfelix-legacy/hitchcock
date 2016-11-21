defmodule Hitchcock.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    ### Groups
    # A table storing groupings of users
    # Groups can be user created groups or user groups
    # Groups have an owner
    create table(:groups, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :is_user_group, :boolean, default: false, null: false

      add :owner_id, references(:users, on_delete: :delete_all, type: :uuid), null: false

      timestamps
    end

    # Groups use name as a changable identifier in the API
    create unique_index(:groups, [:name])

    ### User Groups
    # A table storing a special relationship between a user and the native group
    # Users have a single group named after them called a "User Group"
    # Only one group may be a user group for a given user
    # Only one user may be owner to a user group
    create table(:user_groups, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false
      add :group_id, references(:groups, on_delete: :delete_all, type: :uuid), null: false

      timestamps
    end

    # Can't have more than one UserGroup per Group
    create unique_index(:user_groups, [:group_id])

    # Can't have more than one UserGroup per User
    create unique_index(:user_groups, [:user_id])

    ### Group Members
    # A table storing many to many relationships between users and groups
    # A user may be members of many groups
    # A group may have many users
    create table(:group_members, primary_key: false) do
      add id, :uuid, primary_key: true

      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false
      add :group_id, references(:groups, on_delete: :delete_all, type: :uuid), null: false

      timestamps
    end

    # A user can't have multiple memberships on the same group
    create unique_index(:group_members, [:user_id, :group_id])

  end
end
