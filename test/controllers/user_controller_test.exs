defmodule Hitchcock.UserControllerTest do
  use Hitchcock.ConnCase, async: true

  alias Hitchcock.User

  ### Test fixtures
  @user1 %{
    username: "TestUser1",
    email: "Test1@test.com",
    password: "T3$t123456",
    password_confirmation: "T3$t123456"
  }
  @user2 %{
    username: "TestUser2",
    email: "Test2@test.com",
    password: "T3$t123456",
    password_confirmation: "T3$t123456"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end


  ### Index controller tests
  describe "index/2" do
    test "returns an array of users when there are 2+ users", %{conn: conn} do
      users = [User.changeset(%User{}, @user1), User.changeset(%User{}, @user2)]

      expected = users
                 |> Enum.map(&Repo.insert!(&1))
                 |> Enum.map(&stringify_keys/1)
                 |> Enum.map(&Map.take(&1, ["username", "email", "id"]))

      response = conn
                 |> get(user_path(conn, :index))
                 |> json_response(200)

      assert response == expected
    end

    test "returns an array with 1 user when there is 1 user", %{conn: conn} do
      user = User.changeset(%User{}, @user1)

      expected = user
                 |> Repo.insert!
                 |> stringify_keys
                 |> Map.take(["username", "email", "id"])

      response = conn
                 |> get(user_path(conn, :index))
                 |> json_response(200)

      assert response == [expected]
    end

    test "returns an empty array when there are no users", %{conn: conn} do
      expected = []
      response = conn
                 |> get(user_path(conn, :index))
                 |> json_response(200)

      assert response == expected
    end
  end


  ### Show controller tests
  describe "show/2" do
    test "returns a user when it exists", %{conn: conn} do
      expected = %User{}
                 |> Map.merge(@user1)
                 |> Map.merge(%{encrypted_password: "fakecrypto"})
                 |> Repo.insert!
                 |> stringify_keys
                 |> Map.take(["username", "email", "id"])

      response = conn
                 |> get(user_path(conn, :show, expected["id"]))
                 |> json_response(200)

      assert response == expected
    end

    test "returns a server message with 404 error when a user does not exist", %{conn: conn} do
      expected = %{"code" => 404, "description" => "User not found.", "fields" => ["id"]}

      response = conn
                 |> get(user_path(conn, :show, Ecto.UUID.generate()))
                 |> json_response(404)

      assert response == expected
    end

    test "returns a server message with 400 error when a non-uuid id is provided", %{conn: conn} do
      expected = %{"code" => 400, "description" => "Invalid request.", "fields" => ["id"]}

      response = conn
                 |> get(user_path(conn, :show, "Fake ID"))
                 |> json_response(400)

      assert response == expected
    end
  end


  ### Create controller tests
  describe "create/2" do
    test "returns the user with id when user is valid", %{conn: conn} do
      response = conn
                 |> post(user_path(conn, :create), @user1)
                 |> json_response(201)
      expected = User
                 |> Repo.get_by!(Map.take(@user1, [:username, :email]))
                 |> stringify_keys
                 |> Map.take(["username", "email", "id"])

      assert response == expected
    end

    test "returns location header when user is valid", %{conn: conn} do
      response = conn
                 |> post(user_path(conn, :create), @user1)
                 |> get_resp_header("location")

      # Response header is a key: array(values) mapping
      user = User
             |> Repo.get_by!(Map.take(@user1, [:username, :email]))
      expected = [user_path(conn, :show, user.id)]

      assert response == expected
    end

    test "returns a server message with 422 error when user is invalid", %{conn: conn} do
      expected = %{
        "code" => 422,
        "description" => "JSON was unprocessable.",
        "fields" => %{
          "username" => ["can't be blank"],
          "email" => ["can't be blank"],
          "encrypted_password" => ["can't be blank (set by password)"]
        }
      }

      # Post an empty map
      response = conn
                 |> post(user_path(conn, :create), %{})
                 |> json_response(422)

      assert response == expected
    end

    test "does not return a location header when user is invalid", %{conn: conn} do
      # Post an empty map
      response = conn
                 |> post(user_path(conn, :create), %{})
                 |> get_resp_header("location")

      # Response header is a key: array(values) mapping
      expected = []

      assert response == expected
    end
  end


  ### Update controller tests
  describe "update/2" do
    test "returns updated user when valid complete user is provided", %{conn: conn} do
      expected = %User{}
                 |> Map.merge(@user1)
                 |> Map.merge(%{encrypted_password: "fakecrypto"})
                 |> Repo.insert!
                 |> stringify_keys
                 |> Map.take(["username", "email", "id"])
                 |> Map.merge(%{"username" => "TestUser3"})

      response = conn
                 |> put(user_path(conn, :update, expected["id"]), expected)
                 |> json_response(200)

      assert response == expected
    end

    test "returns updated user when valid partial user is provided", %{conn: conn} do
      expected = %User{}
                 |> Map.merge(@user1)
                 |> Map.merge(%{encrypted_password: "fakecrypto"})
                 |> Repo.insert!
                 |> stringify_keys
                 |> Map.take(["username", "email", "id"])
                 |> Map.merge(%{"username" =>"TestUser3"})

      patched = expected |> Map.take(["username"])

      response = conn
                 |> patch(user_path(conn, :update, expected["id"]), patched)
                 |> json_response(200)

      assert response == expected
    end

    test "returns a server message with 422 when invalid user is provided", %{conn: conn} do
      updated = %User{}
                |> Map.merge(@user1)
                |> Map.merge(%{encrypted_password: "fakecrypto"})
                |> Repo.insert!
                |> stringify_keys
                |> Map.merge(%{"username" => 1})

      expected = %{"code" => 422, "description" => "JSON was unprocessable.", "fields" => %{"username" => ["is invalid"]}}

      response = conn
                 |> put(user_path(conn, :update, updated["id"]), updated)
                 |> json_response(422)

      assert response == expected
    end

    test "returns server message with 404 when user is not found", %{conn: conn} do
      expected = %{"code" => 404, "description" => "User not found.", "fields" => ["id"]}
      response = conn
                 |> put(user_path(conn, :update, Ecto.UUID.generate()), @user1)
                 |> json_response(404)

      assert response == expected
    end

    test "returns a server message with 400 when a non-uuid id is provided", %{conn: conn} do
      expected = %{"code" => 400, "description" => "Invalid request.", "fields" => ["id"]}
      response = conn
                 |> put(user_path(conn, :update, "Fake ID"), @user1)
                 |> json_response(400)

      assert response == expected
    end
  end


  ### Delete controller tests
  describe "delete/2" do
    test "returns no content when user did exist", %{conn: conn} do
      user = %User{}
             |> Map.merge(@user1)
             |> Map.merge(%{encrypted_password: "fakecrypto"})
             |> Repo.insert!

      expected = ""
      response = conn
                 |> delete(user_path(conn, :delete, user.id))
                 |> response(204)

      assert response == expected
    end

    test "returns a server message with 404 error when user does not exist", %{conn: conn} do
      expected = %{"code" => 404, "description" => "User not found.", "fields" => ["id"]}

      response = conn
                 |> delete(user_path(conn, :delete, Ecto.UUID.generate()))
                 |> json_response(404)

      assert response == expected
    end

    test "returns a server message with 400 error when a non-uuid id is provided", %{conn: conn} do
      expected = %{"code" => 400, "description" => "Invalid request.", "fields" => ["id"]}
      response = conn
                 |> put(user_path(conn, :delete, "Fake ID"))
                 |> json_response(400)

      assert response == expected
    end
  end
end
