defmodule Hitchcock.Router do
  use Hitchcock.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Hitchcock do
    pipe_through :api
    resources "/groups", GroupController
    resources "/users", UserController
    resources "/videos", VideoController
  end
end
