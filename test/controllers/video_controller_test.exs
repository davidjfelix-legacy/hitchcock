defmodule Hitchcock.VideoControllerTest do
  use Hitchcock.ConnCase

  alias Hitchcock.Video
  @valid_attrs %{title: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, video_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    video = Repo.insert! %Video{}
    conn = get conn, video_path(conn, :show, video)
    assert json_response(conn, 200)["data"] == %{"id" => video.id,
      "title" => video.title}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, video_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, video_path(conn, :create), video: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Video, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, video_path(conn, :create), video: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    video = Repo.insert! %Video{}
    conn = put conn, video_path(conn, :update, video), video: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Video, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    video = Repo.insert! %Video{}
    conn = put conn, video_path(conn, :update, video), video: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    video = Repo.insert! %Video{}
    conn = delete conn, video_path(conn, :delete, video)
    assert response(conn, 204)
    refute Repo.get(Video, video.id)
  end
end
