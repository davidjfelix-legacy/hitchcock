defmodule Hitchcock.UserTest do
  use Hitchcock.ModelCase

  alias Hitchcock.User

  @valid_attrs %{
    username: "testuser",
    email: "testuser@test.com",
    password: "s0meP@$$word123456"
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with missing attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
