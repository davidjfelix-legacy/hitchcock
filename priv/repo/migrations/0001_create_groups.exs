defmodule Hitchcock.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    ### Groups
    create table(:groups, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false

      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false

      timestamps
    end

    # Groups use name as a changable identifier in the API
    create unique_index(:groups, [:name])
  end
end
