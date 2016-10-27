defmodule Hitchcock.UserView do
  use Hitchcock.Web, :view

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      username: user.username,
      email: user.email
    }
  end

  def render("index.json", %{users: users}) do
    render_many(users, Hitchcock.UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render(Hitchcock.UserView, "user.json", user: user)
  end
end
