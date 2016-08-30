defmodule Hitchcock.VideoView do
  use Hitchcock.Web, :view

  def render("index.json", %{videos: videos}) do
    %{data: render_many(videos, Hitchcock.VideoView, "video.json")}
  end

  def render("show.json", %{video: video}) do
    %{data: render_one(video, Hitchcock.VideoView, "video.json")}
  end

  def render("video.json", %{video: video}) do
    %{id: video.id,
      title: video.title}
  end
end
