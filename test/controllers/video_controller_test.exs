defmodule Hitchcock.VideoControllerTest do
  use Hitchcock.ConnCase, async: true

  alias Hitchcock.Video

  ### Test fixtures
  @video1 %{
    title: "TestVideo1",
  }
  @video2 %{
    title: "TestVideo2",
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end


  ### Index controller tests
  describe "index/2" do
    test "returns an array of videos when there are 2+ videos", %{conn: conn} do
      videos = [Video.changeset(%Video{}, @video1), Video.changeset(%Video{}, @video2)]

      expected = videos
                 |> Enum.map(&Repo.insert!(&1))
                 |> Enum.map(&stringify_keys/1)
                 |> Enum.map(&Map.take(&1, ["title", "id"]))

      response = conn
                 |> get(video_path(conn, :index))
                 |> json_response(200)

      assert response == expected
    end

    test "returns an array with 1 video when there is 1 video", %{conn: conn} do
      video = Video.changeset(%Video{}, @video1)

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
    test "returns a video when it exists", %{conn: conn} do
      expected = %Video{}
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
    test "returns the video with id when video is valid", %{conn: conn} do
      response = conn
                 |> post(video_path(conn, :create), @video1)
                 |> json_response(201)
      expected = Video
                 |> Repo.get_by!(Map.take(@video1, [:title, :email]))
                 |> stringify_keys
                 |> Map.take(["title", "id"])

      assert response == expected
    end

    test "returns location header when video is valid", %{conn: conn} do
      response = conn
                 |> post(video_path(conn, :create), @video1)
                 |> get_resp_header("location")

      # Response header is a key: array(values) mapping
      video = Video
             |> Repo.get_by!(Map.take(@video1, [:title, :email]))
      expected = [video_path(conn, :show, video.id)]

      assert response == expected
    end

    test "returns a server message with 422 error when video is invalid", %{conn: conn} do
      expected = %{
        "code" => 422,
        "description" => "JSON was unprocessable.",
        "fields" => %{
          "title" => ["can't be blank"]
        }
      }

      # Post an empty map
      response = conn
                 |> post(video_path(conn, :create), %{})
                 |> json_response(422)

      assert response == expected
    end

    test "does not return a location header when video is invalid", %{conn: conn} do
      # Post an empty map
      response = conn
                 |> post(video_path(conn, :create), %{})
                 |> get_resp_header("location")

      # Response header is a key: array(values) mapping
      expected = []

      assert response == expected
    end
  end


  ### Update controller tests
  describe "update/2" do
    test "returns updated video when valid complete video is provided", %{conn: conn} do
      expected = %Video{}
                 |> Map.merge(@video1)
                 |> Repo.insert!
                 |> stringify_keys
                 |> Map.take(["title", "id"])
                 |> Map.merge(%{"title" => "TestVideo3"})

      response = conn
                 |> put(video_path(conn, :update, expected["id"]), expected)
                 |> json_response(200)

      assert response == expected
    end

    test "returns updated video when valid partial video is provided", %{conn: conn} do
      expected = %Video{}
                 |> Map.merge(@video1)
                 |> Repo.insert!
                 |> stringify_keys
                 |> Map.take(["title", "id"])
                 |> Map.merge(%{"title" =>"TestVideo3"})

      patched = expected |> Map.take(["title"])

      response = conn
                 |> patch(video_path(conn, :update, expected["id"]), patched)
                 |> json_response(200)

      assert response == expected
    end

    test "returns a server message with 422 when invalid video is provided", %{conn: conn} do
      updated = %Video{}
                |> Map.merge(@video1)
                |> Repo.insert!
                |> stringify_keys
                |> Map.merge(%{"title" => 1})

      expected = %{"code" => 422, "description" => "JSON was unprocessable.", "fields" => %{"title" => ["is invalid"]}}

      response = conn
                 |> put(video_path(conn, :update, updated["id"]), updated)
                 |> json_response(422)

      assert response == expected
    end

    test "returns server message with 404 when video is not found", %{conn: conn} do
      expected = %{"code" => 404, "description" => "Video not found.", "fields" => ["id"]}
      response = conn
                 |> put(video_path(conn, :update, Ecto.UUID.generate()), @video1)
                 |> json_response(404)

      assert response == expected
    end

    test "returns a server message with 400 when a non-uuid id is provided", %{conn: conn} do
      expected = %{"code" => 400, "description" => "Invalid request.", "fields" => ["id"]}
      response = conn
                 |> put(video_path(conn, :update, "Fake ID"), @video1)
                 |> json_response(400)

      assert response == expected
    end
  end


  ### Delete controller tests
  describe "delete/2" do
    test "returns no content when video did exist", %{conn: conn} do
      video = %Video{}
             |> Map.merge(@video1)
             |> Repo.insert!

      expected = ""
      response = conn
                 |> delete(video_path(conn, :delete, video.id))
                 |> response(204)

      assert response == expected
    end

    test "returns a server message with 404 error when video does not exist", %{conn: conn} do
      expected = %{"code" => 404, "description" => "Video not found.", "fields" => ["id"]}

      response = conn
                 |> delete(video_path(conn, :delete, Ecto.UUID.generate()))
                 |> json_response(404)

      assert response == expected
    end

    test "returns a server message with 400 error when a non-uuid id is provided", %{conn: conn} do
      expected = %{"code" => 400, "description" => "Invalid request.", "fields" => ["id"]}
      response = conn
                 |> put(video_path(conn, :delete, "Fake ID"))
                 |> json_response(400)

      assert response == expected
    end
  end
end