defmodule Hitchcock.UserController do
  use Hitchcock.Web, :controller

  alias Hitchcock.{ErrorView, Group, User, UserGroup}
  alias Ecto.UUID


  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.json", users: users)
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
        # Create the user group
        changeset = Group.changeset(%Group{}, %{name: user.username, user_id: user.id, is_user_group: true})
        case Repo.insert(changeset) do
          {:ok, group} ->
            changeset = UserGroup.changeset(%UserGroup{}, %{group_id: group.id, user_id: user.id})
            case Repo.insert(changeset) do
              {:ok, user_group} ->
                conn
                |> put_status(:created)
                |> put_resp_header("location", user_path(conn, :show, user.id))
                |> render("show.json", user: user)
              {:error, changeset} ->
                Repo.delete!(user)
                Repo.delete!(group)
                # FIXME: make this more relevant for user and throw a 500 not 422
                conn
                |> put_status(:unprocessable_entity)
                |> render(ErrorView, "422.json", changeset: changeset)
            end
          {:error, changeset} ->
            # FIXME: make this more relevant for user and throw a 409 not 422
            conn
            |> put_status(:unprocessable_entity)
            |> render(ErrorView, "422.json", changeset: changeset)
        end
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
