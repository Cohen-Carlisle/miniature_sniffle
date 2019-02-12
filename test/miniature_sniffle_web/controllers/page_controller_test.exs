defmodule MiniatureSniffleWeb.PageControllerTest do
  use MiniatureSniffleWeb.ConnCase

  test "GET /", %{conn: conn} do
    resp_conn = get(conn, "/")
    assert html_response(resp_conn, 302)
    assert get_resp_header(resp_conn, "location") == ["/comeonin"]
  end
end
