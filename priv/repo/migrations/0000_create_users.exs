defmodule Hitchcock.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    ### Users
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :username, :string, null: false
      add :email, :string, null: false
      add :encrypted_password, :string, null: false

      timestamps
    end

    # Users use username as a changable identifier in the API
    create unique_index(:users, [:username])

    # Users must have unique emails to discourage multi-accounts
    create unique_index(:users, [:email])
  end
end
