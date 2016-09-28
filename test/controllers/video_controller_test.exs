defmodule Hitchcock.VideoControllerTest do
  use Hitchcock.ConnCase

  alias Hitchcock.Video
  @valid_attrs %{
    title: "some content",
    url: "https://assets.mg4.tv/v/1",
    description: "some description2"
  }
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, video_path(conn, :index)
    assert json_response(conn, 200) == []
  end
end
