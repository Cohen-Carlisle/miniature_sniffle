defmodule MiniatureSniffleWeb.AccountControllerTest do
  use MiniatureSniffleWeb.ConnCase
  alias MiniatureSniffle.{Account, Repo}

  describe "GET /comeonin" do
    test "while unauthenticated, renders a login page", %{conn: conn} do
      resp_conn = get(conn, "/comeonin")
      assert html_response(resp_conn, 200) =~ "Login"
    end

    test "while already logged in, redirects to order creation", %{conn: conn} do
      resp_conn =
        conn
        |> assign(:current_user, "test user")
        |> get("/comeonin")

      assert html_response(resp_conn, 302)
      assert get_resp_header(resp_conn, "location") == ["/user/create_order"]
    end
  end

  describe "POST /comeonin" do
    setup do
      %Account.Pharmacy{}
      |> Account.Pharmacy.changeset(%{name: "some pharmacy"})
      |> Repo.insert!()

      :ok
    end

    test "with valid credentials, logs in the user", %{conn: conn} do
      resp_conn = post(conn, "/comeonin", %{pharmacy_name: "some pharmacy"})
      assert html_response(resp_conn, 302)
      assert get_session(resp_conn, :current_user) == "some pharmacy"
      assert get_resp_header(resp_conn, "location") == ["/user/create_order"]
    end

    test "with invalid credentials, returns to login page", %{conn: conn} do
      resp_conn = post(conn, "/comeonin", %{pharmacy_name: "not a pharmacy"})
      assert html_response(resp_conn, 302)
      assert get_session(resp_conn, :current_user) == nil
      assert get_resp_header(resp_conn, "location") == ["/comeonin"]
    end
  end

  test "GET /logout redirects to login", %{conn: conn} do
    resp_conn =
      conn
      |> authenticate()
      |> get("/logout")

    assert html_response(resp_conn, 302)
    assert get_session(resp_conn, :current_user) == nil
    assert get_resp_header(resp_conn, "location") == ["/comeonin"]
  end

  defp authenticate(conn) do
    %Account.Pharmacy{}
    |> Account.Pharmacy.changeset(%{name: "auth pharmacy"})
    |> Repo.insert!()

    session =
      conn
      |> post("/comeonin", %{pharmacy_name: "auth pharmacy"})
      |> get_resp_header("set-cookie")
      |> List.first()
      |> (&Regex.run(~r{_miniature_sniffle_key=[^;]+}, &1)).()
      |> List.first()

    put_req_header(conn, "cookie", session)
  end
end
