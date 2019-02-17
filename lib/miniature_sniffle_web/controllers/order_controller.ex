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

  def new2(conn, _params) do
    select_options = Requisition.order_select_options(conn.assigns.user.id)
    render(conn, "new2.html", select_options: select_options)
  end

  def create2(conn, params) do
    create_order_params = create_order_params(params["order"])

    case Requisition.create_order2(create_order_params, conn.assigns.user.id) do
      {:ok, %{id: id}} ->
        conn
        |> put_flash(:info, "Order #{id} successfully created.")
        |> redirect(to: Routes.order_path(conn, :new2))

      {:error, errors} ->
        select_options = Requisition.order_select_options(conn.assigns.user.id)

        conn
        |> assign(:errors, errors)
        |> put_flash(:error, "Oops, something went wrong.")
        |> render("new2.html", select_options: select_options)
    end
  end

  defp create_order_params(params) do
    %{
      location: location_params(params),
      patient: patient_params(params),
      prescription: prescription_params(params)
    }
  end

  defp location_params(%{"location_id" => id}) when id not in [nil, ""] do
    %{id: id}
  end

  defp location_params(params) do
    atomize_params(params, [:latitude, :longitude])
  end

  defp patient_params(%{"patient_id" => id}) when id not in [nil, ""] do
    %{id: id}
  end

  defp patient_params(params) do
    atomize_params(params, [:first_name, :last_name])
  end

  defp prescription_params(%{"prescription_id" => id}) when id not in [nil, ""] do
    %{id: id}
  end

  defp prescription_params(params) do
    atomize_params(params, [:name])
  end
end
