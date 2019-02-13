defmodule MiniatureSniffleWeb.OrderController do
  use MiniatureSniffleWeb, :controller
  alias MiniatureSniffle.Requisition

  def new(conn, _params) do
    select_options = Requisition.order_select_options(conn.assigns.user.id)
    cs = Requisition.Order.changeset(%Requisition.Order{}, %{})
    render(conn, "new.html", select_options: select_options, cs: cs)
  end

  def create(conn, %{"order" => %{"location_id" => location_id} = order_params}) do
    # I wish we could run the user location assoc check after changeset validations
    # Should be possible in a transaction... but that's too goldplated for now.
    with :ok <- Requisition.check_user_location_assoc(conn.assigns.user.id, location_id),
         {:ok, %{id: id}} <- Requisition.create_order(order_params) do
      conn
      |> put_flash(:info, "Order #{id} successfully created.")
      |> redirect(to: Routes.order_path(conn, :new))
    else
      {:error, :user_and_location_not_associated} ->
        conn
        |> put_flash(:error, "You no can has location!")
        |> redirect(to: Routes.order_path(conn, :new))

      {:error, cs} ->
        select_options = Requisition.order_select_options(conn.assigns.user.id)

        conn
        |> put_flash(:error, "Oops, something went wrong.")
        |> render("new.html", select_options: select_options, cs: cs)
    end
  end
end
