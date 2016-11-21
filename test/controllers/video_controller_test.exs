defmodule Hitchcock.VideoControllerTest do
  use Hitchcock.ConnCase, async: true

  alias Hitchcock.{User, UserGroup, Video}

  ### Test fixtures
  @video1 %{
    title: "TestVideo1",
  }
  @video2 %{
    title: "TestVideo2",
  }

  setup %{conn: conn} do
    user1 = Repo.insert!(%User{
      username: "TestUser1",
      email: "Test1@test.com",
      encrypted_password: "fakecrypto"
    })

    user2 = Repo.insert!(%User{
      username: "TestUser2",
      email: "Test2@test.com",
      encrypted_password: "fakecrypto"
    })

    group1 = user1
             |> build_assoc(:groups)
             |> Map.merge(%{name: "TestUser1"})
             |> Repo.insert!

    group2 = user2
             |> build_assoc(:groups)
             |> Map.merge(%{name: "TestUser2"})
             |> Repo.insert!

    user_group1 = %UserGroup{user_id: user1.id, group_id: group1.id}
                  |> Repo.insert!

    user_group2 = %UserGroup{user_id: user2.id, group_id: group2.id}
                  |> Repo.insert!

    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user1)

    {:ok, %{
      conn: put_req_header(conn, "accept", "application/json"),
      user1: user1,
      group1: group1,
      user_group1: user_group1,
      user2: user2,
      group2: group2,
      user_group2: user_group2,
      jwt1: jwt,
    }}
  end


  ### Index controller tests
  describe "index/2" do
    test "returns an array of videos when there are 2+ videos", %{conn: conn, user1: user, group1: group} do
      videos = [
        Video.changeset(%Video{user_id: user.id, group_id: group.id}, @video1),
        Video.changeset(%Video{user_id: user.id, group_id: group.id}, @video2)
      ]

      expected = videos
                 |> Enum.map(&Repo.insert!(&1))
                 |> Enum.map(&stringify_keys/1)
                 |> Enum.map(&Map.take(&1, ["title", "id"]))

      response = conn
                 |> get(video_path(conn, :index))
                 |> json_response(200)

      assert response == expected
    end

    test "returns an array with 1 video when there is 1 video", %{conn: conn, user1: user, group1: group} do
      video = Video.changeset(%Video{user_id: user.id, group_id: group.id}, @video1)

      expected = video
                 |> Repo.insert!
                 |> stringify_keys
                 |> Map.take(["title", "id"])

      response = conn
                 |> get(video_path(conn, :index))
                 |> json_response(200)

      assert response == [expected]
    end

    test "returns an empty array when there are no videos", %{conn: conn} do
      expected = []
      response = conn
                 |> get(video_path(conn, :index))
                 |> json_response(200)

      assert response == expected
    end
  end


  ### Show controller tests
  describe "show/2" do
    test "returns a video when it exists", %{conn: conn, user1: user, group1: group} do
      expected = %Video{user_id: user.id, group_id: group.id}
                 |> Map.merge(@video1)
                 |> Repo.insert!
                 |> stringify_keys
                 |> Map.take(["title", "id"])

      response = conn
                 |> get(video_path(conn, :show, expected["id"]))
                 |> json_response(200)

      assert response == expected
    end

    test "returns a server message with 404 error when a video does not exist", %{conn: conn} do
      expected = %{"code" => 404, "description" => "Video not found.", "fields" => ["id"]}

      response = conn
                 |> get(video_path(conn, :show, Ecto.UUID.generate()))
                 |> json_response(404)

      assert response == expected
    end

    test "returns a server message with 400 error when a non-uuid id is provided", %{conn: conn} do
      expected = %{"code" => 400, "description" => "Invalid request.", "fields" => ["id"]}

      response = conn
                 |> get(video_path(conn, :show, "Fake ID"))
                 |> json_response(400)

      assert response == expected
    end
  end


  ### Create controller tests
  describe "create/2" do
    test "returns the video with id when video is valid", %{conn: conn, jwt1: jwt} do
      response = conn
                 |> put_req_header("authorization", jwt)
                 |> post(video_path(conn, :create), @video1)
                 |> json_response(201)
      expected = Video
                 |> Repo.get_by!(Map.take(@video1, [:title, :email]))
                 |> stringify_keys
                 |> Map.take(["title", "id"])

      assert response == expected
    end

    test "returns location header when video is valid", %{conn: conn, jwt1: jwt} do
      response = conn
                 |> put_req_header("authorization", jwt)
                 |> post(video_path(conn, :create), @video1)
                 |> get_resp_header("location")

      # Response header is a key: array(values) mapping
      video = Video
             |> Repo.get_by!(Map.take(@video1, [:title, :email]))
      expected = [video_path(conn, :show, video.id)]

      assert response == expected
    end

    test "returns a server message with 422 error when video is invalid", %{conn: conn, jwt1: jwt} do
      expected = %{
        "code" => 422,
        "description" => "JSON was unprocessable.",
        "fields" => %{
          "title" => ["can't be blank"]
        }
      }

      # Post an empty map
      response = conn
                 |> put_req_header("authorization", jwt)
                 |> post(video_path(conn, :create), %{})
                 |> json_response(422)

      assert response == expected
    end

    test "does not return a location header when video is invalid", %{conn: conn, jwt1: jwt} do
      # Post an empty map
      response = conn
                 |> put_req_header("authorization", jwt)
                 |> post(video_path(conn, :create), %{})
                 |> get_resp_header("location")

      # Response header is a key: array(values) mapping
      expected = []

      assert response == expected
    end
  end


  ### Update controller tests
  describe "update/2" do
    test "returns updated video when valid complete video is provided", %{conn: conn, user1: user, group1: group, jwt1: jwt} do
      expected = %Video{user_id: user.id, group_id: group.id}
                 |> Map.merge(@video1)
                 |> Repo.insert!
                 |> stringify_keys
                 |> Map.take(["title", "id"])
                 |> Map.merge(%{"title" => "TestVideo3"})

      response = conn
                 |> put_req_header("authorization", jwt)
                 |> put(video_path(conn, :update, expected["id"]), expected)
                 |> json_response(200)

      assert response == expected
    end

    test "returns updated video when valid partial video is provided", %{conn: conn, user1: user, group1: group, jwt1: jwt} do
      expected = %Video{user_id: user.id, group_id: group.id}
                 |> Map.merge(@video1)
                 |> Repo.insert!
                 |> stringify_keys
                 |> Map.take(["title", "id"])
                 |> Map.merge(%{"title" =>"TestVideo3"})

      patched = expected |> Map.take(["title"])

      response = conn
                 |> put_req_header("authorization", jwt)
                 |> patch(video_path(conn, :update, expected["id"]), patched)
                 |> json_response(200)

      assert response == expected
    end

    test "returns a server message with 422 when invalid video is provided", %{conn: conn, user1: user, group1: group, jwt1: jwt} do
      updated = %Video{user_id: user.id, group_id: group.id}
                |> Map.merge(@video1)
                |> Repo.insert!
                |> stringify_keys
                |> Map.merge(%{"title" => 1})

      expected = %{"code" => 422, "description" => "JSON was unprocessable.", "fields" => %{"title" => ["is invalid"]}}

      response = conn
                 |> put_req_header("authorization", jwt)
                 |> put(video_path(conn, :update, updated["id"]), updated)
                 |> json_response(422)

      assert response == expected
    end

    test "returns server message with 404 when video is not found", %{conn: conn, jwt1: jwt} do
      expected = %{"code" => 404, "description" => "Video not found.", "fields" => ["id"]}
      response = conn
                 |> put_req_header("authorization", jwt)
                 |> put(video_path(conn, :update, Ecto.UUID.generate()), @video1)
                 |> json_response(404)

      assert response == expected
    end

    test "returns a server message with 400 when a non-uuid id is provided", %{conn: conn, jwt1: jwt} do
      expected = %{"code" => 400, "description" => "Invalid request.", "fields" => ["id"]}
      response = conn
                 |> put_req_header("authorization", jwt)
                 |> put(video_path(conn, :update, "Fake ID"), @video1)
                 |> json_response(400)

      assert response == expected
    end
  end


  ### Delete controller tests
  describe "delete/2" do
    test "returns no content when video did exist", %{conn: conn, user1: user, group1: group, jwt1: jwt} do
      video = %Video{}
              |> Map.merge(@video1)
              |> Map.merge(%{user_id: user.id, group_id: group.id})
              |> Repo.insert!

      expected = ""
      response = conn
                 |> put_req_header("authorization", jwt)
                 |> delete(video_path(conn, :delete, video.id))
                 |> response(204)

      assert response == expected
    end

    test "returns a server message with 404 error when video does not exist", %{conn: conn, jwt1: jwt} do
      expected = %{"code" => 404, "description" => "Video not found.", "fields" => ["id"]}

      response = conn
                 |> put_req_header("authorization", jwt)
                 |> delete(video_path(conn, :delete, Ecto.UUID.generate()))
                 |> json_response(404)

      assert response == expected
    end

    test "returns a server message with 400 error when a non-uuid id is provided", %{conn: conn, jwt1: jwt} do
      expected = %{"code" => 400, "description" => "Invalid request.", "fields" => ["id"]}
      response = conn
                 |> put_req_header("authorization", jwt)
                 |> delete(video_path(conn, :delete, "Fake ID"))
                 |> json_response(400)

      assert response == expected
    end

    test "does not delete the video when the user does not own the video", %{conn: conn, user2: user, group2: group, jwt1: jwt} do
      video = %Video{}
              |> Map.merge(@video1)
              |> Map.merge(%{user_id: user.id, group_id: group.id})
              |> Repo.insert!

      expected = %{"code" => 403, "description" => "Forbidden", "fields" => ["user_id", "id"]}
      response = conn
                 |> put_req_header("authorization", jwt)
                 |> delete(video_path(conn, :delete, video.id))
                 |> json_response(403)

      assert response == expected
    end

    test "deletes the video when the user is in the group which owns the video", %{conn: conn, user2: user, group3: group, jwt1: jwt} do
      video = %Video{}
              |> Map.merge(@video1)
              |> Map.merge(%{user_id: user.id, group_id: group.id})
              |> Repo.insert!
    end
  end

  # FIXME: add auth tests on creating and editing video
end
