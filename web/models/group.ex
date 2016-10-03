defmodule Hitchcock.Group do
  use Hitchcock.Web, :model

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "groups" do
    field :name, :string

    belongs_to :owner, User, type: Ecto.UUID

    timestamps
  end

  @required_fields ~w(name owner_id)
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
