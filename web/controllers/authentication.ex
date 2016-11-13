defmodule Hitchcock.AuthenticationController do
  use Hitchcock.Web, :controller

  alias Hitchcock.{Authentication, ErrorView}

  def create(conn, session_params) do
    case Authentication.authenticate(session_params) do
      {:ok, user} ->
        {:ok, jwt, _full_claims} = user |> Guardian.encode_and_sign(:token)

        conn
        |> put_status(:created)
        |> render("show.json", jwt: jwt, user: user)

      :error ->
        conn
        |> put_status(:unauthorized)
        |> put_resp_header("www-authenticate", "Bearer realm=\"" <> authentication_path(conn, :create) <> "\"")
        |> render(ErrorView, "401.json")
    end
  end

  def delete(conn, _) do
    {:ok, claims} = Guardian.Plug.claims(conn)

    conn
    |> Guardian.Plug.current_token
    |> Guardian.revoke!(claims)

    conn
    |> render("delete.json")
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> put_resp_header("www-authenticate", "Bearer realm=\"" <> authentication_path(conn, :create) <> "\"")
    |> render(ErrorView, "401.json")
  end
end
