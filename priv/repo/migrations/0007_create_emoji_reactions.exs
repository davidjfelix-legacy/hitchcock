defmodule Hitchcock.Repo.Migrations.CreateEmojiReactions do
  use Ecto.Migration

  def change do

    ### Emoji Reactions
    create table(:emoji_reactions, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :emoji_id, references(:emojis, on_delete: :delete_all, type: :uuid), null: false
      add :author_id, references(:users, on_delete: :delete_all, type: :uuid), null: false
      add :video_id, references(:videos, on_delete: :delete_all, type: :uuid), null: false

      timestamps
    end

    # TODO: add constraint to only allow known emojis
  end
end
