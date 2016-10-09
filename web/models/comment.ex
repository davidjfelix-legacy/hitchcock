defmodule Hitchcock.Comment do
  use Hitchcock.Web, :model

  alias Hitchcock.{User, Video}

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "comments" do
    field :body, :string

    belongs_to :author, User, type: Ecto.UUID
    belongs_to :video, Video, type: Ecto.UUID

    timestamps
  end

  @required_fields ~w(body author_id, video_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
