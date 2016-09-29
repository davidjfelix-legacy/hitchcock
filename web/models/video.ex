defmodule Hitchcock.Video do
  use Hitchcock.Web, :model

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @derive {Poison.Encoder, only: [:id, :title, :url, :description]}
  schema "videos" do
    field :title, :string
    field :url, :string
    field :description, :string

    belongs_to :owner, User

    timestamps
  end

  @required_fields ~w(title url description)
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
