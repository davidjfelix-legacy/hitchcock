defmodule Hitchcock.UserController do
  use Hitchcock.Web, :controller

  alias Hitchcock.{User, ErrorView}
  alias Ecto.UUID


  def index(conn, _params) do
    users = Repo.all(User)

    conn
    |> render("index.json", users: users)
  end


  def show(conn, %{"id" => id}) do
    case UUID.cast(id) do
      {:ok, uuid} ->
        case Repo.get(User, uuid) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(ErrorView, "404.json", type: "User")

          user ->
            render(conn, "show.json", user: user)
        end

      :error ->
        conn
        |> put_status(:bad_request)
        |> render(ErrorView, "400.json", %{description: "Invalid request.", fields: ["id"]})
    end
  end


  def create(conn, user_params) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user.id))
        |> render("show.json", user: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ErrorView, "422.json", changeset: changeset)
    end
  end


  def update(conn, user_params) do
    case UUID.cast(user_params["id"]) do
      {:ok, uuid} ->
        case Repo.get(User, uuid) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(ErrorView, "404.json", type: "User")

          user ->
            changeset = User.changeset(user, user_params)
            case Repo.update(changeset) do
              {:ok, user} ->
                render(conn, "show.json", user: user)

              {:error, changeset} ->
                conn
                |> put_status(:unprocessable_entity)
                |> render(ErrorView, "422.json", changeset: changeset)
            end
        end

      :error ->
        conn
        |> put_status(:bad_request)
        |> render(ErrorView, "400.json", %{description: "Invalid request.", fields: ["id"]})
    end
  end


  def delete(conn, %{"id" => id}) do
    case UUID.cast(id) do
      {:ok, uuid} ->
        case Repo.get(User, uuid) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(ErrorView, "404.json", %{type: "User"})

          card ->
            Repo.delete!(card)
            send_resp(conn, :no_content, "")
        end

      :error ->
        conn
        |> put_status(:bad_request)
        |> render(ErrorView, "400.json", %{description: "Invalid request.", fields: ["id"]})
    end
  end
end
