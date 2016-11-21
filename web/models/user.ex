defmodule Hitchcock.User do
  use Hitchcock.Web, :model

  alias Hitchcock.{Group, UserGroup, Video}

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  @derive {Poison.Encoder, only: [:id, :username, :email]}
  schema "users" do
    field :username, :string
    field :email, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true

    # Has one. A user_group is created when user is created via controller
    has_one :user_group, UserGroup
    has_one :user_group_group, through: [:user_group, :group]

    has_many :owned_groups, Group, foreign_key: "owner_id"
    has_many :videos, Video

    many_to_many :groups, Group, join_through: "group_members"

    timestamps
  end

  @allowed_fields ~w(username email password encrypted_password)a
  @required_fields ~w(username email)a

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @allowed_fields)
    |> generate_encrypted_password
    |> validate_required(@required_fields)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> validate_required([:encrypted_password], message: "can't be blank (set by password)")
  end

  defp generate_encrypted_password(current_changeset) do
    case current_changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(current_changeset, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        current_changeset
    end
  end
end
