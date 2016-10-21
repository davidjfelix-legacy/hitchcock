defmodule Hitchcock.UserControllerTest do
  use Hitchcock.ConnCase, async: true

  alias Hitchcock.User

  ### Test fixtures
  @user1 %{
  }
  @user2 %{
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  ### Index tests
  describe "index/2" do
    test "returns an array of users when there are 2+ users", %{conn: conn} do
      users = [User.changeset(%User{}, @user1), User.changeset(%User{}, @user2)]

      expected = users
                 |> Enum.map(&Repo.insert!(&1))
                 |> Enum.map(&stringify_keys/1)

      response = conn
                 |> get(user_path(conn, :index))
                 |> json_response(200)

      assert response == expected
    end
  end


  ### Show tests
  # TODO write test
  test "show renders json for a user that exists when authenticated as that user", %{conn: conn} do
    assert true
  end

  # TODO write test
  test "show renders json for public user attributes for a user that exists", %{conn: conn} do
    assert true
  end

  test "show renders json for an error for a user that does not exist", %{conn: conn} do
    conn = get conn, user_path(conn, :show, Ecto.UUID.generate())
    assert json_response(conn, 404) == %{"code" => 404, "fields" => ["id"], "message" => "ID not found"}
  end
end
