defmodule Hitchcock.Repo.Migrations.CreatePollOptions do
  use Ecto.Migration

  def change do
    
    ### Poll Options
    create table(:poll_options, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :body, :text, null: false

      add :poll_id, references(:polls, on_delete: :delete_all, type: :uuid), null: false

      timestamps
    end
  end
end
