defmodule Hitchcock.Repo.Migrations.CreateDb do
  use Ecto.Migration

  def change do
    create table(:users) do

      timestamps
    end

    create table(:videos) do
      add :title, :string

      timestamps
    end
  end
end
