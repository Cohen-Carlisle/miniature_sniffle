defmodule MiniatureSniffleWeb.Router do
  use MiniatureSniffleWeb, :router

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

  scope "/", MiniatureSniffleWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/comeonin", AccountController, :index
    post "/comeonin", AccountController, :login
  end

  # Other scopes may use custom stacks.
  # scope "/api", MiniatureSniffleWeb do
  #   pipe_through :api
  # end
end
