defmodule Hitchcock.Video do
  use Hitchcock.Web, :model

  alias Hitchcock.{Group, User}

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @derive {Poison.Encoder, only: [:id, :title, :is_uploaded, :description]}
  schema "videos" do
    field :title, :string
    field :is_uploaded, :boolean
    field :description, :string

    belongs_to :user, User, type: Ecto.UUID
    belongs_to :group, Group, type: Ecto.UUID

    timestamps
  end

  @allowed_fields ~w(title is_uploaded description user_id group_id)a
  @required_fields ~w(title)a

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @allowed_fields)
    |> validate_required(@required_fields)
  end
end
