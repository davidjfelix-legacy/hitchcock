defmodule Hitchcock.UserGroup do
  use Hitchcock.Web, :model

  alias Hitchcock.{Group, User}

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "user_groups" do
    belongs_to :group, Group, type: Ecto.UUID
    belongs_to :user, User, type: Ecto.UUID

    timestamps
  end

  @allowed_fields ~w(name is_user_group)a
  @required_fields ~w(name)a

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
