defmodule MiniatureSniffleWeb.AccountController do
  use MiniatureSniffleWeb, :controller
  alias MiniatureSniffle.Account

  def index(conn, _params) do
    case conn.assigns.user do
      nil ->
        render(conn, "index.html")

      user ->
        conn
        |> put_flash(:info, "Already logged in as #{user.name}.")
        |> redirect(to: Routes.order_path(conn, :new))
    end
  end

  def login(conn, %{"pharmacy_name" => pharmacy_name}) do
    case Account.get_pharmacy(pharmacy_name) do
      {:ok, pharmacy} ->
        conn
        |> put_session(:user, %{name: pharmacy.name, id: pharmacy.id})
        |> put_flash(:info, "Welcome to MiniatureSniffle, #{pharmacy.name}.")
        |> redirect(to: Routes.order_path(conn, :new))

      {:error, :pharmacy_not_found} ->
        conn
        |> put_flash(:error, "Sorry, that pharmacy was not found.")
        |> redirect(to: Routes.account_path(conn, :index))
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "You have been logged out.")
    |> redirect(to: Routes.account_path(conn, :index))
  end
end
