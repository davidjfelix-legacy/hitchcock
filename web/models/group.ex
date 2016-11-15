defmodule Hitchcock.Group do
  use Hitchcock.Web, :model

  alias Hitchcock.{User, UserGroup}

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "groups" do
    field :name, :string
    field :is_user_group, :boolean

    # Has one or none. Canonically, when is_user_group is set true
    has_one :user_group, UserGroup
    has_one :user_group_user, through: [:user_group, :user]

    # The user who created and owns the group if is_user_group is false,
    # this can be changed, otherwise it can't as it's named after the user
    belongs_to :user, User, type: Ecto.UUID

    timestamps
  end

  @allowed_fields ~w(name is_user_group user_id)a
  @required_fields ~w(name user_id)a

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
