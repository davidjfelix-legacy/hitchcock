defmodule Hitchcock.Router do
  use Hitchcock.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/", Hitchcock do
    pipe_through :api
    resources "/auth", AuthenticationController, only: [:create, :delete]
    resources "/groups", GroupController
    resources "/users", UserController
    resources "/videos", VideoController
  end
end
