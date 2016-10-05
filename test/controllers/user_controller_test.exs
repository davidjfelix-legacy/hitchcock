defmodule Hitchcock.UserControllerTest do
  use Hitchcock.ConnCase

  alias Hitchcock.User

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  ### Index tests
  # TODO write test
  test "index renders json for an error when not authenticated", %{conn: conn} do
    # conn = get conn, user_path(conn, :index)
    # assert json_response(conn, 401) == %{}
    assert true
  end

  test "index renders json for an error when authenticated", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert json_response(conn, 403) == %{"code" => 403, "message" => "Listing forbidden"}
  end

  # TODO write test
  test "index returns a 401 code when not authenticated", %{conn: conn} do
    # conn = get conn, user_path(conn, :index)
    # assert response(conn, 401)
    assert true
  end

  test "index returns a 403 code when authenticated", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert response(conn, 403)
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
