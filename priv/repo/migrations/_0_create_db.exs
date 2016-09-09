defmodule Hitchcock.Repo.Migrations.CreateDb do
  use Ecto.Migration

  def change do
    ### Groups
    create table(:groups, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string

      timestamps
    end

    # Groups use name as a changable identifier in the API
    create unique_index(:groups, [:name])


    ### Permissions
    create table(:permissions, primary_key: false) do
      add :id, :uuid, primary_key: true

      timestamps
    end


    ### Users
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :username, :string
      add :email, :string

      timestamps
    end

    # Users use username as a changable identifier in the API
    create unique_index(:users, [:username])

    # Users must have unique emails to discourage multi-accounts
    create unique_index(:users, [:email])


    ### Videos
    create table(:videos) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :url, :string

      add :owner_id, references(:user, on_delete: :delete_all), null: false
      add :group_id, references(:group, on_delete: :delete_all), null: false

      timestamps
    end
  end
end
