defmodule Hitchcock.ErrorView do
  use Hitchcock.Web, :view

  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("404.html", _assigns) do
    "Page not found"
  end

  def render("400.json", %{description: description, fields: fields}) do
    render(Hitchcock.ErrorView, "error.json", %{
      code: 400,
      description: description,
      fields: fields
    })
  end

  def render("401.json", _assigns) do
    render(Hitchcock.ErrorView, "error.json", %{
      code: 401,
      description: "Unauthorized",
      fields: ["www-authenticate"]
    })
  end

  def render("403.json", _assigns) do
    render(Hitchcock.ErrorView, "error.json", %{
      code: 403,
      description: "Forbidden",
      fields: ["user_id", "id"]
    })
  end

  def render("404.json", %{type: type}) do
    render(Hitchcock.ErrorView, "error.json", %{
      code: 404,
      description: type <> " not found.",
      fields: ["id"]
    })
  end

  def render("422.json", %{changeset: changeset}) do
    render(Hitchcock.ErrorView, "error.json", %{
      code: 422,
      description: "JSON was unprocessable.",
      fields: translate_errors(changeset)
    })
  end

  def render("500.html", _assigns) do
    "Server internal error"
  end

  def render("error.json", %{code: code, description: description, fields: fields}) do
    %{
      code: code,
      description: description,
      fields: fields
    }
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
