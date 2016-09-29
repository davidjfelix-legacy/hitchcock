defmodule Hitchcock.UserControllerTest do
  use Hitchcock.ConnCase

  alias Hitchcock.User
  @valid_attrs %{
    username: "testuser",
    email: "testuser@test.com",
  }
  @create_attrs %{
    username: "testuser",
    email: "testuser@test.com",
    password: "testpassword"
  }
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert json_response(conn, 200) == []
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{
      username: "testuser1",
      email: "testuser@test.com",
      encrypted_password: "test"
    }
    conn = get conn, user_path(conn, :show, user)
    assert json_response(conn, 200) == %{"id" => user.id}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show,  Ecto.UUID.generate())
    end
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    user = Repo.insert! %User{
      username: "testuser1",
      email: "testuser@test.com",
      encrypted_password: "test"
    }
    conn = delete conn, user_path(conn, :delete, user)
    assert response(conn, 204)
    refute Repo.get(User, user.id)
  end
end
