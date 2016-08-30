defmodule Hitchcock.VideoController do
  use Hitchcock.Web, :controller

  alias Hitchcock.Video

  plug :scrub_params, "video" when action in [:create, :update]

  def index(conn, _params) do
    videos = Repo.all(Video)
    render(conn, "index.json", videos: videos)
  end

  def create(conn, %{"video" => video_params}) do
    changeset = Video.changeset(%Video{}, video_params)

    case Repo.insert(changeset) do
      {:ok, video} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", video_path(conn, :show, video))
        |> render("show.json", video: video)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Hitchcock.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    video = Repo.get!(Video, id)
    render(conn, "show.json", video: video)
  end

  def update(conn, %{"id" => id, "video" => video_params}) do
    video = Repo.get!(Video, id)
    changeset = Video.changeset(video, video_params)

    case Repo.update(changeset) do
      {:ok, video} ->
        render(conn, "show.json", video: video)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Hitchcock.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    video = Repo.get!(Video, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(video)

    send_resp(conn, :no_content, "")
  end
end
