defmodule Hitchcock.Repo.Migrations.CreatePolls do
  use Ecto.Migration

  def change do
    
    ### Poll
    create table(:polls, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, null: false

      timestamps
    end
  end
end
