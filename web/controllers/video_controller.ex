defmodule Hitchcock.VideoController do
  use Hitchcock.Web, :controller

  alias Hitchcock.{Video, ErrorView}
  alias Ecto.UUID


  def index(conn, _params) do
    videos = Repo.all(Video)
    render(conn, "index.json", videos: videos)
  end


  def show(conn, %{"id" => id}) do
    case UUID.cast(id) do
      {:ok, uuid} ->
        case Repo.get(Video, uuid) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(ErrorView, "404.json", type: "Video")

          video ->
            render(conn, "show.json", video: video)
        end

      :error ->
        conn
        |> put_status(:bad_request)
        |> render(ErrorView, "400.json", %{description: "Invalid request.", fields: ["id"]})
    end
  end


  def create(conn, video_params) do
    changeset = Video.changeset(%Video{}, video_params)

    case Repo.insert(changeset) do
      {:ok, video} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", video_path(conn, :show, video.id))
        |> render("show.json", video: video)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ErrorView, "422.json", changeset: changeset)
    end
  end


  def update(conn, video_params) do
    case UUID.cast(video_params["id"]) do
      {:ok, uuid} ->
        case Repo.get(Video, uuid) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(ErrorView, "404.json", type: "Video")

          video ->
            changeset = Video.changeset(video, video_params)
            case Repo.update(changeset) do
              {:ok, video} ->
                render(conn, "show.json", video: video)

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
        case Repo.get(Video, uuid) do
          nil ->
            conn
            |> put_status(:not_found)
            |> render(ErrorView, "404.json", %{type: "Video"})

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
