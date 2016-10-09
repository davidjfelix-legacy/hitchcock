defmodule Hitchcock.Video do
  use Hitchcock.Web, :model

  alias Hitchcock.{Group, User}

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @derive {Poison.Encoder, only: [:id, :title, :url, :description]}
  schema "videos" do
    field :title, :string
    field :url, :string
    field :description, :string

    belongs_to :owner, User, type: Ecto.UUID
    belongs_to :group, Groug, type: Ecto.UUID

    timestamps
  end

  @required_fields ~w(title url description owner_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
