defmodule Hitchcock.Emoji do
  use Hitchcock.Web, :model

  @primary_key {:id, Ecto.UUID, autogenerate:true}

  schema "emoji" do
    field :name, :string
    field :image_url, :string

    timestamps
  end

  @required_fields ~w(name image_url)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
