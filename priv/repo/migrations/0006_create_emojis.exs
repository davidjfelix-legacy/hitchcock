defmodule Hitchcock.Repo.Migrations.CreateEmojis do
  use Ecto.Migration

  def change do

    ### Emojis
    create table(:emojis, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :image_url, :string, null: false

      timestamps
    end

    # Emojis must have a unique name
    create unique_index(:emojis, [:name])

    # TODO: validate that the names have no spaces or symbols
  end
end
