defmodule MiniatureSniffleWeb.PageController do
  use MiniatureSniffleWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.account_path(conn, :index))
  end
end
