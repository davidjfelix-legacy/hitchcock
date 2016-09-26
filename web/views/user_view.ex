defmodule Hitchcock.UserView do
  use Hitchcock.Web, :view

  def render("index.json", %{users: users}) do
    render_many(users, Hitchcock.UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    %{id: user.id}
  end
end
