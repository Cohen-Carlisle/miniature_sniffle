defmodule MiniatureSniffleWeb.OrderController do
  use MiniatureSniffleWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(_conn, _params) do
    raise "NYI"
  end
end
