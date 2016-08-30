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

    # /videos
    # /users
    # /groups
    # /permission_groups

    get "/", PageController, :index
  end

  scope "/docs", Hitchcock do
    pipe_through :browser

    get "*path", PageController, :index
  end
end
