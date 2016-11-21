defmodule Hitchcock.GroupController do
  use Hitchcock.Web, :controller

  alias Hitchcock.{AuthenticationController, Group}
  alias Ecto.UUID
  alias Guardian.Plug.EnsureAuthenticated

  plug EnsureAuthenticated, [handler: AuthenticationController] when action in [:create, :update, :delete]


  def index(conn, _params) do
    groups = Repo.all(Group)
    render(conn, "index.json", groups: groups)
  end

  def create(conn, group_params) do
    current_user = Guardian.Plug.current_resource(conn)
    group_params = Map.merge(group_params, %{user_id: current_user.id})
    changeset = Group.changeset(%Group{}, group_params)

    case Repo.insert(changeset) do
      {:ok, group} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", group_path(conn, :show, group))
        |> render("show.json", group: group)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Hitchcock.ChangesetView,
                  "error.json",
                  changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    case UUID.cast(id) do
      {:ok, uuid} ->
        case Repo.get(Group, uuid) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(Hitchcock.ErrorView,
                      "error.json",
                      error: %{code: 404, message: "ID not found", fields: ["id"]})
          group ->
            render(conn, "show.json", group: group)
        end
      :error ->
        conn
        |> put_status(:bad_request)
        |> render(Hitchcock.ErrorView,
                  "error.json",
                  error: %{code: 400, message: "Invalid ID"})
    end
  end

  def update(conn, group_params) do
    # FIXME: auth
    case UUID.cast(group_params["id"]) do
      {:ok, uuid} ->
        case Repo.get(Group, uuid) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(Hitchcock.ErrorView,
                      "error.json",
                      error: %{code: 404, message: "ID not found", fields: ["id"]})
          group ->
            changeset = Group.changeset(group, group_params)
            case Repo.update(changeset) do
              {:ok, group} ->
                render(conn, "show.json", group: group)
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
    # FIXME: auth
    group = Repo.get!(Group, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(group)

    send_resp(conn, :no_content, "")
  end
end
