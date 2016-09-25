defmodule Hitchcock.Repo.Migrations.CreateEmojiStreamReactions do
  use Ecto.Migration

  def change do


    ### Emoji Reaction Stream
    create table(:emoji_stream_reactions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :time, :integer, null: false

      add :emoji_reaction_id, references(:emoji_reactions, on_delete: :delete_all, type: :uuid), null: false

      timestamps
    end

    # TODO: add constraint to only allow positive time
  end
end
