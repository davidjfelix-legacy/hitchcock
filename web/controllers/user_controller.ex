defmodule Hitchcock.UserController do
  use Hitchcock.Web, :controller

  alias Hitchcock.User
  alias Ecto.UUID

  def index(conn, _params) do
    conn
    |> put_status(:forbidden)
    |> render(Hitchcock.ErrorView,
              "error.json",
              error: %{code: 403, message: "Listing forbidden"})
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render("show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Hitchcock.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    case UUID.cast(id) do
      {:ok, uuid} ->
        case Repo.get(User, uuid) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(Hitchcock.ErrorView,
                      "error.json",
                      error: %{code: 404, message: "ID not found", fields: ["id"]})
          user ->
            render(conn, "show.json", user: user)
        end
      :error ->
        conn
        |> put_status(:bad_request)
        |> render(Hitchcock.ErrorView,
                  "error.json",
                  error: %{code: 400, message: "Invalid ID"})
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    case UUID.case(id) do
      {:ok, uuid} ->
        case Repo.get(User, uuid) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(Hitchcock.ErrorView,
                      "error.json",
                      error: %{code: 404, message: "ID not found", fields: ["id"]})
          group ->
            changeset = User.changeset(user, user_params)
            case Repo.update(changeset) do
              {:ok, user} ->
                render(conn, "show.json", user: user)
              {:error, changeset} ->
                conn
                |> put_status(:unprocessable_entity)
                |> render(Hitchcock.ChangesetView,
                          "error.json",
                          changeset: changeset)
            end
        end
      :error ->
        conn
        |> put_status(:bad_request)
        |> render(Hitchcock.ErrorView,
                  "error.json",
                  error: %{code: 400, message: "Invalid ID"})
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    send_resp(conn, :no_content, "")
  end
end
