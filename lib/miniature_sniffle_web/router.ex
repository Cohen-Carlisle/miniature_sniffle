defmodule MiniatureSniffleWeb.Router do
  use MiniatureSniffleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_user
  end

  scope "/user/", MiniatureSniffleWeb do
    pipe_through [:browser, :authenticate]

    get "/create_order", OrderController, :new
    post "/create_order", OrderController, :create
  end

  scope "/", MiniatureSniffleWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/comeonin", AccountController, :index
    post "/comeonin", AccountController, :login
    get "/logout", AccountController, :logout
  end

  defp assign_user(conn, _options) do
    # allow assigns to be set up and preserved for unit tests
    if Mix.env() == :test and Map.has_key?(conn.assigns, :user) do
      conn
    else
      assign(conn, :user, get_session(conn, :user))
    end
  end

  defp authenticate(conn, _options) do
    if conn.assigns.user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to view that page.")
      |> redirect(to: "/comeonin")
      |> halt()
    end
  end
end
