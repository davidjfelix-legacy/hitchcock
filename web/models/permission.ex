defmodule Hitchcock.Permission do
  use Hitchcock.Web, :model

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "permissions" do
    field :grant, :string

    belongs_to :user, User, type: Ecto.UUID

    timestamps
  end

  @required_fields ~w(grant, user_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
