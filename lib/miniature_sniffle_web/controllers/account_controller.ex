defmodule MiniatureSniffleWeb.AccountController do
  use MiniatureSniffleWeb, :controller
  alias MiniatureSniffle.Account

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn, %{"pharmacy_name" => pharmacy_name}) do
    with {:ok, pharmacy} <- Account.get_pharmacy(pharmacy_name)
    do
      conn
      |> put_flash(:info, "Welcome to MiniatureSniffle, #{pharmacy.name}.")
      |> render("index.html")
    else
      {:error, :pharmacy_not_found} ->
        conn
        |> put_flash(:error, "Sorry, that pharmacy was not found.")
        |> render("index.html")
    end
  end
end
