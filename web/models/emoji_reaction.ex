defmodule Hitchcock.EmojiReaction do
  use Hitchcock.Web, :model

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "emoji_reactions" do
    belongs_to :author, User, type: Ecto.UUID
    belongs_to :emoji, Emoji, type: Ecto.UUID
    belongs_to :video, Video, type: Ecto.UUID

    timestamps
  end

  @required_fields ~w(author_id emoji_id video_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
