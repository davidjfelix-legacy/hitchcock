defmodule Hitchcock.GroupView do
  use Hitchcock.Web, :view

  def render("index.json", %{groups: groups}) do
    render_many(groups, Hitchcock.GroupView, "show.json")
  end

  def render("show.json", %{group: group}) do
    %{id: group.id,
      name: group.name}
  end
end
