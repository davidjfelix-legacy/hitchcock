defmodule Hitchcock.CreateCommentStreamComments do
  use Hitchcock.Web, :model

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "comment_stream_comments" do
    field :time, :integer

    belongs_to :comment, Comment, type: Ecto.UUID

    timestamps
  end

  @required_fields ~w(time comment_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
