defmodule Hitchcock.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    ### Videos
    create table(:videos, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, null: false
      add :url, :string, null: false
      add :description, :text, null: false

      add :owner_id, references(:users, on_delete: :delete_all, type: :uuid), null: false
      add :group_id, references(:groups, on_delete: :delete_all, type: :uuid), null: false

      timestamps
    end
  end
end
